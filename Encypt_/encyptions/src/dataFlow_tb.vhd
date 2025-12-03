library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataFlow_tb is
end dataFlow_tb;

architecture tb of dataFlow_tb is
component goldModelDataflow
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;

        key_load     : in  std_logic;
        IV_load      : in  std_logic;
        db_load      : in  std_logic;

        stream       : in  std_logic;
        ECB_mode     : in  std_logic;
        CBC_mode     : in  std_logic;

        dataIn       : in  std_logic_vector(0 to 31);
        dataOut      : out std_logic_vector(0 to 31);

        Done         : out std_logic;

        state_debug  : out std_logic_vector(1 downto 0);
        kcnt_debug   : out std_logic_vector(1 downto 0);
        icnt_debug   : out std_logic_vector(1 downto 0);
        dcnt_debug   : out std_logic_vector(1 downto 0)
    );
end component;

signal clock      : std_logic := '0';
signal reset      : std_logic := '0';

signal key_load   : std_logic := '0';
signal IV_load    : std_logic := '0';
signal db_load    : std_logic := '0';

signal stream     : std_logic := '0';
signal ECB_mode   : std_logic := '1';
signal CBC_mode   : std_logic := '0';

signal dataIn     : std_logic_vector(0 to 31) := (others => '0');
signal dataOut    : std_logic_vector(0 to 31);

signal Done       : std_logic;

signal state_debug  : std_logic_vector(1 downto 0);
signal kcnt_debug   : std_logic_vector(1 downto 0);
signal icnt_debug   : std_logic_vector(1 downto 0);
signal dcnt_debug   : std_logic_vector(1 downto 0);

begin
    clock <= not clock after 5 ns;

    DUT: goldModelDataflow
        port map(
            clock, reset,
            key_load, IV_load, db_load,
            stream, ECB_mode, CBC_mode,
            dataIn, dataOut,
            Done,
            state_debug, kcnt_debug, icnt_debug, dcnt_debug
        );


    stim: process
    begin

        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait until rising_edge(clock);

        -- ECB encryption
        key_load <= '1';
		dataIn <= x"00010203";	 
		wait for 10 ns;
		dataIn <= x"04050607";
		wait for 10 ns;
		dataIn <= x"08090A0B";	
		wait for 10 ns;
		dataIn <= x"0C0D0E0F";	
		wait for 10 ns;
		key_load <= '0';
		wait for 10 ns;
		
		db_load <= '1';
		dataIn <= x"00112233";	 
		wait for 10 ns;
		dataIn <= x"44556677";
		wait for 10 ns;
		dataIn <= x"8899AABB";	
		wait for 10 ns;
		dataIn <= x"CCDDEEFF";	
		wait for 10 ns;
		db_load <= '0';	
		
		wait until Done = '1';
		wait for 10 ns;	
		
		---------------------------
		
		key_load <= '1';
		dataIn <= x"01234567";	 
		wait for 10 ns;
		dataIn <= x"89ABCDEF";
		wait for 10 ns;
		dataIn <= x"01234567";	 
		wait for 10 ns;
		dataIn <= x"89ABCDEF";
		wait for 10 ns;
		key_load <= '0';
		wait for  20 ns;
		
		db_load <= '1';
		dataIn <= x"00112233";	 
		wait for 10 ns;
		dataIn <= x"00112233";	 
		wait for 10 ns;
		dataIn <= x"00112233";	 
		wait for 10 ns;
		dataIn <= x"00112233";	 
		wait for 10 ns;
		db_load <= '0';	
		
		wait until Done = '1';
		wait for 10 ns;
		
		--CBC encryption 
		ECB_mode <= '0';
		CBC_mode <= '1';
		wait for 20 ns;
		
		IV_load <= '1';
		dataIn <= x"FEDCBA98";	 
		wait for 10 ns;
		dataIn <= x"76543210";
		wait for 10 ns;
		dataIn <= x"FEDCBA98";	 
		wait for 10 ns;
		dataIn <= x"76543210";
		wait for 10 ns;
		IV_load <= '0';
		wait for 20 ns;
		
		db_load <= '1';
		dataIn <= x"33221100";	 
		wait for 10 ns;
		dataIn <= x"33221100";	 
		wait for 10 ns;
		dataIn <= x"00112233";	 
		wait for 10 ns;
		dataIn <= x"00112233";	 
		wait for 10 ns;
		db_load <= '0';	
		
		wait until Done = '1';
		wait for 10 ns;
    end process;

end architecture ;