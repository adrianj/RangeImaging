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
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal BL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal BL_avalon_slave_read_n : OUT STD_LOGIC;
                 signal BL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal BL_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal BL_avalon_slave_write_n : OUT STD_LOGIC;
                 signal BL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_BL_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_BL_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_BL_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_BL_avalon_slave : OUT STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC
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
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_BL_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_BL_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_BL_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_BL_avalon_slave :  STD_LOGIC;
                signal p1_ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_BL_avalon_slave :  STD_LOGIC;
                signal shifted_address_to_BL_avalon_slave_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  BL_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_BL_avalon_slave);
  --assign BL_avalon_slave_readdata_from_sa = BL_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  BL_avalon_slave_readdata_from_sa <= BL_avalon_slave_readdata;
  internal_ranger_cpu_data_master_requests_BL_avalon_slave <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("011000000000000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --registered rdv signal_name registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave assignment, which is an e_assign
  registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave <= ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in;
  --BL_avalon_slave_arb_share_counter set values, which is an e_mux
  BL_avalon_slave_arb_share_set_values <= std_logic'('1');
  --BL_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  BL_avalon_slave_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_BL_avalon_slave;
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

  --ranger_cpu/data_master BL/avalon_slave arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= BL_avalon_slave_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --BL_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  BL_avalon_slave_slavearbiterlockenable2 <= BL_avalon_slave_arb_share_counter_next_value;
  --ranger_cpu/data_master BL/avalon_slave arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= BL_avalon_slave_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --BL_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  BL_avalon_slave_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_BL_avalon_slave <= internal_ranger_cpu_data_master_requests_BL_avalon_slave AND NOT ((((ranger_cpu_data_master_read AND (ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))));
  --ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in <= ((internal_ranger_cpu_data_master_granted_BL_avalon_slave AND ranger_cpu_data_master_read) AND NOT BL_avalon_slave_waits_for_read) AND NOT (ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register);
  --shift register p1 ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register) & A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register_in)));
  --ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register <= p1_ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid ranger_cpu_data_master_read_data_valid_BL_avalon_slave, which is an e_mux
  ranger_cpu_data_master_read_data_valid_BL_avalon_slave <= ranger_cpu_data_master_read_data_valid_BL_avalon_slave_shift_register;
  --BL_avalon_slave_writedata mux, which is an e_mux
  BL_avalon_slave_writedata <= ranger_cpu_data_master_writedata;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_BL_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_BL_avalon_slave;
  --ranger_cpu/data_master saved-grant BL/avalon_slave, which is an e_assign
  ranger_cpu_data_master_saved_grant_BL_avalon_slave <= internal_ranger_cpu_data_master_requests_BL_avalon_slave;
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
  BL_avalon_slave_read_n <= NOT ((internal_ranger_cpu_data_master_granted_BL_avalon_slave AND ranger_cpu_data_master_read));
  --~BL_avalon_slave_write_n assignment, which is an e_mux
  BL_avalon_slave_write_n <= NOT ((internal_ranger_cpu_data_master_granted_BL_avalon_slave AND ranger_cpu_data_master_write));
  shifted_address_to_BL_avalon_slave_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --BL_avalon_slave_address mux, which is an e_mux
  BL_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_BL_avalon_slave_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
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
  BL_avalon_slave_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_BL_avalon_slave AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= BL_avalon_slave_in_a_read_cycle;
  --BL_avalon_slave_waits_for_write in a cycle, which is an e_mux
  BL_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BL_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --BL_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  BL_avalon_slave_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_BL_avalon_slave AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= BL_avalon_slave_in_a_write_cycle;
  wait_for_BL_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_BL_avalon_slave <= internal_ranger_cpu_data_master_granted_BL_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_BL_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_BL_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_BL_avalon_slave <= internal_ranger_cpu_data_master_requests_BL_avalon_slave;
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
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal BR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal BR_avalon_slave_read_n : OUT STD_LOGIC;
                 signal BR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal BR_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal BR_avalon_slave_write_n : OUT STD_LOGIC;
                 signal BR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_BR_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_BR_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_BR_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_BR_avalon_slave : OUT STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC
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
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_BR_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_BR_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_BR_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_BR_avalon_slave :  STD_LOGIC;
                signal p1_ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_BR_avalon_slave :  STD_LOGIC;
                signal shifted_address_to_BR_avalon_slave_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  BR_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_BR_avalon_slave);
  --assign BR_avalon_slave_readdata_from_sa = BR_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  BR_avalon_slave_readdata_from_sa <= BR_avalon_slave_readdata;
  internal_ranger_cpu_data_master_requests_BR_avalon_slave <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("100000000000000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --registered rdv signal_name registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave assignment, which is an e_assign
  registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave <= ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in;
  --BR_avalon_slave_arb_share_counter set values, which is an e_mux
  BR_avalon_slave_arb_share_set_values <= std_logic'('1');
  --BR_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  BR_avalon_slave_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_BR_avalon_slave;
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

  --ranger_cpu/data_master BR/avalon_slave arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= BR_avalon_slave_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --BR_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  BR_avalon_slave_slavearbiterlockenable2 <= BR_avalon_slave_arb_share_counter_next_value;
  --ranger_cpu/data_master BR/avalon_slave arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= BR_avalon_slave_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --BR_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  BR_avalon_slave_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_BR_avalon_slave <= internal_ranger_cpu_data_master_requests_BR_avalon_slave AND NOT ((((ranger_cpu_data_master_read AND (ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))));
  --ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in <= ((internal_ranger_cpu_data_master_granted_BR_avalon_slave AND ranger_cpu_data_master_read) AND NOT BR_avalon_slave_waits_for_read) AND NOT (ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register);
  --shift register p1 ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register) & A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register_in)));
  --ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register <= p1_ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid ranger_cpu_data_master_read_data_valid_BR_avalon_slave, which is an e_mux
  ranger_cpu_data_master_read_data_valid_BR_avalon_slave <= ranger_cpu_data_master_read_data_valid_BR_avalon_slave_shift_register;
  --BR_avalon_slave_writedata mux, which is an e_mux
  BR_avalon_slave_writedata <= ranger_cpu_data_master_writedata;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_BR_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_BR_avalon_slave;
  --ranger_cpu/data_master saved-grant BR/avalon_slave, which is an e_assign
  ranger_cpu_data_master_saved_grant_BR_avalon_slave <= internal_ranger_cpu_data_master_requests_BR_avalon_slave;
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
  BR_avalon_slave_read_n <= NOT ((internal_ranger_cpu_data_master_granted_BR_avalon_slave AND ranger_cpu_data_master_read));
  --~BR_avalon_slave_write_n assignment, which is an e_mux
  BR_avalon_slave_write_n <= NOT ((internal_ranger_cpu_data_master_granted_BR_avalon_slave AND ranger_cpu_data_master_write));
  shifted_address_to_BR_avalon_slave_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --BR_avalon_slave_address mux, which is an e_mux
  BR_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_BR_avalon_slave_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
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
  BR_avalon_slave_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_BR_avalon_slave AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= BR_avalon_slave_in_a_read_cycle;
  --BR_avalon_slave_waits_for_write in a cycle, which is an e_mux
  BR_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(BR_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --BR_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  BR_avalon_slave_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_BR_avalon_slave AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= BR_avalon_slave_in_a_write_cycle;
  wait_for_BR_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_BR_avalon_slave <= internal_ranger_cpu_data_master_granted_BR_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_BR_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_BR_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_BR_avalon_slave <= internal_ranger_cpu_data_master_requests_BR_avalon_slave;
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
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal TL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal TL_avalon_slave_read_n : OUT STD_LOGIC;
                 signal TL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TL_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal TL_avalon_slave_write_n : OUT STD_LOGIC;
                 signal TL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_TL_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_TL_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_TL_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_TL_avalon_slave : OUT STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC
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
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_TL_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_TL_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_TL_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_TL_avalon_slave :  STD_LOGIC;
                signal p1_ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_TL_avalon_slave :  STD_LOGIC;
                signal shifted_address_to_TL_avalon_slave_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  TL_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_TL_avalon_slave);
  --assign TL_avalon_slave_readdata_from_sa = TL_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  TL_avalon_slave_readdata_from_sa <= TL_avalon_slave_readdata;
  internal_ranger_cpu_data_master_requests_TL_avalon_slave <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("001000000000000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --registered rdv signal_name registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave assignment, which is an e_assign
  registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave <= ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in;
  --TL_avalon_slave_arb_share_counter set values, which is an e_mux
  TL_avalon_slave_arb_share_set_values <= std_logic'('1');
  --TL_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  TL_avalon_slave_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_TL_avalon_slave;
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

  --ranger_cpu/data_master TL/avalon_slave arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= TL_avalon_slave_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --TL_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  TL_avalon_slave_slavearbiterlockenable2 <= TL_avalon_slave_arb_share_counter_next_value;
  --ranger_cpu/data_master TL/avalon_slave arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= TL_avalon_slave_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --TL_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  TL_avalon_slave_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_TL_avalon_slave <= internal_ranger_cpu_data_master_requests_TL_avalon_slave AND NOT ((((ranger_cpu_data_master_read AND (ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))));
  --ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in <= ((internal_ranger_cpu_data_master_granted_TL_avalon_slave AND ranger_cpu_data_master_read) AND NOT TL_avalon_slave_waits_for_read) AND NOT (ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register);
  --shift register p1 ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register) & A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register_in)));
  --ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register <= p1_ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid ranger_cpu_data_master_read_data_valid_TL_avalon_slave, which is an e_mux
  ranger_cpu_data_master_read_data_valid_TL_avalon_slave <= ranger_cpu_data_master_read_data_valid_TL_avalon_slave_shift_register;
  --TL_avalon_slave_writedata mux, which is an e_mux
  TL_avalon_slave_writedata <= ranger_cpu_data_master_writedata;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_TL_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_TL_avalon_slave;
  --ranger_cpu/data_master saved-grant TL/avalon_slave, which is an e_assign
  ranger_cpu_data_master_saved_grant_TL_avalon_slave <= internal_ranger_cpu_data_master_requests_TL_avalon_slave;
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
  TL_avalon_slave_read_n <= NOT ((internal_ranger_cpu_data_master_granted_TL_avalon_slave AND ranger_cpu_data_master_read));
  --~TL_avalon_slave_write_n assignment, which is an e_mux
  TL_avalon_slave_write_n <= NOT ((internal_ranger_cpu_data_master_granted_TL_avalon_slave AND ranger_cpu_data_master_write));
  shifted_address_to_TL_avalon_slave_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --TL_avalon_slave_address mux, which is an e_mux
  TL_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_TL_avalon_slave_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
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
  TL_avalon_slave_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_TL_avalon_slave AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= TL_avalon_slave_in_a_read_cycle;
  --TL_avalon_slave_waits_for_write in a cycle, which is an e_mux
  TL_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TL_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TL_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  TL_avalon_slave_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_TL_avalon_slave AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= TL_avalon_slave_in_a_write_cycle;
  wait_for_TL_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_TL_avalon_slave <= internal_ranger_cpu_data_master_granted_TL_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_TL_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_TL_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_TL_avalon_slave <= internal_ranger_cpu_data_master_requests_TL_avalon_slave;
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
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal TR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal TR_avalon_slave_read_n : OUT STD_LOGIC;
                 signal TR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TR_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal TR_avalon_slave_write_n : OUT STD_LOGIC;
                 signal TR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_TR_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_TR_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_TR_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_TR_avalon_slave : OUT STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC
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
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_TR_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_TR_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_TR_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_TR_avalon_slave :  STD_LOGIC;
                signal p1_ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_TR_avalon_slave :  STD_LOGIC;
                signal shifted_address_to_TR_avalon_slave_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  TR_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_TR_avalon_slave);
  --assign TR_avalon_slave_readdata_from_sa = TR_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  TR_avalon_slave_readdata_from_sa <= TR_avalon_slave_readdata;
  internal_ranger_cpu_data_master_requests_TR_avalon_slave <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("010000000000000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --registered rdv signal_name registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave assignment, which is an e_assign
  registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave <= ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in;
  --TR_avalon_slave_arb_share_counter set values, which is an e_mux
  TR_avalon_slave_arb_share_set_values <= std_logic'('1');
  --TR_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  TR_avalon_slave_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_TR_avalon_slave;
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

  --ranger_cpu/data_master TR/avalon_slave arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= TR_avalon_slave_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --TR_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  TR_avalon_slave_slavearbiterlockenable2 <= TR_avalon_slave_arb_share_counter_next_value;
  --ranger_cpu/data_master TR/avalon_slave arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= TR_avalon_slave_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --TR_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  TR_avalon_slave_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_TR_avalon_slave <= internal_ranger_cpu_data_master_requests_TR_avalon_slave AND NOT ((((ranger_cpu_data_master_read AND (ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))));
  --ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in <= ((internal_ranger_cpu_data_master_granted_TR_avalon_slave AND ranger_cpu_data_master_read) AND NOT TR_avalon_slave_waits_for_read) AND NOT (ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register);
  --shift register p1 ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register) & A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register_in)));
  --ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register <= p1_ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid ranger_cpu_data_master_read_data_valid_TR_avalon_slave, which is an e_mux
  ranger_cpu_data_master_read_data_valid_TR_avalon_slave <= ranger_cpu_data_master_read_data_valid_TR_avalon_slave_shift_register;
  --TR_avalon_slave_writedata mux, which is an e_mux
  TR_avalon_slave_writedata <= ranger_cpu_data_master_writedata;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_TR_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_TR_avalon_slave;
  --ranger_cpu/data_master saved-grant TR/avalon_slave, which is an e_assign
  ranger_cpu_data_master_saved_grant_TR_avalon_slave <= internal_ranger_cpu_data_master_requests_TR_avalon_slave;
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
  TR_avalon_slave_read_n <= NOT ((internal_ranger_cpu_data_master_granted_TR_avalon_slave AND ranger_cpu_data_master_read));
  --~TR_avalon_slave_write_n assignment, which is an e_mux
  TR_avalon_slave_write_n <= NOT ((internal_ranger_cpu_data_master_granted_TR_avalon_slave AND ranger_cpu_data_master_write));
  shifted_address_to_TR_avalon_slave_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --TR_avalon_slave_address mux, which is an e_mux
  TR_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_TR_avalon_slave_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
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
  TR_avalon_slave_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_TR_avalon_slave AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= TR_avalon_slave_in_a_read_cycle;
  --TR_avalon_slave_waits_for_write in a cycle, which is an e_mux
  TR_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TR_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TR_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  TR_avalon_slave_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_TR_avalon_slave AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= TR_avalon_slave_in_a_write_cycle;
  wait_for_TR_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_TR_avalon_slave <= internal_ranger_cpu_data_master_granted_TR_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_TR_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_TR_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_TR_avalon_slave <= internal_ranger_cpu_data_master_requests_TR_avalon_slave;
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
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal control_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal control_avalon_slave_read_n : OUT STD_LOGIC;
                 signal control_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal control_avalon_slave_reset_n : OUT STD_LOGIC;
                 signal control_avalon_slave_write_n : OUT STD_LOGIC;
                 signal control_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_control_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_control_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_control_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_control_avalon_slave : OUT STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC
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
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_control_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_control_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_control_avalon_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_control_avalon_slave :  STD_LOGIC;
                signal p1_ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_control_avalon_slave :  STD_LOGIC;
                signal shifted_address_to_control_avalon_slave_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  control_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_control_avalon_slave);
  --assign control_avalon_slave_readdata_from_sa = control_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  control_avalon_slave_readdata_from_sa <= control_avalon_slave_readdata;
  internal_ranger_cpu_data_master_requests_control_avalon_slave <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 18) & std_logic_vector'("000000000000000000")) = std_logic_vector'("000000000000000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --registered rdv signal_name registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave assignment, which is an e_assign
  registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave <= ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in;
  --control_avalon_slave_arb_share_counter set values, which is an e_mux
  control_avalon_slave_arb_share_set_values <= std_logic'('1');
  --control_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  control_avalon_slave_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_control_avalon_slave;
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

  --ranger_cpu/data_master control/avalon_slave arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= control_avalon_slave_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --control_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  control_avalon_slave_slavearbiterlockenable2 <= control_avalon_slave_arb_share_counter_next_value;
  --ranger_cpu/data_master control/avalon_slave arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= control_avalon_slave_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --control_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  control_avalon_slave_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_control_avalon_slave <= internal_ranger_cpu_data_master_requests_control_avalon_slave AND NOT ((((ranger_cpu_data_master_read AND (ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))));
  --ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in <= ((internal_ranger_cpu_data_master_granted_control_avalon_slave AND ranger_cpu_data_master_read) AND NOT control_avalon_slave_waits_for_read) AND NOT (ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register);
  --shift register p1 ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register) & A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register_in)));
  --ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register <= p1_ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid ranger_cpu_data_master_read_data_valid_control_avalon_slave, which is an e_mux
  ranger_cpu_data_master_read_data_valid_control_avalon_slave <= ranger_cpu_data_master_read_data_valid_control_avalon_slave_shift_register;
  --control_avalon_slave_writedata mux, which is an e_mux
  control_avalon_slave_writedata <= ranger_cpu_data_master_writedata;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_control_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_control_avalon_slave;
  --ranger_cpu/data_master saved-grant control/avalon_slave, which is an e_assign
  ranger_cpu_data_master_saved_grant_control_avalon_slave <= internal_ranger_cpu_data_master_requests_control_avalon_slave;
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
  control_avalon_slave_read_n <= NOT ((internal_ranger_cpu_data_master_granted_control_avalon_slave AND ranger_cpu_data_master_read));
  --~control_avalon_slave_write_n assignment, which is an e_mux
  control_avalon_slave_write_n <= NOT ((internal_ranger_cpu_data_master_granted_control_avalon_slave AND ranger_cpu_data_master_write));
  shifted_address_to_control_avalon_slave_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --control_avalon_slave_address mux, which is an e_mux
  control_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_control_avalon_slave_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 16);
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
  control_avalon_slave_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_control_avalon_slave AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= control_avalon_slave_in_a_read_cycle;
  --control_avalon_slave_waits_for_write in a cycle, which is an e_mux
  control_avalon_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(control_avalon_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --control_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  control_avalon_slave_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_control_avalon_slave AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= control_avalon_slave_in_a_write_cycle;
  wait_for_control_avalon_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_control_avalon_slave <= internal_ranger_cpu_data_master_granted_control_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_control_avalon_slave <= internal_ranger_cpu_data_master_qualified_request_control_avalon_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_control_avalon_slave <= internal_ranger_cpu_data_master_requests_control_avalon_slave;
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

entity cpu_clock_0_in_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_clock_0_in_endofpacket : IN STD_LOGIC;
                 signal cpu_clock_0_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_clock_0_in_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_clock_0_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal cpu_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal cpu_clock_0_in_read : OUT STD_LOGIC;
                 signal cpu_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_clock_0_in_reset_n : OUT STD_LOGIC;
                 signal cpu_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal cpu_clock_0_in_write : OUT STD_LOGIC;
                 signal cpu_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal d1_cpu_clock_0_in_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_cpu_clock_0_in : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_cpu_clock_0_in : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_cpu_clock_0_in : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_cpu_clock_0_in : OUT STD_LOGIC
              );
