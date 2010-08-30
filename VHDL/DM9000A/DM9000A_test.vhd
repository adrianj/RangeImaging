-- Top level entity for testing DM9000A design
-- Design just sends out occasional packets to default addresses/ports.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DM9000A_test is
  
  port (
    clk125  : in std_logic;
    reset_n : in std_logic;

    leds     : out std_logic_vector(7 downto 0);
    switches : in  std_logic_vector(7 downto 0) := (others => '0');
    buttons  : in  std_logic_vector(3 downto 0) := (others => '0');

-- Connections to DM9000A IC
    ENET_RD_N : out   std_logic;
    ENET_WR_N : out   std_logic;
    ENET_CS_N : out   std_logic;
    ENET_CMD  : out   std_logic;
    ENET_INT  : in    std_logic := '0';
    ENET_CLK  : out   std_logic;
    ENET_DATA : inout std_logic_vector(15 downto 0)
    );

end DM9000A_test;

architecture rtl of DM9000A_test is

  signal clk100 : std_logic := '0';

  signal sfr_din  : std_logic_vector(15 downto 0) := (others => '0');
  signal sfr_addr : std_logic_vector(3 downto 0)  := (others => '0');
  signal sfr_we   : std_logic                     := '0';
  signal sfr_dout : std_logic_vector(15 downto 0) := (others => '0');

  signal tx_fifo_din  : std_logic_vector(15 downto 0) := (others => '0');
  signal tx_fifo_we   : std_logic                     := '0';
  signal tx_fifo_full : std_logic                     := '0';
  signal fifo_count   : std_logic_vector(3 downto 0)  := (others => '0');

  signal dm_ready : std_logic := '0';

  signal debug : std_logic_vector(15 downto 0) := (others => '0');

  signal long_counter : std_logic_vector(31 downto 0) := (others => '0');
  
begin  -- rtl

  CLK100_PLL : entity work.pllx4d5
    port map (
      inclk0 => clk125,
      c0     => clk100);

  DM_CON : entity work.DM9000A_Ethernet
    port map (
      clk          => clk100,
      reset_n      => reset_n,
      sfr_addr     => sfr_addr,
      sfr_din      => sfr_din,
      sfr_dout     => sfr_dout,
      sfr_we       => sfr_we,
      tx_fifo_we   => tx_fifo_we,
      tx_fifo_din  => tx_fifo_din,
      tx_fifo_full => tx_fifo_full,
      DM_IOR_n     => ENET_RD_N,
      DM_IOW_n     => ENET_WR_N,
      DM_CS_n      => ENET_CS_N,
      DM_CMD       => ENET_CMD,
      DM_INT       => ENET_INT,
      DM_CLK       => ENET_CLK,
      DM_SD        => ENET_DATA,
      debug        => debug);

  LEDs <= debug(7 downto 0);

  DO_TEST : process (clk100, reset_n)
  begin  -- process DO_TEST
    if reset_n = '0' then               -- asynchronous reset (active low)
      dm_ready    <= '0';
      tx_fifo_we  <= '0';
      tx_fifo_din <= (others => '0');
      fifo_count  <= (others => '0');
    elsif rising_edge(clk100) then      -- rising clock edge      
      fifo_count <= fifo_count + 1;
      if dm_ready = '0' then
        if sfr_addr = X"00" then
          dm_ready <= sfr_dout(2);
        end if;
      else
        if tx_fifo_we = '0' and tx_fifo_full = '0' and fifo_count(1 downto 0) = "00" then
          tx_fifo_we  <= '1';
          tx_fifo_din <= tx_fifo_din + 1;
        elsif tx_fifo_we = '1' then
          tx_fifo_we <= '0';
        end if;
      end if;
    end if;
  end process DO_TEST;

  TEST_SFRS : process(clk100, reset_n)
  begin
    if reset_n = '0' then
      sfr_din      <= (others => '0');
      sfr_addr     <= (others => '0');
      sfr_we       <= '0';
      long_counter <= (others => '0');
    elsif rising_edge(clk100) then
      -- This is basically a wait statement
      if long_counter /= X"FFFFFFFF" then
        long_counter <= long_counter + 1;
      end if;

      sfr_addr <= (others => '0');
      sfr_we   <= '0';
      sfr_din  <= (others => '0');
      -- Issue a pause command after 2000 clks
      if long_counter = X"000007D0" then
        sfr_din  <= sfr_dout or X"0010";
        sfr_we   <= '1';
        sfr_addr <= X"0";
      end if;

      -- Change packet data length to 643 words.
      if long_counter = X"000009F0" then
        sfr_din  <= X"0506";
        sfr_we   <= '1';
        sfr_addr <= X"1";
      end if;

      -- Reset DM9000A
      if long_counter = X"000009F4" then
        sfr_din  <= sfr_dout or X"0001";
        sfr_we   <= '1';
        sfr_addr <= X"0";
      end if;

      -- Unpause
      if long_counter = X"000009F8" then
        sfr_din  <= sfr_dout and (not X"0010");
        sfr_we   <= '1';
        sfr_addr <= X"0";
      end if;
      
    end if;
  end process TEST_SFRS;

end rtl;
