-- Control registers for PMD 19k system
-- All default and reset values are for a system with:
-- 40 MHz + 33.333 MHz modulation, 128:128 ratio.
-- 5 and 2.5 frames per beat.
-- Output unambiguous range of 6553.6 mm
-- pixel value representes 1/10 mm.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PMD19k_registers is
  
  port (
    clk                          : in  std_logic;
    reset_n                      : in  std_logic;
    control_addr                 : in  std_logic_vector(15 downto 0);
    control_din                  : in  std_logic_vector(31 downto 0);
    control_dout                 : out std_logic_vector(31 downto 0);
    control_we_n                 : in  std_logic;
    control_re_n                 : in  std_logic;
    s_reset                      : out std_logic;
    integration_period_requested : out std_logic_vector(31 downto 0);
    integration_period_actual    : in  std_logic_vector(31 downto 0);
    hold_period                  : out std_logic_vector(31 downto 0);
    frame_period                 : out std_logic_vector(31 downto 0);
    max_frames                   : out std_logic_vector(15 downto 0);
    frames_per_output_frame      : out std_logic_vector(15 downto 0);
    fpb_1                        : out std_logic_vector(15 downto 0);
    phase_step_1                 : out std_logic_vector(15 downto 0); 
	phase_scale_1	: out std_logic_vector(15 downto 0);
    fpb_2                        : out std_logic_vector(15 downto 0);
    phase_step_2                 : out std_logic_vector(15 downto 0);  
	phase_scale_2	: out std_logic_vector(15 downto 0);
    integration_ratio            : out std_logic_vector(7 downto 0);
    step_direction               : out std_logic;
    pixel_scale                  : out std_logic_vector(3 downto 0);
    process_select               : out std_logic;	
	process_output_select : out std_logic_vector(7 downto 0);
    dc_offset                    : out std_logic_vector(15 downto 0);
    saturation_level : out std_logic_vector(15 downto 0);
    phase_correction_1             : out std_logic_vector(15 downto 0);
    phase_correction_2             : out std_logic_vector(15 downto 0);
    pause                        : out std_logic;
    frame_received_ack           : out std_logic;
    laser_control                : out std_logic_vector(1 downto 0);
    ssd                          : out std_logic_vector(15 downto 0);
    adc_control_data             : out std_logic_vector(11 downto 0);
    adc_we                       : out std_logic;
    disambig_m : out std_logic_vector(2 downto 0);
    disambig_n : out std_logic_vector(2 downto 0);
    disambig_shift : out std_logic_vector(3 downto 0);
    disambig_mm : out std_logic_vector(15 downto 0);  
	disambig_weight1 : out std_logic_vector(11 downto 0);
	disambig_weight2 : out std_logic_vector(11 downto 0);
    freq_1_din                   : out std_logic_vector(15 downto 0);
    freq_1_dout50                : in  std_logic_vector(15 downto 0);
    freq_1_re                    : out std_logic;
    freq_1_we                    : out std_logic;
    freq_1_addr                  : out std_logic_vector(3 downto 0);
    freq_2_din                   : out std_logic_vector(15 downto 0);
    freq_2_dout50                : in  std_logic_vector(15 downto 0);
    freq_2_re                    : out std_logic;
    freq_2_we                    : out std_logic;
    freq_2_addr                  : out std_logic_vector(3 downto 0)
    );

end PMD19k_registers;

