-- Drives a 640 x 480 pixel display.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity vga_module is
  generic (
    -- Set the (clk_div+1) in order to give a 25 MHz clk pulse
    -- Eg, If input clk = 100 MHz, clk_div = X"3"
    clk_div : std_logic_vector(3 downto 0) := X"3"
    );
  port(
    clk     : in std_logic;
    reset_n : in std_logic;

    -- to VGA chip
    red_out   : out std_logic_vector(9 downto 0);
    green_out : out std_logic_vector(9 downto 0);
    blue_out  : out std_logic_vector(9 downto 0);
    hs_out    : out std_logic;
    vs_out    : out std_logic;
    blank     : out std_logic;
    sync      : out std_logic;
    clk25     : out std_logic;

    -- to internal hardware
    row_address    : out std_logic_vector(8 downto 0);
    column_address : out std_logic_vector(9 downto 0);
    ram_dout       : in  std_logic_vector(15 downto 0));
end vga_module;

architecture Behavioral of vga_module is

  signal clk_cnt  : std_logic_vector(3 downto 0) := (others => '0');
  signal h_count0 : std_logic_vector (11 downto 0);
  signal v_count0 : std_logic_vector (11 downto 0);
  signal h_count1 : std_logic_vector (11 downto 0);
  signal v_count1 : std_logic_vector (11 downto 0);
  signal h_count2 : std_logic_vector (11 downto 0);
  signal v_count2 : std_logic_vector (11 downto 0);

  signal col_address_i : std_logic_vector(11 downto 0) := (others => '0');
  signal row_address_i : std_logic_vector(11 downto 0) := (others => '0');

  -- Horizontal timing for 640 x 480 @ 60 Hz (25 MHz pixel clock)
  -- h_sync_width = 3.8 us (95 clks)
  -- h_back_porch = 1.8 us (47 clks) 
  -- h_display = 25.6 us (640 clks)
  -- h_front_porch = 0.6 us (15 clks)
  signal H_SYNC_WIDTH  : std_logic_vector(11 downto 0) := X"05F";
  signal H_BACK_PORCH  : std_logic_vector(11 downto 0) := X"02F";
  signal H_DISPLAY     : std_logic_vector(11 downto 0) := X"280";
  signal H_FRONT_PORCH : std_logic_vector(11 downto 0) := X"00F";

  -- Vertical timing for 640 x 480 @ 60 Hz (25 MHz pixel clock)
  -- v_sync_width = 2 lines
  -- v_back_porch = 33 lines 
  -- v_display = 480 lines
  -- v_front_porch = 10 lines
  signal V_SYNC_WIDTH  : std_logic_vector(11 downto 0) := X"002";
  signal V_BACK_PORCH  : std_logic_vector(11 downto 0) := X"021";
  signal V_DISPLAY     : std_logic_vector(11 downto 0) := X"1E0";
  signal V_FRONT_PORCH : std_logic_vector(11 downto 0) := X"00A";

  constant MAX_LINES   : std_logic_vector(11 downto 0) := X"20D";  -- 52
  constant MAX_COLUMNS : std_logic_vector(11 downto 0) := X"31D";  -- 797

  -- Output 25 MHz clk - approx 50% duty cycle.
  signal clk25_int : std_logic := '0';
  -- internal 25 MHz pulse.
  signal clk25_p0  : std_logic := '0';
  signal clk25_p1  : std_logic := '0';
  signal clk25_p2  : std_logic := '0';

begin


  -- clock divider process - produces 25 MHz clock based on input clk.
  -- Also produces multiple clk25 pulses at different offsets.
  process(clk, reset_n)
  begin
    if reset_n = '0' then
      clk_cnt   <= (others => '0');
      clk25_int <= '0';
      clk25_p0  <= '0';
      clk25_p1  <= '0';
      clk25_p2  <= '0';
    elsif rising_edge(clk) then
      clk25_p0 <= '0';
      clk25_p1 <= clk25_p0;
      clk25_p2 <= clk25_p1;
      if clk_cnt = clk_div then
        clk_cnt  <= (others => '0');
        clk25_p0 <= '1';
      else
        clk_cnt <= clk_cnt + 1;
      end if;
      -- This part attempts to make a 50% duty cycle clk output.
      if clk_cnt = ('0' & clk_div(2 downto 1)) or clk_cnt = clk_div then
        clk25_int <= not clk25_int;
      end if;
      
    end if;
  end process;

  clk25 <= not clk25_int;


