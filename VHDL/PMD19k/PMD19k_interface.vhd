-- Interface to PMD 19k sensor.
-- Controls all ADC functions and sensor readout timing  
-- See page 15 of PMD 19k datasheet for timing and state descriptions.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PMD19k_interface is
  
  port (
    clk     : in std_logic;             -- 100 MHz input clock
    reset_n : in std_logic;

    -- Internal interface
    s_reset          : in  std_logic;   -- sync reset
    begin_readout    : in  std_logic;
    pixel_data       : out std_logic_vector(31 downto 0);
    pixel_addr       : out std_logic_vector(14 downto 0);
    pixel_valid      : out std_logic;
    pmd_busy         : out std_logic;  -- PMD resetting, or reading out           
    -- hold_period = time spent in T11 state.   In clock cycles
    -- frame_period = integration_period + hold_period + readout (25750) 
    -- Minimum of 100.
    hold_period      : in  std_logic_vector(31 downto 0);
    readout_complete : out std_logic;
    stall            : in  std_logic;

    -- External interface
    clk_r       : out std_logic;
    clk_c       : out std_logic;
    clear_r     : out std_logic;
    clear_c     : out std_logic;
    start_r     : out std_logic;
    start_c     : out std_logic;
    hold        : out std_logic;
    pmd_reset_n : out std_logic;
    end_r       : in  std_logic;
    end_c       : in  std_logic;
    adc_data    : in  std_logic_vector(7 downto 0);
    adcclk      : out std_logic;
    cdsclk      : out std_logic;
    sdata       : out std_logic;
    sdata_rw    : out std_logic;
    sclk        : out std_logic;
    sload       : out std_logic;
												  
    adc_we   : in std_logic;
    adc_control_data : in std_logic_vector(11 downto 0));

end PMD19k_interface;

architecture rtl of PMD19k_interface is

  -- Most of these state names refer to page 15/16 of PMD 19k datasheet Rev 1.0
  type   state_type is (RESETTING, INTEGRATING, T13, T14, T6, T4, T7, T3, COLUMN, T8, T9, T10, T11, T12, S_STALL);
  signal cs : state_type := RESETTING;
  signal ns : state_type := RESETTING;

  signal clk_count      : std_logic_vector(7 downto 0)  := (others => '0');
  signal hold_count     : std_logic_vector(31 downto 0) := (others => '0');
  signal hold_count_100 : std_logic_vector(6 downto 0)  := (others => '0');
  signal adc_count      : std_logic_vector(7 downto 0)  := (others => '0');
  signal adc_data_int   : std_logic_vector(7 downto 0)  := (others => '0');
  signal adc_sample_H1  : std_logic_vector(16 downto 0) := (others => '0');
  signal adc_H1         : std_logic_vector(7 downto 0)  := (others => '0');
  signal adc_sample_L1  : std_logic_vector(16 downto 0) := (others => '0');
  signal adc_L1         : std_logic_vector(7 downto 0)  := (others => '0');
  signal adc_sample_H2  : std_logic_vector(16 downto 0) := (others => '0');
  signal adc_H2         : std_logic_vector(7 downto 0)  := (others => '0');
  signal adc_sample_L2  : std_logic_vector(32 downto 0) := (others => '0');
  signal adc_L2         : std_logic_vector(7 downto 0)  := (others => '0');
  signal col_count      : std_logic_vector(7 downto 0)  := X"9F";
  signal row_count      : std_logic_vector(6 downto 0)  := (others => '0');

  signal pixel_valid_int1 : std_logic := '0';
  signal pixel_valid_int2 : std_logic := '0';


  signal end_r_int : std_logic := '0';
  signal end_c_int : std_logic := '0';
  
  
