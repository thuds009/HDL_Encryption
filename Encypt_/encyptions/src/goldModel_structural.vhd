library ieee;  

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goldModelStructural is
	port (
		clock : in std_logic;
		reset : in std_logic;
		
		--Load controls
		key_load : in std_logic;
		IV_load : in std_logic;
		db_load : in std_logic;
		
		--Stream and mode selection
		stream : in std_logic;
		ECB_mode : in std_logic;
		CBC_mode : in std_logic;
		
		--32-bit data path
		dataIn : in std_logic_Vector(0 to 31);
		dataOut: out std_logic_vector(0 to 31);
		
		--Completion of operation 
		Done : out std_logic;
		
		--Debug ports
		state_debug : out std_logic_vector(1 downto 0);
		kcnt_debug : out std_logic_vector(1 downto 0);
		icnt_debug : out std_logic_vector(1 downto 0);
		dcnt_debug : Out std_logic_vector(1 downto 0)
	);
end entity;

architecture structural of goldModelStructural is  
component rowShift is
	port (
		original_key : in std_logic_vector(127 downto 0);
		shifted_key : out std_logic_vector(127 downto 0)
	);												   
end component;

component mixColumn is
	port (
		shifted_key : in std_logic_vector(127 downto 0);
		mixed_state : out std_logic_vector(127 downto 0)
	);												   
end component;

component addRoundKey is
	port(
		state_in : in std_logic_vector(127 downto 0);
		round_key : in std_logic_vector(127 downto 0);
		state_out : out std_logic_vector(127 downto 0)
	);
end component;

--128-bit registers
signal key_reg : std_Logic_vector(127 downto 0) := (others => '0');
signal iv_reg : std_Logic_vector(127 downto 0) := (others => '0');
signal data_reg : std_Logic_vector(127 downto 0) := (others => '0');
signal result_reg : std_Logic_vector(127 downto 0) := (others => '0');

signal cbc_in : std_logic_vector(127 downto 0);
signal sub_out : std_logic_vector(127 downto 0);
signal shift_out : std_logic_vector(127 downto 0);
signal mix_out : std_logic_vector(127 downto 0);   

--2-bit counters
signal key_count : std_logic_vector(1 downto 0) := "00";
signal iv_count : std_logic_vector(1 downto 0) := "00";
signal data_count : std_logic_vector(1 downto 0) := "00";
signal output_counter : std_logic_vector(1 downto 0) := "00";

--FSM States
type state_type is (IDLE, LOAD, COMPUTE, OUTPUT);
signal state : state_type := IDLE;
signal next_state : state_type := IDLE;

--S-box table
type sbox_array_t is array (0 to 255) of std_logic_vector(7 downto 0);

constant SBOX_TABLE : sbox_array_t := (
    x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5", x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
    x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
    x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
    x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
    x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
    x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
    x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
    x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
    x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
    x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
    x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
    x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
    x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
    x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
    x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
	x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16"
);

function sbox(b : std_logic_vector(7 downto 0)) return std_logic_vector is
variable idx : integer;
begin 
	idx := to_integer(unsigned(b));
	return SBOX_TABLE(idx);
end function;
	