end entity cpu_clock_0_in_arbitrator;


architecture europa of cpu_clock_0_in_arbitrator is
                signal cpu_clock_0_in_allgrants :  STD_LOGIC;
                signal cpu_clock_0_in_allow_new_arb_cycle :  STD_LOGIC;
                signal cpu_clock_0_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal cpu_clock_0_in_any_continuerequest :  STD_LOGIC;
                signal cpu_clock_0_in_arb_counter_enable :  STD_LOGIC;
                signal cpu_clock_0_in_arb_share_counter :  STD_LOGIC;
                signal cpu_clock_0_in_arb_share_counter_next_value :  STD_LOGIC;
                signal cpu_clock_0_in_arb_share_set_values :  STD_LOGIC;
                signal cpu_clock_0_in_beginbursttransfer_internal :  STD_LOGIC;
                signal cpu_clock_0_in_begins_xfer :  STD_LOGIC;
                signal cpu_clock_0_in_end_xfer :  STD_LOGIC;
                signal cpu_clock_0_in_firsttransfer :  STD_LOGIC;
                signal cpu_clock_0_in_grant_vector :  STD_LOGIC;
                signal cpu_clock_0_in_in_a_read_cycle :  STD_LOGIC;
                signal cpu_clock_0_in_in_a_write_cycle :  STD_LOGIC;
                signal cpu_clock_0_in_master_qreq_vector :  STD_LOGIC;
                signal cpu_clock_0_in_non_bursting_master_requests :  STD_LOGIC;
                signal cpu_clock_0_in_reg_firsttransfer :  STD_LOGIC;
                signal cpu_clock_0_in_slavearbiterlockenable :  STD_LOGIC;
                signal cpu_clock_0_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal cpu_clock_0_in_unreg_firsttransfer :  STD_LOGIC;
                signal cpu_clock_0_in_waits_for_read :  STD_LOGIC;
                signal cpu_clock_0_in_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_cpu_clock_0_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_cpu_clock_0_in :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_cpu_clock_0_in :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_cpu_clock_0_in :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_cpu_clock_0_in :  STD_LOGIC;
                signal shifted_address_to_cpu_clock_0_in_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal wait_for_cpu_clock_0_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT cpu_clock_0_in_end_xfer;
      end if;
    end if;

  end process;

  cpu_clock_0_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_cpu_clock_0_in);
  --assign cpu_clock_0_in_readdata_from_sa = cpu_clock_0_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_clock_0_in_readdata_from_sa <= cpu_clock_0_in_readdata;
  internal_ranger_cpu_data_master_requests_cpu_clock_0_in <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("110000001000000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --assign cpu_clock_0_in_waitrequest_from_sa = cpu_clock_0_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_cpu_clock_0_in_waitrequest_from_sa <= cpu_clock_0_in_waitrequest;
  --cpu_clock_0_in_arb_share_counter set values, which is an e_mux
  cpu_clock_0_in_arb_share_set_values <= std_logic'('1');
  --cpu_clock_0_in_non_bursting_master_requests mux, which is an e_mux
  cpu_clock_0_in_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_cpu_clock_0_in;
  --cpu_clock_0_in_any_bursting_master_saved_grant mux, which is an e_mux
  cpu_clock_0_in_any_bursting_master_saved_grant <= std_logic'('0');
  --cpu_clock_0_in_arb_share_counter_next_value assignment, which is an e_assign
  cpu_clock_0_in_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_clock_0_in_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_clock_0_in_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(cpu_clock_0_in_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_clock_0_in_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --cpu_clock_0_in_allgrants all slave grants, which is an e_mux
  cpu_clock_0_in_allgrants <= cpu_clock_0_in_grant_vector;
  --cpu_clock_0_in_end_xfer assignment, which is an e_assign
  cpu_clock_0_in_end_xfer <= NOT ((cpu_clock_0_in_waits_for_read OR cpu_clock_0_in_waits_for_write));
  --end_xfer_arb_share_counter_term_cpu_clock_0_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_cpu_clock_0_in <= cpu_clock_0_in_end_xfer AND (((NOT cpu_clock_0_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --cpu_clock_0_in_arb_share_counter arbitration counter enable, which is an e_assign
  cpu_clock_0_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_cpu_clock_0_in AND cpu_clock_0_in_allgrants)) OR ((end_xfer_arb_share_counter_term_cpu_clock_0_in AND NOT cpu_clock_0_in_non_bursting_master_requests));
  --cpu_clock_0_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_clock_0_in_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_clock_0_in_arb_counter_enable) = '1' then 
        cpu_clock_0_in_arb_share_counter <= cpu_clock_0_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_clock_0_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_clock_0_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((cpu_clock_0_in_master_qreq_vector AND end_xfer_arb_share_counter_term_cpu_clock_0_in)) OR ((end_xfer_arb_share_counter_term_cpu_clock_0_in AND NOT cpu_clock_0_in_non_bursting_master_requests)))) = '1' then 
        cpu_clock_0_in_slavearbiterlockenable <= cpu_clock_0_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu/data_master cpu_clock_0/in arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= cpu_clock_0_in_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --cpu_clock_0_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  cpu_clock_0_in_slavearbiterlockenable2 <= cpu_clock_0_in_arb_share_counter_next_value;
  --ranger_cpu/data_master cpu_clock_0/in arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= cpu_clock_0_in_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --cpu_clock_0_in_any_continuerequest at least one master continues requesting, which is an e_assign
  cpu_clock_0_in_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_cpu_clock_0_in <= internal_ranger_cpu_data_master_requests_cpu_clock_0_in AND NOT ((((ranger_cpu_data_master_read AND (NOT ranger_cpu_data_master_waitrequest))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))));
  --cpu_clock_0_in_writedata mux, which is an e_mux
  cpu_clock_0_in_writedata <= ranger_cpu_data_master_writedata (15 DOWNTO 0);
  --assign cpu_clock_0_in_endofpacket_from_sa = cpu_clock_0_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_clock_0_in_endofpacket_from_sa <= cpu_clock_0_in_endofpacket;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_cpu_clock_0_in <= internal_ranger_cpu_data_master_qualified_request_cpu_clock_0_in;
  --ranger_cpu/data_master saved-grant cpu_clock_0/in, which is an e_assign
  ranger_cpu_data_master_saved_grant_cpu_clock_0_in <= internal_ranger_cpu_data_master_requests_cpu_clock_0_in;
  --allow new arb cycle for cpu_clock_0/in, which is an e_assign
  cpu_clock_0_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  cpu_clock_0_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  cpu_clock_0_in_master_qreq_vector <= std_logic'('1');
  --cpu_clock_0_in_reset_n assignment, which is an e_assign
  cpu_clock_0_in_reset_n <= reset_n;
  --cpu_clock_0_in_firsttransfer first transaction, which is an e_assign
  cpu_clock_0_in_firsttransfer <= A_WE_StdLogic((std_logic'(cpu_clock_0_in_begins_xfer) = '1'), cpu_clock_0_in_unreg_firsttransfer, cpu_clock_0_in_reg_firsttransfer);
  --cpu_clock_0_in_unreg_firsttransfer first transaction, which is an e_assign
  cpu_clock_0_in_unreg_firsttransfer <= NOT ((cpu_clock_0_in_slavearbiterlockenable AND cpu_clock_0_in_any_continuerequest));
  --cpu_clock_0_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_clock_0_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_clock_0_in_begins_xfer) = '1' then 
        cpu_clock_0_in_reg_firsttransfer <= cpu_clock_0_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --cpu_clock_0_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  cpu_clock_0_in_beginbursttransfer_internal <= cpu_clock_0_in_begins_xfer;
  --cpu_clock_0_in_read assignment, which is an e_mux
  cpu_clock_0_in_read <= internal_ranger_cpu_data_master_granted_cpu_clock_0_in AND ranger_cpu_data_master_read;
  --cpu_clock_0_in_write assignment, which is an e_mux
  cpu_clock_0_in_write <= internal_ranger_cpu_data_master_granted_cpu_clock_0_in AND ranger_cpu_data_master_write;
  shifted_address_to_cpu_clock_0_in_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --cpu_clock_0_in_address mux, which is an e_mux
  cpu_clock_0_in_address <= A_EXT (A_SRL(shifted_address_to_cpu_clock_0_in_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 4);
  --slaveid cpu_clock_0_in_nativeaddress nativeaddress mux, which is an e_mux
  cpu_clock_0_in_nativeaddress <= A_EXT (A_SRL(ranger_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_cpu_clock_0_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_cpu_clock_0_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_cpu_clock_0_in_end_xfer <= cpu_clock_0_in_end_xfer;
      end if;
    end if;

  end process;

  --cpu_clock_0_in_waits_for_read in a cycle, which is an e_mux
  cpu_clock_0_in_waits_for_read <= cpu_clock_0_in_in_a_read_cycle AND internal_cpu_clock_0_in_waitrequest_from_sa;
  --cpu_clock_0_in_in_a_read_cycle assignment, which is an e_assign
  cpu_clock_0_in_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_cpu_clock_0_in AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= cpu_clock_0_in_in_a_read_cycle;
  --cpu_clock_0_in_waits_for_write in a cycle, which is an e_mux
  cpu_clock_0_in_waits_for_write <= cpu_clock_0_in_in_a_write_cycle AND internal_cpu_clock_0_in_waitrequest_from_sa;
  --cpu_clock_0_in_in_a_write_cycle assignment, which is an e_assign
  cpu_clock_0_in_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_cpu_clock_0_in AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= cpu_clock_0_in_in_a_write_cycle;
  wait_for_cpu_clock_0_in_counter <= std_logic'('0');
  --cpu_clock_0_in_byteenable byte enable port mux, which is an e_mux
  cpu_clock_0_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_data_master_granted_cpu_clock_0_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ranger_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 2);
  --vhdl renameroo for output signals
  cpu_clock_0_in_waitrequest_from_sa <= internal_cpu_clock_0_in_waitrequest_from_sa;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_cpu_clock_0_in <= internal_ranger_cpu_data_master_granted_cpu_clock_0_in;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_cpu_clock_0_in <= internal_ranger_cpu_data_master_qualified_request_cpu_clock_0_in;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_cpu_clock_0_in <= internal_ranger_cpu_data_master_requests_cpu_clock_0_in;
--synthesis translate_off
    --cpu_clock_0/in enable non-zero assertions, which is an e_register
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

entity cpu_clock_0_out_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_clock_0_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_clock_0_out_granted_pll_s1 : IN STD_LOGIC;
                 signal cpu_clock_0_out_qualified_request_pll_s1 : IN STD_LOGIC;
                 signal cpu_clock_0_out_read : IN STD_LOGIC;
                 signal cpu_clock_0_out_read_data_valid_pll_s1 : IN STD_LOGIC;
                 signal cpu_clock_0_out_requests_pll_s1 : IN STD_LOGIC;
                 signal cpu_clock_0_out_write : IN STD_LOGIC;
                 signal cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal d1_pll_s1_end_xfer : IN STD_LOGIC;
                 signal pll_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_clock_0_out_reset_n : OUT STD_LOGIC;
                 signal cpu_clock_0_out_waitrequest : OUT STD_LOGIC
              );
end entity cpu_clock_0_out_arbitrator;


architecture europa of cpu_clock_0_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal cpu_clock_0_out_address_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_clock_0_out_read_last_time :  STD_LOGIC;
                signal cpu_clock_0_out_run :  STD_LOGIC;
                signal cpu_clock_0_out_write_last_time :  STD_LOGIC;
                signal cpu_clock_0_out_writedata_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_cpu_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_cpu_clock_0_out_waitrequest :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_clock_0_out_qualified_request_pll_s1 OR NOT cpu_clock_0_out_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_pll_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_clock_0_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_clock_0_out_qualified_request_pll_s1 OR NOT cpu_clock_0_out_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_clock_0_out_write)))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_clock_0_out_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_clock_0_out_address_to_slave <= cpu_clock_0_out_address;
  --cpu_clock_0/out readdata mux, which is an e_mux
  cpu_clock_0_out_readdata <= pll_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_cpu_clock_0_out_waitrequest <= NOT cpu_clock_0_out_run;
  --cpu_clock_0_out_reset_n assignment, which is an e_assign
  cpu_clock_0_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  cpu_clock_0_out_address_to_slave <= internal_cpu_clock_0_out_address_to_slave;
  --vhdl renameroo for output signals
  cpu_clock_0_out_waitrequest <= internal_cpu_clock_0_out_waitrequest;
--synthesis translate_off
    --cpu_clock_0_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_clock_0_out_address_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_clock_0_out_address_last_time <= cpu_clock_0_out_address;
        end if;
      end if;

    end process;

    --cpu_clock_0/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          active_and_waiting_last_time <= internal_cpu_clock_0_out_waitrequest AND ((cpu_clock_0_out_read OR cpu_clock_0_out_write));
        end if;
      end if;

    end process;

    --cpu_clock_0_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_clock_0_out_address /= cpu_clock_0_out_address_last_time))))) = '1' then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("cpu_clock_0_out_address did not heed wait!!!"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_clock_0_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_clock_0_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_clock_0_out_read_last_time <= cpu_clock_0_out_read;
        end if;
      end if;

    end process;

    --cpu_clock_0_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_clock_0_out_read) /= std_logic'(cpu_clock_0_out_read_last_time)))))) = '1' then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("cpu_clock_0_out_read did not heed wait!!!"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_clock_0_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_clock_0_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_clock_0_out_write_last_time <= cpu_clock_0_out_write;
        end if;
      end if;

    end process;

    --cpu_clock_0_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_clock_0_out_write) /= std_logic'(cpu_clock_0_out_write_last_time)))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("cpu_clock_0_out_write did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_clock_0_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_clock_0_out_writedata_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_clock_0_out_writedata_last_time <= cpu_clock_0_out_writedata;
        end if;
      end if;

    end process;

    --cpu_clock_0_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((cpu_clock_0_out_writedata /= cpu_clock_0_out_writedata_last_time)))) AND cpu_clock_0_out_write)) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("cpu_clock_0_out_writedata did not heed wait!!!"));
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

entity frame_received_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal frame_received_s1_irq : IN STD_LOGIC;
                 signal frame_received_s1_readdata : IN STD_LOGIC;
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_frame_received_s1_end_xfer : OUT STD_LOGIC;
                 signal frame_received_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal frame_received_s1_chipselect : OUT STD_LOGIC;
                 signal frame_received_s1_irq_from_sa : OUT STD_LOGIC;
                 signal frame_received_s1_readdata_from_sa : OUT STD_LOGIC;
                 signal frame_received_s1_reset_n : OUT STD_LOGIC;
                 signal frame_received_s1_write_n : OUT STD_LOGIC;
                 signal frame_received_s1_writedata : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_frame_received_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_frame_received_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_frame_received_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_frame_received_s1 : OUT STD_LOGIC
              );
end entity frame_received_s1_arbitrator;


