-- SPI Master controller
-- Specifically used for ADC serial communications.
-- Only SPI Writes currently available.
-- Data packet is '1' & A(2:0) & "00" & D(8:0) sent MSB first.
-- SCLK is 1/16th of input clk.
-- Immediately transmits 2 frames (Config and MuxConfig) after reset

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SPI_master is
  
  port (
    clk      : in  std_logic;
    reset_n  : in  std_logic;
    s_reset  : in  std_logic;
    sclk     : out std_logic;
    sload    : out std_logic;
    sdata    : out std_logic;
    sdata_rw : out std_logic;
    addr     : in  std_logic_vector(2 downto 0);
    data     : in  std_logic_vector(8 downto 0);
    we       : in  std_logic);

end SPI_master;

architecture rtl of SPI_master is

  signal sreg        : std_logic_vector(15 downto 0) := (others => '0');
  type   STATE_TYPE is (INIT, FRAME1, DELAY1, FRAME2, DELAY2, DONE);
  signal cs          : STATE_TYPE                    := INIT;
  signal ns          : STATE_TYPE                    := INIT;
  signal sclk_count  : std_logic_vector(7 downto 0)  := (others => '0');
  signal bit_count   : std_logic_vector(7 downto 0)  := (others => '0');
  signal s_reset_int : std_logic                     := '0';


  -- bit rate = input clk / 2 / (DIVIDER+1).
  -- HIGHTIME = input clk periods sclk is high for
  constant DIVIDER  : std_logic_vector(7 downto 0) := X"27";
  constant HIGHTIME : std_logic_vector(7 downto 0) := X"13";
  
begin  -- rtl

  DO_SCLK : process (clk, reset_n)
  begin  -- process DO_SCLK
    if reset_n = '0' then               -- asynchronous reset (active low)
      sclk        <= '1';
      sclk_count  <= (others => '0');
      s_reset_int <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      s_reset_int <= s_reset;
      if cs = DONE or cs = INIT or cs = DELAY2 then
        sclk_count <= (others => '0');
        sclk       <= '1';
      else
        
        if sclk_count = HIGHTIME then
          sclk       <= '0';
          sclk_count <= sclk_count + 1;
        elsif sclk_count = DIVIDER then
          sclk       <= '1';
          sclk_count <= (others => '0');
        else
          sclk_count <= sclk_count + 1;
        end if;
      end if;
    end if;
  end process DO_SCLK;

  SET_CS : process (clk, reset_n)
  begin  -- process SET_CS
    if reset_n = '0' then               -- asynchronous reset (active low)
      cs <= INIT;
    elsif rising_edge(clk) then         -- rising clock edge
      if s_reset_int = '1' then
        cs <= INIT;
      else
        cs <= ns;
      end if;
    end if;
  end process SET_CS;

  SET_NS : process (cs, sclk_count, bit_count, we)
  begin  -- process SET_NS
    ns <= cs;
    case cs is
      when INIT =>
        ns <= FRAME1;
      when FRAME1 =>
        if sclk_count = (HIGHTIME-1) and bit_count = X"0F" then
          ns <= DELAY1;
        end if;
      when DELAY1 =>
        if sclk_count = HIGHTIME and bit_count = X"1F" then
          ns <= FRAME2;
        end if;
      when FRAME2 =>
        if sclk_count = (HIGHTIME-1) and bit_count = X"2F" then
          ns <= DELAY2;
        end if;
      when DELAY2 =>
        --if sclk_count = HIGHTIME and bit_count = X"30" then
          ns <= DONE;
        --end if;
      when DONE   =>
        if we = '1' then
          ns <= FRAME2;
        end if;
        -- do nothing. Stay here.
      when others =>
        ns <= INIT;
    end case;
  end process SET_NS;

  SET_OUTPUTS : process (clk, reset_n)
  begin  -- process SET_OUTPUTS
    if reset_n = '0' then               -- asynchronous reset (active low)
      bit_count <= (others => '0');
      sreg      <= (others => '0');
      sload     <= '1';
      sdata     <= '1';
      sdata_rw  <= '1';
    elsif rising_edge(clk) then         -- rising clock edge
      sdata_rw <= '0';

      if cs = FRAME1 or cs = FRAME2 or cs = DELAY1 or cs = DELAY2 then
        if sclk_count = HIGHTIME then
          bit_count <= bit_count + 1;
        end if;	  
	  elsif cs = DONE then
	  	bit_count <= X"20";
      else
        bit_count <= (others => '0');
      end if;

      if cs = FRAME1 or cs = FRAME2 then
        if sclk_count = HIGHTIME then
          sload <= '0';
          sdata <= sreg(15);
        end if;
      else
        sdata <= '1';
        sload <= '1';
      end if;

      if cs = FRAME1 or cs = FRAME2 then
        if sclk_count = (HIGHTIME-1) then
          sreg <= sreg(14 downto 0) & '1';
        end if;
      elsif cs = INIT then
        sreg <= '0' & '0' & "000" & "00" & "011001000";
      elsif cs = DELAY1 then
        sreg <= '0' & '0' & "001" & "00" & "010110000";
      elsif cs = DONE and we = '1' then
        sreg <= '0' & '0' & addr & "00" & data;
      end if;
    end if;
  end process SET_OUTPUTS;
  

end rtl;
