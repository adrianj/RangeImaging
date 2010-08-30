-- Model of the PMD 19k sensor.
-- Drives end_r and end_c based on on the clks and clears.
-- Drives adc_data based on adcclk and cdsclk.
-- Reads from a file for adc_data, each rising_edge of cdsclk
-- reads a new line from the .hex file.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use std.textio.all;
use work.testbench_functions.all;

entity PMD19k_model is
  generic (
    inFileName : string := "");
  port (
    reset_n  : in  std_logic;
    clk_c    : in  std_logic;
    clk_r    : in  std_logic;
    clear_r  : in  std_logic;
    clear_c  : in  std_logic;
    end_c    : out std_logic;
    end_r    : out std_logic;
    adcclk   : in  std_logic;
    cdsclk   : in  std_logic;
    adc_data : out std_logic_vector(7 downto 0));

end PMD19k_model;

architecture model of PMD19k_model is



  signal col_count       : std_logic_vector(7 downto 0)  := (others => '0');
  signal pixel_count_a   : std_logic_vector(15 downto 0)  := (others => '0');
  signal phase_in        : std_logic_vector(15 downto 0) := (others => '0');
  signal row_count       : std_logic_vector(7 downto 0)  := (others => '0');
  signal offset          : std_logic_vector(15 downto 0) := (others => '0');
  signal offset_interval : std_logic_vector(15 downto 0) := X"3800";
  signal col_max         : std_logic_vector(7 downto 0)  := X"A0";
  signal row_max         : std_logic_vector(7 downto 0)  := X"78";

  signal adc_data_int    : std_logic_vector(79 downto 0) := (others => '0');
  signal adc_channel_sel : std_logic                     := '0';
  signal clear_r_a       : std_logic                     := '0';
  signal clear_r_a2      : std_logic                     := '0';  
  signal clear_c_a		 : std_logic := '0';
  signal cordic_sin      : std_logic_vector(15 downto 0) := (others => '0');
  
begin  -- model

  DO_ROW_COUNT : process (clk_r, clear_r)
  begin  -- process DO_ROW_COUNT
    if clear_r = '1' then
      end_r     <= '0';
      row_count <= (others => '0');
    elsif rising_edge(clk_r) then
      if row_count = row_max - 1 then
        row_count <= row_max;
        end_r     <= '1';
      else
        end_r     <= '0';
        row_count <= row_count + 1;
      end if;
    end if;
  end process DO_ROW_COUNT;

  DO_COL_COUNT : process (clk_c, clear_c)
  begin  -- process DO_ROW_COUNT
    if clear_c = '1' then
      end_c     <= '0';
      col_count <= (others => '0');
    elsif rising_edge(clk_c) then
      
      if col_count = col_max - 1 then
        col_count <= col_max;
        end_c     <= '1';
      else
        end_c     <= '0';
        col_count <= col_count + 1;
      end if;
    end if;
  end process DO_COL_COUNT;


  GEN_NOT_SYNTH : if inFileName /= "" generate
    DO_ADC : process(adcclk, cdsclk)
      file inFile     : text is in inFileName;
      variable temp16 : std_logic_vector(15 downto 0) := (others => '0');
    begin
      if rising_edge(cdsclk) then
        temp16                    := file2slv16(inFile);
        adc_data_int(31 downto 0) <= temp16 & X"0012";
      end if;
      if rising_edge(adcclk) then
        adc_data_int <= adc_data_int(71 downto 0) & X"00";
        adc_data     <= adc_data_int(79 downto 72);
      elsif falling_edge(adcclk) then
        adc_data_int <= adc_data_int(71 downto 0) & X"00";
        adc_data     <= adc_data_int(79 downto 72);
      end if;
    end process DO_ADC;
  end generate GEN_NOT_SYNTH;

  GEN_SYNTH : if inFileName = "" generate
    
    DO_ADC : process (adcclk, reset_n)
    begin  -- process DO_ADC
      if reset_n = '0' then             -- asynchronous reset (active low)
        pixel_count_a   <= (others => '0');
        offset          <= (others => '0');
        adc_data_int    <= (others => '0');
        --adc_data        <= (others => '0');
        adc_channel_sel <= '0';
        clear_r_a       <= '0';
        clear_r_a2      <= '0';		
		clear_c_a <= '0';
      elsif rising_edge(adcclk) then    -- rising clock edge
        pixel_count_a <= row_count(5 downto 0) & col_count & "00";
        clear_r_a     <= clear_r;
        clear_r_a2    <= clear_r_a;	
		clear_c_a <= clear_c;
        if clear_r_a = '1' and clear_r_a2 = '0' then
          offset <= offset + offset_interval;
        end if;
        phase_in <= pixel_count_a + offset;
		if clear_c_a = '1' then
			adc_channel_sel <= '0';
		else
        	adc_channel_sel <= not adc_channel_sel;
		end if;
        if adc_channel_sel = '1' then
          adc_data_int <= X"0000000000000000" & cordic_sin;	
		  --adc_data <= (others => '0');
        else
          --adc_data <= adc_data_int(15 downto 8);
        end if;
        
        
      end if;
    end process DO_ADC;
    
    adc_data <= cordic_sin(15 downto 8) when adc_channel_sel = '0' and adcclk = '1' else
    cordic_sin(7 downto 0) when adc_channel_sel = '0' and adcclk = '0' else
    (others => '0');

    THE_CORDIC : entity work.cordic_cosine	
	  generic map (
      	I => 12)
      port map (
        clk         => adcclk,
        reset_n     => reset_n,
        phase_in    => phase_in,
        sin_out     => cordic_sin,
        cos_out     => open,
        nd          => '0',
        rdy         => open,
        storage_in  => X"0000",
        storage_out => open);

  end generate GEN_SYNTH;

end model;
