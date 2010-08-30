-- Top level for PMD Ranger logic.
-- Does not include Nios CPU, or VGA Module
-- Includes:
-- PMD_interface
-- Modulation driver
-- Control Registers
-- Output Buffers (4 frames)
-- Accumulator
-- Atan / Cordic
-- This version configured for only a single modulation frequency.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PMD_Ranger_top is
  generic (IS_CYCLONE3 : std_logic := '0';
	OB_WIDTH : integer := 16);
  port (
    clk     : in  std_logic;
    clk50   : in  std_logic;
    reset_n : in  std_logic;
    s_reset : out std_logic;

    leds  : out std_logic_vector(7 downto 0);

    -- PMD Mainboard connections
    laser_mod_1     : out std_logic;    -- Red diodes
    laser_mod_2     : out std_logic;    -- IR diodes
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


    -- VGA Module connections
    vga_addr    : in  std_logic_vector(14 downto 0);
    vga_TL_dout : out std_logic_vector(15 downto 0);
    vga_TR_dout : out std_logic_vector(15 downto 0);
    vga_BL_dout : out std_logic_vector(15 downto 0);
    vga_BR_dout : out std_logic_vector(15 downto 0);

    -- Nios connections
    control_addr   : in  std_logic_vector(15 downto 0);
    control_din    : in  std_logic_vector(31 downto 0);
    control_dout   : out std_logic_vector(31 downto 0);
    control_we_n   : in  std_logic;
    control_re_n   : in  std_logic;
    frame_received : out std_logic;

    TL_addr : in  std_logic_vector(14 downto 0);
    TL_din  : in  std_logic_vector(15 downto 0);
    TL_dout : out std_logic_vector(15 downto 0);
    TL_we_n : in  std_logic;
    TR_addr : in  std_logic_vector(14 downto 0);
    TR_din  : in  std_logic_vector(15 downto 0);
    TR_dout : out std_logic_vector(15 downto 0);
    TR_we_n : in  std_logic;
    BL_addr : in  std_logic_vector(14 downto 0);
    BL_din  : in  std_logic_vector(15 downto 0);
    BL_dout : out std_logic_vector(15 downto 0);
    BL_we_n : in  std_logic;
    BR_addr : in  std_logic_vector(14 downto 0);
    BR_din  : in  std_logic_vector(15 downto 0);
    BR_dout : out std_logic_vector(15 downto 0);
    BR_we_n : in  std_logic;
    ssd     : out std_logic_vector(15 downto 0)
    );

end PMD_Ranger_top;

