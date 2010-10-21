--Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity BR is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal ex_dout : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal nios_addr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal nios_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal nios_re_n : IN STD_LOGIC;
                 signal nios_we_n : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ex_addr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ex_clk : OUT STD_LOGIC;
                 signal ex_din : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_re_n : OUT STD_LOGIC;
                 signal ex_reset_n : OUT STD_LOGIC;
                 signal ex_we_n : OUT STD_LOGIC;
                 signal nios_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity BR;


architecture europa of BR is
component nios_slave_16 is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal ex_dout : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal nios_addr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal nios_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal nios_re_n : IN STD_LOGIC;
                    signal nios_we_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ex_addr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ex_clk : OUT STD_LOGIC;
                    signal ex_din : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_re_n : OUT STD_LOGIC;
                    signal ex_reset_n : OUT STD_LOGIC;
                    signal ex_we_n : OUT STD_LOGIC;
                    signal nios_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component nios_slave_16;

                signal internal_ex_addr :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ex_clk :  STD_LOGIC;
                signal internal_ex_din :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ex_re_n :  STD_LOGIC;
                signal internal_ex_reset_n :  STD_LOGIC;
                signal internal_ex_we_n :  STD_LOGIC;
                signal internal_nios_dout :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --the_nios_slave_16, which is an e_instance
  the_nios_slave_16 : nios_slave_16
    port map(
      ex_addr => internal_ex_addr,
      ex_clk => internal_ex_clk,
      ex_din => internal_ex_din,
      ex_re_n => internal_ex_re_n,
      ex_reset_n => internal_ex_reset_n,
      ex_we_n => internal_ex_we_n,
      nios_dout => internal_nios_dout,
      clk => clk,
      ex_dout => ex_dout,
      nios_addr => nios_addr,
      nios_din => nios_din,
      nios_re_n => nios_re_n,
      nios_we_n => nios_we_n,
      reset_n => reset_n
    );


  --vhdl renameroo for output signals
  ex_addr <= internal_ex_addr;
  --vhdl renameroo for output signals
  ex_clk <= internal_ex_clk;
  --vhdl renameroo for output signals
  ex_din <= internal_ex_din;
  --vhdl renameroo for output signals
  ex_re_n <= internal_ex_re_n;
  --vhdl renameroo for output signals
  ex_reset_n <= internal_ex_reset_n;
  --vhdl renameroo for output signals
  ex_we_n <= internal_ex_we_n;
  --vhdl renameroo for output signals
  nios_dout <= internal_nios_dout;

end europa;

