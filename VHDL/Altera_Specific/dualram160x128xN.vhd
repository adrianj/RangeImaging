-- Dual port Block RAM designed for PMD 19k sensor size and Stratix III chip
-- col_addr(7 downto 0)
-- row_addr(6 downto 0)
-- RAM_addr(14 downto 0) = row_addr & col_addr;
-- Reads outside this range (col_addr 160->256) return '1's
-- Rows 120->127 are still usable.
-- Bit depth of N.
-- Write enable is active high.

-------------------------------------------------------------------------------
-- Added generic feature SMALL_RAM, which has the same port structure (ie,
-- rows, columns, N bits wide) but only a 64x64 portion of pixels have been
-- implemented. This feature is useful for prototyping the design on a smaller
-- FPGA, eg, the Cyclone3.

library ieee;
use ieee.std_logic_1164.all;

entity dualram160x128xN is
  generic (N         : integer   := 32;
           SMALL_RAM : std_logic := '0');
  port (
    address_a : in  std_logic_vector(14 downto 0);
    address_b : in  std_logic_vector(14 downto 0);
    clock     : in  std_logic;
    data_a    : in  std_logic_vector(N-1 downto 0);
    data_b    : in  std_logic_vector(N-1 downto 0);
    wren_a    : in  std_logic;
    wren_b    : in  std_logic;
    q_a       : out std_logic_vector(N-1 downto 0);
    q_b       : out std_logic_vector(N-1 downto 0));

end dualram160x128xN;

architecture rtl of dualram160x128xN is

  signal q_1_a : std_logic_vector(N-1 downto 0) := (others => '0');
  signal q_2_a : std_logic_vector(N-1 downto 0) := (others => '0');
  signal q_1_b : std_logic_vector(N-1 downto 0) := (others => '0');
  signal q_2_b : std_logic_vector(N-1 downto 0) := (others => '0');

  signal block_sel_a : std_logic_vector(2 downto 0) := (others => '0');
  signal block_sel_b : std_logic_vector(2 downto 0) := (others => '0');
  signal wren_1_a    : std_logic                    := '0';
  signal wren_1_b    : std_logic                    := '0';
  signal wren_2_a    : std_logic                    := '0';
  signal wren_2_b    : std_logic                    := '0';

  signal address_1_a : std_logic_vector(13 downto 0) := (others => '0');
  signal address_1_b : std_logic_vector(13 downto 0) := (others => '0');
  signal address_2_a : std_logic_vector(11 downto 0) := (others => '0');
  signal address_2_b : std_logic_vector(11 downto 0) := (others => '0');
  
begin  -- rtl

  USE_BIG_RAM : if SMALL_RAM = '0' generate

    BLOCK_1 : entity work.dualram128x128xN
      generic map (
        N => N)
      port map (
        address_a => address_1_a,
        address_b => address_1_b,
        clock     => clock,
        data_a    => data_a,
        data_b    => data_b,
        wren_a    => wren_1_a,
        wren_b    => wren_1_b,
        q_a       => q_1_a,
        q_b       => q_1_b);

    BLOCK_2 : entity work.dualram32x128xN
      generic map (
        N => N)
      port map (
        address_a => address_2_a,
        address_b => address_2_b,
        clock     => clock,
        data_a    => data_a,
        data_b    => data_b,
        wren_a    => wren_2_a,
        wren_b    => wren_2_b,
        q_a       => q_2_a,
        q_b       => q_2_b);

    -- Organise addresses
    address_1_a <= address_a(14 downto 8) & address_a(6 downto 0);
    address_1_b <= address_b(14 downto 8) & address_b(6 downto 0);
    address_2_a <= address_a(14 downto 8) & address_a(4 downto 0);
    address_2_b <= address_b(14 downto 8) & address_b(4 downto 0);

    -- Write enables
    wren_1_a <= wren_a when address_a(7) = '0' else '0';
    wren_2_a <= wren_a when address_a(7) = '1' else '0';
    wren_1_b <= wren_b when address_b(7) = '0' else '0';
    wren_2_b <= wren_b when address_b(7) = '1' else '0';

    -- delay switching part of address for output selecting
    HOLD_SELECT : process (clock)
    begin  -- process HOLD_SELECT
      if rising_edge(clock) then        -- rising clock edge
        block_sel_a <= address_a(7 downto 5);
        block_sel_b <= address_b(7 downto 5);
      end if;
    end process HOLD_SELECT;

    -- Select output. Addresses outside of column range return 1s.
    SET_OUTPUT : process (block_sel_a, block_sel_b, q_1_a, q_2_a, q_1_b, q_2_b)
    begin  -- process SET_OUTPUT
      if block_sel_a(2) = '0' then
        q_a <= q_1_a;
      elsif block_sel_a(2 downto 0) = "100" then
        q_a <= q_2_a;
      else
        q_a <= (others => '1');
      end if;
      if block_sel_b(2) = '0' then
        q_b <= q_1_b;
      elsif block_sel_b(2 downto 0) = "100" then
        q_b <= q_2_b;
      else
        q_b <= (others => '1');
      end if;
    end process SET_OUTPUT;

  end generate USE_BIG_RAM;

  USE_SMALL_RAM : if SMALL_RAM = '1' generate

    BLOCK_2 : entity work.dualram64x64xN
      generic map (
        N => N)
      port map (
        address_a => address_2_a,
        address_b => address_2_b,
        clock     => clock,
        data_a    => data_a,
        data_b    => data_b,
        wren_a    => wren_2_a,
        wren_b    => wren_2_b,
        q_a       => q_2_a,
        q_b       => q_2_b);

    address_2_a <= address_a(13 downto 8) & address_a(5 downto 0);
    address_2_b <= address_b(13 downto 8) & address_b(5 downto 0);

    -- Write enables
    wren_2_a <= wren_a when (address_a(14) = '0' and address_a(7 downto 6) = "01") else '0';
    wren_2_b <= wren_b when (address_b(14) = '0' and address_b(7 downto 6) = "01") else '0';

    -- delay switching part of address for output selecting
    HOLD_SELECT : process (clock)
    begin  -- process HOLD_SELECT
      if rising_edge(clock) then        -- rising clock edge
        block_sel_a <= address_a(14) & address_a(7 downto 6);
        block_sel_b <= address_b(14) & address_b(7 downto 6);
      end if;
    end process HOLD_SELECT;

    -- Select output. Addresses outside of column range return 1s.
    SET_OUTPUT : process (block_sel_a, block_sel_b, q_2_a, q_2_b)
    begin  -- process SET_OUTPUT
      if block_sel_a(2 downto 0) = "001" then
        q_a <= q_2_a;
      else
        q_a <= (others => '1');
      end if;
      if block_sel_b(2 downto 0) = "001" then
        q_b <= q_2_b;
      else
        q_b <= (others => '1');
      end if;
    end process SET_OUTPUT;
    
  end generate USE_SMALL_RAM;
  
end rtl;