begin  -- rtl    


  ADC_SERIAL : entity work.SPI_master
    port map (
      clk      => clk,
      reset_n  => reset_n,
      s_reset  => s_reset,
      addr     => adc_control_data(11 downto 9),
      data     => adc_control_data(8 downto 0),
      we       => adc_we,
      sclk     => sclk,
      sload    => sload,
      sdata    => sdata,
      sdata_rw => sdata_rw);



  DO_ADC_CLK : process(clk, reset_n)
  begin
    if reset_n = '0' then
      adc_count     <= (others => '0');
      adcclk        <= '1';
      cdsclk        <= '0';
      adc_data_int  <= (others => '0');
      adc_sample_H1 <= (others => '0');
      adc_H1        <= (others => '0');

      pixel_data       <= (others => '0');
      pixel_valid_int1 <= '0';
      pixel_valid_int2 <= '0';
      pixel_addr       <= (others => '0');
      row_count        <= (others => '0');
      col_count        <= X"9F";
    elsif rising_edge(clk) then
      
      adc_data_int <= adc_data;

      if cs = COLUMN or cs = T3 or cs = T8 or cs = T9 then
        if adc_count = 15 then
          adc_count <= (others => '0');
        else
          adc_count <= adc_count + 1;
        end if;

        if adc_count = 13 then
          adcclk <= '1';
        elsif adc_count = 9 then
          adcclk <= '0';
        elsif adc_count = 5 then
          adcclk <= '1';
        elsif adc_count = 1 then
          adcclk <= '0';
        end if;
      else
        adc_count <= (others => '0');
        adcclk    <= '1';
      end if;

      if cs = COLUMN or cs = T3 then
        if adc_count = 3 then
          cdsclk <= '1';
        elsif adc_count = 7 then
          cdsclk <= '0';
        end if;
      else
        cdsclk <= '0';
      end if;
      adc_sample_H1 <= adc_sample_H1(15 downto 0) & '0';
      adc_sample_L1 <= adc_sample_L1(15 downto 0) & '0';
      adc_sample_H2 <= adc_sample_H2(15 downto 0) & '0';
      adc_sample_L2 <= adc_sample_L2(31 downto 0) & '0';
      if cs = COLUMN or cs = T8 or cs = T9 then