architecture europa of frame_received_s1_arbitrator is
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
                signal internal_ranger_cpu_data_master_granted_frame_received_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_frame_received_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_frame_received_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_frame_received_s1 :  STD_LOGIC;
                signal shifted_address_to_frame_received_s1_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  frame_received_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_frame_received_s1);
  --assign frame_received_s1_readdata_from_sa = frame_received_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  frame_received_s1_readdata_from_sa <= frame_received_s1_readdata;
  internal_ranger_cpu_data_master_requests_frame_received_s1 <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("110000001000001000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --frame_received_s1_arb_share_counter set values, which is an e_mux
  frame_received_s1_arb_share_set_values <= std_logic'('1');
  --frame_received_s1_non_bursting_master_requests mux, which is an e_mux
  frame_received_s1_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_frame_received_s1;
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

  --ranger_cpu/data_master frame_received/s1 arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= frame_received_s1_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --frame_received_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  frame_received_s1_slavearbiterlockenable2 <= frame_received_s1_arb_share_counter_next_value;
  --ranger_cpu/data_master frame_received/s1 arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= frame_received_s1_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --frame_received_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  frame_received_s1_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_frame_received_s1 <= internal_ranger_cpu_data_master_requests_frame_received_s1 AND NOT (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write));
  --frame_received_s1_writedata mux, which is an e_mux
  frame_received_s1_writedata <= ranger_cpu_data_master_writedata(0);
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_frame_received_s1 <= internal_ranger_cpu_data_master_qualified_request_frame_received_s1;
  --ranger_cpu/data_master saved-grant frame_received/s1, which is an e_assign
  ranger_cpu_data_master_saved_grant_frame_received_s1 <= internal_ranger_cpu_data_master_requests_frame_received_s1;
  --allow new arb cycle for frame_received/s1, which is an e_assign
  frame_received_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  frame_received_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  frame_received_s1_master_qreq_vector <= std_logic'('1');
  --frame_received_s1_reset_n assignment, which is an e_assign
  frame_received_s1_reset_n <= reset_n;
  frame_received_s1_chipselect <= internal_ranger_cpu_data_master_granted_frame_received_s1;
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
  frame_received_s1_write_n <= NOT ((internal_ranger_cpu_data_master_granted_frame_received_s1 AND ranger_cpu_data_master_write));
  shifted_address_to_frame_received_s1_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --frame_received_s1_address mux, which is an e_mux
  frame_received_s1_address <= A_EXT (A_SRL(shifted_address_to_frame_received_s1_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
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
  frame_received_s1_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_frame_received_s1 AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= frame_received_s1_in_a_read_cycle;
  --frame_received_s1_waits_for_write in a cycle, which is an e_mux
  frame_received_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(frame_received_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --frame_received_s1_in_a_write_cycle assignment, which is an e_assign
  frame_received_s1_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_frame_received_s1 AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= frame_received_s1_in_a_write_cycle;
  wait_for_frame_received_s1_counter <= std_logic'('0');
  --assign frame_received_s1_irq_from_sa = frame_received_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  frame_received_s1_irq_from_sa <= frame_received_s1_irq;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_frame_received_s1 <= internal_ranger_cpu_data_master_granted_frame_received_s1;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_frame_received_s1 <= internal_ranger_cpu_data_master_qualified_request_frame_received_s1;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_frame_received_s1 <= internal_ranger_cpu_data_master_requests_frame_received_s1;
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
                 signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
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
                 signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC
              );
end entity jtag_uart_avalon_jtag_slave_arbitrator;


architecture europa of jtag_uart_avalon_jtag_slave_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
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
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal shifted_address_to_jtag_uart_avalon_jtag_slave_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  jtag_uart_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave);
  --assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readdata_from_sa <= jtag_uart_avalon_jtag_slave_readdata;
  internal_ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("110000001000001010000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_avalon_jtag_slave_waitrequest;
  --jtag_uart_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_avalon_jtag_slave_arb_share_set_values <= std_logic'('1');
  --jtag_uart_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
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

  --ranger_cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
  --ranger_cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave AND NOT ((((ranger_cpu_data_master_read AND (NOT ranger_cpu_data_master_waitrequest))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))));
  --jtag_uart_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_writedata <= ranger_cpu_data_master_writedata;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --ranger_cpu/data_master saved-grant jtag_uart/avalon_jtag_slave, which is an e_assign
  ranger_cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave <= internal_ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart/avalon_jtag_slave, which is an e_assign
  jtag_uart_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_avalon_jtag_slave_chipselect <= internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
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
  jtag_uart_avalon_jtag_slave_read_n <= NOT ((internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND ranger_cpu_data_master_read));
  --~jtag_uart_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_avalon_jtag_slave_write_n <= NOT ((internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND ranger_cpu_data_master_write));
  shifted_address_to_jtag_uart_avalon_jtag_slave_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --jtag_uart_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_jtag_uart_avalon_jtag_slave_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
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
  jtag_uart_avalon_jtag_slave_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_avalon_jtag_slave_waits_for_write <= jtag_uart_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_irq_from_sa <= jtag_uart_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= internal_ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
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

library std;
use std.textio.all;

entity onchip_mem_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_onchip_mem_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_mem_s1_address : OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
                 signal onchip_mem_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_mem_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_mem_s1_clken : OUT STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_mem_s1_write : OUT STD_LOGIC;
                 signal onchip_mem_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_data_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC
              );
end entity onchip_mem_s1_arbitrator;


architecture europa of onchip_mem_s1_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_mem_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal last_cycle_ranger_cpu_data_master_granted_slave_onchip_mem_s1 :  STD_LOGIC;
                signal last_cycle_ranger_cpu_instruction_master_granted_slave_onchip_mem_s1 :  STD_LOGIC;
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
                signal p1_ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal p1_ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in :  STD_LOGIC;
                signal ranger_cpu_instruction_master_saved_grant_onchip_mem_s1 :  STD_LOGIC;
                signal shifted_address_to_onchip_mem_s1_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal shifted_address_to_onchip_mem_s1_from_ranger_cpu_instruction_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  onchip_mem_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ranger_cpu_data_master_qualified_request_onchip_mem_s1 OR internal_ranger_cpu_instruction_master_qualified_request_onchip_mem_s1));
  --assign onchip_mem_s1_readdata_from_sa = onchip_mem_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_mem_s1_readdata_from_sa <= onchip_mem_s1_readdata;
  internal_ranger_cpu_data_master_requests_onchip_mem_s1 <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 17) & std_logic_vector'("00000000000000000")) = std_logic_vector'("101100000000000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --registered rdv signal_name registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 assignment, which is an e_assign
  registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 <= ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in;
  --onchip_mem_s1_arb_share_counter set values, which is an e_mux
  onchip_mem_s1_arb_share_set_values <= std_logic'('1');
  --onchip_mem_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_mem_s1_non_bursting_master_requests <= ((internal_ranger_cpu_data_master_requests_onchip_mem_s1 OR internal_ranger_cpu_instruction_master_requests_onchip_mem_s1) OR internal_ranger_cpu_data_master_requests_onchip_mem_s1) OR internal_ranger_cpu_instruction_master_requests_onchip_mem_s1;
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

  --ranger_cpu/data_master onchip_mem/s1 arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= onchip_mem_s1_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --onchip_mem_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_mem_s1_slavearbiterlockenable2 <= onchip_mem_s1_arb_share_counter_next_value;
  --ranger_cpu/data_master onchip_mem/s1 arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= onchip_mem_s1_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --ranger_cpu/instruction_master onchip_mem/s1 arbiterlock, which is an e_assign
  ranger_cpu_instruction_master_arbiterlock <= onchip_mem_s1_slavearbiterlockenable AND ranger_cpu_instruction_master_continuerequest;
  --ranger_cpu/instruction_master onchip_mem/s1 arbiterlock2, which is an e_assign
  ranger_cpu_instruction_master_arbiterlock2 <= onchip_mem_s1_slavearbiterlockenable2 AND ranger_cpu_instruction_master_continuerequest;
  --ranger_cpu/instruction_master granted onchip_mem/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ranger_cpu_instruction_master_granted_slave_onchip_mem_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_ranger_cpu_instruction_master_granted_slave_onchip_mem_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_instruction_master_saved_grant_onchip_mem_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_arbitration_holdoff_internal OR NOT internal_ranger_cpu_instruction_master_requests_onchip_mem_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ranger_cpu_instruction_master_granted_slave_onchip_mem_s1))))));
      end if;
    end if;

  end process;

  --ranger_cpu_instruction_master_continuerequest continued request, which is an e_mux
  ranger_cpu_instruction_master_continuerequest <= last_cycle_ranger_cpu_instruction_master_granted_slave_onchip_mem_s1 AND internal_ranger_cpu_instruction_master_requests_onchip_mem_s1;
  --onchip_mem_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_mem_s1_any_continuerequest <= ranger_cpu_instruction_master_continuerequest OR ranger_cpu_data_master_continuerequest;
  internal_ranger_cpu_data_master_qualified_request_onchip_mem_s1 <= internal_ranger_cpu_data_master_requests_onchip_mem_s1 AND NOT (((((ranger_cpu_data_master_read AND (ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register))) OR (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write))) OR ranger_cpu_instruction_master_arbiterlock));
  --ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in <= ((internal_ranger_cpu_data_master_granted_onchip_mem_s1 AND ranger_cpu_data_master_read) AND NOT onchip_mem_s1_waits_for_read) AND NOT (ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register);
  --shift register p1 ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register) & A_ToStdLogicVector(ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in)));
  --ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= p1_ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid ranger_cpu_data_master_read_data_valid_onchip_mem_s1, which is an e_mux
  ranger_cpu_data_master_read_data_valid_onchip_mem_s1 <= ranger_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register;
  --onchip_mem_s1_writedata mux, which is an e_mux
  onchip_mem_s1_writedata <= ranger_cpu_data_master_writedata;
  --mux onchip_mem_s1_clken, which is an e_mux
  onchip_mem_s1_clken <= std_logic'('1');
  internal_ranger_cpu_instruction_master_requests_onchip_mem_s1 <= ((to_std_logic(((Std_Logic_Vector'(ranger_cpu_instruction_master_address_to_slave(20 DOWNTO 17) & std_logic_vector'("00000000000000000")) = std_logic_vector'("101100000000000000000")))) AND (ranger_cpu_instruction_master_read))) AND ranger_cpu_instruction_master_read;
  --ranger_cpu/data_master granted onchip_mem/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ranger_cpu_data_master_granted_slave_onchip_mem_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_ranger_cpu_data_master_granted_slave_onchip_mem_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_data_master_saved_grant_onchip_mem_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_arbitration_holdoff_internal OR NOT internal_ranger_cpu_data_master_requests_onchip_mem_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ranger_cpu_data_master_granted_slave_onchip_mem_s1))))));
      end if;
    end if;

  end process;

  --ranger_cpu_data_master_continuerequest continued request, which is an e_mux
  ranger_cpu_data_master_continuerequest <= last_cycle_ranger_cpu_data_master_granted_slave_onchip_mem_s1 AND internal_ranger_cpu_data_master_requests_onchip_mem_s1;
  internal_ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 <= internal_ranger_cpu_instruction_master_requests_onchip_mem_s1 AND NOT ((((ranger_cpu_instruction_master_read AND to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_instruction_master_latency_counter)))))))) OR ranger_cpu_data_master_arbiterlock));
  --ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in <= (internal_ranger_cpu_instruction_master_granted_onchip_mem_s1 AND ranger_cpu_instruction_master_read) AND NOT onchip_mem_s1_waits_for_read;
  --shift register p1 ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register) & A_ToStdLogicVector(ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in)));
  --ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= p1_ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1, which is an e_mux
  ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 <= ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register;
  --allow new arb cycle for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_allow_new_arb_cycle <= NOT ranger_cpu_data_master_arbiterlock AND NOT ranger_cpu_instruction_master_arbiterlock;
  --ranger_cpu/instruction_master assignment into master qualified-requests vector for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_master_qreq_vector(0) <= internal_ranger_cpu_instruction_master_qualified_request_onchip_mem_s1;
  --ranger_cpu/instruction_master grant onchip_mem/s1, which is an e_assign
  internal_ranger_cpu_instruction_master_granted_onchip_mem_s1 <= onchip_mem_s1_grant_vector(0);
  --ranger_cpu/instruction_master saved-grant onchip_mem/s1, which is an e_assign
  ranger_cpu_instruction_master_saved_grant_onchip_mem_s1 <= onchip_mem_s1_arb_winner(0) AND internal_ranger_cpu_instruction_master_requests_onchip_mem_s1;
  --ranger_cpu/data_master assignment into master qualified-requests vector for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_master_qreq_vector(1) <= internal_ranger_cpu_data_master_qualified_request_onchip_mem_s1;
  --ranger_cpu/data_master grant onchip_mem/s1, which is an e_assign
  internal_ranger_cpu_data_master_granted_onchip_mem_s1 <= onchip_mem_s1_grant_vector(1);
  --ranger_cpu/data_master saved-grant onchip_mem/s1, which is an e_assign
  ranger_cpu_data_master_saved_grant_onchip_mem_s1 <= onchip_mem_s1_arb_winner(1) AND internal_ranger_cpu_data_master_requests_onchip_mem_s1;
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

  onchip_mem_s1_chipselect <= internal_ranger_cpu_data_master_granted_onchip_mem_s1 OR internal_ranger_cpu_instruction_master_granted_onchip_mem_s1;
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
  onchip_mem_s1_write <= internal_ranger_cpu_data_master_granted_onchip_mem_s1 AND ranger_cpu_data_master_write;
  shifted_address_to_onchip_mem_s1_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --onchip_mem_s1_address mux, which is an e_mux
  onchip_mem_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_data_master_granted_onchip_mem_s1)) = '1'), (A_SRL(shifted_address_to_onchip_mem_s1_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_onchip_mem_s1_from_ranger_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 15);
  shifted_address_to_onchip_mem_s1_from_ranger_cpu_instruction_master <= ranger_cpu_instruction_master_address_to_slave;
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
  onchip_mem_s1_in_a_read_cycle <= ((internal_ranger_cpu_data_master_granted_onchip_mem_s1 AND ranger_cpu_data_master_read)) OR ((internal_ranger_cpu_instruction_master_granted_onchip_mem_s1 AND ranger_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_mem_s1_in_a_read_cycle;
  --onchip_mem_s1_waits_for_write in a cycle, which is an e_mux
  onchip_mem_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_mem_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_mem_s1_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_onchip_mem_s1 AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_mem_s1_in_a_write_cycle;
  wait_for_onchip_mem_s1_counter <= std_logic'('0');
  --onchip_mem_s1_byteenable byte enable port mux, which is an e_mux
  onchip_mem_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_data_master_granted_onchip_mem_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ranger_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_onchip_mem_s1 <= internal_ranger_cpu_data_master_granted_onchip_mem_s1;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_onchip_mem_s1 <= internal_ranger_cpu_data_master_qualified_request_onchip_mem_s1;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_onchip_mem_s1 <= internal_ranger_cpu_data_master_requests_onchip_mem_s1;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_granted_onchip_mem_s1 <= internal_ranger_cpu_instruction_master_granted_onchip_mem_s1;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 <= internal_ranger_cpu_instruction_master_qualified_request_onchip_mem_s1;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_requests_onchip_mem_s1 <= internal_ranger_cpu_instruction_master_requests_onchip_mem_s1;
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
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ranger_cpu_data_master_granted_onchip_mem_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ranger_cpu_instruction_master_granted_onchip_mem_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
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
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_saved_grant_onchip_mem_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ranger_cpu_instruction_master_saved_grant_onchip_mem_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
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

entity pll_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_clock_0_out_nativeaddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal cpu_clock_0_out_read : IN STD_LOGIC;
                 signal cpu_clock_0_out_write : IN STD_LOGIC;
                 signal cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal pll_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal pll_s1_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_clock_0_out_granted_pll_s1 : OUT STD_LOGIC;
                 signal cpu_clock_0_out_qualified_request_pll_s1 : OUT STD_LOGIC;
                 signal cpu_clock_0_out_read_data_valid_pll_s1 : OUT STD_LOGIC;
                 signal cpu_clock_0_out_requests_pll_s1 : OUT STD_LOGIC;
                 signal d1_pll_s1_end_xfer : OUT STD_LOGIC;
                 signal pll_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal pll_s1_chipselect : OUT STD_LOGIC;
                 signal pll_s1_read : OUT STD_LOGIC;
                 signal pll_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal pll_s1_reset_n : OUT STD_LOGIC;
                 signal pll_s1_resetrequest_from_sa : OUT STD_LOGIC;
                 signal pll_s1_write : OUT STD_LOGIC;
                 signal pll_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity pll_s1_arbitrator;


architecture europa of pll_s1_arbitrator is
                signal cpu_clock_0_out_arbiterlock :  STD_LOGIC;
                signal cpu_clock_0_out_arbiterlock2 :  STD_LOGIC;
                signal cpu_clock_0_out_continuerequest :  STD_LOGIC;
                signal cpu_clock_0_out_saved_grant_pll_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pll_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_clock_0_out_granted_pll_s1 :  STD_LOGIC;
                signal internal_cpu_clock_0_out_qualified_request_pll_s1 :  STD_LOGIC;
                signal internal_cpu_clock_0_out_requests_pll_s1 :  STD_LOGIC;
                signal pll_s1_allgrants :  STD_LOGIC;
                signal pll_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pll_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pll_s1_any_continuerequest :  STD_LOGIC;
                signal pll_s1_arb_counter_enable :  STD_LOGIC;
                signal pll_s1_arb_share_counter :  STD_LOGIC;
                signal pll_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal pll_s1_arb_share_set_values :  STD_LOGIC;
                signal pll_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pll_s1_begins_xfer :  STD_LOGIC;
                signal pll_s1_end_xfer :  STD_LOGIC;
                signal pll_s1_firsttransfer :  STD_LOGIC;
                signal pll_s1_grant_vector :  STD_LOGIC;
                signal pll_s1_in_a_read_cycle :  STD_LOGIC;
                signal pll_s1_in_a_write_cycle :  STD_LOGIC;
                signal pll_s1_master_qreq_vector :  STD_LOGIC;
                signal pll_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pll_s1_reg_firsttransfer :  STD_LOGIC;
                signal pll_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pll_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pll_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pll_s1_waits_for_read :  STD_LOGIC;
                signal pll_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_pll_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT pll_s1_end_xfer;
      end if;
    end if;

  end process;

  pll_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_clock_0_out_qualified_request_pll_s1);
  --assign pll_s1_readdata_from_sa = pll_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pll_s1_readdata_from_sa <= pll_s1_readdata;
  internal_cpu_clock_0_out_requests_pll_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_clock_0_out_read OR cpu_clock_0_out_write)))))));
  --pll_s1_arb_share_counter set values, which is an e_mux
  pll_s1_arb_share_set_values <= std_logic'('1');
  --pll_s1_non_bursting_master_requests mux, which is an e_mux
  pll_s1_non_bursting_master_requests <= internal_cpu_clock_0_out_requests_pll_s1;
  --pll_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pll_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pll_s1_arb_share_counter_next_value assignment, which is an e_assign
  pll_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pll_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pll_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(pll_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pll_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --pll_s1_allgrants all slave grants, which is an e_mux
  pll_s1_allgrants <= pll_s1_grant_vector;
  --pll_s1_end_xfer assignment, which is an e_assign
  pll_s1_end_xfer <= NOT ((pll_s1_waits_for_read OR pll_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pll_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pll_s1 <= pll_s1_end_xfer AND (((NOT pll_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pll_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pll_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pll_s1 AND pll_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pll_s1 AND NOT pll_s1_non_bursting_master_requests));
  --pll_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pll_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(pll_s1_arb_counter_enable) = '1' then 
        pll_s1_arb_share_counter <= pll_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pll_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pll_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pll_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pll_s1)) OR ((end_xfer_arb_share_counter_term_pll_s1 AND NOT pll_s1_non_bursting_master_requests)))) = '1' then 
        pll_s1_slavearbiterlockenable <= pll_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_clock_0/out pll/s1 arbiterlock, which is an e_assign
  cpu_clock_0_out_arbiterlock <= pll_s1_slavearbiterlockenable AND cpu_clock_0_out_continuerequest;
  --pll_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pll_s1_slavearbiterlockenable2 <= pll_s1_arb_share_counter_next_value;
  --cpu_clock_0/out pll/s1 arbiterlock2, which is an e_assign
  cpu_clock_0_out_arbiterlock2 <= pll_s1_slavearbiterlockenable2 AND cpu_clock_0_out_continuerequest;
  --pll_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pll_s1_any_continuerequest <= std_logic'('1');
  --cpu_clock_0_out_continuerequest continued request, which is an e_assign
  cpu_clock_0_out_continuerequest <= std_logic'('1');
  internal_cpu_clock_0_out_qualified_request_pll_s1 <= internal_cpu_clock_0_out_requests_pll_s1;
  --pll_s1_writedata mux, which is an e_mux
  pll_s1_writedata <= cpu_clock_0_out_writedata;
  --master is always granted when requested
  internal_cpu_clock_0_out_granted_pll_s1 <= internal_cpu_clock_0_out_qualified_request_pll_s1;
  --cpu_clock_0/out saved-grant pll/s1, which is an e_assign
  cpu_clock_0_out_saved_grant_pll_s1 <= internal_cpu_clock_0_out_requests_pll_s1;
  --allow new arb cycle for pll/s1, which is an e_assign
  pll_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pll_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pll_s1_master_qreq_vector <= std_logic'('1');
  --pll_s1_reset_n assignment, which is an e_assign
  pll_s1_reset_n <= reset_n;
  --assign pll_s1_resetrequest_from_sa = pll_s1_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  pll_s1_resetrequest_from_sa <= pll_s1_resetrequest;
  pll_s1_chipselect <= internal_cpu_clock_0_out_granted_pll_s1;
  --pll_s1_firsttransfer first transaction, which is an e_assign
  pll_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pll_s1_begins_xfer) = '1'), pll_s1_unreg_firsttransfer, pll_s1_reg_firsttransfer);
  --pll_s1_unreg_firsttransfer first transaction, which is an e_assign
  pll_s1_unreg_firsttransfer <= NOT ((pll_s1_slavearbiterlockenable AND pll_s1_any_continuerequest));
  --pll_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pll_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pll_s1_begins_xfer) = '1' then 
        pll_s1_reg_firsttransfer <= pll_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pll_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pll_s1_beginbursttransfer_internal <= pll_s1_begins_xfer;
  --pll_s1_read assignment, which is an e_mux
  pll_s1_read <= internal_cpu_clock_0_out_granted_pll_s1 AND cpu_clock_0_out_read;
  --pll_s1_write assignment, which is an e_mux
  pll_s1_write <= internal_cpu_clock_0_out_granted_pll_s1 AND cpu_clock_0_out_write;
  --pll_s1_address mux, which is an e_mux
  pll_s1_address <= cpu_clock_0_out_nativeaddress;
  --d1_pll_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pll_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_pll_s1_end_xfer <= pll_s1_end_xfer;
      end if;
    end if;

  end process;

  --pll_s1_waits_for_read in a cycle, which is an e_mux
  pll_s1_waits_for_read <= pll_s1_in_a_read_cycle AND pll_s1_begins_xfer;
  --pll_s1_in_a_read_cycle assignment, which is an e_assign
  pll_s1_in_a_read_cycle <= internal_cpu_clock_0_out_granted_pll_s1 AND cpu_clock_0_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pll_s1_in_a_read_cycle;
  --pll_s1_waits_for_write in a cycle, which is an e_mux
  pll_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pll_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pll_s1_in_a_write_cycle assignment, which is an e_assign
  pll_s1_in_a_write_cycle <= internal_cpu_clock_0_out_granted_pll_s1 AND cpu_clock_0_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pll_s1_in_a_write_cycle;
  wait_for_pll_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_clock_0_out_granted_pll_s1 <= internal_cpu_clock_0_out_granted_pll_s1;
  --vhdl renameroo for output signals
  cpu_clock_0_out_qualified_request_pll_s1 <= internal_cpu_clock_0_out_qualified_request_pll_s1;
  --vhdl renameroo for output signals
  cpu_clock_0_out_requests_pll_s1 <= internal_cpu_clock_0_out_requests_pll_s1;
