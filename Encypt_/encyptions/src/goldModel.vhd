Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goldModel is 
	port (
	clock 		:in std_logic;
	reset		:in std_logic;
	mode_select	:in std_logic;
	cbc_enabled	:in std_logic;
	start		:in std_logic;
	
	data_in		:in std_logic_vector(127 downto 0);
	key_in		:in std_logic_vector(127 downto 0);
	iv_in		:in std_logic_vector(127 downto 0);
	
	data_out	:out std_logic_vector(127 downto 0);
	done 		:out std_logic
	);
end entity goldModel;
