-- Full controller for stratix III reconfigurable PLL
-- Consists of two blocks:
-- Phase Controller: drives phase_step and phasecounterselect based
-- on desired phase and phase direction
-- Frequency Controller: Sets all other parameters using scan chain. These are
-- set through writable control registers with various addresses.
-- Everything is internally synchronised to the 50 MHz clk.     
-- Register read result is in 50 MHz domain, and is questionable... 
-- Possible require 2 consecutive reads to be guaranteed correct result.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pll_control_s3_full is
  generic (												
  	-- VCO pre_scale = 5, therefore actual VCO = 50 MHz / 5 * (M+M).
    M_DEFAULT : in std_logic_vector(7 downto 0) := X"3C";
    C_DEFAULT : in std_logic_vector(7 downto 0) := X"0F"
    );
  port (
    clk50              : in  std_logic;
    reset_n            : in  std_logic;
    -- CHANGED: desired_phase now counts actual phase step pulses.
    desired_phase      : in  std_logic_vector(15 downto 0);
    steps_per_cycle_50 : out std_logic_vector(15 downto 0);
    camera_mod         : out std_logic;
    laser_mod          : out std_logic;
    din                : in  std_logic_vector(15 downto 0);
    dout50             : out std_logic_vector(15 downto 0);
    addr               : in  std_logic_vector(3 downto 0);
    we                 : in  std_logic;
    re                 : in  std_logic;
    debug              : out std_logic_vector(7 downto 0)
    );    

end pll_control_s3_full;

architecture rtl of pll_control_s3_full is

  signal din50           : std_logic_vector(15 downto 0) := (others => '0');
  signal addr50          : std_logic_vector(3 downto 0)  := (others => '0');
  signal we50_2          : std_logic                     := '0';
  signal we50_1          : std_logic                     := '0';
  signal we50_rising     : std_logic                     := '0';
  signal re50_2          : std_logic                     := '0';
  signal re50_1          : std_logic                     := '0';
  signal re50_rising     : std_logic                     := '0';
  signal desired_phase50 : std_logic_vector(15 downto 0) := (others => '0');

  signal config_update        : std_logic                    := '0';
  signal phase_counter_select : std_logic_vector(3 downto 0) := "0010";
  signal phase_step           : std_logic                    := '0';
  signal phase_up_down        : std_logic                    := '0';
  signal scan_clk_enable      : std_logic                    := '0';
  signal scan_data            : std_logic                    := '0';
  signal pll_locked           : std_logic                    := '0';
  signal phase_done           : std_logic                    := '0';
  signal scan_data_out        : std_logic                    := '0';
  signal scan_done            : std_logic                    := '0';
  signal phase_reset          : std_logic                    := '0';
  signal pll_reset            : std_logic                    := '0';
  signal reconfig_in_progress : std_logic                    := '0';

  -- for triggering initial reconfig.
  signal reconfig_first_count : std_logic_vector(7 downto 0) := (others => '0');

  -- Control registers
  signal   step_direction       : std_logic                     := '0';
  constant STEP_DIRECTION_ADDR  : std_logic_vector(3 downto 0)  := X"0";
  signal   initial_step         : std_logic_vector(15 downto 0) := (others => '0');
  constant INITIAL_STEP_ADDR    : std_logic_vector(3 downto 0)  := X"1";
  signal   steps_per_cycle      : std_logic_vector(15 downto 0) := X"00F0";
  constant STEPS_PER_CYCLE_ADDR : std_logic_vector(3 downto 0)  := X"2";
  signal   begin_reconfig       : std_logic                     := '0';
  constant BEGIN_RECONFIG_ADDR  : std_logic_vector(3 downto 0)  := X"3";

  signal   c0_hi_count       : std_logic_vector(7 downto 0) := C_DEFAULT;
  constant C0_HI_COUNT_ADDR  : std_logic_vector(3 downto 0) := X"4";
  signal   c0_low_count      : std_logic_vector(7 downto 0) := C_DEFAULT;
  constant C0_LOW_COUNT_ADDR : std_logic_vector(3 downto 0) := X"5";
  signal   c1_hi_count       : std_logic_vector(7 downto 0) := C_DEFAULT;
  constant C1_HI_COUNT_ADDR  : std_logic_vector(3 downto 0) := X"6";
  signal   c1_low_count      : std_logic_vector(7 downto 0) := C_DEFAULT;
  constant C1_LOW_COUNT_ADDR : std_logic_vector(3 downto 0) := X"7";
  -- Default M is 12+12 = 24, = 50 MHz * 24 = 1200 MHz.
  signal   m_hi_count        : std_logic_vector(7 downto 0) := M_DEFAULT;
  constant M_HI_COUNT_ADDR   : std_logic_vector(3 downto 0) := X"8";
  signal   m_low_count       : std_logic_vector(7 downto 0) := M_DEFAULT;
  constant M_LOW_COUNT_ADDR  : std_logic_vector(3 downto 0) := X"9";   
  signal r_sel_odd : std_logic_vector(1 downto 0) := "00";
  constant R_SEL_ODD_ADDR : std_logic_vector(3 downto 0) := X"A";
  
  
