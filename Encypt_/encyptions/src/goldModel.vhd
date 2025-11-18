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
signal key_reg	:std_logic_vector(127 downto 0);
signal iv_reg	:std_logic_vector(127 downto 0);
signal data_reg	:std_logic_vector(127 downto 0);

signal key_count	:std_logic_vector(1 downto 0);
signal iv_count 	:std_logic_vector(1 downto 0);
signal data_count	:std_logic_vector(1 downto 0);

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
					
			end case;
			
			--increment counter
			if key_count = "11" then 
				key_count <= "00";	--wrap if fully loaded
			else
				key_count <= key_count + 1;
			end if;
			
			end if;	
		end if;
	end process;
	
------Initial Value Load--------

process(clock, reset)
begin	
	if reset = '1' then
		iv_reg		<= (others => '0');
		iv_clock 	<= (others => '0');
		
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
				
			end case;
			
			--increment counter
			if iv_counter = "11" then
				iv_counter <= "00"; --wrap if fully loaded
			else
				iv_counter <= counter +1;
			end if;
			
			end if;
		end if;
	end process;	
				
------Data Block Load-----

process(clock, reset)
begin
	if reset = '1' then 
		data_reg 	<= (others =>0);
		data_clcok	<= (others =>0);
	
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

            end case;

            -- increment counter
            if data_count = "11" then
                data_count <= "00";  -- wrap when block fully loaded
            else
                data_count <= data_count + 1;
            end if;

        	end if;
    	end if;
	end process;
	
	










		
			
				
				