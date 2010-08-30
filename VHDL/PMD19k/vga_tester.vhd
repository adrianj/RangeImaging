-- 640 x 480 doesn't fit into RAM so well, and takes up quite a bit.
-- See Digilent Spartan3 reference manual for details of timing.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity vga_tester is
  generic (
    testing : std_logic := '1';
    clk_div : std_logic_vector(3 downto 0) := X"3"-- VGA_clk = clk / (clk_div+1) = 25 MHz.
    );
    
  port(
    clk     : in std_logic;
    reset_n : in std_logic;

    -- Internal RAM connections
    video_address : out std_logic_vector(14 downto 0);
    ram_dout_TL   : in  std_logic_vector(15 downto 0);
    ram_dout_TR   : in  std_logic_vector(15 downto 0);
    ram_dout_BL   : in  std_logic_vector(15 downto 0);
    ram_dout_BR   : in  std_logic_vector(15 downto 0);

    -- to VGA chip
    VGA_R     : out std_logic_vector(9 downto 0);
    VGA_G     : out std_logic_vector(9 downto 0);
    VGA_B     : out std_logic_vector(9 downto 0);
    VGA_HS    : out std_logic;
    VGA_VS    : out std_logic;
    VGA_CLK   : out std_logic;
    VGA_blank : out std_logic;
    VGA_sync  : out std_logic);
end vga_tester;

architecture rtl of vga_tester is


  signal row_address_vga    : std_logic_vector(8 downto 0)  := (others => '0');
  signal column_address_vga : std_logic_vector(9 downto 0)  := (others => '0');
  signal ram_dout           : std_logic_vector(15 downto 0) := (others => '0');
  signal ram_dout_not_test : std_logic_vector(15 downto 0) := (others => '0');
  signal ram_dout_test      : std_logic_vector(15 downto 0) := (others => '0');


  signal region             : std_logic_vector(1 downto 0) := "00";
  signal region_int1        : std_logic_vector(1 downto 0) := "00";
  signal region_int2        : std_logic_vector(1 downto 0) := "00";
  signal row_address_int    : std_logic_vector(6 downto 0) := (others => '0');
  signal column_address_int : std_logic_vector(7 downto 0) := (others => '0');

  signal ram_dout_TL_i : std_logic_vector(15 downto 0) := X"0000";
  signal ram_dout_TR_i : std_logic_vector(15 downto 0) := X"4000";
  signal ram_dout_BL_i : std_logic_vector(15 downto 0) := X"8000";
  signal ram_dout_BR_i : std_logic_vector(15 downto 0) := X"C000";

  signal clk100 : std_logic := '0';

begin


		clk100 <= clk;
		ram_dout <= ram_dout_not_test;




  THE_VGA_MODULE : entity work.vga_module
	generic map (clk_div => clk_div)
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
      row_address    => row_address_vga,
      column_address => column_address_vga,
      ram_dout       => ram_dout);


  -- interpret row and column addresses to 4 regions of display.
  SET_RAM : process (clk100, reset_n)
    variable row_8    : std_logic_vector(7 downto 0);
    variable column_9 : std_logic_vector(8 downto 0);
  begin  -- process SET_RAM
    if reset_n = '0' then               -- asynchronous reset (active low)
      ram_dout_not_test           <= (others => '0');
      ram_dout_test <= (others => '0');
      region             <= "00";
      region_int1        <= "00";
      region_int2        <= "00";
      row_address_int    <= (others => '0');
      column_address_int <= (others => '0');
    elsif rising_edge(clk100) then      -- rising clock edge
      -- Latency = 0
      if row_address_vga(8 downto 1) >= 120 then
        row_8           := row_address_vga(8 downto 1) - 120;
        row_address_int <= row_8(6 downto 0);
        region(1)       <= '1';
      else
        row_address_int <= row_address_vga(7 downto 1);
        region(1)       <= '0';
      end if;
      if column_address_vga(9 downto 1) >= 158 then
        column_9           := column_address_vga(9 downto 1) - 158;
        column_address_int <= column_9(7 downto 0);
        region(0)          <= '1';
      else
        column_address_int <= column_address_vga(8 downto 1);
        region(0)          <= '0';
      end if;

      -- Latency = 1
      region_int1 <= region;
      --ram_dout <= column_address_int & row_address_int & '0';

      -- Latency = 2
      region_int2 <= region_int1;
      --ram_dout_int1 <= ram_dout;

      -- Latency = 3
      if region_int2 = "00" then
        ram_dout_not_test <= ram_dout_TL;
      elsif region_int2 = "01" then
        ram_dout_not_test <= ram_dout_TR;
      elsif region_int2 = "10" then
        ram_dout_not_test <= ram_dout_BL;
      else
        ram_dout_not_test <= ram_dout_BR;
      end if;
      -- Use this line for testing.
      ram_dout_test <= (column_address_int(7 downto 0)) & row_address_int & column_address_int(0);
      
    end if;
  end process SET_RAM;
  video_address <= (row_address_int) & (column_address_int);


end rtl;