architecture rtl of PMD19k_registers is


  signal frame_period_int : std_logic_vector(31 downto 0)
 := X"00013880";                        -- 0.08 seconds
  constant FRAME_PD_ADDR : std_logic_vector(15 downto 0) := X"0000";

  signal integration_period_requested_int : std_logic_vector(31 downto 0)
 := X"00013880";                        -- 30 ms
  constant INTEGRATION_PD_REQ_ADDR : std_logic_vector(15 downto 0) := X"0001";
  constant INTEGRATION_PD_ACT_ADDR : std_logic_vector(15 downto 0) := X"0002";

  constant MAX_FRAMES_ADDR  : std_logic_vector(15 downto 0) := X"0003";
  signal   max_frames_int   : std_logic_vector(15 downto 0) := (others => '0');
  constant COUNTER_ADDR     : std_logic_vector(15 downto 0) := X"0004";
  constant COUNTER_RST_ADDR : std_logic_vector(15 downto 0) := X"0005";
  signal   counter          : std_logic_vector(31 downto 0) := (others => '0');
  signal   counter_rst      : std_logic_vector(31 downto 0) := (others => '0');

  constant FRAME_RECD_ACK_ADDR : std_logic_vector(15 downto 0) := X"0006";
  constant PAUSE_ADDR          : std_logic_vector(15 downto 0) := X"0007";
  signal   pause_int           : std_logic                     := '0';



  --constant SIN_COSINE_OFFSET : std_logic_vector(6 downto 0) := "0000001";

  constant FRAMES_PER_OUTPUT_ADDR : std_logic_vector(15 downto 0) := X"0008";
  signal   frames_per_output_int  : std_logic_vector(15 downto 0) := X"0006";

  --constant SSD_ADDR     : std_logic_vector(15 downto 0) := X"0009";
  signal   ssd_int      : std_logic_vector(15 downto 0) := X"1234";
  constant S_RESET_ADDR : std_logic_vector(15 downto 0) := X"000A";

  constant ADC_ADDR     : std_logic_vector(15 downto 0) := X"000B";
  signal   adc_data_int : std_logic_vector(11 downto 0) := (others => '0');
  
  constant SATURATION_ADDR     : std_logic_vector(15 downto 0) := X"0009";
  signal   saturation_int      : std_logic_vector(15 downto 0) := X"8500";

  signal   dc_offset_int  : std_logic_vector(15 downto 0) := (others => '0');
  constant DC_OFFSET_ADDR : std_logic_vector(15 downto 0) := X"000C";

  signal   phase_correction_1_int  : std_logic_vector(15 downto 0) := X"09AE";
  constant PHASE_CORRECTION_1_ADDR : std_logic_vector(15 downto 0) := X"000D";
  signal   phase_correction_2_int  : std_logic_vector(15 downto 0) := X"C6C8";
  constant PHASE_CORRECTION_2_ADDR : std_logic_vector(15 downto 0) := X"000E";
  signal   process_output_select_int  : std_logic_vector(7 downto 0) := X"01";
  constant PROCESS_OUTPUT_SELECT_ADDR : std_logic_vector(15 downto 0) := X"000F";
  
  constant FPB_1_ADDR        : std_logic_vector(15 downto 0) := X"0010";
  constant FPB_2_ADDR        : std_logic_vector(15 downto 0) := X"0011";
  constant PHASE_STEP_1_ADDR : std_logic_vector(15 downto 0) := X"0012";
  constant PHASE_STEP_2_ADDR : std_logic_vector(15 downto 0) := X"0013";
  signal   fpb_1_int         : std_logic_vector(15 downto 0) := X"0005";
  signal   fpb_2_int         : std_logic_vector(15 downto 0) := X"0005";
  signal   phase_step_1_int  : std_logic_vector(15 downto 0) := X"0028";
  signal   phase_step_2_int  : std_logic_vector(15 downto 0) := X"0050";

  constant INTEGRATION_RATIO_ADDR : std_logic_vector(15 downto 0) := X"0014";
  signal   integration_ratio_int  : std_logic_vector(7 downto 0)  := X"80";

  constant PIXEL_SCALE_ADDR : std_logic_vector(15 downto 0) := X"0015";
  signal   pixel_scale_int  : std_logic_vector(3 downto 0);

  constant PROCESS_SELECT_ADDR : std_logic_vector(15 downto 0) := X"0016";
  signal   process_select_int  : std_logic                     := '0';
  constant LASER_CONTROL_ADDR  : std_logic_vector(15 downto 0) := X"0017";
  -- Laser illumination control. '0' = off. Red = MSB.
  signal   laser_control_int   : std_logic_vector(1 downto 0)  := "11";	 
  
  constant PHASE_SCALE_1_ADDR : std_logic_vector(15 downto 0) := X"0018";
  signal phase_scale_1_int : std_logic_vector(15 downto 0) := X"0147";  
  constant PHASE_SCALE_2_ADDR : std_logic_vector(15 downto 0) := X"0019";
  signal phase_scale_2_int : std_logic_vector(15 downto 0) := X"0147";
  
  constant DISAMBIG_M_ADDR : std_logic_vector(15 downto 0) := X"001A";
  signal disambig_m_int : std_logic_vector(2 downto 0) := "101";
  constant DISAMBIG_N_ADDR : std_logic_vector(15 downto 0) := X"001B";
  signal disambig_n_int : std_logic_vector(2 downto 0) := "100";
  constant DISAMBIG_SHIFT_ADDR : std_logic_vector(15 downto 0) := X"001C";
  signal disambig_shift_int : std_logic_vector(3 downto 0) := X"A";	 
  constant DISAMBIG_MM_ADDR : std_logic_vector(15 downto 0) := X"001D";
  signal disambig_mm_int : std_logic_vector(15 downto 0) := X"0080";  
  constant DISAMBIG_WEIGHT1_ADDR : std_logic_vector(15 downto 0) := X"001E";
  signal disambig_weight1_int : std_logic_vector(11 downto 0) := X"900"; 
  constant DISAMBIG_WEIGHT2_ADDR : std_logic_vector(15 downto 0) := X"001F";
  signal disambig_weight2_int : std_logic_vector(11 downto 0) := X"900";

  constant FREQ_CONTROL_OFFSET_1 : std_logic_vector(11 downto 0) := X"002";
  signal   freq_1_dout           : std_logic_vector(15 downto 0) := (others => '0');
  signal   freq_1_we_sreg        : std_logic_vector(7 downto 0)  := (others => '0');
  signal   freq_1_re_sreg        : std_logic_vector(7 downto 0)  := (others => '0');
  constant FREQ_CONTROL_OFFSET_2 : std_logic_vector(11 downto 0) := X"003";
  signal   freq_2_dout           : std_logic_vector(15 downto 0) := (others => '0');
  signal   freq_2_we_sreg        : std_logic_vector(7 downto 0)  := (others => '0');
  signal   freq_2_re_sreg        : std_logic_vector(7 downto 0)  := (others => '0');

