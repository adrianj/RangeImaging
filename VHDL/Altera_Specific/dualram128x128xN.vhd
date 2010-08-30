-- dual port Block RAM with 32x128 lines of N bits wide.

library ieee;
use ieee.std_logic_1164.all;

entity dualram128x128xN is
  
  generic (
    N : integer := 1);
  port (
    address_a : in  std_logic_vector(13 downto 0);
    address_b : in  std_logic_vector(13 downto 0);
    clock     : in  std_logic;
    data_a    : in  std_logic_vector(N-1 downto 0);
    data_b    : in  std_logic_vector(N-1 downto 0);
    wren_a    : in  std_logic;
    wren_b    : in  std_logic;
    q_a       : out std_logic_vector(N-1 downto 0);
    q_b       : out std_logic_vector(N-1 downto 0));


end dualram128x128xN;

architecture rtl of dualram128x128xN is

begin  -- rtl

  SMALL : if N < 9 generate
    SMALL_G : for i in N-1 downto 0 generate
      SMALL_RAM : entity work.dualram128x128x1
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
    end generate SMALL_G;
  end generate SMALL;

  BIG : if N >= 9 generate
    BIG_G : for i in N-1 downto 9 generate
      SMALL_RAM : entity work.dualram128x128x1
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
    end generate BIG_G;
    BIG_RAM : entity work.dualram128x128x9
      port map (
        address_a => address_a,
        address_b => address_b,
        clock     => clock,
        data_a    => data_a(8 downto 0),
        data_b    => data_b(8 downto 0),
        wren_a    => wren_a,
        wren_b    => wren_b,
        q_a       => q_a(8 downto 0),
        q_b       => q_b(8 downto 0));
  end generate BIG;
  

end rtl;
