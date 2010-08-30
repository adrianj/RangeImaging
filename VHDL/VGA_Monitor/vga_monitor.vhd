-- Tester code for VGA_Module

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity vga_monitor is
  port(
    clk125  : in std_logic;
    reset_n : in std_logic;

    -- to VGA chip
    VGA_R     : out std_logic_vector(9 downto 0);
    VGA_G     : out std_logic_vector(9 downto 0);
    VGA_B     : out std_logic_vector(9 downto 0);
    VGA_HS    : out std_logic;
    VGA_VS    : out std_logic;
    VGA_CLK   : out std_logic;
    VGA_blank : out std_logic;
    VGA_sync  : out std_logic);
end vga_monitor;

architecture rtl of vga_monitor is


  signal row_address    : std_logic_vector(8 downto 0)  := (others => '0');
  signal column_address : std_logic_vector(9 downto 0)  := (others => '0');
  signal ram_dout       : std_logic_vector(15 downto 0) := (others => '0');

  signal clk100 : std_logic := '0';

begin

  THE_PLL : entity work.pllx4d5
    port map (
      inclk0 => clk125,
      c0    => clk100);

  THE_VGA_MODULE : entity work.vga_module
    generic map (clk_div => X"3")
    port map (
      clk            => clk100,
      reset_n        => reset_n,
      red_out        => VGA_R,
      green_out      => VGA_G,
      blue_out       => VGA_B,
      hs_out         => VGA_HS,
      vs_out         => VGA_VS,
      blank          => VGA_blank,
      sync           => vga_sync,
      clk25          => VGA_CLK,
      row_address    => row_address,
      column_address => column_address,
      ram_dout       => ram_dout);

  SET_RAM : process (clk100, reset_n)
  begin  -- process SET_RAM
    if reset_n = '0' then               -- asynchronous reset (active low)
      ram_dout <= (others => '0');
    elsif rising_edge(clk100) then      -- rising clock edge
      if row_address < 480 and column_address < 640 then
        ram_dout <= column_address(3 downto 0) & row_address(3 downto 0) & X"00";
      else
        ram_dout <= (others => '1');
      end if;
    end if;
  end process SET_RAM;


end rtl;
