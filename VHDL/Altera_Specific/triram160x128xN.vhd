-- Triple port Block RAM designed for PMD 19k sensor size and Stratix III chip
-- Port B is time multiplexed, Port A is normal
-- Therefore, increase hold times by extra clock cycle.
-- Output latency is also increased.
-- col_addr(7 downto 0)
-- row_addr(6 downto 0)
-- RAM_addr(14 downto 0) = row_addr & col_addr;
-- Reads outside this range (col_addr 160->256) return '1's
-- Rows 120->127 are still usable.
-- Bit depth of 16.
-- Write enable is active high.
-- Each instance requires 40 x 9k blocks.

library ieee;
use ieee.std_logic_1164.all;

entity triram160x128xN is
  generic (N : integer := 32);
  port (
    address_a : in  std_logic_vector(14 downto 0);
    address_b : in  std_logic_vector(14 downto 0);
    address_c : in  std_logic_vector(14 downto 0);
    clock     : in  std_logic;
    data_a    : in  std_logic_vector(N-1 downto 0);
    data_b    : in  std_logic_vector(N-1 downto 0);
    data_c    : in  std_logic_vector(N-1 downto 0);
    wren_a    : in  std_logic;
    wren_b    : in  std_logic;
    wren_c    : in  std_logic;
    q_a       : out std_logic_vector(N-1 downto 0);
    q_b       : out std_logic_vector(N-1 downto 0);
    q_c       : out std_logic_vector(N-1 downto 0));

end triram160x128xN;

architecture rtl of triram160x128xN is

  signal address_b_int : std_logic_vector(14 downto 0)  := (others => '0');
  signal data_b_int    : std_logic_vector(N-1 downto 0) := (others => '0');
  signal q_b_int       : std_logic_vector(N-1 downto 0) := (others => '0');
  signal wren_b_int    : std_logic                      := '0';
  signal b_sel         : std_logic                      := '0';
  
begin  -- rtl

  BLOCK_1 : entity work.dualram160x128xN
	generic map ( N => N )
    port map (
      address_a => address_a,
      address_b => address_b_int,
      clock     => clock,
      data_a    => data_a,
      data_b    => data_b_int,
      wren_a    => wren_a,
      wren_b    => wren_b_int,
      q_a       => q_a,
      q_b       => q_b_int);

  SET_SELECT : process (clock)
  begin  -- process SET_SELECT
    if rising_edge(clock) then          -- rising clock edge
      b_sel <= not b_sel;
      if b_sel = '1' then
        q_c <= q_b_int;
      else
        q_b <= q_b_int;
      end if;
    end if;
  end process SET_SELECT;

  SET_B_PORT : process (b_sel, q_b_int, address_b, address_c, data_b, data_c, wren_b, wren_c)
  begin  -- process SET_B_POT
    if b_sel = '1' then
      address_b_int <= address_b;
      data_b_int    <= data_b;
      wren_b_int    <= wren_b;
    else
      address_b_int <= address_c;
      data_b_int    <= data_c;
      wren_b_int    <= wren_c;
    end if;
  end process SET_B_PORT;


end rtl;