--        if adc_count = 15 then
--          adc_sample_L2 <= adc_sample_L2(16 downto 0) & '1';
--        elsif adc_count = 11 then
--          adc_sample_H2 <= adc_sample_H2(15 downto 0) & '1';
--        elsif adc_count = 7 then
--          adc_sample_L1 <= adc_sample_L1(15 downto 0) & '1';
--        elsif adc_count = 3 then
--          adc_sample_H1 <= adc_sample_H1(15 downto 0) & '1';
--        end if;
--
--        if adc_sample_H1(13) = '1' then
--          adc_H1 <= adc_data_int;
--        end if;
--        if adc_sample_L1(13) = '1' then
--          adc_L1 <= adc_data_int;
--        end if;
--        if adc_sample_H2(13) = '1' then
--          adc_H2 <= adc_data_int;
--        end if;
--        if adc_sample_L2(14) = '1' then
--          adc_L2 <= adc_data_int;
--        end if;         
        if adc_count = 8 then
          adc_H1 <= adc_data_int;
        elsif adc_count = 12 then
          adc_L1 <= adc_data_int;
        elsif adc_count = 0 then
          adc_H2 <= adc_data_int;
        elsif adc_count = 4 then
          adc_L2        <= adc_data_int;
          adc_sample_L2 <= adc_sample_L2(31 downto 0) & '1';
        end if;


        if adc_sample_L2(32) = '1' then
          pixel_valid_int1 <= '1';
          pixel_data       <= adc_H1 & adc_L1 & adc_H2 & adc_L2;
          col_count        <= col_count - 1;
          pixel_addr       <= row_count & col_count;
        else
          pixel_valid_int1 <= '0';
        end if;


        if ns = T7 then
          row_count <= row_count + 1;
          col_count <= X"9F";
        end if;
      elsif cs = INTEGRATING or cs = RESETTING or cs = S_STALL then
        row_count <= (others => '0');
        col_count <= X"9F";
      end if;
      pixel_valid_int2 <= pixel_valid_int1;
    end if;
  end process DO_ADC_CLK;

  pixel_valid <= pixel_valid_int1 or pixel_valid_int2;

  DO_CLK_DIV : process (clk, reset_n)
  begin  -- process DO_CLK_DIV
    if reset_n = '0' then               -- asynchronous reset (active low)
      clk_count      <= (others => '0');
      hold_count     <= (others => '0');
      hold_count_100 <= (others => '0');
      end_r_int      <= '0';
      end_c_int      <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      end_r_int <= end_r;
      end_c_int <= end_c;

      if cs = COLUMN then
        if clk_count = 15 or ns = T8 or ns = T9 then
          clk_count <= (others => '0');
        else
          clk_count <= clk_count + 1;
        end if;
        
      elsif cs = INTEGRATING then
        clk_count <= (others => '0');
        
      elsif cs = T4 or cs = T8 then
        if ns = T7 then
          clk_count <= (others => '0');
        else
          clk_count <= clk_count + 1;
        end if;

      elsif cs = T3 then
        if ns = COLUMN then
          clk_count <= (others => '0');
        else
          clk_count <= clk_count + 1;
        end if;
        
      else
        clk_count <= clk_count + 1;
      end if;

      if cs = T10 or cs = T11 or cs = T12 then
        hold_count_100 <= hold_count_100 + 1;
        if hold_count_100 = 99 then
          hold_count     <= hold_count + 1;
          hold_count_100 <= (others => '0');
        end if;
      else
        hold_count_100 <= (others => '0');
        hold_count     <= (others => '0');
      end if;
      
    end if;
  end process DO_CLK_DIV;

  SET_CS : process (clk, reset_n)
  begin  -- process SET_CS
    if reset_n = '0' then               -- asynchronous reset (active low)
      cs <= RESETTING;
    elsif rising_edge(clk) then         -- rising clock edge      
      if s_reset = '1' then
        cs <= RESETTING;
      else
        cs <= ns;
      end if;
    end if;
  end process SET_CS;

  SET_NS : process (cs, begin_readout, end_c_int, end_r_int, clk_count, row_count, col_count,
  hold_count_100, hold_count, hold_period, stall)
  begin
    ns <= cs;
    case cs is
      when RESETTING =>
        if clk_count = 200 then
          ns <= INTEGRATING;
        end if;
        
      when INTEGRATING =>
        if begin_readout = '1' then
          ns <= T13;
        end if;
      when T13 =>
        if clk_count = 20 then
          ns <= T14;
        end if;
      when T14 =>
        if clk_count = 160 then
          ns <= T6;
        end if;
      when T6 =>
        if clk_count = 173 then
          ns <= T4;
        end if;
      when T4 =>
        if clk_count = 186 then
          ns <= T7;
        end if;
      when T7 =>
        if clk_count = 30 then
          ns <= T3;
        end if;
      when T3 =>
        if clk_count = 43 then
          ns <= COLUMN;
        end if;
      when COLUMN =>
        if (end_c_int = '1' or col_count = 0) and clk_count = 5 then
          if (end_r_int = '1' or row_count = 119) then
            ns <= T9;
          else
            ns <= T8;
          end if;
        end if;
      when T8 =>
        if clk_count = 35 then
          ns <= T7;
        end if;
      when T9 =>
        if clk_count = 35 then
          ns <= S_STALL;
        end if;
      when S_STALL =>
        if stall = '0' then
          ns <= T10;
        end if;
      when T10 =>
        if hold_count = hold_period then
          ns <= T11;
        end if;
      when T11 =>
        if hold_count = (hold_period + 1) then
          ns <= T12;
        end if;
      when T12 =>
        if hold_count = (hold_period + 2) and hold_count_100 = 41 then
          ns <= INTEGRATING;
        end if;
      when others =>
        ns <= INTEGRATING;
    end case;
  end process SET_NS;

  SET_PMD_OUTPUTS : process (clk, reset_n)
  begin  -- process SET_PMD_OUTPUTS
    if reset_n = '0' then               -- asynchronous reset (active low)
      clear_r     <= '1';
      clear_c     <= '1';
      start_r     <= '0';
      start_c     <= '0';
      clk_r       <= '0';
      clk_c       <= '0';
      hold        <= '0';
      pmd_reset_n <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      clear_r     <= '0';
      clear_c     <= '0';
      start_r     <= '0';
      start_c     <= '0';
      clk_r       <= '0';
      --clk_c       <= '0';
      hold        <= '1';
      pmd_reset_n <= '0';
      if cs = RESETTING or cs = S_STALL then
        hold        <= '1';
        pmd_reset_n <= '0';
        clear_c     <= '1';
        clear_r     <= '1';
      elsif cs = INTEGRATING or cs = T13 or cs = T12 then
        hold        <= '0';
        pmd_reset_n <= '1';
      elsif cs = T14 then
        pmd_reset_n <= '1';
      elsif cs = T6 then
        start_r <= '1';
      elsif cs = T4 then
        clk_r   <= '1';
        start_r <= '1';
      elsif cs = T3 then
        start_c <= '1';
        if clk_count = 37 then
          clk_c <= '1';
        end if;
      elsif cs = COLUMN then
        if clk_count = 0 then
          clk_c <= '0';
        elsif clk_count = 8 then
          clk_c <= '1';
        end if;
      elsif cs = T8 then
        clear_c <= '1';
        clk_c   <= '0';
        clk_r   <= '1';
      elsif cs = T9 then
        clear_c <= '1';
        clear_r <= '1';
        clk_c   <= '0';
      elsif cs = T11 then
        hold <= '0';
      end if;
    end if;
  end process SET_PMD_OUTPUTS;

  SET_OTHER_OUTPUTS : process(clk, reset_n)
  begin
    if reset_n = '0' then
      pmd_busy         <= '1';
      readout_complete <= '0';
    elsif rising_edge(clk) then
      if cs = INTEGRATING then
        pmd_busy <= '0';
      else
        pmd_busy <= '1';
      end if;
      if cs = T9 and ns = S_STALL then
        readout_complete <= '1';
      else
        readout_complete <= '0';
      end if;
    end if;
  end process SET_OTHER_OUTPUTS;

end rtl;
