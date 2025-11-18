Library ieee;
use ieee.std_logic_1164.all;

--Generates the next round key were one key consists of 4 words
--and 1 word consists of 4 bytes
entity nextRoundKey is
    port(input_key:  in std_logic_vector(127 downto 0);
		 RCon:       in std_logic_vector(31 downto 0);
         output_key: out std_logic_vector(127 downto 0));
end;

--Implement code to divide key into its 4 words, get temporary word,
--then xor every word to get new round key. See below:
--https://www.youtube.com/watch?v=OvipL5OEWCY	  

architecture behavioral of nextRoundKey is
signal W0, W1, W2, W3, W4, W5, W6, W7, Rot_word, Rot_word_changed, Temp: std_logic_vector(31 downto 0);
signal Rot_byte0, Rot_byte1, Rot_byte2, Rot_byte3: std_logic_vector(7 downto 0); 
signal STRW0, STRW1, STRW2, STRW3: std_logic_vector(7 downto 0);

component sTable is
	port(input_byte:  in std_logic_vector(7 downto 0);
         output_byte: out std_logic_vector(7 downto 0));	
end component;

begin	
	W0 <= input_key(127 downto 96);
	W1 <= input_key(95 downto 64);
	W2 <= input_key(63 downto 32);
	W3 <= input_key(31 downto 0); 
	
	Rot_word <= W3(23 downto 0) & W3(31 downto 24);	
	Rot_byte0 <= Rot_word(31 downto 24);
	Rot_byte1 <= Rot_word(23 downto 16);
	Rot_byte2 <= Rot_word(15 downto 8);
	Rot_byte3 <= Rot_word(7 downto 0);
	
	STRWT0: sTable port map(Rot_byte0, STRW0);
	STRWT1: sTable port map(Rot_byte1, STRW1);
	STRWT2: sTable port map(Rot_byte2, STRW2);
	STRWT3: sTable port map(Rot_byte3, STRW3);
	Temp <=	STRW0 & STRW1 & STRW2 & STRW3;
	Rot_word_changed <= Temp xor RCon;
	
	W4 <= Rot_word_changed xor W0;
	W5 <= W4 xor W1;
	W6 <= W5 xor W2;
	W7 <= W6 xor W3;
	
	output_key <= W4 & W5 & W6 & W7;
end architecture;