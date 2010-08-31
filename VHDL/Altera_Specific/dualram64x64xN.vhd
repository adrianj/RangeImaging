-- dual port Block RAM with 64x64 lines of N bits wide.
-- Must be an eve number of bits wide (implemented using M9K blocks)

library ieee;
use ieee.std_logic_1164.all;

entity dualram64x64xN is
  
  generic (
    N : integer := 2);
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


end dualram64x64xN;

architecture rtl of dualram64x64xN is

begin  -- rtl

  G : for i in N/2-1 downto 0 generate
    SMALL_RAM : entity work.dualram64x64x2
      port map (
        address_a => address_a,
        address_b => address_b,
        clock     => clock,
        data_a    => data_a(i*2+1 downto i*2),
        data_b    => data_b(i*2+1 downto i*2),
        wren_a    => wren_a,
        wren_b    => wren_b,
        q_a       => q_a(i*2+1 downto i*2),
        q_b       => q_b(i*2+1 downto i*2));
  end generate G;

end rtl;
