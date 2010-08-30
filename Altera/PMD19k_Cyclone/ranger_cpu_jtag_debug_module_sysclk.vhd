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

entity ranger_cpu_jtag_debug_module_sysclk is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal ir_in : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal sr : IN STD_LOGIC_VECTOR (37 DOWNTO 0);
                 signal vs_udr : IN STD_LOGIC;
                 signal vs_uir : IN STD_LOGIC;

              -- outputs:
                 signal jdo : OUT STD_LOGIC_VECTOR (37 DOWNTO 0);
                 signal take_action_break_a : OUT STD_LOGIC;
                 signal take_action_break_b : OUT STD_LOGIC;
                 signal take_action_break_c : OUT STD_LOGIC;
                 signal take_action_ocimem_a : OUT STD_LOGIC;
                 signal take_action_ocimem_b : OUT STD_LOGIC;
                 signal take_action_tracectrl : OUT STD_LOGIC;
                 signal take_action_tracemem_a : OUT STD_LOGIC;
                 signal take_action_tracemem_b : OUT STD_LOGIC;
                 signal take_no_action_break_a : OUT STD_LOGIC;
                 signal take_no_action_break_b : OUT STD_LOGIC;
                 signal take_no_action_break_c : OUT STD_LOGIC;
                 signal take_no_action_ocimem_a : OUT STD_LOGIC;
                 signal take_no_action_tracemem_a : OUT STD_LOGIC
              );
end entity ranger_cpu_jtag_debug_module_sysclk;


architecture europa of ranger_cpu_jtag_debug_module_sysclk is
                signal internal_jdo1 :  STD_LOGIC_VECTOR (37 DOWNTO 0);
                signal ir :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jxdr :  STD_LOGIC;
                signal jxuir :  STD_LOGIC;
                signal prejxdr :  STD_LOGIC;
                signal udr_sync1 :  STD_LOGIC;
                signal udr_sync2 :  STD_LOGIC;
                signal udr_sync3 :  STD_LOGIC;
                signal uir_sync1 :  STD_LOGIC;
                signal uir_sync2 :  STD_LOGIC;
                signal uir_sync3 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of jdo : signal is "SUPPRESS_DA_RULE_INTERNAL=""D101,R101""";
attribute ALTERA_ATTRIBUTE of udr_sync1 : signal is "SUPPRESS_DA_RULE_INTERNAL=""D101,D103""";
attribute ALTERA_ATTRIBUTE of uir_sync1 : signal is "SUPPRESS_DA_RULE_INTERNAL=""D101,D103""";

begin

  process (clk)
  begin
    if clk'event and clk = '1' then
      udr_sync1 <= vs_udr;
      udr_sync2 <= udr_sync1;
      udr_sync3 <= udr_sync2;
      prejxdr <= udr_sync2 AND NOT udr_sync3;
      jxdr <= prejxdr;
      uir_sync1 <= vs_uir;
      uir_sync2 <= uir_sync1;
      uir_sync3 <= uir_sync2;
      jxuir <= uir_sync2 AND NOT uir_sync3;
    end if;

  end process;

  take_action_ocimem_a <= ((jxdr AND to_std_logic(((ir = std_logic_vector'("00"))))) AND NOT internal_jdo1(35)) AND internal_jdo1(34);
  take_no_action_ocimem_a <= ((jxdr AND to_std_logic(((ir = std_logic_vector'("00"))))) AND NOT internal_jdo1(35)) AND NOT internal_jdo1(34);
  take_action_ocimem_b <= (jxdr AND to_std_logic(((ir = std_logic_vector'("00"))))) AND internal_jdo1(35);
  take_action_tracemem_a <= ((jxdr AND to_std_logic(((ir = std_logic_vector'("01"))))) AND NOT internal_jdo1(37)) AND internal_jdo1(36);
  take_no_action_tracemem_a <= ((jxdr AND to_std_logic(((ir = std_logic_vector'("01"))))) AND NOT internal_jdo1(37)) AND NOT internal_jdo1(36);
  take_action_tracemem_b <= (jxdr AND to_std_logic(((ir = std_logic_vector'("01"))))) AND internal_jdo1(37);
  take_action_break_a <= ((jxdr AND to_std_logic(((ir = std_logic_vector'("10"))))) AND NOT internal_jdo1(36)) AND internal_jdo1(37);
  take_no_action_break_a <= ((jxdr AND to_std_logic(((ir = std_logic_vector'("10"))))) AND NOT internal_jdo1(36)) AND NOT internal_jdo1(37);
  take_action_break_b <= (((jxdr AND to_std_logic(((ir = std_logic_vector'("10"))))) AND internal_jdo1(36)) AND NOT internal_jdo1(35)) AND internal_jdo1(37);
  take_no_action_break_b <= (((jxdr AND to_std_logic(((ir = std_logic_vector'("10"))))) AND internal_jdo1(36)) AND NOT internal_jdo1(35)) AND NOT internal_jdo1(37);
  take_action_break_c <= (((jxdr AND to_std_logic(((ir = std_logic_vector'("10"))))) AND internal_jdo1(36)) AND internal_jdo1(35)) AND internal_jdo1(37);
  take_no_action_break_c <= (((jxdr AND to_std_logic(((ir = std_logic_vector'("10"))))) AND internal_jdo1(36)) AND internal_jdo1(35)) AND NOT internal_jdo1(37);
  take_action_tracectrl <= (jxdr AND to_std_logic(((ir = std_logic_vector'("11"))))) AND internal_jdo1(15);
  process (clk)
  begin
    if clk'event and clk = '1' then
      if std_logic'(jxuir) = '1' then 
        ir <= ir_in;
      end if;
      if std_logic'(prejxdr) = '1' then 
        internal_jdo1 <= sr;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  jdo <= internal_jdo1;

end europa;

