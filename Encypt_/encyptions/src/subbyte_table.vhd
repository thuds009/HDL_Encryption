Library ieee;
use ieee.std_logic_1164.all;

--Converts input byte based off of the subbyte tabel for AES
entity sTable is
    port(input_byte:  in std_logic_vector(7 downto 0);
         output_byte: out std_logic_vector(7 downto 0));
end;

--Implement code to encrypt bytes, e.g.:
--AA => AC
--See below links:
--https://www.redalyc.org/journal/5122/512253718012/html (AES S-box table)
--https://www.youtube.com/watch?v=OvipL5OEWCY

--Probably a more efficient way to do this, but
--I just wanted to work on the project some more :')
architecture behavioral of sTable is
begin
    process(input_byte)
    begin
        case input_byte is
            when x"00" => output_byte <= x"63";
            when x"01" => output_byte <= x"7C";
            when x"02" => output_byte <= x"77";
            when x"03" => output_byte <= x"7B";
            when x"04" => output_byte <= x"F2";
            when x"05" => output_byte <= x"6B";
            when x"06" => output_byte <= x"6F";
            when x"07" => output_byte <= x"C5";
            when x"08" => output_byte <= x"30";
            when x"09" => output_byte <= x"01";
            when x"0A" => output_byte <= x"67";
            when x"0B" => output_byte <= x"2B";
            when x"0C" => output_byte <= x"FE";
            when x"0D" => output_byte <= x"D7";
            when x"0E" => output_byte <= x"AB";
            when x"0F" => output_byte <= x"76";
            
            when x"10" => output_byte <= x"CA";
            when x"11" => output_byte <= x"82";
            when x"12" => output_byte <= x"C9";
            when x"13" => output_byte <= x"7D";
            when x"14" => output_byte <= x"FA";
            when x"15" => output_byte <= x"59";
            when x"16" => output_byte <= x"47";
            when x"17" => output_byte <= x"F0";
            when x"18" => output_byte <= x"AD";
            when x"19" => output_byte <= x"D4";
            when x"1A" => output_byte <= x"A2";
            when x"1B" => output_byte <= x"AF";
            when x"1C" => output_byte <= x"9C";
            when x"1D" => output_byte <= x"A4";
            when x"1E" => output_byte <= x"72";
            when x"1F" => output_byte <= x"C0";

            when x"20" => output_byte <= x"B7";
            when x"21" => output_byte <= x"FD";
            when x"22" => output_byte <= x"93";
            when x"23" => output_byte <= x"26";
            when x"24" => output_byte <= x"36";
            when x"25" => output_byte <= x"3F";
            when x"26" => output_byte <= x"F7";
            when x"27" => output_byte <= x"CC";
            when x"28" => output_byte <= x"34";
            when x"29" => output_byte <= x"A5";
            when x"2A" => output_byte <= x"E5";
            when x"2B" => output_byte <= x"F1";
            when x"2C" => output_byte <= x"71";
            when x"2D" => output_byte <= x"D8";
            when x"2E" => output_byte <= x"31";
            when x"2F" => output_byte <= x"15";

            when x"30" => output_byte <= x"04";
            when x"31" => output_byte <= x"C7";
            when x"32" => output_byte <= x"23";
            when x"33" => output_byte <= x"C3";
            when x"34" => output_byte <= x"18";
            when x"35" => output_byte <= x"96";
            when x"36" => output_byte <= x"05";
            when x"37" => output_byte <= x"9A";
            when x"38" => output_byte <= x"07";
            when x"39" => output_byte <= x"12";
            when x"3A" => output_byte <= x"80";
            when x"3B" => output_byte <= x"E2";
            when x"3C" => output_byte <= x"EB";
            when x"3D" => output_byte <= x"27";
            when x"3E" => output_byte <= x"B2";
            when x"3F" => output_byte <= x"75";

            when x"40" => output_byte <= x"09";
            when x"41" => output_byte <= x"83";
            when x"42" => output_byte <= x"2C";
            when x"43" => output_byte <= x"1A";
            when x"44" => output_byte <= x"1B";
            when x"45" => output_byte <= x"6E";
            when x"46" => output_byte <= x"5A";
            when x"47" => output_byte <= x"A0";
            when x"48" => output_byte <= x"52";
            when x"49" => output_byte <= x"3B";
            when x"4A" => output_byte <= x"D6";
            when x"4B" => output_byte <= x"B3";
            when x"4C" => output_byte <= x"29";
            when x"4D" => output_byte <= x"E3";
            when x"4E" => output_byte <= x"2F";
            when x"4F" => output_byte <= x"84";

            when x"50" => output_byte <= x"53";
            when x"51" => output_byte <= x"D1";
            when x"52" => output_byte <= x"00";
            when x"53" => output_byte <= x"ED";
            when x"54" => output_byte <= x"20";
            when x"55" => output_byte <= x"FC";
            when x"56" => output_byte <= x"B1";
            when x"57" => output_byte <= x"5B";
            when x"58" => output_byte <= x"6A";
            when x"59" => output_byte <= x"CB";
            when x"5A" => output_byte <= x"BE";
            when x"5B" => output_byte <= x"39";
            when x"5C" => output_byte <= x"4A";
            when x"5D" => output_byte <= x"4C";
            when x"5E" => output_byte <= x"58";
            when x"5F" => output_byte <= x"CF";

            when x"60" => output_byte <= x"D0";
            when x"61" => output_byte <= x"EF";
            when x"62" => output_byte <= x"AA";
            when x"63" => output_byte <= x"FB";
            when x"64" => output_byte <= x"43";
            when x"65" => output_byte <= x"4D";
            when x"66" => output_byte <= x"33";
            when x"67" => output_byte <= x"85";
            when x"68" => output_byte <= x"45";
            when x"69" => output_byte <= x"F9";
            when x"6A" => output_byte <= x"02";
            when x"6B" => output_byte <= x"7F";
            when x"6C" => output_byte <= x"50";
            when x"6D" => output_byte <= x"3C";
            when x"6E" => output_byte <= x"9F";
            when x"6F" => output_byte <= x"A8";

            when x"70" => output_byte <= x"51";
            when x"71" => output_byte <= x"A3";
            when x"72" => output_byte <= x"40";
            when x"73" => output_byte <= x"8F";
            when x"74" => output_byte <= x"92";
            when x"75" => output_byte <= x"9D";
            when x"76" => output_byte <= x"38";
            when x"77" => output_byte <= x"F5";
            when x"78" => output_byte <= x"BC";
            when x"79" => output_byte <= x"B6";
            when x"7A" => output_byte <= x"DA";
            when x"7B" => output_byte <= x"21";
            when x"7C" => output_byte <= x"10";
            when x"7D" => output_byte <= x"FF";
            when x"7E" => output_byte <= x"F3";
            when x"7F" => output_byte <= x"D2";

            when x"80" => output_byte <= x"CD";
            when x"81" => output_byte <= x"0C";
            when x"82" => output_byte <= x"13";
            when x"83" => output_byte <= x"EC";
            when x"84" => output_byte <= x"5F";
            when x"85" => output_byte <= x"97";
            when x"86" => output_byte <= x"44";
            when x"87" => output_byte <= x"17";
            when x"88" => output_byte <= x"C4";
            when x"89" => output_byte <= x"A7";
            when x"8A" => output_byte <= x"7E";
            when x"8B" => output_byte <= x"3D";
            when x"8C" => output_byte <= x"64";
            when x"8D" => output_byte <= x"5D";
            when x"8E" => output_byte <= x"19";
            when x"8F" => output_byte <= x"73";

            when x"90" => output_byte <= x"60";
            when x"91" => output_byte <= x"81";
            when x"92" => output_byte <= x"4F";
            when x"93" => output_byte <= x"DC";
            when x"94" => output_byte <= x"22";
            when x"95" => output_byte <= x"2A";
            when x"96" => output_byte <= x"90";
            when x"97" => output_byte <= x"88";
            when x"98" => output_byte <= x"46";
            when x"99" => output_byte <= x"EE";
            when x"9A" => output_byte <= x"B8";
            when x"9B" => output_byte <= x"14";
            when x"9C" => output_byte <= x"DE";
            when x"9D" => output_byte <= x"5E";
            when x"9E" => output_byte <= x"0B";
            when x"9F" => output_byte <= x"DB";

            when x"A0" => output_byte <= x"E0";
            when x"A1" => output_byte <= x"32";
            when x"A2" => output_byte <= x"3A";
            when x"A3" => output_byte <= x"0A";
            when x"A4" => output_byte <= x"49";
            when x"A5" => output_byte <= x"06";
            when x"A6" => output_byte <= x"24";
            when x"A7" => output_byte <= x"5C";
            when x"A8" => output_byte <= x"C2";
            when x"A9" => output_byte <= x"D3";
            when x"AA" => output_byte <= x"AC";
            when x"AB" => output_byte <= x"62";
            when x"AC" => output_byte <= x"91";
            when x"AD" => output_byte <= x"95";
            when x"AE" => output_byte <= x"E4";
            when x"AF" => output_byte <= x"79";

            when x"B0" => output_byte <= x"E7";
            when x"B1" => output_byte <= x"C8";
            when x"B2" => output_byte <= x"37";
            when x"B3" => output_byte <= x"6D";
            when x"B4" => output_byte <= x"8D";
            when x"B5" => output_byte <= x"D5";
            when x"B6" => output_byte <= x"4E";
            when x"B7" => output_byte <= x"A9";
            when x"B8" => output_byte <= x"6C";
            when x"B9" => output_byte <= x"56";
            when x"BA" => output_byte <= x"F4";
            when x"BB" => output_byte <= x"EA";
            when x"BC" => output_byte <= x"65";
            when x"BD" => output_byte <= x"7A";
            when x"BE" => output_byte <= x"AE";
            when x"BF" => output_byte <= x"08";

            when x"C0" => output_byte <= x"BA";
            when x"C1" => output_byte <= x"78";
            when x"C2" => output_byte <= x"25";
            when x"C3" => output_byte <= x"2E";
            when x"C4" => output_byte <= x"1C";
            when x"C5" => output_byte <= x"A6";
            when x"C6" => output_byte <= x"B4";
            when x"C7" => output_byte <= x"C6";
            when x"C8" => output_byte <= x"E8";
            when x"C9" => output_byte <= x"DD";
            when x"CA" => output_byte <= x"74";
            when x"CB" => output_byte <= x"1F";
            when x"CC" => output_byte <= x"4B";
            when x"CD" => output_byte <= x"BD";
            when x"CE" => output_byte <= x"8B";
            when x"CF" => output_byte <= x"8A";

            when x"D0" => output_byte <= x"70";
            when x"D1" => output_byte <= x"3E";
            when x"D2" => output_byte <= x"B5";
            when x"D3" => output_byte <= x"66";
            when x"D4" => output_byte <= x"48";
            when x"D5" => output_byte <= x"03";
            when x"D6" => output_byte <= x"F6";
            when x"D7" => output_byte <= x"0E";
            when x"D8" => output_byte <= x"61";
            when x"D9" => output_byte <= x"35";
            when x"DA" => output_byte <= x"57";
            when x"DB" => output_byte <= x"B9";
            when x"DC" => output_byte <= x"86";
            when x"DD" => output_byte <= x"C1";
            when x"DE" => output_byte <= x"1D";
            when x"DF" => output_byte <= x"9E";

            when x"E0" => output_byte <= x"E1";
            when x"E1" => output_byte <= x"F8";
            when x"E2" => output_byte <= x"98";
            when x"E3" => output_byte <= x"11";
            when x"E4" => output_byte <= x"69";
            when x"E5" => output_byte <= x"D9";
            when x"E6" => output_byte <= x"8E";
            when x"E7" => output_byte <= x"94";
            when x"E8" => output_byte <= x"9B";
            when x"E9" => output_byte <= x"1E";
            when x"EA" => output_byte <= x"87";
            when x"EB" => output_byte <= x"E9";
            when x"EC" => output_byte <= x"CE";
            when x"ED" => output_byte <= x"55";
            when x"EE" => output_byte <= x"28";
            when x"EF" => output_byte <= x"DF";

            when x"F0" => output_byte <= x"8C";
            when x"F1" => output_byte <= x"A1";
            when x"F2" => output_byte <= x"89";
            when x"F3" => output_byte <= x"0D";
            when x"F4" => output_byte <= x"BF";
            when x"F5" => output_byte <= x"E6";
            when x"F6" => output_byte <= x"42";
            when x"F7" => output_byte <= x"68";
            when x"F8" => output_byte <= x"41";
            when x"F9" => output_byte <= x"99";
            when x"FA" => output_byte <= x"2D";
            when x"FB" => output_byte <= x"0F";
            when x"FC" => output_byte <= x"B0";
            when x"FD" => output_byte <= x"54";
            when x"FE" => output_byte <= x"BB";
            when x"FF" => output_byte <= x"16";
            when others => null;
        end case;
    end process;
end architecture;