-- Homodyne modulation using Stratix III Phase Stepping.
-- Typically uses phase step resolution of 1.5 degrees = 240 steps per cycle.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mod_homodyne_c3 is
  generic (			 
    IS_CYCLONE3 : in std_logic := '1';
    M_DEFAULT : in std_logic_vector(7 downto 0) := X"10";
    C_DEFAULT : in std_logic_vector(7 downto 0) := X"0F"
    );
  port (
    clk                          : in  std_logic;
    clk50                        : in  std_logic;
    reset_n                      : in  std_logic;
    s_reset                      : in  std_logic;
    --step_direction               : in  std_logic;
    -- Number of frames per beat cycle.
    fpb                          : in  std_logic_vector(15 downto 0);
    -- step size between frames = 2^16 / fpb.    
    -- CHANGED: phase_step now counts actual phase step pulses.
    phase_step                   : in  std_logic_vector(15 downto 0);
    -- phase_scale is used to convert from phase_steps to phase in range 0->2^16. 
    -- it is equal to 8192/pll_counter_sum, best calculated in Nios since it involves division.
    phase_scale                  : in  std_logic_vector(15 downto 0);
    camera_mod                   : out std_logic;
    laser_mod                    : out std_logic;
    pmd_busy                     : in  std_logic;
    begin_readout                : out std_logic;
    -- some multiple of fpb.
    frames_per_output_frame      : in  std_logic_vector(15 downto 0);
    frame_index                  : out std_logic_vector(15 downto 0);
    sin                          : out std_logic_vector(15 downto 0);
    cos                          : out std_logic_vector(15 downto 0);
    -- frame_period = integration_period + readout + hold time (T11) 
    frame_period                 : in  std_logic_vector(31 downto 0);
    integration_period_requested : in  std_logic_vector(31 downto 0);
    -- clock cycles per integration
    integration_period_actual    : out std_logic_vector(31 downto 0);
    hold_period                  : out std_logic_vector(31 downto 0);

    freq_dout50 : out std_logic_vector(15 downto 0);
    freq_din    : in  std_logic_vector(15 downto 0);
    freq_addr   : in  std_logic_vector(3 downto 0);
    freq_re     : in  std_logic;
    freq_we     : in  std_logic;
    freq_debug  : out std_logic_vector(7 downto 0)

    );

end mod_homodyne_c3;

architecture rtl of mod_homodyne_c3 is

  signal frame_index_int        : std_logic_vector(15 downto 0) := (others => '0');
  signal frame_index_int2       : std_logic_vector(15 downto 0) := (others => '0');
  signal mod_count              : std_logic_vector(1 downto 0)  := (others => '0');
  signal mod_enable             : std_logic                     := '0';
  signal integration_count      : std_logic_vector(31 downto 0) := (others => '0');
  signal integration_count_100  : std_logic_vector(6 downto 0)  := (others => '0');
  signal integration_period_int : std_logic_vector(31 downto 0) := (others => '0');
  signal steps_per_cycle_50     : std_logic_vector(15 downto 0) := (others => '0');
  signal steps_per_cycle        : std_logic_vector(15 downto 0) := (others => '0');

  -- This is the time subtracted from integration time requested to give integration time actual
  -- when integration time is close to frame period.
  --constant READOUT_TIME : std_logic_vector(15 downto 0) := X"0C57";  
  constant READOUT_TIME : std_logic_vector(15 downto 0) := X"0C7D";


  signal desired_phase        : std_logic_vector(15 downto 0) := (others => '0');
  signal desired_phase_scaled : std_logic_vector(15 downto 0) := (others => '0');
  signal begin_readout_int    : std_logic                     := '0';

  signal camera_mod_raw : std_logic := '0';
  
