-- Tester code for VGA_Module

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity vga_monitor_tb is

end vga_monitor_tb;

architecture testbench of vga_monitor_tb is

  signal clk125  : std_logic;
  signal reset_n : std_logic;

  -- to VGA chip
  signal VGA_R     : std_logic_vector(9 downto 0);
  signal VGA_G     : std_logic_vector(9 downto 0);
  signal VGA_B     : std_logic_vector(9 downto 0);
  signal VGA_HS    : std_logic;
  signal VGA_VS    : std_logic;
  signal VGA_CLK   : std_logic;
  signal VGA_blank : std_logic;
  signal VGA_sync  : std_logic;

begin


  THE_VGA_MODULE : entity work.vga_monitor
    port map (
      clk125       => clk125,
      reset_n   => reset_n,
      VGA_R   => VGA_R,
      VGA_G => VGA_G,
      VGA_B  => VGA_B,
      VGA_HS    => VGA_HS,
      VGA_VS    => VGA_VS,
      VGA_BLANK     => VGA_blank,
      VGA_SYNC      => vga_sync,
      VGA_CLK     => VGA_CLK);

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
    wait;
  end process TB;

end testbench;
