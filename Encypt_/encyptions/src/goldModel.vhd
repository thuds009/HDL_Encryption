Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goldModel is 
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
	Done		:out std_logic
	);
end entity goldModel;

architecture Behavioral of goldModel is	 

---------internal signals-----------------
signal key_reg    : std_logic_vector(127 downto 0);
signal iv_reg     : std_logic_vector(127 downto 0);
signal data_reg   : std_logic_vector(127 downto 0);

signal key_count  : std_logic_vector(1 downto 0);
signal iv_count   : std_logic_vector(1 downto 0);
signal data_count : std_logic_vector(1 downto 0);

----internal signals for FSM-----
type state_type is (IDLE, LOAD, COMPUTE, OUTPUT);
signal state      : state_type := IDLE;
signal next_state : state_type := IDLE;

----internal signals for output------
signal result_reg     : std_logic_vector(127 downto 0) := (others => '0');
signal output_counter : std_logic_vector(1 downto 0)  := (others => '0');

--cbc signals
signal cbc_in    : std_logic_vector(127 downto 0);
signal sub_out   : std_logic_vector(127 downto 0);
signal shift_out : std_logic_vector(127 downto 0);
signal mix_out   : std_logic_vector(127 downto 0);

component subBytes is 
   port(state_in : in std_logic_vector(127 downto 0);
        state_out: out std_logic_vector(127 downto 0));
end component;

component rowShift is
    port(original_state : in std_logic_vector(127 downto 0);
         shifted_state  : out std_logic_vector(127 downto 0));
end component;

component mixColumn is
    port(shifted_state : in std_logic_vector(127 downto 0);
         mixed_state   : out std_logic_vector(127 downto 0));
end component;

component addRoundKey is
    port(state_in  : in std_logic_vector(127 downto 0);
         round_key : in std_logic_vector(127 downto 0);
         state_out : out std_logic_vector(127 downto 0));
end component;

begin
-----key load-------- 

process(clock, reset)  
begin
	if reset = '1' then 
		
		key_reg 	<= (others => '0');
		key_count 	<= (others => '0');
		
	elsif rising_edge(clock) then
		
		if key_load = '1' then
			--store dataIn into correct 32 bit slice
			case key_count is 
				
				when "00" =>
				key_reg(127 downto 96) <= dataIn;
				
				when "01" =>
				key_reg(95 downto 64) <= dataIn;
				
				when "10" => 
				key_reg(63 downto 32) <= dataIn;
					
				when "11" =>
				key_reg(31 downto 0) <= dataIn;	
				
				when others => null;
					
			end case;
			
			--increment counter
			if key_count = "11" then 
				key_count <= "00";	--wrap if fully loaded
			else
				key_count <= std_logic_vector(unsigned(key_count) + 1);
			end if;
			
			end if;	
		end if;
	end process;
	
------Initial Value Load--------

process(clock, reset)
begin	
	if reset = '1' then
		iv_reg		<= (others => '0');
		iv_count 	<= (others => '0');
		
	elsif rising_edge(clock) then
		
		if IV_load = '1' then 
			--store dataIn into correct 32 bit slice
			case iv_count is 
				
				when "00" =>
				iv_reg(127 downto 96) <= dataIn;
				
				when "01" =>
				iv_reg(95 downto 64) <= dataIn;
				
				when "10" => 
				iv_reg(63 downto 32) <= dataIn;
				
				when "11" =>
				iv_reg(31 downto 0) <= dataIn;
				
				when others => null;
				
			end case;
			
			--increment counter
			if iv_count = "11" then
				iv_count <= "00"; --wrap if fully loaded
			else
				iv_count <= std_logic_vector(unsigned(iv_count) + 1);
			end if;
			
			end if;
		end if;
	end process;	
				
------Data Block Load-----

process(clock, reset)
begin
	if reset = '1' then 
		data_reg 	<= (others => '0');
		data_count	<= (others => '0');
	
	elsif rising_edge(clock) then 
	
		if db_load = '1' then
            -- store dataIn into correct 32-bit slice
            case data_count is

                when "00" =>
                data_reg(127 downto 96) <= dataIn;

                when "01" =>
                 data_reg(95 downto 64) <= dataIn;

                when "10" =>
                data_reg(63 downto 32) <= dataIn;

                when "11" =>
                data_reg(31 downto 0) <= dataIn;
				
				when others => null;

            end case;

            -- increment counter
            if data_count = "11" then
                data_count <= "00";  -- wrap when block fully loaded
            else
				data_count <= std_logic_vector(unsigned(data_count) + 1);
            end if;

        	end if;
    	end if;
	end process;
	
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
    -- when loading is finished (all load signals low), go to COMPUTE
    if key_load = '0' and IV_load = '0' and db_load = '0' then
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
	--After four sections out output have been transmitted 
	next_state <= IDLE;
	
	end case;
	end process;

--------- Output ----------
process(clock, reset)
begin
	if reset = '1' then
		
		dataOut			<= (others => '0');
		output_counter 	<= "00";
		Done			<= '0';
		
	elsif rising_edge(clock) then
		
		-- Only output when in OUTPUT state
		if state = OUTPUT then
			
			Done <= '0';
			
			case output_counter is 
				when "00" =>
				dataOut <= result_reg(127 downto 96);
				
				when "01" =>
				dataOut <= result_reg(95 downto 64);
				
				when "10" =>
				dataOut <= result_reg(63 downto 32);
				
				when "11" => 
				dataOut <= result_reg(31 downto 0);
				
				when others => null;
			end case;
			
			--increment counter
			if output_counter = "11" then 
				output_counter <= "00";
				Done <= '1';
			else
				output_counter <= std_logic_vector(unsigned(output_counter) + 1);
			end if;
		else
			-- Not in output state -> reset done and counter
			Done <= '0';
			output_counter <= "00";
			end if;
			
		end if;
	end process;
		
		----- AES COMPUTE PLACEHOLDER --------
--process(clock, reset)
--begin
--   if reset = '1' then
--        result_reg <= (others => '0');
--
--    elsif rising_edge(clock) then
--
--        if state = COMPUTE then
            -- TEMPORARY PLACEHOLDER
            -- Replace this with real AES later
--           result_reg <= data_reg XOR key_reg;  -- simple XOR for testing

            -- (Optional: pulse DONE here if you are skipping OUTPUT state)
--        end if;

--   end if;
--end process;

-- CBC input
cbc_in <= data_reg xor iv_reg when CBC_mode='1' else data_reg;

U_subbytes : subBytes
    port map( state_in => cbc_in, state_out => sub_out );

U_shiftRows : rowShift
    port map( original_state => sub_out, shifted_state => shift_out);

U_mixColumns : mixColumn
    port map( shifted_state => shift_out, mixed_state => mix_out);

U_addRoundKey : addRoundKey
port map( state_in => mix_out, round_key => key_reg, state_out => result_reg );

end architecture behavioral;	
	

	

	










		
			
				
				