--synthesis translate_off
    --pll/s1 enable non-zero assertions, which is an e_register
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

entity ranger_cpu_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_data_master_debugaccess : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_read : IN STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_ranger_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal ranger_cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ranger_cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_jtag_debug_module_reset : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_write : OUT STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity ranger_cpu_jtag_debug_module_arbitrator;


architecture europa of ranger_cpu_jtag_debug_module_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ranger_cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal last_cycle_ranger_cpu_data_master_granted_slave_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_ranger_cpu_instruction_master_granted_slave_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_instruction_master_saved_grant_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_allgrants :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_arb_share_counter :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_arb_share_set_values :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_ranger_cpu_jtag_debug_module_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal shifted_address_to_ranger_cpu_jtag_debug_module_from_ranger_cpu_instruction_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal wait_for_ranger_cpu_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT ranger_cpu_jtag_debug_module_end_xfer;
      end if;
    end if;

  end process;

  ranger_cpu_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module OR internal_ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module));
  --assign ranger_cpu_jtag_debug_module_readdata_from_sa = ranger_cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_jtag_debug_module_readdata_from_sa <= ranger_cpu_jtag_debug_module_readdata;
  internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("110000000100000000000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --ranger_cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  ranger_cpu_jtag_debug_module_arb_share_set_values <= std_logic'('1');
  --ranger_cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  ranger_cpu_jtag_debug_module_non_bursting_master_requests <= ((internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module OR internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module) OR internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module) OR internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module;
  --ranger_cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  ranger_cpu_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --ranger_cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  ranger_cpu_jtag_debug_module_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_jtag_debug_module_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ranger_cpu_jtag_debug_module_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_jtag_debug_module_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ranger_cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  ranger_cpu_jtag_debug_module_allgrants <= ((or_reduce(ranger_cpu_jtag_debug_module_grant_vector) OR or_reduce(ranger_cpu_jtag_debug_module_grant_vector)) OR or_reduce(ranger_cpu_jtag_debug_module_grant_vector)) OR or_reduce(ranger_cpu_jtag_debug_module_grant_vector);
  --ranger_cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  ranger_cpu_jtag_debug_module_end_xfer <= NOT ((ranger_cpu_jtag_debug_module_waits_for_read OR ranger_cpu_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_ranger_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ranger_cpu_jtag_debug_module <= ranger_cpu_jtag_debug_module_end_xfer AND (((NOT ranger_cpu_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ranger_cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  ranger_cpu_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ranger_cpu_jtag_debug_module AND ranger_cpu_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_jtag_debug_module AND NOT ranger_cpu_jtag_debug_module_non_bursting_master_requests));
  --ranger_cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_jtag_debug_module_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_jtag_debug_module_arb_counter_enable) = '1' then 
        ranger_cpu_jtag_debug_module_arb_share_counter <= ranger_cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(ranger_cpu_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_ranger_cpu_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_ranger_cpu_jtag_debug_module AND NOT ranger_cpu_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        ranger_cpu_jtag_debug_module_slavearbiterlockenable <= ranger_cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ranger_cpu/data_master ranger_cpu/jtag_debug_module arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= ranger_cpu_jtag_debug_module_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --ranger_cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ranger_cpu_jtag_debug_module_slavearbiterlockenable2 <= ranger_cpu_jtag_debug_module_arb_share_counter_next_value;
  --ranger_cpu/data_master ranger_cpu/jtag_debug_module arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= ranger_cpu_jtag_debug_module_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --ranger_cpu/instruction_master ranger_cpu/jtag_debug_module arbiterlock, which is an e_assign
  ranger_cpu_instruction_master_arbiterlock <= ranger_cpu_jtag_debug_module_slavearbiterlockenable AND ranger_cpu_instruction_master_continuerequest;
  --ranger_cpu/instruction_master ranger_cpu/jtag_debug_module arbiterlock2, which is an e_assign
  ranger_cpu_instruction_master_arbiterlock2 <= ranger_cpu_jtag_debug_module_slavearbiterlockenable2 AND ranger_cpu_instruction_master_continuerequest;
  --ranger_cpu/instruction_master granted ranger_cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ranger_cpu_instruction_master_granted_slave_ranger_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_ranger_cpu_instruction_master_granted_slave_ranger_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_instruction_master_saved_grant_ranger_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ranger_cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ranger_cpu_instruction_master_granted_slave_ranger_cpu_jtag_debug_module))))));
      end if;
    end if;

  end process;

  --ranger_cpu_instruction_master_continuerequest continued request, which is an e_mux
  ranger_cpu_instruction_master_continuerequest <= last_cycle_ranger_cpu_instruction_master_granted_slave_ranger_cpu_jtag_debug_module AND internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module;
  --ranger_cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  ranger_cpu_jtag_debug_module_any_continuerequest <= ranger_cpu_instruction_master_continuerequest OR ranger_cpu_data_master_continuerequest;
  internal_ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module AND NOT (((((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write)) OR ranger_cpu_instruction_master_arbiterlock));
  --ranger_cpu_jtag_debug_module_writedata mux, which is an e_mux
  ranger_cpu_jtag_debug_module_writedata <= ranger_cpu_data_master_writedata;
  internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(ranger_cpu_instruction_master_address_to_slave(20 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("110000000100000000000")))) AND (ranger_cpu_instruction_master_read))) AND ranger_cpu_instruction_master_read;
  --ranger_cpu/data_master granted ranger_cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ranger_cpu_data_master_granted_slave_ranger_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_ranger_cpu_data_master_granted_slave_ranger_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ranger_cpu_data_master_saved_grant_ranger_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ranger_cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ranger_cpu_data_master_granted_slave_ranger_cpu_jtag_debug_module))))));
      end if;
    end if;

  end process;

  --ranger_cpu_data_master_continuerequest continued request, which is an e_mux
  ranger_cpu_data_master_continuerequest <= last_cycle_ranger_cpu_data_master_granted_slave_ranger_cpu_jtag_debug_module AND internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module;
  internal_ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module AND NOT ((((ranger_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR ranger_cpu_data_master_arbiterlock));
  --local readdatavalid ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module, which is an e_mux
  ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module <= (internal_ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module AND ranger_cpu_instruction_master_read) AND NOT ranger_cpu_jtag_debug_module_waits_for_read;
  --allow new arb cycle for ranger_cpu/jtag_debug_module, which is an e_assign
  ranger_cpu_jtag_debug_module_allow_new_arb_cycle <= NOT ranger_cpu_data_master_arbiterlock AND NOT ranger_cpu_instruction_master_arbiterlock;
  --ranger_cpu/instruction_master assignment into master qualified-requests vector for ranger_cpu/jtag_debug_module, which is an e_assign
  ranger_cpu_jtag_debug_module_master_qreq_vector(0) <= internal_ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module;
  --ranger_cpu/instruction_master grant ranger_cpu/jtag_debug_module, which is an e_assign
  internal_ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module <= ranger_cpu_jtag_debug_module_grant_vector(0);
  --ranger_cpu/instruction_master saved-grant ranger_cpu/jtag_debug_module, which is an e_assign
  ranger_cpu_instruction_master_saved_grant_ranger_cpu_jtag_debug_module <= ranger_cpu_jtag_debug_module_arb_winner(0) AND internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module;
  --ranger_cpu/data_master assignment into master qualified-requests vector for ranger_cpu/jtag_debug_module, which is an e_assign
  ranger_cpu_jtag_debug_module_master_qreq_vector(1) <= internal_ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module;
  --ranger_cpu/data_master grant ranger_cpu/jtag_debug_module, which is an e_assign
  internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module <= ranger_cpu_jtag_debug_module_grant_vector(1);
  --ranger_cpu/data_master saved-grant ranger_cpu/jtag_debug_module, which is an e_assign
  ranger_cpu_data_master_saved_grant_ranger_cpu_jtag_debug_module <= ranger_cpu_jtag_debug_module_arb_winner(1) AND internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module;
  --ranger_cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  ranger_cpu_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((ranger_cpu_jtag_debug_module_master_qreq_vector & ranger_cpu_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT ranger_cpu_jtag_debug_module_master_qreq_vector & NOT ranger_cpu_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (ranger_cpu_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  ranger_cpu_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((ranger_cpu_jtag_debug_module_allow_new_arb_cycle AND or_reduce(ranger_cpu_jtag_debug_module_grant_vector)))) = '1'), ranger_cpu_jtag_debug_module_grant_vector, ranger_cpu_jtag_debug_module_saved_chosen_master_vector);
  --saved ranger_cpu_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        ranger_cpu_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(ranger_cpu_jtag_debug_module_grant_vector)) = '1'), ranger_cpu_jtag_debug_module_grant_vector, ranger_cpu_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  ranger_cpu_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((ranger_cpu_jtag_debug_module_chosen_master_double_vector(1) OR ranger_cpu_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((ranger_cpu_jtag_debug_module_chosen_master_double_vector(0) OR ranger_cpu_jtag_debug_module_chosen_master_double_vector(2)))));
  --ranger_cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  ranger_cpu_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(ranger_cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(ranger_cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --ranger_cpu/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(ranger_cpu_jtag_debug_module_grant_vector)) = '1' then 
        ranger_cpu_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(ranger_cpu_jtag_debug_module_end_xfer) = '1'), ranger_cpu_jtag_debug_module_chosen_master_rot_left, ranger_cpu_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  ranger_cpu_jtag_debug_module_begintransfer <= ranger_cpu_jtag_debug_module_begins_xfer;
  --assign lhs ~ranger_cpu_jtag_debug_module_reset of type reset_n to ranger_cpu_jtag_debug_module_reset_n, which is an e_assign
  ranger_cpu_jtag_debug_module_reset <= NOT internal_ranger_cpu_jtag_debug_module_reset_n;
  --ranger_cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  internal_ranger_cpu_jtag_debug_module_reset_n <= reset_n;
  --assign ranger_cpu_jtag_debug_module_resetrequest_from_sa = ranger_cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  ranger_cpu_jtag_debug_module_resetrequest_from_sa <= ranger_cpu_jtag_debug_module_resetrequest;
  ranger_cpu_jtag_debug_module_chipselect <= internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module OR internal_ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module;
  --ranger_cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  ranger_cpu_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(ranger_cpu_jtag_debug_module_begins_xfer) = '1'), ranger_cpu_jtag_debug_module_unreg_firsttransfer, ranger_cpu_jtag_debug_module_reg_firsttransfer);
  --ranger_cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  ranger_cpu_jtag_debug_module_unreg_firsttransfer <= NOT ((ranger_cpu_jtag_debug_module_slavearbiterlockenable AND ranger_cpu_jtag_debug_module_any_continuerequest));
  --ranger_cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ranger_cpu_jtag_debug_module_begins_xfer) = '1' then 
        ranger_cpu_jtag_debug_module_reg_firsttransfer <= ranger_cpu_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ranger_cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ranger_cpu_jtag_debug_module_beginbursttransfer_internal <= ranger_cpu_jtag_debug_module_begins_xfer;
  --ranger_cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  ranger_cpu_jtag_debug_module_arbitration_holdoff_internal <= ranger_cpu_jtag_debug_module_begins_xfer AND ranger_cpu_jtag_debug_module_firsttransfer;
  --ranger_cpu_jtag_debug_module_write assignment, which is an e_mux
  ranger_cpu_jtag_debug_module_write <= internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module AND ranger_cpu_data_master_write;
  shifted_address_to_ranger_cpu_jtag_debug_module_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --ranger_cpu_jtag_debug_module_address mux, which is an e_mux
  ranger_cpu_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_ranger_cpu_jtag_debug_module_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_ranger_cpu_jtag_debug_module_from_ranger_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
  shifted_address_to_ranger_cpu_jtag_debug_module_from_ranger_cpu_instruction_master <= ranger_cpu_instruction_master_address_to_slave;
  --d1_ranger_cpu_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ranger_cpu_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_ranger_cpu_jtag_debug_module_end_xfer <= ranger_cpu_jtag_debug_module_end_xfer;
      end if;
    end if;

  end process;

  --ranger_cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  ranger_cpu_jtag_debug_module_waits_for_read <= ranger_cpu_jtag_debug_module_in_a_read_cycle AND ranger_cpu_jtag_debug_module_begins_xfer;
  --ranger_cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  ranger_cpu_jtag_debug_module_in_a_read_cycle <= ((internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module AND ranger_cpu_data_master_read)) OR ((internal_ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module AND ranger_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ranger_cpu_jtag_debug_module_in_a_read_cycle;
  --ranger_cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  ranger_cpu_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --ranger_cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  ranger_cpu_jtag_debug_module_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ranger_cpu_jtag_debug_module_in_a_write_cycle;
  wait_for_ranger_cpu_jtag_debug_module_counter <= std_logic'('0');
  --ranger_cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  ranger_cpu_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ranger_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  ranger_cpu_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module <= internal_ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ranger_cpu_jtag_debug_module_reset_n <= internal_ranger_cpu_jtag_debug_module_reset_n;
--synthesis translate_off
    --ranger_cpu/jtag_debug_module enable non-zero assertions, which is an e_register
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
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
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
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_saved_grant_ranger_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ranger_cpu_instruction_master_saved_grant_ranger_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
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

entity ranger_cpu_data_master_arbitrator is 
        port (
              -- inputs:
                 signal BL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal BR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal control_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal d1_BL_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_BR_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_TL_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_TR_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_control_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_clock_0_in_end_xfer : IN STD_LOGIC;
                 signal d1_frame_received_s1_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                 signal d1_ranger_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal d1_timer_1ms_s1_end_xfer : IN STD_LOGIC;
                 signal frame_received_s1_irq_from_sa : IN STD_LOGIC;
                 signal frame_received_s1_readdata_from_sa : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_data_master_address : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_granted_BL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_BR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_TL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_TR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_control_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_cpu_clock_0_in : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_frame_received_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_granted_timer_1ms_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_BL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_BR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_TL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_TR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_control_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_cpu_clock_0_in : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_frame_received_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_timer_1ms_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_cpu_clock_0_in : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_frame_received_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_timer_1ms_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_BL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_BR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_TL_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_TR_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_control_avalon_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_cpu_clock_0_in : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_frame_received_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                 signal ranger_cpu_data_master_requests_timer_1ms_s1 : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                 signal registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal timer_1ms_s1_irq_from_sa : IN STD_LOGIC;
                 signal timer_1ms_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal ranger_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_data_master_waitrequest : OUT STD_LOGIC
              );
end entity ranger_cpu_data_master_arbitrator;


architecture europa of ranger_cpu_data_master_arbitrator is
                signal internal_ranger_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal internal_ranger_cpu_data_master_waitrequest :  STD_LOGIC;
                signal p1_registered_ranger_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal ranger_cpu_data_master_run :  STD_LOGIC;
                signal registered_ranger_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_data_master_qualified_request_BL_avalon_slave OR registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave) OR NOT ranger_cpu_data_master_requests_BL_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_data_master_qualified_request_BL_avalon_slave OR NOT ranger_cpu_data_master_read) OR ((registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave AND ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_BL_avalon_slave OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_data_master_qualified_request_BR_avalon_slave OR registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave) OR NOT ranger_cpu_data_master_requests_BR_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_data_master_qualified_request_BR_avalon_slave OR NOT ranger_cpu_data_master_read) OR ((registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave AND ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_BR_avalon_slave OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_data_master_qualified_request_TL_avalon_slave OR registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave) OR NOT ranger_cpu_data_master_requests_TL_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_data_master_qualified_request_TL_avalon_slave OR NOT ranger_cpu_data_master_read) OR ((registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave AND ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_TL_avalon_slave OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_data_master_qualified_request_TR_avalon_slave OR registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave) OR NOT ranger_cpu_data_master_requests_TR_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_data_master_qualified_request_TR_avalon_slave OR NOT ranger_cpu_data_master_read) OR ((registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave AND ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_TR_avalon_slave OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_data_master_qualified_request_control_avalon_slave OR registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave) OR NOT ranger_cpu_data_master_requests_control_avalon_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_data_master_qualified_request_control_avalon_slave OR NOT ranger_cpu_data_master_read) OR ((registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave AND ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_control_avalon_slave OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  ranger_cpu_data_master_run <= (r_0 AND r_1) AND r_2;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_qualified_request_cpu_clock_0_in OR NOT ranger_cpu_data_master_requests_cpu_clock_0_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_cpu_clock_0_in OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT cpu_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_cpu_clock_0_in OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT cpu_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_qualified_request_frame_received_s1 OR NOT ranger_cpu_data_master_requests_frame_received_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_frame_received_s1 OR NOT ranger_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_frame_received_s1 OR NOT ranger_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ranger_cpu_data_master_qualified_request_onchip_mem_s1 OR registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1) OR NOT ranger_cpu_data_master_requests_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_granted_onchip_mem_s1 OR NOT ranger_cpu_data_master_qualified_request_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ranger_cpu_data_master_qualified_request_onchip_mem_s1 OR NOT ranger_cpu_data_master_read) OR ((registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 AND ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_onchip_mem_s1 OR NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module OR NOT ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module OR NOT ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module)))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module OR NOT ranger_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_read))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module OR NOT ranger_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_sysid_control_slave OR NOT ranger_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_sysid_control_slave OR NOT ranger_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_qualified_request_timer_1ms_s1 OR NOT ranger_cpu_data_master_requests_timer_1ms_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_timer_1ms_s1 OR NOT ranger_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_data_master_qualified_request_timer_1ms_s1 OR NOT ranger_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_data_master_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_ranger_cpu_data_master_address_to_slave <= ranger_cpu_data_master_address(20 DOWNTO 0);
  --ranger_cpu/data_master readdata mux, which is an e_mux
  ranger_cpu_data_master_readdata <= ((((((((((((A_REP(NOT ranger_cpu_data_master_requests_BL_avalon_slave, 32) OR BL_avalon_slave_readdata_from_sa)) AND ((A_REP(NOT ranger_cpu_data_master_requests_BR_avalon_slave, 32) OR BR_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT ranger_cpu_data_master_requests_TL_avalon_slave, 32) OR TL_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT ranger_cpu_data_master_requests_TR_avalon_slave, 32) OR TR_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT ranger_cpu_data_master_requests_control_avalon_slave, 32) OR control_avalon_slave_readdata_from_sa))) AND ((A_REP(NOT ranger_cpu_data_master_requests_cpu_clock_0_in, 32) OR registered_ranger_cpu_data_master_readdata))) AND ((A_REP(NOT ranger_cpu_data_master_requests_frame_received_s1, 32) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(frame_received_s1_readdata_from_sa)))))) AND ((A_REP(NOT ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR registered_ranger_cpu_data_master_readdata))) AND ((A_REP(NOT ranger_cpu_data_master_requests_onchip_mem_s1, 32) OR onchip_mem_s1_readdata_from_sa))) AND ((A_REP(NOT ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module, 32) OR ranger_cpu_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT ranger_cpu_data_master_requests_sysid_control_slave, 32) OR sysid_control_slave_readdata_from_sa))) AND ((A_REP(NOT ranger_cpu_data_master_requests_timer_1ms_s1, 32) OR (std_logic_vector'("0000000000000000") & (timer_1ms_s1_readdata_from_sa))));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ranger_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        internal_ranger_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_data_master_run AND internal_ranger_cpu_data_master_waitrequest))))))));
      end if;
    end if;

  end process;

  --unpredictable registered wait state incoming data, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      registered_ranger_cpu_data_master_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        registered_ranger_cpu_data_master_readdata <= p1_registered_ranger_cpu_data_master_readdata;
      end if;
    end if;

  end process;

  --registered readdata mux, which is an e_mux
  p1_registered_ranger_cpu_data_master_readdata <= ((A_REP(NOT ranger_cpu_data_master_requests_cpu_clock_0_in, 32) OR (std_logic_vector'("0000000000000000") & (cpu_clock_0_in_readdata_from_sa)))) AND ((A_REP(NOT ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR jtag_uart_avalon_jtag_slave_readdata_from_sa));
  --irq assign, which is an e_assign
  ranger_cpu_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(frame_received_s1_irq_from_sa) & A_ToStdLogicVector(timer_1ms_s1_irq_from_sa) & A_ToStdLogicVector(jtag_uart_avalon_jtag_slave_irq_from_sa));
  --vhdl renameroo for output signals
  ranger_cpu_data_master_address_to_slave <= internal_ranger_cpu_data_master_address_to_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_waitrequest <= internal_ranger_cpu_data_master_waitrequest;

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

entity ranger_cpu_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                 signal d1_ranger_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_instruction_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_read : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                 signal ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ranger_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ranger_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_instruction_master_latency_counter : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ranger_cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal ranger_cpu_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity ranger_cpu_instruction_master_arbitrator;


architecture europa of ranger_cpu_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal internal_ranger_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal internal_ranger_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_ranger_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal pre_flush_ranger_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_address_last_time :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal ranger_cpu_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal ranger_cpu_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal ranger_cpu_instruction_master_read_last_time :  STD_LOGIC;
                signal ranger_cpu_instruction_master_run :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 OR NOT ranger_cpu_instruction_master_requests_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_instruction_master_granted_onchip_mem_s1 OR NOT ranger_cpu_instruction_master_qualified_request_onchip_mem_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 OR NOT ranger_cpu_instruction_master_read)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module OR NOT ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module)))))));
  --cascaded wait assignment, which is an e_assign
  ranger_cpu_instruction_master_run <= r_1 AND r_2;
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module OR NOT ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module OR NOT ranger_cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_ranger_cpu_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_instruction_master_read)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_ranger_cpu_instruction_master_address_to_slave <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('1')) & ranger_cpu_instruction_master_address(19 DOWNTO 0));
  --ranger_cpu_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ranger_cpu_instruction_master_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        ranger_cpu_instruction_master_read_but_no_slave_selected <= (ranger_cpu_instruction_master_read AND ranger_cpu_instruction_master_run) AND NOT ranger_cpu_instruction_master_is_granted_some_slave;
      end if;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  ranger_cpu_instruction_master_is_granted_some_slave <= ranger_cpu_instruction_master_granted_onchip_mem_s1 OR ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_ranger_cpu_instruction_master_readdatavalid <= ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  ranger_cpu_instruction_master_readdatavalid <= (((ranger_cpu_instruction_master_read_but_no_slave_selected OR pre_flush_ranger_cpu_instruction_master_readdatavalid) OR ranger_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_ranger_cpu_instruction_master_readdatavalid) OR ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module;
  --ranger_cpu/instruction_master readdata mux, which is an e_mux
  ranger_cpu_instruction_master_readdata <= ((A_REP(NOT ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1, 32) OR onchip_mem_s1_readdata_from_sa)) AND ((A_REP(NOT ((ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module AND ranger_cpu_instruction_master_read)) , 32) OR ranger_cpu_jtag_debug_module_readdata_from_sa));
  --actual waitrequest port, which is an e_assign
  internal_ranger_cpu_instruction_master_waitrequest <= NOT ranger_cpu_instruction_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ranger_cpu_instruction_master_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        internal_ranger_cpu_instruction_master_latency_counter <= p1_ranger_cpu_instruction_master_latency_counter;
      end if;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_ranger_cpu_instruction_master_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((ranger_cpu_instruction_master_run AND ranger_cpu_instruction_master_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_ranger_cpu_instruction_master_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_ranger_cpu_instruction_master_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_instruction_master_requests_onchip_mem_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_address_to_slave <= internal_ranger_cpu_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_latency_counter <= internal_ranger_cpu_instruction_master_latency_counter;
  --vhdl renameroo for output signals
  ranger_cpu_instruction_master_waitrequest <= internal_ranger_cpu_instruction_master_waitrequest;
--synthesis translate_off
    --ranger_cpu_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_instruction_master_address_last_time <= std_logic_vector'("000000000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_instruction_master_address_last_time <= ranger_cpu_instruction_master_address;
        end if;
      end if;

    end process;

    --ranger_cpu/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          active_and_waiting_last_time <= internal_ranger_cpu_instruction_master_waitrequest AND (ranger_cpu_instruction_master_read);
        end if;
      end if;

    end process;

    --ranger_cpu_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((ranger_cpu_instruction_master_address /= ranger_cpu_instruction_master_address_last_time))))) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("ranger_cpu_instruction_master_address did not heed wait!!!"));
          write(output, write_line8.all);
          deallocate (write_line8);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ranger_cpu_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ranger_cpu_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          ranger_cpu_instruction_master_read_last_time <= ranger_cpu_instruction_master_read;
        end if;
      end if;

    end process;

    --ranger_cpu_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ranger_cpu_instruction_master_read) /= std_logic'(ranger_cpu_instruction_master_read_last_time)))))) = '1' then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("ranger_cpu_instruction_master_read did not heed wait!!!"));
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