architecture rtl of PMD_Ranger_top is


  signal frame_period : std_logic_vector(31 downto 0)
 := X"00000050";  --:= X"05F5E100";                        -- 1 s
  signal integration_period_requested : std_logic_vector(31 downto 0)
 := X"00000030";  --:= X"030AAE60";                        -- ~0.5 s
  signal integration_period_actual : std_logic_vector(31 downto 0)
 := (others => '0');
  signal hold_period : std_logic_vector(31 downto 0)
 := (others => '0');

  -- Dynamic Phase Reconfiguration - selects which channel to step.
  -- '0' for c0, '1' for c1.
  signal step_direction : std_logic := '0';

  signal s_reset_int      : std_logic := '0';  -- sync reset
  signal laser_mod_int    : std_logic := '0';
  signal camera_mod_int   : std_logic := '0';
  signal laser_mod_int_1  : std_logic := '0';
  signal camera_mod_int_1 : std_logic := '0';
  signal camera_mod_out   : std_logic := '0';
  signal laser_mod_out_1  : std_logic := '0';
  signal laser_mod_out_2  : std_logic := '0';
  signal begin_readout    : std_logic := '0';
  signal readout_complete : std_logic := '0';

  signal raw_pixel_data  : std_logic_vector(31 downto 0) := (others => '0');
  signal raw_pixel_addr  : std_logic_vector(14 downto 0) := (others => '0');
  signal raw_pixel_valid : std_logic                     := '0';

  signal raw_pixel_valid_int : std_logic := '0';

  signal pmd_busy : std_logic := '0';   -- PMD resetting, or reading out

  signal frame_index : std_logic_vector(15 downto 0) := (others => '0');

  signal frames_per_output_frame : std_logic_vector(15 downto 0) := (others => '0');

  signal fpb_1         : std_logic_vector(15 downto 0) := (others => '0');
  signal phase_step_1  : std_logic_vector(15 downto 0) := (others => '0');     
  signal phase_scale_1 : std_logic_vector(15 downto 0) := (others => '0');

  signal frame_count        : std_logic_vector(15 downto 0) := (others => '0');
  signal stall              : std_logic                     := '0';
  signal max_frames         : std_logic_vector(15 downto 0) := (others => '0');
  signal frame_received_int : std_logic                     := '0';
  signal frame_received_ack : std_logic                     := '0';
  signal pause              : std_logic                     := '0';

  signal TL_wren     : std_logic                     := '0';
  signal TL_wren_int : std_logic                     := '0';
  signal TL_din_int  : std_logic_vector(15 downto 0) := (others => '0');
  signal TL_addr_int : std_logic_vector(14 downto 0) := (others => '0');
  signal TR_wren     : std_logic                     := '0';
  signal TR_wren_int : std_logic                     := '0';
  signal TR_din_int  : std_logic_vector(15 downto 0) := (others => '0');
  signal TR_addr_int : std_logic_vector(14 downto 0) := (others => '0');
  signal BL_wren     : std_logic                     := '0';
  signal BL_wren_int : std_logic                     := '0';
  signal BL_din_int  : std_logic_vector(15 downto 0) := (others => '0');
  signal BL_addr_int : std_logic_vector(14 downto 0) := (others => '0');
  signal BR_wren     : std_logic                     := '0';
  signal BR_wren_int : std_logic                     := '0';
  signal BR_din_int  : std_logic_vector(15 downto 0) := (others => '0');
  signal BR_addr_int : std_logic_vector(14 downto 0) := (others => '0');

  signal process_phase_1 : std_logic_vector(15 downto 0) := (others => '0');
  signal process_mag_1   : std_logic_vector(15 downto 0) := (others => '0');
  signal process_addr    : std_logic_vector(14 downto 0) := (others => '0');
  signal process_valid   : std_logic                     := '0';

  signal debug_data_1 : std_logic_vector(15 downto 0) := (others => '0');
  signal debug_addr   : std_logic_vector(14 downto 0) := (others => '0');
  signal debug_valid  : std_logic                     := '0';

  signal sin_cosine_addr : std_logic_vector(8 downto 0) := (others => '0');
  signal sin_cosine_we   : std_logic                    := '0';

  signal sin_cosine_write_data : std_logic_vector(7 downto 0) := (others => '0');
  signal sin_cosine_read_data  : std_logic_vector(7 downto 0) := (others => '0');

  signal sin_1 : std_logic_vector(15 downto 0) := (others => '0');
  signal cos_1 : std_logic_vector(15 downto 0) := (others => '0');

  signal pixel_scale        : std_logic_vector(3 downto 0)  := (others => '0');
  signal dc_offset          : std_logic_vector(15 downto 0) := (others => '0');
  signal saturation_level   : std_logic_vector(15 downto 0) := (others => '0');
  signal phase_correction_1 : std_logic_vector(15 downto 0) := (others => '0');
  signal process_select     : std_logic                     := '0';


  signal adc_control_data : std_logic_vector(11 downto 0) := (others => '0');
  signal adc_we           : std_logic                     := '0';

  signal laser_control : std_logic_vector(1 downto 0) := (others => '0');


  signal freq_1_dout50 : std_logic_vector(15 downto 0) := (others => '0');
  signal freq_1_din    : std_logic_vector(15 downto 0) := (others => '0');
  signal freq_1_addr   : std_logic_vector(3 downto 0)  := (others => '0');
  signal freq_1_re     : std_logic                     := '0';
  signal freq_1_we     : std_logic                     := '0';
  signal freq_1_debug  : std_logic_vector(7 downto 0)  := (others => '0');

