library ieee;
use ieee.std_logic_1164.all;

entity subBytes is 
	port(
	state_in : in std_logic_vector(127 downto 0);
	state_out : out std_logic_vector(127 downto 0)
	);
end entity;

architecture behavioral of subBytes is 

component sTable is 
	port(input_byte : in std_logic_vector(7 downto 0);
	output_byte : out std_logic_vector(7 downto 0));
end component;

begin
	
	GEN_SBOX: for i in 0 to 15 generate
		U_sbox : sTable
		port map(
		input_byte => state_in( (i*8+7) downto (i*8) ),
		output_byte => state_out( (i*8+7) downto (i*8) )
		);
	end generate;
	
end architecture;
