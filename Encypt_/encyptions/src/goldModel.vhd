Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goldModel is 
	port (
	clock 		:in std_logic;
	reset		:in std_logic;
	
	-- mode/config
    cfg_mode       : in  std_logic_vector(1 downto 0);
		-- 00=ECB enc, 01=ECB dec, 10=CBC enc, 11=CBC dec
    cfg_key        : in  std_logic_vector(127 downto 0);
    cfg_key_valid  : in  std_logic;
    cfg_iv         : in  std_logic_vector(127 downto 0);
    cfg_iv_valid   : in  std_logic;

    -- input stream
    in_valid       : in  std_logic;
    in_ready       : out std_logic;
    in_block       : in  std_logic_vector(127 downto 0);
    in_stream_id   : in  std_logic_vector(3 downto 0);  
	-- adjust width if needed

    -- output stream
    out_valid      : out std_logic;
    out_ready      : in  std_logic;
    out_block      : out std_logic_vector(127 downto 0);
    out_stream_id  : out std_logic_vector(3 downto 0)   
	-- match in_stream_id width
  );
end entity goldModel;

architecture Behavioral of goldModel is
begin
	