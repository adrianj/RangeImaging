-- Interface for DM9000A.
-- Handles tristating of data lines.
-- Provides 25MHz output clock assuming a 50 MHz input clock.
-- Basically does everything that verilog file DM9000A_IF.v does.

library ieee;
use ieee.std_logic_1164.all;

entity DM9000_interface is
  
  port (
    iDATA      : in    std_logic_vector(15 downto 0);
    oData      : out   std_logic_vector(15 downto 0);
    iCMD       : in    std_logic;
    iRD_N      : in    std_logic;
    iWR_N      : in    std_logic;
    iCS_N      : in    std_logic;
    iRST_N     : in    std_logic;
    iCLK       : in    std_logic;       -- 50 MHz
    iOSC_50    : in    std_logic;       -- Also 50 MHz
    oINT       : out   std_logic;       -- interrupt
    ENET_DATA  : inout std_logic_vector(15 downto 0);
    ENET_CMD   : out   std_logic;
    ENET_RD_N  : out   std_logic;
    ENET_WR_N  : out   std_logic;
    ENET_CS_N  : out   std_logic;
    ENET_RST_N : out   std_logic;
    ENET_INT   : in    std_logic;
    ENET_CLK   : out   std_logic        -- 25 Mhz
    );

end DM9000_interface;

architecture rtl of DM9000_interface is

  signal data_int  : std_logic_vector(15 downto 0) := (others => '0');
  signal data_we_n : std_logic                     := '0';
  
begin  -- rtl

  ENET_DATA <= data_int when data_we_n = '0' else (others => 'Z');
  ENET_RST_N <= iRST_N;

  process (iCLK, iRST_N)
  begin  -- process
    if iRST_N = '0' then                -- asynchronous reset (active low)
      data_int  <= (others => '0');
      data_we_n <= '1';
      ENET_CMD  <= '0';
      ENET_RD_N <= '1';
      ENET_WR_N <= '1';
      ENET_CS_N <= '1';
      oDATA     <= (others => '0');
      oINT      <= '0';
      ENET_CLK <= '0';
    elsif rising_edge(iCLK) then        -- rising clock edge
      data_int  <= iDATA;
      data_we_n <= iWR_N;
      ENET_CMD  <= iCMD;
      ENET_CS_N <= iCS_N;
      ENET_WR_N <= iWR_N;
      ENET_RD_N <= iRD_N;
      oDATA     <= ENET_DATA;
      oINT      <= ENET_INT;
      ENET_CLK <= not ENET_CLK;
    end if;
  end process;

end rtl;
