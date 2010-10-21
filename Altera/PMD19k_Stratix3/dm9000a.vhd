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

entity dm9000a is 
        port (
              -- inputs:
                 signal ENET_INT : IN STD_LOGIC;
                 signal iCLK : IN STD_LOGIC;
                 signal iCMD : IN STD_LOGIC;
                 signal iCS_N : IN STD_LOGIC;
                 signal iDATA : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal iOSC_50 : IN STD_LOGIC;
                 signal iRD_N : IN STD_LOGIC;
                 signal iRST_N : IN STD_LOGIC;
                 signal iWR_N : IN STD_LOGIC;

              -- outputs:
                 signal ENET_CLK : OUT STD_LOGIC;
                 signal ENET_CMD : OUT STD_LOGIC;
                 signal ENET_CS_N : OUT STD_LOGIC;
                 signal ENET_DATA : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ENET_RD_N : OUT STD_LOGIC;
                 signal ENET_RST_N : OUT STD_LOGIC;
                 signal ENET_WR_N : OUT STD_LOGIC;
                 signal oDATA : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal oINT : OUT STD_LOGIC
              );
end entity dm9000a;


architecture europa of dm9000a is
component DM9000A_IF is 
           port (
                 -- inputs:
                    signal ENET_INT : IN STD_LOGIC;
                    signal iCLK : IN STD_LOGIC;
                    signal iCMD : IN STD_LOGIC;
                    signal iCS_N : IN STD_LOGIC;
                    signal iDATA : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal iOSC_50 : IN STD_LOGIC;
                    signal iRD_N : IN STD_LOGIC;
                    signal iRST_N : IN STD_LOGIC;
                    signal iWR_N : IN STD_LOGIC;

                 -- outputs:
                    signal ENET_CLK : OUT STD_LOGIC;
                    signal ENET_CMD : OUT STD_LOGIC;
                    signal ENET_CS_N : OUT STD_LOGIC;
                    signal ENET_DATA : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ENET_RD_N : OUT STD_LOGIC;
                    signal ENET_RST_N : OUT STD_LOGIC;
                    signal ENET_WR_N : OUT STD_LOGIC;
                    signal oDATA : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal oINT : OUT STD_LOGIC
                 );
end component DM9000A_IF;

                signal internal_ENET_CLK :  STD_LOGIC;
                signal internal_ENET_CMD :  STD_LOGIC;
                signal internal_ENET_CS_N :  STD_LOGIC;
                signal internal_ENET_RD_N :  STD_LOGIC;
                signal internal_ENET_RST_N :  STD_LOGIC;
                signal internal_ENET_WR_N :  STD_LOGIC;
                signal internal_oDATA :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_oINT :  STD_LOGIC;

begin

  --the_DM9000A_IF, which is an e_instance
  the_DM9000A_IF : DM9000A_IF
    port map(
      ENET_CLK => internal_ENET_CLK,
      ENET_CMD => internal_ENET_CMD,
      ENET_CS_N => internal_ENET_CS_N,
      ENET_DATA => ENET_DATA,
      ENET_RD_N => internal_ENET_RD_N,
      ENET_RST_N => internal_ENET_RST_N,
      ENET_WR_N => internal_ENET_WR_N,
      oDATA => internal_oDATA,
      oINT => internal_oINT,
      ENET_INT => ENET_INT,
      iCLK => iCLK,
      iCMD => iCMD,
      iCS_N => iCS_N,
      iDATA => iDATA,
      iOSC_50 => iOSC_50,
      iRD_N => iRD_N,
      iRST_N => iRST_N,
      iWR_N => iWR_N
    );


  --vhdl renameroo for output signals
  ENET_CLK <= internal_ENET_CLK;
  --vhdl renameroo for output signals
  ENET_CMD <= internal_ENET_CMD;
  --vhdl renameroo for output signals
  ENET_CS_N <= internal_ENET_CS_N;
  --vhdl renameroo for output signals
  ENET_RD_N <= internal_ENET_RD_N;
  --vhdl renameroo for output signals
  ENET_RST_N <= internal_ENET_RST_N;
  --vhdl renameroo for output signals
  ENET_WR_N <= internal_ENET_WR_N;
  --vhdl renameroo for output signals
  oDATA <= internal_oDATA;
  --vhdl renameroo for output signals
  oINT <= internal_oINT;

end europa;