begin

  -- Register all the inputs into the 50 MHz clock domain
  REGISTER_INPUTS : process (clk50, reset_n)
  begin  -- process REGISTER_INPUTS
    if reset_n = '0' then               -- asynchronous reset (active low)
      din50           <= (others => '0');
      addr50          <= (others => '0');
      we50_1          <= '0';
      we50_2          <= '0';
      we50_rising     <= '0';
      re50_1          <= '0';
      re50_2          <= '0';
      re50_rising     <= '0';
      desired_phase50 <= (others => '0');
    elsif rising_edge(clk50) then       -- rising clock edge
      desired_phase50 <= desired_phase;
      we50_1          <= we;
      we50_2          <= we50_1;
      we50_rising     <= we50_1 and not we50_2;
      re50_1          <= re;
      re50_2          <= re50_1;
      re50_rising     <= re50_1 and not re50_2;
      din50           <= din;
      addr50          <= addr;
    end if;
  end process REGISTER_INPUTS;

  THE_PLL : entity work.pll_reconfig_full
    port map (
      areset             => pll_reset,
      configupdate       => config_update,
      inclk0             => clk50,
      phasecounterselect => phase_counter_select,
      phasestep          => phase_step,
      phaseupdown        => phase_up_down,
      scanclk            => clk50,
      scanclkena         => scan_clk_enable,
      scandata           => scan_data,
      c0                 => camera_mod,
      c1                 => laser_mod,
      locked             => pll_locked,
      phasedone          => phase_done,
      scandataout        => scan_data_out,
      scandone           => scan_done);

  THE_PHASE_CON : entity work.phase_controller
    port map (
      clk                  => clk50,
      reset_n              => reset_n,
      s_reset              => phase_reset,
      desired_phase        => desired_phase50,
      initial_step         => initial_step,
      step_direction       => step_direction,
      steps_per_cycle      => steps_per_cycle(11 downto 0),
      phase_counter_select => phase_counter_select,
      phase_up_down        => phase_up_down,
      phase_step           => phase_step);

  THE_FREQ_CON : entity work.frequency_controller
    port map (
      clk                  => clk50,
      reset_n              => reset_n,
      begin_reconfig       => begin_reconfig,
      pll_locked           => pll_locked,
      reconfig_in_progress => reconfig_in_progress,
      scan_clk_enable      => scan_clk_enable,
      scan_data            => scan_data,
      scan_data_out        => scan_data_out,
      config_update        => config_update,
      pll_reset            => pll_reset,
      scan_done            => scan_done,
      c0_hi_count          => c0_hi_count,
      c0_low_count         => c0_low_count,
      c1_hi_count          => c1_hi_count,
      c1_low_count         => c1_low_count,
      m_hi_count           => m_hi_count,
      m_low_count          => m_low_count,
	  r_sel_odd => r_sel_odd);

  CONTROL_REGISTERS : process (clk50, reset_n)
  begin  -- process CONTROL_REGISTERS
    if reset_n = '0' then               -- asynchronous reset (active low)
      step_direction       <= '0';
      initial_step         <= (others => '0');
      --steps_per_cycle <= X"F0";
      begin_reconfig       <= '0';
      reconfig_first_count <= (others => '1');
      c0_hi_count          <= C_DEFAULT;
      c0_low_count         <= C_DEFAULT;
      c1_hi_count          <= C_DEFAULT;
      c1_low_count         <= C_DEFAULT;
      m_hi_count           <= M_DEFAULT;
      m_low_count          <= M_DEFAULT;   
	  r_sel_odd <= "00";
    elsif rising_edge(clk50) then       -- rising clock edge   
      if reconfig_first_count = X"80" then
        begin_reconfig <= '1';
      else
        begin_reconfig <= '0';
      end if;
      if reconfig_first_count /= X"00" then
        reconfig_first_count <= reconfig_first_count - 1;
      end if;
      if we50_rising = '1' then
        case addr50 is
          when STEP_DIRECTION_ADDR => step_direction <= din50(0);
          when INITIAL_STEP_ADDR   => initial_step   <= din50;
                                      --when STEPS_PER_CYCLE_ADDR => steps_per_cycle <= din(7 downto 0);
          when BEGIN_RECONFIG_ADDR => begin_reconfig <= '1';
          when C0_HI_COUNT_ADDR    => c0_hi_count    <= din(7 downto 0);
          when C0_LOW_COUNT_ADDR   => c0_low_count   <= din(7 downto 0);
          when C1_HI_COUNT_ADDR    => c1_hi_count    <= din(7 downto 0);
          when C1_LOW_COUNT_ADDR   => c1_low_count   <= din(7 downto 0);
          when M_HI_COUNT_ADDR     => m_hi_count     <= din(7 downto 0);
          when M_LOW_COUNT_ADDR    => m_low_count    <= din(7 downto 0);  
		  when R_SEL_ODD_ADDR => r_sel_odd <= din(1 downto 0);
          when others              => null;
        end case;
      end if;
    end if;
  end process CONTROL_REGISTERS;

  SET_RESETS : process (clk50, reset_n)
  begin  -- process SET_RESETS
    if reset_n = '0' then               -- asynchronous reset (active low)
      phase_reset <= '1';
    elsif rising_edge(clk50) then       -- rising clock edge
      if pll_reset = '1' then
        phase_reset <= '1';
      elsif reconfig_in_progress = '1' then
        phase_reset <= '1';
      elsif pll_locked = '1' then
        phase_reset <= '0';
      end if;
    end if;
  end process SET_RESETS;

  debug <= reconfig_in_progress & pll_locked & phase_step & scan_data & X"0";


  SET_STEPS_PER_CYCLE : process(clk50, reset_n)
    variable q : std_logic_vector(8 downto 0) := (others => '0');
  begin
    if reset_n = '0' then
      steps_per_cycle <= X"00F0";
      q               := (others => '0');
    elsif rising_edge(clk50) then
      q               := ('0' & c0_hi_count) + ('0' & c0_low_count);
      steps_per_cycle <= X"0" & q & "000";
    end if;
  end process SET_STEPS_PER_CYCLE;

  steps_per_cycle_50 <= steps_per_cycle;

  -- Reading from the registers... not sure how this will work out. 
  -- I suspect 2 reads in a row from Nios will be required
  CONTROL_REGISTER_READ : process (clk50, reset_n)
  begin
    if reset_n = '0' then
      dout50 <= (others => '0');
    elsif rising_edge(clk50) then
      if re50_rising = '1' then
        case addr50 is
          when STEP_DIRECTION_ADDR  => dout50 <= "000" & X"000" & step_direction;
          when INITIAL_STEP_ADDR    => dout50 <= initial_step;
          when STEPS_PER_CYCLE_ADDR => dout50 <= steps_per_cycle;
          when BEGIN_RECONFIG_ADDR  => dout50 <= "000" & X"000" & reconfig_in_progress;
          when C0_HI_COUNT_ADDR     => dout50 <= X"00" & c0_hi_count;
          when C0_LOW_COUNT_ADDR    => dout50 <= X"00" & c0_low_count;
          when C1_HI_COUNT_ADDR     => dout50 <= X"00" & c1_hi_count;
          when C1_LOW_COUNT_ADDR    => dout50 <= X"00" & c1_low_count;
          when M_HI_COUNT_ADDR      => dout50 <= X"00" & m_hi_count;
          when M_LOW_COUNT_ADDR     => dout50 <= X"00" & m_low_count;
		  when R_SEL_ODD_ADDR => dout50 <= X"000" & "00" & r_sel_odd;
          when others               => dout50 <= X"FEE6";
        end case;
      end if;
    end if;
  end process CONTROL_REGISTER_READ;

end rtl;
