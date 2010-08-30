-- Wrapper for signedmult18x18 megawizard function
-- Basically 18x18 uses the same resources as 17x8.
-- This wrapper ensures output is 27 bits, ready for accumulator.
-- X and Y can me up to 17.

library ieee;
use ieee.std_logic_1164.all;

entity signedmultXxY is
  generic ( X : integer := 8;
			Y : integer := 17);
  port (
    clk     : in  std_logic;
    a       : in  std_logic_vector(X-1 downto 0);
    b       : in  std_logic_vector(Y-1 downto 0);
    q       : out std_logic_vector(X+Y-2 downto 0));

end signedmultXxY;

architecture rtl of signedmultXxY is

  signal a_int : std_logic_vector(17 downto 0) := (others => '0');
  signal b_int : std_logic_vector(17 downto 0) := (others => '0');
  signal q_int : std_logic_vector(35 downto 0) := (others => '0');
  
begin  -- rtl

  DSP_MULT : entity work.signedmult18x18
    port map (
      clock  => clk,
      dataa  => a_int,
      datab  => b_int,
      result => q_int);
			
  -- a_int = 'sign_a' & a & zeros'	  
  a_int(17 downto 18-X) <= a;
  a_int(17-X downto 0) <= (others => '0');	
  
  -- b_int = 'sign_b' & b & zeros'
  b_int(17 downto 18-Y) <= b;
  b_int(17-Y downto 0) <= (others => '0');	
  
  q <= q_int(34 downto 36-X-Y);

end rtl;