entity sysid_control_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                 signal sysid_control_slave_address : OUT STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity sysid_control_slave_arbitrator;


architecture europa of sysid_control_slave_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sysid_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_sysid_control_slave :  STD_LOGIC;
                signal shifted_address_to_sysid_control_slave_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  sysid_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_sysid_control_slave);
  --assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sysid_control_slave_readdata_from_sa <= sysid_control_slave_readdata;
  internal_ranger_cpu_data_master_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("110000001000001011000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write)))) AND ranger_cpu_data_master_read;
  --sysid_control_slave_arb_share_counter set values, which is an e_mux
  sysid_control_slave_arb_share_set_values <= std_logic'('1');
  --sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  sysid_control_slave_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_sysid_control_slave;
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

  --ranger_cpu/data_master sysid/control_slave arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= sysid_control_slave_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sysid_control_slave_slavearbiterlockenable2 <= sysid_control_slave_arb_share_counter_next_value;
  --ranger_cpu/data_master sysid/control_slave arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= sysid_control_slave_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  sysid_control_slave_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_sysid_control_slave <= internal_ranger_cpu_data_master_requests_sysid_control_slave;
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_sysid_control_slave <= internal_ranger_cpu_data_master_qualified_request_sysid_control_slave;
  --ranger_cpu/data_master saved-grant sysid/control_slave, which is an e_assign
  ranger_cpu_data_master_saved_grant_sysid_control_slave <= internal_ranger_cpu_data_master_requests_sysid_control_slave;
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
  shifted_address_to_sysid_control_slave_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --sysid_control_slave_address mux, which is an e_mux
  sysid_control_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_sysid_control_slave_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
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
  sysid_control_slave_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_sysid_control_slave AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sysid_control_slave_in_a_read_cycle;
  --sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  sysid_control_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_sysid_control_slave AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sysid_control_slave_in_a_write_cycle;
  wait_for_sysid_control_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_sysid_control_slave <= internal_ranger_cpu_data_master_granted_sysid_control_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_sysid_control_slave <= internal_ranger_cpu_data_master_qualified_request_sysid_control_slave;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_sysid_control_slave <= internal_ranger_cpu_data_master_requests_sysid_control_slave;
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
                 signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ranger_cpu_data_master_read : IN STD_LOGIC;
                 signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ranger_cpu_data_master_write : IN STD_LOGIC;
                 signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal timer_1ms_s1_irq : IN STD_LOGIC;
                 signal timer_1ms_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal d1_timer_1ms_s1_end_xfer : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_granted_timer_1ms_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_qualified_request_timer_1ms_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_read_data_valid_timer_1ms_s1 : OUT STD_LOGIC;
                 signal ranger_cpu_data_master_requests_timer_1ms_s1 : OUT STD_LOGIC;
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
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_timer_1ms_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_granted_timer_1ms_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_qualified_request_timer_1ms_s1 :  STD_LOGIC;
                signal internal_ranger_cpu_data_master_requests_timer_1ms_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ranger_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ranger_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ranger_cpu_data_master_saved_grant_timer_1ms_s1 :  STD_LOGIC;
                signal shifted_address_to_timer_1ms_s1_from_ranger_cpu_data_master :  STD_LOGIC_VECTOR (20 DOWNTO 0);
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

  timer_1ms_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ranger_cpu_data_master_qualified_request_timer_1ms_s1);
  --assign timer_1ms_s1_readdata_from_sa = timer_1ms_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_1ms_s1_readdata_from_sa <= timer_1ms_s1_readdata;
  internal_ranger_cpu_data_master_requests_timer_1ms_s1 <= to_std_logic(((Std_Logic_Vector'(ranger_cpu_data_master_address_to_slave(20 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("110000001000000100000")))) AND ((ranger_cpu_data_master_read OR ranger_cpu_data_master_write));
  --timer_1ms_s1_arb_share_counter set values, which is an e_mux
  timer_1ms_s1_arb_share_set_values <= std_logic'('1');
  --timer_1ms_s1_non_bursting_master_requests mux, which is an e_mux
  timer_1ms_s1_non_bursting_master_requests <= internal_ranger_cpu_data_master_requests_timer_1ms_s1;
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

  --ranger_cpu/data_master timer_1ms/s1 arbiterlock, which is an e_assign
  ranger_cpu_data_master_arbiterlock <= timer_1ms_s1_slavearbiterlockenable AND ranger_cpu_data_master_continuerequest;
  --timer_1ms_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  timer_1ms_s1_slavearbiterlockenable2 <= timer_1ms_s1_arb_share_counter_next_value;
  --ranger_cpu/data_master timer_1ms/s1 arbiterlock2, which is an e_assign
  ranger_cpu_data_master_arbiterlock2 <= timer_1ms_s1_slavearbiterlockenable2 AND ranger_cpu_data_master_continuerequest;
  --timer_1ms_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  timer_1ms_s1_any_continuerequest <= std_logic'('1');
  --ranger_cpu_data_master_continuerequest continued request, which is an e_assign
  ranger_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ranger_cpu_data_master_qualified_request_timer_1ms_s1 <= internal_ranger_cpu_data_master_requests_timer_1ms_s1 AND NOT (((NOT ranger_cpu_data_master_waitrequest) AND ranger_cpu_data_master_write));
  --timer_1ms_s1_writedata mux, which is an e_mux
  timer_1ms_s1_writedata <= ranger_cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_ranger_cpu_data_master_granted_timer_1ms_s1 <= internal_ranger_cpu_data_master_qualified_request_timer_1ms_s1;
  --ranger_cpu/data_master saved-grant timer_1ms/s1, which is an e_assign
  ranger_cpu_data_master_saved_grant_timer_1ms_s1 <= internal_ranger_cpu_data_master_requests_timer_1ms_s1;
  --allow new arb cycle for timer_1ms/s1, which is an e_assign
  timer_1ms_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  timer_1ms_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  timer_1ms_s1_master_qreq_vector <= std_logic'('1');
  --timer_1ms_s1_reset_n assignment, which is an e_assign
  timer_1ms_s1_reset_n <= reset_n;
  timer_1ms_s1_chipselect <= internal_ranger_cpu_data_master_granted_timer_1ms_s1;
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
  timer_1ms_s1_write_n <= NOT ((internal_ranger_cpu_data_master_granted_timer_1ms_s1 AND ranger_cpu_data_master_write));
  shifted_address_to_timer_1ms_s1_from_ranger_cpu_data_master <= ranger_cpu_data_master_address_to_slave;
  --timer_1ms_s1_address mux, which is an e_mux
  timer_1ms_s1_address <= A_EXT (A_SRL(shifted_address_to_timer_1ms_s1_from_ranger_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
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
  timer_1ms_s1_in_a_read_cycle <= internal_ranger_cpu_data_master_granted_timer_1ms_s1 AND ranger_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= timer_1ms_s1_in_a_read_cycle;
  --timer_1ms_s1_waits_for_write in a cycle, which is an e_mux
  timer_1ms_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_1ms_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --timer_1ms_s1_in_a_write_cycle assignment, which is an e_assign
  timer_1ms_s1_in_a_write_cycle <= internal_ranger_cpu_data_master_granted_timer_1ms_s1 AND ranger_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= timer_1ms_s1_in_a_write_cycle;
  wait_for_timer_1ms_s1_counter <= std_logic'('0');
  --assign timer_1ms_s1_irq_from_sa = timer_1ms_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_1ms_s1_irq_from_sa <= timer_1ms_s1_irq;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_granted_timer_1ms_s1 <= internal_ranger_cpu_data_master_granted_timer_1ms_s1;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_qualified_request_timer_1ms_s1 <= internal_ranger_cpu_data_master_qualified_request_timer_1ms_s1;
  --vhdl renameroo for output signals
  ranger_cpu_data_master_requests_timer_1ms_s1 <= internal_ranger_cpu_data_master_requests_timer_1ms_s1;
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

entity cpu_reset_clk100_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity cpu_reset_clk100_domain_synch_module;


architecture europa of cpu_reset_clk100_domain_synch_module is
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

entity cpu_reset_clk50_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity cpu_reset_clk50_domain_synch_module;


architecture europa of cpu_reset_clk50_domain_synch_module is
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

entity cpu is 
        port (
              -- 1) global signals:
                 signal clk100 : OUT STD_LOGIC;
                 signal clk50 : IN STD_LOGIC;
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

              -- the_frame_received
                 signal in_port_to_the_frame_received : IN STD_LOGIC
              );
end entity cpu;


architecture europa of cpu is
component BL_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal BL_avalon_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal BL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal BL_avalon_slave_read_n : OUT STD_LOGIC;
                    signal BL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal BL_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal BL_avalon_slave_write_n : OUT STD_LOGIC;
                    signal BL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_BL_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_BL_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_BL_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_BL_avalon_slave : OUT STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave : OUT STD_LOGIC
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
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal BR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal BR_avalon_slave_read_n : OUT STD_LOGIC;
                    signal BR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal BR_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal BR_avalon_slave_write_n : OUT STD_LOGIC;
                    signal BR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_BR_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_BR_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_BR_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_BR_avalon_slave : OUT STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave : OUT STD_LOGIC
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
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal TL_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal TL_avalon_slave_read_n : OUT STD_LOGIC;
                    signal TL_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TL_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal TL_avalon_slave_write_n : OUT STD_LOGIC;
                    signal TL_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_TL_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_TL_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_TL_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_TL_avalon_slave : OUT STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave : OUT STD_LOGIC
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
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal TR_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal TR_avalon_slave_read_n : OUT STD_LOGIC;
                    signal TR_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TR_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal TR_avalon_slave_write_n : OUT STD_LOGIC;
                    signal TR_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_TR_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_TR_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_TR_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_TR_avalon_slave : OUT STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave : OUT STD_LOGIC
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
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal control_avalon_slave_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal control_avalon_slave_read_n : OUT STD_LOGIC;
                    signal control_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal control_avalon_slave_reset_n : OUT STD_LOGIC;
                    signal control_avalon_slave_write_n : OUT STD_LOGIC;
                    signal control_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_control_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_control_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_control_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_control_avalon_slave : OUT STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave : OUT STD_LOGIC
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

component cpu_clock_0_in_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_clock_0_in_endofpacket : IN STD_LOGIC;
                    signal cpu_clock_0_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_clock_0_in_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_clock_0_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal cpu_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal cpu_clock_0_in_read : OUT STD_LOGIC;
                    signal cpu_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_clock_0_in_reset_n : OUT STD_LOGIC;
                    signal cpu_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal cpu_clock_0_in_write : OUT STD_LOGIC;
                    signal cpu_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal d1_cpu_clock_0_in_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_cpu_clock_0_in : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_cpu_clock_0_in : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_cpu_clock_0_in : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_cpu_clock_0_in : OUT STD_LOGIC
                 );
end component cpu_clock_0_in_arbitrator;

component cpu_clock_0_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_clock_0_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_clock_0_out_granted_pll_s1 : IN STD_LOGIC;
                    signal cpu_clock_0_out_qualified_request_pll_s1 : IN STD_LOGIC;
                    signal cpu_clock_0_out_read : IN STD_LOGIC;
                    signal cpu_clock_0_out_read_data_valid_pll_s1 : IN STD_LOGIC;
                    signal cpu_clock_0_out_requests_pll_s1 : IN STD_LOGIC;
                    signal cpu_clock_0_out_write : IN STD_LOGIC;
                    signal cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal d1_pll_s1_end_xfer : IN STD_LOGIC;
                    signal pll_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_clock_0_out_reset_n : OUT STD_LOGIC;
                    signal cpu_clock_0_out_waitrequest : OUT STD_LOGIC
                 );
end component cpu_clock_0_out_arbitrator;

component cpu_clock_0 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component cpu_clock_0;

component frame_received_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal frame_received_s1_irq : IN STD_LOGIC;
                    signal frame_received_s1_readdata : IN STD_LOGIC;
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_frame_received_s1_end_xfer : OUT STD_LOGIC;
                    signal frame_received_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal frame_received_s1_chipselect : OUT STD_LOGIC;
                    signal frame_received_s1_irq_from_sa : OUT STD_LOGIC;
                    signal frame_received_s1_readdata_from_sa : OUT STD_LOGIC;
                    signal frame_received_s1_reset_n : OUT STD_LOGIC;
                    signal frame_received_s1_write_n : OUT STD_LOGIC;
                    signal frame_received_s1_writedata : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_frame_received_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_frame_received_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_frame_received_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_frame_received_s1 : OUT STD_LOGIC
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
                    signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
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
                    signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC
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

component onchip_mem_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_onchip_mem_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_mem_s1_address : OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
                    signal onchip_mem_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_mem_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_mem_s1_clken : OUT STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_mem_s1_write : OUT STD_LOGIC;
                    signal onchip_mem_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_data_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC
                 );
end component onchip_mem_s1_arbitrator;

component onchip_mem is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
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

component pll_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_clock_0_out_nativeaddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal cpu_clock_0_out_read : IN STD_LOGIC;
                    signal cpu_clock_0_out_write : IN STD_LOGIC;
                    signal cpu_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal pll_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal pll_s1_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_clock_0_out_granted_pll_s1 : OUT STD_LOGIC;
                    signal cpu_clock_0_out_qualified_request_pll_s1 : OUT STD_LOGIC;
                    signal cpu_clock_0_out_read_data_valid_pll_s1 : OUT STD_LOGIC;
                    signal cpu_clock_0_out_requests_pll_s1 : OUT STD_LOGIC;
                    signal d1_pll_s1_end_xfer : OUT STD_LOGIC;
                    signal pll_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal pll_s1_chipselect : OUT STD_LOGIC;
                    signal pll_s1_read : OUT STD_LOGIC;
                    signal pll_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal pll_s1_reset_n : OUT STD_LOGIC;
                    signal pll_s1_resetrequest_from_sa : OUT STD_LOGIC;
                    signal pll_s1_write : OUT STD_LOGIC;
                    signal pll_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component pll_s1_arbitrator;

component pll is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal c0 : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal resetrequest : OUT STD_LOGIC
                 );