begin  -- rtl


  pmd_mod           <= camera_mod_out;
  laser_mod_1       <= laser_mod_out_1; -- Red channel
  laser_mod_2       <= laser_mod_out_2; -- IR channel

  leds         <= not frame_count(7 downto 0);


  MODULATION_CONTROL : entity work.mod_disambig
    port map (
      clk                => clk,
      reset_n            => reset_n,
      pmd_busy           => pmd_busy,
      integration_period => integration_period_actual,
      integration_ratio  => X"00",
      laser_control      => laser_control,
      camera_mod_in_1    => camera_mod_int_1,
      camera_mod_in_2    => camera_mod_int_1,
      laser_mod_in_1     => laser_mod_int_1,
      laser_mod_in_2     => laser_mod_int_1,
      camera_mod_out     => camera_mod_out,
      laser_mod_out_1    => laser_mod_out_1,
      laser_mod_out_2    => laser_mod_out_2);

  MODULATION_SOURCE_1 : entity work.mod_homodyne_c3
    generic map (IS_CYCLONE3 => IS_CYCLONE3,
				M_DEFAULT => X"3C",
                 C_DEFAULT => X"0F")
    port map (
      clk                          => clk,
      clk50                        => clk50,
      reset_n                      => reset_n,
      s_reset                      => s_reset_int,
      --step_direction               => step_direction,
      fpb                          => fpb_1,
      phase_step                   => phase_step_1,
      phase_scale                  => phase_scale_1,
      camera_mod                   => camera_mod_int_1,
      laser_mod                    => laser_mod_int_1,
      pmd_busy                     => pmd_busy,
      begin_readout                => begin_readout,
      frames_per_output_frame      => frames_per_output_frame,
      frame_index                  => frame_index,
      sin                          => sin_1,
      cos                          => cos_1,
      frame_period                 => frame_period,
      integration_period_requested => integration_period_requested,
      integration_period_actual    => integration_period_actual,
      hold_period                  => hold_period,
      freq_dout50                  => freq_1_dout50,
      freq_din                     => freq_1_din,
      freq_addr                    => freq_1_addr,
      freq_re                      => freq_1_re,
      freq_we                      => freq_1_we,
      freq_debug                   => freq_1_debug);


  PMD_INT : entity work.PMD19k_interface
    port map (
      clk              => clk,
      reset_n          => reset_n,
      s_reset          => s_reset_int,
      begin_readout    => begin_readout,
      readout_complete => readout_complete,
      pixel_data       => raw_pixel_data,
      pixel_addr       => raw_pixel_addr,
      pixel_valid      => raw_pixel_valid,
      pmd_busy         => pmd_busy,
      hold_period      => hold_period,
      stall            => pause,
      clk_r            => PMD_clk_r,
      clk_c            => PMD_clk_c,
      clear_r          => PMD_clear_r,
      clear_c          => PMD_clear_c,
      start_r          => PMD_start_r,
      start_c          => PMD_start_c,
      hold             => PMD_hold,
      pmd_reset_n      => PMD_reset_n,
      end_r            => PMD_end_r,
      end_c            => PMD_end_c,
      adc_data         => ADC_d,
      adcclk           => ADC_adcclk,
      cdsclk           => ADC_cdsclk,
      sdata            => ADC_sdata_write,
      sclk             => ADC_sclk,
      sload            => ADC_sload,
      sdata_rw         => ADC_sdata_we_n,
      adc_control_data => adc_control_data,
      adc_we           => adc_we); 

  TL_BUFFER : entity work.triram160x128xN
	generic map ( N => OB_WIDTH )
    port map (
      address_a => TL_addr,
      address_b => TL_addr_int,
      address_c => vga_addr,
      clock     => clk,
      data_a    => TL_din(15 downto 16-OB_WIDTH),
      data_b    => TL_din_int(15 downto 16-OB_WIDTH),
      data_c    => (others => '0'),
      wren_a    => TL_wren,
      wren_b    => TL_wren_int,
      wren_c    => '0',
      q_a       => TL_dout(15 downto 16-OB_WIDTH),
      q_b       => open,
      q_c       => vga_TL_dout(15 downto 16-OB_WIDTH)
      );

  TR_BUFFER : entity work.triram160x128xN
	generic map ( N => OB_WIDTH )
    port map (
      address_a => TR_addr,
      address_b => TR_addr_int,
      address_c => vga_addr,
      clock     => clk,
      data_a    => TR_din(15 downto 16-OB_WIDTH),
      data_b    => TR_din_int(15 downto 16-OB_WIDTH),
      data_c    => (others => '0'),
      wren_a    => TR_wren,
      wren_b    => TR_wren_int,
      wren_c    => '0',
      q_a       => TR_dout(15 downto 16-OB_WIDTH),
      q_b       => open,
      q_c       => vga_TR_dout(15 downto 16-OB_WIDTH)
      );


  BL_BUFFER : entity work.triram160x128xN
	generic map ( N => OB_WIDTH )
    port map (
      address_a => BL_addr,
      address_b => BL_addr_int,
      address_c => vga_addr,
      clock     => clk,
      data_a    => BL_din(15 downto 16-OB_WIDTH),
      data_b    => BL_din_int(15 downto 16-OB_WIDTH),
      data_c    => (others => '0'),
      wren_a    => BL_wren,
      wren_b    => BL_wren_int,
      wren_c    => '0',
      q_a       => BL_dout(15 downto 16-OB_WIDTH),
      q_b       => open,
      q_c       => vga_BL_dout(15 downto 16-OB_WIDTH)
      );

  BR_BUFFER : entity work.triram160x128xN
	generic map ( N => OB_WIDTH )
    port map (
      address_a => BR_addr,
      address_b => BR_addr_int,
      address_c => vga_addr,
      clock     => clk,
      data_a    => BR_din(15 downto 16-OB_WIDTH),
      data_b    => BR_din_int(15 downto 16-OB_WIDTH),
      data_c    => (others => '0'),
      wren_a    => BR_wren,
      wren_b    => BR_wren_int,
      wren_c    => '0',
      q_a       => BR_dout(15 downto 16-OB_WIDTH),
      q_b       => open,
      q_c       => vga_BR_dout(15 downto 16-OB_WIDTH)
      );

  PROCESSOR_1 : entity work.ranger_process
    port map (
      clk              => clk,
      reset_n          => reset_n,
      pixel_a          => raw_pixel_data(31 downto 16),
      pixel_b          => raw_pixel_data(15 downto 0),
      pixel_addr       => raw_pixel_addr,
      pixel_valid      => raw_pixel_valid,
      sine             => sin_1(15 downto 0),
      cosine           => cos_1(15 downto 0),
      frame_index      => frame_index,
      output_phase     => process_phase_1,
      output_mag       => process_mag_1,
      output_addr      => process_addr,
      output_valid     => process_valid,
      debug_data       => debug_data_1,
      debug_addr       => debug_addr,
      debug_valid      => debug_valid,
      pixel_scale      => pixel_scale,
      dc_offset        => dc_offset,
      saturation_level => saturation_level,
      phase_correction => phase_correction_1
      );

  CONTROL_REGISTERS : entity work.PMD19k_registers
    port map (
      clk                          => clk,
      reset_n                      => reset_n,
      control_addr                 => control_addr,
      control_din                  => control_din,
      control_dout                 => control_dout,
      control_we_n                 => control_we_n,
      control_re_n                 => control_re_n,
      s_reset                      => s_reset_int,
      integration_period_requested => integration_period_requested,
      integration_period_actual    => integration_period_actual,
      frame_period                 => frame_period,
      frame_received_ack           => frame_received_ack,
      max_frames                   => max_frames,
      frames_per_output_frame      => frames_per_output_frame,
      dc_offset                    => dc_offset,
      fpb_1                        => fpb_1,
      fpb_2                        => open,
      phase_step_1                 => phase_step_1,
      phase_step_2                 => open,
      phase_scale_1                => phase_scale_1,
      phase_scale_2                => open,
      integration_ratio            => open,
      step_direction               => step_direction,
      pause                        => pause,
      ssd                          => ssd,
      adc_control_data             => adc_control_data,
      adc_we                       => adc_we,
      saturation_level             => saturation_level,
      pixel_scale                  => pixel_scale,
      process_select               => process_select,
      laser_control                => laser_control,
      phase_correction_1           => phase_correction_1,
      phase_correction_2           => open,
      disambig_m                   => open,
      disambig_n                   => open,
      disambig_shift               => open,
      disambig_mm                  => open,
      disambig_weight1             => open,
      disambig_weight2             => open,
      freq_1_dout50                => freq_1_dout50,
      freq_1_din                   => freq_1_din,
      freq_1_addr                  => freq_1_addr,
      freq_1_re                    => freq_1_re,
      freq_1_we                    => freq_1_we,
      freq_2_dout50                => (others => '1'),
      freq_2_din                   => open,
      freq_2_addr                  => open,
      freq_2_re                    => open,
      freq_2_we                    => open
      );

  -- Nios write enables.
  TL_wren <= not TL_we_n;
  TR_wren <= not TR_we_n;
  BL_wren <= not BL_we_n;
  BR_wren <= not BR_we_n;

  -- Hardware RAM writing.   
  -- TOP LEFT = RAW PIXEL A
  TL_addr_int <= raw_pixel_addr;
  TL_din_int  <= frame_count(7 downto 0) & frame_count(15 downto 8) when raw_pixel_addr = "000000000000000"
                 else frame_count(7 downto 0) & frame_count(15 downto 8) when (stall = '1' and raw_pixel_addr(14 downto 10) = "00000")
                 else raw_pixel_data(15 downto 0);
  TL_wren_int <= raw_pixel_valid;

  -- TOP RIGHT = RAW PIXEL B
  TR_addr_int <= raw_pixel_addr;
  TR_din_int  <= frame_count(7 downto 0) & frame_count(15 downto 8) when raw_pixel_addr = "000000000000000"
                 else raw_pixel_data(31 downto 16);
  TR_wren_int <= raw_pixel_valid;

  -- BOTTOM LEFT = PHASE 1
  BL_addr_int <= process_addr;
  BL_din_int  <= frame_count(7 downto 0) & frame_count(15 downto 8) when process_addr = "000000000000000"
                 else process_phase_1;
  BL_wren_int <= process_valid when frame_index = (frames_per_output_frame-1) or process_addr = "000000000000000" else '0';

  -- BOTTOM RIGHT = MAG 1
  BR_addr_int <= process_addr;
  BR_din_int  <= frame_count(7 downto 0) & frame_count(15 downto 8) when process_addr = "000000000000000"
                 else process_mag_1;
  BR_wren_int <= process_valid when frame_index = (frames_per_output_frame-1) or process_addr = "000000000000000" else '0';



  DO_FRAME_COUNT : process (clk, reset_n)
  begin  -- process DO_FRAME_COUNT
    if reset_n = '0' then               -- asynchronous reset (active low)
      frame_count <= (others => '1');
      stall       <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      if s_reset_int = '1' or pause = '1' then
        frame_count <= (others => '1');
        stall       <= '0';
        --elsif pause = '1' then
        --stall <= '1';         
      elsif begin_readout = '1' then
        frame_count <= frame_count + 1;
        if max_frames = X"0000" then
          stall <= '1';
          --frame_count <= frame_count + 1;
        elsif frame_count = max_frames-1 then
          stall <= '1';
        else
          --stall       <= '0';
          --frame_count <= frame_count + 1;
        end if;
      end if;
    end if;
  end process DO_FRAME_COUNT;

  frame_received <= frame_received_int;

  SET_FRAME_RECEIVED : process(clk, reset_n)
  begin
    if reset_n = '0' then
      frame_received_int <= '0';
    elsif rising_edge(clk) then
      if readout_complete = '1' and stall = '0' then
        frame_received_int <= '1';
      end if;
      if frame_received_ack = '1' or s_reset_int = '1' then
        frame_received_int <= '0';
      end if;
    end if;
  end process SET_FRAME_RECEIVED;

  s_reset <= s_reset_int;

end rtl;
