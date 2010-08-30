-- Test bench for testing DM9000A_test

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DM9000A_tb is

end DM9000A_tb;

architecture testbench of DM9000A_tb is

  signal clk125    : std_logic                     := '0';
  signal reset_n   : std_logic                     := '1';
  signal ENET_RD_N : std_logic                     := '1';
  signal ENET_WR_N : std_logic                     := '1';
  signal ENET_CMD  : std_logic                     := '0';
  signal ENET_INT  : std_logic                     := '0';
  signal ENET_CS_N : std_logic                     := '1';
  signal ENET_CLK  : std_logic                     := '0';
  signal ENET_DATA : std_logic_vector(15 downto 0) := (others => '0');

  signal LEDs : std_logic_vector(7 downto 0) := (others => '0');
  
begin  -- rtl

  SYS_CLK : process
  begin  -- process SYS_CLK
    clk125 <= '1';
    wait for 4 ns;
    clk125 <= '0';
    wait for 4 ns;
  end process SYS_CLK;

  TB : process
  begin  -- process TB
    reset_n <= '0';
    wait for 100 ns;
    reset_n <= '1';

    wait for 20 us;


    wait;
  end process TB;

  UUT : entity work.DM9000A_test
    port map (
      clk125    => clk125,
      reset_n   => reset_n,
      ENET_RD_N => ENET_RD_N,
      ENET_WR_N => ENET_WR_N,
      ENET_CS_N => ENET_CS_N,
      ENET_CMD  => ENET_CMD,
      ENET_INT  => ENET_INT,
      ENET_CLK  => ENET_CLK,
      ENET_DATA => ENET_DATA,
      LEDs      => LEDs);        

  MODEL : entity work.DM9000A_model
    port map (
      clk      => ENET_CLK,
      reset_n  => reset_n,
      DM_IOR_n => ENET_RD_N,
      DM_IOW_n => ENET_WR_N,
      DM_CS_n  => ENET_CS_N,
      DM_CMD   => ENET_CMD,
      DM_INT   => ENET_INT,
      DM_SD    => ENET_DATA);


end testbench;