begin  -- rtl

  DO_MOD : process (clk, reset_n)
  begin  -- process DO_MOD
    if reset_n = '0' then               -- asynchronous reset (active low)
      frame_index_int       <= (others => '1');
      frame_index_int2      <= (others => '1');
      integration_count     <= (others => '0');
      integration_count_100 <= (others => '0');
      begin_readout_int     <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      begin_readout_int <= '0';
      if s_reset = '1' then
        frame_index_int  <= (others => '1');
        frame_index_int2 <= (others => '1');
      elsif pmd_busy = '1' then
        integration_count     <= integration_period_int;
        integration_count_100 <= (others => '0');
      elsif integration_count = 2 and integration_count_100 = 67 then
        begin_readout_int     <= '1';   -- initiate frame readout
        integration_count     <= X"00000010";  -- will cause pmd_busy to go high
        integration_count_100 <= (others => '0');

        -- Have two frame_index values. 1st if for total frames per output frame.
        -- Second is for total frames within this cycle.
        if frame_index_int = frames_per_output_frame - 1 then
          frame_index_int <= (others => '0');
        else
          frame_index_int <= frame_index_int + 1;
        end if;
        if frame_index_int2 = fpb - 1 then
          frame_index_int2 <= (others => '0');
        else
          frame_index_int2 <= frame_index_int2 + 1;
        end if;
      else
        integration_count_100 <= integration_count_100 + 1;
        if integration_count_100 = 99 then
          integration_count     <= integration_count - 1;
          integration_count_100 <= (others => '0');
        end if;
      end if;
    end if;
  end process DO_MOD;

  begin_readout <= begin_readout_int;
  frame_index   <= frame_index_int;

  THE_CORDIC_COS : entity work.cordic_cosine
    generic map (I => 12)
    port map (
      clk         => clk,
      reset_n     => reset_n,
      phase_in    => desired_phase_scaled,
      sin_out     => sin,
      cos_out     => cos,
      nd          => '0',
      rdy         => open,
      storage_in  => X"0000",
      storage_out => open);


  THE_PLL_CONTROLLER : entity work.pll_control_c3_full
    generic map (
      C_DEFAULT => C_DEFAULT,
      M_DEFAULT => M_DEFAULT)
    port map (
      clk50              => clk50,
      reset_n            => reset_n,
      desired_phase      => desired_phase,
      steps_per_cycle_50 => steps_per_cycle_50,
      camera_mod         => camera_mod,
      laser_mod          => laser_mod,
      din                => freq_din,
      dout50             => freq_dout50,
      addr               => freq_addr,
      we                 => freq_we,
      re                 => freq_re,
      debug              => freq_debug);          





  -- increment desired phase with begin_readout pulse
  -- if frame_index_int2 is equal to fpb-1, reset phase to 0.
  process(clk, reset_n)
    variable q : std_logic_vector(15 downto 0) := (others => '0');
  begin
    if reset_n = '0' then
      desired_phase <= (others => '0');
      
    elsif rising_edge(clk) then
      if begin_readout_int = '1' then
        if frame_index_int2 = fpb - 1 then
          desired_phase <= (others => '0');
        else
          q := desired_phase + phase_step;
          if q >= steps_per_cycle then
            desired_phase <= q - steps_per_cycle;
          else
            desired_phase <= q;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk, reset_n)
    variable q : std_logic_vector(31 downto 0) := (others => '0');
  begin
    if reset_n = '0' then
      steps_per_cycle      <= (others => '0');
      desired_phase_scaled <= (others => '0');
    elsif rising_edge(clk) then
      steps_per_cycle      <= steps_per_cycle_50;
      q                    := desired_phase * phase_scale;
      desired_phase_scaled <= q(15 downto 0);
    end if;
  end process;

  -- This all gets quite confusing...
  -- Basically... setting frame period is guaranteed.
  -- Integration time actual = FramePeriod - Readout, 
  -- or Integration requested, whichever is the lower.  
  -- counts are in us, ie, 100s of clocks.
  CALC_HOLD_TIME : process(clk, reset_n)
    variable temp : std_logic_vector(31 downto 0) := (others => '0');
  begin
    if reset_n = '0' then
      hold_period            <= (others => '0');
      integration_period_int <= (others => '0');
    elsif rising_edge(clk) then
      temp := frame_period - integration_period_requested - READOUT_TIME;
      if temp(31) = '1' then
        hold_period            <= (others => '0');
        integration_period_int <= frame_period - READOUT_TIME;
      else
        hold_period            <= temp;
        integration_period_int <= integration_period_requested;
      end if;
    end if;
  end process CALC_HOLD_TIME;

  integration_period_actual <= integration_period_int;

end rtl;
