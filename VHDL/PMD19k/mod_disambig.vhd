-- Controller for multi-frequency modulation.
-- The idea is that two independent PLLs are both running internall, and
-- this module selects which is being output to the hardware.
-- Also controls which of the laser output channels is turned on, if any. 
-- If integration_ratio is 0, only modulation source 1 is used.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mod_disambig is
  
  port (
    clk                : in  std_logic;
    reset_n            : in  std_logic;	 
	pmd_busy 	   		: in std_logic;
    integration_period : in  std_logic_vector(31 downto 0);
    integration_ratio          : in  std_logic_vector(7 downto 0);
    laser_control      : in  std_logic_vector(1 downto 0);
    camera_mod_in_1    : in  std_logic;
    camera_mod_in_2    : in  std_logic;
    laser_mod_in_1     : in  std_logic;
    laser_mod_in_2     : in  std_logic;
    camera_mod_out     : out std_logic;
    laser_mod_out_1    : out std_logic;
    laser_mod_out_2    : out std_logic);

end mod_disambig;

architecture rtl of mod_disambig is

  type   STATE_TYPE is (HOLD, S_PMD_BUSY, MOD_PERIOD_1, CHANGE, MOD_PERIOD_2);
  signal cs : STATE_TYPE := HOLD;

  signal int_period_1      : std_logic_vector(31 downto 0) := (others => '0');
  signal int_period_2      : std_logic_vector(31 downto 0) := (others => '0');
  signal count100          : std_logic_vector(6 downto 0)  := (others => '0');
  signal count_us          : std_logic_vector(31 downto 0) := (others => '0');
  signal laser_control_int : std_logic_vector(1 downto 0)  := (others => '0');

  -- control signals for camera and laser outputs.
  -- LSB selects on or off
  -- MSB selects source.
  signal laser_select_1 : std_logic_vector(1 downto 0) := "00";
  signal laser_select_2 : std_logic_vector(1 downto 0) := "00";
  signal camera_select  : std_logic_vector(1 downto 0) := "00";


begin  -- rtl

  SET_INT_PERIODS : process (clk, reset_n)
    variable q1 : std_logic_vector(39 downto 0) := (others => '0');
    variable q2 : std_logic_vector(39 downto 0) := (others => '0');
  begin  -- process SET_INT_PERIODS
    if reset_n = '0' then               -- asynchronous reset (active low)
      int_period_1 <= (others => '0');
      int_period_2 <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if cs = HOLD then
        q2           := integration_period * integration_ratio;
        q1           := integration_period * (not integration_ratio);
        int_period_1 <= q1(39 downto 8);
        int_period_2 <= q2(39 downto 8);
      end if;
    end if;
  end process SET_INT_PERIODS;

  DO_COUNTERS : process (clk, reset_n)
  begin  -- process DO_COUNTERS
    if reset_n = '0' then               -- asynchronous reset (active low)
      count100 <= (others => '0');
      count_us <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if cs = S_PMD_BUSY or cs = HOLD then
        count100 <= (others => '0');
      else
        if count100 = 99 then
          count100 <= (others => '0');
        else
          count100 <= count100 + 1;
        end if;
      end if;
      if cs = S_PMD_BUSY or cs = CHANGE or cs = HOLD then
        count_us <= (others => '0');
      else						  
	  	if count100 = 50 then
        count_us <= count_us + 1;
		end if;
      end if;
    end if;
  end process DO_COUNTERS;

  SET_CS : process (clk, reset_n)
  begin  -- process SET_CS
    if reset_n = '0' then               -- asynchronous reset (active low)
      cs <= S_PMD_BUSY;
    elsif rising_edge(clk) then         -- rising clock edge
      case cs is
        when S_PMD_BUSY =>
          if pmd_busy = '0' then
            cs <= MOD_PERIOD_1;
          end if;
        when MOD_PERIOD_1 =>
          if count_us = int_period_1 then
            cs <= CHANGE;
          end if;
        when CHANGE => 
			if integration_ratio = 0 then
				cs <= HOLD;
			else
          		cs <= MOD_PERIOD_2;
			end if;
        when MOD_PERIOD_2 =>
          if count_us = int_period_2 then
            cs <= HOLD;
          end if;
        when HOLD =>
          if pmd_busy = '1' then
            cs <= S_PMD_BUSY;
          end if;
        when others => cs <= HOLD;
      end case;
    end if;
  end process SET_CS;

  -- Removes the synchronous control logic from the asynchronous control
  -- of selecting the outputs.
  SET_MOD_SELECT : process (clk, reset_n)
  begin  -- process SET_MOD_SELECT
    if reset_n = '0' then               -- asynchronous reset (active low)
      laser_select_1 <= "00";
      laser_select_2 <= "00";
      camera_select  <= "00";
    elsif rising_edge(clk) then         -- rising clock edge
      if cs = MOD_PERIOD_1 or cs = CHANGE or cs = HOLD then
        camera_select <= "01";
      elsif cs = MOD_PERIOD_2 then
        camera_select <= "11";
      else
        camera_select <= "00";
      end if;
      laser_select_1(0) <= laser_control(1);
      laser_select_2(0) <= laser_control(0);
      if cs = MOD_PERIOD_2 then
        laser_select_1(1) <= '1';
        laser_select_2(1) <= '1';
      else
        laser_select_1(1) <= '0';
        laser_select_2(1) <= '0';
      end if;
    end if;
  end process SET_MOD_SELECT;

  camera_mod_out  <= '1' when camera_select(0) = '0'  else camera_mod_in_1 when camera_select(1) = '0' else camera_mod_in_2;
  laser_mod_out_1 <= '1' when laser_select_1(0) = '0' else laser_mod_in_1 when laser_select_1(1) = '0' else laser_mod_in_2;
  laser_mod_out_2 <= '1' when laser_select_2(0) = '0' else laser_mod_in_1 when laser_select_2(1) = '0' else laser_mod_in_2;
  

  

end rtl;
