library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BehavioralTestbench is
end entity;

architecture sim of BehavioralTestbench is
signal clock       : std_logic := '0';
signal reset       : std_logic := '1';

signal key_load    : std_logic := '0';
signal IV_load     : std_logic := '0';
signal db_load     : std_logic := '0'; 
signal compute_now : std_logic := '0';

signal stream      : std_logic := '0';
signal ECB_mode    : std_logic := '1';
signal CBC_mode    : std_logic := '0';

signal dataIn      : std_logic_vector(0 to 31) := (others => '0');
signal dataOut     : std_logic_vector(0 to 31);
signal Done        : std_logic := '0';
	
begin
    DUT : entity work.goldModel
        port map(
            clock       => clock,
            reset       => reset,
            key_load    => key_load,
            IV_load     => IV_load,
            db_load     => db_load,	 
			compute_now => compute_now,
            stream      => stream,
            ECB_mode    => ECB_mode,
            CBC_mode    => CBC_mode,
            dataIn      => dataIn,
            dataOut     => dataOut,
            Done        => Done	
        );

    clock <= not clock after 5 ns;
    process
    begin 
		
		--Used https://testprotect.com/appendix/AEScalc to check for correct encryption
		
		reset <= '0';
		wait for 20 ns;
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        key_load <= '1';
        dataIn <= x"01234567"; wait for 10 ns;
        dataIn <= x"89ABCDEF"; wait for 10 ns;
        dataIn <= x"01234567"; wait for 10 ns;
        dataIn <= x"89ABCDEF"; wait for 10 ns;
        key_load <= '0';
        wait for 20 ns;

        db_load <= '1';
        dataIn <= x"00112233"; wait for 10 ns;
        dataIn <= x"44556677"; wait for 10 ns;
        dataIn <= x"8899AABB"; wait for 10 ns;
        dataIn <= x"CCDDEEFF"; wait for 10 ns;
        db_load <= '0';	 
		wait for 20 ns;
		
		compute_now <= '1';	  
		wait for 40 ns;
		compute_now <= '0';
       
        wait until Done = '1';	
		
		--------------------------------------
		
		reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        key_load <= '1';
        dataIn <= x"00010203"; wait for 10 ns;
        dataIn <= x"04050607"; wait for 10 ns;
        dataIn <= x"08090A0B"; wait for 10 ns;
        dataIn <= x"0C0D0E0F"; wait for 10 ns;
        key_load <= '0';
        wait for 20 ns;

        db_load <= '1';
        dataIn <= x"01020304"; wait for 10 ns;
        dataIn <= x"05060708"; wait for 10 ns;
        dataIn <= x"090A0B0C"; wait for 10 ns;
        dataIn <= x"0D0E0F10"; wait for 10 ns;
        db_load <= '0';	 
		wait for 20 ns;
		
		compute_now <= '1';	  
		wait for 40 ns;
		compute_now <= '0';
       
        wait until Done = '1';
    end process;

end architecture;