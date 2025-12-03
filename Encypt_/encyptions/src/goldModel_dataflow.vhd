Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goldModelDataflow is 
	port (
	clock 		:in std_logic;
	reset		:in std_logic; 
	
	--Load controls
	key_load	:in std_logic;
	IV_load		:in std_logic;
	db_load		:in std_logic;
	
	--Stream and mode selection
	stream		:in std_logic;
	ECB_mode	:in std_logic;
	CBC_mode	:in std_logic; 
	
	--32 bit data path
	dataIn		:in std_logic_vector(0 to 31);
	dataOut		:out std_logic_vector(0 to 31);
	
	--Completion of operation
	Done		:out std_logic;
	
	--test
	state_debug : out std_logic_vector(1 downto 0);
kcnt_debug  : out std_logic_vector(1 downto 0);
icnt_debug  : out std_logic_vector(1 downto 0);
dcnt_debug  : out std_logic_vector(1 downto 0)
	);
end entity goldModelDataflow;

architecture Dataflow of goldModelDataflow is 

--internal signals
--AES datapath signals
signal sub_out	: std_logic_vector(127 downto 0);
signal shift_out: std_logic_vector(127 downto 0);
signal mix_out	: std_logic_vector(127 downto 0);
signal add_out 	: std_logic_vector(127 downto 0);
signal result_reg: std_logic_vector(127 downto 0);

--registers
signal key_reg	: std_logic_vector(127 downto 0);
signal iv_reg	: std_logic_vector(127 downto 0);
signal data_reg	: std_logic_vector(127 downto 0);

--counters
signal key_count: std_logic_vector(1 downto 0);
signal iv_count	: std_logic_vector(1 downto 0);
signal data_count: std_logic_vector(1 downto 0); 
signal output_counter: std_logic_vector(1 downto 0);

--FSM state signals
type state_type is (IDLE, LOAD, COMPUTE, OUTPUT);
signal state		: state_type;
signal next_state	: state_type;

--CBC signal
signal cbc_in : std_logic_vector(127 downto 0);
	
--components

component subBytes is 
		 port(state_in : in std_logic_vector(127 downto 0);
         state_out: out std_logic_vector(127 downto 0));
end component;


component rowShift is
    port(original_key : in std_logic_vector(127 downto 0);
         shifted_key  : out std_logic_vector(127 downto 0));
end component;

component mixColumn is
    port(shifted_key : in std_logic_vector(127 downto 0);
         mixed_state : out std_logic_vector(127 downto 0));
end component;	

component addRoundKey is
    port(state_in  : in std_logic_vector(127 downto 0);
         round_key : in std_logic_vector(127 downto 0);
         state_out : out std_logic_vector(127 downto 0));
end component;

begin 
	--input selection CBC / EBC

	cbc_in <= data_reg xor iv_reg when CBC_mode='1' else
	data_reg;
	
	--AES Datapath
	
	--SubBytes transformation
	U_subbytes : subBytes
    port map(
        state_in  => cbc_in,
        state_out => sub_out
    );	
	
	--ShiftRows transformation
	U_shiftRows : rowShift
    port map(
        original_key => sub_out,
        shifted_key  => shift_out
    );
	
	--mixColums transformation
	U_mixColumns : mixColumn
  	port map(
	  shifted_key => shift_out,
	  mixed_state => mix_out
	  );
	  
	--addRoundKey (final XOR with the AES key)
	u_addrk : addRoundKey
	port map(
	state_in => mix_out,
	round_key => key_reg,
	state_out => add_out
	);
	
	--store the final 128-bit output of the round 
	result_reg <= add_out;
	
	--key register and count
	
key_reg <= (others => '0') when reset='1' 
else
	dataIn & key_reg(95 downto 0) when 
	(rising_edge(clock) and key_load='1' and key_count="00")
	
else
	key_reg(127 downto 96) & dataIn & key_reg(63 downto 0) when 
	(rising_edge(clock) and key_load='1' and key_count="01")
	
else
    key_reg(127 downto 64) & dataIn & key_reg(31 downto 0) when 
	(rising_edge(clock) and key_load='1' and key_count="10") 
	
else
    key_reg(127 downto 32) & dataIn when 
	(rising_edge(clock) and key_load='1' and key_count="11")
	