end component pll;

component ranger_cpu_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_data_master_debugaccess : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_read : IN STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_ranger_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal ranger_cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ranger_cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_jtag_debug_module_reset : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_write : OUT STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component ranger_cpu_jtag_debug_module_arbitrator;

component ranger_cpu_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal BL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal BR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TL_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal TR_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal control_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal d1_BL_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_BR_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_TL_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_TR_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_control_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_clock_0_in_end_xfer : IN STD_LOGIC;
                    signal d1_frame_received_s1_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                    signal d1_ranger_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal d1_timer_1ms_s1_end_xfer : IN STD_LOGIC;
                    signal frame_received_s1_irq_from_sa : IN STD_LOGIC;
                    signal frame_received_s1_readdata_from_sa : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_data_master_address : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_granted_BL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_BR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_TL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_TR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_control_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_cpu_clock_0_in : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_frame_received_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_granted_timer_1ms_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_BL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_BR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_TL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_TR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_control_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_cpu_clock_0_in : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_frame_received_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_timer_1ms_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_cpu_clock_0_in : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_frame_received_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_timer_1ms_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_BL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_BR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_TL_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_TR_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_control_avalon_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_cpu_clock_0_in : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_frame_received_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                    signal ranger_cpu_data_master_requests_timer_1ms_s1 : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave : IN STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave : IN STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave : IN STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave : IN STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave : IN STD_LOGIC;
                    signal registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal timer_1ms_s1_irq_from_sa : IN STD_LOGIC;
                    signal timer_1ms_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal ranger_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_data_master_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_data_master_arbitrator;

component ranger_cpu_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                    signal d1_ranger_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_instruction_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_read : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                    signal ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ranger_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ranger_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_instruction_master_latency_counter : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ranger_cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                    signal ranger_cpu_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component ranger_cpu_instruction_master_arbitrator;

component ranger_cpu is 
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
                    signal d_address : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component ranger_cpu;

component sysid_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
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
                    signal ranger_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ranger_cpu_data_master_read : IN STD_LOGIC;
                    signal ranger_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ranger_cpu_data_master_write : IN STD_LOGIC;
                    signal ranger_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal timer_1ms_s1_irq : IN STD_LOGIC;
                    signal timer_1ms_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal d1_timer_1ms_s1_end_xfer : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_granted_timer_1ms_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_qualified_request_timer_1ms_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_read_data_valid_timer_1ms_s1 : OUT STD_LOGIC;
                    signal ranger_cpu_data_master_requests_timer_1ms_s1 : OUT STD_LOGIC;
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

component cpu_reset_clk100_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component cpu_reset_clk100_domain_synch_module;

