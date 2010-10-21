--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


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

entity BL_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal BL_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal BL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal BL_avalon_slave_read_n : OUT STD_LOGIC;
                 signal BL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal BL_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal BL_avalon_slave_write_n : OUT STD_LOGIC;
                 signal BL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_granted_BL_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_BL_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_BL_avalon_slave : OUT STD_LOGIC;
                 signal d1_BL_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC
              );
end entity BL_avalon_slave_arbitrator;


architecture europa of BL_avalon_slave_arbitrator is
                signal BL_avalon_slave_allgrants :  STD_LOGIC;
                signal BL_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal BL_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal BL_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal BL_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal BL_avalon_slave_arb_share_counter :  STD_LOGIC;
                signal BL_avalon_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal BL_avalon_slave_arb_share_set_values :  STD_LOGIC;
                signal BL_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal BL_avalon_slave_begins_xfer :  STD_LOGIC;
                signal BL_avalon_slave_end_xfer :  STD_LOGIC;
                signal BL_avalon_slave_firsttransfer :  STD_LOGIC;
                signal BL_avalon_slave_grant_vector :  STD_LOGIC;
                signal BL_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal BL_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal BL_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal BL_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal BL_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal BL_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal BL_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal BL_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal BL_avalon_slave_waits_for_read :  STD_LOGIC;
                signal BL_avalon_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_BL_avalon_slave_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_BL_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_BL_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_BL_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_BL_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_BL_avalon_slave :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register :  STD_LOGIC;
                signal shifted_address_to_BL_avalon_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_BL_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT BL_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  BL_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_BL_avalon_slave);
  --assign BL_avalon_slave_readdata_from_sa = BL_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  BL_avalon_slave_readdata_from_sa <= BL_avalon_slave_readdata;
  internal_cpu_data_master_requests_BL_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("000000010000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_BL_avalon_slave assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_BL_avalon_slave <= cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in;
  --BL_avalon_slave_arb_share_counter set values, which is an e_mux
  BL_avalon_slave_arb_share_set_values <= std_logic'('1');
  --BL_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  BL_avalon_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_BL_avalon_slave;
  --BL_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  BL_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --BL_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  BL_avalon_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(BL_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BL_avalon_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(BL_avalon_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BL_avalon_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --BL_avalon_slave_allgrants all slave grants, which is an e_mux
  BL_avalon_slave_allgrants <= BL_avalon_slave_grant_vector;
  --BL_avalon_slave_end_xfer assignment, which is an e_assign
  BL_avalon_slave_end_xfer <= NOT ((BL_avalon_slave_waits_for_read OR BL_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_BL_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_BL_avalon_slave <= BL_avalon_slave_end_xfer AND (((NOT BL_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --BL_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  BL_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_BL_avalon_slave AND BL_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_BL_avalon_slave AND NOT BL_avalon_slave_non_bursting_master_requests));
  --BL_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      BL_avalon_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(BL_avalon_slave_arb_counter_enable) = '1' then 
        BL_avalon_slave_arb_share_counter <= BL_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --BL_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      BL_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((BL_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_BL_avalon_slave)) OR ((end_xfer_arb_share_counter_term_BL_avalon_slave AND NOT BL_avalon_slave_non_bursting_master_requests)))) = '1' then 
        BL_avalon_slave_slavearbiterlockenable <= BL_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master BL/avalon_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= BL_avalon_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --BL_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  BL_avalon_slave_slavearbiterlockenable2 <= BL_avalon_slave_arb_share_counter_next_value;
  --cpu/data_master BL/avalon_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= BL_avalon_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --BL_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  BL_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_BL_avalon_slave <= internal_cpu_data_master_requests_BL_avalon_slave AND NOT ((((cpu_data_master_read AND (cpu_data_master_read_data_valid_BL_avalon_slave_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in <= ((internal_cpu_data_master_granted_BL_avalon_slave AND cpu_data_master_read) AND NOT BL_avalon_slave_waits_for_read) AND NOT (cpu_data_master_read_data_valid_BL_avalon_slave_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_BL_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_BL_avalon_slave_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in)));
  --cpu_data_master_read_data_valid_BL_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_BL_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_BL_avalon_slave_shift_register <= p1_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_BL_avalon_slave, which is an e_mux
  cpu_data_master_read_data_valid_BL_avalon_slave <= cpu_data_master_read_data_valid_BL_avalon_slave_shift_register;
  --BL_avalon_slave_writedata mux, which is an e_mux
  BL_avalon_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_BL_avalon_slave <= internal_cpu_data_master_qualified_request_BL_avalon_slave;
  --cpu/data_master saved-grant BL/avalon_slave, which is an e_assign
  cpu_data_master_saved_grant_BL_avalon_slave <= internal_cpu_data_master_requests_BL_avalon_slave;
  --allow new arb cycle for BL/avalon_slave, which is an e_assign
  BL_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  BL_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  BL_avalon_slave_master_qreq_vector <= std_logic'('1');
  --BL_avalon_slave_reset_n assignment, which is an e_assign
  BL_avalon_slave_reset_n <= reset_n;
  --BL_avalon_slave_firsttransfer first transaction, which is an e_assign
  BL_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(BL_avalon_slave_begins_xfer) = '1'), BL_avalon_slave_unreg_firsttransfer, BL_avalon_slave_reg_firsttransfer);
  --BL_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  BL_avalon_slave_unreg_firsttransfer <= NOT ((BL_avalon_slave_slavearbiterlockenable AND BL_avalon_slave_any_continuerequest));
  --BL_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      BL_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(BL_avalon_slave_begins_xfer) = '1' then 
        BL_avalon_slave_reg_firsttransfer <= BL_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --BL_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  BL_avalon_slave_beginbursttransfer_internal <= BL_avalon_slave_begins_xfer;
  --~BL_avalon_slave_read_n assignment, which is an e_mux
  BL_avalon_slave_read_n <= NOT ((internal_cpu_data_master_granted_BL_avalon_slave AND cpu_data_master_read));
  --~BL_avalon_slave_write_n assignment, which is an e_mux
  BL_avalon_slave_write_n <= NOT ((internal_cpu_data_master_granted_BL_avalon_slave AND cpu_data_master_write));
  shifted_address_to_BL_avalon_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --BL_avalon_slave_address mux, which is an e_mux
  BL_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_BL_avalon_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
  --d1_BL_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_BL_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_BL_avalon_slave_end_xfer <= BL_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  --BL_avalon_slave_waits_for_read in a cycle, which is an e_mux
  BL_avalon_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BL_avalon_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --BL_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  BL_avalon_slave_in_a_read_cycle <= internal_cpu_data_master_granted_BL_avalon_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= BL_avalon_slave_in_a_read_cycle;
  --BL_avalon_slave_waits_for_write in a cycle, which is an e_mux
  BL_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BL_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --BL_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  BL_avalon_slave_in_a_write_cycle <= internal_cpu_data_master_granted_BL_avalon_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= BL_avalon_slave_in_a_write_cycle;
  wait_for_BL_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_BL_avalon_slave <= internal_cpu_data_master_granted_BL_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_BL_avalon_slave <= internal_cpu_data_master_qualified_request_BL_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_BL_avalon_slave <= internal_cpu_data_master_requests_BL_avalon_slave;
--synthesis translate_off
    --BL/avalon_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity BR_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal BR_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal BR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal BR_avalon_slave_read_n : OUT STD_LOGIC;
                 signal BR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal BR_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal BR_avalon_slave_write_n : OUT STD_LOGIC;
                 signal BR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_granted_BR_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_BR_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_BR_avalon_slave : OUT STD_LOGIC;
                 signal d1_BR_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC
              );
end entity BR_avalon_slave_arbitrator;


architecture europa of BR_avalon_slave_arbitrator is
                signal BR_avalon_slave_allgrants :  STD_LOGIC;
                signal BR_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal BR_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal BR_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal BR_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal BR_avalon_slave_arb_share_counter :  STD_LOGIC;
                signal BR_avalon_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal BR_avalon_slave_arb_share_set_values :  STD_LOGIC;
                signal BR_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal BR_avalon_slave_begins_xfer :  STD_LOGIC;
                signal BR_avalon_slave_end_xfer :  STD_LOGIC;
                signal BR_avalon_slave_firsttransfer :  STD_LOGIC;
                signal BR_avalon_slave_grant_vector :  STD_LOGIC;
                signal BR_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal BR_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal BR_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal BR_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal BR_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal BR_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal BR_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal BR_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal BR_avalon_slave_waits_for_read :  STD_LOGIC;
                signal BR_avalon_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_BR_avalon_slave_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_BR_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_BR_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_BR_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_BR_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_BR_avalon_slave :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register :  STD_LOGIC;
                signal shifted_address_to_BR_avalon_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_BR_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT BR_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  BR_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_BR_avalon_slave);
  --assign BR_avalon_slave_readdata_from_sa = BR_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  BR_avalon_slave_readdata_from_sa <= BR_avalon_slave_readdata;
  internal_cpu_data_master_requests_BR_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("000000011000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_BR_avalon_slave assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_BR_avalon_slave <= cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in;
  --BR_avalon_slave_arb_share_counter set values, which is an e_mux
  BR_avalon_slave_arb_share_set_values <= std_logic'('1');
  --BR_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  BR_avalon_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_BR_avalon_slave;
  --BR_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  BR_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --BR_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  BR_avalon_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(BR_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BR_avalon_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(BR_avalon_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BR_avalon_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --BR_avalon_slave_allgrants all slave grants, which is an e_mux
  BR_avalon_slave_allgrants <= BR_avalon_slave_grant_vector;
  --BR_avalon_slave_end_xfer assignment, which is an e_assign
  BR_avalon_slave_end_xfer <= NOT ((BR_avalon_slave_waits_for_read OR BR_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_BR_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_BR_avalon_slave <= BR_avalon_slave_end_xfer AND (((NOT BR_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --BR_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  BR_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_BR_avalon_slave AND BR_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_BR_avalon_slave AND NOT BR_avalon_slave_non_bursting_master_requests));
  --BR_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      BR_avalon_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(BR_avalon_slave_arb_counter_enable) = '1' then 
        BR_avalon_slave_arb_share_counter <= BR_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --BR_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      BR_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((BR_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_BR_avalon_slave)) OR ((end_xfer_arb_share_counter_term_BR_avalon_slave AND NOT BR_avalon_slave_non_bursting_master_requests)))) = '1' then 
        BR_avalon_slave_slavearbiterlockenable <= BR_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master BR/avalon_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= BR_avalon_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --BR_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  BR_avalon_slave_slavearbiterlockenable2 <= BR_avalon_slave_arb_share_counter_next_value;
  --cpu/data_master BR/avalon_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= BR_avalon_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --BR_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  BR_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_BR_avalon_slave <= internal_cpu_data_master_requests_BR_avalon_slave AND NOT ((((cpu_data_master_read AND (cpu_data_master_read_data_valid_BR_avalon_slave_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in <= ((internal_cpu_data_master_granted_BR_avalon_slave AND cpu_data_master_read) AND NOT BR_avalon_slave_waits_for_read) AND NOT (cpu_data_master_read_data_valid_BR_avalon_slave_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_BR_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_BR_avalon_slave_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in)));
  --cpu_data_master_read_data_valid_BR_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_BR_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_BR_avalon_slave_shift_register <= p1_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_BR_avalon_slave, which is an e_mux
  cpu_data_master_read_data_valid_BR_avalon_slave <= cpu_data_master_read_data_valid_BR_avalon_slave_shift_register;
  --BR_avalon_slave_writedata mux, which is an e_mux
  BR_avalon_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_BR_avalon_slave <= internal_cpu_data_master_qualified_request_BR_avalon_slave;
  --cpu/data_master saved-grant BR/avalon_slave, which is an e_assign
  cpu_data_master_saved_grant_BR_avalon_slave <= internal_cpu_data_master_requests_BR_avalon_slave;
  --allow new arb cycle for BR/avalon_slave, which is an e_assign
  BR_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  BR_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  BR_avalon_slave_master_qreq_vector <= std_logic'('1');
  --BR_avalon_slave_reset_n assignment, which is an e_assign
  BR_avalon_slave_reset_n <= reset_n;
  --BR_avalon_slave_firsttransfer first transaction, which is an e_assign
  BR_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(BR_avalon_slave_begins_xfer) = '1'), BR_avalon_slave_unreg_firsttransfer, BR_avalon_slave_reg_firsttransfer);
  --BR_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  BR_avalon_slave_unreg_firsttransfer <= NOT ((BR_avalon_slave_slavearbiterlockenable AND BR_avalon_slave_any_continuerequest));
  --BR_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      BR_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(BR_avalon_slave_begins_xfer) = '1' then 
        BR_avalon_slave_reg_firsttransfer <= BR_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --BR_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  BR_avalon_slave_beginbursttransfer_internal <= BR_avalon_slave_begins_xfer;
  --~BR_avalon_slave_read_n assignment, which is an e_mux
  BR_avalon_slave_read_n <= NOT ((internal_cpu_data_master_granted_BR_avalon_slave AND cpu_data_master_read));
  --~BR_avalon_slave_write_n assignment, which is an e_mux
  BR_avalon_slave_write_n <= NOT ((internal_cpu_data_master_granted_BR_avalon_slave AND cpu_data_master_write));
  shifted_address_to_BR_avalon_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --BR_avalon_slave_address mux, which is an e_mux
  BR_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_BR_avalon_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
  --d1_BR_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_BR_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_BR_avalon_slave_end_xfer <= BR_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  --BR_avalon_slave_waits_for_read in a cycle, which is an e_mux
  BR_avalon_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BR_avalon_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --BR_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  BR_avalon_slave_in_a_read_cycle <= internal_cpu_data_master_granted_BR_avalon_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= BR_avalon_slave_in_a_read_cycle;
  --BR_avalon_slave_waits_for_write in a cycle, which is an e_mux
  BR_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BR_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --BR_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  BR_avalon_slave_in_a_write_cycle <= internal_cpu_data_master_granted_BR_avalon_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= BR_avalon_slave_in_a_write_cycle;
  wait_for_BR_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_BR_avalon_slave <= internal_cpu_data_master_granted_BR_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_BR_avalon_slave <= internal_cpu_data_master_qualified_request_BR_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_BR_avalon_slave <= internal_cpu_data_master_requests_BR_avalon_slave;
--synthesis translate_off
    --BR/avalon_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity TL_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal TL_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal TL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal TL_avalon_slave_read_n : OUT STD_LOGIC;
                 signal TL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TL_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal TL_avalon_slave_write_n : OUT STD_LOGIC;
                 signal TL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_granted_TL_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_TL_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_TL_avalon_slave : OUT STD_LOGIC;
                 signal d1_TL_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC
              );
end entity TL_avalon_slave_arbitrator;


architecture europa of TL_avalon_slave_arbitrator is
                signal TL_avalon_slave_allgrants :  STD_LOGIC;
                signal TL_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal TL_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal TL_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal TL_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal TL_avalon_slave_arb_share_counter :  STD_LOGIC;
                signal TL_avalon_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal TL_avalon_slave_arb_share_set_values :  STD_LOGIC;
                signal TL_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal TL_avalon_slave_begins_xfer :  STD_LOGIC;
                signal TL_avalon_slave_end_xfer :  STD_LOGIC;
                signal TL_avalon_slave_firsttransfer :  STD_LOGIC;
                signal TL_avalon_slave_grant_vector :  STD_LOGIC;
                signal TL_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal TL_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal TL_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal TL_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal TL_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal TL_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal TL_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal TL_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal TL_avalon_slave_waits_for_read :  STD_LOGIC;
                signal TL_avalon_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TL_avalon_slave_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_TL_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_TL_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_TL_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_TL_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_TL_avalon_slave :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register :  STD_LOGIC;
                signal shifted_address_to_TL_avalon_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_TL_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT TL_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  TL_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_TL_avalon_slave);
  --assign TL_avalon_slave_readdata_from_sa = TL_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  TL_avalon_slave_readdata_from_sa <= TL_avalon_slave_readdata;
  internal_cpu_data_master_requests_TL_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("000000000000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_TL_avalon_slave assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_TL_avalon_slave <= cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in;
  --TL_avalon_slave_arb_share_counter set values, which is an e_mux
  TL_avalon_slave_arb_share_set_values <= std_logic'('1');
  --TL_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  TL_avalon_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_TL_avalon_slave;
  --TL_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  TL_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --TL_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  TL_avalon_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(TL_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TL_avalon_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(TL_avalon_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TL_avalon_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --TL_avalon_slave_allgrants all slave grants, which is an e_mux
  TL_avalon_slave_allgrants <= TL_avalon_slave_grant_vector;
  --TL_avalon_slave_end_xfer assignment, which is an e_assign
  TL_avalon_slave_end_xfer <= NOT ((TL_avalon_slave_waits_for_read OR TL_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_TL_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_TL_avalon_slave <= TL_avalon_slave_end_xfer AND (((NOT TL_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --TL_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  TL_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_TL_avalon_slave AND TL_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_TL_avalon_slave AND NOT TL_avalon_slave_non_bursting_master_requests));
  --TL_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TL_avalon_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(TL_avalon_slave_arb_counter_enable) = '1' then 
        TL_avalon_slave_arb_share_counter <= TL_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --TL_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TL_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((TL_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_TL_avalon_slave)) OR ((end_xfer_arb_share_counter_term_TL_avalon_slave AND NOT TL_avalon_slave_non_bursting_master_requests)))) = '1' then 
        TL_avalon_slave_slavearbiterlockenable <= TL_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master TL/avalon_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= TL_avalon_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --TL_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  TL_avalon_slave_slavearbiterlockenable2 <= TL_avalon_slave_arb_share_counter_next_value;
  --cpu/data_master TL/avalon_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= TL_avalon_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --TL_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  TL_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_TL_avalon_slave <= internal_cpu_data_master_requests_TL_avalon_slave AND NOT ((((cpu_data_master_read AND (cpu_data_master_read_data_valid_TL_avalon_slave_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in <= ((internal_cpu_data_master_granted_TL_avalon_slave AND cpu_data_master_read) AND NOT TL_avalon_slave_waits_for_read) AND NOT (cpu_data_master_read_data_valid_TL_avalon_slave_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_TL_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_TL_avalon_slave_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in)));
  --cpu_data_master_read_data_valid_TL_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_TL_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_TL_avalon_slave_shift_register <= p1_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_TL_avalon_slave, which is an e_mux
  cpu_data_master_read_data_valid_TL_avalon_slave <= cpu_data_master_read_data_valid_TL_avalon_slave_shift_register;
  --TL_avalon_slave_writedata mux, which is an e_mux
  TL_avalon_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_TL_avalon_slave <= internal_cpu_data_master_qualified_request_TL_avalon_slave;
  --cpu/data_master saved-grant TL/avalon_slave, which is an e_assign
  cpu_data_master_saved_grant_TL_avalon_slave <= internal_cpu_data_master_requests_TL_avalon_slave;
  --allow new arb cycle for TL/avalon_slave, which is an e_assign
  TL_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  TL_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  TL_avalon_slave_master_qreq_vector <= std_logic'('1');
  --TL_avalon_slave_reset_n assignment, which is an e_assign
  TL_avalon_slave_reset_n <= reset_n;
  --TL_avalon_slave_firsttransfer first transaction, which is an e_assign
  TL_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(TL_avalon_slave_begins_xfer) = '1'), TL_avalon_slave_unreg_firsttransfer, TL_avalon_slave_reg_firsttransfer);
  --TL_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  TL_avalon_slave_unreg_firsttransfer <= NOT ((TL_avalon_slave_slavearbiterlockenable AND TL_avalon_slave_any_continuerequest));
  --TL_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TL_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(TL_avalon_slave_begins_xfer) = '1' then 
        TL_avalon_slave_reg_firsttransfer <= TL_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --TL_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  TL_avalon_slave_beginbursttransfer_internal <= TL_avalon_slave_begins_xfer;
  --~TL_avalon_slave_read_n assignment, which is an e_mux
  TL_avalon_slave_read_n <= NOT ((internal_cpu_data_master_granted_TL_avalon_slave AND cpu_data_master_read));
  --~TL_avalon_slave_write_n assignment, which is an e_mux
  TL_avalon_slave_write_n <= NOT ((internal_cpu_data_master_granted_TL_avalon_slave AND cpu_data_master_write));
  shifted_address_to_TL_avalon_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --TL_avalon_slave_address mux, which is an e_mux
  TL_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_TL_avalon_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
  --d1_TL_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_TL_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_TL_avalon_slave_end_xfer <= TL_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  --TL_avalon_slave_waits_for_read in a cycle, which is an e_mux
  TL_avalon_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TL_avalon_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TL_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  TL_avalon_slave_in_a_read_cycle <= internal_cpu_data_master_granted_TL_avalon_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= TL_avalon_slave_in_a_read_cycle;
  --TL_avalon_slave_waits_for_write in a cycle, which is an e_mux
  TL_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TL_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TL_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  TL_avalon_slave_in_a_write_cycle <= internal_cpu_data_master_granted_TL_avalon_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= TL_avalon_slave_in_a_write_cycle;
  wait_for_TL_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_TL_avalon_slave <= internal_cpu_data_master_granted_TL_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_TL_avalon_slave <= internal_cpu_data_master_qualified_request_TL_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_TL_avalon_slave <= internal_cpu_data_master_requests_TL_avalon_slave;
--synthesis translate_off
    --TL/avalon_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity TR_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal TR_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal TR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal TR_avalon_slave_read_n : OUT STD_LOGIC;
                 signal TR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TR_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal TR_avalon_slave_write_n : OUT STD_LOGIC;
                 signal TR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_granted_TR_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_TR_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_TR_avalon_slave : OUT STD_LOGIC;
                 signal d1_TR_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC
              );
end entity TR_avalon_slave_arbitrator;


architecture europa of TR_avalon_slave_arbitrator is
                signal TR_avalon_slave_allgrants :  STD_LOGIC;
                signal TR_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal TR_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal TR_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal TR_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal TR_avalon_slave_arb_share_counter :  STD_LOGIC;
                signal TR_avalon_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal TR_avalon_slave_arb_share_set_values :  STD_LOGIC;
                signal TR_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal TR_avalon_slave_begins_xfer :  STD_LOGIC;
                signal TR_avalon_slave_end_xfer :  STD_LOGIC;
                signal TR_avalon_slave_firsttransfer :  STD_LOGIC;
                signal TR_avalon_slave_grant_vector :  STD_LOGIC;
                signal TR_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal TR_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal TR_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal TR_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal TR_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal TR_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal TR_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal TR_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal TR_avalon_slave_waits_for_read :  STD_LOGIC;
                signal TR_avalon_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TR_avalon_slave_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_TR_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_TR_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_TR_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_TR_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_TR_avalon_slave :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register :  STD_LOGIC;
                signal shifted_address_to_TR_avalon_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_TR_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT TR_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  TR_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_TR_avalon_slave);
  --assign TR_avalon_slave_readdata_from_sa = TR_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  TR_avalon_slave_readdata_from_sa <= TR_avalon_slave_readdata;
  internal_cpu_data_master_requests_TR_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("000000001000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_TR_avalon_slave assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_TR_avalon_slave <= cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in;
  --TR_avalon_slave_arb_share_counter set values, which is an e_mux
  TR_avalon_slave_arb_share_set_values <= std_logic'('1');
  --TR_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  TR_avalon_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_TR_avalon_slave;
  --TR_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  TR_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --TR_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  TR_avalon_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(TR_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TR_avalon_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(TR_avalon_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TR_avalon_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --TR_avalon_slave_allgrants all slave grants, which is an e_mux
  TR_avalon_slave_allgrants <= TR_avalon_slave_grant_vector;
  --TR_avalon_slave_end_xfer assignment, which is an e_assign
  TR_avalon_slave_end_xfer <= NOT ((TR_avalon_slave_waits_for_read OR TR_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_TR_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_TR_avalon_slave <= TR_avalon_slave_end_xfer AND (((NOT TR_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --TR_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  TR_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_TR_avalon_slave AND TR_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_TR_avalon_slave AND NOT TR_avalon_slave_non_bursting_master_requests));
  --TR_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TR_avalon_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(TR_avalon_slave_arb_counter_enable) = '1' then 
        TR_avalon_slave_arb_share_counter <= TR_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --TR_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TR_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((TR_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_TR_avalon_slave)) OR ((end_xfer_arb_share_counter_term_TR_avalon_slave AND NOT TR_avalon_slave_non_bursting_master_requests)))) = '1' then 
        TR_avalon_slave_slavearbiterlockenable <= TR_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master TR/avalon_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= TR_avalon_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --TR_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  TR_avalon_slave_slavearbiterlockenable2 <= TR_avalon_slave_arb_share_counter_next_value;
  --cpu/data_master TR/avalon_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= TR_avalon_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --TR_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  TR_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_TR_avalon_slave <= internal_cpu_data_master_requests_TR_avalon_slave AND NOT ((((cpu_data_master_read AND (cpu_data_master_read_data_valid_TR_avalon_slave_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in <= ((internal_cpu_data_master_granted_TR_avalon_slave AND cpu_data_master_read) AND NOT TR_avalon_slave_waits_for_read) AND NOT (cpu_data_master_read_data_valid_TR_avalon_slave_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_TR_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_TR_avalon_slave_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in)));
  --cpu_data_master_read_data_valid_TR_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_TR_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_TR_avalon_slave_shift_register <= p1_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_TR_avalon_slave, which is an e_mux
  cpu_data_master_read_data_valid_TR_avalon_slave <= cpu_data_master_read_data_valid_TR_avalon_slave_shift_register;
  --TR_avalon_slave_writedata mux, which is an e_mux
  TR_avalon_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_TR_avalon_slave <= internal_cpu_data_master_qualified_request_TR_avalon_slave;
  --cpu/data_master saved-grant TR/avalon_slave, which is an e_assign
  cpu_data_master_saved_grant_TR_avalon_slave <= internal_cpu_data_master_requests_TR_avalon_slave;
  --allow new arb cycle for TR/avalon_slave, which is an e_assign
  TR_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  TR_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  TR_avalon_slave_master_qreq_vector <= std_logic'('1');
  --TR_avalon_slave_reset_n assignment, which is an e_assign
  TR_avalon_slave_reset_n <= reset_n;
  --TR_avalon_slave_firsttransfer first transaction, which is an e_assign
  TR_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(TR_avalon_slave_begins_xfer) = '1'), TR_avalon_slave_unreg_firsttransfer, TR_avalon_slave_reg_firsttransfer);
  --TR_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  TR_avalon_slave_unreg_firsttransfer <= NOT ((TR_avalon_slave_slavearbiterlockenable AND TR_avalon_slave_any_continuerequest));
  --TR_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TR_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(TR_avalon_slave_begins_xfer) = '1' then 
        TR_avalon_slave_reg_firsttransfer <= TR_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --TR_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  TR_avalon_slave_beginbursttransfer_internal <= TR_avalon_slave_begins_xfer;
  --~TR_avalon_slave_read_n assignment, which is an e_mux
  TR_avalon_slave_read_n <= NOT ((internal_cpu_data_master_granted_TR_avalon_slave AND cpu_data_master_read));
  --~TR_avalon_slave_write_n assignment, which is an e_mux
  TR_avalon_slave_write_n <= NOT ((internal_cpu_data_master_granted_TR_avalon_slave AND cpu_data_master_write));
  shifted_address_to_TR_avalon_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --TR_avalon_slave_address mux, which is an e_mux
  TR_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_TR_avalon_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
  --d1_TR_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_TR_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_TR_avalon_slave_end_xfer <= TR_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  --TR_avalon_slave_waits_for_read in a cycle, which is an e_mux
  TR_avalon_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TR_avalon_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TR_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  TR_avalon_slave_in_a_read_cycle <= internal_cpu_data_master_granted_TR_avalon_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= TR_avalon_slave_in_a_read_cycle;
  --TR_avalon_slave_waits_for_write in a cycle, which is an e_mux
  TR_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TR_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TR_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  TR_avalon_slave_in_a_write_cycle <= internal_cpu_data_master_granted_TR_avalon_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= TR_avalon_slave_in_a_write_cycle;
  wait_for_TR_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_TR_avalon_slave <= internal_cpu_data_master_granted_TR_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_TR_avalon_slave <= internal_cpu_data_master_qualified_request_TR_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_TR_avalon_slave <= internal_cpu_data_master_requests_TR_avalon_slave;
--synthesis translate_off
    --TR/avalon_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity control_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal control_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal control_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal control_avalon_slave_read_n : OUT STD_LOGIC;
                 signal control_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal control_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal control_avalon_slave_write_n : OUT STD_LOGIC;
                 signal control_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_granted_control_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_control_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_control_avalon_slave : OUT STD_LOGIC;
                 signal d1_control_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC
              );
end entity control_avalon_slave_arbitrator;


architecture europa of control_avalon_slave_arbitrator is
                signal control_avalon_slave_allgrants :  STD_LOGIC;
                signal control_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal control_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal control_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal control_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal control_avalon_slave_arb_share_counter :  STD_LOGIC;
                signal control_avalon_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal control_avalon_slave_arb_share_set_values :  STD_LOGIC;
                signal control_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal control_avalon_slave_begins_xfer :  STD_LOGIC;
                signal control_avalon_slave_end_xfer :  STD_LOGIC;
                signal control_avalon_slave_firsttransfer :  STD_LOGIC;
                signal control_avalon_slave_grant_vector :  STD_LOGIC;
                signal control_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal control_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal control_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal control_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal control_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal control_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal control_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal control_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal control_avalon_slave_waits_for_read :  STD_LOGIC;
                signal control_avalon_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_control_avalon_slave_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_control_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_control_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_control_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_control_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_control_avalon_slave :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_control_avalon_slave_shift_register :  STD_LOGIC;
                signal shifted_address_to_control_avalon_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_control_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT control_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  control_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_control_avalon_slave);
  --assign control_avalon_slave_readdata_from_sa = control_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  control_avalon_slave_readdata_from_sa <= control_avalon_slave_readdata;
  internal_cpu_data_master_requests_control_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("000000100000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_control_avalon_slave assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_control_avalon_slave <= cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in;
  --control_avalon_slave_arb_share_counter set values, which is an e_mux
  control_avalon_slave_arb_share_set_values <= std_logic'('1');
  --control_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  control_avalon_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_control_avalon_slave;
  --control_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  control_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --control_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  control_avalon_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(control_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(control_avalon_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(control_avalon_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(control_avalon_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --control_avalon_slave_allgrants all slave grants, which is an e_mux
  control_avalon_slave_allgrants <= control_avalon_slave_grant_vector;
  --control_avalon_slave_end_xfer assignment, which is an e_assign
  control_avalon_slave_end_xfer <= NOT ((control_avalon_slave_waits_for_read OR control_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_control_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_control_avalon_slave <= control_avalon_slave_end_xfer AND (((NOT control_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --control_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  control_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_control_avalon_slave AND control_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_control_avalon_slave AND NOT control_avalon_slave_non_bursting_master_requests));
  --control_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      control_avalon_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(control_avalon_slave_arb_counter_enable) = '1' then 
        control_avalon_slave_arb_share_counter <= control_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --control_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      control_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((control_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_control_avalon_slave)) OR ((end_xfer_arb_share_counter_term_control_avalon_slave AND NOT control_avalon_slave_non_bursting_master_requests)))) = '1' then 
        control_avalon_slave_slavearbiterlockenable <= control_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master control/avalon_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= control_avalon_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --control_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  control_avalon_slave_slavearbiterlockenable2 <= control_avalon_slave_arb_share_counter_next_value;
  --cpu/data_master control/avalon_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= control_avalon_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --control_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  control_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_control_avalon_slave <= internal_cpu_data_master_requests_control_avalon_slave AND NOT ((((cpu_data_master_read AND (cpu_data_master_read_data_valid_control_avalon_slave_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in <= ((internal_cpu_data_master_granted_control_avalon_slave AND cpu_data_master_read) AND NOT control_avalon_slave_waits_for_read) AND NOT (cpu_data_master_read_data_valid_control_avalon_slave_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_control_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_control_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_control_avalon_slave_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in)));
  --cpu_data_master_read_data_valid_control_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_control_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_control_avalon_slave_shift_register <= p1_cpu_data_master_read_data_valid_control_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_control_avalon_slave, which is an e_mux
  cpu_data_master_read_data_valid_control_avalon_slave <= cpu_data_master_read_data_valid_control_avalon_slave_shift_register;
  --control_avalon_slave_writedata mux, which is an e_mux
  control_avalon_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_control_avalon_slave <= internal_cpu_data_master_qualified_request_control_avalon_slave;
  --cpu/data_master saved-grant control/avalon_slave, which is an e_assign
  cpu_data_master_saved_grant_control_avalon_slave <= internal_cpu_data_master_requests_control_avalon_slave;
  --allow new arb cycle for control/avalon_slave, which is an e_assign
  control_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  control_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  control_avalon_slave_master_qreq_vector <= std_logic'('1');
  --control_avalon_slave_reset_n assignment, which is an e_assign
  control_avalon_slave_reset_n <= reset_n;
  --control_avalon_slave_firsttransfer first transaction, which is an e_assign
  control_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(control_avalon_slave_begins_xfer) = '1'), control_avalon_slave_unreg_firsttransfer, control_avalon_slave_reg_firsttransfer);
  --control_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  control_avalon_slave_unreg_firsttransfer <= NOT ((control_avalon_slave_slavearbiterlockenable AND control_avalon_slave_any_continuerequest));
  --control_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      control_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(control_avalon_slave_begins_xfer) = '1' then 
        control_avalon_slave_reg_firsttransfer <= control_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --control_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  control_avalon_slave_beginbursttransfer_internal <= control_avalon_slave_begins_xfer;
  --~control_avalon_slave_read_n assignment, which is an e_mux
  control_avalon_slave_read_n <= NOT ((internal_cpu_data_master_granted_control_avalon_slave AND cpu_data_master_read));
  --~control_avalon_slave_write_n assignment, which is an e_mux
  control_avalon_slave_write_n <= NOT ((internal_cpu_data_master_granted_control_avalon_slave AND cpu_data_master_write));
  shifted_address_to_control_avalon_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --control_avalon_slave_address mux, which is an e_mux
  control_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_control_avalon_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
  --d1_control_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_control_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_control_avalon_slave_end_xfer <= control_avalon_slave_end_xfer;
      end if;
    end if;

  end process;

  --control_avalon_slave_waits_for_read in a cycle, which is an e_mux
  control_avalon_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(control_avalon_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --control_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  control_avalon_slave_in_a_read_cycle <= internal_cpu_data_master_granted_control_avalon_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= control_avalon_slave_in_a_read_cycle;
  --control_avalon_slave_waits_for_write in a cycle, which is an e_mux
  control_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(control_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --control_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  control_avalon_slave_in_a_write_cycle <= internal_cpu_data_master_granted_control_avalon_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= control_avalon_slave_in_a_write_cycle;
  wait_for_control_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_control_avalon_slave <= internal_cpu_data_master_granted_control_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_control_avalon_slave <= internal_cpu_data_master_qualified_request_control_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_control_avalon_slave <= internal_cpu_data_master_requests_control_avalon_slave;
--synthesis translate_off
    --control/avalon_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_debugaccess : IN STD_LOGIC;
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_jtag_debug_module_reset : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_write : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
              );
end entity cpu_jtag_debug_module_arbitrator;


architecture europa of cpu_jtag_debug_module_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_jtag_debug_module_allgrants :  STD_LOGIC;
                signal cpu_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal cpu_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_share_counter :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_share_set_values :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal cpu_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal cpu_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal cpu_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal cpu_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal cpu_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal cpu_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_cpu_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_data_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module :  STD_LOGIC;
                signal shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_cpu_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT cpu_jtag_debug_module_end_xfer;
      end if;
    end if;

  end process;

  cpu_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_data_master_qualified_request_cpu_jtag_debug_module OR internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module));
  --assign cpu_jtag_debug_module_readdata_from_sa = cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_jtag_debug_module_readdata_from_sa <= cpu_jtag_debug_module_readdata;
  internal_cpu_data_master_requests_cpu_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("000000101000100100000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  cpu_jtag_debug_module_arb_share_set_values <= std_logic'('1');
  --cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  cpu_jtag_debug_module_non_bursting_master_requests <= ((internal_cpu_data_master_requests_cpu_jtag_debug_module OR internal_cpu_instruction_master_requests_cpu_jtag_debug_module) OR internal_cpu_data_master_requests_cpu_jtag_debug_module) OR internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  cpu_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  cpu_jtag_debug_module_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  cpu_jtag_debug_module_allgrants <= ((or_reduce(cpu_jtag_debug_module_grant_vector) OR or_reduce(cpu_jtag_debug_module_grant_vector)) OR or_reduce(cpu_jtag_debug_module_grant_vector)) OR or_reduce(cpu_jtag_debug_module_grant_vector);
  --cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  cpu_jtag_debug_module_end_xfer <= NOT ((cpu_jtag_debug_module_waits_for_read OR cpu_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_cpu_jtag_debug_module <= cpu_jtag_debug_module_end_xfer AND (((NOT cpu_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  cpu_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND cpu_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND NOT cpu_jtag_debug_module_non_bursting_master_requests));
  --cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_arb_counter_enable) = '1' then 
        cpu_jtag_debug_module_arb_share_counter <= cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(cpu_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_cpu_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND NOT cpu_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        cpu_jtag_debug_module_slavearbiterlockenable <= cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= cpu_jtag_debug_module_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  cpu_jtag_debug_module_slavearbiterlockenable2 <= cpu_jtag_debug_module_arb_share_counter_next_value;
  --cpu/data_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= cpu_jtag_debug_module_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --cpu/instruction_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= cpu_jtag_debug_module_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= cpu_jtag_debug_module_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master granted cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_instruction_master_saved_grant_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_instruction_master_requests_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module))))));
      end if;
    end if;

  end process;

  --cpu_instruction_master_continuerequest continued request, which is an e_mux
  cpu_instruction_master_continuerequest <= last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module AND internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  cpu_jtag_debug_module_any_continuerequest <= cpu_instruction_master_continuerequest OR cpu_data_master_continuerequest;
  internal_cpu_data_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_data_master_requests_cpu_jtag_debug_module AND NOT (((((NOT cpu_data_master_waitrequest) AND cpu_data_master_write)) OR cpu_instruction_master_arbiterlock));
  --cpu_jtag_debug_module_writedata mux, which is an e_mux
  cpu_jtag_debug_module_writedata <= cpu_data_master_writedata;
  internal_cpu_instruction_master_requests_cpu_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(26 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("000000101000100100000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --cpu/data_master granted cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_data_master_saved_grant_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_data_master_requests_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module))))));
      end if;
    end if;

  end process;

  --cpu_data_master_continuerequest continued request, which is an e_mux
  cpu_data_master_continuerequest <= last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module AND internal_cpu_data_master_requests_cpu_jtag_debug_module;
  internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_instruction_master_requests_cpu_jtag_debug_module AND NOT ((((cpu_instruction_master_read AND ((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))) OR (cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register))))) OR cpu_data_master_arbiterlock));
  --local readdatavalid cpu_instruction_master_read_data_valid_cpu_jtag_debug_module, which is an e_mux
  cpu_instruction_master_read_data_valid_cpu_jtag_debug_module <= (internal_cpu_instruction_master_granted_cpu_jtag_debug_module AND cpu_instruction_master_read) AND NOT cpu_jtag_debug_module_waits_for_read;
  --allow new arb cycle for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_allow_new_arb_cycle <= NOT cpu_data_master_arbiterlock AND NOT cpu_instruction_master_arbiterlock;
  --cpu/instruction_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_master_qreq_vector(0) <= internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  --cpu/instruction_master grant cpu/jtag_debug_module, which is an e_assign
  internal_cpu_instruction_master_granted_cpu_jtag_debug_module <= cpu_jtag_debug_module_grant_vector(0);
  --cpu/instruction_master saved-grant cpu/jtag_debug_module, which is an e_assign
  cpu_instruction_master_saved_grant_cpu_jtag_debug_module <= cpu_jtag_debug_module_arb_winner(0) AND internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu/data_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_master_qreq_vector(1) <= internal_cpu_data_master_qualified_request_cpu_jtag_debug_module;
  --cpu/data_master grant cpu/jtag_debug_module, which is an e_assign
  internal_cpu_data_master_granted_cpu_jtag_debug_module <= cpu_jtag_debug_module_grant_vector(1);
  --cpu/data_master saved-grant cpu/jtag_debug_module, which is an e_assign
  cpu_data_master_saved_grant_cpu_jtag_debug_module <= cpu_jtag_debug_module_arb_winner(1) AND internal_cpu_data_master_requests_cpu_jtag_debug_module;
  --cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  cpu_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((cpu_jtag_debug_module_master_qreq_vector & cpu_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT cpu_jtag_debug_module_master_qreq_vector & NOT cpu_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (cpu_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  cpu_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_allow_new_arb_cycle AND or_reduce(cpu_jtag_debug_module_grant_vector)))) = '1'), cpu_jtag_debug_module_grant_vector, cpu_jtag_debug_module_saved_chosen_master_vector);
  --saved cpu_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        cpu_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(cpu_jtag_debug_module_grant_vector)) = '1'), cpu_jtag_debug_module_grant_vector, cpu_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  cpu_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((cpu_jtag_debug_module_chosen_master_double_vector(1) OR cpu_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((cpu_jtag_debug_module_chosen_master_double_vector(0) OR cpu_jtag_debug_module_chosen_master_double_vector(2)))));
  --cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  cpu_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --cpu/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(cpu_jtag_debug_module_grant_vector)) = '1' then 
        cpu_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_end_xfer) = '1'), cpu_jtag_debug_module_chosen_master_rot_left, cpu_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  cpu_jtag_debug_module_begintransfer <= cpu_jtag_debug_module_begins_xfer;
  --assign lhs ~cpu_jtag_debug_module_reset of type reset_n to cpu_jtag_debug_module_reset_n, which is an e_assign
  cpu_jtag_debug_module_reset <= NOT internal_cpu_jtag_debug_module_reset_n;
  --cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  internal_cpu_jtag_debug_module_reset_n <= reset_n;
  --assign cpu_jtag_debug_module_resetrequest_from_sa = cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_jtag_debug_module_resetrequest_from_sa <= cpu_jtag_debug_module_resetrequest;
  cpu_jtag_debug_module_chipselect <= internal_cpu_data_master_granted_cpu_jtag_debug_module OR internal_cpu_instruction_master_granted_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  cpu_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(cpu_jtag_debug_module_begins_xfer) = '1'), cpu_jtag_debug_module_unreg_firsttransfer, cpu_jtag_debug_module_reg_firsttransfer);
  --cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  cpu_jtag_debug_module_unreg_firsttransfer <= NOT ((cpu_jtag_debug_module_slavearbiterlockenable AND cpu_jtag_debug_module_any_continuerequest));
  --cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_begins_xfer) = '1' then 
        cpu_jtag_debug_module_reg_firsttransfer <= cpu_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  cpu_jtag_debug_module_beginbursttransfer_internal <= cpu_jtag_debug_module_begins_xfer;
  --cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  cpu_jtag_debug_module_arbitration_holdoff_internal <= cpu_jtag_debug_module_begins_xfer AND cpu_jtag_debug_module_firsttransfer;
  --cpu_jtag_debug_module_write assignment, which is an e_mux
  cpu_jtag_debug_module_write <= internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_write;
  shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --cpu_jtag_debug_module_address mux, which is an e_mux
  cpu_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
  shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master <= cpu_instruction_master_address_to_slave;
  --d1_cpu_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_cpu_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_cpu_jtag_debug_module_end_xfer <= cpu_jtag_debug_module_end_xfer;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  cpu_jtag_debug_module_waits_for_read <= cpu_jtag_debug_module_in_a_read_cycle AND cpu_jtag_debug_module_begins_xfer;
  --cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  cpu_jtag_debug_module_in_a_read_cycle <= ((internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_read)) OR ((internal_cpu_instruction_master_granted_cpu_jtag_debug_module AND cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= cpu_jtag_debug_module_in_a_read_cycle;
  --cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  cpu_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  cpu_jtag_debug_module_in_a_write_cycle <= internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= cpu_jtag_debug_module_in_a_write_cycle;
  wait_for_cpu_jtag_debug_module_counter <= std_logic'('0');
  --cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  cpu_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  cpu_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  cpu_data_master_granted_cpu_jtag_debug_module <= internal_cpu_data_master_granted_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_data_master_qualified_request_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_data_master_requests_cpu_jtag_debug_module <= internal_cpu_data_master_requests_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_cpu_jtag_debug_module <= internal_cpu_instruction_master_granted_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_cpu_jtag_debug_module <= internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_jtag_debug_module_reset_n <= internal_cpu_jtag_debug_module_reset_n;
--synthesis translate_off
    --cpu/jtag_debug_module enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_data_master_granted_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_granted_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_data_master_saved_grant_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_saved_grant_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dm9000a_avalon_slave_0_irq_from_sa_clock_crossing_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity dm9000a_avalon_slave_0_irq_from_sa_clock_crossing_cpu_data_master_module;


architecture europa of dm9000a_avalon_slave_0_irq_from_sa_clock_crossing_cpu_data_master_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_out <= data_in_d1;
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cpu_data_master_arbitrator is 
        port (
              -- inputs:
                 signal BL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal BR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal clk100 : IN STD_LOGIC;
                 signal clk100_reset_n : IN STD_LOGIC;
                 signal control_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_granted_BL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_BR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_TL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_TR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_control_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_granted_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_frame_received_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_laser_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_ranger_cpu_clock_0_in : IN STD_LOGIC;
                 signal cpu_data_master_granted_ranger_cpu_clock_2_in : IN STD_LOGIC;
                 signal cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_timer_1ms_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_BL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_BR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_TL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_TR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_control_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_frame_received_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_laser_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_ranger_cpu_clock_0_in : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_ranger_cpu_clock_2_in : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_timer_1ms_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_frame_received_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_laser_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ranger_cpu_clock_0_in : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ranger_cpu_clock_2_in : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_timer_1ms_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_BL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_BR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_TL_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_TR_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_control_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_requests_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_frame_received_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_laser_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_ranger_cpu_clock_0_in : IN STD_LOGIC;
                 signal cpu_data_master_requests_ranger_cpu_clock_2_in : IN STD_LOGIC;
                 signal cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_timer_1ms_s1 : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_BL_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_BR_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_TL_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_TR_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_control_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_ddr2_deva_s1_end_xfer : IN STD_LOGIC;
                 signal d1_frame_received_s1_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_laser_uart_s1_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                 signal d1_ranger_cpu_clock_0_in_end_xfer : IN STD_LOGIC;
                 signal d1_ranger_cpu_clock_2_in_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal d1_timer_1ms_s1_end_xfer : IN STD_LOGIC;
                 signal ddr2_deva_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_deva_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal dm9000a_avalon_slave_0_irq_from_sa : IN STD_LOGIC;
                 signal frame_received_s1_irq_from_sa : IN STD_LOGIC;
                 signal frame_received_s1_readdata_from_sa : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal laser_uart_s1_irq_from_sa : IN STD_LOGIC;
                 signal laser_uart_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ranger_cpu_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_2_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal timer_1ms_s1_irq_from_sa : IN STD_LOGIC;
                 signal timer_1ms_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_data_master_arbitrator;


architecture europa of cpu_data_master_arbitrator is
component dm9000a_avalon_slave_0_irq_from_sa_clock_crossing_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component dm9000a_avalon_slave_0_irq_from_sa_clock_crossing_cpu_data_master_module;

                signal clk100_dm9000a_avalon_slave_0_irq_from_sa :  STD_LOGIC;
                signal cpu_data_master_run :  STD_LOGIC;
                signal internal_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal internal_cpu_data_master_waitrequest :  STD_LOGIC;
                signal p1_registered_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal r_3 :  STD_LOGIC;
                signal registered_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_BL_avalon_slave OR registered_cpu_data_master_read_data_valid_BL_avalon_slave) OR NOT cpu_data_master_requests_BL_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_BL_avalon_slave OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_BL_avalon_slave AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_BL_avalon_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_BR_avalon_slave OR registered_cpu_data_master_read_data_valid_BR_avalon_slave) OR NOT cpu_data_master_requests_BR_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_BR_avalon_slave OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_BR_avalon_slave AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_BR_avalon_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_TL_avalon_slave OR registered_cpu_data_master_read_data_valid_TL_avalon_slave) OR NOT cpu_data_master_requests_TL_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_TL_avalon_slave OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_TL_avalon_slave AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_TL_avalon_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_TR_avalon_slave OR registered_cpu_data_master_read_data_valid_TR_avalon_slave) OR NOT cpu_data_master_requests_TR_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_TR_avalon_slave OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_TR_avalon_slave AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_TR_avalon_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_control_avalon_slave OR registered_cpu_data_master_read_data_valid_control_avalon_slave) OR NOT cpu_data_master_requests_control_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_control_avalon_slave OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_control_avalon_slave AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_control_avalon_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_data_master_run <= ((r_0 AND r_1) AND r_2) AND r_3;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_requests_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_granted_cpu_jtag_debug_module OR NOT cpu_data_master_qualified_request_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_ddr2_deva_s1 OR cpu_data_master_read_data_valid_ddr2_deva_s1) OR NOT cpu_data_master_requests_ddr2_deva_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_granted_ddr2_deva_s1 OR NOT cpu_data_master_qualified_request_ddr2_deva_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_ddr2_deva_s1 OR NOT cpu_data_master_read) OR ((cpu_data_master_read_data_valid_ddr2_deva_s1 AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_ddr2_deva_s1 OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_deva_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_frame_received_s1 OR NOT cpu_data_master_requests_frame_received_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_frame_received_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_frame_received_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_laser_uart_s1 OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic(((((((((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_laser_uart_s1 OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_onchip_mem_s1 OR registered_cpu_data_master_read_data_valid_onchip_mem_s1) OR NOT cpu_data_master_requests_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_granted_onchip_mem_s1 OR NOT cpu_data_master_qualified_request_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_onchip_mem_s1 OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_onchip_mem_s1 AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_onchip_mem_s1 OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_ranger_cpu_clock_0_in OR NOT cpu_data_master_requests_ranger_cpu_clock_0_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_ranger_cpu_clock_0_in OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ranger_cpu_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_ranger_cpu_clock_0_in OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ranger_cpu_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_ranger_cpu_clock_2_in OR NOT cpu_data_master_requests_ranger_cpu_clock_2_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_ranger_cpu_clock_2_in OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ranger_cpu_clock_2_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_ranger_cpu_clock_2_in OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ranger_cpu_clock_2_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_sysid_control_slave OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_sysid_control_slave OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_timer_1ms_s1 OR NOT cpu_data_master_requests_timer_1ms_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_timer_1ms_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))));
  --r_3 master_run cascaded wait assignment, which is an e_assign
  r_3 <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_timer_1ms_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_data_master_address_to_slave <= cpu_data_master_address(26 DOWNTO 0);
  --cpu/data_master readdata mux, which is an e_mux
  cpu_data_master_readdata <= (((((((((((((((A_REP(NOT cpu_data_master_requests_BL_avalon_slave, 32) OR BL_avalon_slave_readdata_from_sa)) AND ((A_REP(NOT cpu_data_master_requests_BR_avalon_slave, 32) OR BR_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_TL_avalon_slave, 32) OR TL_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_TR_avalon_slave, 32) OR TR_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_control_avalon_slave, 32) OR control_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_cpu_jtag_debug_module, 32) OR cpu_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_ddr2_deva_s1, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_frame_received_s1, 32) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(frame_received_s1_readdata_from_sa)))))) AND ((A_REP(NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_laser_uart_s1, 32) OR (std_logic_vector'("0000000000000000") & (laser_uart_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_data_master_requests_onchip_mem_s1, 32) OR onchip_mem_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_ranger_cpu_clock_0_in, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_ranger_cpu_clock_2_in, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_sysid_control_slave, 32) OR sysid_control_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_timer_1ms_s1, 32) OR (std_logic_vector'("0000000000000000") & (timer_1ms_s1_readdata_from_sa))));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        internal_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((cpu_data_master_read OR cpu_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_run AND internal_cpu_data_master_waitrequest))))))));
      end if;
    end if;

  end process;

  --unpredictable registered wait state incoming data, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      registered_cpu_data_master_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        registered_cpu_data_master_readdata <= p1_registered_cpu_data_master_readdata;
      end if;
    end if;

  end process;

  --registered readdata mux, which is an e_mux
  p1_registered_cpu_data_master_readdata <= ((((A_REP(NOT cpu_data_master_requests_ddr2_deva_s1, 32) OR ddr2_deva_s1_readdata_from_sa)) AND ((A_REP(NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR jtag_uart_avalon_jtag_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_ranger_cpu_clock_0_in, 32) OR (std_logic_vector'("0000000000000000") & (ranger_cpu_clock_0_in_readdata_from_sa))))) AND ((A_REP(NOT cpu_data_master_requests_ranger_cpu_clock_2_in, 32) OR ranger_cpu_clock_2_in_readdata_from_sa));
  --dm9000a_avalon_slave_0_irq_from_sa from clk50 to clk100
  dm9000a_avalon_slave_0_irq_from_sa_clock_crossing_cpu_data_master : dm9000a_avalon_slave_0_irq_from_sa_clock_crossing_cpu_data_master_module
    port map(
      data_out => clk100_dm9000a_avalon_slave_0_irq_from_sa,
      clk => clk100,
      data_in => dm9000a_avalon_slave_0_irq_from_sa,
      reset_n => clk100_reset_n
    );


  --irq assign, which is an e_assign
  cpu_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(laser_uart_s1_irq_from_sa) & A_ToStdLogicVector(clk100_dm9000a_avalon_slave_0_irq_from_sa) & A_ToStdLogicVector(jtag_uart_avalon_jtag_slave_irq_from_sa) & A_ToStdLogicVector(timer_1ms_s1_irq_from_sa) & A_ToStdLogicVector(frame_received_s1_irq_from_sa));
  --vhdl renameroo for output signals
  cpu_data_master_address_to_slave <= internal_cpu_data_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_data_master_waitrequest <= internal_cpu_data_master_waitrequest;

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_instruction_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_granted_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_granted_ranger_cpu_clock_1_in : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_ddr2_deva_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_ranger_cpu_clock_1_in : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_ddr2_deva_s1_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                 signal d1_ranger_cpu_clock_1_in_end_xfer : IN STD_LOGIC;
                 signal ddr2_deva_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_deva_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : OUT STD_LOGIC;
                 signal cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal cpu_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_instruction_master_arbitrator;


architecture europa of cpu_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal cpu_instruction_master_address_last_time :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal cpu_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal cpu_instruction_master_read_last_time :  STD_LOGIC;
                signal cpu_instruction_master_run :  STD_LOGIC;
                signal internal_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal internal_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal internal_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal pre_flush_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_instruction_master_requests_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_granted_cpu_jtag_debug_module OR NOT cpu_instruction_master_qualified_request_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_cpu_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_qualified_request_ddr2_deva_s1 OR NOT cpu_instruction_master_requests_ddr2_deva_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_granted_ddr2_deva_s1 OR NOT cpu_instruction_master_qualified_request_ddr2_deva_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_ddr2_deva_s1 OR NOT cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_deva_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_read)))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_instruction_master_run <= r_1 AND r_2;
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic(((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_qualified_request_onchip_mem_s1 OR NOT cpu_instruction_master_requests_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_granted_onchip_mem_s1 OR NOT cpu_instruction_master_qualified_request_onchip_mem_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_onchip_mem_s1 OR NOT cpu_instruction_master_read)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in OR NOT cpu_instruction_master_requests_ranger_cpu_clock_1_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in OR NOT (cpu_instruction_master_read))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ranger_cpu_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_instruction_master_read))))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_instruction_master_address_to_slave <= cpu_instruction_master_address(26 DOWNTO 0);
  --cpu_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_instruction_master_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_instruction_master_read_but_no_slave_selected <= (cpu_instruction_master_read AND cpu_instruction_master_run) AND NOT cpu_instruction_master_is_granted_some_slave;
      end if;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  cpu_instruction_master_is_granted_some_slave <= ((cpu_instruction_master_granted_cpu_jtag_debug_module OR cpu_instruction_master_granted_ddr2_deva_s1) OR cpu_instruction_master_granted_onchip_mem_s1) OR cpu_instruction_master_granted_ranger_cpu_clock_1_in;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_cpu_instruction_master_readdatavalid <= cpu_instruction_master_read_data_valid_ddr2_deva_s1 OR cpu_instruction_master_read_data_valid_onchip_mem_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  cpu_instruction_master_readdatavalid <= ((((((((cpu_instruction_master_read_but_no_slave_selected OR pre_flush_cpu_instruction_master_readdatavalid) OR cpu_instruction_master_read_data_valid_cpu_jtag_debug_module) OR cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_cpu_instruction_master_readdatavalid) OR cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_cpu_instruction_master_readdatavalid) OR cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_cpu_instruction_master_readdatavalid) OR cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in;
  --cpu/instruction_master readdata mux, which is an e_mux
  cpu_instruction_master_readdata <= ((((A_REP(NOT ((cpu_instruction_master_qualified_request_cpu_jtag_debug_module AND cpu_instruction_master_read)) , 32) OR cpu_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT cpu_instruction_master_read_data_valid_ddr2_deva_s1, 32) OR ddr2_deva_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_instruction_master_read_data_valid_onchip_mem_s1, 32) OR onchip_mem_s1_readdata_from_sa))) AND ((A_REP(NOT ((cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in AND cpu_instruction_master_read)) , 32) OR ranger_cpu_clock_1_in_readdata_from_sa));
  --actual waitrequest port, which is an e_assign
  internal_cpu_instruction_master_waitrequest <= NOT cpu_instruction_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_instruction_master_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        internal_cpu_instruction_master_latency_counter <= p1_cpu_instruction_master_latency_counter;
      end if;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_cpu_instruction_master_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((cpu_instruction_master_run AND cpu_instruction_master_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_cpu_instruction_master_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_requests_onchip_mem_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
  --vhdl renameroo for output signals
  cpu_instruction_master_address_to_slave <= internal_cpu_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_instruction_master_latency_counter <= internal_cpu_instruction_master_latency_counter;
  --vhdl renameroo for output signals
  cpu_instruction_master_waitrequest <= internal_cpu_instruction_master_waitrequest;
--synthesis translate_off
    --cpu_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_instruction_master_address_last_time <= std_logic_vector'("000000000000000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_instruction_master_address_last_time <= cpu_instruction_master_address;
        end if;
      end if;

    end process;

    --cpu/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          active_and_waiting_last_time <= internal_cpu_instruction_master_waitrequest AND (cpu_instruction_master_read);
        end if;
      end if;

    end process;

    --cpu_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_instruction_master_address /= cpu_instruction_master_address_last_time))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("cpu_instruction_master_address did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_instruction_master_read_last_time <= cpu_instruction_master_read;
        end if;
      end if;

    end process;

    --cpu_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_instruction_master_read) /= std_logic'(cpu_instruction_master_read_last_time)))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("cpu_instruction_master_read did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1_module;


architecture europa of rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1_module;


architecture europa of rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity ddr2_deva_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal ddr2_deva_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_deva_s1_readdatavalid : IN STD_LOGIC;
                 signal ddr2_deva_s1_resetrequest_n : IN STD_LOGIC;
                 signal ddr2_deva_s1_waitrequest_n : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register : OUT STD_LOGIC;
                 signal cpu_data_master_requests_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_granted_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_ddr2_deva_s1 : OUT STD_LOGIC;
                 signal d1_ddr2_deva_s1_end_xfer : OUT STD_LOGIC;
                 signal ddr2_deva_s1_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ddr2_deva_s1_beginbursttransfer : OUT STD_LOGIC;
                 signal ddr2_deva_s1_burstcount : OUT STD_LOGIC;
                 signal ddr2_deva_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ddr2_deva_s1_read : OUT STD_LOGIC;
                 signal ddr2_deva_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_deva_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                 signal ddr2_deva_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                 signal ddr2_deva_s1_write : OUT STD_LOGIC;
                 signal ddr2_deva_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity ddr2_deva_s1_arbitrator;


architecture europa of ddr2_deva_s1_arbitrator is
component rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1_module;

component rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1_module;

                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_rdv_fifo_empty_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_data_master_rdv_fifo_output_from_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_data_master_saved_grant_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_rdv_fifo_empty_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_instruction_master_rdv_fifo_output_from_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_ddr2_deva_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal ddr2_deva_s1_allgrants :  STD_LOGIC;
                signal ddr2_deva_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal ddr2_deva_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ddr2_deva_s1_any_continuerequest :  STD_LOGIC;
                signal ddr2_deva_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_deva_s1_arb_counter_enable :  STD_LOGIC;
                signal ddr2_deva_s1_arb_share_counter :  STD_LOGIC;
                signal ddr2_deva_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal ddr2_deva_s1_arb_share_set_values :  STD_LOGIC;
                signal ddr2_deva_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_deva_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal ddr2_deva_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal ddr2_deva_s1_begins_xfer :  STD_LOGIC;
                signal ddr2_deva_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ddr2_deva_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_deva_s1_end_xfer :  STD_LOGIC;
                signal ddr2_deva_s1_firsttransfer :  STD_LOGIC;
                signal ddr2_deva_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_deva_s1_in_a_read_cycle :  STD_LOGIC;
                signal ddr2_deva_s1_in_a_write_cycle :  STD_LOGIC;
                signal ddr2_deva_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_deva_s1_move_on_to_next_transaction :  STD_LOGIC;
                signal ddr2_deva_s1_non_bursting_master_requests :  STD_LOGIC;
                signal ddr2_deva_s1_readdatavalid_from_sa :  STD_LOGIC;
                signal ddr2_deva_s1_reg_firsttransfer :  STD_LOGIC;
                signal ddr2_deva_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_deva_s1_slavearbiterlockenable :  STD_LOGIC;
                signal ddr2_deva_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal ddr2_deva_s1_unreg_firsttransfer :  STD_LOGIC;
                signal ddr2_deva_s1_waits_for_read :  STD_LOGIC;
                signal ddr2_deva_s1_waits_for_write :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ddr2_deva_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_ddr2_deva_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_ddr2_deva_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register :  STD_LOGIC;
                signal internal_cpu_data_master_requests_ddr2_deva_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_ddr2_deva_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_ddr2_deva_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_ddr2_deva_s1 :  STD_LOGIC;
                signal internal_ddr2_deva_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal last_cycle_cpu_data_master_granted_slave_ddr2_deva_s1 :  STD_LOGIC;
                signal last_cycle_cpu_instruction_master_granted_slave_ddr2_deva_s1 :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal module_input2 :  STD_LOGIC;
                signal module_input3 :  STD_LOGIC;
                signal module_input4 :  STD_LOGIC;
                signal module_input5 :  STD_LOGIC;
                signal shifted_address_to_ddr2_deva_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal shifted_address_to_ddr2_deva_s1_from_cpu_instruction_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_ddr2_deva_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT ddr2_deva_s1_end_xfer;
      end if;
    end if;

  end process;

  ddr2_deva_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_data_master_qualified_request_ddr2_deva_s1 OR internal_cpu_instruction_master_qualified_request_ddr2_deva_s1));
  --assign ddr2_deva_s1_readdatavalid_from_sa = ddr2_deva_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  ddr2_deva_s1_readdatavalid_from_sa <= ddr2_deva_s1_readdatavalid;
  --assign ddr2_deva_s1_readdata_from_sa = ddr2_deva_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ddr2_deva_s1_readdata_from_sa <= ddr2_deva_s1_readdata;
  internal_cpu_data_master_requests_ddr2_deva_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 25) & std_logic_vector'("0000000000000000000000000")) = std_logic_vector'("100000000000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign ddr2_deva_s1_waitrequest_n_from_sa = ddr2_deva_s1_waitrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_ddr2_deva_s1_waitrequest_n_from_sa <= ddr2_deva_s1_waitrequest_n;
  --ddr2_deva_s1_arb_share_counter set values, which is an e_mux
  ddr2_deva_s1_arb_share_set_values <= std_logic'('1');
  --ddr2_deva_s1_non_bursting_master_requests mux, which is an e_mux
  ddr2_deva_s1_non_bursting_master_requests <= ((internal_cpu_data_master_requests_ddr2_deva_s1 OR internal_cpu_instruction_master_requests_ddr2_deva_s1) OR internal_cpu_data_master_requests_ddr2_deva_s1) OR internal_cpu_instruction_master_requests_ddr2_deva_s1;
  --ddr2_deva_s1_any_bursting_master_saved_grant mux, which is an e_mux
  ddr2_deva_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --ddr2_deva_s1_arb_share_counter_next_value assignment, which is an e_assign
  ddr2_deva_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ddr2_deva_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_deva_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ddr2_deva_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_deva_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ddr2_deva_s1_allgrants all slave grants, which is an e_mux
  ddr2_deva_s1_allgrants <= ((or_reduce(ddr2_deva_s1_grant_vector) OR or_reduce(ddr2_deva_s1_grant_vector)) OR or_reduce(ddr2_deva_s1_grant_vector)) OR or_reduce(ddr2_deva_s1_grant_vector);
  --ddr2_deva_s1_end_xfer assignment, which is an e_assign
  ddr2_deva_s1_end_xfer <= NOT ((ddr2_deva_s1_waits_for_read OR ddr2_deva_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_ddr2_deva_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ddr2_deva_s1 <= ddr2_deva_s1_end_xfer AND (((NOT ddr2_deva_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ddr2_deva_s1_arb_share_counter arbitration counter enable, which is an e_assign
  ddr2_deva_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ddr2_deva_s1 AND ddr2_deva_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_ddr2_deva_s1 AND NOT ddr2_deva_s1_non_bursting_master_requests));
  --ddr2_deva_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_deva_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ddr2_deva_s1_arb_counter_enable) = '1' then 
        ddr2_deva_s1_arb_share_counter <= ddr2_deva_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ddr2_deva_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_deva_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(ddr2_deva_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_ddr2_deva_s1)) OR ((end_xfer_arb_share_counter_term_ddr2_deva_s1 AND NOT ddr2_deva_s1_non_bursting_master_requests)))) = '1' then 
        ddr2_deva_s1_slavearbiterlockenable <= ddr2_deva_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master ddr2_deva/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= ddr2_deva_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --ddr2_deva_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ddr2_deva_s1_slavearbiterlockenable2 <= ddr2_deva_s1_arb_share_counter_next_value;
  --cpu/data_master ddr2_deva/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= ddr2_deva_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --cpu/instruction_master ddr2_deva/s1 arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= ddr2_deva_s1_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master ddr2_deva/s1 arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= ddr2_deva_s1_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master granted ddr2_deva/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_instruction_master_granted_slave_ddr2_deva_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_instruction_master_granted_slave_ddr2_deva_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_instruction_master_saved_grant_ddr2_deva_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ddr2_deva_s1_arbitration_holdoff_internal OR NOT internal_cpu_instruction_master_requests_ddr2_deva_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_instruction_master_granted_slave_ddr2_deva_s1))))));
      end if;
    end if;

  end process;

  --cpu_instruction_master_continuerequest continued request, which is an e_mux
  cpu_instruction_master_continuerequest <= last_cycle_cpu_instruction_master_granted_slave_ddr2_deva_s1 AND internal_cpu_instruction_master_requests_ddr2_deva_s1;
  --ddr2_deva_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  ddr2_deva_s1_any_continuerequest <= cpu_instruction_master_continuerequest OR cpu_data_master_continuerequest;
  internal_cpu_data_master_qualified_request_ddr2_deva_s1 <= internal_cpu_data_master_requests_ddr2_deva_s1 AND NOT (((((cpu_data_master_read AND ((NOT cpu_data_master_waitrequest OR (internal_cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register))))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))) OR cpu_instruction_master_arbiterlock));
  --unique name for ddr2_deva_s1_move_on_to_next_transaction, which is an e_assign
  ddr2_deva_s1_move_on_to_next_transaction <= ddr2_deva_s1_readdatavalid_from_sa;
  --rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1 : rdv_fifo_for_cpu_data_master_to_ddr2_deva_s1_module
    port map(
      data_out => cpu_data_master_rdv_fifo_output_from_ddr2_deva_s1,
      empty => open,
      fifo_contains_ones_n => cpu_data_master_rdv_fifo_empty_ddr2_deva_s1,
      full => open,
      clear_fifo => module_input,
      clk => clk,
      data_in => internal_cpu_data_master_granted_ddr2_deva_s1,
      read => ddr2_deva_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input1,
      write => module_input2
    );

  module_input <= std_logic'('0');
  module_input1 <= std_logic'('0');
  module_input2 <= in_a_read_cycle AND NOT ddr2_deva_s1_waits_for_read;

  internal_cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register <= NOT cpu_data_master_rdv_fifo_empty_ddr2_deva_s1;
  --local readdatavalid cpu_data_master_read_data_valid_ddr2_deva_s1, which is an e_mux
  cpu_data_master_read_data_valid_ddr2_deva_s1 <= ((ddr2_deva_s1_readdatavalid_from_sa AND cpu_data_master_rdv_fifo_output_from_ddr2_deva_s1)) AND NOT cpu_data_master_rdv_fifo_empty_ddr2_deva_s1;
  --ddr2_deva_s1_writedata mux, which is an e_mux
  ddr2_deva_s1_writedata <= cpu_data_master_writedata;
  internal_cpu_instruction_master_requests_ddr2_deva_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(26 DOWNTO 25) & std_logic_vector'("0000000000000000000000000")) = std_logic_vector'("100000000000000000000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --cpu/data_master granted ddr2_deva/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_data_master_granted_slave_ddr2_deva_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_data_master_granted_slave_ddr2_deva_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_data_master_saved_grant_ddr2_deva_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ddr2_deva_s1_arbitration_holdoff_internal OR NOT internal_cpu_data_master_requests_ddr2_deva_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_data_master_granted_slave_ddr2_deva_s1))))));
      end if;
    end if;

  end process;

  --cpu_data_master_continuerequest continued request, which is an e_mux
  cpu_data_master_continuerequest <= last_cycle_cpu_data_master_granted_slave_ddr2_deva_s1 AND internal_cpu_data_master_requests_ddr2_deva_s1;
  internal_cpu_instruction_master_qualified_request_ddr2_deva_s1 <= internal_cpu_instruction_master_requests_ddr2_deva_s1 AND NOT ((((cpu_instruction_master_read AND to_std_logic((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))) OR ((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_latency_counter)))))))))) OR cpu_data_master_arbiterlock));
  --rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1 : rdv_fifo_for_cpu_instruction_master_to_ddr2_deva_s1_module
    port map(
      data_out => cpu_instruction_master_rdv_fifo_output_from_ddr2_deva_s1,
      empty => open,
      fifo_contains_ones_n => cpu_instruction_master_rdv_fifo_empty_ddr2_deva_s1,
      full => open,
      clear_fifo => module_input3,
      clk => clk,
      data_in => internal_cpu_instruction_master_granted_ddr2_deva_s1,
      read => ddr2_deva_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input4,
      write => module_input5
    );

  module_input3 <= std_logic'('0');
  module_input4 <= std_logic'('0');
  module_input5 <= in_a_read_cycle AND NOT ddr2_deva_s1_waits_for_read;

  cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register <= NOT cpu_instruction_master_rdv_fifo_empty_ddr2_deva_s1;
  --local readdatavalid cpu_instruction_master_read_data_valid_ddr2_deva_s1, which is an e_mux
  cpu_instruction_master_read_data_valid_ddr2_deva_s1 <= ((ddr2_deva_s1_readdatavalid_from_sa AND cpu_instruction_master_rdv_fifo_output_from_ddr2_deva_s1)) AND NOT cpu_instruction_master_rdv_fifo_empty_ddr2_deva_s1;
  --allow new arb cycle for ddr2_deva/s1, which is an e_assign
  ddr2_deva_s1_allow_new_arb_cycle <= NOT cpu_data_master_arbiterlock AND NOT cpu_instruction_master_arbiterlock;
  --cpu/instruction_master assignment into master qualified-requests vector for ddr2_deva/s1, which is an e_assign
  ddr2_deva_s1_master_qreq_vector(0) <= internal_cpu_instruction_master_qualified_request_ddr2_deva_s1;
  --cpu/instruction_master grant ddr2_deva/s1, which is an e_assign
  internal_cpu_instruction_master_granted_ddr2_deva_s1 <= ddr2_deva_s1_grant_vector(0);
  --cpu/instruction_master saved-grant ddr2_deva/s1, which is an e_assign
  cpu_instruction_master_saved_grant_ddr2_deva_s1 <= ddr2_deva_s1_arb_winner(0) AND internal_cpu_instruction_master_requests_ddr2_deva_s1;
  --cpu/data_master assignment into master qualified-requests vector for ddr2_deva/s1, which is an e_assign
  ddr2_deva_s1_master_qreq_vector(1) <= internal_cpu_data_master_qualified_request_ddr2_deva_s1;
  --cpu/data_master grant ddr2_deva/s1, which is an e_assign
  internal_cpu_data_master_granted_ddr2_deva_s1 <= ddr2_deva_s1_grant_vector(1);
  --cpu/data_master saved-grant ddr2_deva/s1, which is an e_assign
  cpu_data_master_saved_grant_ddr2_deva_s1 <= ddr2_deva_s1_arb_winner(1) AND internal_cpu_data_master_requests_ddr2_deva_s1;
  --ddr2_deva/s1 chosen-master double-vector, which is an e_assign
  ddr2_deva_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((ddr2_deva_s1_master_qreq_vector & ddr2_deva_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT ddr2_deva_s1_master_qreq_vector & NOT ddr2_deva_s1_master_qreq_vector))) + (std_logic_vector'("000") & (ddr2_deva_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  ddr2_deva_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((ddr2_deva_s1_allow_new_arb_cycle AND or_reduce(ddr2_deva_s1_grant_vector)))) = '1'), ddr2_deva_s1_grant_vector, ddr2_deva_s1_saved_chosen_master_vector);
  --saved ddr2_deva_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_deva_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(ddr2_deva_s1_allow_new_arb_cycle) = '1' then 
        ddr2_deva_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(ddr2_deva_s1_grant_vector)) = '1'), ddr2_deva_s1_grant_vector, ddr2_deva_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  ddr2_deva_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((ddr2_deva_s1_chosen_master_double_vector(1) OR ddr2_deva_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((ddr2_deva_s1_chosen_master_double_vector(0) OR ddr2_deva_s1_chosen_master_double_vector(2)))));
  --ddr2_deva/s1 chosen master rotated left, which is an e_assign
  ddr2_deva_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(ddr2_deva_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(ddr2_deva_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --ddr2_deva/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_deva_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(ddr2_deva_s1_grant_vector)) = '1' then 
        ddr2_deva_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(ddr2_deva_s1_end_xfer) = '1'), ddr2_deva_s1_chosen_master_rot_left, ddr2_deva_s1_grant_vector);
      end if;
    end if;

  end process;

  --assign ddr2_deva_s1_resetrequest_n_from_sa = ddr2_deva_s1_resetrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  ddr2_deva_s1_resetrequest_n_from_sa <= ddr2_deva_s1_resetrequest_n;
  --ddr2_deva_s1_firsttransfer first transaction, which is an e_assign
  ddr2_deva_s1_firsttransfer <= A_WE_StdLogic((std_logic'(ddr2_deva_s1_begins_xfer) = '1'), ddr2_deva_s1_unreg_firsttransfer, ddr2_deva_s1_reg_firsttransfer);
  --ddr2_deva_s1_unreg_firsttransfer first transaction, which is an e_assign
  ddr2_deva_s1_unreg_firsttransfer <= NOT ((ddr2_deva_s1_slavearbiterlockenable AND ddr2_deva_s1_any_continuerequest));
  --ddr2_deva_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_deva_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ddr2_deva_s1_begins_xfer) = '1' then 
        ddr2_deva_s1_reg_firsttransfer <= ddr2_deva_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ddr2_deva_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ddr2_deva_s1_beginbursttransfer_internal <= ddr2_deva_s1_begins_xfer;
  --ddr2_deva/s1 begin burst transfer to slave, which is an e_assign
  ddr2_deva_s1_beginbursttransfer <= ddr2_deva_s1_beginbursttransfer_internal;
  --ddr2_deva_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  ddr2_deva_s1_arbitration_holdoff_internal <= ddr2_deva_s1_begins_xfer AND ddr2_deva_s1_firsttransfer;
  --ddr2_deva_s1_read assignment, which is an e_mux
  ddr2_deva_s1_read <= ((internal_cpu_data_master_granted_ddr2_deva_s1 AND cpu_data_master_read)) OR ((internal_cpu_instruction_master_granted_ddr2_deva_s1 AND cpu_instruction_master_read));
  --ddr2_deva_s1_write assignment, which is an e_mux
  ddr2_deva_s1_write <= internal_cpu_data_master_granted_ddr2_deva_s1 AND cpu_data_master_write;
  shifted_address_to_ddr2_deva_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --ddr2_deva_s1_address mux, which is an e_mux
  ddr2_deva_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_ddr2_deva_s1)) = '1'), (A_SRL(shifted_address_to_ddr2_deva_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_ddr2_deva_s1_from_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 23);
  shifted_address_to_ddr2_deva_s1_from_cpu_instruction_master <= cpu_instruction_master_address_to_slave;
  --d1_ddr2_deva_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ddr2_deva_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_ddr2_deva_s1_end_xfer <= ddr2_deva_s1_end_xfer;
      end if;
    end if;

  end process;

  --ddr2_deva_s1_waits_for_read in a cycle, which is an e_mux
  ddr2_deva_s1_waits_for_read <= ddr2_deva_s1_in_a_read_cycle AND NOT internal_ddr2_deva_s1_waitrequest_n_from_sa;
  --ddr2_deva_s1_in_a_read_cycle assignment, which is an e_assign
  ddr2_deva_s1_in_a_read_cycle <= ((internal_cpu_data_master_granted_ddr2_deva_s1 AND cpu_data_master_read)) OR ((internal_cpu_instruction_master_granted_ddr2_deva_s1 AND cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ddr2_deva_s1_in_a_read_cycle;
  --ddr2_deva_s1_waits_for_write in a cycle, which is an e_mux
  ddr2_deva_s1_waits_for_write <= ddr2_deva_s1_in_a_write_cycle AND NOT internal_ddr2_deva_s1_waitrequest_n_from_sa;
  --ddr2_deva_s1_in_a_write_cycle assignment, which is an e_assign
  ddr2_deva_s1_in_a_write_cycle <= internal_cpu_data_master_granted_ddr2_deva_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ddr2_deva_s1_in_a_write_cycle;
  wait_for_ddr2_deva_s1_counter <= std_logic'('0');
  --ddr2_deva_s1_byteenable byte enable port mux, which is an e_mux
  ddr2_deva_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_ddr2_deva_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --burstcount mux, which is an e_mux
  ddr2_deva_s1_burstcount <= std_logic'('1');
  --vhdl renameroo for output signals
  cpu_data_master_granted_ddr2_deva_s1 <= internal_cpu_data_master_granted_ddr2_deva_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_ddr2_deva_s1 <= internal_cpu_data_master_qualified_request_ddr2_deva_s1;
  --vhdl renameroo for output signals
  cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register <= internal_cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register;
  --vhdl renameroo for output signals
  cpu_data_master_requests_ddr2_deva_s1 <= internal_cpu_data_master_requests_ddr2_deva_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_ddr2_deva_s1 <= internal_cpu_instruction_master_granted_ddr2_deva_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_ddr2_deva_s1 <= internal_cpu_instruction_master_qualified_request_ddr2_deva_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_ddr2_deva_s1 <= internal_cpu_instruction_master_requests_ddr2_deva_s1;
  --vhdl renameroo for output signals
  ddr2_deva_s1_waitrequest_n_from_sa <= internal_ddr2_deva_s1_waitrequest_n_from_sa;
--synthesis translate_off
    --ddr2_deva/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_data_master_granted_ddr2_deva_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_granted_ddr2_deva_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_data_master_saved_grant_ddr2_deva_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_saved_grant_ddr2_deva_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line5.all);
          deallocate (write_line5);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu_reset_clk125_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity ranger_cpu_reset_clk125_domain_synch_module;


architecture europa of ranger_cpu_reset_clk125_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_out <= data_in_d1;
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1_module;


architecture europa of rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1_module;


architecture europa of rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity ddr2_devb_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal ddr2_devb_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_devb_s1_readdatavalid : IN STD_LOGIC;
                 signal ddr2_devb_s1_resetrequest_n : IN STD_LOGIC;
                 signal ddr2_devb_s1_waitrequest_n : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_clock_1_out_read : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_write : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_2_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_2_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_clock_2_out_read : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_write : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_ddr2_devb_s1_end_xfer : OUT STD_LOGIC;
                 signal ddr2_devb_s1_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ddr2_devb_s1_beginbursttransfer : OUT STD_LOGIC;
                 signal ddr2_devb_s1_burstcount : OUT STD_LOGIC;
                 signal ddr2_devb_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ddr2_devb_s1_read : OUT STD_LOGIC;
                 signal ddr2_devb_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_devb_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                 signal ddr2_devb_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                 signal ddr2_devb_s1_write : OUT STD_LOGIC;
                 signal ddr2_devb_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_1_out_granted_ddr2_devb_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_out_requests_ddr2_devb_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_out_granted_ddr2_devb_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_out_requests_ddr2_devb_s1 : OUT STD_LOGIC
              );
end entity ddr2_devb_s1_arbitrator;


architecture europa of ddr2_devb_s1_arbitrator is
component rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1_module;

component rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1_module;

                signal d1_reasons_to_wait :  STD_LOGIC;
                signal ddr2_devb_s1_allgrants :  STD_LOGIC;
                signal ddr2_devb_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal ddr2_devb_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ddr2_devb_s1_any_continuerequest :  STD_LOGIC;
                signal ddr2_devb_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_devb_s1_arb_counter_enable :  STD_LOGIC;
                signal ddr2_devb_s1_arb_share_counter :  STD_LOGIC;
                signal ddr2_devb_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal ddr2_devb_s1_arb_share_set_values :  STD_LOGIC;
                signal ddr2_devb_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_devb_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal ddr2_devb_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal ddr2_devb_s1_begins_xfer :  STD_LOGIC;
                signal ddr2_devb_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ddr2_devb_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_devb_s1_end_xfer :  STD_LOGIC;
                signal ddr2_devb_s1_firsttransfer :  STD_LOGIC;
                signal ddr2_devb_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_devb_s1_in_a_read_cycle :  STD_LOGIC;
                signal ddr2_devb_s1_in_a_write_cycle :  STD_LOGIC;
                signal ddr2_devb_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_devb_s1_move_on_to_next_transaction :  STD_LOGIC;
                signal ddr2_devb_s1_non_bursting_master_requests :  STD_LOGIC;
                signal ddr2_devb_s1_readdatavalid_from_sa :  STD_LOGIC;
                signal ddr2_devb_s1_reg_firsttransfer :  STD_LOGIC;
                signal ddr2_devb_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ddr2_devb_s1_slavearbiterlockenable :  STD_LOGIC;
                signal ddr2_devb_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal ddr2_devb_s1_unreg_firsttransfer :  STD_LOGIC;
                signal ddr2_devb_s1_waits_for_read :  STD_LOGIC;
                signal ddr2_devb_s1_waits_for_write :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ddr2_devb_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ddr2_devb_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register :  STD_LOGIC;
                signal internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register :  STD_LOGIC;
                signal internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1 :  STD_LOGIC;
                signal last_cycle_ranger_cpu_clock_1_out_granted_slave_ddr2_devb_s1 :  STD_LOGIC;
                signal last_cycle_ranger_cpu_clock_2_out_granted_slave_ddr2_devb_s1 :  STD_LOGIC;
                signal module_input10 :  STD_LOGIC;
                signal module_input11 :  STD_LOGIC;
                signal module_input12 :  STD_LOGIC;
                signal module_input7 :  STD_LOGIC;
                signal module_input8 :  STD_LOGIC;
                signal module_input9 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_continuerequest :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_rdv_fifo_empty_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_rdv_fifo_output_from_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_saved_grant_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_continuerequest :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_rdv_fifo_empty_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_rdv_fifo_output_from_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_saved_grant_ddr2_devb_s1 :  STD_LOGIC;
                signal shifted_address_to_ddr2_devb_s1_from_ranger_cpu_clock_1_out :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_ddr2_devb_s1_from_ranger_cpu_clock_2_out :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal wait_for_ddr2_devb_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT ddr2_devb_s1_end_xfer;
      end if;
    end if;

  end process;

  ddr2_devb_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 OR internal_ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1));
  --assign ddr2_devb_s1_readdata_from_sa = ddr2_devb_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ddr2_devb_s1_readdata_from_sa <= ddr2_devb_s1_readdata;
  internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_1_out_read OR ranger_cpu_clock_1_out_write)))))));
  --assign ddr2_devb_s1_waitrequest_n_from_sa = ddr2_devb_s1_waitrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_ddr2_devb_s1_waitrequest_n_from_sa <= ddr2_devb_s1_waitrequest_n;
  --assign ddr2_devb_s1_readdatavalid_from_sa = ddr2_devb_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  ddr2_devb_s1_readdatavalid_from_sa <= ddr2_devb_s1_readdatavalid;
  --ddr2_devb_s1_arb_share_counter set values, which is an e_mux
  ddr2_devb_s1_arb_share_set_values <= std_logic'('1');
  --ddr2_devb_s1_non_bursting_master_requests mux, which is an e_mux
  ddr2_devb_s1_non_bursting_master_requests <= ((internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1 OR internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1) OR internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1) OR internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1;
  --ddr2_devb_s1_any_bursting_master_saved_grant mux, which is an e_mux
  ddr2_devb_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --ddr2_devb_s1_arb_share_counter_next_value assignment, which is an e_assign
  ddr2_devb_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ddr2_devb_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_devb_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ddr2_devb_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_devb_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ddr2_devb_s1_allgrants all slave grants, which is an e_mux
  ddr2_devb_s1_allgrants <= ((or_reduce(ddr2_devb_s1_grant_vector) OR or_reduce(ddr2_devb_s1_grant_vector)) OR or_reduce(ddr2_devb_s1_grant_vector)) OR or_reduce(ddr2_devb_s1_grant_vector);
  --ddr2_devb_s1_end_xfer assignment, which is an e_assign
  ddr2_devb_s1_end_xfer <= NOT ((ddr2_devb_s1_waits_for_read OR ddr2_devb_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_ddr2_devb_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ddr2_devb_s1 <= ddr2_devb_s1_end_xfer AND (((NOT ddr2_devb_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ddr2_devb_s1_arb_share_counter arbitration counter enable, which is an e_assign
  ddr2_devb_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ddr2_devb_s1 AND ddr2_devb_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_ddr2_devb_s1 AND NOT ddr2_devb_s1_non_bursting_master_requests));
  --ddr2_devb_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_devb_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ddr2_devb_s1_arb_counter_enable) = '1' then 
        ddr2_devb_s1_arb_share_counter <= ddr2_devb_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ddr2_devb_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_devb_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(ddr2_devb_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_ddr2_devb_s1)) OR ((end_xfer_arb_share_counter_term_ddr2_devb_s1 AND NOT ddr2_devb_s1_non_bursting_master_requests)))) = '1' then 
        ddr2_devb_s1_slavearbiterlockenable <= ddr2_devb_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_1/out ddr2_devb/s1 arbiterlock, which is an e_assign
  ranger_cpu_clock_1_out_arbiterlock <= ddr2_devb_s1_slavearbiterlockenable AND ranger_cpu_clock_1_out_continuerequest;
  --ddr2_devb_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ddr2_devb_s1_slavearbiterlockenable2 <= ddr2_devb_s1_arb_share_counter_next_value;
  --ranger_cpu_clock_1/out ddr2_devb/s1 arbiterlock2, which is an e_assign
  ranger_cpu_clock_1_out_arbiterlock2 <= ddr2_devb_s1_slavearbiterlockenable2 AND ranger_cpu_clock_1_out_continuerequest;
  --ranger_cpu_clock_2/out ddr2_devb/s1 arbiterlock, which is an e_assign
  ranger_cpu_clock_2_out_arbiterlock <= ddr2_devb_s1_slavearbiterlockenable AND ranger_cpu_clock_2_out_continuerequest;
  --ranger_cpu_clock_2/out ddr2_devb/s1 arbiterlock2, which is an e_assign
  ranger_cpu_clock_2_out_arbiterlock2 <= ddr2_devb_s1_slavearbiterlockenable2 AND ranger_cpu_clock_2_out_continuerequest;
  --ranger_cpu_clock_2/out granted ddr2_devb/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ranger_cpu_clock_2_out_granted_slave_ddr2_devb_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_ranger_cpu_clock_2_out_granted_slave_ddr2_devb_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_2_out_saved_grant_ddr2_devb_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ddr2_devb_s1_arbitration_holdoff_internal OR NOT internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ranger_cpu_clock_2_out_granted_slave_ddr2_devb_s1))))));
      end if;
    end if;

  end process;

  --ranger_cpu_clock_2_out_continuerequest continued request, which is an e_mux
  ranger_cpu_clock_2_out_continuerequest <= last_cycle_ranger_cpu_clock_2_out_granted_slave_ddr2_devb_s1 AND internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1;
  --ddr2_devb_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  ddr2_devb_s1_any_continuerequest <= ranger_cpu_clock_2_out_continuerequest OR ranger_cpu_clock_1_out_continuerequest;
  internal_ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 <= internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1 AND NOT ((((ranger_cpu_clock_1_out_read AND (internal_ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register))) OR ranger_cpu_clock_2_out_arbiterlock));
  --unique name for ddr2_devb_s1_move_on_to_next_transaction, which is an e_assign
  ddr2_devb_s1_move_on_to_next_transaction <= ddr2_devb_s1_readdatavalid_from_sa;
  --rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1 : rdv_fifo_for_ranger_cpu_clock_1_out_to_ddr2_devb_s1_module
    port map(
      data_out => ranger_cpu_clock_1_out_rdv_fifo_output_from_ddr2_devb_s1,
      empty => open,
      fifo_contains_ones_n => ranger_cpu_clock_1_out_rdv_fifo_empty_ddr2_devb_s1,
      full => open,
      clear_fifo => module_input7,
      clk => clk,
      data_in => internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1,
      read => ddr2_devb_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input8,
      write => module_input9
    );

  module_input7 <= std_logic'('0');
  module_input8 <= std_logic'('0');
  module_input9 <= in_a_read_cycle AND NOT ddr2_devb_s1_waits_for_read;

  internal_ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register <= NOT ranger_cpu_clock_1_out_rdv_fifo_empty_ddr2_devb_s1;
  --local readdatavalid ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1, which is an e_mux
  ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 <= ((ddr2_devb_s1_readdatavalid_from_sa AND ranger_cpu_clock_1_out_rdv_fifo_output_from_ddr2_devb_s1)) AND NOT ranger_cpu_clock_1_out_rdv_fifo_empty_ddr2_devb_s1;
  --ddr2_devb_s1_writedata mux, which is an e_mux
  ddr2_devb_s1_writedata <= A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1)) = '1'), ranger_cpu_clock_1_out_writedata, ranger_cpu_clock_2_out_writedata);
  internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_2_out_read OR ranger_cpu_clock_2_out_write)))))));
  --ranger_cpu_clock_1/out granted ddr2_devb/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ranger_cpu_clock_1_out_granted_slave_ddr2_devb_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_ranger_cpu_clock_1_out_granted_slave_ddr2_devb_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_1_out_saved_grant_ddr2_devb_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ddr2_devb_s1_arbitration_holdoff_internal OR NOT internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ranger_cpu_clock_1_out_granted_slave_ddr2_devb_s1))))));
      end if;
    end if;

  end process;

  --ranger_cpu_clock_1_out_continuerequest continued request, which is an e_mux
  ranger_cpu_clock_1_out_continuerequest <= last_cycle_ranger_cpu_clock_1_out_granted_slave_ddr2_devb_s1 AND internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1;
  internal_ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 <= internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1 AND NOT ((((ranger_cpu_clock_2_out_read AND (internal_ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register))) OR ranger_cpu_clock_1_out_arbiterlock));
  --rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1 : rdv_fifo_for_ranger_cpu_clock_2_out_to_ddr2_devb_s1_module
    port map(
      data_out => ranger_cpu_clock_2_out_rdv_fifo_output_from_ddr2_devb_s1,
      empty => open,
      fifo_contains_ones_n => ranger_cpu_clock_2_out_rdv_fifo_empty_ddr2_devb_s1,
      full => open,
      clear_fifo => module_input10,
      clk => clk,
      data_in => internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1,
      read => ddr2_devb_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input11,
      write => module_input12
    );

  module_input10 <= std_logic'('0');
  module_input11 <= std_logic'('0');
  module_input12 <= in_a_read_cycle AND NOT ddr2_devb_s1_waits_for_read;

  internal_ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register <= NOT ranger_cpu_clock_2_out_rdv_fifo_empty_ddr2_devb_s1;
  --local readdatavalid ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1, which is an e_mux
  ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 <= ((ddr2_devb_s1_readdatavalid_from_sa AND ranger_cpu_clock_2_out_rdv_fifo_output_from_ddr2_devb_s1)) AND NOT ranger_cpu_clock_2_out_rdv_fifo_empty_ddr2_devb_s1;
  --allow new arb cycle for ddr2_devb/s1, which is an e_assign
  ddr2_devb_s1_allow_new_arb_cycle <= NOT ranger_cpu_clock_1_out_arbiterlock AND NOT ranger_cpu_clock_2_out_arbiterlock;
  --ranger_cpu_clock_2/out assignment into master qualified-requests vector for ddr2_devb/s1, which is an e_assign
  ddr2_devb_s1_master_qreq_vector(0) <= internal_ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1;
  --ranger_cpu_clock_2/out grant ddr2_devb/s1, which is an e_assign
  internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1 <= ddr2_devb_s1_grant_vector(0);
  --ranger_cpu_clock_2/out saved-grant ddr2_devb/s1, which is an e_assign
  ranger_cpu_clock_2_out_saved_grant_ddr2_devb_s1 <= ddr2_devb_s1_arb_winner(0) AND internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1;
  --ranger_cpu_clock_1/out assignment into master qualified-requests vector for ddr2_devb/s1, which is an e_assign
  ddr2_devb_s1_master_qreq_vector(1) <= internal_ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1;
  --ranger_cpu_clock_1/out grant ddr2_devb/s1, which is an e_assign
  internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1 <= ddr2_devb_s1_grant_vector(1);
  --ranger_cpu_clock_1/out saved-grant ddr2_devb/s1, which is an e_assign
  ranger_cpu_clock_1_out_saved_grant_ddr2_devb_s1 <= ddr2_devb_s1_arb_winner(1) AND internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1;
  --ddr2_devb/s1 chosen-master double-vector, which is an e_assign
  ddr2_devb_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((ddr2_devb_s1_master_qreq_vector & ddr2_devb_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT ddr2_devb_s1_master_qreq_vector & NOT ddr2_devb_s1_master_qreq_vector))) + (std_logic_vector'("000") & (ddr2_devb_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  ddr2_devb_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((ddr2_devb_s1_allow_new_arb_cycle AND or_reduce(ddr2_devb_s1_grant_vector)))) = '1'), ddr2_devb_s1_grant_vector, ddr2_devb_s1_saved_chosen_master_vector);
  --saved ddr2_devb_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_devb_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(ddr2_devb_s1_allow_new_arb_cycle) = '1' then 
        ddr2_devb_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(ddr2_devb_s1_grant_vector)) = '1'), ddr2_devb_s1_grant_vector, ddr2_devb_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  ddr2_devb_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((ddr2_devb_s1_chosen_master_double_vector(1) OR ddr2_devb_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((ddr2_devb_s1_chosen_master_double_vector(0) OR ddr2_devb_s1_chosen_master_double_vector(2)))));
  --ddr2_devb/s1 chosen master rotated left, which is an e_assign
  ddr2_devb_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(ddr2_devb_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(ddr2_devb_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --ddr2_devb/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_devb_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(ddr2_devb_s1_grant_vector)) = '1' then 
        ddr2_devb_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(ddr2_devb_s1_end_xfer) = '1'), ddr2_devb_s1_chosen_master_rot_left, ddr2_devb_s1_grant_vector);
      end if;
    end if;

  end process;

  --assign ddr2_devb_s1_resetrequest_n_from_sa = ddr2_devb_s1_resetrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  ddr2_devb_s1_resetrequest_n_from_sa <= ddr2_devb_s1_resetrequest_n;
  --ddr2_devb_s1_firsttransfer first transaction, which is an e_assign
  ddr2_devb_s1_firsttransfer <= A_WE_StdLogic((std_logic'(ddr2_devb_s1_begins_xfer) = '1'), ddr2_devb_s1_unreg_firsttransfer, ddr2_devb_s1_reg_firsttransfer);
  --ddr2_devb_s1_unreg_firsttransfer first transaction, which is an e_assign
  ddr2_devb_s1_unreg_firsttransfer <= NOT ((ddr2_devb_s1_slavearbiterlockenable AND ddr2_devb_s1_any_continuerequest));
  --ddr2_devb_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ddr2_devb_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ddr2_devb_s1_begins_xfer) = '1' then 
        ddr2_devb_s1_reg_firsttransfer <= ddr2_devb_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ddr2_devb_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ddr2_devb_s1_beginbursttransfer_internal <= ddr2_devb_s1_begins_xfer;
  --ddr2_devb/s1 begin burst transfer to slave, which is an e_assign
  ddr2_devb_s1_beginbursttransfer <= ddr2_devb_s1_beginbursttransfer_internal;
  --ddr2_devb_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  ddr2_devb_s1_arbitration_holdoff_internal <= ddr2_devb_s1_begins_xfer AND ddr2_devb_s1_firsttransfer;
  --ddr2_devb_s1_read assignment, which is an e_mux
  ddr2_devb_s1_read <= ((internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_1_out_read)) OR ((internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_2_out_read));
  --ddr2_devb_s1_write assignment, which is an e_mux
  ddr2_devb_s1_write <= ((internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_1_out_write)) OR ((internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_2_out_write));
  shifted_address_to_ddr2_devb_s1_from_ranger_cpu_clock_1_out <= ranger_cpu_clock_1_out_address_to_slave;
  --ddr2_devb_s1_address mux, which is an e_mux
  ddr2_devb_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1)) = '1'), (A_SRL(shifted_address_to_ddr2_devb_s1_from_ranger_cpu_clock_1_out,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_ddr2_devb_s1_from_ranger_cpu_clock_2_out,std_logic_vector'("00000000000000000000000000000010")))), 23);
  shifted_address_to_ddr2_devb_s1_from_ranger_cpu_clock_2_out <= ranger_cpu_clock_2_out_address_to_slave;
  --d1_ddr2_devb_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ddr2_devb_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_ddr2_devb_s1_end_xfer <= ddr2_devb_s1_end_xfer;
      end if;
    end if;

  end process;

  --ddr2_devb_s1_waits_for_read in a cycle, which is an e_mux
  ddr2_devb_s1_waits_for_read <= ddr2_devb_s1_in_a_read_cycle AND NOT internal_ddr2_devb_s1_waitrequest_n_from_sa;
  --ddr2_devb_s1_in_a_read_cycle assignment, which is an e_assign
  ddr2_devb_s1_in_a_read_cycle <= ((internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_1_out_read)) OR ((internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_2_out_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ddr2_devb_s1_in_a_read_cycle;
  --ddr2_devb_s1_waits_for_write in a cycle, which is an e_mux
  ddr2_devb_s1_waits_for_write <= ddr2_devb_s1_in_a_write_cycle AND NOT internal_ddr2_devb_s1_waitrequest_n_from_sa;
  --ddr2_devb_s1_in_a_write_cycle assignment, which is an e_assign
  ddr2_devb_s1_in_a_write_cycle <= ((internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_1_out_write)) OR ((internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1 AND ranger_cpu_clock_2_out_write));
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ddr2_devb_s1_in_a_write_cycle;
  wait_for_ddr2_devb_s1_counter <= std_logic'('0');
  --ddr2_devb_s1_byteenable byte enable port mux, which is an e_mux
  ddr2_devb_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ranger_cpu_clock_1_out_byteenable)), A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ranger_cpu_clock_2_out_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001")))), 4);
  --burstcount mux, which is an e_mux
  ddr2_devb_s1_burstcount <= std_logic'('1');
  --vhdl renameroo for output signals
  ddr2_devb_s1_waitrequest_n_from_sa <= internal_ddr2_devb_s1_waitrequest_n_from_sa;
  --vhdl renameroo for output signals
  ranger_cpu_clock_1_out_granted_ddr2_devb_s1 <= internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1;
  --vhdl renameroo for output signals
  ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 <= internal_ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1;
  --vhdl renameroo for output signals
  ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register <= internal_ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register;
  --vhdl renameroo for output signals
  ranger_cpu_clock_1_out_requests_ddr2_devb_s1 <= internal_ranger_cpu_clock_1_out_requests_ddr2_devb_s1;
  --vhdl renameroo for output signals
  ranger_cpu_clock_2_out_granted_ddr2_devb_s1 <= internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1;
  --vhdl renameroo for output signals
  ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 <= internal_ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1;
  --vhdl renameroo for output signals
  ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register <= internal_ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register;
  --vhdl renameroo for output signals
  ranger_cpu_clock_2_out_requests_ddr2_devb_s1 <= internal_ranger_cpu_clock_2_out_requests_ddr2_devb_s1;
--synthesis translate_off
    --ddr2_devb/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ranger_cpu_clock_1_out_granted_ddr2_devb_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ranger_cpu_clock_2_out_granted_ddr2_devb_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line6.all);
          deallocate (write_line6);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_1_out_saved_grant_ddr2_devb_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_2_out_saved_grant_ddr2_devb_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line7.all);
          deallocate (write_line7);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dm9000a_avalon_slave_0_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal dm9000a_avalon_slave_0_irq : IN STD_LOGIC;
                 signal dm9000a_avalon_slave_0_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ranger_cpu_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ranger_cpu_clock_0_out_nativeaddress : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_read : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_write : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_dm9000a_avalon_slave_0_end_xfer : OUT STD_LOGIC;
                 signal dm9000a_avalon_slave_0_address : OUT STD_LOGIC;
                 signal dm9000a_avalon_slave_0_chipselect_n : OUT STD_LOGIC;
                 signal dm9000a_avalon_slave_0_irq_from_sa : OUT STD_LOGIC;
                 signal dm9000a_avalon_slave_0_read_n : OUT STD_LOGIC;
                 signal dm9000a_avalon_slave_0_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal dm9000a_avalon_slave_0_reset_n : OUT STD_LOGIC;
                 signal dm9000a_avalon_slave_0_write_n : OUT STD_LOGIC;
                 signal dm9000a_avalon_slave_0_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0 : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 : OUT STD_LOGIC
              );
end entity dm9000a_avalon_slave_0_arbitrator;


architecture europa of dm9000a_avalon_slave_0_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_allgrants :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_allow_new_arb_cycle :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_any_bursting_master_saved_grant :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_any_continuerequest :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_arb_counter_enable :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_arb_share_counter :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_arb_share_counter_next_value :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_arb_share_set_values :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_beginbursttransfer_internal :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_begins_xfer :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_end_xfer :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_firsttransfer :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_grant_vector :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_in_a_read_cycle :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_in_a_write_cycle :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_master_qreq_vector :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_non_bursting_master_requests :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_reg_firsttransfer :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_slavearbiterlockenable :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_slavearbiterlockenable2 :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_unreg_firsttransfer :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_waits_for_read :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_waits_for_write :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal internal_ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal internal_ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_continuerequest :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_saved_grant_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal wait_for_dm9000a_avalon_slave_0_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT dm9000a_avalon_slave_0_end_xfer;
      end if;
    end if;

  end process;

  dm9000a_avalon_slave_0_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0);
  --assign dm9000a_avalon_slave_0_readdata_from_sa = dm9000a_avalon_slave_0_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  dm9000a_avalon_slave_0_readdata_from_sa <= dm9000a_avalon_slave_0_readdata;
  internal_ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_0_out_read OR ranger_cpu_clock_0_out_write)))))));
  --dm9000a_avalon_slave_0_arb_share_counter set values, which is an e_mux
  dm9000a_avalon_slave_0_arb_share_set_values <= std_logic'('1');
  --dm9000a_avalon_slave_0_non_bursting_master_requests mux, which is an e_mux
  dm9000a_avalon_slave_0_non_bursting_master_requests <= internal_ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0;
  --dm9000a_avalon_slave_0_any_bursting_master_saved_grant mux, which is an e_mux
  dm9000a_avalon_slave_0_any_bursting_master_saved_grant <= std_logic'('0');
  --dm9000a_avalon_slave_0_arb_share_counter_next_value assignment, which is an e_assign
  dm9000a_avalon_slave_0_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(dm9000a_avalon_slave_0_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(dm9000a_avalon_slave_0_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(dm9000a_avalon_slave_0_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(dm9000a_avalon_slave_0_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --dm9000a_avalon_slave_0_allgrants all slave grants, which is an e_mux
  dm9000a_avalon_slave_0_allgrants <= dm9000a_avalon_slave_0_grant_vector;
  --dm9000a_avalon_slave_0_end_xfer assignment, which is an e_assign
  dm9000a_avalon_slave_0_end_xfer <= NOT ((dm9000a_avalon_slave_0_waits_for_read OR dm9000a_avalon_slave_0_waits_for_write));
  --end_xfer_arb_share_counter_term_dm9000a_avalon_slave_0 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_dm9000a_avalon_slave_0 <= dm9000a_avalon_slave_0_end_xfer AND (((NOT dm9000a_avalon_slave_0_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --dm9000a_avalon_slave_0_arb_share_counter arbitration counter enable, which is an e_assign
  dm9000a_avalon_slave_0_arb_counter_enable <= ((end_xfer_arb_share_counter_term_dm9000a_avalon_slave_0 AND dm9000a_avalon_slave_0_allgrants)) OR ((end_xfer_arb_share_counter_term_dm9000a_avalon_slave_0 AND NOT dm9000a_avalon_slave_0_non_bursting_master_requests));
  --dm9000a_avalon_slave_0_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dm9000a_avalon_slave_0_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(dm9000a_avalon_slave_0_arb_counter_enable) = '1' then 
        dm9000a_avalon_slave_0_arb_share_counter <= dm9000a_avalon_slave_0_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --dm9000a_avalon_slave_0_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dm9000a_avalon_slave_0_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((dm9000a_avalon_slave_0_master_qreq_vector AND end_xfer_arb_share_counter_term_dm9000a_avalon_slave_0)) OR ((end_xfer_arb_share_counter_term_dm9000a_avalon_slave_0 AND NOT dm9000a_avalon_slave_0_non_bursting_master_requests)))) = '1' then 
        dm9000a_avalon_slave_0_slavearbiterlockenable <= dm9000a_avalon_slave_0_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_0/out dm9000a/avalon_slave_0 arbiterlock, which is an e_assign
  ranger_cpu_clock_0_out_arbiterlock <= dm9000a_avalon_slave_0_slavearbiterlockenable AND ranger_cpu_clock_0_out_continuerequest;
  --dm9000a_avalon_slave_0_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  dm9000a_avalon_slave_0_slavearbiterlockenable2 <= dm9000a_avalon_slave_0_arb_share_counter_next_value;
  --ranger_cpu_clock_0/out dm9000a/avalon_slave_0 arbiterlock2, which is an e_assign
  ranger_cpu_clock_0_out_arbiterlock2 <= dm9000a_avalon_slave_0_slavearbiterlockenable2 AND ranger_cpu_clock_0_out_continuerequest;
  --dm9000a_avalon_slave_0_any_continuerequest at least one master continues requesting, which is an e_assign
  dm9000a_avalon_slave_0_any_continuerequest <= std_logic'('1');
  --ranger_cpu_clock_0_out_continuerequest continued request, which is an e_assign
  ranger_cpu_clock_0_out_continuerequest <= std_logic'('1');
  internal_ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 <= internal_ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0;
  --dm9000a_avalon_slave_0_writedata mux, which is an e_mux
  dm9000a_avalon_slave_0_writedata <= ranger_cpu_clock_0_out_writedata;
  --master is always granted when requested
  internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 <= internal_ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0;
  --ranger_cpu_clock_0/out saved-grant dm9000a/avalon_slave_0, which is an e_assign
  ranger_cpu_clock_0_out_saved_grant_dm9000a_avalon_slave_0 <= internal_ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0;
  --allow new arb cycle for dm9000a/avalon_slave_0, which is an e_assign
  dm9000a_avalon_slave_0_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  dm9000a_avalon_slave_0_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  dm9000a_avalon_slave_0_master_qreq_vector <= std_logic'('1');
  --dm9000a_avalon_slave_0_reset_n assignment, which is an e_assign
  dm9000a_avalon_slave_0_reset_n <= reset_n;
  dm9000a_avalon_slave_0_chipselect_n <= NOT internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0;
  --dm9000a_avalon_slave_0_firsttransfer first transaction, which is an e_assign
  dm9000a_avalon_slave_0_firsttransfer <= A_WE_StdLogic((std_logic'(dm9000a_avalon_slave_0_begins_xfer) = '1'), dm9000a_avalon_slave_0_unreg_firsttransfer, dm9000a_avalon_slave_0_reg_firsttransfer);
  --dm9000a_avalon_slave_0_unreg_firsttransfer first transaction, which is an e_assign
  dm9000a_avalon_slave_0_unreg_firsttransfer <= NOT ((dm9000a_avalon_slave_0_slavearbiterlockenable AND dm9000a_avalon_slave_0_any_continuerequest));
  --dm9000a_avalon_slave_0_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dm9000a_avalon_slave_0_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(dm9000a_avalon_slave_0_begins_xfer) = '1' then 
        dm9000a_avalon_slave_0_reg_firsttransfer <= dm9000a_avalon_slave_0_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --dm9000a_avalon_slave_0_beginbursttransfer_internal begin burst transfer, which is an e_assign
  dm9000a_avalon_slave_0_beginbursttransfer_internal <= dm9000a_avalon_slave_0_begins_xfer;
  --~dm9000a_avalon_slave_0_read_n assignment, which is an e_mux
  dm9000a_avalon_slave_0_read_n <= NOT ((internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 AND ranger_cpu_clock_0_out_read));
  --~dm9000a_avalon_slave_0_write_n assignment, which is an e_mux
  dm9000a_avalon_slave_0_write_n <= NOT ((internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 AND ranger_cpu_clock_0_out_write));
  --dm9000a_avalon_slave_0_address mux, which is an e_mux
  dm9000a_avalon_slave_0_address <= ranger_cpu_clock_0_out_nativeaddress;
  --d1_dm9000a_avalon_slave_0_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_dm9000a_avalon_slave_0_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_dm9000a_avalon_slave_0_end_xfer <= dm9000a_avalon_slave_0_end_xfer;
      end if;
    end if;

  end process;

  --dm9000a_avalon_slave_0_waits_for_read in a cycle, which is an e_mux
  dm9000a_avalon_slave_0_waits_for_read <= dm9000a_avalon_slave_0_in_a_read_cycle AND dm9000a_avalon_slave_0_begins_xfer;
  --dm9000a_avalon_slave_0_in_a_read_cycle assignment, which is an e_assign
  dm9000a_avalon_slave_0_in_a_read_cycle <= internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 AND ranger_cpu_clock_0_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= dm9000a_avalon_slave_0_in_a_read_cycle;
  --dm9000a_avalon_slave_0_waits_for_write in a cycle, which is an e_mux
  dm9000a_avalon_slave_0_waits_for_write <= dm9000a_avalon_slave_0_in_a_write_cycle AND dm9000a_avalon_slave_0_begins_xfer;
  --dm9000a_avalon_slave_0_in_a_write_cycle assignment, which is an e_assign
  dm9000a_avalon_slave_0_in_a_write_cycle <= internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 AND ranger_cpu_clock_0_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= dm9000a_avalon_slave_0_in_a_write_cycle;
  wait_for_dm9000a_avalon_slave_0_counter <= std_logic'('0');
  --assign dm9000a_avalon_slave_0_irq_from_sa = dm9000a_avalon_slave_0_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  dm9000a_avalon_slave_0_irq_from_sa <= dm9000a_avalon_slave_0_irq;
  --vhdl renameroo for output signals
  ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 <= internal_ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0;
  --vhdl renameroo for output signals
  ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 <= internal_ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0;
  --vhdl renameroo for output signals
  ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 <= internal_ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0;
--synthesis translate_off
    --dm9000a/avalon_slave_0 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity frame_received_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal frame_received_s1_irq : IN STD_LOGIC;
                 signal frame_received_s1_readdata : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_frame_received_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_frame_received_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_frame_received_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_frame_received_s1 : OUT STD_LOGIC;
                 signal d1_frame_received_s1_end_xfer : OUT STD_LOGIC;
                 signal frame_received_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal frame_received_s1_chipselect : OUT STD_LOGIC;
                 signal frame_received_s1_irq_from_sa : OUT STD_LOGIC;
                 signal frame_received_s1_readdata_from_sa : OUT STD_LOGIC;
                 signal frame_received_s1_reset_n : OUT STD_LOGIC;
                 signal frame_received_s1_write_n : OUT STD_LOGIC;
                 signal frame_received_s1_writedata : OUT STD_LOGIC
              );
end entity frame_received_s1_arbitrator;


architecture europa of frame_received_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_frame_received_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_frame_received_s1 :  STD_LOGIC;
                signal frame_received_s1_allgrants :  STD_LOGIC;
                signal frame_received_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal frame_received_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal frame_received_s1_any_continuerequest :  STD_LOGIC;
                signal frame_received_s1_arb_counter_enable :  STD_LOGIC;
                signal frame_received_s1_arb_share_counter :  STD_LOGIC;
                signal frame_received_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal frame_received_s1_arb_share_set_values :  STD_LOGIC;
                signal frame_received_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal frame_received_s1_begins_xfer :  STD_LOGIC;
                signal frame_received_s1_end_xfer :  STD_LOGIC;
                signal frame_received_s1_firsttransfer :  STD_LOGIC;
                signal frame_received_s1_grant_vector :  STD_LOGIC;
                signal frame_received_s1_in_a_read_cycle :  STD_LOGIC;
                signal frame_received_s1_in_a_write_cycle :  STD_LOGIC;
                signal frame_received_s1_master_qreq_vector :  STD_LOGIC;
                signal frame_received_s1_non_bursting_master_requests :  STD_LOGIC;
                signal frame_received_s1_reg_firsttransfer :  STD_LOGIC;
                signal frame_received_s1_slavearbiterlockenable :  STD_LOGIC;
                signal frame_received_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal frame_received_s1_unreg_firsttransfer :  STD_LOGIC;
                signal frame_received_s1_waits_for_read :  STD_LOGIC;
                signal frame_received_s1_waits_for_write :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_frame_received_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_frame_received_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_frame_received_s1 :  STD_LOGIC;
                signal shifted_address_to_frame_received_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_frame_received_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT frame_received_s1_end_xfer;
      end if;
    end if;

  end process;

  frame_received_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_frame_received_s1);
  --assign frame_received_s1_readdata_from_sa = frame_received_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  frame_received_s1_readdata_from_sa <= frame_received_s1_readdata;
  internal_cpu_data_master_requests_frame_received_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("000000101000101000001000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --frame_received_s1_arb_share_counter set values, which is an e_mux
  frame_received_s1_arb_share_set_values <= std_logic'('1');
  --frame_received_s1_non_bursting_master_requests mux, which is an e_mux
  frame_received_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_frame_received_s1;
  --frame_received_s1_any_bursting_master_saved_grant mux, which is an e_mux
  frame_received_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --frame_received_s1_arb_share_counter_next_value assignment, which is an e_assign
  frame_received_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(frame_received_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(frame_received_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(frame_received_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(frame_received_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --frame_received_s1_allgrants all slave grants, which is an e_mux
  frame_received_s1_allgrants <= frame_received_s1_grant_vector;
  --frame_received_s1_end_xfer assignment, which is an e_assign
  frame_received_s1_end_xfer <= NOT ((frame_received_s1_waits_for_read OR frame_received_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_frame_received_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_frame_received_s1 <= frame_received_s1_end_xfer AND (((NOT frame_received_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --frame_received_s1_arb_share_counter arbitration counter enable, which is an e_assign
  frame_received_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_frame_received_s1 AND frame_received_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_frame_received_s1 AND NOT frame_received_s1_non_bursting_master_requests));
  --frame_received_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      frame_received_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(frame_received_s1_arb_counter_enable) = '1' then 
        frame_received_s1_arb_share_counter <= frame_received_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --frame_received_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      frame_received_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((frame_received_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_frame_received_s1)) OR ((end_xfer_arb_share_counter_term_frame_received_s1 AND NOT frame_received_s1_non_bursting_master_requests)))) = '1' then 
        frame_received_s1_slavearbiterlockenable <= frame_received_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master frame_received/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= frame_received_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --frame_received_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  frame_received_s1_slavearbiterlockenable2 <= frame_received_s1_arb_share_counter_next_value;
  --cpu/data_master frame_received/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= frame_received_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --frame_received_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  frame_received_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_frame_received_s1 <= internal_cpu_data_master_requests_frame_received_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --frame_received_s1_writedata mux, which is an e_mux
  frame_received_s1_writedata <= cpu_data_master_writedata(0);
  --master is always granted when requested
  internal_cpu_data_master_granted_frame_received_s1 <= internal_cpu_data_master_qualified_request_frame_received_s1;
  --cpu/data_master saved-grant frame_received/s1, which is an e_assign
  cpu_data_master_saved_grant_frame_received_s1 <= internal_cpu_data_master_requests_frame_received_s1;
  --allow new arb cycle for frame_received/s1, which is an e_assign
  frame_received_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  frame_received_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  frame_received_s1_master_qreq_vector <= std_logic'('1');
  --frame_received_s1_reset_n assignment, which is an e_assign
  frame_received_s1_reset_n <= reset_n;
  frame_received_s1_chipselect <= internal_cpu_data_master_granted_frame_received_s1;
  --frame_received_s1_firsttransfer first transaction, which is an e_assign
  frame_received_s1_firsttransfer <= A_WE_StdLogic((std_logic'(frame_received_s1_begins_xfer) = '1'), frame_received_s1_unreg_firsttransfer, frame_received_s1_reg_firsttransfer);
  --frame_received_s1_unreg_firsttransfer first transaction, which is an e_assign
  frame_received_s1_unreg_firsttransfer <= NOT ((frame_received_s1_slavearbiterlockenable AND frame_received_s1_any_continuerequest));
  --frame_received_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      frame_received_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(frame_received_s1_begins_xfer) = '1' then 
        frame_received_s1_reg_firsttransfer <= frame_received_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --frame_received_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  frame_received_s1_beginbursttransfer_internal <= frame_received_s1_begins_xfer;
  --~frame_received_s1_write_n assignment, which is an e_mux
  frame_received_s1_write_n <= NOT ((internal_cpu_data_master_granted_frame_received_s1 AND cpu_data_master_write));
  shifted_address_to_frame_received_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --frame_received_s1_address mux, which is an e_mux
  frame_received_s1_address <= A_EXT (A_SRL(shifted_address_to_frame_received_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_frame_received_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_frame_received_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_frame_received_s1_end_xfer <= frame_received_s1_end_xfer;
      end if;
    end if;

  end process;

  --frame_received_s1_waits_for_read in a cycle, which is an e_mux
  frame_received_s1_waits_for_read <= frame_received_s1_in_a_read_cycle AND frame_received_s1_begins_xfer;
  --frame_received_s1_in_a_read_cycle assignment, which is an e_assign
  frame_received_s1_in_a_read_cycle <= internal_cpu_data_master_granted_frame_received_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= frame_received_s1_in_a_read_cycle;
  --frame_received_s1_waits_for_write in a cycle, which is an e_mux
  frame_received_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(frame_received_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --frame_received_s1_in_a_write_cycle assignment, which is an e_assign
  frame_received_s1_in_a_write_cycle <= internal_cpu_data_master_granted_frame_received_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= frame_received_s1_in_a_write_cycle;
  wait_for_frame_received_s1_counter <= std_logic'('0');
  --assign frame_received_s1_irq_from_sa = frame_received_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  frame_received_s1_irq_from_sa <= frame_received_s1_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_frame_received_s1 <= internal_cpu_data_master_granted_frame_received_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_frame_received_s1 <= internal_cpu_data_master_qualified_request_frame_received_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_frame_received_s1 <= internal_cpu_data_master_requests_frame_received_s1;
--synthesis translate_off
    --frame_received/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jtag_uart_avalon_jtag_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal d1_jtag_uart_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_address : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity jtag_uart_avalon_jtag_slave_arbitrator;


architecture europa of jtag_uart_avalon_jtag_slave_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_allgrants :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_any_continuerequest :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_counter_enable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_share_counter :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_share_set_values :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_begins_xfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_grant_vector :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_in_a_read_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_in_a_write_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_master_qreq_vector :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_non_bursting_master_requests :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_reg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_slavearbiterlockenable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_unreg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waits_for_read :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_jtag_uart_avalon_jtag_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT jtag_uart_avalon_jtag_slave_end_xfer;
      end if;
    end if;

  end process;

  jtag_uart_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave);
  --assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readdata_from_sa <= jtag_uart_avalon_jtag_slave_readdata;
  internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("000000101000101000001010000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_avalon_jtag_slave_waitrequest;
  --jtag_uart_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_avalon_jtag_slave_arb_share_set_values <= std_logic'('1');
  --jtag_uart_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --jtag_uart_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(jtag_uart_avalon_jtag_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(jtag_uart_avalon_jtag_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(jtag_uart_avalon_jtag_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(jtag_uart_avalon_jtag_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --jtag_uart_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  jtag_uart_avalon_jtag_slave_allgrants <= jtag_uart_avalon_jtag_slave_grant_vector;
  --jtag_uart_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_end_xfer <= NOT ((jtag_uart_avalon_jtag_slave_waits_for_read OR jtag_uart_avalon_jtag_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave <= jtag_uart_avalon_jtag_slave_end_xfer AND (((NOT jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --jtag_uart_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  jtag_uart_avalon_jtag_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND jtag_uart_avalon_jtag_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND NOT jtag_uart_avalon_jtag_slave_non_bursting_master_requests));
  --jtag_uart_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_avalon_jtag_slave_arb_counter_enable) = '1' then 
        jtag_uart_avalon_jtag_slave_arb_share_counter <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((jtag_uart_avalon_jtag_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave)) OR ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND NOT jtag_uart_avalon_jtag_slave_non_bursting_master_requests)))) = '1' then 
        jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
  --cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --jtag_uart_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --cpu/data_master saved-grant jtag_uart/avalon_jtag_slave, which is an e_assign
  cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart/avalon_jtag_slave, which is an e_assign
  jtag_uart_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_avalon_jtag_slave_chipselect <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  --jtag_uart_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  jtag_uart_avalon_jtag_slave_firsttransfer <= A_WE_StdLogic((std_logic'(jtag_uart_avalon_jtag_slave_begins_xfer) = '1'), jtag_uart_avalon_jtag_slave_unreg_firsttransfer, jtag_uart_avalon_jtag_slave_reg_firsttransfer);
  --jtag_uart_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  jtag_uart_avalon_jtag_slave_unreg_firsttransfer <= NOT ((jtag_uart_avalon_jtag_slave_slavearbiterlockenable AND jtag_uart_avalon_jtag_slave_any_continuerequest));
  --jtag_uart_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_avalon_jtag_slave_begins_xfer) = '1' then 
        jtag_uart_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_avalon_jtag_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  jtag_uart_avalon_jtag_slave_beginbursttransfer_internal <= jtag_uart_avalon_jtag_slave_begins_xfer;
  --~jtag_uart_avalon_jtag_slave_read_n assignment, which is an e_mux
  jtag_uart_avalon_jtag_slave_read_n <= NOT ((internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_read));
  --~jtag_uart_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_avalon_jtag_slave_write_n <= NOT ((internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_write));
  shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --jtag_uart_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_jtag_uart_avalon_jtag_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_jtag_uart_avalon_jtag_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_jtag_uart_avalon_jtag_slave_end_xfer <= jtag_uart_avalon_jtag_slave_end_xfer;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  jtag_uart_avalon_jtag_slave_waits_for_read <= jtag_uart_avalon_jtag_slave_in_a_read_cycle AND internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_in_a_read_cycle <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_avalon_jtag_slave_waits_for_write <= jtag_uart_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_in_a_write_cycle <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_irq_from_sa <= jtag_uart_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
--synthesis translate_off
    --jtag_uart/avalon_jtag_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity laser_uart_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal laser_uart_s1_dataavailable : IN STD_LOGIC;
                 signal laser_uart_s1_irq : IN STD_LOGIC;
                 signal laser_uart_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal laser_uart_s1_readyfordata : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_laser_uart_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_laser_uart_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_laser_uart_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_laser_uart_s1 : OUT STD_LOGIC;
                 signal d1_laser_uart_s1_end_xfer : OUT STD_LOGIC;
                 signal laser_uart_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal laser_uart_s1_begintransfer : OUT STD_LOGIC;
                 signal laser_uart_s1_chipselect : OUT STD_LOGIC;
                 signal laser_uart_s1_dataavailable_from_sa : OUT STD_LOGIC;
                 signal laser_uart_s1_irq_from_sa : OUT STD_LOGIC;
                 signal laser_uart_s1_read_n : OUT STD_LOGIC;
                 signal laser_uart_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal laser_uart_s1_readyfordata_from_sa : OUT STD_LOGIC;
                 signal laser_uart_s1_reset_n : OUT STD_LOGIC;
                 signal laser_uart_s1_write_n : OUT STD_LOGIC;
                 signal laser_uart_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity laser_uart_s1_arbitrator;


architecture europa of laser_uart_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_laser_uart_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_laser_uart_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_laser_uart_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_laser_uart_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_laser_uart_s1 :  STD_LOGIC;
                signal laser_uart_s1_allgrants :  STD_LOGIC;
                signal laser_uart_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal laser_uart_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal laser_uart_s1_any_continuerequest :  STD_LOGIC;
                signal laser_uart_s1_arb_counter_enable :  STD_LOGIC;
                signal laser_uart_s1_arb_share_counter :  STD_LOGIC;
                signal laser_uart_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal laser_uart_s1_arb_share_set_values :  STD_LOGIC;
                signal laser_uart_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal laser_uart_s1_begins_xfer :  STD_LOGIC;
                signal laser_uart_s1_end_xfer :  STD_LOGIC;
                signal laser_uart_s1_firsttransfer :  STD_LOGIC;
                signal laser_uart_s1_grant_vector :  STD_LOGIC;
                signal laser_uart_s1_in_a_read_cycle :  STD_LOGIC;
                signal laser_uart_s1_in_a_write_cycle :  STD_LOGIC;
                signal laser_uart_s1_master_qreq_vector :  STD_LOGIC;
                signal laser_uart_s1_non_bursting_master_requests :  STD_LOGIC;
                signal laser_uart_s1_reg_firsttransfer :  STD_LOGIC;
                signal laser_uart_s1_slavearbiterlockenable :  STD_LOGIC;
                signal laser_uart_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal laser_uart_s1_unreg_firsttransfer :  STD_LOGIC;
                signal laser_uart_s1_waits_for_read :  STD_LOGIC;
                signal laser_uart_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_laser_uart_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_laser_uart_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT laser_uart_s1_end_xfer;
      end if;
    end if;

  end process;

  laser_uart_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_laser_uart_s1);
  --assign laser_uart_s1_readdata_from_sa = laser_uart_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  laser_uart_s1_readdata_from_sa <= laser_uart_s1_readdata;
  internal_cpu_data_master_requests_laser_uart_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("000000101000101000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign laser_uart_s1_dataavailable_from_sa = laser_uart_s1_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  laser_uart_s1_dataavailable_from_sa <= laser_uart_s1_dataavailable;
  --assign laser_uart_s1_readyfordata_from_sa = laser_uart_s1_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  laser_uart_s1_readyfordata_from_sa <= laser_uart_s1_readyfordata;
  --laser_uart_s1_arb_share_counter set values, which is an e_mux
  laser_uart_s1_arb_share_set_values <= std_logic'('1');
  --laser_uart_s1_non_bursting_master_requests mux, which is an e_mux
  laser_uart_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_laser_uart_s1;
  --laser_uart_s1_any_bursting_master_saved_grant mux, which is an e_mux
  laser_uart_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --laser_uart_s1_arb_share_counter_next_value assignment, which is an e_assign
  laser_uart_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(laser_uart_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(laser_uart_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(laser_uart_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(laser_uart_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --laser_uart_s1_allgrants all slave grants, which is an e_mux
  laser_uart_s1_allgrants <= laser_uart_s1_grant_vector;
  --laser_uart_s1_end_xfer assignment, which is an e_assign
  laser_uart_s1_end_xfer <= NOT ((laser_uart_s1_waits_for_read OR laser_uart_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_laser_uart_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_laser_uart_s1 <= laser_uart_s1_end_xfer AND (((NOT laser_uart_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --laser_uart_s1_arb_share_counter arbitration counter enable, which is an e_assign
  laser_uart_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_laser_uart_s1 AND laser_uart_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_laser_uart_s1 AND NOT laser_uart_s1_non_bursting_master_requests));
  --laser_uart_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      laser_uart_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(laser_uart_s1_arb_counter_enable) = '1' then 
        laser_uart_s1_arb_share_counter <= laser_uart_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --laser_uart_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      laser_uart_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((laser_uart_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_laser_uart_s1)) OR ((end_xfer_arb_share_counter_term_laser_uart_s1 AND NOT laser_uart_s1_non_bursting_master_requests)))) = '1' then 
        laser_uart_s1_slavearbiterlockenable <= laser_uart_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master laser_uart/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= laser_uart_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --laser_uart_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  laser_uart_s1_slavearbiterlockenable2 <= laser_uart_s1_arb_share_counter_next_value;
  --cpu/data_master laser_uart/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= laser_uart_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --laser_uart_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  laser_uart_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_laser_uart_s1 <= internal_cpu_data_master_requests_laser_uart_s1;
  --laser_uart_s1_writedata mux, which is an e_mux
  laser_uart_s1_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_laser_uart_s1 <= internal_cpu_data_master_qualified_request_laser_uart_s1;
  --cpu/data_master saved-grant laser_uart/s1, which is an e_assign
  cpu_data_master_saved_grant_laser_uart_s1 <= internal_cpu_data_master_requests_laser_uart_s1;
  --allow new arb cycle for laser_uart/s1, which is an e_assign
  laser_uart_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  laser_uart_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  laser_uart_s1_master_qreq_vector <= std_logic'('1');
  laser_uart_s1_begintransfer <= laser_uart_s1_begins_xfer;
  --laser_uart_s1_reset_n assignment, which is an e_assign
  laser_uart_s1_reset_n <= reset_n;
  laser_uart_s1_chipselect <= internal_cpu_data_master_granted_laser_uart_s1;
  --laser_uart_s1_firsttransfer first transaction, which is an e_assign
  laser_uart_s1_firsttransfer <= A_WE_StdLogic((std_logic'(laser_uart_s1_begins_xfer) = '1'), laser_uart_s1_unreg_firsttransfer, laser_uart_s1_reg_firsttransfer);
  --laser_uart_s1_unreg_firsttransfer first transaction, which is an e_assign
  laser_uart_s1_unreg_firsttransfer <= NOT ((laser_uart_s1_slavearbiterlockenable AND laser_uart_s1_any_continuerequest));
  --laser_uart_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      laser_uart_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(laser_uart_s1_begins_xfer) = '1' then 
        laser_uart_s1_reg_firsttransfer <= laser_uart_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --laser_uart_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  laser_uart_s1_beginbursttransfer_internal <= laser_uart_s1_begins_xfer;
  --~laser_uart_s1_read_n assignment, which is an e_mux
  laser_uart_s1_read_n <= NOT ((internal_cpu_data_master_granted_laser_uart_s1 AND cpu_data_master_read));
  --~laser_uart_s1_write_n assignment, which is an e_mux
  laser_uart_s1_write_n <= NOT ((internal_cpu_data_master_granted_laser_uart_s1 AND cpu_data_master_write));
  shifted_address_to_laser_uart_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --laser_uart_s1_address mux, which is an e_mux
  laser_uart_s1_address <= A_EXT (A_SRL(shifted_address_to_laser_uart_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_laser_uart_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_laser_uart_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_laser_uart_s1_end_xfer <= laser_uart_s1_end_xfer;
      end if;
    end if;

  end process;

  --laser_uart_s1_waits_for_read in a cycle, which is an e_mux
  laser_uart_s1_waits_for_read <= laser_uart_s1_in_a_read_cycle AND laser_uart_s1_begins_xfer;
  --laser_uart_s1_in_a_read_cycle assignment, which is an e_assign
  laser_uart_s1_in_a_read_cycle <= internal_cpu_data_master_granted_laser_uart_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= laser_uart_s1_in_a_read_cycle;
  --laser_uart_s1_waits_for_write in a cycle, which is an e_mux
  laser_uart_s1_waits_for_write <= laser_uart_s1_in_a_write_cycle AND laser_uart_s1_begins_xfer;
  --laser_uart_s1_in_a_write_cycle assignment, which is an e_assign
  laser_uart_s1_in_a_write_cycle <= internal_cpu_data_master_granted_laser_uart_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= laser_uart_s1_in_a_write_cycle;
  wait_for_laser_uart_s1_counter <= std_logic'('0');
  --assign laser_uart_s1_irq_from_sa = laser_uart_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  laser_uart_s1_irq_from_sa <= laser_uart_s1_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_laser_uart_s1 <= internal_cpu_data_master_granted_laser_uart_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_laser_uart_s1 <= internal_cpu_data_master_qualified_request_laser_uart_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_laser_uart_s1 <= internal_cpu_data_master_requests_laser_uart_s1;
--synthesis translate_off
    --laser_uart/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity onchip_mem_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_mem_s1_address : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
                 signal onchip_mem_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_mem_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_mem_s1_clken : OUT STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_mem_s1_write : OUT STD_LOGIC;
                 signal onchip_mem_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC
              );
end entity onchip_mem_s1_arbitrator;


architecture europa of onchip_mem_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_onchip_mem_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_mem_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 :  STD_LOGIC;
                signal last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 :  STD_LOGIC;
                signal onchip_mem_s1_allgrants :  STD_LOGIC;
                signal onchip_mem_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal onchip_mem_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal onchip_mem_s1_any_continuerequest :  STD_LOGIC;
                signal onchip_mem_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_arb_counter_enable :  STD_LOGIC;
                signal onchip_mem_s1_arb_share_counter :  STD_LOGIC;
                signal onchip_mem_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal onchip_mem_s1_arb_share_set_values :  STD_LOGIC;
                signal onchip_mem_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal onchip_mem_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal onchip_mem_s1_begins_xfer :  STD_LOGIC;
                signal onchip_mem_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_mem_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_end_xfer :  STD_LOGIC;
                signal onchip_mem_s1_firsttransfer :  STD_LOGIC;
                signal onchip_mem_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_in_a_read_cycle :  STD_LOGIC;
                signal onchip_mem_s1_in_a_write_cycle :  STD_LOGIC;
                signal onchip_mem_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_non_bursting_master_requests :  STD_LOGIC;
                signal onchip_mem_s1_reg_firsttransfer :  STD_LOGIC;
                signal onchip_mem_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_slavearbiterlockenable :  STD_LOGIC;
                signal onchip_mem_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal onchip_mem_s1_unreg_firsttransfer :  STD_LOGIC;
                signal onchip_mem_s1_waits_for_read :  STD_LOGIC;
                signal onchip_mem_s1_waits_for_write :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal p1_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal shifted_address_to_onchip_mem_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal shifted_address_to_onchip_mem_s1_from_cpu_instruction_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_onchip_mem_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT onchip_mem_s1_end_xfer;
      end if;
    end if;

  end process;

  onchip_mem_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_data_master_qualified_request_onchip_mem_s1 OR internal_cpu_instruction_master_qualified_request_onchip_mem_s1));
  --assign onchip_mem_s1_readdata_from_sa = onchip_mem_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_mem_s1_readdata_from_sa <= onchip_mem_s1_readdata;
  internal_cpu_data_master_requests_onchip_mem_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 13) & std_logic_vector'("0000000000000")) = std_logic_vector'("000000101000010000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_onchip_mem_s1 assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_onchip_mem_s1 <= cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in;
  --onchip_mem_s1_arb_share_counter set values, which is an e_mux
  onchip_mem_s1_arb_share_set_values <= std_logic'('1');
  --onchip_mem_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_mem_s1_non_bursting_master_requests <= ((internal_cpu_data_master_requests_onchip_mem_s1 OR internal_cpu_instruction_master_requests_onchip_mem_s1) OR internal_cpu_data_master_requests_onchip_mem_s1) OR internal_cpu_instruction_master_requests_onchip_mem_s1;
  --onchip_mem_s1_any_bursting_master_saved_grant mux, which is an e_mux
  onchip_mem_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --onchip_mem_s1_arb_share_counter_next_value assignment, which is an e_assign
  onchip_mem_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(onchip_mem_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(onchip_mem_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --onchip_mem_s1_allgrants all slave grants, which is an e_mux
  onchip_mem_s1_allgrants <= ((or_reduce(onchip_mem_s1_grant_vector) OR or_reduce(onchip_mem_s1_grant_vector)) OR or_reduce(onchip_mem_s1_grant_vector)) OR or_reduce(onchip_mem_s1_grant_vector);
  --onchip_mem_s1_end_xfer assignment, which is an e_assign
  onchip_mem_s1_end_xfer <= NOT ((onchip_mem_s1_waits_for_read OR onchip_mem_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_onchip_mem_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_onchip_mem_s1 <= onchip_mem_s1_end_xfer AND (((NOT onchip_mem_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --onchip_mem_s1_arb_share_counter arbitration counter enable, which is an e_assign
  onchip_mem_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_onchip_mem_s1 AND onchip_mem_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_onchip_mem_s1 AND NOT onchip_mem_s1_non_bursting_master_requests));
  --onchip_mem_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_mem_s1_arb_counter_enable) = '1' then 
        onchip_mem_s1_arb_share_counter <= onchip_mem_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --onchip_mem_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(onchip_mem_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_onchip_mem_s1)) OR ((end_xfer_arb_share_counter_term_onchip_mem_s1 AND NOT onchip_mem_s1_non_bursting_master_requests)))) = '1' then 
        onchip_mem_s1_slavearbiterlockenable <= onchip_mem_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master onchip_mem/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= onchip_mem_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --onchip_mem_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_mem_s1_slavearbiterlockenable2 <= onchip_mem_s1_arb_share_counter_next_value;
  --cpu/data_master onchip_mem/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= onchip_mem_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --cpu/instruction_master onchip_mem/s1 arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= onchip_mem_s1_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master onchip_mem/s1 arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= onchip_mem_s1_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master granted onchip_mem/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_instruction_master_saved_grant_onchip_mem_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_arbitration_holdoff_internal OR NOT internal_cpu_instruction_master_requests_onchip_mem_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1))))));
      end if;
    end if;

  end process;

  --cpu_instruction_master_continuerequest continued request, which is an e_mux
  cpu_instruction_master_continuerequest <= last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 AND internal_cpu_instruction_master_requests_onchip_mem_s1;
  --onchip_mem_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_mem_s1_any_continuerequest <= cpu_instruction_master_continuerequest OR cpu_data_master_continuerequest;
  internal_cpu_data_master_qualified_request_onchip_mem_s1 <= internal_cpu_data_master_requests_onchip_mem_s1 AND NOT (((((cpu_data_master_read AND (cpu_data_master_read_data_valid_onchip_mem_s1_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))) OR cpu_instruction_master_arbiterlock));
  --cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in <= ((internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_read) AND NOT onchip_mem_s1_waits_for_read) AND NOT (cpu_data_master_read_data_valid_onchip_mem_s1_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_onchip_mem_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_onchip_mem_s1_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in)));
  --cpu_data_master_read_data_valid_onchip_mem_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= p1_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_onchip_mem_s1, which is an e_mux
  cpu_data_master_read_data_valid_onchip_mem_s1 <= cpu_data_master_read_data_valid_onchip_mem_s1_shift_register;
  --onchip_mem_s1_writedata mux, which is an e_mux
  onchip_mem_s1_writedata <= cpu_data_master_writedata;
  --mux onchip_mem_s1_clken, which is an e_mux
  onchip_mem_s1_clken <= std_logic'('1');
  internal_cpu_instruction_master_requests_onchip_mem_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(26 DOWNTO 13) & std_logic_vector'("0000000000000")) = std_logic_vector'("000000101000010000000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --cpu/data_master granted onchip_mem/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_data_master_saved_grant_onchip_mem_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_arbitration_holdoff_internal OR NOT internal_cpu_data_master_requests_onchip_mem_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_data_master_granted_slave_onchip_mem_s1))))));
      end if;
    end if;

  end process;

  --cpu_data_master_continuerequest continued request, which is an e_mux
  cpu_data_master_continuerequest <= last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 AND internal_cpu_data_master_requests_onchip_mem_s1;
  internal_cpu_instruction_master_qualified_request_onchip_mem_s1 <= internal_cpu_instruction_master_requests_onchip_mem_s1 AND NOT ((((cpu_instruction_master_read AND ((to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_latency_counter)))))) OR (cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register))))) OR cpu_data_master_arbiterlock));
  --cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in <= (internal_cpu_instruction_master_granted_onchip_mem_s1 AND cpu_instruction_master_read) AND NOT onchip_mem_s1_waits_for_read;
  --shift register p1 cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register) & A_ToStdLogicVector(cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in)));
  --cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= p1_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_instruction_master_read_data_valid_onchip_mem_s1, which is an e_mux
  cpu_instruction_master_read_data_valid_onchip_mem_s1 <= cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register;
  --allow new arb cycle for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_allow_new_arb_cycle <= NOT cpu_data_master_arbiterlock AND NOT cpu_instruction_master_arbiterlock;
  --cpu/instruction_master assignment into master qualified-requests vector for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_master_qreq_vector(0) <= internal_cpu_instruction_master_qualified_request_onchip_mem_s1;
  --cpu/instruction_master grant onchip_mem/s1, which is an e_assign
  internal_cpu_instruction_master_granted_onchip_mem_s1 <= onchip_mem_s1_grant_vector(0);
  --cpu/instruction_master saved-grant onchip_mem/s1, which is an e_assign
  cpu_instruction_master_saved_grant_onchip_mem_s1 <= onchip_mem_s1_arb_winner(0) AND internal_cpu_instruction_master_requests_onchip_mem_s1;
  --cpu/data_master assignment into master qualified-requests vector for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_master_qreq_vector(1) <= internal_cpu_data_master_qualified_request_onchip_mem_s1;
  --cpu/data_master grant onchip_mem/s1, which is an e_assign
  internal_cpu_data_master_granted_onchip_mem_s1 <= onchip_mem_s1_grant_vector(1);
  --cpu/data_master saved-grant onchip_mem/s1, which is an e_assign
  cpu_data_master_saved_grant_onchip_mem_s1 <= onchip_mem_s1_arb_winner(1) AND internal_cpu_data_master_requests_onchip_mem_s1;
  --onchip_mem/s1 chosen-master double-vector, which is an e_assign
  onchip_mem_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((onchip_mem_s1_master_qreq_vector & onchip_mem_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT onchip_mem_s1_master_qreq_vector & NOT onchip_mem_s1_master_qreq_vector))) + (std_logic_vector'("000") & (onchip_mem_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  onchip_mem_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_allow_new_arb_cycle AND or_reduce(onchip_mem_s1_grant_vector)))) = '1'), onchip_mem_s1_grant_vector, onchip_mem_s1_saved_chosen_master_vector);
  --saved onchip_mem_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_mem_s1_allow_new_arb_cycle) = '1' then 
        onchip_mem_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(onchip_mem_s1_grant_vector)) = '1'), onchip_mem_s1_grant_vector, onchip_mem_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  onchip_mem_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((onchip_mem_s1_chosen_master_double_vector(1) OR onchip_mem_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((onchip_mem_s1_chosen_master_double_vector(0) OR onchip_mem_s1_chosen_master_double_vector(2)))));
  --onchip_mem/s1 chosen master rotated left, which is an e_assign
  onchip_mem_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(onchip_mem_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(onchip_mem_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --onchip_mem/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(onchip_mem_s1_grant_vector)) = '1' then 
        onchip_mem_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(onchip_mem_s1_end_xfer) = '1'), onchip_mem_s1_chosen_master_rot_left, onchip_mem_s1_grant_vector);
      end if;
    end if;

  end process;

  onchip_mem_s1_chipselect <= internal_cpu_data_master_granted_onchip_mem_s1 OR internal_cpu_instruction_master_granted_onchip_mem_s1;
  --onchip_mem_s1_firsttransfer first transaction, which is an e_assign
  onchip_mem_s1_firsttransfer <= A_WE_StdLogic((std_logic'(onchip_mem_s1_begins_xfer) = '1'), onchip_mem_s1_unreg_firsttransfer, onchip_mem_s1_reg_firsttransfer);
  --onchip_mem_s1_unreg_firsttransfer first transaction, which is an e_assign
  onchip_mem_s1_unreg_firsttransfer <= NOT ((onchip_mem_s1_slavearbiterlockenable AND onchip_mem_s1_any_continuerequest));
  --onchip_mem_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_mem_s1_begins_xfer) = '1' then 
        onchip_mem_s1_reg_firsttransfer <= onchip_mem_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --onchip_mem_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  onchip_mem_s1_beginbursttransfer_internal <= onchip_mem_s1_begins_xfer;
  --onchip_mem_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  onchip_mem_s1_arbitration_holdoff_internal <= onchip_mem_s1_begins_xfer AND onchip_mem_s1_firsttransfer;
  --onchip_mem_s1_write assignment, which is an e_mux
  onchip_mem_s1_write <= internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_write;
  shifted_address_to_onchip_mem_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --onchip_mem_s1_address mux, which is an e_mux
  onchip_mem_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_onchip_mem_s1)) = '1'), (A_SRL(shifted_address_to_onchip_mem_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_onchip_mem_s1_from_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 11);
  shifted_address_to_onchip_mem_s1_from_cpu_instruction_master <= cpu_instruction_master_address_to_slave;
  --d1_onchip_mem_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_onchip_mem_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_onchip_mem_s1_end_xfer <= onchip_mem_s1_end_xfer;
      end if;
    end if;

  end process;

  --onchip_mem_s1_waits_for_read in a cycle, which is an e_mux
  onchip_mem_s1_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_mem_s1_in_a_read_cycle assignment, which is an e_assign
  onchip_mem_s1_in_a_read_cycle <= ((internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_read)) OR ((internal_cpu_instruction_master_granted_onchip_mem_s1 AND cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_mem_s1_in_a_read_cycle;
  --onchip_mem_s1_waits_for_write in a cycle, which is an e_mux
  onchip_mem_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_mem_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_mem_s1_in_a_write_cycle <= internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_mem_s1_in_a_write_cycle;
  wait_for_onchip_mem_s1_counter <= std_logic'('0');
  --onchip_mem_s1_byteenable byte enable port mux, which is an e_mux
  onchip_mem_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_onchip_mem_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  cpu_data_master_granted_onchip_mem_s1 <= internal_cpu_data_master_granted_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_onchip_mem_s1 <= internal_cpu_data_master_qualified_request_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_onchip_mem_s1 <= internal_cpu_data_master_requests_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_onchip_mem_s1 <= internal_cpu_instruction_master_granted_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_onchip_mem_s1 <= internal_cpu_instruction_master_qualified_request_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_onchip_mem_s1 <= internal_cpu_instruction_master_requests_onchip_mem_s1;
--synthesis translate_off
    --onchip_mem/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_data_master_granted_onchip_mem_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_granted_onchip_mem_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line8.all);
          deallocate (write_line8);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_data_master_saved_grant_onchip_mem_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_saved_grant_onchip_mem_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line9.all);
          deallocate (write_line9);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu_clock_0_in_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_0_in_endofpacket : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ranger_cpu_clock_0_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                 signal cpu_data_master_requests_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                 signal d1_ranger_cpu_clock_0_in_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_in_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ranger_cpu_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ranger_cpu_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_in_nativeaddress : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_in_read : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ranger_cpu_clock_0_in_reset_n : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_in_write : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity ranger_cpu_clock_0_in_arbitrator;


architecture europa of ranger_cpu_clock_0_in_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal internal_cpu_data_master_requests_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal internal_ranger_cpu_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_allgrants :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_allow_new_arb_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_any_continuerequest :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_arb_counter_enable :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_arb_share_counter :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_arb_share_counter_next_value :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_arb_share_set_values :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_beginbursttransfer_internal :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_begins_xfer :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_end_xfer :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_grant_vector :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_in_a_read_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_in_a_write_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_master_qreq_vector :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_non_bursting_master_requests :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_reg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_slavearbiterlockenable :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_unreg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_waits_for_read :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_ranger_cpu_clock_0_in_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_ranger_cpu_clock_0_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT ranger_cpu_clock_0_in_end_xfer;
      end if;
    end if;

  end process;

  ranger_cpu_clock_0_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_ranger_cpu_clock_0_in);
  --assign ranger_cpu_clock_0_in_readdata_from_sa = ranger_cpu_clock_0_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_clock_0_in_readdata_from_sa <= ranger_cpu_clock_0_in_readdata;
  internal_cpu_data_master_requests_ranger_cpu_clock_0_in <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("000000101000101000001100000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign ranger_cpu_clock_0_in_waitrequest_from_sa = ranger_cpu_clock_0_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_ranger_cpu_clock_0_in_waitrequest_from_sa <= ranger_cpu_clock_0_in_waitrequest;
  --ranger_cpu_clock_0_in_arb_share_counter set values, which is an e_mux
  ranger_cpu_clock_0_in_arb_share_set_values <= std_logic'('1');
  --ranger_cpu_clock_0_in_non_bursting_master_requests mux, which is an e_mux
  ranger_cpu_clock_0_in_non_bursting_master_requests <= internal_cpu_data_master_requests_ranger_cpu_clock_0_in;
  --ranger_cpu_clock_0_in_any_bursting_master_saved_grant mux, which is an e_mux
  ranger_cpu_clock_0_in_any_bursting_master_saved_grant <= std_logic'('0');
  --ranger_cpu_clock_0_in_arb_share_counter_next_value assignment, which is an e_assign
  ranger_cpu_clock_0_in_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_0_in_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_0_in_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_0_in_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_0_in_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ranger_cpu_clock_0_in_allgrants all slave grants, which is an e_mux
  ranger_cpu_clock_0_in_allgrants <= ranger_cpu_clock_0_in_grant_vector;
  --ranger_cpu_clock_0_in_end_xfer assignment, which is an e_assign
  ranger_cpu_clock_0_in_end_xfer <= NOT ((ranger_cpu_clock_0_in_waits_for_read OR ranger_cpu_clock_0_in_waits_for_write));
  --end_xfer_arb_share_counter_term_ranger_cpu_clock_0_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ranger_cpu_clock_0_in <= ranger_cpu_clock_0_in_end_xfer AND (((NOT ranger_cpu_clock_0_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ranger_cpu_clock_0_in_arb_share_counter arbitration counter enable, which is an e_assign
  ranger_cpu_clock_0_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ranger_cpu_clock_0_in AND ranger_cpu_clock_0_in_allgrants)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_clock_0_in AND NOT ranger_cpu_clock_0_in_non_bursting_master_requests));
  --ranger_cpu_clock_0_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_0_in_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_clock_0_in_arb_counter_enable) = '1' then 
        ranger_cpu_clock_0_in_arb_share_counter <= ranger_cpu_clock_0_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_0_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_0_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((ranger_cpu_clock_0_in_master_qreq_vector AND end_xfer_arb_share_counter_term_ranger_cpu_clock_0_in)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_clock_0_in AND NOT ranger_cpu_clock_0_in_non_bursting_master_requests)))) = '1' then 
        ranger_cpu_clock_0_in_slavearbiterlockenable <= ranger_cpu_clock_0_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master ranger_cpu_clock_0/in arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= ranger_cpu_clock_0_in_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --ranger_cpu_clock_0_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ranger_cpu_clock_0_in_slavearbiterlockenable2 <= ranger_cpu_clock_0_in_arb_share_counter_next_value;
  --cpu/data_master ranger_cpu_clock_0/in arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= ranger_cpu_clock_0_in_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --ranger_cpu_clock_0_in_any_continuerequest at least one master continues requesting, which is an e_assign
  ranger_cpu_clock_0_in_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_ranger_cpu_clock_0_in <= internal_cpu_data_master_requests_ranger_cpu_clock_0_in AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --ranger_cpu_clock_0_in_writedata mux, which is an e_mux
  ranger_cpu_clock_0_in_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --assign ranger_cpu_clock_0_in_endofpacket_from_sa = ranger_cpu_clock_0_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_clock_0_in_endofpacket_from_sa <= ranger_cpu_clock_0_in_endofpacket;
  --master is always granted when requested
  internal_cpu_data_master_granted_ranger_cpu_clock_0_in <= internal_cpu_data_master_qualified_request_ranger_cpu_clock_0_in;
  --cpu/data_master saved-grant ranger_cpu_clock_0/in, which is an e_assign
  cpu_data_master_saved_grant_ranger_cpu_clock_0_in <= internal_cpu_data_master_requests_ranger_cpu_clock_0_in;
  --allow new arb cycle for ranger_cpu_clock_0/in, which is an e_assign
  ranger_cpu_clock_0_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  ranger_cpu_clock_0_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  ranger_cpu_clock_0_in_master_qreq_vector <= std_logic'('1');
  --ranger_cpu_clock_0_in_reset_n assignment, which is an e_assign
  ranger_cpu_clock_0_in_reset_n <= reset_n;
  --ranger_cpu_clock_0_in_firsttransfer first transaction, which is an e_assign
  ranger_cpu_clock_0_in_firsttransfer <= A_WE_StdLogic((std_logic'(ranger_cpu_clock_0_in_begins_xfer) = '1'), ranger_cpu_clock_0_in_unreg_firsttransfer, ranger_cpu_clock_0_in_reg_firsttransfer);
  --ranger_cpu_clock_0_in_unreg_firsttransfer first transaction, which is an e_assign
  ranger_cpu_clock_0_in_unreg_firsttransfer <= NOT ((ranger_cpu_clock_0_in_slavearbiterlockenable AND ranger_cpu_clock_0_in_any_continuerequest));
  --ranger_cpu_clock_0_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_0_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_clock_0_in_begins_xfer) = '1' then 
        ranger_cpu_clock_0_in_reg_firsttransfer <= ranger_cpu_clock_0_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_0_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ranger_cpu_clock_0_in_beginbursttransfer_internal <= ranger_cpu_clock_0_in_begins_xfer;
  --ranger_cpu_clock_0_in_read assignment, which is an e_mux
  ranger_cpu_clock_0_in_read <= internal_cpu_data_master_granted_ranger_cpu_clock_0_in AND cpu_data_master_read;
  --ranger_cpu_clock_0_in_write assignment, which is an e_mux
  ranger_cpu_clock_0_in_write <= internal_cpu_data_master_granted_ranger_cpu_clock_0_in AND cpu_data_master_write;
  shifted_address_to_ranger_cpu_clock_0_in_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --ranger_cpu_clock_0_in_address mux, which is an e_mux
  ranger_cpu_clock_0_in_address <= A_EXT (A_SRL(shifted_address_to_ranger_cpu_clock_0_in_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --slaveid ranger_cpu_clock_0_in_nativeaddress nativeaddress mux, which is an e_mux
  ranger_cpu_clock_0_in_nativeaddress <= Vector_To_Std_Logic(A_SRL(cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")));
  --d1_ranger_cpu_clock_0_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ranger_cpu_clock_0_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_ranger_cpu_clock_0_in_end_xfer <= ranger_cpu_clock_0_in_end_xfer;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_0_in_waits_for_read in a cycle, which is an e_mux
  ranger_cpu_clock_0_in_waits_for_read <= ranger_cpu_clock_0_in_in_a_read_cycle AND internal_ranger_cpu_clock_0_in_waitrequest_from_sa;
  --ranger_cpu_clock_0_in_in_a_read_cycle assignment, which is an e_assign
  ranger_cpu_clock_0_in_in_a_read_cycle <= internal_cpu_data_master_granted_ranger_cpu_clock_0_in AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ranger_cpu_clock_0_in_in_a_read_cycle;
  --ranger_cpu_clock_0_in_waits_for_write in a cycle, which is an e_mux
  ranger_cpu_clock_0_in_waits_for_write <= ranger_cpu_clock_0_in_in_a_write_cycle AND internal_ranger_cpu_clock_0_in_waitrequest_from_sa;
  --ranger_cpu_clock_0_in_in_a_write_cycle assignment, which is an e_assign
  ranger_cpu_clock_0_in_in_a_write_cycle <= internal_cpu_data_master_granted_ranger_cpu_clock_0_in AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ranger_cpu_clock_0_in_in_a_write_cycle;
  wait_for_ranger_cpu_clock_0_in_counter <= std_logic'('0');
  --ranger_cpu_clock_0_in_byteenable byte enable port mux, which is an e_mux
  ranger_cpu_clock_0_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_ranger_cpu_clock_0_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 2);
  --vhdl renameroo for output signals
  cpu_data_master_granted_ranger_cpu_clock_0_in <= internal_cpu_data_master_granted_ranger_cpu_clock_0_in;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_ranger_cpu_clock_0_in <= internal_cpu_data_master_qualified_request_ranger_cpu_clock_0_in;
  --vhdl renameroo for output signals
  cpu_data_master_requests_ranger_cpu_clock_0_in <= internal_cpu_data_master_requests_ranger_cpu_clock_0_in;
  --vhdl renameroo for output signals
  ranger_cpu_clock_0_in_waitrequest_from_sa <= internal_ranger_cpu_clock_0_in_waitrequest_from_sa;
--synthesis translate_off
    --ranger_cpu_clock_0/in enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity ranger_cpu_clock_0_out_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_dm9000a_avalon_slave_0_end_xfer : IN STD_LOGIC;
                 signal dm9000a_avalon_slave_0_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ranger_cpu_clock_0_out_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_read : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_write : IN STD_LOGIC;
                 signal ranger_cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ranger_cpu_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ranger_cpu_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ranger_cpu_clock_0_out_reset_n : OUT STD_LOGIC;
                 signal ranger_cpu_clock_0_out_waitrequest : OUT STD_LOGIC
              );
end entity ranger_cpu_clock_0_out_arbitrator;


architecture europa of ranger_cpu_clock_0_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_ranger_cpu_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_ranger_cpu_clock_0_out_waitrequest :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_address_last_time :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_clock_0_out_read_last_time :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_run :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_write_last_time :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_writedata_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 OR NOT ((ranger_cpu_clock_0_out_read OR ranger_cpu_clock_0_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_dm9000a_avalon_slave_0_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_0_out_read OR ranger_cpu_clock_0_out_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 OR NOT ((ranger_cpu_clock_0_out_read OR ranger_cpu_clock_0_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_dm9000a_avalon_slave_0_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_0_out_read OR ranger_cpu_clock_0_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  ranger_cpu_clock_0_out_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_ranger_cpu_clock_0_out_address_to_slave <= ranger_cpu_clock_0_out_address;
  --ranger_cpu_clock_0/out readdata mux, which is an e_mux
  ranger_cpu_clock_0_out_readdata <= dm9000a_avalon_slave_0_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_ranger_cpu_clock_0_out_waitrequest <= NOT ranger_cpu_clock_0_out_run;
  --ranger_cpu_clock_0_out_reset_n assignment, which is an e_assign
  ranger_cpu_clock_0_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  ranger_cpu_clock_0_out_address_to_slave <= internal_ranger_cpu_clock_0_out_address_to_slave;
  --vhdl renameroo for output signals
  ranger_cpu_clock_0_out_waitrequest <= internal_ranger_cpu_clock_0_out_waitrequest;
--synthesis translate_off
    --ranger_cpu_clock_0_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_0_out_address_last_time <= std_logic_vector'("00");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_0_out_address_last_time <= ranger_cpu_clock_0_out_address;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          active_and_waiting_last_time <= internal_ranger_cpu_clock_0_out_waitrequest AND ((ranger_cpu_clock_0_out_read OR ranger_cpu_clock_0_out_write));
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line10 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((ranger_cpu_clock_0_out_address /= ranger_cpu_clock_0_out_address_last_time))))) = '1' then 
          write(write_line10, now);
          write(write_line10, string'(": "));
          write(write_line10, string'("ranger_cpu_clock_0_out_address did not heed wait!!!"));
          write(output, write_line10.all);
          deallocate (write_line10);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_0_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_0_out_read_last_time <= ranger_cpu_clock_0_out_read;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line11 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ranger_cpu_clock_0_out_read) /= std_logic'(ranger_cpu_clock_0_out_read_last_time)))))) = '1' then 
          write(write_line11, now);
          write(write_line11, string'(": "));
          write(write_line11, string'("ranger_cpu_clock_0_out_read did not heed wait!!!"));
          write(output, write_line11.all);
          deallocate (write_line11);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_0_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_0_out_write_last_time <= ranger_cpu_clock_0_out_write;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line12 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ranger_cpu_clock_0_out_write) /= std_logic'(ranger_cpu_clock_0_out_write_last_time)))))) = '1' then 
          write(write_line12, now);
          write(write_line12, string'(": "));
          write(write_line12, string'("ranger_cpu_clock_0_out_write did not heed wait!!!"));
          write(output, write_line12.all);
          deallocate (write_line12);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_0_out_writedata_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_0_out_writedata_last_time <= ranger_cpu_clock_0_out_writedata;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_0_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line13 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((ranger_cpu_clock_0_out_writedata /= ranger_cpu_clock_0_out_writedata_last_time)))) AND ranger_cpu_clock_0_out_write)) = '1' then 
          write(write_line13, now);
          write(write_line13, string'(": "));
          write(write_line13, string'("ranger_cpu_clock_0_out_writedata did not heed wait!!!"));
          write(output, write_line13.all);
          deallocate (write_line13);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu_clock_1_in_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_in_endofpacket : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_1_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_instruction_master_granted_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                 signal d1_ranger_cpu_clock_1_in_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ranger_cpu_clock_1_in_read : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_1_in_reset_n : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_in_write : OUT STD_LOGIC
              );
end entity ranger_cpu_clock_1_in_arbitrator;


architecture europa of ranger_cpu_clock_1_in_arbitrator is
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal internal_ranger_cpu_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_allgrants :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_allow_new_arb_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_any_continuerequest :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_arb_counter_enable :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_arb_share_counter :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_arb_share_counter_next_value :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_arb_share_set_values :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_beginbursttransfer_internal :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_begins_xfer :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_end_xfer :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_grant_vector :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_in_a_read_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_in_a_write_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_master_qreq_vector :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_non_bursting_master_requests :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_reg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_slavearbiterlockenable :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_unreg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_waits_for_read :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_waits_for_write :  STD_LOGIC;
                signal wait_for_ranger_cpu_clock_1_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT ranger_cpu_clock_1_in_end_xfer;
      end if;
    end if;

  end process;

  ranger_cpu_clock_1_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in);
  --assign ranger_cpu_clock_1_in_readdata_from_sa = ranger_cpu_clock_1_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_clock_1_in_readdata_from_sa <= ranger_cpu_clock_1_in_readdata;
  internal_cpu_instruction_master_requests_ranger_cpu_clock_1_in <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(26 DOWNTO 25) & std_logic_vector'("0000000000000000000000000")) = std_logic_vector'("110000000000000000000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --assign ranger_cpu_clock_1_in_waitrequest_from_sa = ranger_cpu_clock_1_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_ranger_cpu_clock_1_in_waitrequest_from_sa <= ranger_cpu_clock_1_in_waitrequest;
  --ranger_cpu_clock_1_in_arb_share_counter set values, which is an e_mux
  ranger_cpu_clock_1_in_arb_share_set_values <= std_logic'('1');
  --ranger_cpu_clock_1_in_non_bursting_master_requests mux, which is an e_mux
  ranger_cpu_clock_1_in_non_bursting_master_requests <= internal_cpu_instruction_master_requests_ranger_cpu_clock_1_in;
  --ranger_cpu_clock_1_in_any_bursting_master_saved_grant mux, which is an e_mux
  ranger_cpu_clock_1_in_any_bursting_master_saved_grant <= std_logic'('0');
  --ranger_cpu_clock_1_in_arb_share_counter_next_value assignment, which is an e_assign
  ranger_cpu_clock_1_in_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_1_in_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_1_in_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_1_in_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_1_in_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ranger_cpu_clock_1_in_allgrants all slave grants, which is an e_mux
  ranger_cpu_clock_1_in_allgrants <= ranger_cpu_clock_1_in_grant_vector;
  --ranger_cpu_clock_1_in_end_xfer assignment, which is an e_assign
  ranger_cpu_clock_1_in_end_xfer <= NOT ((ranger_cpu_clock_1_in_waits_for_read OR ranger_cpu_clock_1_in_waits_for_write));
  --end_xfer_arb_share_counter_term_ranger_cpu_clock_1_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ranger_cpu_clock_1_in <= ranger_cpu_clock_1_in_end_xfer AND (((NOT ranger_cpu_clock_1_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ranger_cpu_clock_1_in_arb_share_counter arbitration counter enable, which is an e_assign
  ranger_cpu_clock_1_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ranger_cpu_clock_1_in AND ranger_cpu_clock_1_in_allgrants)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_clock_1_in AND NOT ranger_cpu_clock_1_in_non_bursting_master_requests));
  --ranger_cpu_clock_1_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_1_in_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_clock_1_in_arb_counter_enable) = '1' then 
        ranger_cpu_clock_1_in_arb_share_counter <= ranger_cpu_clock_1_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_1_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_1_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((ranger_cpu_clock_1_in_master_qreq_vector AND end_xfer_arb_share_counter_term_ranger_cpu_clock_1_in)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_clock_1_in AND NOT ranger_cpu_clock_1_in_non_bursting_master_requests)))) = '1' then 
        ranger_cpu_clock_1_in_slavearbiterlockenable <= ranger_cpu_clock_1_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/instruction_master ranger_cpu_clock_1/in arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= ranger_cpu_clock_1_in_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --ranger_cpu_clock_1_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ranger_cpu_clock_1_in_slavearbiterlockenable2 <= ranger_cpu_clock_1_in_arb_share_counter_next_value;
  --cpu/instruction_master ranger_cpu_clock_1/in arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= ranger_cpu_clock_1_in_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --ranger_cpu_clock_1_in_any_continuerequest at least one master continues requesting, which is an e_assign
  ranger_cpu_clock_1_in_any_continuerequest <= std_logic'('1');
  --cpu_instruction_master_continuerequest continued request, which is an e_assign
  cpu_instruction_master_continuerequest <= std_logic'('1');
  internal_cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in <= internal_cpu_instruction_master_requests_ranger_cpu_clock_1_in AND NOT ((cpu_instruction_master_read AND ((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))) OR (cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register)))));
  --local readdatavalid cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in, which is an e_mux
  cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in <= (internal_cpu_instruction_master_granted_ranger_cpu_clock_1_in AND cpu_instruction_master_read) AND NOT ranger_cpu_clock_1_in_waits_for_read;
  --assign ranger_cpu_clock_1_in_endofpacket_from_sa = ranger_cpu_clock_1_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_clock_1_in_endofpacket_from_sa <= ranger_cpu_clock_1_in_endofpacket;
  --master is always granted when requested
  internal_cpu_instruction_master_granted_ranger_cpu_clock_1_in <= internal_cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in;
  --cpu/instruction_master saved-grant ranger_cpu_clock_1/in, which is an e_assign
  cpu_instruction_master_saved_grant_ranger_cpu_clock_1_in <= internal_cpu_instruction_master_requests_ranger_cpu_clock_1_in;
  --allow new arb cycle for ranger_cpu_clock_1/in, which is an e_assign
  ranger_cpu_clock_1_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  ranger_cpu_clock_1_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  ranger_cpu_clock_1_in_master_qreq_vector <= std_logic'('1');
  --ranger_cpu_clock_1_in_reset_n assignment, which is an e_assign
  ranger_cpu_clock_1_in_reset_n <= reset_n;
  --ranger_cpu_clock_1_in_firsttransfer first transaction, which is an e_assign
  ranger_cpu_clock_1_in_firsttransfer <= A_WE_StdLogic((std_logic'(ranger_cpu_clock_1_in_begins_xfer) = '1'), ranger_cpu_clock_1_in_unreg_firsttransfer, ranger_cpu_clock_1_in_reg_firsttransfer);
  --ranger_cpu_clock_1_in_unreg_firsttransfer first transaction, which is an e_assign
  ranger_cpu_clock_1_in_unreg_firsttransfer <= NOT ((ranger_cpu_clock_1_in_slavearbiterlockenable AND ranger_cpu_clock_1_in_any_continuerequest));
  --ranger_cpu_clock_1_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_1_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_clock_1_in_begins_xfer) = '1' then 
        ranger_cpu_clock_1_in_reg_firsttransfer <= ranger_cpu_clock_1_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_1_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ranger_cpu_clock_1_in_beginbursttransfer_internal <= ranger_cpu_clock_1_in_begins_xfer;
  --ranger_cpu_clock_1_in_read assignment, which is an e_mux
  ranger_cpu_clock_1_in_read <= internal_cpu_instruction_master_granted_ranger_cpu_clock_1_in AND cpu_instruction_master_read;
  --ranger_cpu_clock_1_in_write assignment, which is an e_mux
  ranger_cpu_clock_1_in_write <= std_logic'('0');
  --ranger_cpu_clock_1_in_address mux, which is an e_mux
  ranger_cpu_clock_1_in_address <= cpu_instruction_master_address_to_slave (24 DOWNTO 0);
  --slaveid ranger_cpu_clock_1_in_nativeaddress nativeaddress mux, which is an e_mux
  ranger_cpu_clock_1_in_nativeaddress <= A_EXT (A_SRL(cpu_instruction_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 23);
  --d1_ranger_cpu_clock_1_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ranger_cpu_clock_1_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_ranger_cpu_clock_1_in_end_xfer <= ranger_cpu_clock_1_in_end_xfer;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_1_in_waits_for_read in a cycle, which is an e_mux
  ranger_cpu_clock_1_in_waits_for_read <= ranger_cpu_clock_1_in_in_a_read_cycle AND internal_ranger_cpu_clock_1_in_waitrequest_from_sa;
  --ranger_cpu_clock_1_in_in_a_read_cycle assignment, which is an e_assign
  ranger_cpu_clock_1_in_in_a_read_cycle <= internal_cpu_instruction_master_granted_ranger_cpu_clock_1_in AND cpu_instruction_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ranger_cpu_clock_1_in_in_a_read_cycle;
  --ranger_cpu_clock_1_in_waits_for_write in a cycle, which is an e_mux
  ranger_cpu_clock_1_in_waits_for_write <= ranger_cpu_clock_1_in_in_a_write_cycle AND internal_ranger_cpu_clock_1_in_waitrequest_from_sa;
  --ranger_cpu_clock_1_in_in_a_write_cycle assignment, which is an e_assign
  ranger_cpu_clock_1_in_in_a_write_cycle <= std_logic'('0');
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ranger_cpu_clock_1_in_in_a_write_cycle;
  wait_for_ranger_cpu_clock_1_in_counter <= std_logic'('0');
  --ranger_cpu_clock_1_in_byteenable byte enable port mux, which is an e_mux
  ranger_cpu_clock_1_in_byteenable <= A_EXT (-SIGNED(std_logic_vector'("00000000000000000000000000000001")), 4);
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_ranger_cpu_clock_1_in <= internal_cpu_instruction_master_granted_ranger_cpu_clock_1_in;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in <= internal_cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_ranger_cpu_clock_1_in <= internal_cpu_instruction_master_requests_ranger_cpu_clock_1_in;
  --vhdl renameroo for output signals
  ranger_cpu_clock_1_in_waitrequest_from_sa <= internal_ranger_cpu_clock_1_in_waitrequest_from_sa;
--synthesis translate_off
    --ranger_cpu_clock_1/in enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity ranger_cpu_clock_1_out_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_ddr2_devb_s1_end_xfer : IN STD_LOGIC;
                 signal ddr2_devb_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_devb_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_1_out_granted_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_read : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_requests_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_write : IN STD_LOGIC;
                 signal ranger_cpu_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ranger_cpu_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_1_out_reset_n : OUT STD_LOGIC;
                 signal ranger_cpu_clock_1_out_waitrequest : OUT STD_LOGIC
              );
end entity ranger_cpu_clock_1_out_arbitrator;


architecture europa of ranger_cpu_clock_1_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_ranger_cpu_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal internal_ranger_cpu_clock_1_out_waitrequest :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_address_last_time :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_1_out_read_last_time :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_run :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_write_last_time :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 OR ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1) OR NOT ranger_cpu_clock_1_out_requests_ddr2_devb_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_1_out_granted_ddr2_devb_s1 OR NOT ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 OR NOT ranger_cpu_clock_1_out_read) OR ((ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 AND ranger_cpu_clock_1_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 OR NOT ((ranger_cpu_clock_1_out_read OR ranger_cpu_clock_1_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_devb_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_1_out_read OR ranger_cpu_clock_1_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  ranger_cpu_clock_1_out_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_ranger_cpu_clock_1_out_address_to_slave <= ranger_cpu_clock_1_out_address;
  --ranger_cpu_clock_1/out readdata mux, which is an e_mux
  ranger_cpu_clock_1_out_readdata <= ddr2_devb_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_ranger_cpu_clock_1_out_waitrequest <= NOT ranger_cpu_clock_1_out_run;
  --ranger_cpu_clock_1_out_reset_n assignment, which is an e_assign
  ranger_cpu_clock_1_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  ranger_cpu_clock_1_out_address_to_slave <= internal_ranger_cpu_clock_1_out_address_to_slave;
  --vhdl renameroo for output signals
  ranger_cpu_clock_1_out_waitrequest <= internal_ranger_cpu_clock_1_out_waitrequest;
--synthesis translate_off
    --ranger_cpu_clock_1_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_1_out_address_last_time <= std_logic_vector'("0000000000000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_1_out_address_last_time <= ranger_cpu_clock_1_out_address;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          active_and_waiting_last_time <= internal_ranger_cpu_clock_1_out_waitrequest AND ((ranger_cpu_clock_1_out_read OR ranger_cpu_clock_1_out_write));
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line14 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((ranger_cpu_clock_1_out_address /= ranger_cpu_clock_1_out_address_last_time))))) = '1' then 
          write(write_line14, now);
          write(write_line14, string'(": "));
          write(write_line14, string'("ranger_cpu_clock_1_out_address did not heed wait!!!"));
          write(output, write_line14.all);
          deallocate (write_line14);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_1_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_1_out_read_last_time <= ranger_cpu_clock_1_out_read;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line15 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ranger_cpu_clock_1_out_read) /= std_logic'(ranger_cpu_clock_1_out_read_last_time)))))) = '1' then 
          write(write_line15, now);
          write(write_line15, string'(": "));
          write(write_line15, string'("ranger_cpu_clock_1_out_read did not heed wait!!!"));
          write(output, write_line15.all);
          deallocate (write_line15);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_1_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_1_out_write_last_time <= ranger_cpu_clock_1_out_write;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line16 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ranger_cpu_clock_1_out_write) /= std_logic'(ranger_cpu_clock_1_out_write_last_time)))))) = '1' then 
          write(write_line16, now);
          write(write_line16, string'(": "));
          write(write_line16, string'("ranger_cpu_clock_1_out_write did not heed wait!!!"));
          write(output, write_line16.all);
          deallocate (write_line16);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_1_out_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_1_out_writedata_last_time <= ranger_cpu_clock_1_out_writedata;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_1_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line17 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((ranger_cpu_clock_1_out_writedata /= ranger_cpu_clock_1_out_writedata_last_time)))) AND ranger_cpu_clock_1_out_write)) = '1' then 
          write(write_line17, now);
          write(write_line17, string'(": "));
          write(write_line17, string'("ranger_cpu_clock_1_out_writedata did not heed wait!!!"));
          write(output, write_line17.all);
          deallocate (write_line17);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu_clock_2_in_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_2_in_endofpacket : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_2_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                 signal cpu_data_master_requests_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                 signal d1_ranger_cpu_clock_2_in_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_2_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_clock_2_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_in_nativeaddress : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ranger_cpu_clock_2_in_read : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_2_in_reset_n : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_in_write : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity ranger_cpu_clock_2_in_arbitrator;


architecture europa of ranger_cpu_clock_2_in_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal internal_cpu_data_master_requests_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal internal_ranger_cpu_clock_2_in_waitrequest_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_allgrants :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_allow_new_arb_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_any_continuerequest :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_arb_counter_enable :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_arb_share_counter :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_arb_share_counter_next_value :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_arb_share_set_values :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_beginbursttransfer_internal :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_begins_xfer :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_end_xfer :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_grant_vector :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_in_a_read_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_in_a_write_cycle :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_master_qreq_vector :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_non_bursting_master_requests :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_reg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_slavearbiterlockenable :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_unreg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_waits_for_read :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_waits_for_write :  STD_LOGIC;
                signal wait_for_ranger_cpu_clock_2_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT ranger_cpu_clock_2_in_end_xfer;
      end if;
    end if;

  end process;

  ranger_cpu_clock_2_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_ranger_cpu_clock_2_in);
  --assign ranger_cpu_clock_2_in_readdata_from_sa = ranger_cpu_clock_2_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_clock_2_in_readdata_from_sa <= ranger_cpu_clock_2_in_readdata;
  internal_cpu_data_master_requests_ranger_cpu_clock_2_in <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 25) & std_logic_vector'("0000000000000000000000000")) = std_logic_vector'("110000000000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign ranger_cpu_clock_2_in_waitrequest_from_sa = ranger_cpu_clock_2_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_ranger_cpu_clock_2_in_waitrequest_from_sa <= ranger_cpu_clock_2_in_waitrequest;
  --ranger_cpu_clock_2_in_arb_share_counter set values, which is an e_mux
  ranger_cpu_clock_2_in_arb_share_set_values <= std_logic'('1');
  --ranger_cpu_clock_2_in_non_bursting_master_requests mux, which is an e_mux
  ranger_cpu_clock_2_in_non_bursting_master_requests <= internal_cpu_data_master_requests_ranger_cpu_clock_2_in;
  --ranger_cpu_clock_2_in_any_bursting_master_saved_grant mux, which is an e_mux
  ranger_cpu_clock_2_in_any_bursting_master_saved_grant <= std_logic'('0');
  --ranger_cpu_clock_2_in_arb_share_counter_next_value assignment, which is an e_assign
  ranger_cpu_clock_2_in_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_2_in_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_2_in_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ranger_cpu_clock_2_in_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_clock_2_in_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ranger_cpu_clock_2_in_allgrants all slave grants, which is an e_mux
  ranger_cpu_clock_2_in_allgrants <= ranger_cpu_clock_2_in_grant_vector;
  --ranger_cpu_clock_2_in_end_xfer assignment, which is an e_assign
  ranger_cpu_clock_2_in_end_xfer <= NOT ((ranger_cpu_clock_2_in_waits_for_read OR ranger_cpu_clock_2_in_waits_for_write));
  --end_xfer_arb_share_counter_term_ranger_cpu_clock_2_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ranger_cpu_clock_2_in <= ranger_cpu_clock_2_in_end_xfer AND (((NOT ranger_cpu_clock_2_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ranger_cpu_clock_2_in_arb_share_counter arbitration counter enable, which is an e_assign
  ranger_cpu_clock_2_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ranger_cpu_clock_2_in AND ranger_cpu_clock_2_in_allgrants)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_clock_2_in AND NOT ranger_cpu_clock_2_in_non_bursting_master_requests));
  --ranger_cpu_clock_2_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_2_in_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_clock_2_in_arb_counter_enable) = '1' then 
        ranger_cpu_clock_2_in_arb_share_counter <= ranger_cpu_clock_2_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_2_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_2_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((ranger_cpu_clock_2_in_master_qreq_vector AND end_xfer_arb_share_counter_term_ranger_cpu_clock_2_in)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_clock_2_in AND NOT ranger_cpu_clock_2_in_non_bursting_master_requests)))) = '1' then 
        ranger_cpu_clock_2_in_slavearbiterlockenable <= ranger_cpu_clock_2_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master ranger_cpu_clock_2/in arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= ranger_cpu_clock_2_in_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --ranger_cpu_clock_2_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ranger_cpu_clock_2_in_slavearbiterlockenable2 <= ranger_cpu_clock_2_in_arb_share_counter_next_value;
  --cpu/data_master ranger_cpu_clock_2/in arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= ranger_cpu_clock_2_in_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --ranger_cpu_clock_2_in_any_continuerequest at least one master continues requesting, which is an e_assign
  ranger_cpu_clock_2_in_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_ranger_cpu_clock_2_in <= internal_cpu_data_master_requests_ranger_cpu_clock_2_in AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --ranger_cpu_clock_2_in_writedata mux, which is an e_mux
  ranger_cpu_clock_2_in_writedata <= cpu_data_master_writedata;
  --assign ranger_cpu_clock_2_in_endofpacket_from_sa = ranger_cpu_clock_2_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_clock_2_in_endofpacket_from_sa <= ranger_cpu_clock_2_in_endofpacket;
  --master is always granted when requested
  internal_cpu_data_master_granted_ranger_cpu_clock_2_in <= internal_cpu_data_master_qualified_request_ranger_cpu_clock_2_in;
  --cpu/data_master saved-grant ranger_cpu_clock_2/in, which is an e_assign
  cpu_data_master_saved_grant_ranger_cpu_clock_2_in <= internal_cpu_data_master_requests_ranger_cpu_clock_2_in;
  --allow new arb cycle for ranger_cpu_clock_2/in, which is an e_assign
  ranger_cpu_clock_2_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  ranger_cpu_clock_2_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  ranger_cpu_clock_2_in_master_qreq_vector <= std_logic'('1');
  --ranger_cpu_clock_2_in_reset_n assignment, which is an e_assign
  ranger_cpu_clock_2_in_reset_n <= reset_n;
  --ranger_cpu_clock_2_in_firsttransfer first transaction, which is an e_assign
  ranger_cpu_clock_2_in_firsttransfer <= A_WE_StdLogic((std_logic'(ranger_cpu_clock_2_in_begins_xfer) = '1'), ranger_cpu_clock_2_in_unreg_firsttransfer, ranger_cpu_clock_2_in_reg_firsttransfer);
  --ranger_cpu_clock_2_in_unreg_firsttransfer first transaction, which is an e_assign
  ranger_cpu_clock_2_in_unreg_firsttransfer <= NOT ((ranger_cpu_clock_2_in_slavearbiterlockenable AND ranger_cpu_clock_2_in_any_continuerequest));
  --ranger_cpu_clock_2_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_clock_2_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_clock_2_in_begins_xfer) = '1' then 
        ranger_cpu_clock_2_in_reg_firsttransfer <= ranger_cpu_clock_2_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_2_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ranger_cpu_clock_2_in_beginbursttransfer_internal <= ranger_cpu_clock_2_in_begins_xfer;
  --ranger_cpu_clock_2_in_read assignment, which is an e_mux
  ranger_cpu_clock_2_in_read <= internal_cpu_data_master_granted_ranger_cpu_clock_2_in AND cpu_data_master_read;
  --ranger_cpu_clock_2_in_write assignment, which is an e_mux
  ranger_cpu_clock_2_in_write <= internal_cpu_data_master_granted_ranger_cpu_clock_2_in AND cpu_data_master_write;
  --ranger_cpu_clock_2_in_address mux, which is an e_mux
  ranger_cpu_clock_2_in_address <= cpu_data_master_address_to_slave (24 DOWNTO 0);
  --slaveid ranger_cpu_clock_2_in_nativeaddress nativeaddress mux, which is an e_mux
  ranger_cpu_clock_2_in_nativeaddress <= A_EXT (A_SRL(cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 23);
  --d1_ranger_cpu_clock_2_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ranger_cpu_clock_2_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_ranger_cpu_clock_2_in_end_xfer <= ranger_cpu_clock_2_in_end_xfer;
      end if;
    end if;

  end process;

  --ranger_cpu_clock_2_in_waits_for_read in a cycle, which is an e_mux
  ranger_cpu_clock_2_in_waits_for_read <= ranger_cpu_clock_2_in_in_a_read_cycle AND internal_ranger_cpu_clock_2_in_waitrequest_from_sa;
  --ranger_cpu_clock_2_in_in_a_read_cycle assignment, which is an e_assign
  ranger_cpu_clock_2_in_in_a_read_cycle <= internal_cpu_data_master_granted_ranger_cpu_clock_2_in AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ranger_cpu_clock_2_in_in_a_read_cycle;
  --ranger_cpu_clock_2_in_waits_for_write in a cycle, which is an e_mux
  ranger_cpu_clock_2_in_waits_for_write <= ranger_cpu_clock_2_in_in_a_write_cycle AND internal_ranger_cpu_clock_2_in_waitrequest_from_sa;
  --ranger_cpu_clock_2_in_in_a_write_cycle assignment, which is an e_assign
  ranger_cpu_clock_2_in_in_a_write_cycle <= internal_cpu_data_master_granted_ranger_cpu_clock_2_in AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ranger_cpu_clock_2_in_in_a_write_cycle;
  wait_for_ranger_cpu_clock_2_in_counter <= std_logic'('0');
  --ranger_cpu_clock_2_in_byteenable byte enable port mux, which is an e_mux
  ranger_cpu_clock_2_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_ranger_cpu_clock_2_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  cpu_data_master_granted_ranger_cpu_clock_2_in <= internal_cpu_data_master_granted_ranger_cpu_clock_2_in;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_ranger_cpu_clock_2_in <= internal_cpu_data_master_qualified_request_ranger_cpu_clock_2_in;
  --vhdl renameroo for output signals
  cpu_data_master_requests_ranger_cpu_clock_2_in <= internal_cpu_data_master_requests_ranger_cpu_clock_2_in;
  --vhdl renameroo for output signals
  ranger_cpu_clock_2_in_waitrequest_from_sa <= internal_ranger_cpu_clock_2_in_waitrequest_from_sa;
--synthesis translate_off
    --ranger_cpu_clock_2/in enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity ranger_cpu_clock_2_out_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_ddr2_devb_s1_end_xfer : IN STD_LOGIC;
                 signal ddr2_devb_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ddr2_devb_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_2_out_granted_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_read : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_requests_ddr2_devb_s1 : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_write : IN STD_LOGIC;
                 signal ranger_cpu_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ranger_cpu_clock_2_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ranger_cpu_clock_2_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_clock_2_out_reset_n : OUT STD_LOGIC;
                 signal ranger_cpu_clock_2_out_waitrequest : OUT STD_LOGIC
              );
end entity ranger_cpu_clock_2_out_arbitrator;


architecture europa of ranger_cpu_clock_2_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_ranger_cpu_clock_2_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal internal_ranger_cpu_clock_2_out_waitrequest :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_address_last_time :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_2_out_read_last_time :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_run :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_write_last_time :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 OR ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1) OR NOT ranger_cpu_clock_2_out_requests_ddr2_devb_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_2_out_granted_ddr2_devb_s1 OR NOT ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 OR NOT ranger_cpu_clock_2_out_read) OR ((ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 AND ranger_cpu_clock_2_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 OR NOT ((ranger_cpu_clock_2_out_read OR ranger_cpu_clock_2_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ddr2_devb_s1_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_clock_2_out_read OR ranger_cpu_clock_2_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  ranger_cpu_clock_2_out_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_ranger_cpu_clock_2_out_address_to_slave <= ranger_cpu_clock_2_out_address;
  --ranger_cpu_clock_2/out readdata mux, which is an e_mux
  ranger_cpu_clock_2_out_readdata <= ddr2_devb_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_ranger_cpu_clock_2_out_waitrequest <= NOT ranger_cpu_clock_2_out_run;
  --ranger_cpu_clock_2_out_reset_n assignment, which is an e_assign
  ranger_cpu_clock_2_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  ranger_cpu_clock_2_out_address_to_slave <= internal_ranger_cpu_clock_2_out_address_to_slave;
  --vhdl renameroo for output signals
  ranger_cpu_clock_2_out_waitrequest <= internal_ranger_cpu_clock_2_out_waitrequest;
--synthesis translate_off
    --ranger_cpu_clock_2_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_2_out_address_last_time <= std_logic_vector'("0000000000000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_2_out_address_last_time <= ranger_cpu_clock_2_out_address;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          active_and_waiting_last_time <= internal_ranger_cpu_clock_2_out_waitrequest AND ((ranger_cpu_clock_2_out_read OR ranger_cpu_clock_2_out_write));
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line18 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((ranger_cpu_clock_2_out_address /= ranger_cpu_clock_2_out_address_last_time))))) = '1' then 
          write(write_line18, now);
          write(write_line18, string'(": "));
          write(write_line18, string'("ranger_cpu_clock_2_out_address did not heed wait!!!"));
          write(output, write_line18.all);
          deallocate (write_line18);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_2_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_2_out_read_last_time <= ranger_cpu_clock_2_out_read;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line19 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ranger_cpu_clock_2_out_read) /= std_logic'(ranger_cpu_clock_2_out_read_last_time)))))) = '1' then 
          write(write_line19, now);
          write(write_line19, string'(": "));
          write(write_line19, string'("ranger_cpu_clock_2_out_read did not heed wait!!!"));
          write(output, write_line19.all);
          deallocate (write_line19);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_2_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_2_out_write_last_time <= ranger_cpu_clock_2_out_write;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line20 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ranger_cpu_clock_2_out_write) /= std_logic'(ranger_cpu_clock_2_out_write_last_time)))))) = '1' then 
          write(write_line20, now);
          write(write_line20, string'(": "));
          write(write_line20, string'("ranger_cpu_clock_2_out_write did not heed wait!!!"));
          write(output, write_line20.all);
          deallocate (write_line20);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_clock_2_out_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_clock_2_out_writedata_last_time <= ranger_cpu_clock_2_out_writedata;
        end if;
      end if;

    end process;

    --ranger_cpu_clock_2_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line21 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((ranger_cpu_clock_2_out_writedata /= ranger_cpu_clock_2_out_writedata_last_time)))) AND ranger_cpu_clock_2_out_write)) = '1' then 
          write(write_line21, now);
          write(write_line21, string'(": "));
          write(write_line21, string'("ranger_cpu_clock_2_out_writedata did not heed wait!!!"));
          write(output, write_line21.all);
          deallocate (write_line21);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sysid_control_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                 signal sysid_control_slave_address : OUT STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity sysid_control_slave_arbitrator;


architecture europa of sysid_control_slave_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_sysid_control_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sysid_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal shifted_address_to_sysid_control_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal sysid_control_slave_allgrants :  STD_LOGIC;
                signal sysid_control_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal sysid_control_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sysid_control_slave_any_continuerequest :  STD_LOGIC;
                signal sysid_control_slave_arb_counter_enable :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal sysid_control_slave_arb_share_set_values :  STD_LOGIC;
                signal sysid_control_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal sysid_control_slave_begins_xfer :  STD_LOGIC;
                signal sysid_control_slave_end_xfer :  STD_LOGIC;
                signal sysid_control_slave_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_grant_vector :  STD_LOGIC;
                signal sysid_control_slave_in_a_read_cycle :  STD_LOGIC;
                signal sysid_control_slave_in_a_write_cycle :  STD_LOGIC;
                signal sysid_control_slave_master_qreq_vector :  STD_LOGIC;
                signal sysid_control_slave_non_bursting_master_requests :  STD_LOGIC;
                signal sysid_control_slave_reg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal sysid_control_slave_unreg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_waits_for_read :  STD_LOGIC;
                signal sysid_control_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_sysid_control_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT sysid_control_slave_end_xfer;
      end if;
    end if;

  end process;

  sysid_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_sysid_control_slave);
  --assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sysid_control_slave_readdata_from_sa <= sysid_control_slave_readdata;
  internal_cpu_data_master_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("000000101000101000001011000")))) AND ((cpu_data_master_read OR cpu_data_master_write)))) AND cpu_data_master_read;
  --sysid_control_slave_arb_share_counter set values, which is an e_mux
  sysid_control_slave_arb_share_set_values <= std_logic'('1');
  --sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  sysid_control_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_sysid_control_slave;
  --sysid_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  sysid_control_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --sysid_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  sysid_control_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(sysid_control_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(sysid_control_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --sysid_control_slave_allgrants all slave grants, which is an e_mux
  sysid_control_slave_allgrants <= sysid_control_slave_grant_vector;
  --sysid_control_slave_end_xfer assignment, which is an e_assign
  sysid_control_slave_end_xfer <= NOT ((sysid_control_slave_waits_for_read OR sysid_control_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_sysid_control_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sysid_control_slave <= sysid_control_slave_end_xfer AND (((NOT sysid_control_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sysid_control_slave_arb_share_counter arbitration counter enable, which is an e_assign
  sysid_control_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sysid_control_slave AND sysid_control_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests));
  --sysid_control_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_arb_counter_enable) = '1' then 
        sysid_control_slave_arb_share_counter <= sysid_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sysid_control_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((sysid_control_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_sysid_control_slave)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests)))) = '1' then 
        sysid_control_slave_slavearbiterlockenable <= sysid_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master sysid/control_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= sysid_control_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sysid_control_slave_slavearbiterlockenable2 <= sysid_control_slave_arb_share_counter_next_value;
  --cpu/data_master sysid/control_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= sysid_control_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  sysid_control_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_sysid_control_slave <= internal_cpu_data_master_requests_sysid_control_slave;
  --master is always granted when requested
  internal_cpu_data_master_granted_sysid_control_slave <= internal_cpu_data_master_qualified_request_sysid_control_slave;
  --cpu/data_master saved-grant sysid/control_slave, which is an e_assign
  cpu_data_master_saved_grant_sysid_control_slave <= internal_cpu_data_master_requests_sysid_control_slave;
  --allow new arb cycle for sysid/control_slave, which is an e_assign
  sysid_control_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  sysid_control_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  sysid_control_slave_master_qreq_vector <= std_logic'('1');
  --sysid_control_slave_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_firsttransfer <= A_WE_StdLogic((std_logic'(sysid_control_slave_begins_xfer) = '1'), sysid_control_slave_unreg_firsttransfer, sysid_control_slave_reg_firsttransfer);
  --sysid_control_slave_unreg_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_unreg_firsttransfer <= NOT ((sysid_control_slave_slavearbiterlockenable AND sysid_control_slave_any_continuerequest));
  --sysid_control_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_begins_xfer) = '1' then 
        sysid_control_slave_reg_firsttransfer <= sysid_control_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sysid_control_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sysid_control_slave_beginbursttransfer_internal <= sysid_control_slave_begins_xfer;
  shifted_address_to_sysid_control_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --sysid_control_slave_address mux, which is an e_mux
  sysid_control_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_sysid_control_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_sysid_control_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sysid_control_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_sysid_control_slave_end_xfer <= sysid_control_slave_end_xfer;
      end if;
    end if;

  end process;

  --sysid_control_slave_waits_for_read in a cycle, which is an e_mux
  sysid_control_slave_waits_for_read <= sysid_control_slave_in_a_read_cycle AND sysid_control_slave_begins_xfer;
  --sysid_control_slave_in_a_read_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_read_cycle <= internal_cpu_data_master_granted_sysid_control_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sysid_control_slave_in_a_read_cycle;
  --sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  sysid_control_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_write_cycle <= internal_cpu_data_master_granted_sysid_control_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sysid_control_slave_in_a_write_cycle;
  wait_for_sysid_control_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_sysid_control_slave <= internal_cpu_data_master_granted_sysid_control_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_sysid_control_slave <= internal_cpu_data_master_qualified_request_sysid_control_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_sysid_control_slave <= internal_cpu_data_master_requests_sysid_control_slave;
--synthesis translate_off
    --sysid/control_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity timer_1ms_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal timer_1ms_s1_irq : IN STD_LOGIC;
                 signal timer_1ms_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_granted_timer_1ms_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_timer_1ms_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_timer_1ms_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_timer_1ms_s1 : OUT STD_LOGIC;
                 signal d1_timer_1ms_s1_end_xfer : OUT STD_LOGIC;
                 signal timer_1ms_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal timer_1ms_s1_chipselect : OUT STD_LOGIC;
                 signal timer_1ms_s1_irq_from_sa : OUT STD_LOGIC;
                 signal timer_1ms_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal timer_1ms_s1_reset_n : OUT STD_LOGIC;
                 signal timer_1ms_s1_write_n : OUT STD_LOGIC;
                 signal timer_1ms_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity timer_1ms_s1_arbitrator;


architecture europa of timer_1ms_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_timer_1ms_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_timer_1ms_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_timer_1ms_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_timer_1ms_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_timer_1ms_s1 :  STD_LOGIC;
                signal shifted_address_to_timer_1ms_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal timer_1ms_s1_allgrants :  STD_LOGIC;
                signal timer_1ms_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal timer_1ms_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal timer_1ms_s1_any_continuerequest :  STD_LOGIC;
                signal timer_1ms_s1_arb_counter_enable :  STD_LOGIC;
                signal timer_1ms_s1_arb_share_counter :  STD_LOGIC;
                signal timer_1ms_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal timer_1ms_s1_arb_share_set_values :  STD_LOGIC;
                signal timer_1ms_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal timer_1ms_s1_begins_xfer :  STD_LOGIC;
                signal timer_1ms_s1_end_xfer :  STD_LOGIC;
                signal timer_1ms_s1_firsttransfer :  STD_LOGIC;
                signal timer_1ms_s1_grant_vector :  STD_LOGIC;
                signal timer_1ms_s1_in_a_read_cycle :  STD_LOGIC;
                signal timer_1ms_s1_in_a_write_cycle :  STD_LOGIC;
                signal timer_1ms_s1_master_qreq_vector :  STD_LOGIC;
                signal timer_1ms_s1_non_bursting_master_requests :  STD_LOGIC;
                signal timer_1ms_s1_reg_firsttransfer :  STD_LOGIC;
                signal timer_1ms_s1_slavearbiterlockenable :  STD_LOGIC;
                signal timer_1ms_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal timer_1ms_s1_unreg_firsttransfer :  STD_LOGIC;
                signal timer_1ms_s1_waits_for_read :  STD_LOGIC;
                signal timer_1ms_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_timer_1ms_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT timer_1ms_s1_end_xfer;
      end if;
    end if;

  end process;

  timer_1ms_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_timer_1ms_s1);
  --assign timer_1ms_s1_readdata_from_sa = timer_1ms_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_1ms_s1_readdata_from_sa <= timer_1ms_s1_readdata;
  internal_cpu_data_master_requests_timer_1ms_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("000000101000101000000100000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --timer_1ms_s1_arb_share_counter set values, which is an e_mux
  timer_1ms_s1_arb_share_set_values <= std_logic'('1');
  --timer_1ms_s1_non_bursting_master_requests mux, which is an e_mux
  timer_1ms_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_timer_1ms_s1;
  --timer_1ms_s1_any_bursting_master_saved_grant mux, which is an e_mux
  timer_1ms_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --timer_1ms_s1_arb_share_counter_next_value assignment, which is an e_assign
  timer_1ms_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(timer_1ms_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_1ms_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(timer_1ms_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_1ms_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --timer_1ms_s1_allgrants all slave grants, which is an e_mux
  timer_1ms_s1_allgrants <= timer_1ms_s1_grant_vector;
  --timer_1ms_s1_end_xfer assignment, which is an e_assign
  timer_1ms_s1_end_xfer <= NOT ((timer_1ms_s1_waits_for_read OR timer_1ms_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_timer_1ms_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_timer_1ms_s1 <= timer_1ms_s1_end_xfer AND (((NOT timer_1ms_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --timer_1ms_s1_arb_share_counter arbitration counter enable, which is an e_assign
  timer_1ms_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_timer_1ms_s1 AND timer_1ms_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_timer_1ms_s1 AND NOT timer_1ms_s1_non_bursting_master_requests));
  --timer_1ms_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_1ms_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(timer_1ms_s1_arb_counter_enable) = '1' then 
        timer_1ms_s1_arb_share_counter <= timer_1ms_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --timer_1ms_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_1ms_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((timer_1ms_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_timer_1ms_s1)) OR ((end_xfer_arb_share_counter_term_timer_1ms_s1 AND NOT timer_1ms_s1_non_bursting_master_requests)))) = '1' then 
        timer_1ms_s1_slavearbiterlockenable <= timer_1ms_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master timer_1ms/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= timer_1ms_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --timer_1ms_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  timer_1ms_s1_slavearbiterlockenable2 <= timer_1ms_s1_arb_share_counter_next_value;
  --cpu/data_master timer_1ms/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= timer_1ms_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --timer_1ms_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  timer_1ms_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_timer_1ms_s1 <= internal_cpu_data_master_requests_timer_1ms_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --timer_1ms_s1_writedata mux, which is an e_mux
  timer_1ms_s1_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_timer_1ms_s1 <= internal_cpu_data_master_qualified_request_timer_1ms_s1;
  --cpu/data_master saved-grant timer_1ms/s1, which is an e_assign
  cpu_data_master_saved_grant_timer_1ms_s1 <= internal_cpu_data_master_requests_timer_1ms_s1;
  --allow new arb cycle for timer_1ms/s1, which is an e_assign
  timer_1ms_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  timer_1ms_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  timer_1ms_s1_master_qreq_vector <= std_logic'('1');
  --timer_1ms_s1_reset_n assignment, which is an e_assign
  timer_1ms_s1_reset_n <= reset_n;
  timer_1ms_s1_chipselect <= internal_cpu_data_master_granted_timer_1ms_s1;
  --timer_1ms_s1_firsttransfer first transaction, which is an e_assign
  timer_1ms_s1_firsttransfer <= A_WE_StdLogic((std_logic'(timer_1ms_s1_begins_xfer) = '1'), timer_1ms_s1_unreg_firsttransfer, timer_1ms_s1_reg_firsttransfer);
  --timer_1ms_s1_unreg_firsttransfer first transaction, which is an e_assign
  timer_1ms_s1_unreg_firsttransfer <= NOT ((timer_1ms_s1_slavearbiterlockenable AND timer_1ms_s1_any_continuerequest));
  --timer_1ms_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_1ms_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(timer_1ms_s1_begins_xfer) = '1' then 
        timer_1ms_s1_reg_firsttransfer <= timer_1ms_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --timer_1ms_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  timer_1ms_s1_beginbursttransfer_internal <= timer_1ms_s1_begins_xfer;
  --~timer_1ms_s1_write_n assignment, which is an e_mux
  timer_1ms_s1_write_n <= NOT ((internal_cpu_data_master_granted_timer_1ms_s1 AND cpu_data_master_write));
  shifted_address_to_timer_1ms_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --timer_1ms_s1_address mux, which is an e_mux
  timer_1ms_s1_address <= A_EXT (A_SRL(shifted_address_to_timer_1ms_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_timer_1ms_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_timer_1ms_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_timer_1ms_s1_end_xfer <= timer_1ms_s1_end_xfer;
      end if;
    end if;

  end process;

  --timer_1ms_s1_waits_for_read in a cycle, which is an e_mux
  timer_1ms_s1_waits_for_read <= timer_1ms_s1_in_a_read_cycle AND timer_1ms_s1_begins_xfer;
  --timer_1ms_s1_in_a_read_cycle assignment, which is an e_assign
  timer_1ms_s1_in_a_read_cycle <= internal_cpu_data_master_granted_timer_1ms_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= timer_1ms_s1_in_a_read_cycle;
  --timer_1ms_s1_waits_for_write in a cycle, which is an e_mux
  timer_1ms_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_1ms_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --timer_1ms_s1_in_a_write_cycle assignment, which is an e_assign
  timer_1ms_s1_in_a_write_cycle <= internal_cpu_data_master_granted_timer_1ms_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= timer_1ms_s1_in_a_write_cycle;
  wait_for_timer_1ms_s1_counter <= std_logic'('0');
  --assign timer_1ms_s1_irq_from_sa = timer_1ms_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_1ms_s1_irq_from_sa <= timer_1ms_s1_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_timer_1ms_s1 <= internal_cpu_data_master_granted_timer_1ms_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_timer_1ms_s1 <= internal_cpu_data_master_qualified_request_timer_1ms_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_timer_1ms_s1 <= internal_cpu_data_master_requests_timer_1ms_s1;
--synthesis translate_off
    --timer_1ms/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu_reset_clk100_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity ranger_cpu_reset_clk100_domain_synch_module;


architecture europa of ranger_cpu_reset_clk100_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_out <= data_in_d1;
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu_reset_ddr2_devb_phy_clk_out_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity ranger_cpu_reset_ddr2_devb_phy_clk_out_domain_synch_module;


architecture europa of ranger_cpu_reset_ddr2_devb_phy_clk_out_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_out <= data_in_d1;
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu_reset_clk50_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity ranger_cpu_reset_clk50_domain_synch_module;


architecture europa of ranger_cpu_reset_clk50_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_out <= data_in_d1;
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ranger_cpu is 
        port (
              -- 1) global signals:
                 signal clk100 : OUT STD_LOGIC;
                 signal clk125 : IN STD_LOGIC;
                 signal clk50 : IN STD_LOGIC;
                 signal ddr2_deva_aux_full_rate_clk_out : OUT STD_LOGIC;
                 signal ddr2_deva_aux_half_rate_clk_out : OUT STD_LOGIC;
                 signal ddr2_devb_aux_full_rate_clk_out : OUT STD_LOGIC;
                 signal ddr2_devb_aux_half_rate_clk_out : OUT STD_LOGIC;
                 signal ddr2_devb_phy_clk_out : OUT STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_BL
                 signal ex_addr_from_the_BL : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ex_clk_from_the_BL : OUT STD_LOGIC;
                 signal ex_din_from_the_BL : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_dout_to_the_BL : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_re_n_from_the_BL : OUT STD_LOGIC;
                 signal ex_reset_n_from_the_BL : OUT STD_LOGIC;
                 signal ex_we_n_from_the_BL : OUT STD_LOGIC;

              -- the_BR
                 signal ex_addr_from_the_BR : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ex_clk_from_the_BR : OUT STD_LOGIC;
                 signal ex_din_from_the_BR : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_dout_to_the_BR : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_re_n_from_the_BR : OUT STD_LOGIC;
                 signal ex_reset_n_from_the_BR : OUT STD_LOGIC;
                 signal ex_we_n_from_the_BR : OUT STD_LOGIC;

              -- the_TL
                 signal ex_addr_from_the_TL : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ex_clk_from_the_TL : OUT STD_LOGIC;
                 signal ex_din_from_the_TL : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_dout_to_the_TL : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_re_n_from_the_TL : OUT STD_LOGIC;
                 signal ex_reset_n_from_the_TL : OUT STD_LOGIC;
                 signal ex_we_n_from_the_TL : OUT STD_LOGIC;

              -- the_TR
                 signal ex_addr_from_the_TR : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ex_clk_from_the_TR : OUT STD_LOGIC;
                 signal ex_din_from_the_TR : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_dout_to_the_TR : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_re_n_from_the_TR : OUT STD_LOGIC;
                 signal ex_reset_n_from_the_TR : OUT STD_LOGIC;
                 signal ex_we_n_from_the_TR : OUT STD_LOGIC;

              -- the_control
                 signal ex_addr_from_the_control : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ex_clk_from_the_control : OUT STD_LOGIC;
                 signal ex_din_from_the_control : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_dout_to_the_control : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ex_re_n_from_the_control : OUT STD_LOGIC;
                 signal ex_reset_n_from_the_control : OUT STD_LOGIC;
                 signal ex_we_n_from_the_control : OUT STD_LOGIC;

              -- the_ddr2_deva
                 signal global_reset_n_to_the_ddr2_deva : IN STD_LOGIC;
                 signal local_init_done_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal local_refresh_ack_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal local_wdata_req_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal mem_addr_from_the_ddr2_deva : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal mem_ba_from_the_ddr2_deva : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_cas_n_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal mem_cke_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal mem_clk_n_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                 signal mem_clk_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                 signal mem_cs_n_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal mem_dm_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal mem_dq_to_and_from_the_ddr2_deva : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal mem_dqs_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                 signal mem_dqsn_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                 signal mem_odt_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal mem_ras_n_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal mem_we_n_from_the_ddr2_deva : OUT STD_LOGIC;
                 signal oct_ctl_rs_value_to_the_ddr2_deva : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal oct_ctl_rt_value_to_the_ddr2_deva : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal reset_phy_clk_n_from_the_ddr2_deva : OUT STD_LOGIC;

              -- the_ddr2_devb
                 signal global_reset_n_to_the_ddr2_devb : IN STD_LOGIC;
                 signal local_init_done_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal local_refresh_ack_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal local_wdata_req_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal mem_addr_from_the_ddr2_devb : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal mem_ba_from_the_ddr2_devb : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_cas_n_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal mem_cke_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal mem_clk_n_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                 signal mem_clk_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                 signal mem_cs_n_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal mem_dm_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal mem_dq_to_and_from_the_ddr2_devb : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal mem_dqs_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                 signal mem_dqsn_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                 signal mem_odt_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal mem_ras_n_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal mem_we_n_from_the_ddr2_devb : OUT STD_LOGIC;
                 signal oct_ctl_rs_value_to_the_ddr2_devb : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal oct_ctl_rt_value_to_the_ddr2_devb : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal reset_phy_clk_n_from_the_ddr2_devb : OUT STD_LOGIC;

              -- the_dm9000a
                 signal ENET_CLK_from_the_dm9000a : OUT STD_LOGIC;
                 signal ENET_CMD_from_the_dm9000a : OUT STD_LOGIC;
                 signal ENET_CS_N_from_the_dm9000a : OUT STD_LOGIC;
                 signal ENET_DATA_to_and_from_the_dm9000a : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ENET_INT_to_the_dm9000a : IN STD_LOGIC;
                 signal ENET_RD_N_from_the_dm9000a : OUT STD_LOGIC;
                 signal ENET_RST_N_from_the_dm9000a : OUT STD_LOGIC;
                 signal ENET_WR_N_from_the_dm9000a : OUT STD_LOGIC;
                 signal iOSC_50_to_the_dm9000a : IN STD_LOGIC;

              -- the_frame_received
                 signal in_port_to_the_frame_received : IN STD_LOGIC;

              -- the_laser_uart
                 signal rxd_to_the_laser_uart : IN STD_LOGIC;
                 signal txd_from_the_laser_uart : OUT STD_LOGIC
              );
end entity ranger_cpu;


architecture europa of ranger_cpu is
component BL_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal BL_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal BL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal BL_avalon_slave_read_n : OUT STD_LOGIC;
                    signal BL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal BL_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal BL_avalon_slave_write_n : OUT STD_LOGIC;
                    signal BL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_granted_BL_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_BL_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_BL_avalon_slave : OUT STD_LOGIC;
                    signal d1_BL_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC
                 );
end component BL_avalon_slave_arbitrator;

component BL is 
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
end component BL;

component BR_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal BR_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal BR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal BR_avalon_slave_read_n : OUT STD_LOGIC;
                    signal BR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal BR_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal BR_avalon_slave_write_n : OUT STD_LOGIC;
                    signal BR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_granted_BR_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_BR_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_BR_avalon_slave : OUT STD_LOGIC;
                    signal d1_BR_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC
                 );
end component BR_avalon_slave_arbitrator;

component BR is 
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
end component BR;

component TL_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal TL_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal TL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal TL_avalon_slave_read_n : OUT STD_LOGIC;
                    signal TL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TL_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal TL_avalon_slave_write_n : OUT STD_LOGIC;
                    signal TL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_granted_TL_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_TL_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_TL_avalon_slave : OUT STD_LOGIC;
                    signal d1_TL_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC
                 );
end component TL_avalon_slave_arbitrator;

component TL is 
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
end component TL;

component TR_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal TR_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal TR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal TR_avalon_slave_read_n : OUT STD_LOGIC;
                    signal TR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TR_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal TR_avalon_slave_write_n : OUT STD_LOGIC;
                    signal TR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_granted_TR_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_TR_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_TR_avalon_slave : OUT STD_LOGIC;
                    signal d1_TR_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC
                 );
end component TR_avalon_slave_arbitrator;

component TR is 
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
end component TR;

component control_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal control_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal control_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal control_avalon_slave_read_n : OUT STD_LOGIC;
                    signal control_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal control_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal control_avalon_slave_write_n : OUT STD_LOGIC;
                    signal control_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_granted_control_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_control_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_control_avalon_slave : OUT STD_LOGIC;
                    signal d1_control_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC
                 );
end component control_avalon_slave_arbitrator;

component control is 
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
end component control;

component cpu_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_debugaccess : IN STD_LOGIC;
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_jtag_debug_module_reset : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_write : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
                 );
end component cpu_jtag_debug_module_arbitrator;

component cpu_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal BL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal BR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal clk100 : IN STD_LOGIC;
                    signal clk100_reset_n : IN STD_LOGIC;
                    signal control_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_granted_BL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_BR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_TL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_TR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_control_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_granted_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_frame_received_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_laser_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_ranger_cpu_clock_0_in : IN STD_LOGIC;
                    signal cpu_data_master_granted_ranger_cpu_clock_2_in : IN STD_LOGIC;
                    signal cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_timer_1ms_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_BL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_BR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_TL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_TR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_control_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_frame_received_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_laser_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_ranger_cpu_clock_0_in : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_ranger_cpu_clock_2_in : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_timer_1ms_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_frame_received_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_laser_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ranger_cpu_clock_0_in : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ranger_cpu_clock_2_in : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_timer_1ms_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_BL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_BR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_TL_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_TR_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_control_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_requests_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_frame_received_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_laser_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_ranger_cpu_clock_0_in : IN STD_LOGIC;
                    signal cpu_data_master_requests_ranger_cpu_clock_2_in : IN STD_LOGIC;
                    signal cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_timer_1ms_s1 : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_BL_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_BR_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_TL_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_TR_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_control_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_ddr2_deva_s1_end_xfer : IN STD_LOGIC;
                    signal d1_frame_received_s1_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_laser_uart_s1_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                    signal d1_ranger_cpu_clock_0_in_end_xfer : IN STD_LOGIC;
                    signal d1_ranger_cpu_clock_2_in_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal d1_timer_1ms_s1_end_xfer : IN STD_LOGIC;
                    signal ddr2_deva_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_deva_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal dm9000a_avalon_slave_0_irq_from_sa : IN STD_LOGIC;
                    signal frame_received_s1_irq_from_sa : IN STD_LOGIC;
                    signal frame_received_s1_readdata_from_sa : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal laser_uart_s1_irq_from_sa : IN STD_LOGIC;
                    signal laser_uart_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ranger_cpu_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_2_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal timer_1ms_s1_irq_from_sa : IN STD_LOGIC;
                    signal timer_1ms_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_data_master_arbitrator;

component cpu_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_instruction_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_granted_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_granted_ranger_cpu_clock_1_in : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_ddr2_deva_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_ranger_cpu_clock_1_in : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_ddr2_deva_s1_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                    signal d1_ranger_cpu_clock_1_in_end_xfer : IN STD_LOGIC;
                    signal ddr2_deva_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_deva_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : OUT STD_LOGIC;
                    signal cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                    signal cpu_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_instruction_master_arbitrator;

component cpu is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d_irq : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_waitrequest : IN STD_LOGIC;
                    signal i_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_readdatavalid : IN STD_LOGIC;
                    signal i_waitrequest : IN STD_LOGIC;
                    signal jtag_debug_module_address : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal jtag_debug_module_begintransfer : IN STD_LOGIC;
                    signal jtag_debug_module_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal jtag_debug_module_clk : IN STD_LOGIC;
                    signal jtag_debug_module_debugaccess : IN STD_LOGIC;
                    signal jtag_debug_module_reset : IN STD_LOGIC;
                    signal jtag_debug_module_select : IN STD_LOGIC;
                    signal jtag_debug_module_write : IN STD_LOGIC;
                    signal jtag_debug_module_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component cpu;

component ddr2_deva_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal ddr2_deva_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_deva_s1_readdatavalid : IN STD_LOGIC;
                    signal ddr2_deva_s1_resetrequest_n : IN STD_LOGIC;
                    signal ddr2_deva_s1_waitrequest_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register : OUT STD_LOGIC;
                    signal cpu_data_master_requests_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_granted_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_ddr2_deva_s1 : OUT STD_LOGIC;
                    signal d1_ddr2_deva_s1_end_xfer : OUT STD_LOGIC;
                    signal ddr2_deva_s1_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ddr2_deva_s1_beginbursttransfer : OUT STD_LOGIC;
                    signal ddr2_deva_s1_burstcount : OUT STD_LOGIC;
                    signal ddr2_deva_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ddr2_deva_s1_read : OUT STD_LOGIC;
                    signal ddr2_deva_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_deva_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                    signal ddr2_deva_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                    signal ddr2_deva_s1_write : OUT STD_LOGIC;
                    signal ddr2_deva_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component ddr2_deva_s1_arbitrator;

component ranger_cpu_reset_clk125_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component ranger_cpu_reset_clk125_domain_synch_module;

component ddr2_deva is 
           port (
                 -- inputs:
                    signal global_reset_n : IN STD_LOGIC;
                    signal local_address : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal local_be : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal local_burstbegin : IN STD_LOGIC;
                    signal local_read_req : IN STD_LOGIC;
                    signal local_size : IN STD_LOGIC;
                    signal local_wdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal local_write_req : IN STD_LOGIC;
                    signal oct_ctl_rs_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal oct_ctl_rt_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal pll_ref_clk : IN STD_LOGIC;
                    signal soft_reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal aux_full_rate_clk : OUT STD_LOGIC;
                    signal aux_half_rate_clk : OUT STD_LOGIC;
                    signal local_init_done : OUT STD_LOGIC;
                    signal local_rdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal local_rdata_valid : OUT STD_LOGIC;
                    signal local_ready : OUT STD_LOGIC;
                    signal local_refresh_ack : OUT STD_LOGIC;
                    signal local_wdata_req : OUT STD_LOGIC;
                    signal mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_cas_n : OUT STD_LOGIC;
                    signal mem_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk_n : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dm : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dq : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dqs : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dqsn : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_ras_n : OUT STD_LOGIC;
                    signal mem_we_n : OUT STD_LOGIC;
                    signal phy_clk : OUT STD_LOGIC;
                    signal reset_phy_clk_n : OUT STD_LOGIC;
                    signal reset_request_n : OUT STD_LOGIC
                 );
end component ddr2_deva;

component ddr2_devb_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal ddr2_devb_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_devb_s1_readdatavalid : IN STD_LOGIC;
                    signal ddr2_devb_s1_resetrequest_n : IN STD_LOGIC;
                    signal ddr2_devb_s1_waitrequest_n : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_clock_1_out_read : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_write : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_2_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_2_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_clock_2_out_read : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_write : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_ddr2_devb_s1_end_xfer : OUT STD_LOGIC;
                    signal ddr2_devb_s1_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ddr2_devb_s1_beginbursttransfer : OUT STD_LOGIC;
                    signal ddr2_devb_s1_burstcount : OUT STD_LOGIC;
                    signal ddr2_devb_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ddr2_devb_s1_read : OUT STD_LOGIC;
                    signal ddr2_devb_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_devb_s1_resetrequest_n_from_sa : OUT STD_LOGIC;
                    signal ddr2_devb_s1_waitrequest_n_from_sa : OUT STD_LOGIC;
                    signal ddr2_devb_s1_write : OUT STD_LOGIC;
                    signal ddr2_devb_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_1_out_granted_ddr2_devb_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_out_requests_ddr2_devb_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_out_granted_ddr2_devb_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_out_requests_ddr2_devb_s1 : OUT STD_LOGIC
                 );
end component ddr2_devb_s1_arbitrator;

component ddr2_devb is 
           port (
                 -- inputs:
                    signal global_reset_n : IN STD_LOGIC;
                    signal local_address : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal local_be : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal local_burstbegin : IN STD_LOGIC;
                    signal local_read_req : IN STD_LOGIC;
                    signal local_size : IN STD_LOGIC;
                    signal local_wdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal local_write_req : IN STD_LOGIC;
                    signal oct_ctl_rs_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal oct_ctl_rt_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal pll_ref_clk : IN STD_LOGIC;
                    signal soft_reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal aux_full_rate_clk : OUT STD_LOGIC;
                    signal aux_half_rate_clk : OUT STD_LOGIC;
                    signal local_init_done : OUT STD_LOGIC;
                    signal local_rdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal local_rdata_valid : OUT STD_LOGIC;
                    signal local_ready : OUT STD_LOGIC;
                    signal local_refresh_ack : OUT STD_LOGIC;
                    signal local_wdata_req : OUT STD_LOGIC;
                    signal mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_cas_n : OUT STD_LOGIC;
                    signal mem_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_clk_n : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dm : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dq : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dqs : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_dqsn : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                    signal mem_ras_n : OUT STD_LOGIC;
                    signal mem_we_n : OUT STD_LOGIC;
                    signal phy_clk : OUT STD_LOGIC;
                    signal reset_phy_clk_n : OUT STD_LOGIC;
                    signal reset_request_n : OUT STD_LOGIC
                 );
end component ddr2_devb;

component dm9000a_avalon_slave_0_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal dm9000a_avalon_slave_0_irq : IN STD_LOGIC;
                    signal dm9000a_avalon_slave_0_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ranger_cpu_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ranger_cpu_clock_0_out_nativeaddress : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_read : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_write : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_dm9000a_avalon_slave_0_end_xfer : OUT STD_LOGIC;
                    signal dm9000a_avalon_slave_0_address : OUT STD_LOGIC;
                    signal dm9000a_avalon_slave_0_chipselect_n : OUT STD_LOGIC;
                    signal dm9000a_avalon_slave_0_irq_from_sa : OUT STD_LOGIC;
                    signal dm9000a_avalon_slave_0_read_n : OUT STD_LOGIC;
                    signal dm9000a_avalon_slave_0_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal dm9000a_avalon_slave_0_reset_n : OUT STD_LOGIC;
                    signal dm9000a_avalon_slave_0_write_n : OUT STD_LOGIC;
                    signal dm9000a_avalon_slave_0_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0 : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 : OUT STD_LOGIC
                 );
end component dm9000a_avalon_slave_0_arbitrator;

component dm9000a is 
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
end component dm9000a;

component frame_received_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal frame_received_s1_irq : IN STD_LOGIC;
                    signal frame_received_s1_readdata : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_frame_received_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_frame_received_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_frame_received_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_frame_received_s1 : OUT STD_LOGIC;
                    signal d1_frame_received_s1_end_xfer : OUT STD_LOGIC;
                    signal frame_received_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal frame_received_s1_chipselect : OUT STD_LOGIC;
                    signal frame_received_s1_irq_from_sa : OUT STD_LOGIC;
                    signal frame_received_s1_readdata_from_sa : OUT STD_LOGIC;
                    signal frame_received_s1_reset_n : OUT STD_LOGIC;
                    signal frame_received_s1_write_n : OUT STD_LOGIC;
                    signal frame_received_s1_writedata : OUT STD_LOGIC
                 );
end component frame_received_s1_arbitrator;

component frame_received is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC;

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC
                 );
end component frame_received;

component jtag_uart_avalon_jtag_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal d1_jtag_uart_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_address : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jtag_uart_avalon_jtag_slave_arbitrator;

component jtag_uart is 
           port (
                 -- inputs:
                    signal av_address : IN STD_LOGIC;
                    signal av_chipselect : IN STD_LOGIC;
                    signal av_read_n : IN STD_LOGIC;
                    signal av_write_n : IN STD_LOGIC;
                    signal av_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal rst_n : IN STD_LOGIC;

                 -- outputs:
                    signal av_irq : OUT STD_LOGIC;
                    signal av_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal av_waitrequest : OUT STD_LOGIC;
                    signal dataavailable : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component jtag_uart;

component laser_uart_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal laser_uart_s1_dataavailable : IN STD_LOGIC;
                    signal laser_uart_s1_irq : IN STD_LOGIC;
                    signal laser_uart_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal laser_uart_s1_readyfordata : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_laser_uart_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_laser_uart_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_laser_uart_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_laser_uart_s1 : OUT STD_LOGIC;
                    signal d1_laser_uart_s1_end_xfer : OUT STD_LOGIC;
                    signal laser_uart_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal laser_uart_s1_begintransfer : OUT STD_LOGIC;
                    signal laser_uart_s1_chipselect : OUT STD_LOGIC;
                    signal laser_uart_s1_dataavailable_from_sa : OUT STD_LOGIC;
                    signal laser_uart_s1_irq_from_sa : OUT STD_LOGIC;
                    signal laser_uart_s1_read_n : OUT STD_LOGIC;
                    signal laser_uart_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal laser_uart_s1_readyfordata_from_sa : OUT STD_LOGIC;
                    signal laser_uart_s1_reset_n : OUT STD_LOGIC;
                    signal laser_uart_s1_write_n : OUT STD_LOGIC;
                    signal laser_uart_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component laser_uart_s1_arbitrator;

component laser_uart is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal begintransfer : IN STD_LOGIC;
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal rxd : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal dataavailable : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal readyfordata : OUT STD_LOGIC;
                    signal txd : OUT STD_LOGIC
                 );
end component laser_uart;

component onchip_mem_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_mem_s1_address : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
                    signal onchip_mem_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_mem_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_mem_s1_clken : OUT STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_mem_s1_write : OUT STD_LOGIC;
                    signal onchip_mem_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC
                 );
end component onchip_mem_s1_arbitrator;

component onchip_mem is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
                    signal byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal clken : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component onchip_mem;

component ranger_cpu_clock_0_in_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_0_in_endofpacket : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ranger_cpu_clock_0_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                    signal cpu_data_master_requests_ranger_cpu_clock_0_in : OUT STD_LOGIC;
                    signal d1_ranger_cpu_clock_0_in_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_in_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ranger_cpu_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ranger_cpu_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_in_nativeaddress : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_in_read : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ranger_cpu_clock_0_in_reset_n : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_in_write : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component ranger_cpu_clock_0_in_arbitrator;

component ranger_cpu_clock_0_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_dm9000a_avalon_slave_0_end_xfer : IN STD_LOGIC;
                    signal dm9000a_avalon_slave_0_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ranger_cpu_clock_0_out_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_read : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_write : IN STD_LOGIC;
                    signal ranger_cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ranger_cpu_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ranger_cpu_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ranger_cpu_clock_0_out_reset_n : OUT STD_LOGIC;
                    signal ranger_cpu_clock_0_out_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_clock_0_out_arbitrator;

component ranger_cpu_clock_0 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC;
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC;
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_clock_0;

component ranger_cpu_clock_1_in_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_in_endofpacket : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_1_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_instruction_master_granted_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_ranger_cpu_clock_1_in : OUT STD_LOGIC;
                    signal d1_ranger_cpu_clock_1_in_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ranger_cpu_clock_1_in_read : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_1_in_reset_n : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_in_write : OUT STD_LOGIC
                 );
end component ranger_cpu_clock_1_in_arbitrator;

component ranger_cpu_clock_1_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_ddr2_devb_s1_end_xfer : IN STD_LOGIC;
                    signal ddr2_devb_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_devb_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_1_out_granted_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_read : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_requests_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_write : IN STD_LOGIC;
                    signal ranger_cpu_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ranger_cpu_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_1_out_reset_n : OUT STD_LOGIC;
                    signal ranger_cpu_clock_1_out_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_clock_1_out_arbitrator;

component ranger_cpu_clock_1 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_clock_1;

component ranger_cpu_clock_2_in_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_2_in_endofpacket : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_2_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                    signal cpu_data_master_requests_ranger_cpu_clock_2_in : OUT STD_LOGIC;
                    signal d1_ranger_cpu_clock_2_in_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_2_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_clock_2_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_in_nativeaddress : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ranger_cpu_clock_2_in_read : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_2_in_reset_n : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_in_write : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component ranger_cpu_clock_2_in_arbitrator;

component ranger_cpu_clock_2_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_ddr2_devb_s1_end_xfer : IN STD_LOGIC;
                    signal ddr2_devb_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ddr2_devb_s1_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_2_out_granted_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_read : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_requests_ddr2_devb_s1 : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_write : IN STD_LOGIC;
                    signal ranger_cpu_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ranger_cpu_clock_2_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ranger_cpu_clock_2_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_clock_2_out_reset_n : OUT STD_LOGIC;
                    signal ranger_cpu_clock_2_out_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_clock_2_out_arbitrator;

component ranger_cpu_clock_2 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_clock_2;

component sysid_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                    signal sysid_control_slave_address : OUT STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sysid_control_slave_arbitrator;

component sysid is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sysid;

component timer_1ms_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal timer_1ms_s1_irq : IN STD_LOGIC;
                    signal timer_1ms_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_granted_timer_1ms_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_timer_1ms_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_timer_1ms_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_timer_1ms_s1 : OUT STD_LOGIC;
                    signal d1_timer_1ms_s1_end_xfer : OUT STD_LOGIC;
                    signal timer_1ms_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal timer_1ms_s1_chipselect : OUT STD_LOGIC;
                    signal timer_1ms_s1_irq_from_sa : OUT STD_LOGIC;
                    signal timer_1ms_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal timer_1ms_s1_reset_n : OUT STD_LOGIC;
                    signal timer_1ms_s1_write_n : OUT STD_LOGIC;
                    signal timer_1ms_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_1ms_s1_arbitrator;

component timer_1ms is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_1ms;

component ranger_cpu_reset_clk100_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component ranger_cpu_reset_clk100_domain_synch_module;

component ranger_cpu_reset_ddr2_devb_phy_clk_out_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component ranger_cpu_reset_ddr2_devb_phy_clk_out_domain_synch_module;

component ranger_cpu_reset_clk50_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component ranger_cpu_reset_clk50_domain_synch_module;

                signal BL_avalon_slave_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal BL_avalon_slave_read_n :  STD_LOGIC;
                signal BL_avalon_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal BL_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal BL_avalon_slave_reset_n :  STD_LOGIC;
                signal BL_avalon_slave_write_n :  STD_LOGIC;
                signal BL_avalon_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal BR_avalon_slave_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal BR_avalon_slave_read_n :  STD_LOGIC;
                signal BR_avalon_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal BR_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal BR_avalon_slave_reset_n :  STD_LOGIC;
                signal BR_avalon_slave_write_n :  STD_LOGIC;
                signal BR_avalon_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal TL_avalon_slave_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal TL_avalon_slave_read_n :  STD_LOGIC;
                signal TL_avalon_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal TL_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal TL_avalon_slave_reset_n :  STD_LOGIC;
                signal TL_avalon_slave_write_n :  STD_LOGIC;
                signal TL_avalon_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal TR_avalon_slave_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal TR_avalon_slave_read_n :  STD_LOGIC;
                signal TR_avalon_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal TR_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal TR_avalon_slave_reset_n :  STD_LOGIC;
                signal TR_avalon_slave_write_n :  STD_LOGIC;
                signal TR_avalon_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clk100_reset_n :  STD_LOGIC;
                signal clk125_reset_n :  STD_LOGIC;
                signal clk50_reset_n :  STD_LOGIC;
                signal control_avalon_slave_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal control_avalon_slave_read_n :  STD_LOGIC;
                signal control_avalon_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal control_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal control_avalon_slave_reset_n :  STD_LOGIC;
                signal control_avalon_slave_write_n :  STD_LOGIC;
                signal control_avalon_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_data_master_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_data_master_debugaccess :  STD_LOGIC;
                signal cpu_data_master_granted_BL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_granted_BR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_granted_TL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_granted_TR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_granted_control_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_granted_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_frame_received_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_granted_laser_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal cpu_data_master_granted_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_granted_timer_1ms_s1 :  STD_LOGIC;
                signal cpu_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_data_master_qualified_request_BL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_BR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_TL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_TR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_control_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_qualified_request_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_frame_received_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_laser_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal cpu_data_master_qualified_request_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_timer_1ms_s1 :  STD_LOGIC;
                signal cpu_data_master_read :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_BL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_BR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_control_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_frame_received_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_laser_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_timer_1ms_s1 :  STD_LOGIC;
                signal cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_data_master_requests_BL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_requests_BR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_requests_TL_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_requests_TR_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_requests_control_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_requests_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_frame_received_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_requests_laser_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_ranger_cpu_clock_0_in :  STD_LOGIC;
                signal cpu_data_master_requests_ranger_cpu_clock_2_in :  STD_LOGIC;
                signal cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_requests_timer_1ms_s1 :  STD_LOGIC;
                signal cpu_data_master_waitrequest :  STD_LOGIC;
                signal cpu_data_master_write :  STD_LOGIC;
                signal cpu_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_instruction_master_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_instruction_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_granted_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_instruction_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_granted_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal cpu_instruction_master_read :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal cpu_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal cpu_instruction_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_requests_ddr2_deva_s1 :  STD_LOGIC;
                signal cpu_instruction_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_requests_ranger_cpu_clock_1_in :  STD_LOGIC;
                signal cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal cpu_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_jtag_debug_module_chipselect :  STD_LOGIC;
                signal cpu_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal cpu_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_jtag_debug_module_reset :  STD_LOGIC;
                signal cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal cpu_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal cpu_jtag_debug_module_write :  STD_LOGIC;
                signal cpu_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal d1_BL_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_BR_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_TL_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_TR_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_control_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_ddr2_deva_s1_end_xfer :  STD_LOGIC;
                signal d1_ddr2_devb_s1_end_xfer :  STD_LOGIC;
                signal d1_dm9000a_avalon_slave_0_end_xfer :  STD_LOGIC;
                signal d1_frame_received_s1_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_laser_uart_s1_end_xfer :  STD_LOGIC;
                signal d1_onchip_mem_s1_end_xfer :  STD_LOGIC;
                signal d1_ranger_cpu_clock_0_in_end_xfer :  STD_LOGIC;
                signal d1_ranger_cpu_clock_1_in_end_xfer :  STD_LOGIC;
                signal d1_ranger_cpu_clock_2_in_end_xfer :  STD_LOGIC;
                signal d1_sysid_control_slave_end_xfer :  STD_LOGIC;
                signal d1_timer_1ms_s1_end_xfer :  STD_LOGIC;
                signal ddr2_deva_s1_address :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ddr2_deva_s1_beginbursttransfer :  STD_LOGIC;
                signal ddr2_deva_s1_burstcount :  STD_LOGIC;
                signal ddr2_deva_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ddr2_deva_s1_read :  STD_LOGIC;
                signal ddr2_deva_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ddr2_deva_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ddr2_deva_s1_readdatavalid :  STD_LOGIC;
                signal ddr2_deva_s1_resetrequest_n :  STD_LOGIC;
                signal ddr2_deva_s1_resetrequest_n_from_sa :  STD_LOGIC;
                signal ddr2_deva_s1_waitrequest_n :  STD_LOGIC;
                signal ddr2_deva_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal ddr2_deva_s1_write :  STD_LOGIC;
                signal ddr2_deva_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ddr2_devb_phy_clk_out_reset_n :  STD_LOGIC;
                signal ddr2_devb_s1_address :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ddr2_devb_s1_beginbursttransfer :  STD_LOGIC;
                signal ddr2_devb_s1_burstcount :  STD_LOGIC;
                signal ddr2_devb_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ddr2_devb_s1_read :  STD_LOGIC;
                signal ddr2_devb_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ddr2_devb_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ddr2_devb_s1_readdatavalid :  STD_LOGIC;
                signal ddr2_devb_s1_resetrequest_n :  STD_LOGIC;
                signal ddr2_devb_s1_resetrequest_n_from_sa :  STD_LOGIC;
                signal ddr2_devb_s1_waitrequest_n :  STD_LOGIC;
                signal ddr2_devb_s1_waitrequest_n_from_sa :  STD_LOGIC;
                signal ddr2_devb_s1_write :  STD_LOGIC;
                signal ddr2_devb_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal dm9000a_avalon_slave_0_address :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_chipselect_n :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_irq :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_irq_from_sa :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_read_n :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dm9000a_avalon_slave_0_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dm9000a_avalon_slave_0_reset_n :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_write_n :  STD_LOGIC;
                signal dm9000a_avalon_slave_0_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal frame_received_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal frame_received_s1_chipselect :  STD_LOGIC;
                signal frame_received_s1_irq :  STD_LOGIC;
                signal frame_received_s1_irq_from_sa :  STD_LOGIC;
                signal frame_received_s1_readdata :  STD_LOGIC;
                signal frame_received_s1_readdata_from_sa :  STD_LOGIC;
                signal frame_received_s1_reset_n :  STD_LOGIC;
                signal frame_received_s1_write_n :  STD_LOGIC;
                signal frame_received_s1_writedata :  STD_LOGIC;
                signal internal_ENET_CLK_from_the_dm9000a :  STD_LOGIC;
                signal internal_ENET_CMD_from_the_dm9000a :  STD_LOGIC;
                signal internal_ENET_CS_N_from_the_dm9000a :  STD_LOGIC;
                signal internal_ENET_RD_N_from_the_dm9000a :  STD_LOGIC;
                signal internal_ENET_RST_N_from_the_dm9000a :  STD_LOGIC;
                signal internal_ENET_WR_N_from_the_dm9000a :  STD_LOGIC;
                signal internal_clk100 :  STD_LOGIC;
                signal internal_ddr2_devb_phy_clk_out :  STD_LOGIC;
                signal internal_ex_addr_from_the_BL :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ex_addr_from_the_BR :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ex_addr_from_the_TL :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ex_addr_from_the_TR :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ex_addr_from_the_control :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ex_clk_from_the_BL :  STD_LOGIC;
                signal internal_ex_clk_from_the_BR :  STD_LOGIC;
                signal internal_ex_clk_from_the_TL :  STD_LOGIC;
                signal internal_ex_clk_from_the_TR :  STD_LOGIC;
                signal internal_ex_clk_from_the_control :  STD_LOGIC;
                signal internal_ex_din_from_the_BL :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ex_din_from_the_BR :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ex_din_from_the_TL :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ex_din_from_the_TR :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ex_din_from_the_control :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ex_re_n_from_the_BL :  STD_LOGIC;
                signal internal_ex_re_n_from_the_BR :  STD_LOGIC;
                signal internal_ex_re_n_from_the_TL :  STD_LOGIC;
                signal internal_ex_re_n_from_the_TR :  STD_LOGIC;
                signal internal_ex_re_n_from_the_control :  STD_LOGIC;
                signal internal_ex_reset_n_from_the_BL :  STD_LOGIC;
                signal internal_ex_reset_n_from_the_BR :  STD_LOGIC;
                signal internal_ex_reset_n_from_the_TL :  STD_LOGIC;
                signal internal_ex_reset_n_from_the_TR :  STD_LOGIC;
                signal internal_ex_reset_n_from_the_control :  STD_LOGIC;
                signal internal_ex_we_n_from_the_BL :  STD_LOGIC;
                signal internal_ex_we_n_from_the_BR :  STD_LOGIC;
                signal internal_ex_we_n_from_the_TL :  STD_LOGIC;
                signal internal_ex_we_n_from_the_TR :  STD_LOGIC;
                signal internal_ex_we_n_from_the_control :  STD_LOGIC;
                signal internal_local_init_done_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_local_init_done_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_local_refresh_ack_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_local_refresh_ack_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_local_wdata_req_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_local_wdata_req_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_mem_addr_from_the_ddr2_deva :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_mem_addr_from_the_ddr2_devb :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_mem_ba_from_the_ddr2_deva :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_mem_ba_from_the_ddr2_devb :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_mem_cas_n_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_mem_cas_n_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_mem_cke_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_mem_cke_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_mem_cs_n_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_mem_cs_n_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_mem_dm_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_mem_dm_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_mem_odt_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_mem_odt_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_mem_ras_n_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_mem_ras_n_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_mem_we_n_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_mem_we_n_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_reset_phy_clk_n_from_the_ddr2_deva :  STD_LOGIC;
                signal internal_reset_phy_clk_n_from_the_ddr2_devb :  STD_LOGIC;
                signal internal_txd_from_the_laser_uart :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_address :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_chipselect :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_irq :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_read_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_readyfordata :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_reset_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waitrequest :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_write_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal laser_uart_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal laser_uart_s1_begintransfer :  STD_LOGIC;
                signal laser_uart_s1_chipselect :  STD_LOGIC;
                signal laser_uart_s1_dataavailable :  STD_LOGIC;
                signal laser_uart_s1_dataavailable_from_sa :  STD_LOGIC;
                signal laser_uart_s1_irq :  STD_LOGIC;
                signal laser_uart_s1_irq_from_sa :  STD_LOGIC;
                signal laser_uart_s1_read_n :  STD_LOGIC;
                signal laser_uart_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal laser_uart_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal laser_uart_s1_readyfordata :  STD_LOGIC;
                signal laser_uart_s1_readyfordata_from_sa :  STD_LOGIC;
                signal laser_uart_s1_reset_n :  STD_LOGIC;
                signal laser_uart_s1_write_n :  STD_LOGIC;
                signal laser_uart_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal module_input13 :  STD_LOGIC;
                signal module_input14 :  STD_LOGIC;
                signal module_input15 :  STD_LOGIC;
                signal module_input6 :  STD_LOGIC;
                signal onchip_mem_s1_address :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal onchip_mem_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_mem_s1_chipselect :  STD_LOGIC;
                signal onchip_mem_s1_clken :  STD_LOGIC;
                signal onchip_mem_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_mem_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_mem_s1_write :  STD_LOGIC;
                signal onchip_mem_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_clk_ddr2_deva_aux_full_rate_clk :  STD_LOGIC;
                signal out_clk_ddr2_deva_aux_half_rate_clk :  STD_LOGIC;
                signal out_clk_ddr2_deva_phy_clk :  STD_LOGIC;
                signal out_clk_ddr2_devb_aux_full_rate_clk :  STD_LOGIC;
                signal out_clk_ddr2_devb_aux_half_rate_clk :  STD_LOGIC;
                signal out_clk_ddr2_devb_phy_clk :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_clock_0_in_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_clock_0_in_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_nativeaddress :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_read :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ranger_cpu_clock_0_in_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ranger_cpu_clock_0_in_reset_n :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_waitrequest :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_write :  STD_LOGIC;
                signal ranger_cpu_clock_0_in_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ranger_cpu_clock_0_out_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_clock_0_out_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_clock_0_out_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_nativeaddress :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_read :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_reset_n :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_waitrequest :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_write :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ranger_cpu_clock_1_in_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_1_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ranger_cpu_clock_1_in_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_nativeaddress :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ranger_cpu_clock_1_in_read :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_1_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_1_in_reset_n :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_waitrequest :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_write :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_1_out_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_1_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ranger_cpu_clock_1_out_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_granted_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_read :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_1_out_requests_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_reset_n :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_waitrequest :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_write :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_2_in_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_2_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ranger_cpu_clock_2_in_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_endofpacket_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_nativeaddress :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ranger_cpu_clock_2_in_read :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_2_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_2_in_reset_n :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_waitrequest :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_waitrequest_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_write :  STD_LOGIC;
                signal ranger_cpu_clock_2_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_2_out_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_2_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ranger_cpu_clock_2_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ranger_cpu_clock_2_out_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_granted_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_nativeaddress :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_read :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_2_out_requests_ddr2_devb_s1 :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_reset_n :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_waitrequest :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_write :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal registered_cpu_data_master_read_data_valid_BL_avalon_slave :  STD_LOGIC;
                signal registered_cpu_data_master_read_data_valid_BR_avalon_slave :  STD_LOGIC;
                signal registered_cpu_data_master_read_data_valid_TL_avalon_slave :  STD_LOGIC;
                signal registered_cpu_data_master_read_data_valid_TR_avalon_slave :  STD_LOGIC;
                signal registered_cpu_data_master_read_data_valid_control_avalon_slave :  STD_LOGIC;
                signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal reset_n_sources :  STD_LOGIC;
                signal sysid_control_slave_address :  STD_LOGIC;
                signal sysid_control_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal timer_1ms_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_1ms_s1_chipselect :  STD_LOGIC;
                signal timer_1ms_s1_irq :  STD_LOGIC;
                signal timer_1ms_s1_irq_from_sa :  STD_LOGIC;
                signal timer_1ms_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_1ms_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_1ms_s1_reset_n :  STD_LOGIC;
                signal timer_1ms_s1_write_n :  STD_LOGIC;
                signal timer_1ms_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);

begin

  --the_BL_avalon_slave, which is an e_instance
  the_BL_avalon_slave : BL_avalon_slave_arbitrator
    port map(
      BL_avalon_slave_address => BL_avalon_slave_address,
      BL_avalon_slave_read_n => BL_avalon_slave_read_n,
      BL_avalon_slave_readdata_from_sa => BL_avalon_slave_readdata_from_sa,
      BL_avalon_slave_reset_n => BL_avalon_slave_reset_n,
      BL_avalon_slave_write_n => BL_avalon_slave_write_n,
      BL_avalon_slave_writedata => BL_avalon_slave_writedata,
      cpu_data_master_granted_BL_avalon_slave => cpu_data_master_granted_BL_avalon_slave,
      cpu_data_master_qualified_request_BL_avalon_slave => cpu_data_master_qualified_request_BL_avalon_slave,
      cpu_data_master_read_data_valid_BL_avalon_slave => cpu_data_master_read_data_valid_BL_avalon_slave,
      cpu_data_master_requests_BL_avalon_slave => cpu_data_master_requests_BL_avalon_slave,
      d1_BL_avalon_slave_end_xfer => d1_BL_avalon_slave_end_xfer,
      registered_cpu_data_master_read_data_valid_BL_avalon_slave => registered_cpu_data_master_read_data_valid_BL_avalon_slave,
      BL_avalon_slave_readdata => BL_avalon_slave_readdata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk100_reset_n
    );


  --the_BL, which is an e_ptf_instance
  the_BL : BL
    port map(
      ex_addr => internal_ex_addr_from_the_BL,
      ex_clk => internal_ex_clk_from_the_BL,
      ex_din => internal_ex_din_from_the_BL,
      ex_re_n => internal_ex_re_n_from_the_BL,
      ex_reset_n => internal_ex_reset_n_from_the_BL,
      ex_we_n => internal_ex_we_n_from_the_BL,
      nios_dout => BL_avalon_slave_readdata,
      clk => internal_clk100,
      ex_dout => ex_dout_to_the_BL,
      nios_addr => BL_avalon_slave_address,
      nios_din => BL_avalon_slave_writedata,
      nios_re_n => BL_avalon_slave_read_n,
      nios_we_n => BL_avalon_slave_write_n,
      reset_n => BL_avalon_slave_reset_n
    );


  --the_BR_avalon_slave, which is an e_instance
  the_BR_avalon_slave : BR_avalon_slave_arbitrator
    port map(
      BR_avalon_slave_address => BR_avalon_slave_address,
      BR_avalon_slave_read_n => BR_avalon_slave_read_n,
      BR_avalon_slave_readdata_from_sa => BR_avalon_slave_readdata_from_sa,
      BR_avalon_slave_reset_n => BR_avalon_slave_reset_n,
      BR_avalon_slave_write_n => BR_avalon_slave_write_n,
      BR_avalon_slave_writedata => BR_avalon_slave_writedata,
      cpu_data_master_granted_BR_avalon_slave => cpu_data_master_granted_BR_avalon_slave,
      cpu_data_master_qualified_request_BR_avalon_slave => cpu_data_master_qualified_request_BR_avalon_slave,
      cpu_data_master_read_data_valid_BR_avalon_slave => cpu_data_master_read_data_valid_BR_avalon_slave,
      cpu_data_master_requests_BR_avalon_slave => cpu_data_master_requests_BR_avalon_slave,
      d1_BR_avalon_slave_end_xfer => d1_BR_avalon_slave_end_xfer,
      registered_cpu_data_master_read_data_valid_BR_avalon_slave => registered_cpu_data_master_read_data_valid_BR_avalon_slave,
      BR_avalon_slave_readdata => BR_avalon_slave_readdata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk100_reset_n
    );


  --the_BR, which is an e_ptf_instance
  the_BR : BR
    port map(
      ex_addr => internal_ex_addr_from_the_BR,
      ex_clk => internal_ex_clk_from_the_BR,
      ex_din => internal_ex_din_from_the_BR,
      ex_re_n => internal_ex_re_n_from_the_BR,
      ex_reset_n => internal_ex_reset_n_from_the_BR,
      ex_we_n => internal_ex_we_n_from_the_BR,
      nios_dout => BR_avalon_slave_readdata,
      clk => internal_clk100,
      ex_dout => ex_dout_to_the_BR,
      nios_addr => BR_avalon_slave_address,
      nios_din => BR_avalon_slave_writedata,
      nios_re_n => BR_avalon_slave_read_n,
      nios_we_n => BR_avalon_slave_write_n,
      reset_n => BR_avalon_slave_reset_n
    );


  --the_TL_avalon_slave, which is an e_instance
  the_TL_avalon_slave : TL_avalon_slave_arbitrator
    port map(
      TL_avalon_slave_address => TL_avalon_slave_address,
      TL_avalon_slave_read_n => TL_avalon_slave_read_n,
      TL_avalon_slave_readdata_from_sa => TL_avalon_slave_readdata_from_sa,
      TL_avalon_slave_reset_n => TL_avalon_slave_reset_n,
      TL_avalon_slave_write_n => TL_avalon_slave_write_n,
      TL_avalon_slave_writedata => TL_avalon_slave_writedata,
      cpu_data_master_granted_TL_avalon_slave => cpu_data_master_granted_TL_avalon_slave,
      cpu_data_master_qualified_request_TL_avalon_slave => cpu_data_master_qualified_request_TL_avalon_slave,
      cpu_data_master_read_data_valid_TL_avalon_slave => cpu_data_master_read_data_valid_TL_avalon_slave,
      cpu_data_master_requests_TL_avalon_slave => cpu_data_master_requests_TL_avalon_slave,
      d1_TL_avalon_slave_end_xfer => d1_TL_avalon_slave_end_xfer,
      registered_cpu_data_master_read_data_valid_TL_avalon_slave => registered_cpu_data_master_read_data_valid_TL_avalon_slave,
      TL_avalon_slave_readdata => TL_avalon_slave_readdata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk100_reset_n
    );


  --the_TL, which is an e_ptf_instance
  the_TL : TL
    port map(
      ex_addr => internal_ex_addr_from_the_TL,
      ex_clk => internal_ex_clk_from_the_TL,
      ex_din => internal_ex_din_from_the_TL,
      ex_re_n => internal_ex_re_n_from_the_TL,
      ex_reset_n => internal_ex_reset_n_from_the_TL,
      ex_we_n => internal_ex_we_n_from_the_TL,
      nios_dout => TL_avalon_slave_readdata,
      clk => internal_clk100,
      ex_dout => ex_dout_to_the_TL,
      nios_addr => TL_avalon_slave_address,
      nios_din => TL_avalon_slave_writedata,
      nios_re_n => TL_avalon_slave_read_n,
      nios_we_n => TL_avalon_slave_write_n,
      reset_n => TL_avalon_slave_reset_n
    );


  --the_TR_avalon_slave, which is an e_instance
  the_TR_avalon_slave : TR_avalon_slave_arbitrator
    port map(
      TR_avalon_slave_address => TR_avalon_slave_address,
      TR_avalon_slave_read_n => TR_avalon_slave_read_n,
      TR_avalon_slave_readdata_from_sa => TR_avalon_slave_readdata_from_sa,
      TR_avalon_slave_reset_n => TR_avalon_slave_reset_n,
      TR_avalon_slave_write_n => TR_avalon_slave_write_n,
      TR_avalon_slave_writedata => TR_avalon_slave_writedata,
      cpu_data_master_granted_TR_avalon_slave => cpu_data_master_granted_TR_avalon_slave,
      cpu_data_master_qualified_request_TR_avalon_slave => cpu_data_master_qualified_request_TR_avalon_slave,
      cpu_data_master_read_data_valid_TR_avalon_slave => cpu_data_master_read_data_valid_TR_avalon_slave,
      cpu_data_master_requests_TR_avalon_slave => cpu_data_master_requests_TR_avalon_slave,
      d1_TR_avalon_slave_end_xfer => d1_TR_avalon_slave_end_xfer,
      registered_cpu_data_master_read_data_valid_TR_avalon_slave => registered_cpu_data_master_read_data_valid_TR_avalon_slave,
      TR_avalon_slave_readdata => TR_avalon_slave_readdata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk100_reset_n
    );


  --the_TR, which is an e_ptf_instance
  the_TR : TR
    port map(
      ex_addr => internal_ex_addr_from_the_TR,
      ex_clk => internal_ex_clk_from_the_TR,
      ex_din => internal_ex_din_from_the_TR,
      ex_re_n => internal_ex_re_n_from_the_TR,
      ex_reset_n => internal_ex_reset_n_from_the_TR,
      ex_we_n => internal_ex_we_n_from_the_TR,
      nios_dout => TR_avalon_slave_readdata,
      clk => internal_clk100,
      ex_dout => ex_dout_to_the_TR,
      nios_addr => TR_avalon_slave_address,
      nios_din => TR_avalon_slave_writedata,
      nios_re_n => TR_avalon_slave_read_n,
      nios_we_n => TR_avalon_slave_write_n,
      reset_n => TR_avalon_slave_reset_n
    );


  --the_control_avalon_slave, which is an e_instance
  the_control_avalon_slave : control_avalon_slave_arbitrator
    port map(
      control_avalon_slave_address => control_avalon_slave_address,
      control_avalon_slave_read_n => control_avalon_slave_read_n,
      control_avalon_slave_readdata_from_sa => control_avalon_slave_readdata_from_sa,
      control_avalon_slave_reset_n => control_avalon_slave_reset_n,
      control_avalon_slave_write_n => control_avalon_slave_write_n,
      control_avalon_slave_writedata => control_avalon_slave_writedata,
      cpu_data_master_granted_control_avalon_slave => cpu_data_master_granted_control_avalon_slave,
      cpu_data_master_qualified_request_control_avalon_slave => cpu_data_master_qualified_request_control_avalon_slave,
      cpu_data_master_read_data_valid_control_avalon_slave => cpu_data_master_read_data_valid_control_avalon_slave,
      cpu_data_master_requests_control_avalon_slave => cpu_data_master_requests_control_avalon_slave,
      d1_control_avalon_slave_end_xfer => d1_control_avalon_slave_end_xfer,
      registered_cpu_data_master_read_data_valid_control_avalon_slave => registered_cpu_data_master_read_data_valid_control_avalon_slave,
      clk => internal_clk100,
      control_avalon_slave_readdata => control_avalon_slave_readdata,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk100_reset_n
    );


  --the_control, which is an e_ptf_instance
  the_control : control
    port map(
      ex_addr => internal_ex_addr_from_the_control,
      ex_clk => internal_ex_clk_from_the_control,
      ex_din => internal_ex_din_from_the_control,
      ex_re_n => internal_ex_re_n_from_the_control,
      ex_reset_n => internal_ex_reset_n_from_the_control,
      ex_we_n => internal_ex_we_n_from_the_control,
      nios_dout => control_avalon_slave_readdata,
      clk => internal_clk100,
      ex_dout => ex_dout_to_the_control,
      nios_addr => control_avalon_slave_address,
      nios_din => control_avalon_slave_writedata,
      nios_re_n => control_avalon_slave_read_n,
      nios_we_n => control_avalon_slave_write_n,
      reset_n => control_avalon_slave_reset_n
    );


  --the_cpu_jtag_debug_module, which is an e_instance
  the_cpu_jtag_debug_module : cpu_jtag_debug_module_arbitrator
    port map(
      cpu_data_master_granted_cpu_jtag_debug_module => cpu_data_master_granted_cpu_jtag_debug_module,
      cpu_data_master_qualified_request_cpu_jtag_debug_module => cpu_data_master_qualified_request_cpu_jtag_debug_module,
      cpu_data_master_read_data_valid_cpu_jtag_debug_module => cpu_data_master_read_data_valid_cpu_jtag_debug_module,
      cpu_data_master_requests_cpu_jtag_debug_module => cpu_data_master_requests_cpu_jtag_debug_module,
      cpu_instruction_master_granted_cpu_jtag_debug_module => cpu_instruction_master_granted_cpu_jtag_debug_module,
      cpu_instruction_master_qualified_request_cpu_jtag_debug_module => cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
      cpu_instruction_master_read_data_valid_cpu_jtag_debug_module => cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
      cpu_instruction_master_requests_cpu_jtag_debug_module => cpu_instruction_master_requests_cpu_jtag_debug_module,
      cpu_jtag_debug_module_address => cpu_jtag_debug_module_address,
      cpu_jtag_debug_module_begintransfer => cpu_jtag_debug_module_begintransfer,
      cpu_jtag_debug_module_byteenable => cpu_jtag_debug_module_byteenable,
      cpu_jtag_debug_module_chipselect => cpu_jtag_debug_module_chipselect,
      cpu_jtag_debug_module_debugaccess => cpu_jtag_debug_module_debugaccess,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      cpu_jtag_debug_module_reset => cpu_jtag_debug_module_reset,
      cpu_jtag_debug_module_reset_n => cpu_jtag_debug_module_reset_n,
      cpu_jtag_debug_module_resetrequest_from_sa => cpu_jtag_debug_module_resetrequest_from_sa,
      cpu_jtag_debug_module_write => cpu_jtag_debug_module_write,
      cpu_jtag_debug_module_writedata => cpu_jtag_debug_module_writedata,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_debugaccess => cpu_data_master_debugaccess,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register => cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register,
      cpu_jtag_debug_module_readdata => cpu_jtag_debug_module_readdata,
      cpu_jtag_debug_module_resetrequest => cpu_jtag_debug_module_resetrequest,
      reset_n => clk100_reset_n
    );


  --the_cpu_data_master, which is an e_instance
  the_cpu_data_master : cpu_data_master_arbitrator
    port map(
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_irq => cpu_data_master_irq,
      cpu_data_master_readdata => cpu_data_master_readdata,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      BL_avalon_slave_readdata_from_sa => BL_avalon_slave_readdata_from_sa,
      BR_avalon_slave_readdata_from_sa => BR_avalon_slave_readdata_from_sa,
      TL_avalon_slave_readdata_from_sa => TL_avalon_slave_readdata_from_sa,
      TR_avalon_slave_readdata_from_sa => TR_avalon_slave_readdata_from_sa,
      clk => internal_clk100,
      clk100 => internal_clk100,
      clk100_reset_n => clk100_reset_n,
      control_avalon_slave_readdata_from_sa => control_avalon_slave_readdata_from_sa,
      cpu_data_master_address => cpu_data_master_address,
      cpu_data_master_granted_BL_avalon_slave => cpu_data_master_granted_BL_avalon_slave,
      cpu_data_master_granted_BR_avalon_slave => cpu_data_master_granted_BR_avalon_slave,
      cpu_data_master_granted_TL_avalon_slave => cpu_data_master_granted_TL_avalon_slave,
      cpu_data_master_granted_TR_avalon_slave => cpu_data_master_granted_TR_avalon_slave,
      cpu_data_master_granted_control_avalon_slave => cpu_data_master_granted_control_avalon_slave,
      cpu_data_master_granted_cpu_jtag_debug_module => cpu_data_master_granted_cpu_jtag_debug_module,
      cpu_data_master_granted_ddr2_deva_s1 => cpu_data_master_granted_ddr2_deva_s1,
      cpu_data_master_granted_frame_received_s1 => cpu_data_master_granted_frame_received_s1,
      cpu_data_master_granted_jtag_uart_avalon_jtag_slave => cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      cpu_data_master_granted_laser_uart_s1 => cpu_data_master_granted_laser_uart_s1,
      cpu_data_master_granted_onchip_mem_s1 => cpu_data_master_granted_onchip_mem_s1,
      cpu_data_master_granted_ranger_cpu_clock_0_in => cpu_data_master_granted_ranger_cpu_clock_0_in,
      cpu_data_master_granted_ranger_cpu_clock_2_in => cpu_data_master_granted_ranger_cpu_clock_2_in,
      cpu_data_master_granted_sysid_control_slave => cpu_data_master_granted_sysid_control_slave,
      cpu_data_master_granted_timer_1ms_s1 => cpu_data_master_granted_timer_1ms_s1,
      cpu_data_master_qualified_request_BL_avalon_slave => cpu_data_master_qualified_request_BL_avalon_slave,
      cpu_data_master_qualified_request_BR_avalon_slave => cpu_data_master_qualified_request_BR_avalon_slave,
      cpu_data_master_qualified_request_TL_avalon_slave => cpu_data_master_qualified_request_TL_avalon_slave,
      cpu_data_master_qualified_request_TR_avalon_slave => cpu_data_master_qualified_request_TR_avalon_slave,
      cpu_data_master_qualified_request_control_avalon_slave => cpu_data_master_qualified_request_control_avalon_slave,
      cpu_data_master_qualified_request_cpu_jtag_debug_module => cpu_data_master_qualified_request_cpu_jtag_debug_module,
      cpu_data_master_qualified_request_ddr2_deva_s1 => cpu_data_master_qualified_request_ddr2_deva_s1,
      cpu_data_master_qualified_request_frame_received_s1 => cpu_data_master_qualified_request_frame_received_s1,
      cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      cpu_data_master_qualified_request_laser_uart_s1 => cpu_data_master_qualified_request_laser_uart_s1,
      cpu_data_master_qualified_request_onchip_mem_s1 => cpu_data_master_qualified_request_onchip_mem_s1,
      cpu_data_master_qualified_request_ranger_cpu_clock_0_in => cpu_data_master_qualified_request_ranger_cpu_clock_0_in,
      cpu_data_master_qualified_request_ranger_cpu_clock_2_in => cpu_data_master_qualified_request_ranger_cpu_clock_2_in,
      cpu_data_master_qualified_request_sysid_control_slave => cpu_data_master_qualified_request_sysid_control_slave,
      cpu_data_master_qualified_request_timer_1ms_s1 => cpu_data_master_qualified_request_timer_1ms_s1,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_read_data_valid_BL_avalon_slave => cpu_data_master_read_data_valid_BL_avalon_slave,
      cpu_data_master_read_data_valid_BR_avalon_slave => cpu_data_master_read_data_valid_BR_avalon_slave,
      cpu_data_master_read_data_valid_TL_avalon_slave => cpu_data_master_read_data_valid_TL_avalon_slave,
      cpu_data_master_read_data_valid_TR_avalon_slave => cpu_data_master_read_data_valid_TR_avalon_slave,
      cpu_data_master_read_data_valid_control_avalon_slave => cpu_data_master_read_data_valid_control_avalon_slave,
      cpu_data_master_read_data_valid_cpu_jtag_debug_module => cpu_data_master_read_data_valid_cpu_jtag_debug_module,
      cpu_data_master_read_data_valid_ddr2_deva_s1 => cpu_data_master_read_data_valid_ddr2_deva_s1,
      cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register => cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register,
      cpu_data_master_read_data_valid_frame_received_s1 => cpu_data_master_read_data_valid_frame_received_s1,
      cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      cpu_data_master_read_data_valid_laser_uart_s1 => cpu_data_master_read_data_valid_laser_uart_s1,
      cpu_data_master_read_data_valid_onchip_mem_s1 => cpu_data_master_read_data_valid_onchip_mem_s1,
      cpu_data_master_read_data_valid_ranger_cpu_clock_0_in => cpu_data_master_read_data_valid_ranger_cpu_clock_0_in,
      cpu_data_master_read_data_valid_ranger_cpu_clock_2_in => cpu_data_master_read_data_valid_ranger_cpu_clock_2_in,
      cpu_data_master_read_data_valid_sysid_control_slave => cpu_data_master_read_data_valid_sysid_control_slave,
      cpu_data_master_read_data_valid_timer_1ms_s1 => cpu_data_master_read_data_valid_timer_1ms_s1,
      cpu_data_master_requests_BL_avalon_slave => cpu_data_master_requests_BL_avalon_slave,
      cpu_data_master_requests_BR_avalon_slave => cpu_data_master_requests_BR_avalon_slave,
      cpu_data_master_requests_TL_avalon_slave => cpu_data_master_requests_TL_avalon_slave,
      cpu_data_master_requests_TR_avalon_slave => cpu_data_master_requests_TR_avalon_slave,
      cpu_data_master_requests_control_avalon_slave => cpu_data_master_requests_control_avalon_slave,
      cpu_data_master_requests_cpu_jtag_debug_module => cpu_data_master_requests_cpu_jtag_debug_module,
      cpu_data_master_requests_ddr2_deva_s1 => cpu_data_master_requests_ddr2_deva_s1,
      cpu_data_master_requests_frame_received_s1 => cpu_data_master_requests_frame_received_s1,
      cpu_data_master_requests_jtag_uart_avalon_jtag_slave => cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      cpu_data_master_requests_laser_uart_s1 => cpu_data_master_requests_laser_uart_s1,
      cpu_data_master_requests_onchip_mem_s1 => cpu_data_master_requests_onchip_mem_s1,
      cpu_data_master_requests_ranger_cpu_clock_0_in => cpu_data_master_requests_ranger_cpu_clock_0_in,
      cpu_data_master_requests_ranger_cpu_clock_2_in => cpu_data_master_requests_ranger_cpu_clock_2_in,
      cpu_data_master_requests_sysid_control_slave => cpu_data_master_requests_sysid_control_slave,
      cpu_data_master_requests_timer_1ms_s1 => cpu_data_master_requests_timer_1ms_s1,
      cpu_data_master_write => cpu_data_master_write,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      d1_BL_avalon_slave_end_xfer => d1_BL_avalon_slave_end_xfer,
      d1_BR_avalon_slave_end_xfer => d1_BR_avalon_slave_end_xfer,
      d1_TL_avalon_slave_end_xfer => d1_TL_avalon_slave_end_xfer,
      d1_TR_avalon_slave_end_xfer => d1_TR_avalon_slave_end_xfer,
      d1_control_avalon_slave_end_xfer => d1_control_avalon_slave_end_xfer,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      d1_ddr2_deva_s1_end_xfer => d1_ddr2_deva_s1_end_xfer,
      d1_frame_received_s1_end_xfer => d1_frame_received_s1_end_xfer,
      d1_jtag_uart_avalon_jtag_slave_end_xfer => d1_jtag_uart_avalon_jtag_slave_end_xfer,
      d1_laser_uart_s1_end_xfer => d1_laser_uart_s1_end_xfer,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      d1_ranger_cpu_clock_0_in_end_xfer => d1_ranger_cpu_clock_0_in_end_xfer,
      d1_ranger_cpu_clock_2_in_end_xfer => d1_ranger_cpu_clock_2_in_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      d1_timer_1ms_s1_end_xfer => d1_timer_1ms_s1_end_xfer,
      ddr2_deva_s1_readdata_from_sa => ddr2_deva_s1_readdata_from_sa,
      ddr2_deva_s1_waitrequest_n_from_sa => ddr2_deva_s1_waitrequest_n_from_sa,
      dm9000a_avalon_slave_0_irq_from_sa => dm9000a_avalon_slave_0_irq_from_sa,
      frame_received_s1_irq_from_sa => frame_received_s1_irq_from_sa,
      frame_received_s1_readdata_from_sa => frame_received_s1_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_irq_from_sa => jtag_uart_avalon_jtag_slave_irq_from_sa,
      jtag_uart_avalon_jtag_slave_readdata_from_sa => jtag_uart_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
      laser_uart_s1_irq_from_sa => laser_uart_s1_irq_from_sa,
      laser_uart_s1_readdata_from_sa => laser_uart_s1_readdata_from_sa,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      ranger_cpu_clock_0_in_readdata_from_sa => ranger_cpu_clock_0_in_readdata_from_sa,
      ranger_cpu_clock_0_in_waitrequest_from_sa => ranger_cpu_clock_0_in_waitrequest_from_sa,
      ranger_cpu_clock_2_in_readdata_from_sa => ranger_cpu_clock_2_in_readdata_from_sa,
      ranger_cpu_clock_2_in_waitrequest_from_sa => ranger_cpu_clock_2_in_waitrequest_from_sa,
      registered_cpu_data_master_read_data_valid_BL_avalon_slave => registered_cpu_data_master_read_data_valid_BL_avalon_slave,
      registered_cpu_data_master_read_data_valid_BR_avalon_slave => registered_cpu_data_master_read_data_valid_BR_avalon_slave,
      registered_cpu_data_master_read_data_valid_TL_avalon_slave => registered_cpu_data_master_read_data_valid_TL_avalon_slave,
      registered_cpu_data_master_read_data_valid_TR_avalon_slave => registered_cpu_data_master_read_data_valid_TR_avalon_slave,
      registered_cpu_data_master_read_data_valid_control_avalon_slave => registered_cpu_data_master_read_data_valid_control_avalon_slave,
      registered_cpu_data_master_read_data_valid_onchip_mem_s1 => registered_cpu_data_master_read_data_valid_onchip_mem_s1,
      reset_n => clk100_reset_n,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      timer_1ms_s1_irq_from_sa => timer_1ms_s1_irq_from_sa,
      timer_1ms_s1_readdata_from_sa => timer_1ms_s1_readdata_from_sa
    );


  --the_cpu_instruction_master, which is an e_instance
  the_cpu_instruction_master : cpu_instruction_master_arbitrator
    port map(
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_readdata => cpu_instruction_master_readdata,
      cpu_instruction_master_readdatavalid => cpu_instruction_master_readdatavalid,
      cpu_instruction_master_waitrequest => cpu_instruction_master_waitrequest,
      clk => internal_clk100,
      cpu_instruction_master_address => cpu_instruction_master_address,
      cpu_instruction_master_granted_cpu_jtag_debug_module => cpu_instruction_master_granted_cpu_jtag_debug_module,
      cpu_instruction_master_granted_ddr2_deva_s1 => cpu_instruction_master_granted_ddr2_deva_s1,
      cpu_instruction_master_granted_onchip_mem_s1 => cpu_instruction_master_granted_onchip_mem_s1,
      cpu_instruction_master_granted_ranger_cpu_clock_1_in => cpu_instruction_master_granted_ranger_cpu_clock_1_in,
      cpu_instruction_master_qualified_request_cpu_jtag_debug_module => cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
      cpu_instruction_master_qualified_request_ddr2_deva_s1 => cpu_instruction_master_qualified_request_ddr2_deva_s1,
      cpu_instruction_master_qualified_request_onchip_mem_s1 => cpu_instruction_master_qualified_request_onchip_mem_s1,
      cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in => cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_instruction_master_read_data_valid_cpu_jtag_debug_module => cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
      cpu_instruction_master_read_data_valid_ddr2_deva_s1 => cpu_instruction_master_read_data_valid_ddr2_deva_s1,
      cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register => cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register,
      cpu_instruction_master_read_data_valid_onchip_mem_s1 => cpu_instruction_master_read_data_valid_onchip_mem_s1,
      cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in => cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in,
      cpu_instruction_master_requests_cpu_jtag_debug_module => cpu_instruction_master_requests_cpu_jtag_debug_module,
      cpu_instruction_master_requests_ddr2_deva_s1 => cpu_instruction_master_requests_ddr2_deva_s1,
      cpu_instruction_master_requests_onchip_mem_s1 => cpu_instruction_master_requests_onchip_mem_s1,
      cpu_instruction_master_requests_ranger_cpu_clock_1_in => cpu_instruction_master_requests_ranger_cpu_clock_1_in,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      d1_ddr2_deva_s1_end_xfer => d1_ddr2_deva_s1_end_xfer,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      d1_ranger_cpu_clock_1_in_end_xfer => d1_ranger_cpu_clock_1_in_end_xfer,
      ddr2_deva_s1_readdata_from_sa => ddr2_deva_s1_readdata_from_sa,
      ddr2_deva_s1_waitrequest_n_from_sa => ddr2_deva_s1_waitrequest_n_from_sa,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      ranger_cpu_clock_1_in_readdata_from_sa => ranger_cpu_clock_1_in_readdata_from_sa,
      ranger_cpu_clock_1_in_waitrequest_from_sa => ranger_cpu_clock_1_in_waitrequest_from_sa,
      reset_n => clk100_reset_n
    );


  --the_cpu, which is an e_ptf_instance
  the_cpu : cpu
    port map(
      d_address => cpu_data_master_address,
      d_byteenable => cpu_data_master_byteenable,
      d_read => cpu_data_master_read,
      d_write => cpu_data_master_write,
      d_writedata => cpu_data_master_writedata,
      i_address => cpu_instruction_master_address,
      i_read => cpu_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => cpu_data_master_debugaccess,
      jtag_debug_module_readdata => cpu_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => cpu_jtag_debug_module_resetrequest,
      clk => internal_clk100,
      d_irq => cpu_data_master_irq,
      d_readdata => cpu_data_master_readdata,
      d_waitrequest => cpu_data_master_waitrequest,
      i_readdata => cpu_instruction_master_readdata,
      i_readdatavalid => cpu_instruction_master_readdatavalid,
      i_waitrequest => cpu_instruction_master_waitrequest,
      jtag_debug_module_address => cpu_jtag_debug_module_address,
      jtag_debug_module_begintransfer => cpu_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => cpu_jtag_debug_module_byteenable,
      jtag_debug_module_clk => internal_clk100,
      jtag_debug_module_debugaccess => cpu_jtag_debug_module_debugaccess,
      jtag_debug_module_reset => cpu_jtag_debug_module_reset,
      jtag_debug_module_select => cpu_jtag_debug_module_chipselect,
      jtag_debug_module_write => cpu_jtag_debug_module_write,
      jtag_debug_module_writedata => cpu_jtag_debug_module_writedata,
      reset_n => cpu_jtag_debug_module_reset_n
    );


  --the_ddr2_deva_s1, which is an e_instance
  the_ddr2_deva_s1 : ddr2_deva_s1_arbitrator
    port map(
      cpu_data_master_granted_ddr2_deva_s1 => cpu_data_master_granted_ddr2_deva_s1,
      cpu_data_master_qualified_request_ddr2_deva_s1 => cpu_data_master_qualified_request_ddr2_deva_s1,
      cpu_data_master_read_data_valid_ddr2_deva_s1 => cpu_data_master_read_data_valid_ddr2_deva_s1,
      cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register => cpu_data_master_read_data_valid_ddr2_deva_s1_shift_register,
      cpu_data_master_requests_ddr2_deva_s1 => cpu_data_master_requests_ddr2_deva_s1,
      cpu_instruction_master_granted_ddr2_deva_s1 => cpu_instruction_master_granted_ddr2_deva_s1,
      cpu_instruction_master_qualified_request_ddr2_deva_s1 => cpu_instruction_master_qualified_request_ddr2_deva_s1,
      cpu_instruction_master_read_data_valid_ddr2_deva_s1 => cpu_instruction_master_read_data_valid_ddr2_deva_s1,
      cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register => cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register,
      cpu_instruction_master_requests_ddr2_deva_s1 => cpu_instruction_master_requests_ddr2_deva_s1,
      d1_ddr2_deva_s1_end_xfer => d1_ddr2_deva_s1_end_xfer,
      ddr2_deva_s1_address => ddr2_deva_s1_address,
      ddr2_deva_s1_beginbursttransfer => ddr2_deva_s1_beginbursttransfer,
      ddr2_deva_s1_burstcount => ddr2_deva_s1_burstcount,
      ddr2_deva_s1_byteenable => ddr2_deva_s1_byteenable,
      ddr2_deva_s1_read => ddr2_deva_s1_read,
      ddr2_deva_s1_readdata_from_sa => ddr2_deva_s1_readdata_from_sa,
      ddr2_deva_s1_resetrequest_n_from_sa => ddr2_deva_s1_resetrequest_n_from_sa,
      ddr2_deva_s1_waitrequest_n_from_sa => ddr2_deva_s1_waitrequest_n_from_sa,
      ddr2_deva_s1_write => ddr2_deva_s1_write,
      ddr2_deva_s1_writedata => ddr2_deva_s1_writedata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_read => cpu_instruction_master_read,
      ddr2_deva_s1_readdata => ddr2_deva_s1_readdata,
      ddr2_deva_s1_readdatavalid => ddr2_deva_s1_readdatavalid,
      ddr2_deva_s1_resetrequest_n => ddr2_deva_s1_resetrequest_n,
      ddr2_deva_s1_waitrequest_n => ddr2_deva_s1_waitrequest_n,
      reset_n => clk100_reset_n
    );


  --ddr2_deva_aux_full_rate_clk_out out_clk assignment, which is an e_assign
  ddr2_deva_aux_full_rate_clk_out <= out_clk_ddr2_deva_aux_full_rate_clk;
  --ddr2_deva_aux_half_rate_clk_out out_clk assignment, which is an e_assign
  ddr2_deva_aux_half_rate_clk_out <= out_clk_ddr2_deva_aux_half_rate_clk;
  --clk100 out_clk assignment, which is an e_assign
  internal_clk100 <= out_clk_ddr2_deva_phy_clk;
  --reset is asserted asynchronously and deasserted synchronously
  ranger_cpu_reset_clk125_domain_synch : ranger_cpu_reset_clk125_domain_synch_module
    port map(
      data_out => clk125_reset_n,
      clk => clk125,
      data_in => module_input6,
      reset_n => reset_n_sources
    );

  module_input6 <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT ((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ddr2_deva_s1_resetrequest_n_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ddr2_deva_s1_resetrequest_n_from_sa)))) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ddr2_devb_s1_resetrequest_n_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ddr2_devb_s1_resetrequest_n_from_sa)))) OR std_logic_vector'("00000000000000000000000000000000"))));
  --the_ddr2_deva, which is an e_ptf_instance
  the_ddr2_deva : ddr2_deva
    port map(
      aux_full_rate_clk => out_clk_ddr2_deva_aux_full_rate_clk,
      aux_half_rate_clk => out_clk_ddr2_deva_aux_half_rate_clk,
      local_init_done => internal_local_init_done_from_the_ddr2_deva,
      local_rdata => ddr2_deva_s1_readdata,
      local_rdata_valid => ddr2_deva_s1_readdatavalid,
      local_ready => ddr2_deva_s1_waitrequest_n,
      local_refresh_ack => internal_local_refresh_ack_from_the_ddr2_deva,
      local_wdata_req => internal_local_wdata_req_from_the_ddr2_deva,
      mem_addr => internal_mem_addr_from_the_ddr2_deva,
      mem_ba => internal_mem_ba_from_the_ddr2_deva,
      mem_cas_n => internal_mem_cas_n_from_the_ddr2_deva,
      mem_cke(0) => internal_mem_cke_from_the_ddr2_deva,
      mem_clk(0) => mem_clk_to_and_from_the_ddr2_deva,
      mem_clk_n(0) => mem_clk_n_to_and_from_the_ddr2_deva,
      mem_cs_n(0) => internal_mem_cs_n_from_the_ddr2_deva,
      mem_dm(0) => internal_mem_dm_from_the_ddr2_deva,
      mem_dq => mem_dq_to_and_from_the_ddr2_deva,
      mem_dqs(0) => mem_dqs_to_and_from_the_ddr2_deva,
      mem_dqsn(0) => mem_dqsn_to_and_from_the_ddr2_deva,
      mem_odt(0) => internal_mem_odt_from_the_ddr2_deva,
      mem_ras_n => internal_mem_ras_n_from_the_ddr2_deva,
      mem_we_n => internal_mem_we_n_from_the_ddr2_deva,
      phy_clk => out_clk_ddr2_deva_phy_clk,
      reset_phy_clk_n => internal_reset_phy_clk_n_from_the_ddr2_deva,
      reset_request_n => ddr2_deva_s1_resetrequest_n,
      global_reset_n => global_reset_n_to_the_ddr2_deva,
      local_address => ddr2_deva_s1_address,
      local_be => ddr2_deva_s1_byteenable,
      local_burstbegin => ddr2_deva_s1_beginbursttransfer,
      local_read_req => ddr2_deva_s1_read,
      local_size => ddr2_deva_s1_burstcount,
      local_wdata => ddr2_deva_s1_writedata,
      local_write_req => ddr2_deva_s1_write,
      oct_ctl_rs_value => oct_ctl_rs_value_to_the_ddr2_deva,
      oct_ctl_rt_value => oct_ctl_rt_value_to_the_ddr2_deva,
      pll_ref_clk => clk125,
      soft_reset_n => clk125_reset_n
    );


  --the_ddr2_devb_s1, which is an e_instance
  the_ddr2_devb_s1 : ddr2_devb_s1_arbitrator
    port map(
      d1_ddr2_devb_s1_end_xfer => d1_ddr2_devb_s1_end_xfer,
      ddr2_devb_s1_address => ddr2_devb_s1_address,
      ddr2_devb_s1_beginbursttransfer => ddr2_devb_s1_beginbursttransfer,
      ddr2_devb_s1_burstcount => ddr2_devb_s1_burstcount,
      ddr2_devb_s1_byteenable => ddr2_devb_s1_byteenable,
      ddr2_devb_s1_read => ddr2_devb_s1_read,
      ddr2_devb_s1_readdata_from_sa => ddr2_devb_s1_readdata_from_sa,
      ddr2_devb_s1_resetrequest_n_from_sa => ddr2_devb_s1_resetrequest_n_from_sa,
      ddr2_devb_s1_waitrequest_n_from_sa => ddr2_devb_s1_waitrequest_n_from_sa,
      ddr2_devb_s1_write => ddr2_devb_s1_write,
      ddr2_devb_s1_writedata => ddr2_devb_s1_writedata,
      ranger_cpu_clock_1_out_granted_ddr2_devb_s1 => ranger_cpu_clock_1_out_granted_ddr2_devb_s1,
      ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 => ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1,
      ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 => ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1,
      ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register => ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register,
      ranger_cpu_clock_1_out_requests_ddr2_devb_s1 => ranger_cpu_clock_1_out_requests_ddr2_devb_s1,
      ranger_cpu_clock_2_out_granted_ddr2_devb_s1 => ranger_cpu_clock_2_out_granted_ddr2_devb_s1,
      ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 => ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1,
      ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 => ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1,
      ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register => ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register,
      ranger_cpu_clock_2_out_requests_ddr2_devb_s1 => ranger_cpu_clock_2_out_requests_ddr2_devb_s1,
      clk => internal_ddr2_devb_phy_clk_out,
      ddr2_devb_s1_readdata => ddr2_devb_s1_readdata,
      ddr2_devb_s1_readdatavalid => ddr2_devb_s1_readdatavalid,
      ddr2_devb_s1_resetrequest_n => ddr2_devb_s1_resetrequest_n,
      ddr2_devb_s1_waitrequest_n => ddr2_devb_s1_waitrequest_n,
      ranger_cpu_clock_1_out_address_to_slave => ranger_cpu_clock_1_out_address_to_slave,
      ranger_cpu_clock_1_out_byteenable => ranger_cpu_clock_1_out_byteenable,
      ranger_cpu_clock_1_out_read => ranger_cpu_clock_1_out_read,
      ranger_cpu_clock_1_out_write => ranger_cpu_clock_1_out_write,
      ranger_cpu_clock_1_out_writedata => ranger_cpu_clock_1_out_writedata,
      ranger_cpu_clock_2_out_address_to_slave => ranger_cpu_clock_2_out_address_to_slave,
      ranger_cpu_clock_2_out_byteenable => ranger_cpu_clock_2_out_byteenable,
      ranger_cpu_clock_2_out_read => ranger_cpu_clock_2_out_read,
      ranger_cpu_clock_2_out_write => ranger_cpu_clock_2_out_write,
      ranger_cpu_clock_2_out_writedata => ranger_cpu_clock_2_out_writedata,
      reset_n => ddr2_devb_phy_clk_out_reset_n
    );


  --ddr2_devb_aux_full_rate_clk_out out_clk assignment, which is an e_assign
  ddr2_devb_aux_full_rate_clk_out <= out_clk_ddr2_devb_aux_full_rate_clk;
  --ddr2_devb_aux_half_rate_clk_out out_clk assignment, which is an e_assign
  ddr2_devb_aux_half_rate_clk_out <= out_clk_ddr2_devb_aux_half_rate_clk;
  --ddr2_devb_phy_clk_out out_clk assignment, which is an e_assign
  internal_ddr2_devb_phy_clk_out <= out_clk_ddr2_devb_phy_clk;
  --the_ddr2_devb, which is an e_ptf_instance
  the_ddr2_devb : ddr2_devb
    port map(
      aux_full_rate_clk => out_clk_ddr2_devb_aux_full_rate_clk,
      aux_half_rate_clk => out_clk_ddr2_devb_aux_half_rate_clk,
      local_init_done => internal_local_init_done_from_the_ddr2_devb,
      local_rdata => ddr2_devb_s1_readdata,
      local_rdata_valid => ddr2_devb_s1_readdatavalid,
      local_ready => ddr2_devb_s1_waitrequest_n,
      local_refresh_ack => internal_local_refresh_ack_from_the_ddr2_devb,
      local_wdata_req => internal_local_wdata_req_from_the_ddr2_devb,
      mem_addr => internal_mem_addr_from_the_ddr2_devb,
      mem_ba => internal_mem_ba_from_the_ddr2_devb,
      mem_cas_n => internal_mem_cas_n_from_the_ddr2_devb,
      mem_cke(0) => internal_mem_cke_from_the_ddr2_devb,
      mem_clk(0) => mem_clk_to_and_from_the_ddr2_devb,
      mem_clk_n(0) => mem_clk_n_to_and_from_the_ddr2_devb,
      mem_cs_n(0) => internal_mem_cs_n_from_the_ddr2_devb,
      mem_dm(0) => internal_mem_dm_from_the_ddr2_devb,
      mem_dq => mem_dq_to_and_from_the_ddr2_devb,
      mem_dqs(0) => mem_dqs_to_and_from_the_ddr2_devb,
      mem_dqsn(0) => mem_dqsn_to_and_from_the_ddr2_devb,
      mem_odt(0) => internal_mem_odt_from_the_ddr2_devb,
      mem_ras_n => internal_mem_ras_n_from_the_ddr2_devb,
      mem_we_n => internal_mem_we_n_from_the_ddr2_devb,
      phy_clk => out_clk_ddr2_devb_phy_clk,
      reset_phy_clk_n => internal_reset_phy_clk_n_from_the_ddr2_devb,
      reset_request_n => ddr2_devb_s1_resetrequest_n,
      global_reset_n => global_reset_n_to_the_ddr2_devb,
      local_address => ddr2_devb_s1_address,
      local_be => ddr2_devb_s1_byteenable,
      local_burstbegin => ddr2_devb_s1_beginbursttransfer,
      local_read_req => ddr2_devb_s1_read,
      local_size => ddr2_devb_s1_burstcount,
      local_wdata => ddr2_devb_s1_writedata,
      local_write_req => ddr2_devb_s1_write,
      oct_ctl_rs_value => oct_ctl_rs_value_to_the_ddr2_devb,
      oct_ctl_rt_value => oct_ctl_rt_value_to_the_ddr2_devb,
      pll_ref_clk => clk125,
      soft_reset_n => clk125_reset_n
    );


  --the_dm9000a_avalon_slave_0, which is an e_instance
  the_dm9000a_avalon_slave_0 : dm9000a_avalon_slave_0_arbitrator
    port map(
      d1_dm9000a_avalon_slave_0_end_xfer => d1_dm9000a_avalon_slave_0_end_xfer,
      dm9000a_avalon_slave_0_address => dm9000a_avalon_slave_0_address,
      dm9000a_avalon_slave_0_chipselect_n => dm9000a_avalon_slave_0_chipselect_n,
      dm9000a_avalon_slave_0_irq_from_sa => dm9000a_avalon_slave_0_irq_from_sa,
      dm9000a_avalon_slave_0_read_n => dm9000a_avalon_slave_0_read_n,
      dm9000a_avalon_slave_0_readdata_from_sa => dm9000a_avalon_slave_0_readdata_from_sa,
      dm9000a_avalon_slave_0_reset_n => dm9000a_avalon_slave_0_reset_n,
      dm9000a_avalon_slave_0_write_n => dm9000a_avalon_slave_0_write_n,
      dm9000a_avalon_slave_0_writedata => dm9000a_avalon_slave_0_writedata,
      ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0,
      ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0,
      ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0,
      ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0,
      clk => clk50,
      dm9000a_avalon_slave_0_irq => dm9000a_avalon_slave_0_irq,
      dm9000a_avalon_slave_0_readdata => dm9000a_avalon_slave_0_readdata,
      ranger_cpu_clock_0_out_address_to_slave => ranger_cpu_clock_0_out_address_to_slave,
      ranger_cpu_clock_0_out_nativeaddress => ranger_cpu_clock_0_out_nativeaddress,
      ranger_cpu_clock_0_out_read => ranger_cpu_clock_0_out_read,
      ranger_cpu_clock_0_out_write => ranger_cpu_clock_0_out_write,
      ranger_cpu_clock_0_out_writedata => ranger_cpu_clock_0_out_writedata,
      reset_n => clk50_reset_n
    );


  --the_dm9000a, which is an e_ptf_instance
  the_dm9000a : dm9000a
    port map(
      ENET_CLK => internal_ENET_CLK_from_the_dm9000a,
      ENET_CMD => internal_ENET_CMD_from_the_dm9000a,
      ENET_CS_N => internal_ENET_CS_N_from_the_dm9000a,
      ENET_DATA => ENET_DATA_to_and_from_the_dm9000a,
      ENET_RD_N => internal_ENET_RD_N_from_the_dm9000a,
      ENET_RST_N => internal_ENET_RST_N_from_the_dm9000a,
      ENET_WR_N => internal_ENET_WR_N_from_the_dm9000a,
      oDATA => dm9000a_avalon_slave_0_readdata,
      oINT => dm9000a_avalon_slave_0_irq,
      ENET_INT => ENET_INT_to_the_dm9000a,
      iCLK => clk50,
      iCMD => dm9000a_avalon_slave_0_address,
      iCS_N => dm9000a_avalon_slave_0_chipselect_n,
      iDATA => dm9000a_avalon_slave_0_writedata,
      iOSC_50 => iOSC_50_to_the_dm9000a,
      iRD_N => dm9000a_avalon_slave_0_read_n,
      iRST_N => dm9000a_avalon_slave_0_reset_n,
      iWR_N => dm9000a_avalon_slave_0_write_n
    );


  --the_frame_received_s1, which is an e_instance
  the_frame_received_s1 : frame_received_s1_arbitrator
    port map(
      cpu_data_master_granted_frame_received_s1 => cpu_data_master_granted_frame_received_s1,
      cpu_data_master_qualified_request_frame_received_s1 => cpu_data_master_qualified_request_frame_received_s1,
      cpu_data_master_read_data_valid_frame_received_s1 => cpu_data_master_read_data_valid_frame_received_s1,
      cpu_data_master_requests_frame_received_s1 => cpu_data_master_requests_frame_received_s1,
      d1_frame_received_s1_end_xfer => d1_frame_received_s1_end_xfer,
      frame_received_s1_address => frame_received_s1_address,
      frame_received_s1_chipselect => frame_received_s1_chipselect,
      frame_received_s1_irq_from_sa => frame_received_s1_irq_from_sa,
      frame_received_s1_readdata_from_sa => frame_received_s1_readdata_from_sa,
      frame_received_s1_reset_n => frame_received_s1_reset_n,
      frame_received_s1_write_n => frame_received_s1_write_n,
      frame_received_s1_writedata => frame_received_s1_writedata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      frame_received_s1_irq => frame_received_s1_irq,
      frame_received_s1_readdata => frame_received_s1_readdata,
      reset_n => clk100_reset_n
    );


  --the_frame_received, which is an e_ptf_instance
  the_frame_received : frame_received
    port map(
      irq => frame_received_s1_irq,
      readdata => frame_received_s1_readdata,
      address => frame_received_s1_address,
      chipselect => frame_received_s1_chipselect,
      clk => internal_clk100,
      in_port => in_port_to_the_frame_received,
      reset_n => frame_received_s1_reset_n,
      write_n => frame_received_s1_write_n,
      writedata => frame_received_s1_writedata
    );


  --the_jtag_uart_avalon_jtag_slave, which is an e_instance
  the_jtag_uart_avalon_jtag_slave : jtag_uart_avalon_jtag_slave_arbitrator
    port map(
      cpu_data_master_granted_jtag_uart_avalon_jtag_slave => cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      cpu_data_master_requests_jtag_uart_avalon_jtag_slave => cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      d1_jtag_uart_avalon_jtag_slave_end_xfer => d1_jtag_uart_avalon_jtag_slave_end_xfer,
      jtag_uart_avalon_jtag_slave_address => jtag_uart_avalon_jtag_slave_address,
      jtag_uart_avalon_jtag_slave_chipselect => jtag_uart_avalon_jtag_slave_chipselect,
      jtag_uart_avalon_jtag_slave_dataavailable_from_sa => jtag_uart_avalon_jtag_slave_dataavailable_from_sa,
      jtag_uart_avalon_jtag_slave_irq_from_sa => jtag_uart_avalon_jtag_slave_irq_from_sa,
      jtag_uart_avalon_jtag_slave_read_n => jtag_uart_avalon_jtag_slave_read_n,
      jtag_uart_avalon_jtag_slave_readdata_from_sa => jtag_uart_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_readyfordata_from_sa => jtag_uart_avalon_jtag_slave_readyfordata_from_sa,
      jtag_uart_avalon_jtag_slave_reset_n => jtag_uart_avalon_jtag_slave_reset_n,
      jtag_uart_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
      jtag_uart_avalon_jtag_slave_write_n => jtag_uart_avalon_jtag_slave_write_n,
      jtag_uart_avalon_jtag_slave_writedata => jtag_uart_avalon_jtag_slave_writedata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      jtag_uart_avalon_jtag_slave_dataavailable => jtag_uart_avalon_jtag_slave_dataavailable,
      jtag_uart_avalon_jtag_slave_irq => jtag_uart_avalon_jtag_slave_irq,
      jtag_uart_avalon_jtag_slave_readdata => jtag_uart_avalon_jtag_slave_readdata,
      jtag_uart_avalon_jtag_slave_readyfordata => jtag_uart_avalon_jtag_slave_readyfordata,
      jtag_uart_avalon_jtag_slave_waitrequest => jtag_uart_avalon_jtag_slave_waitrequest,
      reset_n => clk100_reset_n
    );


  --the_jtag_uart, which is an e_ptf_instance
  the_jtag_uart : jtag_uart
    port map(
      av_irq => jtag_uart_avalon_jtag_slave_irq,
      av_readdata => jtag_uart_avalon_jtag_slave_readdata,
      av_waitrequest => jtag_uart_avalon_jtag_slave_waitrequest,
      dataavailable => jtag_uart_avalon_jtag_slave_dataavailable,
      readyfordata => jtag_uart_avalon_jtag_slave_readyfordata,
      av_address => jtag_uart_avalon_jtag_slave_address,
      av_chipselect => jtag_uart_avalon_jtag_slave_chipselect,
      av_read_n => jtag_uart_avalon_jtag_slave_read_n,
      av_write_n => jtag_uart_avalon_jtag_slave_write_n,
      av_writedata => jtag_uart_avalon_jtag_slave_writedata,
      clk => internal_clk100,
      rst_n => jtag_uart_avalon_jtag_slave_reset_n
    );


  --the_laser_uart_s1, which is an e_instance
  the_laser_uart_s1 : laser_uart_s1_arbitrator
    port map(
      cpu_data_master_granted_laser_uart_s1 => cpu_data_master_granted_laser_uart_s1,
      cpu_data_master_qualified_request_laser_uart_s1 => cpu_data_master_qualified_request_laser_uart_s1,
      cpu_data_master_read_data_valid_laser_uart_s1 => cpu_data_master_read_data_valid_laser_uart_s1,
      cpu_data_master_requests_laser_uart_s1 => cpu_data_master_requests_laser_uart_s1,
      d1_laser_uart_s1_end_xfer => d1_laser_uart_s1_end_xfer,
      laser_uart_s1_address => laser_uart_s1_address,
      laser_uart_s1_begintransfer => laser_uart_s1_begintransfer,
      laser_uart_s1_chipselect => laser_uart_s1_chipselect,
      laser_uart_s1_dataavailable_from_sa => laser_uart_s1_dataavailable_from_sa,
      laser_uart_s1_irq_from_sa => laser_uart_s1_irq_from_sa,
      laser_uart_s1_read_n => laser_uart_s1_read_n,
      laser_uart_s1_readdata_from_sa => laser_uart_s1_readdata_from_sa,
      laser_uart_s1_readyfordata_from_sa => laser_uart_s1_readyfordata_from_sa,
      laser_uart_s1_reset_n => laser_uart_s1_reset_n,
      laser_uart_s1_write_n => laser_uart_s1_write_n,
      laser_uart_s1_writedata => laser_uart_s1_writedata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      laser_uart_s1_dataavailable => laser_uart_s1_dataavailable,
      laser_uart_s1_irq => laser_uart_s1_irq,
      laser_uart_s1_readdata => laser_uart_s1_readdata,
      laser_uart_s1_readyfordata => laser_uart_s1_readyfordata,
      reset_n => clk100_reset_n
    );


  --the_laser_uart, which is an e_ptf_instance
  the_laser_uart : laser_uart
    port map(
      dataavailable => laser_uart_s1_dataavailable,
      irq => laser_uart_s1_irq,
      readdata => laser_uart_s1_readdata,
      readyfordata => laser_uart_s1_readyfordata,
      txd => internal_txd_from_the_laser_uart,
      address => laser_uart_s1_address,
      begintransfer => laser_uart_s1_begintransfer,
      chipselect => laser_uart_s1_chipselect,
      clk => internal_clk100,
      read_n => laser_uart_s1_read_n,
      reset_n => laser_uart_s1_reset_n,
      rxd => rxd_to_the_laser_uart,
      write_n => laser_uart_s1_write_n,
      writedata => laser_uart_s1_writedata
    );


  --the_onchip_mem_s1, which is an e_instance
  the_onchip_mem_s1 : onchip_mem_s1_arbitrator
    port map(
      cpu_data_master_granted_onchip_mem_s1 => cpu_data_master_granted_onchip_mem_s1,
      cpu_data_master_qualified_request_onchip_mem_s1 => cpu_data_master_qualified_request_onchip_mem_s1,
      cpu_data_master_read_data_valid_onchip_mem_s1 => cpu_data_master_read_data_valid_onchip_mem_s1,
      cpu_data_master_requests_onchip_mem_s1 => cpu_data_master_requests_onchip_mem_s1,
      cpu_instruction_master_granted_onchip_mem_s1 => cpu_instruction_master_granted_onchip_mem_s1,
      cpu_instruction_master_qualified_request_onchip_mem_s1 => cpu_instruction_master_qualified_request_onchip_mem_s1,
      cpu_instruction_master_read_data_valid_onchip_mem_s1 => cpu_instruction_master_read_data_valid_onchip_mem_s1,
      cpu_instruction_master_requests_onchip_mem_s1 => cpu_instruction_master_requests_onchip_mem_s1,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      onchip_mem_s1_address => onchip_mem_s1_address,
      onchip_mem_s1_byteenable => onchip_mem_s1_byteenable,
      onchip_mem_s1_chipselect => onchip_mem_s1_chipselect,
      onchip_mem_s1_clken => onchip_mem_s1_clken,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      onchip_mem_s1_write => onchip_mem_s1_write,
      onchip_mem_s1_writedata => onchip_mem_s1_writedata,
      registered_cpu_data_master_read_data_valid_onchip_mem_s1 => registered_cpu_data_master_read_data_valid_onchip_mem_s1,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register => cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register,
      onchip_mem_s1_readdata => onchip_mem_s1_readdata,
      reset_n => clk100_reset_n
    );


  --the_onchip_mem, which is an e_ptf_instance
  the_onchip_mem : onchip_mem
    port map(
      readdata => onchip_mem_s1_readdata,
      address => onchip_mem_s1_address,
      byteenable => onchip_mem_s1_byteenable,
      chipselect => onchip_mem_s1_chipselect,
      clk => internal_clk100,
      clken => onchip_mem_s1_clken,
      write => onchip_mem_s1_write,
      writedata => onchip_mem_s1_writedata
    );


  --the_ranger_cpu_clock_0_in, which is an e_instance
  the_ranger_cpu_clock_0_in : ranger_cpu_clock_0_in_arbitrator
    port map(
      cpu_data_master_granted_ranger_cpu_clock_0_in => cpu_data_master_granted_ranger_cpu_clock_0_in,
      cpu_data_master_qualified_request_ranger_cpu_clock_0_in => cpu_data_master_qualified_request_ranger_cpu_clock_0_in,
      cpu_data_master_read_data_valid_ranger_cpu_clock_0_in => cpu_data_master_read_data_valid_ranger_cpu_clock_0_in,
      cpu_data_master_requests_ranger_cpu_clock_0_in => cpu_data_master_requests_ranger_cpu_clock_0_in,
      d1_ranger_cpu_clock_0_in_end_xfer => d1_ranger_cpu_clock_0_in_end_xfer,
      ranger_cpu_clock_0_in_address => ranger_cpu_clock_0_in_address,
      ranger_cpu_clock_0_in_byteenable => ranger_cpu_clock_0_in_byteenable,
      ranger_cpu_clock_0_in_endofpacket_from_sa => ranger_cpu_clock_0_in_endofpacket_from_sa,
      ranger_cpu_clock_0_in_nativeaddress => ranger_cpu_clock_0_in_nativeaddress,
      ranger_cpu_clock_0_in_read => ranger_cpu_clock_0_in_read,
      ranger_cpu_clock_0_in_readdata_from_sa => ranger_cpu_clock_0_in_readdata_from_sa,
      ranger_cpu_clock_0_in_reset_n => ranger_cpu_clock_0_in_reset_n,
      ranger_cpu_clock_0_in_waitrequest_from_sa => ranger_cpu_clock_0_in_waitrequest_from_sa,
      ranger_cpu_clock_0_in_write => ranger_cpu_clock_0_in_write,
      ranger_cpu_clock_0_in_writedata => ranger_cpu_clock_0_in_writedata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      ranger_cpu_clock_0_in_endofpacket => ranger_cpu_clock_0_in_endofpacket,
      ranger_cpu_clock_0_in_readdata => ranger_cpu_clock_0_in_readdata,
      ranger_cpu_clock_0_in_waitrequest => ranger_cpu_clock_0_in_waitrequest,
      reset_n => clk100_reset_n
    );


  --the_ranger_cpu_clock_0_out, which is an e_instance
  the_ranger_cpu_clock_0_out : ranger_cpu_clock_0_out_arbitrator
    port map(
      ranger_cpu_clock_0_out_address_to_slave => ranger_cpu_clock_0_out_address_to_slave,
      ranger_cpu_clock_0_out_readdata => ranger_cpu_clock_0_out_readdata,
      ranger_cpu_clock_0_out_reset_n => ranger_cpu_clock_0_out_reset_n,
      ranger_cpu_clock_0_out_waitrequest => ranger_cpu_clock_0_out_waitrequest,
      clk => clk50,
      d1_dm9000a_avalon_slave_0_end_xfer => d1_dm9000a_avalon_slave_0_end_xfer,
      dm9000a_avalon_slave_0_readdata_from_sa => dm9000a_avalon_slave_0_readdata_from_sa,
      ranger_cpu_clock_0_out_address => ranger_cpu_clock_0_out_address,
      ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_granted_dm9000a_avalon_slave_0,
      ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_qualified_request_dm9000a_avalon_slave_0,
      ranger_cpu_clock_0_out_read => ranger_cpu_clock_0_out_read,
      ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_read_data_valid_dm9000a_avalon_slave_0,
      ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0 => ranger_cpu_clock_0_out_requests_dm9000a_avalon_slave_0,
      ranger_cpu_clock_0_out_write => ranger_cpu_clock_0_out_write,
      ranger_cpu_clock_0_out_writedata => ranger_cpu_clock_0_out_writedata,
      reset_n => clk50_reset_n
    );


  --the_ranger_cpu_clock_0, which is an e_ptf_instance
  the_ranger_cpu_clock_0 : ranger_cpu_clock_0
    port map(
      master_address => ranger_cpu_clock_0_out_address,
      master_byteenable => ranger_cpu_clock_0_out_byteenable,
      master_nativeaddress => ranger_cpu_clock_0_out_nativeaddress,
      master_read => ranger_cpu_clock_0_out_read,
      master_write => ranger_cpu_clock_0_out_write,
      master_writedata => ranger_cpu_clock_0_out_writedata,
      slave_endofpacket => ranger_cpu_clock_0_in_endofpacket,
      slave_readdata => ranger_cpu_clock_0_in_readdata,
      slave_waitrequest => ranger_cpu_clock_0_in_waitrequest,
      master_clk => clk50,
      master_endofpacket => ranger_cpu_clock_0_out_endofpacket,
      master_readdata => ranger_cpu_clock_0_out_readdata,
      master_reset_n => ranger_cpu_clock_0_out_reset_n,
      master_waitrequest => ranger_cpu_clock_0_out_waitrequest,
      slave_address => ranger_cpu_clock_0_in_address,
      slave_byteenable => ranger_cpu_clock_0_in_byteenable,
      slave_clk => internal_clk100,
      slave_nativeaddress => ranger_cpu_clock_0_in_nativeaddress,
      slave_read => ranger_cpu_clock_0_in_read,
      slave_reset_n => ranger_cpu_clock_0_in_reset_n,
      slave_write => ranger_cpu_clock_0_in_write,
      slave_writedata => ranger_cpu_clock_0_in_writedata
    );


  --the_ranger_cpu_clock_1_in, which is an e_instance
  the_ranger_cpu_clock_1_in : ranger_cpu_clock_1_in_arbitrator
    port map(
      cpu_instruction_master_granted_ranger_cpu_clock_1_in => cpu_instruction_master_granted_ranger_cpu_clock_1_in,
      cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in => cpu_instruction_master_qualified_request_ranger_cpu_clock_1_in,
      cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in => cpu_instruction_master_read_data_valid_ranger_cpu_clock_1_in,
      cpu_instruction_master_requests_ranger_cpu_clock_1_in => cpu_instruction_master_requests_ranger_cpu_clock_1_in,
      d1_ranger_cpu_clock_1_in_end_xfer => d1_ranger_cpu_clock_1_in_end_xfer,
      ranger_cpu_clock_1_in_address => ranger_cpu_clock_1_in_address,
      ranger_cpu_clock_1_in_byteenable => ranger_cpu_clock_1_in_byteenable,
      ranger_cpu_clock_1_in_endofpacket_from_sa => ranger_cpu_clock_1_in_endofpacket_from_sa,
      ranger_cpu_clock_1_in_nativeaddress => ranger_cpu_clock_1_in_nativeaddress,
      ranger_cpu_clock_1_in_read => ranger_cpu_clock_1_in_read,
      ranger_cpu_clock_1_in_readdata_from_sa => ranger_cpu_clock_1_in_readdata_from_sa,
      ranger_cpu_clock_1_in_reset_n => ranger_cpu_clock_1_in_reset_n,
      ranger_cpu_clock_1_in_waitrequest_from_sa => ranger_cpu_clock_1_in_waitrequest_from_sa,
      ranger_cpu_clock_1_in_write => ranger_cpu_clock_1_in_write,
      clk => internal_clk100,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register => cpu_instruction_master_read_data_valid_ddr2_deva_s1_shift_register,
      ranger_cpu_clock_1_in_endofpacket => ranger_cpu_clock_1_in_endofpacket,
      ranger_cpu_clock_1_in_readdata => ranger_cpu_clock_1_in_readdata,
      ranger_cpu_clock_1_in_waitrequest => ranger_cpu_clock_1_in_waitrequest,
      reset_n => clk100_reset_n
    );


  --the_ranger_cpu_clock_1_out, which is an e_instance
  the_ranger_cpu_clock_1_out : ranger_cpu_clock_1_out_arbitrator
    port map(
      ranger_cpu_clock_1_out_address_to_slave => ranger_cpu_clock_1_out_address_to_slave,
      ranger_cpu_clock_1_out_readdata => ranger_cpu_clock_1_out_readdata,
      ranger_cpu_clock_1_out_reset_n => ranger_cpu_clock_1_out_reset_n,
      ranger_cpu_clock_1_out_waitrequest => ranger_cpu_clock_1_out_waitrequest,
      clk => internal_ddr2_devb_phy_clk_out,
      d1_ddr2_devb_s1_end_xfer => d1_ddr2_devb_s1_end_xfer,
      ddr2_devb_s1_readdata_from_sa => ddr2_devb_s1_readdata_from_sa,
      ddr2_devb_s1_waitrequest_n_from_sa => ddr2_devb_s1_waitrequest_n_from_sa,
      ranger_cpu_clock_1_out_address => ranger_cpu_clock_1_out_address,
      ranger_cpu_clock_1_out_granted_ddr2_devb_s1 => ranger_cpu_clock_1_out_granted_ddr2_devb_s1,
      ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1 => ranger_cpu_clock_1_out_qualified_request_ddr2_devb_s1,
      ranger_cpu_clock_1_out_read => ranger_cpu_clock_1_out_read,
      ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1 => ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1,
      ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register => ranger_cpu_clock_1_out_read_data_valid_ddr2_devb_s1_shift_register,
      ranger_cpu_clock_1_out_requests_ddr2_devb_s1 => ranger_cpu_clock_1_out_requests_ddr2_devb_s1,
      ranger_cpu_clock_1_out_write => ranger_cpu_clock_1_out_write,
      ranger_cpu_clock_1_out_writedata => ranger_cpu_clock_1_out_writedata,
      reset_n => ddr2_devb_phy_clk_out_reset_n
    );


  --the_ranger_cpu_clock_1, which is an e_ptf_instance
  the_ranger_cpu_clock_1 : ranger_cpu_clock_1
    port map(
      master_address => ranger_cpu_clock_1_out_address,
      master_byteenable => ranger_cpu_clock_1_out_byteenable,
      master_nativeaddress => ranger_cpu_clock_1_out_nativeaddress,
      master_read => ranger_cpu_clock_1_out_read,
      master_write => ranger_cpu_clock_1_out_write,
      master_writedata => ranger_cpu_clock_1_out_writedata,
      slave_endofpacket => ranger_cpu_clock_1_in_endofpacket,
      slave_readdata => ranger_cpu_clock_1_in_readdata,
      slave_waitrequest => ranger_cpu_clock_1_in_waitrequest,
      master_clk => internal_ddr2_devb_phy_clk_out,
      master_endofpacket => ranger_cpu_clock_1_out_endofpacket,
      master_readdata => ranger_cpu_clock_1_out_readdata,
      master_reset_n => ranger_cpu_clock_1_out_reset_n,
      master_waitrequest => ranger_cpu_clock_1_out_waitrequest,
      slave_address => ranger_cpu_clock_1_in_address,
      slave_byteenable => ranger_cpu_clock_1_in_byteenable,
      slave_clk => internal_clk100,
      slave_nativeaddress => ranger_cpu_clock_1_in_nativeaddress,
      slave_read => ranger_cpu_clock_1_in_read,
      slave_reset_n => ranger_cpu_clock_1_in_reset_n,
      slave_write => ranger_cpu_clock_1_in_write,
      slave_writedata => ranger_cpu_clock_1_in_writedata
    );


  --the_ranger_cpu_clock_2_in, which is an e_instance
  the_ranger_cpu_clock_2_in : ranger_cpu_clock_2_in_arbitrator
    port map(
      cpu_data_master_granted_ranger_cpu_clock_2_in => cpu_data_master_granted_ranger_cpu_clock_2_in,
      cpu_data_master_qualified_request_ranger_cpu_clock_2_in => cpu_data_master_qualified_request_ranger_cpu_clock_2_in,
      cpu_data_master_read_data_valid_ranger_cpu_clock_2_in => cpu_data_master_read_data_valid_ranger_cpu_clock_2_in,
      cpu_data_master_requests_ranger_cpu_clock_2_in => cpu_data_master_requests_ranger_cpu_clock_2_in,
      d1_ranger_cpu_clock_2_in_end_xfer => d1_ranger_cpu_clock_2_in_end_xfer,
      ranger_cpu_clock_2_in_address => ranger_cpu_clock_2_in_address,
      ranger_cpu_clock_2_in_byteenable => ranger_cpu_clock_2_in_byteenable,
      ranger_cpu_clock_2_in_endofpacket_from_sa => ranger_cpu_clock_2_in_endofpacket_from_sa,
      ranger_cpu_clock_2_in_nativeaddress => ranger_cpu_clock_2_in_nativeaddress,
      ranger_cpu_clock_2_in_read => ranger_cpu_clock_2_in_read,
      ranger_cpu_clock_2_in_readdata_from_sa => ranger_cpu_clock_2_in_readdata_from_sa,
      ranger_cpu_clock_2_in_reset_n => ranger_cpu_clock_2_in_reset_n,
      ranger_cpu_clock_2_in_waitrequest_from_sa => ranger_cpu_clock_2_in_waitrequest_from_sa,
      ranger_cpu_clock_2_in_write => ranger_cpu_clock_2_in_write,
      ranger_cpu_clock_2_in_writedata => ranger_cpu_clock_2_in_writedata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      ranger_cpu_clock_2_in_endofpacket => ranger_cpu_clock_2_in_endofpacket,
      ranger_cpu_clock_2_in_readdata => ranger_cpu_clock_2_in_readdata,
      ranger_cpu_clock_2_in_waitrequest => ranger_cpu_clock_2_in_waitrequest,
      reset_n => clk100_reset_n
    );


  --the_ranger_cpu_clock_2_out, which is an e_instance
  the_ranger_cpu_clock_2_out : ranger_cpu_clock_2_out_arbitrator
    port map(
      ranger_cpu_clock_2_out_address_to_slave => ranger_cpu_clock_2_out_address_to_slave,
      ranger_cpu_clock_2_out_readdata => ranger_cpu_clock_2_out_readdata,
      ranger_cpu_clock_2_out_reset_n => ranger_cpu_clock_2_out_reset_n,
      ranger_cpu_clock_2_out_waitrequest => ranger_cpu_clock_2_out_waitrequest,
      clk => internal_ddr2_devb_phy_clk_out,
      d1_ddr2_devb_s1_end_xfer => d1_ddr2_devb_s1_end_xfer,
      ddr2_devb_s1_readdata_from_sa => ddr2_devb_s1_readdata_from_sa,
      ddr2_devb_s1_waitrequest_n_from_sa => ddr2_devb_s1_waitrequest_n_from_sa,
      ranger_cpu_clock_2_out_address => ranger_cpu_clock_2_out_address,
      ranger_cpu_clock_2_out_granted_ddr2_devb_s1 => ranger_cpu_clock_2_out_granted_ddr2_devb_s1,
      ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1 => ranger_cpu_clock_2_out_qualified_request_ddr2_devb_s1,
      ranger_cpu_clock_2_out_read => ranger_cpu_clock_2_out_read,
      ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1 => ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1,
      ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register => ranger_cpu_clock_2_out_read_data_valid_ddr2_devb_s1_shift_register,
      ranger_cpu_clock_2_out_requests_ddr2_devb_s1 => ranger_cpu_clock_2_out_requests_ddr2_devb_s1,
      ranger_cpu_clock_2_out_write => ranger_cpu_clock_2_out_write,
      ranger_cpu_clock_2_out_writedata => ranger_cpu_clock_2_out_writedata,
      reset_n => ddr2_devb_phy_clk_out_reset_n
    );


  --the_ranger_cpu_clock_2, which is an e_ptf_instance
  the_ranger_cpu_clock_2 : ranger_cpu_clock_2
    port map(
      master_address => ranger_cpu_clock_2_out_address,
      master_byteenable => ranger_cpu_clock_2_out_byteenable,
      master_nativeaddress => ranger_cpu_clock_2_out_nativeaddress,
      master_read => ranger_cpu_clock_2_out_read,
      master_write => ranger_cpu_clock_2_out_write,
      master_writedata => ranger_cpu_clock_2_out_writedata,
      slave_endofpacket => ranger_cpu_clock_2_in_endofpacket,
      slave_readdata => ranger_cpu_clock_2_in_readdata,
      slave_waitrequest => ranger_cpu_clock_2_in_waitrequest,
      master_clk => internal_ddr2_devb_phy_clk_out,
      master_endofpacket => ranger_cpu_clock_2_out_endofpacket,
      master_readdata => ranger_cpu_clock_2_out_readdata,
      master_reset_n => ranger_cpu_clock_2_out_reset_n,
      master_waitrequest => ranger_cpu_clock_2_out_waitrequest,
      slave_address => ranger_cpu_clock_2_in_address,
      slave_byteenable => ranger_cpu_clock_2_in_byteenable,
      slave_clk => internal_clk100,
      slave_nativeaddress => ranger_cpu_clock_2_in_nativeaddress,
      slave_read => ranger_cpu_clock_2_in_read,
      slave_reset_n => ranger_cpu_clock_2_in_reset_n,
      slave_write => ranger_cpu_clock_2_in_write,
      slave_writedata => ranger_cpu_clock_2_in_writedata
    );


  --the_sysid_control_slave, which is an e_instance
  the_sysid_control_slave : sysid_control_slave_arbitrator
    port map(
      cpu_data_master_granted_sysid_control_slave => cpu_data_master_granted_sysid_control_slave,
      cpu_data_master_qualified_request_sysid_control_slave => cpu_data_master_qualified_request_sysid_control_slave,
      cpu_data_master_read_data_valid_sysid_control_slave => cpu_data_master_read_data_valid_sysid_control_slave,
      cpu_data_master_requests_sysid_control_slave => cpu_data_master_requests_sysid_control_slave,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      sysid_control_slave_address => sysid_control_slave_address,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_write => cpu_data_master_write,
      reset_n => clk100_reset_n,
      sysid_control_slave_readdata => sysid_control_slave_readdata
    );


  --the_sysid, which is an e_ptf_instance
  the_sysid : sysid
    port map(
      readdata => sysid_control_slave_readdata,
      address => sysid_control_slave_address
    );


  --the_timer_1ms_s1, which is an e_instance
  the_timer_1ms_s1 : timer_1ms_s1_arbitrator
    port map(
      cpu_data_master_granted_timer_1ms_s1 => cpu_data_master_granted_timer_1ms_s1,
      cpu_data_master_qualified_request_timer_1ms_s1 => cpu_data_master_qualified_request_timer_1ms_s1,
      cpu_data_master_read_data_valid_timer_1ms_s1 => cpu_data_master_read_data_valid_timer_1ms_s1,
      cpu_data_master_requests_timer_1ms_s1 => cpu_data_master_requests_timer_1ms_s1,
      d1_timer_1ms_s1_end_xfer => d1_timer_1ms_s1_end_xfer,
      timer_1ms_s1_address => timer_1ms_s1_address,
      timer_1ms_s1_chipselect => timer_1ms_s1_chipselect,
      timer_1ms_s1_irq_from_sa => timer_1ms_s1_irq_from_sa,
      timer_1ms_s1_readdata_from_sa => timer_1ms_s1_readdata_from_sa,
      timer_1ms_s1_reset_n => timer_1ms_s1_reset_n,
      timer_1ms_s1_write_n => timer_1ms_s1_write_n,
      timer_1ms_s1_writedata => timer_1ms_s1_writedata,
      clk => internal_clk100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk100_reset_n,
      timer_1ms_s1_irq => timer_1ms_s1_irq,
      timer_1ms_s1_readdata => timer_1ms_s1_readdata
    );


  --the_timer_1ms, which is an e_ptf_instance
  the_timer_1ms : timer_1ms
    port map(
      irq => timer_1ms_s1_irq,
      readdata => timer_1ms_s1_readdata,
      address => timer_1ms_s1_address,
      chipselect => timer_1ms_s1_chipselect,
      clk => internal_clk100,
      reset_n => timer_1ms_s1_reset_n,
      write_n => timer_1ms_s1_write_n,
      writedata => timer_1ms_s1_writedata
    );


  --reset is asserted asynchronously and deasserted synchronously
  ranger_cpu_reset_clk100_domain_synch : ranger_cpu_reset_clk100_domain_synch_module
    port map(
      data_out => clk100_reset_n,
      clk => internal_clk100,
      data_in => module_input13,
      reset_n => reset_n_sources
    );

  module_input13 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  ranger_cpu_reset_ddr2_devb_phy_clk_out_domain_synch : ranger_cpu_reset_ddr2_devb_phy_clk_out_domain_synch_module
    port map(
      data_out => ddr2_devb_phy_clk_out_reset_n,
      clk => internal_ddr2_devb_phy_clk_out,
      data_in => module_input14,
      reset_n => reset_n_sources
    );

  module_input14 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  ranger_cpu_reset_clk50_domain_synch : ranger_cpu_reset_clk50_domain_synch_module
    port map(
      data_out => clk50_reset_n,
      clk => clk50,
      data_in => module_input15,
      reset_n => reset_n_sources
    );

  module_input15 <= std_logic'('1');

  --ranger_cpu_clock_0_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  ranger_cpu_clock_0_out_endofpacket <= std_logic'('0');
  --ranger_cpu_clock_1_in_writedata of type writedata does not connect to anything so wire it to default (0)
  ranger_cpu_clock_1_in_writedata <= std_logic_vector'("00000000000000000000000000000000");
  --ranger_cpu_clock_1_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  ranger_cpu_clock_1_out_endofpacket <= std_logic'('0');
  --ranger_cpu_clock_2_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  ranger_cpu_clock_2_out_endofpacket <= std_logic'('0');
  --vhdl renameroo for output signals
  ENET_CLK_from_the_dm9000a <= internal_ENET_CLK_from_the_dm9000a;
  --vhdl renameroo for output signals
  ENET_CMD_from_the_dm9000a <= internal_ENET_CMD_from_the_dm9000a;
  --vhdl renameroo for output signals
  ENET_CS_N_from_the_dm9000a <= internal_ENET_CS_N_from_the_dm9000a;
  --vhdl renameroo for output signals
  ENET_RD_N_from_the_dm9000a <= internal_ENET_RD_N_from_the_dm9000a;
  --vhdl renameroo for output signals
  ENET_RST_N_from_the_dm9000a <= internal_ENET_RST_N_from_the_dm9000a;
  --vhdl renameroo for output signals
  ENET_WR_N_from_the_dm9000a <= internal_ENET_WR_N_from_the_dm9000a;
  --vhdl renameroo for output signals
  clk100 <= internal_clk100;
  --vhdl renameroo for output signals
  ddr2_devb_phy_clk_out <= internal_ddr2_devb_phy_clk_out;
  --vhdl renameroo for output signals
  ex_addr_from_the_BL <= internal_ex_addr_from_the_BL;
  --vhdl renameroo for output signals
  ex_addr_from_the_BR <= internal_ex_addr_from_the_BR;
  --vhdl renameroo for output signals
  ex_addr_from_the_TL <= internal_ex_addr_from_the_TL;
  --vhdl renameroo for output signals
  ex_addr_from_the_TR <= internal_ex_addr_from_the_TR;
  --vhdl renameroo for output signals
  ex_addr_from_the_control <= internal_ex_addr_from_the_control;
  --vhdl renameroo for output signals
  ex_clk_from_the_BL <= internal_ex_clk_from_the_BL;
  --vhdl renameroo for output signals
  ex_clk_from_the_BR <= internal_ex_clk_from_the_BR;
  --vhdl renameroo for output signals
  ex_clk_from_the_TL <= internal_ex_clk_from_the_TL;
  --vhdl renameroo for output signals
  ex_clk_from_the_TR <= internal_ex_clk_from_the_TR;
  --vhdl renameroo for output signals
  ex_clk_from_the_control <= internal_ex_clk_from_the_control;
  --vhdl renameroo for output signals
  ex_din_from_the_BL <= internal_ex_din_from_the_BL;
  --vhdl renameroo for output signals
  ex_din_from_the_BR <= internal_ex_din_from_the_BR;
  --vhdl renameroo for output signals
  ex_din_from_the_TL <= internal_ex_din_from_the_TL;
  --vhdl renameroo for output signals
  ex_din_from_the_TR <= internal_ex_din_from_the_TR;
  --vhdl renameroo for output signals
  ex_din_from_the_control <= internal_ex_din_from_the_control;
  --vhdl renameroo for output signals
  ex_re_n_from_the_BL <= internal_ex_re_n_from_the_BL;
  --vhdl renameroo for output signals
  ex_re_n_from_the_BR <= internal_ex_re_n_from_the_BR;
  --vhdl renameroo for output signals
  ex_re_n_from_the_TL <= internal_ex_re_n_from_the_TL;
  --vhdl renameroo for output signals
  ex_re_n_from_the_TR <= internal_ex_re_n_from_the_TR;
  --vhdl renameroo for output signals
  ex_re_n_from_the_control <= internal_ex_re_n_from_the_control;
  --vhdl renameroo for output signals
  ex_reset_n_from_the_BL <= internal_ex_reset_n_from_the_BL;
  --vhdl renameroo for output signals
  ex_reset_n_from_the_BR <= internal_ex_reset_n_from_the_BR;
  --vhdl renameroo for output signals
  ex_reset_n_from_the_TL <= internal_ex_reset_n_from_the_TL;
  --vhdl renameroo for output signals
  ex_reset_n_from_the_TR <= internal_ex_reset_n_from_the_TR;
  --vhdl renameroo for output signals
  ex_reset_n_from_the_control <= internal_ex_reset_n_from_the_control;
  --vhdl renameroo for output signals
  ex_we_n_from_the_BL <= internal_ex_we_n_from_the_BL;
  --vhdl renameroo for output signals
  ex_we_n_from_the_BR <= internal_ex_we_n_from_the_BR;
  --vhdl renameroo for output signals
  ex_we_n_from_the_TL <= internal_ex_we_n_from_the_TL;
  --vhdl renameroo for output signals
  ex_we_n_from_the_TR <= internal_ex_we_n_from_the_TR;
  --vhdl renameroo for output signals
  ex_we_n_from_the_control <= internal_ex_we_n_from_the_control;
  --vhdl renameroo for output signals
  local_init_done_from_the_ddr2_deva <= internal_local_init_done_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  local_init_done_from_the_ddr2_devb <= internal_local_init_done_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  local_refresh_ack_from_the_ddr2_deva <= internal_local_refresh_ack_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  local_refresh_ack_from_the_ddr2_devb <= internal_local_refresh_ack_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  local_wdata_req_from_the_ddr2_deva <= internal_local_wdata_req_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  local_wdata_req_from_the_ddr2_devb <= internal_local_wdata_req_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_addr_from_the_ddr2_deva <= internal_mem_addr_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_addr_from_the_ddr2_devb <= internal_mem_addr_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_ba_from_the_ddr2_deva <= internal_mem_ba_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_ba_from_the_ddr2_devb <= internal_mem_ba_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_cas_n_from_the_ddr2_deva <= internal_mem_cas_n_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_cas_n_from_the_ddr2_devb <= internal_mem_cas_n_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_cke_from_the_ddr2_deva <= internal_mem_cke_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_cke_from_the_ddr2_devb <= internal_mem_cke_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_cs_n_from_the_ddr2_deva <= internal_mem_cs_n_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_cs_n_from_the_ddr2_devb <= internal_mem_cs_n_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_dm_from_the_ddr2_deva <= internal_mem_dm_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_dm_from_the_ddr2_devb <= internal_mem_dm_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_odt_from_the_ddr2_deva <= internal_mem_odt_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_odt_from_the_ddr2_devb <= internal_mem_odt_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_ras_n_from_the_ddr2_deva <= internal_mem_ras_n_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_ras_n_from_the_ddr2_devb <= internal_mem_ras_n_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  mem_we_n_from_the_ddr2_deva <= internal_mem_we_n_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  mem_we_n_from_the_ddr2_devb <= internal_mem_we_n_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  reset_phy_clk_n_from_the_ddr2_deva <= internal_reset_phy_clk_n_from_the_ddr2_deva;
  --vhdl renameroo for output signals
  reset_phy_clk_n_from_the_ddr2_devb <= internal_reset_phy_clk_n_from_the_ddr2_devb;
  --vhdl renameroo for output signals
  txd_from_the_laser_uart <= internal_txd_from_the_laser_uart;

end europa;


--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your libraries here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>

entity test_bench is 
end entity test_bench;


architecture europa of test_bench is
component ranger_cpu is 
           port (
                 -- 1) global signals:
                    signal clk100 : OUT STD_LOGIC;
                    signal clk125 : IN STD_LOGIC;
                    signal clk50 : IN STD_LOGIC;
                    signal ddr2_deva_aux_full_rate_clk_out : OUT STD_LOGIC;
                    signal ddr2_deva_aux_half_rate_clk_out : OUT STD_LOGIC;
                    signal ddr2_devb_aux_full_rate_clk_out : OUT STD_LOGIC;
                    signal ddr2_devb_aux_half_rate_clk_out : OUT STD_LOGIC;
                    signal ddr2_devb_phy_clk_out : OUT STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_BL
                    signal ex_addr_from_the_BL : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ex_clk_from_the_BL : OUT STD_LOGIC;
                    signal ex_din_from_the_BL : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_dout_to_the_BL : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_re_n_from_the_BL : OUT STD_LOGIC;
                    signal ex_reset_n_from_the_BL : OUT STD_LOGIC;
                    signal ex_we_n_from_the_BL : OUT STD_LOGIC;

                 -- the_BR
                    signal ex_addr_from_the_BR : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ex_clk_from_the_BR : OUT STD_LOGIC;
                    signal ex_din_from_the_BR : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_dout_to_the_BR : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_re_n_from_the_BR : OUT STD_LOGIC;
                    signal ex_reset_n_from_the_BR : OUT STD_LOGIC;
                    signal ex_we_n_from_the_BR : OUT STD_LOGIC;

                 -- the_TL
                    signal ex_addr_from_the_TL : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ex_clk_from_the_TL : OUT STD_LOGIC;
                    signal ex_din_from_the_TL : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_dout_to_the_TL : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_re_n_from_the_TL : OUT STD_LOGIC;
                    signal ex_reset_n_from_the_TL : OUT STD_LOGIC;
                    signal ex_we_n_from_the_TL : OUT STD_LOGIC;

                 -- the_TR
                    signal ex_addr_from_the_TR : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ex_clk_from_the_TR : OUT STD_LOGIC;
                    signal ex_din_from_the_TR : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_dout_to_the_TR : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_re_n_from_the_TR : OUT STD_LOGIC;
                    signal ex_reset_n_from_the_TR : OUT STD_LOGIC;
                    signal ex_we_n_from_the_TR : OUT STD_LOGIC;

                 -- the_control
                    signal ex_addr_from_the_control : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ex_clk_from_the_control : OUT STD_LOGIC;
                    signal ex_din_from_the_control : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_dout_to_the_control : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ex_re_n_from_the_control : OUT STD_LOGIC;
                    signal ex_reset_n_from_the_control : OUT STD_LOGIC;
                    signal ex_we_n_from_the_control : OUT STD_LOGIC;

                 -- the_ddr2_deva
                    signal global_reset_n_to_the_ddr2_deva : IN STD_LOGIC;
                    signal local_init_done_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal local_refresh_ack_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal local_wdata_req_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal mem_addr_from_the_ddr2_deva : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba_from_the_ddr2_deva : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_cas_n_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal mem_cke_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal mem_clk_n_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                    signal mem_clk_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                    signal mem_cs_n_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal mem_dm_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal mem_dq_to_and_from_the_ddr2_deva : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dqs_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                    signal mem_dqsn_to_and_from_the_ddr2_deva : INOUT STD_LOGIC;
                    signal mem_odt_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal mem_ras_n_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal mem_we_n_from_the_ddr2_deva : OUT STD_LOGIC;
                    signal oct_ctl_rs_value_to_the_ddr2_deva : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal oct_ctl_rt_value_to_the_ddr2_deva : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal reset_phy_clk_n_from_the_ddr2_deva : OUT STD_LOGIC;

                 -- the_ddr2_devb
                    signal global_reset_n_to_the_ddr2_devb : IN STD_LOGIC;
                    signal local_init_done_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal local_refresh_ack_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal local_wdata_req_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal mem_addr_from_the_ddr2_devb : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal mem_ba_from_the_ddr2_devb : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mem_cas_n_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal mem_cke_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal mem_clk_n_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                    signal mem_clk_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                    signal mem_cs_n_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal mem_dm_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal mem_dq_to_and_from_the_ddr2_devb : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal mem_dqs_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                    signal mem_dqsn_to_and_from_the_ddr2_devb : INOUT STD_LOGIC;
                    signal mem_odt_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal mem_ras_n_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal mem_we_n_from_the_ddr2_devb : OUT STD_LOGIC;
                    signal oct_ctl_rs_value_to_the_ddr2_devb : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal oct_ctl_rt_value_to_the_ddr2_devb : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal reset_phy_clk_n_from_the_ddr2_devb : OUT STD_LOGIC;

                 -- the_dm9000a
                    signal ENET_CLK_from_the_dm9000a : OUT STD_LOGIC;
                    signal ENET_CMD_from_the_dm9000a : OUT STD_LOGIC;
                    signal ENET_CS_N_from_the_dm9000a : OUT STD_LOGIC;
                    signal ENET_DATA_to_and_from_the_dm9000a : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ENET_INT_to_the_dm9000a : IN STD_LOGIC;
                    signal ENET_RD_N_from_the_dm9000a : OUT STD_LOGIC;
                    signal ENET_RST_N_from_the_dm9000a : OUT STD_LOGIC;
                    signal ENET_WR_N_from_the_dm9000a : OUT STD_LOGIC;
                    signal iOSC_50_to_the_dm9000a : IN STD_LOGIC;

                 -- the_frame_received
                    signal in_port_to_the_frame_received : IN STD_LOGIC;

                 -- the_laser_uart
                    signal rxd_to_the_laser_uart : IN STD_LOGIC;
                    signal txd_from_the_laser_uart : OUT STD_LOGIC
                 );
end component ranger_cpu;

                signal ENET_CLK_from_the_dm9000a :  STD_LOGIC;
                signal ENET_CMD_from_the_dm9000a :  STD_LOGIC;
                signal ENET_CS_N_from_the_dm9000a :  STD_LOGIC;
                signal ENET_DATA_to_and_from_the_dm9000a :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ENET_INT_to_the_dm9000a :  STD_LOGIC;
                signal ENET_RD_N_from_the_dm9000a :  STD_LOGIC;
                signal ENET_RST_N_from_the_dm9000a :  STD_LOGIC;
                signal ENET_WR_N_from_the_dm9000a :  STD_LOGIC;
                signal clk :  STD_LOGIC;
                signal clk100 :  STD_LOGIC;
                signal clk125 :  STD_LOGIC;
                signal clk50 :  STD_LOGIC;
                signal ddr2_deva_aux_full_rate_clk_out :  STD_LOGIC;
                signal ddr2_deva_aux_half_rate_clk_out :  STD_LOGIC;
                signal ddr2_devb_aux_full_rate_clk_out :  STD_LOGIC;
                signal ddr2_devb_aux_half_rate_clk_out :  STD_LOGIC;
                signal ddr2_devb_phy_clk_out :  STD_LOGIC;
                signal ex_addr_from_the_BL :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ex_addr_from_the_BR :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ex_addr_from_the_TL :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ex_addr_from_the_TR :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ex_addr_from_the_control :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ex_clk_from_the_BL :  STD_LOGIC;
                signal ex_clk_from_the_BR :  STD_LOGIC;
                signal ex_clk_from_the_TL :  STD_LOGIC;
                signal ex_clk_from_the_TR :  STD_LOGIC;
                signal ex_clk_from_the_control :  STD_LOGIC;
                signal ex_din_from_the_BL :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_din_from_the_BR :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_din_from_the_TL :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_din_from_the_TR :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_din_from_the_control :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_dout_to_the_BL :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_dout_to_the_BR :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_dout_to_the_TL :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_dout_to_the_TR :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_dout_to_the_control :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ex_re_n_from_the_BL :  STD_LOGIC;
                signal ex_re_n_from_the_BR :  STD_LOGIC;
                signal ex_re_n_from_the_TL :  STD_LOGIC;
                signal ex_re_n_from_the_TR :  STD_LOGIC;
                signal ex_re_n_from_the_control :  STD_LOGIC;
                signal ex_reset_n_from_the_BL :  STD_LOGIC;
                signal ex_reset_n_from_the_BR :  STD_LOGIC;
                signal ex_reset_n_from_the_TL :  STD_LOGIC;
                signal ex_reset_n_from_the_TR :  STD_LOGIC;
                signal ex_reset_n_from_the_control :  STD_LOGIC;
                signal ex_we_n_from_the_BL :  STD_LOGIC;
                signal ex_we_n_from_the_BR :  STD_LOGIC;
                signal ex_we_n_from_the_TL :  STD_LOGIC;
                signal ex_we_n_from_the_TR :  STD_LOGIC;
                signal ex_we_n_from_the_control :  STD_LOGIC;
                signal global_reset_n_to_the_ddr2_deva :  STD_LOGIC;
                signal global_reset_n_to_the_ddr2_devb :  STD_LOGIC;
                signal iOSC_50_to_the_dm9000a :  STD_LOGIC;
                signal in_port_to_the_frame_received :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal laser_uart_s1_dataavailable_from_sa :  STD_LOGIC;
                signal laser_uart_s1_readyfordata_from_sa :  STD_LOGIC;
                signal local_init_done_from_the_ddr2_deva :  STD_LOGIC;
                signal local_init_done_from_the_ddr2_devb :  STD_LOGIC;
                signal local_refresh_ack_from_the_ddr2_deva :  STD_LOGIC;
                signal local_refresh_ack_from_the_ddr2_devb :  STD_LOGIC;
                signal local_wdata_req_from_the_ddr2_deva :  STD_LOGIC;
                signal local_wdata_req_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_addr_from_the_ddr2_deva :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal mem_addr_from_the_ddr2_devb :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal mem_ba_from_the_ddr2_deva :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal mem_ba_from_the_ddr2_devb :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal mem_cas_n_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_cas_n_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_cke_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_cke_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_clk_n_to_and_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_clk_n_to_and_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_clk_to_and_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_clk_to_and_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_cs_n_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_cs_n_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_dm_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_dm_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_dq_to_and_from_the_ddr2_deva :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal mem_dq_to_and_from_the_ddr2_devb :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal mem_dqs_to_and_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_dqs_to_and_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_dqsn_to_and_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_dqsn_to_and_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_odt_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_odt_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_ras_n_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_ras_n_from_the_ddr2_devb :  STD_LOGIC;
                signal mem_we_n_from_the_ddr2_deva :  STD_LOGIC;
                signal mem_we_n_from_the_ddr2_devb :  STD_LOGIC;
                signal oct_ctl_rs_value_to_the_ddr2_deva :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal oct_ctl_rs_value_to_the_ddr2_devb :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal oct_ctl_rt_value_to_the_ddr2_deva :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal oct_ctl_rt_value_to_the_ddr2_devb :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal ranger_cpu_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_0_out_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_clock_0_out_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_1_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_clock_1_out_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ranger_cpu_clock_2_in_endofpacket_from_sa :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_endofpacket :  STD_LOGIC;
                signal ranger_cpu_clock_2_out_nativeaddress :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal reset_n :  STD_LOGIC;
                signal reset_phy_clk_n_from_the_ddr2_deva :  STD_LOGIC;
                signal reset_phy_clk_n_from_the_ddr2_devb :  STD_LOGIC;
                signal rxd_to_the_laser_uart :  STD_LOGIC;
                signal txd_from_the_laser_uart :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : ranger_cpu
    port map(
      ENET_CLK_from_the_dm9000a => ENET_CLK_from_the_dm9000a,
      ENET_CMD_from_the_dm9000a => ENET_CMD_from_the_dm9000a,
      ENET_CS_N_from_the_dm9000a => ENET_CS_N_from_the_dm9000a,
      ENET_DATA_to_and_from_the_dm9000a => ENET_DATA_to_and_from_the_dm9000a,
      ENET_RD_N_from_the_dm9000a => ENET_RD_N_from_the_dm9000a,
      ENET_RST_N_from_the_dm9000a => ENET_RST_N_from_the_dm9000a,
      ENET_WR_N_from_the_dm9000a => ENET_WR_N_from_the_dm9000a,
      clk100 => clk100,
      ddr2_deva_aux_full_rate_clk_out => ddr2_deva_aux_full_rate_clk_out,
      ddr2_deva_aux_half_rate_clk_out => ddr2_deva_aux_half_rate_clk_out,
      ddr2_devb_aux_full_rate_clk_out => ddr2_devb_aux_full_rate_clk_out,
      ddr2_devb_aux_half_rate_clk_out => ddr2_devb_aux_half_rate_clk_out,
      ddr2_devb_phy_clk_out => ddr2_devb_phy_clk_out,
      ex_addr_from_the_BL => ex_addr_from_the_BL,
      ex_addr_from_the_BR => ex_addr_from_the_BR,
      ex_addr_from_the_TL => ex_addr_from_the_TL,
      ex_addr_from_the_TR => ex_addr_from_the_TR,
      ex_addr_from_the_control => ex_addr_from_the_control,
      ex_clk_from_the_BL => ex_clk_from_the_BL,
      ex_clk_from_the_BR => ex_clk_from_the_BR,
      ex_clk_from_the_TL => ex_clk_from_the_TL,
      ex_clk_from_the_TR => ex_clk_from_the_TR,
      ex_clk_from_the_control => ex_clk_from_the_control,
      ex_din_from_the_BL => ex_din_from_the_BL,
      ex_din_from_the_BR => ex_din_from_the_BR,
      ex_din_from_the_TL => ex_din_from_the_TL,
      ex_din_from_the_TR => ex_din_from_the_TR,
      ex_din_from_the_control => ex_din_from_the_control,
      ex_re_n_from_the_BL => ex_re_n_from_the_BL,
      ex_re_n_from_the_BR => ex_re_n_from_the_BR,
      ex_re_n_from_the_TL => ex_re_n_from_the_TL,
      ex_re_n_from_the_TR => ex_re_n_from_the_TR,
      ex_re_n_from_the_control => ex_re_n_from_the_control,
      ex_reset_n_from_the_BL => ex_reset_n_from_the_BL,
      ex_reset_n_from_the_BR => ex_reset_n_from_the_BR,
      ex_reset_n_from_the_TL => ex_reset_n_from_the_TL,
      ex_reset_n_from_the_TR => ex_reset_n_from_the_TR,
      ex_reset_n_from_the_control => ex_reset_n_from_the_control,
      ex_we_n_from_the_BL => ex_we_n_from_the_BL,
      ex_we_n_from_the_BR => ex_we_n_from_the_BR,
      ex_we_n_from_the_TL => ex_we_n_from_the_TL,
      ex_we_n_from_the_TR => ex_we_n_from_the_TR,
      ex_we_n_from_the_control => ex_we_n_from_the_control,
      local_init_done_from_the_ddr2_deva => local_init_done_from_the_ddr2_deva,
      local_init_done_from_the_ddr2_devb => local_init_done_from_the_ddr2_devb,
      local_refresh_ack_from_the_ddr2_deva => local_refresh_ack_from_the_ddr2_deva,
      local_refresh_ack_from_the_ddr2_devb => local_refresh_ack_from_the_ddr2_devb,
      local_wdata_req_from_the_ddr2_deva => local_wdata_req_from_the_ddr2_deva,
      local_wdata_req_from_the_ddr2_devb => local_wdata_req_from_the_ddr2_devb,
      mem_addr_from_the_ddr2_deva => mem_addr_from_the_ddr2_deva,
      mem_addr_from_the_ddr2_devb => mem_addr_from_the_ddr2_devb,
      mem_ba_from_the_ddr2_deva => mem_ba_from_the_ddr2_deva,
      mem_ba_from_the_ddr2_devb => mem_ba_from_the_ddr2_devb,
      mem_cas_n_from_the_ddr2_deva => mem_cas_n_from_the_ddr2_deva,
      mem_cas_n_from_the_ddr2_devb => mem_cas_n_from_the_ddr2_devb,
      mem_cke_from_the_ddr2_deva => mem_cke_from_the_ddr2_deva,
      mem_cke_from_the_ddr2_devb => mem_cke_from_the_ddr2_devb,
      mem_clk_n_to_and_from_the_ddr2_deva => mem_clk_n_to_and_from_the_ddr2_deva,
      mem_clk_n_to_and_from_the_ddr2_devb => mem_clk_n_to_and_from_the_ddr2_devb,
      mem_clk_to_and_from_the_ddr2_deva => mem_clk_to_and_from_the_ddr2_deva,
      mem_clk_to_and_from_the_ddr2_devb => mem_clk_to_and_from_the_ddr2_devb,
      mem_cs_n_from_the_ddr2_deva => mem_cs_n_from_the_ddr2_deva,
      mem_cs_n_from_the_ddr2_devb => mem_cs_n_from_the_ddr2_devb,
      mem_dm_from_the_ddr2_deva => mem_dm_from_the_ddr2_deva,
      mem_dm_from_the_ddr2_devb => mem_dm_from_the_ddr2_devb,
      mem_dq_to_and_from_the_ddr2_deva => mem_dq_to_and_from_the_ddr2_deva,
      mem_dq_to_and_from_the_ddr2_devb => mem_dq_to_and_from_the_ddr2_devb,
      mem_dqs_to_and_from_the_ddr2_deva => mem_dqs_to_and_from_the_ddr2_deva,
      mem_dqs_to_and_from_the_ddr2_devb => mem_dqs_to_and_from_the_ddr2_devb,
      mem_dqsn_to_and_from_the_ddr2_deva => mem_dqsn_to_and_from_the_ddr2_deva,
      mem_dqsn_to_and_from_the_ddr2_devb => mem_dqsn_to_and_from_the_ddr2_devb,
      mem_odt_from_the_ddr2_deva => mem_odt_from_the_ddr2_deva,
      mem_odt_from_the_ddr2_devb => mem_odt_from_the_ddr2_devb,
      mem_ras_n_from_the_ddr2_deva => mem_ras_n_from_the_ddr2_deva,
      mem_ras_n_from_the_ddr2_devb => mem_ras_n_from_the_ddr2_devb,
      mem_we_n_from_the_ddr2_deva => mem_we_n_from_the_ddr2_deva,
      mem_we_n_from_the_ddr2_devb => mem_we_n_from_the_ddr2_devb,
      reset_phy_clk_n_from_the_ddr2_deva => reset_phy_clk_n_from_the_ddr2_deva,
      reset_phy_clk_n_from_the_ddr2_devb => reset_phy_clk_n_from_the_ddr2_devb,
      txd_from_the_laser_uart => txd_from_the_laser_uart,
      ENET_INT_to_the_dm9000a => ENET_INT_to_the_dm9000a,
      clk125 => clk125,
      clk50 => clk50,
      ex_dout_to_the_BL => ex_dout_to_the_BL,
      ex_dout_to_the_BR => ex_dout_to_the_BR,
      ex_dout_to_the_TL => ex_dout_to_the_TL,
      ex_dout_to_the_TR => ex_dout_to_the_TR,
      ex_dout_to_the_control => ex_dout_to_the_control,
      global_reset_n_to_the_ddr2_deva => global_reset_n_to_the_ddr2_deva,
      global_reset_n_to_the_ddr2_devb => global_reset_n_to_the_ddr2_devb,
      iOSC_50_to_the_dm9000a => iOSC_50_to_the_dm9000a,
      in_port_to_the_frame_received => in_port_to_the_frame_received,
      oct_ctl_rs_value_to_the_ddr2_deva => oct_ctl_rs_value_to_the_ddr2_deva,
      oct_ctl_rs_value_to_the_ddr2_devb => oct_ctl_rs_value_to_the_ddr2_devb,
      oct_ctl_rt_value_to_the_ddr2_deva => oct_ctl_rt_value_to_the_ddr2_deva,
      oct_ctl_rt_value_to_the_ddr2_devb => oct_ctl_rt_value_to_the_ddr2_devb,
      reset_n => reset_n,
      rxd_to_the_laser_uart => rxd_to_the_laser_uart
    );


  process
  begin
    clk125 <= '0';
    loop
       wait for 4 ns;
       clk125 <= not clk125;
    end loop;
  end process;
  process
  begin
    clk50 <= '0';
    loop
       wait for 10 ns;
       clk50 <= not clk50;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 80 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
