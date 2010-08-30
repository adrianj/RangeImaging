-- dual port Block RAM with 32x128 lines of N bits wide.

library ieee;
use ieee.std_logic_1164.all;

entity dualram32x128xN is
  
  generic (
    N : integer := 1);
port (
    address_a : in  std_logic_vector(11 downto 0);
    address_b : in  std_logic_vector(11 downto 0);
    clock     : in  std_logic;
    data_a    : in  std_logic_vector(N-1 downto 0);
    data_b    : in  std_logic_vector(N-1 downto 0);
    wren_a    : in  std_logic;
    wren_b    : in  std_logic;
    q_a       : out std_logic_vector(N-1 downto 0);
    q_b       : out std_logic_vector(N-1 downto 0));


end dualram32x128xN;

architecture rtl of dualram32x128xN is

begin  -- rtl

  G: for i in N-1 downto 0 generate
    SMALL_RAM : entity work.dualram32x128x1
      port map (
        address_a => address_a,
        address_b => address_b,
        clock     => clock,
        data_a    => data_a(i downto i),
        data_b    => data_b(i downto i),
        wren_a    => wren_a,
        wren_b    => wren_b,
        q_a       => q_a(i downto i),
        q_b       => q_b(i downto i));
  end generate G;

end rtl;
