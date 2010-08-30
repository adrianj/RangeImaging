-- Phase Controller for Stratix III PLLs
-- Inputs are the oscillator source, the desired output phase, initial
-- step value and step direction.
-- Outputs connect directly to phase related pins of Stratix III PLL.
-- Synchronous reset is available and should be pulsed after PLL frequency
-- reconfiguration.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity phase_controller is
  
  port (
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    s_reset              : in  std_logic;	   
	-- CHANGED: desired_phase and initial_step now count actual phase step pulses.
    desired_phase        : in  std_logic_vector(15 downto 0);
    initial_step         : in  std_logic_vector(15 downto 0);
    step_direction       : in  std_logic;
    steps_per_cycle      : in  std_logic_vector(11 downto 0);
    phase_counter_select : out std_logic_vector(3 downto 0);
    phase_up_down        : out std_logic;
    phase_step           : out std_logic
    );    

end phase_controller;

architecture rtl of phase_controller is

  -- Current_steps is measured in phase steps.
  -- Actual degrees is dependent on frequency by the formula
  -- degrees = 45 * f_output / f_VCO. f_VCO is calculated by PLL Megawizard.
  -- Eg, for 50 MHz input, 40 MHz output, f_VCO = 600 MHz.
  -- degrees = 45 * 40 / 600 = 3.
  signal current_steps : std_logic_vector(15 downto 0) := (others => '0');
  signal desired_steps : std_logic_vector(15 downto 0) := (others => '0');

  signal desired_phase_with_initial : std_logic_vector(15 downto 0) := (others => '0');

  signal phase_step_int : std_logic := '0';

  signal count   : std_logic_vector(5 downto 0) := (others => '0');
  signal pcs_int : std_logic_vector(3 downto 0) := (others => '0');

  
begin  -- rtl

  -- Calculate number of steps per full revolution
  CALC_STEPS : process (clk, reset_n)
    variable q : std_logic_vector(27 downto 0) := (others => '0');
  begin  -- process CALC_STEPS
    if reset_n = '0' then               -- asynchronous reset (active low)
      q                          := (others => '0');
      desired_steps              <= (others => '0');
      desired_phase_with_initial <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      desired_phase_with_initial <= desired_phase + initial_step;

      --q := desired_phase_with_initial * steps_per_cycle;
	  if desired_phase_with_initial >= steps_per_cycle then
	  	desired_steps <= desired_phase_with_initial - steps_per_cycle;
		else
      desired_steps <= desired_phase_with_initial;--q(27 downto 16);	
	  end if;
    end if;
  end process CALC_STEPS;

  -- if phasedone = '1', and current_steps /= desired_steps, phase_step = 1.
  DO_STEPS : process (clk, reset_n)
  begin  -- process DO_STEPS
    if reset_n = '0' then               -- asynchronous reset (active low)
      current_steps  <= (others => '0');
      phase_step_int <= '0';
      count          <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if s_reset = '1' then
        current_steps  <= (others => '0');
        phase_step_int <= '0';
        count          <= (others => '0');
      else
        count <= count + 1;
        if count(2 downto 0) = "001" then
          if current_steps /= desired_steps then
            phase_step_int <= '1';
            -- loop phase steps back to 0 after a full 360 degrees.
            if current_steps = steps_per_cycle-1 then
              current_steps <= (others => '0');
            else
              current_steps <= current_steps + 1;
            end if;
          end if;
          -- hold PhaseStep high for two extra clock cycles.
        elsif count(2) = '0' and phase_step_int = '1' then
          phase_step_int <= '1';
        else
          phase_step_int <= '0';
        end if;
      end if;
    end if;
  end process DO_STEPS;

  phase_step <= phase_step_int;

  -- registers phase counter select, because of issues.
  STUPID_PCS_THING : process (clk, reset_n)
  begin  -- process STUPID_PCS_THING
    if reset_n = '0' then               -- asynchronous reset (active low)
      pcs_int       <= (others => '0');
      phase_up_down <= '0';		
	  phase_counter_select <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
        if pcs_int = "0000" then
          pcs_int <= "1111";
        elsif pcs_int = "1111" then
          pcs_int <= "0011";
        end if;
        phase_up_down        <= step_direction;
        phase_counter_select <= pcs_int;
      end if;
  end process STUPID_PCS_THING;

end rtl;
