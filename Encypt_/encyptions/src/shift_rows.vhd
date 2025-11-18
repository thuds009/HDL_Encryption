Library ieee;

use ieee.std_logic_1164.all;

entity rowShift is
    port(original_key: in std_logic_vector(127 downto 0);
         shifted_key:  out std_logic_vector(127 downto 0));
end entity;

architecture behavioral of rowShift is
begin
    shifted_key <= original_key(127 downto 96) & original_key(87 downto 64) & original_key(95 downto 88) & original_key(47 downto 32) & original_key(63 downto 48) & original_key(7 downto 0) & original_key(31 downto 8);
end architecture;