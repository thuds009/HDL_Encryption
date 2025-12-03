library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goldModel_tb is
end entity;

architecture tb of goldModel_tb is

    -- DUT signals
    signal clock       : std_logic := '0';
    signal reset       : std_logic := '0';

    signal key_load    : std_logic := '0';
    signal IV_load     : std_logic := '0';
    signal db_load     : std_logic := '0';

    signal stream      : std_logic := '0';
    signal ECB_mode    : std_logic := '1';
    signal CBC_mode    : std_logic := '0';

    signal dataIn      : std_logic_vector(31 downto 0) := (others => '0');

    signal dataOut_beh : std_logic_vector(31 downto 0);
    signal dataOut_df  : std_logic_vector(31 downto 0);

    signal Done_beh    : std_logic;
    signal Done_df     : std_logic;
	
	--test
	signal state_dbg_b : std_logic_vector(1 downto 0);
	signal kcnt_dbg_b  : std_logic_vector(1 downto 0);
	signal icnt_dbg_b  : std_logic_vector(1 downto 0);
	signal dcnt_dbg_b  : std_logic_vector(1 downto 0);

begin

   --clock
   
    clock <= not clock after 10 ns;


	--instantiate behavorial model
	
    U_BEHAV : entity work.goldModel
    port map(
        clock    => clock,
        reset    => reset,
        key_load => key_load,
        IV_load  => IV_load,
        db_load  => db_load,
        stream   => stream,
        ECB_mode => ECB_mode,
        CBC_mode => CBC_mode,
        dataIn   => dataIn,
        dataOut  => dataOut_beh,
        Done     => Done_beh,  
        
		--test
		state_debug => state_dbg_b,
        kcnt_debug  => kcnt_dbg_b,
        icnt_debug  => icnt_dbg_b,
        dcnt_debug  => dcnt_dbg_b
    );
	
	--instantiate dataflow model
	
U_DATAFLOW : entity work.goldModelDataflow
    port map(
        clock    => clock,
        reset    => reset,
        key_load => key_load,
        IV_load  => IV_load,
        db_load  => db_load,
        stream   => stream,
        ECB_mode => ECB_mode,
        CBC_mode => CBC_mode,
        dataIn   => dataIn,
        dataOut  => dataOut_df,
        Done     => Done_df
    );

   --Process for test
	   
    stim_proc : process
        -- test vectors (32-bit chunks)
        variable key0 : std_logic_vector(31 downto 0) := x"00112233";
        variable key1 : std_logic_vector(31 downto 0) := x"44556677";
        variable key2 : std_logic_vector(31 downto 0) := x"8899AABB";
        variable key3 : std_logic_vector(31 downto 0) := x"CCDDEEFF";

        variable pt0  : std_logic_vector(31 downto 0) := x"00112233";
        variable pt1  : std_logic_vector(31 downto 0) := x"44556677";
        variable pt2  : std_logic_vector(31 downto 0) := x"8899AABB";
        variable pt3  : std_logic_vector(31 downto 0) := x"CCDDEEFF";

        variable iv0  : std_logic_vector(31 downto 0) := x"01020304";
        variable iv1  : std_logic_vector(31 downto 0) := x"05060708";
        variable iv2  : std_logic_vector(31 downto 0) := x"090A0B0C";
        variable iv3  : std_logic_vector(31 downto 0) := x"0D0E0F10";
    begin

 --reset
 
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait for 20 ns;


        --Load key 4x32
		
        key_load <= '1';

        dataIn <= key0; wait for 20 ns;
        dataIn <= key1; wait for 20 ns;
        dataIn <= key2; wait for 20 ns;
        dataIn <= key3; wait for 20 ns;

        key_load <= '0';


   --Load IV CBC 
   
        IV_load <= '1';
        CBC_mode <= '1';
        ECB_mode <= '0';

        dataIn <= iv0; wait for 20 ns;
        dataIn <= iv1; wait for 20 ns;
        dataIn <= iv2; wait for 20 ns;
        dataIn <= iv3; wait for 20 ns;

        IV_load <= '0';


     --load datablock
	 
        db_load <= '1';

        dataIn <= pt0; wait for 20 ns;
        dataIn <= pt1; wait for 20 ns;
        dataIn <= pt2; wait for 20 ns;
        dataIn <= pt3; wait for 20 ns;

        db_load <= '0';


     --allow finish 
	 
        wait until Done_beh = '1';
        wait until Done_df  = '1';
        wait for 10 ns;


       --compare
	   
        assert (dataOut_beh = dataOut_df)
        report "ERROR: Behavioral and Dataflow outputs DO NOT match!"
        severity error;

        report "SUCCESS: Behavioral and Dataflow outputs match." severity note;


        wait;
    end process;

end architecture;