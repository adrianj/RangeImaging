-------------------------------------------------------------------------------
-- Top level file for PMD19k Ranger based on Cyclone III FPGA.
-- Attempts to use no external RAM.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PMD19k_cyclone is

  port (
    -- Global signals
    clk50   : in std_logic;
    reset_n : in std_logic;



    -- PMD Mainboard connections
    laser_mod_1     : out std_logic;    -- Red Diodes
    laser_mod_2     : out std_logic;    -- IR Diodes
    ADC_sdata_read  : in  std_logic;
    ADC_sdata_write : out std_logic;
    ADC_sdata_we_n  : out std_logic;
    ADC_sclk        : out std_logic;
    ADC_sload       : out std_logic;
    ADC_d           : in  std_logic_vector(7 downto 0);
    ADC_adcclk      : out std_logic;
    ADC_cdsclk      : out std_logic;
    PMD_end_r       : in  std_logic;
    PMD_end_c       : in  std_logic;
    PMD_start_c     : out std_logic;
    PMD_start_r     : out std_logic;
    PMD_clk_c       : out std_logic;
    PMD_clk_r       : out std_logic;
    PMD_clear_c     : out std_logic;
    PMD_clear_r     : out std_logic;
    PMD_hold        : out std_logic;
    PMD_reset_n     : out std_logic;
    PMD_mod         : out std_logic;

    -- VGA Connections
    VGA_CLK   : out std_logic;
    VGA_R     : out std_logic_vector(9 downto 0);
    VGA_G     : out std_logic_vector(9 downto 0);
    VGA_B     : out std_logic_vector(9 downto 0);
    VGA_HS    : out std_logic;
    VGA_VS    : out std_logic;
    VGA_blank : out std_logic;
    VGA_sync  : out std_logic;

    -- Other
    leds     : out std_logic_vector(7 downto 0);
    buttons  : in  std_logic_vector(3 downto 0);
    switches : in  std_logic_vector(7 downto 0)
    );
end PMD19k_Cyclone;

architecture rtl of PMD19k_cyclone is

  
  signal ex_clk     : std_logic := '0';
  signal ex_reset_n : std_logic := '0';

  signal adcclk : std_logic := '0';

  signal vga_addr    : std_logic_vector(14 downto 0) := (others => '0');
  signal vga_TL_dout : std_logic_vector(15 downto 0) := (others => '0');
  signal vga_TR_dout : std_logic_vector(15 downto 0) := (others => '0');
  signal vga_BL_dout : std_logic_vector(15 downto 0) := (others => '0');
  signal vga_BR_dout : std_logic_vector(15 downto 0) := (others => '0');

  signal control_addr : std_logic_vector(15 downto 0) := (others => '0');
  signal control_din  : std_logic_vector(31 downto 0) := (others => '0');
  signal control_dout : std_logic_vector(31 downto 0) := (others => '0');
  signal control_we_n : std_logic                     := '1';
  signal control_re_n : std_logic                     := '1';

  signal TL_addr      : std_logic_vector(15 downto 0) := (others => '0');
  signal TL_din       : std_logic_vector(31 downto 0) := (others => '0');
  signal TL_dout      : std_logic_vector(31 downto 0) := (others => '0');
  signal TL_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal TL_we_n      : std_logic                     := '1';

  signal TR_addr      : std_logic_vector(15 downto 0) := (others => '0');
  signal TR_din       : std_logic_vector(31 downto 0) := (others => '0');
  signal TR_dout      : std_logic_vector(31 downto 0) := (others => '0');
  signal TR_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal TR_we_n      : std_logic                     := '1';

  signal BL_addr      : std_logic_vector(15 downto 0) := (others => '0');
  signal BL_din       : std_logic_vector(31 downto 0) := (others => '0');
  signal BL_dout      : std_logic_vector(31 downto 0) := (others => '0');
  signal BL_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal BL_we_n      : std_logic                     := '1';

  signal BR_addr      : std_logic_vector(15 downto 0) := (others => '0');
  signal BR_din       : std_logic_vector(31 downto 0) := (others => '0');
  signal BR_dout      : std_logic_vector(31 downto 0) := (others => '0');
  signal BR_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal BR_we_n      : std_logic                     := '1';

  signal frame_received : std_logic := '0';