-- Colour LUT process - MATLAB default colours
  -- Alternative is to use blockRAM.
  -- Significant point is that it takes one clock cycle to get through, so if
  -- you are using blockRAM, make sure it also has only one clock cycle
  -- latency. 
  process(clk, reset_n)
  begin
    if reset_n = '0' then
      red_out   <= (others => '1');
      green_out <= (others => '1');
      blue_out  <= (others => '1');
    elsif rising_edge(clk) then
      if ram_dout = X"0000" then
        blue_out  <= (9 => '0', others => '1');
        green_out <= (9 => '0', others => '1');
        red_out   <= (9 => '0', others => '1');
      elsif ram_dout = X"FFFF" then
        blue_out  <= (others => '1');
        green_out <= (others => '1');
        red_out   <= (others => '1');
      elsif ram_dout(15 downto 13) = "000" then
        blue_out  <= '1' & ram_dout(12 downto 4);
        green_out <= (others => '0');
        red_out   <= (others => '0');
      elsif ram_dout(15 downto 13) = "001" then
        blue_out  <= (others => '1');
        green_out <= '0' & ram_dout(12 downto 4);
        red_out   <= (others => '0');
      elsif ram_dout(15 downto 13) = "010" then
        blue_out  <= (others => '1');
        green_out <= '1' & ram_dout(12 downto 4);
        red_out   <= (others => '0');
      elsif ram_dout(15 downto 13) = "011" then
        blue_out  <= '1' & (not ram_dout(12 downto 4));
        green_out <= (others => '1');
        red_out   <= '0' & ram_dout(12 downto 4);
      elsif ram_dout(15 downto 13) = "100" then
        blue_out  <= '0' & (not ram_dout(12 downto 4));
        green_out <= (others => '1');
        red_out   <= '1' & ram_dout(12 downto 4);
      elsif ram_dout(15 downto 13) = "101" then
        blue_out  <= (others => '0');
        green_out <= '1' & (not ram_dout(12 downto 4));
        red_out   <= (others => '1');
      elsif ram_dout(15 downto 13) = "110" then
        blue_out  <= (others => '0');
        green_out <= '0' & (not ram_dout(12 downto 4));
        red_out   <= (others => '1');
      else
        blue_out  <= (others => '0');
        green_out <= (others => '0');
        red_out   <= '1' & (not ram_dout(12 downto 4));
      end if;
    end if;
  end process;


  sync           <= '1';                --bg_colour(0);
  row_address    <= row_address_i(8 downto 0);
  column_address <= col_address_i(9 downto 0);

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      vs_out        <= '0';
      hs_out        <= '0';
      h_count0      <= (others => '0');
      v_count0      <= (others => '0');
      h_count1      <= (others => '0');
      v_count1      <= (others => '0');
      h_count2      <= (others => '0');
      v_count2      <= (others => '0');
      row_address_i <= (others => '0');
      col_address_i <= (others => '0');
    elsif rising_edge(clk) then
      -- First pulse updates counters and sets row/column addresses
      if clk25_p0 = '1' then
        h_count0 <= h_count0 + 1;
        if (h_count0 = MAX_COLUMNS) then
          v_count0 <= v_count0 + 1;
          h_count0 <= (others => '0');
          if (v_count0 = MAX_LINES) then
            v_count0 <= (others => '0');
          end if;
        end if;
      end if;

      --  Second cycle after pulse - establish row/column addresses based on
      --  counters.
      row_address_i <= v_count0 - V_SYNC_WIDTH - V_BACK_PORCH;
      col_address_i <= h_count0 - H_SYNC_WIDTH - H_BACK_PORCH;
      v_count1      <= v_count0;
      h_count1      <= h_count0;

      -- Third cycle after pulse. Row/Column addresses ready to address RAM
      v_count2 <= v_count1;
      h_count2 <= h_count1;

      -- Fourth cycle after pulse - image RAM data available, used to index
      -- colour LUT. Will be available next clk cycle, so want to synchronise
      -- with blank, hs and vs signals.
      if (h_count2 >= H_SYNC_WIDTH + H_BACK_PORCH)
        and (h_count2 < MAX_COLUMNS - H_FRONT_PORCH)
        and (v_count2 >= V_SYNC_WIDTH + V_BACK_PORCH)
        and (v_count2 < MAX_LINES - V_FRONT_PORCH)
      then
        blank <= '0';
      else
        blank <= '1';
      end if;

      if (h_count2 < H_SYNC_WIDTH) then
        hs_out <= '0';
      else
        hs_out <= '1';
      end if;
      if (v_count2 < V_SYNC_WIDTH) then
        vs_out <= '0';
      else
        vs_out <= '1';
      end if;
    end if;
  end process;


end Behavioral;
