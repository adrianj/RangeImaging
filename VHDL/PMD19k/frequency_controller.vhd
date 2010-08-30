-- Frequency Controller for Stratix III PLLs
-- Inputs are all the values relating post-scale counters C0-C1.
-- All other PLL outputs (C2 - C9) are bypassed.
-- A high pulse of begin_reconfig initiates the reconfiguration.
-- Reconfig completes with a pll reset and the pll lock should be regained.
-- The frequency controller has an output signifying that reconfig is in
-- progress, during which other things (eg phase control) should wait.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity frequency_controller is
  generic (
    IS_CYCLONE3 : std_logic := '0');
  port (
    clk                  : in  std_logic;
    reset_n              : in  std_logic;
    begin_reconfig       : in  std_logic;
    pll_locked           : in  std_logic;
    reconfig_in_progress : out std_logic;
    scan_clk_enable      : out std_logic;
    scan_data            : out std_logic;
    scan_data_out        : in  std_logic;
    config_update        : out std_logic;
    pll_reset            : out std_logic;
    scan_done            : in  std_logic;
    c0_hi_count          : in  std_logic_vector(7 downto 0);
    c0_low_count         : in  std_logic_vector(7 downto 0);
    c1_hi_count          : in  std_logic_vector(7 downto 0);
    c1_low_count         : in  std_logic_vector(7 downto 0);
    m_hi_count           : in  std_logic_vector(7 downto 0);
    m_low_count          : in  std_logic_vector(7 downto 0);
    r_sel_odd            : in  std_logic_vector(1 downto 0)
    );    

end frequency_controller;

architecture rtl of frequency_controller is

  type STATE_TYPE is (IDLE, INITIALISE, SHIFTING, UPDATE, DELAY1,
                      RESET_PLL, DELAY2, WAIT_FOR_LOCK, DONE);
  signal state : STATE_TYPE                   := IDLE;
  signal count : std_logic_vector(7 downto 0) := (others => '0');

  -- constant values = CPC = 001, LFC = 00, LFR = 11011, K = 1.
  constant PLL_CONST  : std_logic_vector(17 downto 0)  := "000011011100000001";
  -- scan chain, for left/right pll.
  signal   scan_chain : std_logic_vector(179 downto 0) := (others => '0');
  -- variable scan chains, based on inputs.
  signal   m_chain    : std_logic_vector(17 downto 0)  := (others => '0');
  signal   n_chain    : std_logic_vector(17 downto 0)  := (others => '0');
  signal   c0_chain   : std_logic_vector(17 downto 0)  := (others => '0');
  signal   c1_chain   : std_logic_vector(17 downto 0)  := (others => '0');
  -- constant scan chain for bypassed counters N and C2-26.
  constant BYPASS     : std_logic_vector(17 downto 0)  := "100000000000000000";

  --signal n_low_count : std_logic_vector(7 downto 0) := X"00";
  --signal n_hi_count : std_logic_vector(7 downto 0) := X"00";
  signal SCAN_CHAIN_COUNT : std_logic_vector(7 downto 0) := X"B3"; 
  signal SCAN_CHAIN_ACTUAL : std_logic_vector(179 downto 0) := (others => '0');
  

begin  -- rtl

  SET_SCAN_C3 : if IS_CYCLONE3 = '1' generate
    SCAN_CHAIN_COUNT <= X"8F";	
	SCAN_CHAIN_ACTUAL <= BYPASS & BYPASS & "00"&X"0000" & n_chain & m_chain & c0_chain & c1_chain
                        & BYPASS & BYPASS & BYPASS;
  end generate SET_SCAN_C3;
  SET_SCAN_S3 : if IS_CYCLONE3 = '0' generate
    SCAN_CHAIN_COUNT <= X"B3";	 
	SCAN_CHAIN_ACTUAL <= PLL_CONST & m_chain & n_chain & c0_chain & c1_chain
                        & BYPASS & BYPASS & BYPASS & BYPASS & BYPASS;
  end generate SET_SCAN_S3;

  m_chain  <= '0' & m_hi_count & '0' & m_low_count;
  -- m value shouldn't really need to be changed.
  --m_chain  <= '0' & X"0C" & '0' & X"0C";
  -- n is bypassed.
  --n_chain  <= "10" & X"0000";   
  -- or is it???   
  n_chain  <= '0' & X"03" & '1' & X"02";
  c0_chain <= '0' & c0_hi_count & r_sel_odd(0) & c0_low_count;
  c1_chain <= '0' & c1_hi_count & r_sel_odd(1) & c1_low_count;

  SET_STATE : process (clk, reset_n)
  begin  -- process SET_STATE
    if reset_n = '0' then               -- asynchronous reset (active low)
      state                <= IDLE;
      count                <= (others => '0');
      scan_chain           <= (others => '0');
      reconfig_in_progress <= '0';
      scan_clk_enable      <= '0';
      config_update        <= '0';
      scan_data            <= '0';
      pll_reset            <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      case state is
        when IDLE =>
          if begin_reconfig = '1' then
            state <= INITIALISE;
          end if;
          count                <= (others => '0');
          reconfig_in_progress <= '0';
        when INITIALISE =>
          scan_clk_enable      <= '1';
          reconfig_in_progress <= '1';
          state                <= SHIFTING;
          count                <= (others => '0');
          scan_chain           <= SCAN_CHAIN_ACTUAL;
        when SHIFTING =>
          if count = SCAN_CHAIN_COUNT then
            state <= UPDATE;
          end if;
          count           <= count + 1;
          scan_chain      <= '0' & scan_chain(179 downto 1);
          scan_data       <= scan_chain(0);
          scan_clk_enable <= '1';
          
        when UPDATE =>
          state           <= DELAY1;
          count           <= (others => '0');
          scan_clk_enable <= '0';
          config_update   <= '1';
        when DELAY1 =>
          if count = 10 then
            state <= RESET_PLL;
          end if;
          count         <= count + 1;
          config_update <= '0';
        when RESET_PLL =>
          state     <= DELAY2;
          count     <= (others => '0');
          pll_reset <= '1';
        when DELAY2 =>
          if count = 10 then
            state <= WAIT_FOR_LOCK;
          end if;
          count     <= count + 1;
          pll_reset <= '0';
        when WAIT_FOR_LOCK =>
          if begin_reconfig = '1' then
            state <= INITIALISE;
          elsif pll_locked = '1' then
            state <= DONE;
            
          end if;
          count <= count + 1;
        when DONE =>
          state <= IDLE;
          count <= (others => '0');
          
        when others =>
          state <= IDLE;
      end case;
    end if;
  end process SET_STATE;

end rtl;