begin  
	cbc_in <= data_reg xor iv_reg when CBC_mode = '1' else data_reg; 
	
	process(cbc_in)
	variable tmp : std_logic_vector(127 downto 0);
	variable b   : std_logic_vector(7 downto 0);
	variable i   : integer;
	
	begin
		for i in 0 to 15 loop
			b := cbc_in(127 - i * 8 downto 120 - i * 8);
			tmp(127 - i * 8 downto 120 - i * 8) := sbox(b);
		end loop;
		sub_out <= tmp;
	end process;	  
	
	--Components
	U_shiftRows : rowShift
		port map(
			original_key => sub_out,
			shifted_key => shift_out
		);							
		
	U_mixColumns : mixColumn
		port map(
			shifted_key => shift_out,
			mixed_state => mix_out
		); 
		
	U_addRoundKey : addRoundKey
		port map(
			state_in => mix_out,
			round_key => key_reg,
			state_out => result_reg
		);
	
	--Key load	
	process(clock, reset)
	begin 
		if reset = '1' then
			key_reg <= (others => '0');
			key_count <= "00";
		elsif rising_edge(clock) then
			if key_load = '1' then
				case key_count is
					when "00" => key_reg(127 downto 96) <= dataIn;
					when "01" => key_reg(95 downto 64) <= dataIn;
					when "10" => key_reg(63 downto 32) <= dataIn;
					when "11" => key_reg(31 downto 0) <= dataIn;
					when others => null;
				end case;
				
				if key_count = "11" then
					key_count <= "00";
				else
					key_count <= std_logic_vector(unsigned(key_count) + 1);
				end if;
			else
				key_count <= "00";
			end if;
		end if;
	end process;
	
	--IV load with CBC feedback
	process(clock, reset)
	begin
		if reset = '1' then
			iv_reg <= (others => '0');
			iv_count <= "00";
		elsif rising_edge(clock) then
			if state = OUTPUT and CBC_mode = '1' and output_counter	= "11" then
				iv_reg <= result_reg;
				iv_count <= "00";
			elsif IV_load = '1' then
				case iv_count is
					when "00" => iv_reg(127 downto 96) <= dataIn;
					when "01" => iv_reg(95 downto 64) <= dataIn;
					when "10" => iv_reg(63 downto 32) <= dataIn;
					when "11" => iv_reg(31 downto 0) <= dataIn;
					when others => null;
				end case;
				
				if iv_count = "11" then
					iv_count <= "00";
				else
					iv_count <= std_logic_vector(unsigned(iv_count) + 1);
				end if;
			else
				iv_count <= "00";
			end if;
		end if;
	end process;
	
	--Data block load
	process(clock, reset)
	begin 
		if reset = '1' then
			data_reg <= (others => '0');
			data_count <= "00";
		elsif rising_edge(clock) then
			if db_load = '1' then
				case data_count is
					when "00" => data_reg(127 downto 96) <= dataIn;
					when "01" => data_reg(95 downto 64) <= dataIn;
					when "10" => data_reg(63 downto 32) <= dataIn;
					when "11" => data_reg(31 downto 0) <= dataIn;
					when others => null;
				end case;
				
				if data_count = "11" then
					data_count <= "00";
				else
					data_count <= std_logic_vector(unsigned(data_count) + 1);
				end if;
			else
				data_count <= "00";
			end if;
		end if;
	end process;
	
	--State register
	process(clock, reset)
	begin
		if reset = '1' then
			state <= IDLE;
		elsif rising_edge(clock) then
			state <= next_state;
		end if;
	end process;
	
	--Next-state logic
	process(state, key_count, iv_count, data_count, key_load, IV_load, db_load, output_counter)	
	begin
		case state is
			when IDLE =>
				if key_load = '1' or IV_load = '1' or db_load = '1' then   
					next_state <= LOAD;
				else
					next_state <= IDLE;
				end if;
				
			when LOAD =>
				if key_load = '0' and IV_load = '0' and db_load = '0' and
				   key_count = "00" and iv_count = "00" and data_count = "00" then
				   next_state <= COMPUTE;
				else
					next_state <= LOAD;
				end if;
				
			when COMPUTE =>
				next_state <= OUTPUT;
			
			when OUTPUT =>
				if output_counter = "11" then
					next_state <= IDLE;
				else
					next_state <= OUTPUT;
				end if;
				
			when others =>
				next_state <= IDLE;
		end case;
	end process;
	
	--Output process
	process(clock, reset)
	begin
		if reset = '1' then
			dataOut <= (others => '0');
			output_counter <= "00";
			Done <= '0';
		elsif rising_edge(clock) then
			if state = OUTPUT then
				Done <= '0';
				
				case output_counter is
					when "00" => dataOut <= result_reg(127 downto 96);
					when "01" => dataOut <= result_reg(95 downto 64);
					when "10" => dataOut <= result_reg(63 downto 32);
					when "11" => dataOut <= result_reg(31 downto 0);
					when others => null;
				end case;
				
				if output_counter = "11" then
					output_counter <= "00";
					Done <= '1';
				else
					output_counter <= std_logic_vector(unsigned(output_counter) + 1);
				end if;
			else
				output_counter <= "00";
				Done <= '0';
				dataOut <= (others => '0');
			end if;
		end if;
	end process;
	
	--Debug outputs
	state_debug <=
		"00" when state = IDLE else
		"01" when state = LOAD else
		"10" when state = COMPUTE else
		"11"; --Output
		
	kcnt_debug <= key_count;
	icnt_debug <= iv_count;
	dcnt_debug <= data_count;		
end architecture;