begin  -- rtl

  DO_WRITES : process (clk, reset_n)
  begin  -- process DO_WRITES
    if reset_n = '0' then               -- asynchronous reset (active low)    
      frame_period_int                 <= X"00013880";
      integration_period_requested_int <= X"00013880";
      max_frames_int                   <= (others => '0');
      s_reset                          <= '1';
      frame_received_ack               <= '0';
      pause_int                        <= '0';
      frames_per_output_int            <= X"0004";
      ssd_int                          <= X"1234";
      saturation_int <= X"8500";
      fpb_1_int                        <= X"0004";	-- default steps_per_cycle = 1200 MHz / 40 MHz * 8 = 240
      fpb_2_int                        <= X"0004";
      phase_step_1_int                 <= X"003C";	-- default phase step = 120 / 4 = 30
      phase_step_2_int                 <= X"003C";
	  phase_scale_1_int <= X"0111"; -- default phase scale = 65536 / 240 = 273
	  phase_scale_2_int <= X"0111";
      integration_ratio_int            <= X"00";
      adc_data_int                     <= (others => '0');
      adc_we                           <= '0';
      pixel_scale_int                  <= (others => '0');
      process_select_int               <= '0';	  
	  process_output_select_int <= X"01";
      laser_control_int                <= "11";  -- default both on
      dc_offset_int                    <= (others => '0');
      phase_correction_1_int             <= X"15A0";
      phase_correction_2_int             <= X"D418";   
	  
	  -- These reset parameters are based on 5 and 2.5 frames/cycle, fA = 40MHz, fB = 32 MHz.
      disambig_m_int <= "110";
      disambig_n_int <= "101";
      disambig_shift_int <= X"A";
      disambig_mm_int <= X"0010";
      disambig_weight1_int <= X"EA6"; 
	  disambig_weight2_int <= X"EA6";

    elsif rising_edge(clk) then         -- rising clock edge
      s_reset            <= '0';
      frame_received_ack <= '0';
      adc_we             <= '0';

      if control_we_n = '0' then
        case control_addr is
          when FRAME_PD_ADDR => frame_period_int <= control_din;

          when INTEGRATION_PD_REQ_ADDR => integration_period_requested_int <= control_din;

          when MAX_FRAMES_ADDR     => max_frames_int     <= control_din(15 downto 0);
          when FRAME_RECD_ACK_ADDR => frame_received_ack <= '1';
          when PAUSE_ADDR          => pause_int          <= control_din(0);
          when S_RESET_ADDR        => s_reset            <= '1';

          when FRAMES_PER_OUTPUT_ADDR => frames_per_output_int <= control_din(15 downto 0);
          when DC_OFFSET_ADDR         => dc_offset_int         <= control_din(15 downto 0);
          when PHASE_CORRECTION_1_ADDR => phase_correction_1_int <= control_din(15 downto 0);
          when PHASE_CORRECTION_2_ADDR => phase_correction_2_int <= control_din(15 downto 0);
		  when PROCESS_OUTPUT_SELECT_ADDR => process_output_select_int <= control_din(7 downto 0);

          when SATURATION_ADDR          => saturation_int          <= control_din(15 downto 0);
          when FPB_1_ADDR        => fpb_1_int        <= control_din(15 downto 0);
          when FPB_2_ADDR        => fpb_2_int        <= control_din(15 downto 0);
          when PHASE_STEP_1_ADDR => phase_step_1_int <= control_din(15 downto 0);
          when PHASE_STEP_2_ADDR => phase_step_2_int <= control_din(15 downto 0);

          when INTEGRATION_RATIO_ADDR => integration_ratio_int <= control_din(7 downto 0);

          when PIXEL_SCALE_ADDR      => pixel_scale_int      <= control_din(3 downto 0);
          when PROCESS_SELECT_ADDR   => process_select_int   <= control_din(0);
          when LASER_CONTROL_ADDR    => laser_control_int    <= control_din(1 downto 0);
           
		  when PHASE_SCALE_1_ADDR => phase_scale_1_int <= control_din(15 downto 0);
          when PHASE_SCALE_2_ADDR => phase_scale_2_int <= control_din(15 downto 0);
          when DISAMBIG_M_ADDR => disambig_m_int <= control_din(2 downto 0);
          when DISAMBIG_N_ADDR => disambig_n_int <= control_din(2 downto 0);
          when DISAMBIG_SHIFT_ADDR => disambig_shift_int <= control_din(3 downto 0);  
          when DISAMBIG_MM_ADDR => disambig_mm_int <= control_din(15 downto 0);	  
		  when DISAMBIG_WEIGHT1_ADDR => disambig_weight1_int <= control_din(11 downto 0);
		  when DISAMBIG_WEIGHT2_ADDR => disambig_weight2_int <= control_din(11 downto 0);
          when ADC_ADDR              =>
            adc_data_int <= control_din(11 downto 0);
            adc_we       <= '1';
          when others => null;
        end case;

      end if;
    end if;
  end process DO_WRITES;

  max_frames                   <= max_frames_int;
  integration_period_requested <= integration_period_requested_int;
  frame_period                 <= frame_period_int;
  pause                        <= pause_int;
  frames_per_output_frame      <= frames_per_output_int;
  ssd                          <= ssd_int;
  integration_ratio            <= integration_ratio_int;
  phase_step_1                 <= phase_step_1_int;
  phase_step_2                 <= phase_step_2_int;	 
  phase_scale_1 <= phase_scale_1_int;
  phase_scale_2 <= phase_scale_2_int;
  fpb_1                        <= fpb_1_int;
  fpb_2                        <= fpb_2_int;
  pixel_scale                  <= pixel_scale_int;
  adc_control_data             <= adc_data_int;
  process_select               <= process_select_int;	
  process_output_select <= process_output_select_int;
  laser_control                <= laser_control_int;
  dc_offset                    <= dc_offset_int;
  saturation_level <= saturation_int;
  phase_correction_1             <= phase_correction_1_int;
  phase_correction_2             <= phase_correction_2_int;
  disambig_m <= disambig_m_int;
  disambig_n <= disambig_n_int;
  disambig_shift <= disambig_shift_int;	   
  disambig_mm <= disambig_mm_int;  
  disambig_weight1 <= disambig_weight1_int;	   
  disambig_weight2 <= disambig_weight2_int;

  DO_READS : process (control_addr, max_frames_int, integration_period_requested_int,
                      integration_period_actual, frame_period_int, counter,
                      counter_rst, integration_ratio_int, fpb_1_int, fpb_2_int,
                      phase_step_1_int, phase_step_2_int, ssd_int, pause_int,
                      frames_per_output_int, pixel_scale_int, process_select_int,
                      laser_control_int, freq_1_dout, dc_offset_int, phase_correction_1_int, 
					  phase_correction_2_int,freq_2_dout, phase_scale_1_int, phase_scale_2_int,
					  disambig_m_int, disambig_n_int, disambig_weight1_int, disambig_weight2_int,
					  disambig_mm_int, disambig_shift_int, saturation_int, process_output_select_int)
  begin  -- process DO_READS
    case control_addr is
      when FRAME_PD_ADDR => control_dout <= frame_period_int;

      when INTEGRATION_PD_REQ_ADDR => control_dout <= integration_period_requested_int;

      when INTEGRATION_PD_ACT_ADDR => control_dout <= integration_period_actual;

      when MAX_FRAMES_ADDR        => control_dout <= X"0000" & max_frames_int;
      when COUNTER_ADDR           => control_dout <= counter;
      when COUNTER_RST_ADDR       => control_dout <= counter_rst;
      when PAUSE_ADDR             => control_dout <= X"0000000" & "000" & pause_int;
      when SATURATION_ADDR               => control_dout <= X"0000" & saturation_int;
      when FRAMES_PER_OUTPUT_ADDR => control_dout <= X"0000" & frames_per_output_int;
      when DC_OFFSET_ADDR         => control_dout <= X"0000" & dc_offset_int;
      when PHASE_CORRECTION_1_ADDR  => control_dout <= X"0000" & phase_correction_1_int; 
      when PHASE_CORRECTION_2_ADDR  => control_dout <= X"0000" & phase_correction_2_int;  
	  when PROCESS_OUTPUT_SELECT_ADDR  => control_dout <= X"000000" & process_output_select_int; 
      when FPB_1_ADDR             => control_dout <= X"0000" & fpb_1_int;
      when FPB_2_ADDR             => control_dout <= X"0000" & fpb_2_int;
      when PHASE_STEP_1_ADDR      => control_dout <= X"0000" & phase_step_1_int;
      when PHASE_STEP_2_ADDR      => control_dout <= X"0000" & phase_step_2_int;
      when INTEGRATION_RATIO_ADDR => control_dout <= X"000000" & integration_ratio_int;
      when PIXEL_SCALE_ADDR       => control_dout <= X"0000000" & pixel_scale_int;
      when PROCESS_SELECT_ADDR    => control_dout <= (0 => process_select_int, others => '0');
      when LASER_CONTROL_ADDR     => control_dout <= "00" & X"0000000" & laser_control_int;
      
	  when PHASE_SCALE_1_ADDR      => control_dout <= X"0000" & phase_scale_1_int;
      when PHASE_SCALE_2_ADDR      => control_dout <= X"0000" & phase_scale_2_int;
      when DISAMBIG_M_ADDR => control_dout <= X"0000000" & '0' & disambig_m_int;
      when DISAMBIG_N_ADDR => control_dout <= X"0000000" & '0' & disambig_n_int;
      when DISAMBIG_SHIFT_ADDR => control_dout <= X"0000000" & disambig_shift_int; 
      when DISAMBIG_MM_ADDR => control_dout <= X"0000" & disambig_mm_int;	
	  when DISAMBIG_WEIGHT1_ADDR => control_dout <= X"00000" & disambig_weight1_int;  
	  when DISAMBIG_WEIGHT2_ADDR => control_dout <= X"00000" & disambig_weight2_int;

      when others =>
        if control_addr(15 downto 4) = FREQ_CONTROL_OFFSET_1 then
          control_dout <= X"0000" & freq_1_dout;
        elsif control_addr(15 downto 4) = FREQ_CONTROL_OFFSET_2 then
          control_dout <= X"0000" & freq_2_dout;
        else
          control_dout <= X"FEEDF00D";
        end if;
    end case;
  end process DO_READS;

  DO_COUNTERS : process (clk, reset_n)
  begin  -- process DO_COUNTERS
    if reset_n = '0' then               -- asynchronous reset (active low)
      counter     <= (others => '0');
      counter_rst <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      counter <= counter + 1;
      if control_addr = COUNTER_RST_ADDR and control_re_n = '0' then
        counter_rst <= (others => '0');
      else
        counter_rst <= counter_rst + 1;
      end if;
    end if;
  end process DO_COUNTERS;

  -- PLL Control read and write registers.
  -- These are handled specially because they cross clock domains.
  DO_FREQ_CONTROL_INPUTS : process (clk, reset_n)
  begin  -- process DO_PLL_CONTROL_INPUTS
    if reset_n = '0' then               -- asynchronous reset (active low)
      freq_1_din     <= (others => '0');
      freq_1_addr    <= (others => '0');
      freq_1_dout    <= (others => '0');
      freq_1_re      <= '0';
      freq_1_we      <= '0';
      freq_1_we_sreg <= (others => '0');
      freq_1_re_sreg <= (others => '0');
      freq_2_din     <= (others => '0');
      freq_2_addr    <= (others => '0');
      freq_2_dout    <= (others => '0');
      freq_2_re      <= '0';
      freq_2_we      <= '0';
      freq_2_we_sreg <= (others => '0');
      freq_2_re_sreg <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      freq_1_dout <= freq_1_dout50;
      freq_2_dout <= freq_2_dout50;
      if control_addr(15 downto 4) = FREQ_CONTROL_OFFSET_1 and control_we_n = '0' then
        freq_1_we_sreg <= freq_1_we_sreg(6 downto 0) & '1';
        freq_1_addr    <= control_addr(3 downto 0);
        freq_1_din     <= control_din(15 downto 0);
      else
        freq_1_we_sreg <= freq_1_we_sreg(6 downto 0) & '0';
      end if;
      if freq_1_we_sreg = 0 then
        freq_1_we <= '0';
      else
        freq_1_we <= '1';
      end if;
      if control_addr(15 downto 4) = FREQ_CONTROL_OFFSET_2 and control_we_n = '0' then
        freq_2_we_sreg <= freq_2_we_sreg(6 downto 0) & '1';
        freq_2_addr    <= control_addr(3 downto 0);
        freq_2_din     <= control_din(15 downto 0);
      else
        freq_2_we_sreg <= freq_2_we_sreg(6 downto 0) & '0';
      end if;
      if freq_2_we_sreg = 0 then
        freq_2_we <= '0';
      else
        freq_2_we <= '1';
      end if;


      if control_addr(15 downto 4) = FREQ_CONTROL_OFFSET_1 and control_re_n = '0' then
        freq_1_re_sreg <= freq_1_re_sreg(6 downto 0) & '1';
        freq_1_addr    <= control_addr(3 downto 0);
      else
        freq_1_re_sreg <= freq_1_re_sreg(6 downto 0) & '0';
      end if;
      if freq_1_re_sreg = 0 then
        freq_1_re <= '0';
      else
        freq_1_re <= '1';
      end if;
      if control_addr(15 downto 4) = FREQ_CONTROL_OFFSET_2 and control_re_n = '0' then
        freq_2_re_sreg <= freq_2_re_sreg(6 downto 0) & '1';
        freq_2_addr    <= control_addr(3 downto 0);
      else
        freq_2_re_sreg <= freq_2_re_sreg(6 downto 0) & '0';
      end if;
      if freq_2_re_sreg = 0 then
        freq_2_re <= '0';
      else
        freq_2_re <= '1';
      end if;
    end if;
  end process DO_FREQ_CONTROL_INPUTS;

end rtl;