begin


  -- Not sure timing is correct here.
  ADC_adcclk <= not adcclk;

  PMD_TOP : entity work.PMD_Ranger_top
    generic map (IS_CYCLONE3 => '1',
    OB_WIDTH => 8,
    SMALL_RAM => '1')
    port map (
      clk50   => clk50,
      clk     => ex_clk,
      reset_n => ex_reset_n,
      s_reset => open,
      leds    => leds,

      laser_mod_1     => laser_mod_1,
      laser_mod_2     => laser_mod_2,
      PMD_clk_r       => PMD_clk_r,
      PMD_clk_c       => PMD_clk_c,
      PMD_clear_r     => PMD_clear_r,
      PMD_clear_c     => PMD_clear_c,
      PMD_start_r     => PMD_start_r,
      PMD_start_c     => PMD_start_c,
      PMD_hold        => PMD_hold,
      PMD_reset_n     => PMD_reset_n,
      PMD_end_r       => PMD_end_r,
      PMD_end_c       => PMD_end_c,
      PMD_mod         => PMD_mod,
      ADC_d           => ADC_d,
      ADC_adcclk      => adcclk,
      ADC_cdsclk      => ADC_cdsclk,
      ADC_sdata_write => ADC_sdata_write,
      ADC_sdata_read  => ADC_sdata_read,
      ADC_sclk        => ADC_sclk,
      ADC_sload       => ADC_sload,
      ADC_sdata_we_n  => ADC_sdata_we_n,

      vga_addr    => vga_addr,
      vga_TL_dout => vga_TL_dout,
      vga_TR_dout => vga_TR_dout,
      vga_BL_dout => vga_BL_dout,
      vga_BR_dout => vga_BR_dout,

      control_addr => control_addr,
      control_din  => control_din,
      control_dout => control_dout,
      control_we_n => control_we_n,
      control_re_n => control_re_n,

      frame_received => frame_received,

      TL_addr => TL_addr(14 downto 0),
      TL_din  => TL_din(15 downto 0),
      TL_dout => TL_dout(15 downto 0),
      TL_we_n => TL_we_n,

      TR_addr => TL_addr(14 downto 0),
      TR_din  => TR_din(15 downto 0),
      TR_dout => TR_dout(15 downto 0),
      TR_we_n => TR_we_n,

      BL_addr => BL_addr(14 downto 0),
      BL_din  => BL_din(15 downto 0),
      BL_dout => BL_dout(15 downto 0),
      BL_we_n => BL_we_n,

      BR_addr => BL_addr(14 downto 0),
      BR_din  => BR_din(15 downto 0),
      BR_dout => BR_dout(15 downto 0),
      BR_we_n => BR_we_n
      ); 

  TL_dout_nios <= TR_dout(15 downto 0) & TL_dout(15 downto 0);
  TR_dout_nios <= TL_dout(15 downto 0) & TR_dout(15 downto 0);
  BL_dout_nios <= BR_dout(15 downto 0) & BL_dout(15 downto 0);
  BR_dout_nios <= BL_dout(15 downto 0) & BR_dout(15 downto 0);

  THE_VGA : entity work.vga_tester
    generic map (testing => '0',
                 clk_div => X"3")
    port map (
      clk     => ex_clk,
      reset_n => ex_reset_n,

      video_address => vga_addr,
      ram_dout_TL   => vga_TL_dout,
      ram_dout_TR   => vga_TR_dout,
      ram_dout_BL   => vga_BL_dout,
      ram_dout_BR   => vga_BR_dout,

      VGA_CLK   => VGA_CLK,
      VGA_R     => VGA_R,
      VGA_G     => VGA_G,
      VGA_B     => VGA_B,
      VGA_VS    => VGA_VS,
      VGA_HS    => VGA_HS,
      VGA_blank => VGA_blank,
      VGA_sync  => VGA_sync
      );

-- Ranger_cpu SOPC instance
  THE_RANGER_CPU : entity work.cpu
    port map (
      clk50   => clk50,
      reset_n => reset_n,

      ex_clk_from_the_control     => ex_clk,
      ex_reset_n_from_the_control => ex_reset_n,
      ex_addr_from_the_control    => control_addr,
      ex_din_from_the_control     => control_din,
      ex_we_n_from_the_control    => control_we_n,
      ex_re_n_from_the_control    => control_re_n,
      ex_dout_to_the_control      => control_dout,

      ex_dout_to_the_TL   => TL_dout_nios,
      ex_addr_from_the_TL => TL_addr,
      ex_din_from_the_TL  => TL_din,
      ex_we_n_from_the_TL => TL_we_n,

      ex_dout_to_the_TR   => TR_dout_nios,
      ex_addr_from_the_TR => TR_addr,
      ex_din_from_the_TR  => TR_din,
      ex_we_n_from_the_TR => TR_we_n,

      ex_dout_to_the_BL   => BL_dout_nios,
      ex_addr_from_the_BL => BL_addr,
      ex_din_from_the_BL  => BL_din,
      ex_we_n_from_the_BL => BL_we_n,

      ex_dout_to_the_BR   => BR_dout_nios,
      ex_addr_from_the_BR => BR_addr,
      ex_din_from_the_BR  => BR_din,
      ex_we_n_from_the_BR => BR_we_n,

      in_port_to_the_frame_received => frame_received
      );


end rtl;
