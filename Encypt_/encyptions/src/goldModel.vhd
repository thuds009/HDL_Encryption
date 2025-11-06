Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goldModel is 
	port (clock, reset, mode_select, cbc_enabled, start: in std_logic;
		data_in, key_in, iv_in: in std_logic_vector(127 downto 0);
	data_out: out std_logic_vector(127 downto 0);
		done: out std_logic);
end entity;