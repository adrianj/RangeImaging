-- Very simple interface for Nios II processor

library ieee;
use ieee.std_logic_1164.all;

entity nios_slave_16 is
  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;
    nios_addr  : in  std_logic_vector(15 downto 0);
    nios_din   : in  std_logic_vector(31 downto 0);
    nios_dout  : out std_logic_vector(31 downto 0);
    nios_we_n  : in  std_logic;
    nios_re_n  : in  std_logic;
    ex_din     : out std_logic_vector(31 downto 0);
    ex_dout    : in  std_logic_vector(31 downto 0);
    ex_addr    : out std_logic_vector(15 downto 0);
    ex_we_n    : out std_logic;
    ex_re_n    : out std_logic;
    ex_clk     : out std_logic;
    ex_reset_n : out std_logic);

end nios_slave_16;

architecture rtl of nios_slave_16 is

begin  -- rtl

  ex_din     <= nios_din;
  nios_dout  <= ex_dout;
  ex_we_n    <= nios_we_n;
  ex_re_n    <= nios_re_n;
  ex_addr    <= nios_addr;
  ex_clk     <= clk;
  ex_reset_n <= reset_n;

end rtl;