else
	key_reg;
	
	
	key_count <= "00" when reset='1' 
else
	"00" when 
	(rising_edge(clock) and key_load='1' and key_count="11") 
else
	std_logic_vector(unsigned(key_count)+1) when
	(rising_edge(clock) and key_load='1') 
else
	key_count;
	
	--iv register and count
iv_reg <= (others => '0') when 
reset='1'
else
	result_reg
	when (rising_edge(clock) and state = Output and CBC_mode='1')
else 
	dataIn & iv_reg(95 downto 0) when 
	(rising_edge(clock) and IV_load='1' and iv_count="00") 
else
	iv_reg(127 downto 96) & dataIn & iv_reg(63 downto 0) when
	(rising_edge(clock) and IV_load='1' and iv_count="01") 
else
    iv_reg(127 downto 64) & dataIn & iv_reg(31 downto 0) when
	(rising_edge(clock) and IV_load='1' and iv_count="10") 
else
	iv_reg(127 downto 32) & dataIn when 
	(rising_edge(clock) and IV_load='1' and iv_count="11") 
else
	iv_reg;	
	
	
iv_count <= "00" when 
	reset='1' 
else
  	"00" when
	(rising_edge(clock) and IV_load='1' and iv_count="11") 
else
   	std_logic_vector(unsigned(iv_count)+1) when
	(rising_edge(clock) and IV_load='1') 
else
	iv_count;	
	
	--data register and count 
data_reg <= (others => '0') when 
	reset='1' 
else
 	dataIn & data_reg(95 downto 0) when
	(rising_edge(clock) and db_load='1' and data_count="00") 
else
 	data_reg(127 downto 96) & dataIn & data_reg(63 downto 0) when
	(rising_edge(clock) and db_load='1' and data_count="01") 
else
  	data_reg(127 downto 64) & dataIn & data_reg(31 downto 0) when
	(rising_edge(clock) and db_load='1' and data_count="10") 
else
   	data_reg(127 downto 32) & dataIn when 
	(rising_edge(clock) and db_load='1' and data_count="11") 
else
	data_reg;
	
	
------FSM STATE REGISTER------

process(clock, reset)
begin
	if reset = '1' then
		state <= IDLE;
		
	elsif rising_edge(clock) then
		state <= next_state;
	end if;
	end process;
	
-------FSM Next State Logic------
process(state, key_count, iv_count, data_count, key_load, IV_load, db_load)
begin

case state is
	
	---------------------------
	when IDLE =>
	--move to LOAD when any other load starts
	if key_load = '1' or IV_load = '1' or db_load = '1' then 
		next_state <= LOAD;
	else
		next_state <= IDLE;
	end if;
	
	---------------------------
	when LOAD =>
    -- transition ONLY when all loads have dropped AND all counters wrapped
    if key_load = '0' and IV_load = '0' and db_load = '0' and
       key_count = "00" and iv_count = "00" and data_count = "00" then
        next_state <= COMPUTE;
    else
        next_state <= LOAD;
    end if;
	
	---------------------------
	when COMPUTE =>
	--After AES comp is done (1 gold model cycle)
	next_state <= OUTPUT;
	
	---------------------------
	when OUTPUT =>
    if output_counter = "11" then
        next_state <= IDLE;
    else
        next_state <= OUTPUT;
    end if;
	
	end case;
	end process;
	
--Output

dataOut <= result_reg(127 downto 96) when output_counter="00" 
else
	result_reg(95  downto 64) when output_counter="01" 
else
	result_reg(63  downto 32) when output_counter="10" 
else
    result_reg(31  downto 0);
		   
Done <= '1' when (state = OUTPUT and output_counter = "11") else '0'; 
	
output_counter <= "00" when reset='1' else
	"00" when (rising_edge(clock) and state /= OUTPUT) 
else
 	std_logic_vector(unsigned(output_counter)+1)when 
	(rising_edge(clock) and state = OUTPUT) 
else
	output_counter;  

	state_debug <= 
    "00" when state = IDLE else
    "01" when state = LOAD else
    "10" when state = COMPUTE else
    "11";  -- OUTPUT

kcnt_debug <= key_count;
icnt_debug <= iv_count;
dcnt_debug <= data_count;

end architecture;