component cpu_reset_clk50_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component cpu_reset_clk50_domain_synch_module;

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
                signal clk50_reset_n :  STD_LOGIC;
                signal control_avalon_slave_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal control_avalon_slave_read_n :  STD_LOGIC;
                signal control_avalon_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal control_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal control_avalon_slave_reset_n :  STD_LOGIC;
                signal control_avalon_slave_write_n :  STD_LOGIC;
                signal control_avalon_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_clock_0_in_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_clock_0_in_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_clock_0_in_endofpacket :  STD_LOGIC;
                signal cpu_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal cpu_clock_0_in_nativeaddress :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cpu_clock_0_in_read :  STD_LOGIC;
                signal cpu_clock_0_in_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_clock_0_in_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_clock_0_in_reset_n :  STD_LOGIC;
                signal cpu_clock_0_in_waitrequest :  STD_LOGIC;
                signal cpu_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal cpu_clock_0_in_write :  STD_LOGIC;
                signal cpu_clock_0_in_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_clock_0_out_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_clock_0_out_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_clock_0_out_endofpacket :  STD_LOGIC;
                signal cpu_clock_0_out_granted_pll_s1 :  STD_LOGIC;
                signal cpu_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cpu_clock_0_out_qualified_request_pll_s1 :  STD_LOGIC;
                signal cpu_clock_0_out_read :  STD_LOGIC;
                signal cpu_clock_0_out_read_data_valid_pll_s1 :  STD_LOGIC;
                signal cpu_clock_0_out_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_clock_0_out_requests_pll_s1 :  STD_LOGIC;
                signal cpu_clock_0_out_reset_n :  STD_LOGIC;
                signal cpu_clock_0_out_waitrequest :  STD_LOGIC;
                signal cpu_clock_0_out_write :  STD_LOGIC;
                signal cpu_clock_0_out_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal d1_BL_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_BR_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_TL_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_TR_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_control_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_cpu_clock_0_in_end_xfer :  STD_LOGIC;
                signal d1_frame_received_s1_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_onchip_mem_s1_end_xfer :  STD_LOGIC;
                signal d1_pll_s1_end_xfer :  STD_LOGIC;
                signal d1_ranger_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_sysid_control_slave_end_xfer :  STD_LOGIC;
                signal d1_timer_1ms_s1_end_xfer :  STD_LOGIC;
                signal frame_received_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal frame_received_s1_chipselect :  STD_LOGIC;
                signal frame_received_s1_irq :  STD_LOGIC;
                signal frame_received_s1_irq_from_sa :  STD_LOGIC;
                signal frame_received_s1_readdata :  STD_LOGIC;
                signal frame_received_s1_readdata_from_sa :  STD_LOGIC;
                signal frame_received_s1_reset_n :  STD_LOGIC;
                signal frame_received_s1_write_n :  STD_LOGIC;
                signal frame_received_s1_writedata :  STD_LOGIC;
                signal internal_clk100 :  STD_LOGIC;
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
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal onchip_mem_s1_address :  STD_LOGIC_VECTOR (14 DOWNTO 0);
                signal onchip_mem_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_mem_s1_chipselect :  STD_LOGIC;
                signal onchip_mem_s1_clken :  STD_LOGIC;
                signal onchip_mem_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_mem_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_mem_s1_write :  STD_LOGIC;
                signal onchip_mem_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_clk_pll_c0 :  STD_LOGIC;
                signal pll_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal pll_s1_chipselect :  STD_LOGIC;
                signal pll_s1_read :  STD_LOGIC;
                signal pll_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal pll_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal pll_s1_reset_n :  STD_LOGIC;
                signal pll_s1_resetrequest :  STD_LOGIC;
                signal pll_s1_resetrequest_from_sa :  STD_LOGIC;
                signal pll_s1_write :  STD_LOGIC;
                signal pll_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ranger_cpu_data_master_address :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal ranger_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal ranger_cpu_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ranger_cpu_data_master_debugaccess :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_BL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_BR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_TL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_TR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_control_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_cpu_clock_0_in :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_frame_received_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_granted_timer_1ms_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_data_master_qualified_request_BL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_BR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_TL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_TR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_control_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_cpu_clock_0_in :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_frame_received_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_qualified_request_timer_1ms_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_read :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_BL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_BR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_TL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_TR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_control_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_cpu_clock_0_in :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_frame_received_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_read_data_valid_timer_1ms_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_data_master_requests_BL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_BR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_TL_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_TR_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_control_avalon_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_cpu_clock_0_in :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_frame_received_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal ranger_cpu_data_master_requests_timer_1ms_s1 :  STD_LOGIC;
                signal ranger_cpu_data_master_waitrequest :  STD_LOGIC;
                signal ranger_cpu_data_master_write :  STD_LOGIC;
                signal ranger_cpu_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_instruction_master_address :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal ranger_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal ranger_cpu_instruction_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_instruction_master_read :  STD_LOGIC;
                signal ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal ranger_cpu_instruction_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module :  STD_LOGIC;
                signal ranger_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_chipselect :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ranger_cpu_jtag_debug_module_reset :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_write :  STD_LOGIC;
                signal ranger_cpu_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave :  STD_LOGIC;
                signal registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave :  STD_LOGIC;
                signal registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave :  STD_LOGIC;
                signal registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave :  STD_LOGIC;
                signal registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave :  STD_LOGIC;
                signal registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
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
      d1_BL_avalon_slave_end_xfer => d1_BL_avalon_slave_end_xfer,
      ranger_cpu_data_master_granted_BL_avalon_slave => ranger_cpu_data_master_granted_BL_avalon_slave,
      ranger_cpu_data_master_qualified_request_BL_avalon_slave => ranger_cpu_data_master_qualified_request_BL_avalon_slave,
      ranger_cpu_data_master_read_data_valid_BL_avalon_slave => ranger_cpu_data_master_read_data_valid_BL_avalon_slave,
      ranger_cpu_data_master_requests_BL_avalon_slave => ranger_cpu_data_master_requests_BL_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave,
      BL_avalon_slave_readdata => BL_avalon_slave_readdata,
      clk => internal_clk100,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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
      d1_BR_avalon_slave_end_xfer => d1_BR_avalon_slave_end_xfer,
      ranger_cpu_data_master_granted_BR_avalon_slave => ranger_cpu_data_master_granted_BR_avalon_slave,
      ranger_cpu_data_master_qualified_request_BR_avalon_slave => ranger_cpu_data_master_qualified_request_BR_avalon_slave,
      ranger_cpu_data_master_read_data_valid_BR_avalon_slave => ranger_cpu_data_master_read_data_valid_BR_avalon_slave,
      ranger_cpu_data_master_requests_BR_avalon_slave => ranger_cpu_data_master_requests_BR_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave,
      BR_avalon_slave_readdata => BR_avalon_slave_readdata,
      clk => internal_clk100,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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
      d1_TL_avalon_slave_end_xfer => d1_TL_avalon_slave_end_xfer,
      ranger_cpu_data_master_granted_TL_avalon_slave => ranger_cpu_data_master_granted_TL_avalon_slave,
      ranger_cpu_data_master_qualified_request_TL_avalon_slave => ranger_cpu_data_master_qualified_request_TL_avalon_slave,
      ranger_cpu_data_master_read_data_valid_TL_avalon_slave => ranger_cpu_data_master_read_data_valid_TL_avalon_slave,
      ranger_cpu_data_master_requests_TL_avalon_slave => ranger_cpu_data_master_requests_TL_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave,
      TL_avalon_slave_readdata => TL_avalon_slave_readdata,
      clk => internal_clk100,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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
      d1_TR_avalon_slave_end_xfer => d1_TR_avalon_slave_end_xfer,
      ranger_cpu_data_master_granted_TR_avalon_slave => ranger_cpu_data_master_granted_TR_avalon_slave,
      ranger_cpu_data_master_qualified_request_TR_avalon_slave => ranger_cpu_data_master_qualified_request_TR_avalon_slave,
      ranger_cpu_data_master_read_data_valid_TR_avalon_slave => ranger_cpu_data_master_read_data_valid_TR_avalon_slave,
      ranger_cpu_data_master_requests_TR_avalon_slave => ranger_cpu_data_master_requests_TR_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave,
      TR_avalon_slave_readdata => TR_avalon_slave_readdata,
      clk => internal_clk100,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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
      d1_control_avalon_slave_end_xfer => d1_control_avalon_slave_end_xfer,
      ranger_cpu_data_master_granted_control_avalon_slave => ranger_cpu_data_master_granted_control_avalon_slave,
      ranger_cpu_data_master_qualified_request_control_avalon_slave => ranger_cpu_data_master_qualified_request_control_avalon_slave,
      ranger_cpu_data_master_read_data_valid_control_avalon_slave => ranger_cpu_data_master_read_data_valid_control_avalon_slave,
      ranger_cpu_data_master_requests_control_avalon_slave => ranger_cpu_data_master_requests_control_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave,
      clk => internal_clk100,
      control_avalon_slave_readdata => control_avalon_slave_readdata,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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


  --the_cpu_clock_0_in, which is an e_instance
  the_cpu_clock_0_in : cpu_clock_0_in_arbitrator
    port map(
      cpu_clock_0_in_address => cpu_clock_0_in_address,
      cpu_clock_0_in_byteenable => cpu_clock_0_in_byteenable,
      cpu_clock_0_in_endofpacket_from_sa => cpu_clock_0_in_endofpacket_from_sa,
      cpu_clock_0_in_nativeaddress => cpu_clock_0_in_nativeaddress,
      cpu_clock_0_in_read => cpu_clock_0_in_read,
      cpu_clock_0_in_readdata_from_sa => cpu_clock_0_in_readdata_from_sa,
      cpu_clock_0_in_reset_n => cpu_clock_0_in_reset_n,
      cpu_clock_0_in_waitrequest_from_sa => cpu_clock_0_in_waitrequest_from_sa,
      cpu_clock_0_in_write => cpu_clock_0_in_write,
      cpu_clock_0_in_writedata => cpu_clock_0_in_writedata,
      d1_cpu_clock_0_in_end_xfer => d1_cpu_clock_0_in_end_xfer,
      ranger_cpu_data_master_granted_cpu_clock_0_in => ranger_cpu_data_master_granted_cpu_clock_0_in,
      ranger_cpu_data_master_qualified_request_cpu_clock_0_in => ranger_cpu_data_master_qualified_request_cpu_clock_0_in,
      ranger_cpu_data_master_read_data_valid_cpu_clock_0_in => ranger_cpu_data_master_read_data_valid_cpu_clock_0_in,
      ranger_cpu_data_master_requests_cpu_clock_0_in => ranger_cpu_data_master_requests_cpu_clock_0_in,
      clk => internal_clk100,
      cpu_clock_0_in_endofpacket => cpu_clock_0_in_endofpacket,
      cpu_clock_0_in_readdata => cpu_clock_0_in_readdata,
      cpu_clock_0_in_waitrequest => cpu_clock_0_in_waitrequest,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_byteenable => ranger_cpu_data_master_byteenable,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
      reset_n => clk100_reset_n
    );


  --the_cpu_clock_0_out, which is an e_instance
  the_cpu_clock_0_out : cpu_clock_0_out_arbitrator
    port map(
      cpu_clock_0_out_address_to_slave => cpu_clock_0_out_address_to_slave,
      cpu_clock_0_out_readdata => cpu_clock_0_out_readdata,
      cpu_clock_0_out_reset_n => cpu_clock_0_out_reset_n,
      cpu_clock_0_out_waitrequest => cpu_clock_0_out_waitrequest,
      clk => clk50,
      cpu_clock_0_out_address => cpu_clock_0_out_address,
      cpu_clock_0_out_granted_pll_s1 => cpu_clock_0_out_granted_pll_s1,
      cpu_clock_0_out_qualified_request_pll_s1 => cpu_clock_0_out_qualified_request_pll_s1,
      cpu_clock_0_out_read => cpu_clock_0_out_read,
      cpu_clock_0_out_read_data_valid_pll_s1 => cpu_clock_0_out_read_data_valid_pll_s1,
      cpu_clock_0_out_requests_pll_s1 => cpu_clock_0_out_requests_pll_s1,
      cpu_clock_0_out_write => cpu_clock_0_out_write,
      cpu_clock_0_out_writedata => cpu_clock_0_out_writedata,
      d1_pll_s1_end_xfer => d1_pll_s1_end_xfer,
      pll_s1_readdata_from_sa => pll_s1_readdata_from_sa,
      reset_n => clk50_reset_n
    );


  --the_cpu_clock_0, which is an e_ptf_instance
  the_cpu_clock_0 : cpu_clock_0
    port map(
      master_address => cpu_clock_0_out_address,
      master_byteenable => cpu_clock_0_out_byteenable,
      master_nativeaddress => cpu_clock_0_out_nativeaddress,
      master_read => cpu_clock_0_out_read,
      master_write => cpu_clock_0_out_write,
      master_writedata => cpu_clock_0_out_writedata,
      slave_endofpacket => cpu_clock_0_in_endofpacket,
      slave_readdata => cpu_clock_0_in_readdata,
      slave_waitrequest => cpu_clock_0_in_waitrequest,
      master_clk => clk50,
      master_endofpacket => cpu_clock_0_out_endofpacket,
      master_readdata => cpu_clock_0_out_readdata,
      master_reset_n => cpu_clock_0_out_reset_n,
      master_waitrequest => cpu_clock_0_out_waitrequest,
      slave_address => cpu_clock_0_in_address,
      slave_byteenable => cpu_clock_0_in_byteenable,
      slave_clk => internal_clk100,
      slave_nativeaddress => cpu_clock_0_in_nativeaddress,
      slave_read => cpu_clock_0_in_read,
      slave_reset_n => cpu_clock_0_in_reset_n,
      slave_write => cpu_clock_0_in_write,
      slave_writedata => cpu_clock_0_in_writedata
    );


  --the_frame_received_s1, which is an e_instance
  the_frame_received_s1 : frame_received_s1_arbitrator
    port map(
      d1_frame_received_s1_end_xfer => d1_frame_received_s1_end_xfer,
      frame_received_s1_address => frame_received_s1_address,
      frame_received_s1_chipselect => frame_received_s1_chipselect,
      frame_received_s1_irq_from_sa => frame_received_s1_irq_from_sa,
      frame_received_s1_readdata_from_sa => frame_received_s1_readdata_from_sa,
      frame_received_s1_reset_n => frame_received_s1_reset_n,
      frame_received_s1_write_n => frame_received_s1_write_n,
      frame_received_s1_writedata => frame_received_s1_writedata,
      ranger_cpu_data_master_granted_frame_received_s1 => ranger_cpu_data_master_granted_frame_received_s1,
      ranger_cpu_data_master_qualified_request_frame_received_s1 => ranger_cpu_data_master_qualified_request_frame_received_s1,
      ranger_cpu_data_master_read_data_valid_frame_received_s1 => ranger_cpu_data_master_read_data_valid_frame_received_s1,
      ranger_cpu_data_master_requests_frame_received_s1 => ranger_cpu_data_master_requests_frame_received_s1,
      clk => internal_clk100,
      frame_received_s1_irq => frame_received_s1_irq,
      frame_received_s1_readdata => frame_received_s1_readdata,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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
      ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      clk => internal_clk100,
      jtag_uart_avalon_jtag_slave_dataavailable => jtag_uart_avalon_jtag_slave_dataavailable,
      jtag_uart_avalon_jtag_slave_irq => jtag_uart_avalon_jtag_slave_irq,
      jtag_uart_avalon_jtag_slave_readdata => jtag_uart_avalon_jtag_slave_readdata,
      jtag_uart_avalon_jtag_slave_readyfordata => jtag_uart_avalon_jtag_slave_readyfordata,
      jtag_uart_avalon_jtag_slave_waitrequest => jtag_uart_avalon_jtag_slave_waitrequest,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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


  --the_onchip_mem_s1, which is an e_instance
  the_onchip_mem_s1 : onchip_mem_s1_arbitrator
    port map(
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      onchip_mem_s1_address => onchip_mem_s1_address,
      onchip_mem_s1_byteenable => onchip_mem_s1_byteenable,
      onchip_mem_s1_chipselect => onchip_mem_s1_chipselect,
      onchip_mem_s1_clken => onchip_mem_s1_clken,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      onchip_mem_s1_write => onchip_mem_s1_write,
      onchip_mem_s1_writedata => onchip_mem_s1_writedata,
      ranger_cpu_data_master_granted_onchip_mem_s1 => ranger_cpu_data_master_granted_onchip_mem_s1,
      ranger_cpu_data_master_qualified_request_onchip_mem_s1 => ranger_cpu_data_master_qualified_request_onchip_mem_s1,
      ranger_cpu_data_master_read_data_valid_onchip_mem_s1 => ranger_cpu_data_master_read_data_valid_onchip_mem_s1,
      ranger_cpu_data_master_requests_onchip_mem_s1 => ranger_cpu_data_master_requests_onchip_mem_s1,
      ranger_cpu_instruction_master_granted_onchip_mem_s1 => ranger_cpu_instruction_master_granted_onchip_mem_s1,
      ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 => ranger_cpu_instruction_master_qualified_request_onchip_mem_s1,
      ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 => ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1,
      ranger_cpu_instruction_master_requests_onchip_mem_s1 => ranger_cpu_instruction_master_requests_onchip_mem_s1,
      registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 => registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1,
      clk => internal_clk100,
      onchip_mem_s1_readdata => onchip_mem_s1_readdata,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_byteenable => ranger_cpu_data_master_byteenable,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
      ranger_cpu_instruction_master_address_to_slave => ranger_cpu_instruction_master_address_to_slave,
      ranger_cpu_instruction_master_latency_counter => ranger_cpu_instruction_master_latency_counter,
      ranger_cpu_instruction_master_read => ranger_cpu_instruction_master_read,
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


  --the_pll_s1, which is an e_instance
  the_pll_s1 : pll_s1_arbitrator
    port map(
      cpu_clock_0_out_granted_pll_s1 => cpu_clock_0_out_granted_pll_s1,
      cpu_clock_0_out_qualified_request_pll_s1 => cpu_clock_0_out_qualified_request_pll_s1,
      cpu_clock_0_out_read_data_valid_pll_s1 => cpu_clock_0_out_read_data_valid_pll_s1,
      cpu_clock_0_out_requests_pll_s1 => cpu_clock_0_out_requests_pll_s1,
      d1_pll_s1_end_xfer => d1_pll_s1_end_xfer,
      pll_s1_address => pll_s1_address,
      pll_s1_chipselect => pll_s1_chipselect,
      pll_s1_read => pll_s1_read,
      pll_s1_readdata_from_sa => pll_s1_readdata_from_sa,
      pll_s1_reset_n => pll_s1_reset_n,
      pll_s1_resetrequest_from_sa => pll_s1_resetrequest_from_sa,
      pll_s1_write => pll_s1_write,
      pll_s1_writedata => pll_s1_writedata,
      clk => clk50,
      cpu_clock_0_out_address_to_slave => cpu_clock_0_out_address_to_slave,
      cpu_clock_0_out_nativeaddress => cpu_clock_0_out_nativeaddress,
      cpu_clock_0_out_read => cpu_clock_0_out_read,
      cpu_clock_0_out_write => cpu_clock_0_out_write,
      cpu_clock_0_out_writedata => cpu_clock_0_out_writedata,
      pll_s1_readdata => pll_s1_readdata,
      pll_s1_resetrequest => pll_s1_resetrequest,
      reset_n => clk50_reset_n
    );


  --clk100 out_clk assignment, which is an e_assign
  internal_clk100 <= out_clk_pll_c0;
  --the_pll, which is an e_ptf_instance
  the_pll : pll
    port map(
      c0 => out_clk_pll_c0,
      readdata => pll_s1_readdata,
      resetrequest => pll_s1_resetrequest,
      address => pll_s1_address,
      chipselect => pll_s1_chipselect,
      clk => clk50,
      read => pll_s1_read,
      reset_n => pll_s1_reset_n,
      write => pll_s1_write,
      writedata => pll_s1_writedata
    );


  --the_ranger_cpu_jtag_debug_module, which is an e_instance
  the_ranger_cpu_jtag_debug_module : ranger_cpu_jtag_debug_module_arbitrator
    port map(
      d1_ranger_cpu_jtag_debug_module_end_xfer => d1_ranger_cpu_jtag_debug_module_end_xfer,
      ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module,
      ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module,
      ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module,
      ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module,
      ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module,
      ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module,
      ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module,
      ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module,
      ranger_cpu_jtag_debug_module_address => ranger_cpu_jtag_debug_module_address,
      ranger_cpu_jtag_debug_module_begintransfer => ranger_cpu_jtag_debug_module_begintransfer,
      ranger_cpu_jtag_debug_module_byteenable => ranger_cpu_jtag_debug_module_byteenable,
      ranger_cpu_jtag_debug_module_chipselect => ranger_cpu_jtag_debug_module_chipselect,
      ranger_cpu_jtag_debug_module_debugaccess => ranger_cpu_jtag_debug_module_debugaccess,
      ranger_cpu_jtag_debug_module_readdata_from_sa => ranger_cpu_jtag_debug_module_readdata_from_sa,
      ranger_cpu_jtag_debug_module_reset => ranger_cpu_jtag_debug_module_reset,
      ranger_cpu_jtag_debug_module_reset_n => ranger_cpu_jtag_debug_module_reset_n,
      ranger_cpu_jtag_debug_module_resetrequest_from_sa => ranger_cpu_jtag_debug_module_resetrequest_from_sa,
      ranger_cpu_jtag_debug_module_write => ranger_cpu_jtag_debug_module_write,
      ranger_cpu_jtag_debug_module_writedata => ranger_cpu_jtag_debug_module_writedata,
      clk => internal_clk100,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_byteenable => ranger_cpu_data_master_byteenable,
      ranger_cpu_data_master_debugaccess => ranger_cpu_data_master_debugaccess,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
      ranger_cpu_instruction_master_address_to_slave => ranger_cpu_instruction_master_address_to_slave,
      ranger_cpu_instruction_master_latency_counter => ranger_cpu_instruction_master_latency_counter,
      ranger_cpu_instruction_master_read => ranger_cpu_instruction_master_read,
      ranger_cpu_jtag_debug_module_readdata => ranger_cpu_jtag_debug_module_readdata,
      ranger_cpu_jtag_debug_module_resetrequest => ranger_cpu_jtag_debug_module_resetrequest,
      reset_n => clk100_reset_n
    );


  --the_ranger_cpu_data_master, which is an e_instance
  the_ranger_cpu_data_master : ranger_cpu_data_master_arbitrator
    port map(
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_irq => ranger_cpu_data_master_irq,
      ranger_cpu_data_master_readdata => ranger_cpu_data_master_readdata,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      BL_avalon_slave_readdata_from_sa => BL_avalon_slave_readdata_from_sa,
      BR_avalon_slave_readdata_from_sa => BR_avalon_slave_readdata_from_sa,
      TL_avalon_slave_readdata_from_sa => TL_avalon_slave_readdata_from_sa,
      TR_avalon_slave_readdata_from_sa => TR_avalon_slave_readdata_from_sa,
      clk => internal_clk100,
      control_avalon_slave_readdata_from_sa => control_avalon_slave_readdata_from_sa,
      cpu_clock_0_in_readdata_from_sa => cpu_clock_0_in_readdata_from_sa,
      cpu_clock_0_in_waitrequest_from_sa => cpu_clock_0_in_waitrequest_from_sa,
      d1_BL_avalon_slave_end_xfer => d1_BL_avalon_slave_end_xfer,
      d1_BR_avalon_slave_end_xfer => d1_BR_avalon_slave_end_xfer,
      d1_TL_avalon_slave_end_xfer => d1_TL_avalon_slave_end_xfer,
      d1_TR_avalon_slave_end_xfer => d1_TR_avalon_slave_end_xfer,
      d1_control_avalon_slave_end_xfer => d1_control_avalon_slave_end_xfer,
      d1_cpu_clock_0_in_end_xfer => d1_cpu_clock_0_in_end_xfer,
      d1_frame_received_s1_end_xfer => d1_frame_received_s1_end_xfer,
      d1_jtag_uart_avalon_jtag_slave_end_xfer => d1_jtag_uart_avalon_jtag_slave_end_xfer,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      d1_ranger_cpu_jtag_debug_module_end_xfer => d1_ranger_cpu_jtag_debug_module_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      d1_timer_1ms_s1_end_xfer => d1_timer_1ms_s1_end_xfer,
      frame_received_s1_irq_from_sa => frame_received_s1_irq_from_sa,
      frame_received_s1_readdata_from_sa => frame_received_s1_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_irq_from_sa => jtag_uart_avalon_jtag_slave_irq_from_sa,
      jtag_uart_avalon_jtag_slave_readdata_from_sa => jtag_uart_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      ranger_cpu_data_master_address => ranger_cpu_data_master_address,
      ranger_cpu_data_master_granted_BL_avalon_slave => ranger_cpu_data_master_granted_BL_avalon_slave,
      ranger_cpu_data_master_granted_BR_avalon_slave => ranger_cpu_data_master_granted_BR_avalon_slave,
      ranger_cpu_data_master_granted_TL_avalon_slave => ranger_cpu_data_master_granted_TL_avalon_slave,
      ranger_cpu_data_master_granted_TR_avalon_slave => ranger_cpu_data_master_granted_TR_avalon_slave,
      ranger_cpu_data_master_granted_control_avalon_slave => ranger_cpu_data_master_granted_control_avalon_slave,
      ranger_cpu_data_master_granted_cpu_clock_0_in => ranger_cpu_data_master_granted_cpu_clock_0_in,
      ranger_cpu_data_master_granted_frame_received_s1 => ranger_cpu_data_master_granted_frame_received_s1,
      ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      ranger_cpu_data_master_granted_onchip_mem_s1 => ranger_cpu_data_master_granted_onchip_mem_s1,
      ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_granted_ranger_cpu_jtag_debug_module,
      ranger_cpu_data_master_granted_sysid_control_slave => ranger_cpu_data_master_granted_sysid_control_slave,
      ranger_cpu_data_master_granted_timer_1ms_s1 => ranger_cpu_data_master_granted_timer_1ms_s1,
      ranger_cpu_data_master_qualified_request_BL_avalon_slave => ranger_cpu_data_master_qualified_request_BL_avalon_slave,
      ranger_cpu_data_master_qualified_request_BR_avalon_slave => ranger_cpu_data_master_qualified_request_BR_avalon_slave,
      ranger_cpu_data_master_qualified_request_TL_avalon_slave => ranger_cpu_data_master_qualified_request_TL_avalon_slave,
      ranger_cpu_data_master_qualified_request_TR_avalon_slave => ranger_cpu_data_master_qualified_request_TR_avalon_slave,
      ranger_cpu_data_master_qualified_request_control_avalon_slave => ranger_cpu_data_master_qualified_request_control_avalon_slave,
      ranger_cpu_data_master_qualified_request_cpu_clock_0_in => ranger_cpu_data_master_qualified_request_cpu_clock_0_in,
      ranger_cpu_data_master_qualified_request_frame_received_s1 => ranger_cpu_data_master_qualified_request_frame_received_s1,
      ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      ranger_cpu_data_master_qualified_request_onchip_mem_s1 => ranger_cpu_data_master_qualified_request_onchip_mem_s1,
      ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_qualified_request_ranger_cpu_jtag_debug_module,
      ranger_cpu_data_master_qualified_request_sysid_control_slave => ranger_cpu_data_master_qualified_request_sysid_control_slave,
      ranger_cpu_data_master_qualified_request_timer_1ms_s1 => ranger_cpu_data_master_qualified_request_timer_1ms_s1,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_read_data_valid_BL_avalon_slave => ranger_cpu_data_master_read_data_valid_BL_avalon_slave,
      ranger_cpu_data_master_read_data_valid_BR_avalon_slave => ranger_cpu_data_master_read_data_valid_BR_avalon_slave,
      ranger_cpu_data_master_read_data_valid_TL_avalon_slave => ranger_cpu_data_master_read_data_valid_TL_avalon_slave,
      ranger_cpu_data_master_read_data_valid_TR_avalon_slave => ranger_cpu_data_master_read_data_valid_TR_avalon_slave,
      ranger_cpu_data_master_read_data_valid_control_avalon_slave => ranger_cpu_data_master_read_data_valid_control_avalon_slave,
      ranger_cpu_data_master_read_data_valid_cpu_clock_0_in => ranger_cpu_data_master_read_data_valid_cpu_clock_0_in,
      ranger_cpu_data_master_read_data_valid_frame_received_s1 => ranger_cpu_data_master_read_data_valid_frame_received_s1,
      ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      ranger_cpu_data_master_read_data_valid_onchip_mem_s1 => ranger_cpu_data_master_read_data_valid_onchip_mem_s1,
      ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_read_data_valid_ranger_cpu_jtag_debug_module,
      ranger_cpu_data_master_read_data_valid_sysid_control_slave => ranger_cpu_data_master_read_data_valid_sysid_control_slave,
      ranger_cpu_data_master_read_data_valid_timer_1ms_s1 => ranger_cpu_data_master_read_data_valid_timer_1ms_s1,
      ranger_cpu_data_master_requests_BL_avalon_slave => ranger_cpu_data_master_requests_BL_avalon_slave,
      ranger_cpu_data_master_requests_BR_avalon_slave => ranger_cpu_data_master_requests_BR_avalon_slave,
      ranger_cpu_data_master_requests_TL_avalon_slave => ranger_cpu_data_master_requests_TL_avalon_slave,
      ranger_cpu_data_master_requests_TR_avalon_slave => ranger_cpu_data_master_requests_TR_avalon_slave,
      ranger_cpu_data_master_requests_control_avalon_slave => ranger_cpu_data_master_requests_control_avalon_slave,
      ranger_cpu_data_master_requests_cpu_clock_0_in => ranger_cpu_data_master_requests_cpu_clock_0_in,
      ranger_cpu_data_master_requests_frame_received_s1 => ranger_cpu_data_master_requests_frame_received_s1,
      ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave => ranger_cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      ranger_cpu_data_master_requests_onchip_mem_s1 => ranger_cpu_data_master_requests_onchip_mem_s1,
      ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module => ranger_cpu_data_master_requests_ranger_cpu_jtag_debug_module,
      ranger_cpu_data_master_requests_sysid_control_slave => ranger_cpu_data_master_requests_sysid_control_slave,
      ranger_cpu_data_master_requests_timer_1ms_s1 => ranger_cpu_data_master_requests_timer_1ms_s1,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_jtag_debug_module_readdata_from_sa => ranger_cpu_jtag_debug_module_readdata_from_sa,
      registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_BL_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_BR_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_TL_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_TR_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave => registered_ranger_cpu_data_master_read_data_valid_control_avalon_slave,
      registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1 => registered_ranger_cpu_data_master_read_data_valid_onchip_mem_s1,
      reset_n => clk100_reset_n,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      timer_1ms_s1_irq_from_sa => timer_1ms_s1_irq_from_sa,
      timer_1ms_s1_readdata_from_sa => timer_1ms_s1_readdata_from_sa
    );


  --the_ranger_cpu_instruction_master, which is an e_instance
  the_ranger_cpu_instruction_master : ranger_cpu_instruction_master_arbitrator
    port map(
      ranger_cpu_instruction_master_address_to_slave => ranger_cpu_instruction_master_address_to_slave,
      ranger_cpu_instruction_master_latency_counter => ranger_cpu_instruction_master_latency_counter,
      ranger_cpu_instruction_master_readdata => ranger_cpu_instruction_master_readdata,
      ranger_cpu_instruction_master_readdatavalid => ranger_cpu_instruction_master_readdatavalid,
      ranger_cpu_instruction_master_waitrequest => ranger_cpu_instruction_master_waitrequest,
      clk => internal_clk100,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      d1_ranger_cpu_jtag_debug_module_end_xfer => d1_ranger_cpu_jtag_debug_module_end_xfer,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      ranger_cpu_instruction_master_address => ranger_cpu_instruction_master_address,
      ranger_cpu_instruction_master_granted_onchip_mem_s1 => ranger_cpu_instruction_master_granted_onchip_mem_s1,
      ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_granted_ranger_cpu_jtag_debug_module,
      ranger_cpu_instruction_master_qualified_request_onchip_mem_s1 => ranger_cpu_instruction_master_qualified_request_onchip_mem_s1,
      ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_qualified_request_ranger_cpu_jtag_debug_module,
      ranger_cpu_instruction_master_read => ranger_cpu_instruction_master_read,
      ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1 => ranger_cpu_instruction_master_read_data_valid_onchip_mem_s1,
      ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_read_data_valid_ranger_cpu_jtag_debug_module,
      ranger_cpu_instruction_master_requests_onchip_mem_s1 => ranger_cpu_instruction_master_requests_onchip_mem_s1,
      ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module => ranger_cpu_instruction_master_requests_ranger_cpu_jtag_debug_module,
      ranger_cpu_jtag_debug_module_readdata_from_sa => ranger_cpu_jtag_debug_module_readdata_from_sa,
      reset_n => clk100_reset_n
    );


  --the_ranger_cpu, which is an e_ptf_instance
  the_ranger_cpu : ranger_cpu
    port map(
      d_address => ranger_cpu_data_master_address,
      d_byteenable => ranger_cpu_data_master_byteenable,
      d_read => ranger_cpu_data_master_read,
      d_write => ranger_cpu_data_master_write,
      d_writedata => ranger_cpu_data_master_writedata,
      i_address => ranger_cpu_instruction_master_address,
      i_read => ranger_cpu_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => ranger_cpu_data_master_debugaccess,
      jtag_debug_module_readdata => ranger_cpu_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => ranger_cpu_jtag_debug_module_resetrequest,
      clk => internal_clk100,
      d_irq => ranger_cpu_data_master_irq,
      d_readdata => ranger_cpu_data_master_readdata,
      d_waitrequest => ranger_cpu_data_master_waitrequest,
      i_readdata => ranger_cpu_instruction_master_readdata,
      i_readdatavalid => ranger_cpu_instruction_master_readdatavalid,
      i_waitrequest => ranger_cpu_instruction_master_waitrequest,
      jtag_debug_module_address => ranger_cpu_jtag_debug_module_address,
      jtag_debug_module_begintransfer => ranger_cpu_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => ranger_cpu_jtag_debug_module_byteenable,
      jtag_debug_module_clk => internal_clk100,
      jtag_debug_module_debugaccess => ranger_cpu_jtag_debug_module_debugaccess,
      jtag_debug_module_reset => ranger_cpu_jtag_debug_module_reset,
      jtag_debug_module_select => ranger_cpu_jtag_debug_module_chipselect,
      jtag_debug_module_write => ranger_cpu_jtag_debug_module_write,
      jtag_debug_module_writedata => ranger_cpu_jtag_debug_module_writedata,
      reset_n => ranger_cpu_jtag_debug_module_reset_n
    );


  --the_sysid_control_slave, which is an e_instance
  the_sysid_control_slave : sysid_control_slave_arbitrator
    port map(
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      ranger_cpu_data_master_granted_sysid_control_slave => ranger_cpu_data_master_granted_sysid_control_slave,
      ranger_cpu_data_master_qualified_request_sysid_control_slave => ranger_cpu_data_master_qualified_request_sysid_control_slave,
      ranger_cpu_data_master_read_data_valid_sysid_control_slave => ranger_cpu_data_master_read_data_valid_sysid_control_slave,
      ranger_cpu_data_master_requests_sysid_control_slave => ranger_cpu_data_master_requests_sysid_control_slave,
      sysid_control_slave_address => sysid_control_slave_address,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      clk => internal_clk100,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
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
      d1_timer_1ms_s1_end_xfer => d1_timer_1ms_s1_end_xfer,
      ranger_cpu_data_master_granted_timer_1ms_s1 => ranger_cpu_data_master_granted_timer_1ms_s1,
      ranger_cpu_data_master_qualified_request_timer_1ms_s1 => ranger_cpu_data_master_qualified_request_timer_1ms_s1,
      ranger_cpu_data_master_read_data_valid_timer_1ms_s1 => ranger_cpu_data_master_read_data_valid_timer_1ms_s1,
      ranger_cpu_data_master_requests_timer_1ms_s1 => ranger_cpu_data_master_requests_timer_1ms_s1,
      timer_1ms_s1_address => timer_1ms_s1_address,
      timer_1ms_s1_chipselect => timer_1ms_s1_chipselect,
      timer_1ms_s1_irq_from_sa => timer_1ms_s1_irq_from_sa,
      timer_1ms_s1_readdata_from_sa => timer_1ms_s1_readdata_from_sa,
      timer_1ms_s1_reset_n => timer_1ms_s1_reset_n,
      timer_1ms_s1_write_n => timer_1ms_s1_write_n,
      timer_1ms_s1_writedata => timer_1ms_s1_writedata,
      clk => internal_clk100,
      ranger_cpu_data_master_address_to_slave => ranger_cpu_data_master_address_to_slave,
      ranger_cpu_data_master_read => ranger_cpu_data_master_read,
      ranger_cpu_data_master_waitrequest => ranger_cpu_data_master_waitrequest,
      ranger_cpu_data_master_write => ranger_cpu_data_master_write,
      ranger_cpu_data_master_writedata => ranger_cpu_data_master_writedata,
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
  cpu_reset_clk100_domain_synch : cpu_reset_clk100_domain_synch_module
    port map(
      data_out => clk100_reset_n,
      clk => internal_clk100,
      data_in => module_input,
      reset_n => reset_n_sources
    );

  module_input <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT ((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pll_s1_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pll_s1_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ranger_cpu_jtag_debug_module_resetrequest_from_sa))))));
  --reset is asserted asynchronously and deasserted synchronously
  cpu_reset_clk50_domain_synch : cpu_reset_clk50_domain_synch_module
    port map(
      data_out => clk50_reset_n,
      clk => clk50,
      data_in => module_input1,
      reset_n => reset_n_sources
    );

  module_input1 <= std_logic'('1');

  --cpu_clock_0_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  cpu_clock_0_out_endofpacket <= std_logic'('0');
  --vhdl renameroo for output signals
  clk100 <= internal_clk100;
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
component cpu is 
           port (
                 -- 1) global signals:
                    signal clk100 : OUT STD_LOGIC;
                    signal clk50 : IN STD_LOGIC;
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

                 -- the_frame_received
                    signal in_port_to_the_frame_received : IN STD_LOGIC
                 );
end component cpu;

                signal clk :  STD_LOGIC;
                signal clk100 :  STD_LOGIC;
                signal clk50 :  STD_LOGIC;
                signal cpu_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal cpu_clock_0_out_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_clock_0_out_endofpacket :  STD_LOGIC;
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
                signal in_port_to_the_frame_received :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal reset_n :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : cpu
    port map(
      clk100 => clk100,
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
      clk50 => clk50,
      ex_dout_to_the_BL => ex_dout_to_the_BL,
      ex_dout_to_the_BR => ex_dout_to_the_BR,
      ex_dout_to_the_TL => ex_dout_to_the_TL,
      ex_dout_to_the_TR => ex_dout_to_the_TR,
      ex_dout_to_the_control => ex_dout_to_the_control,
      in_port_to_the_frame_received => in_port_to_the_frame_received,
      reset_n => reset_n
    );


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
       wait for 200 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
