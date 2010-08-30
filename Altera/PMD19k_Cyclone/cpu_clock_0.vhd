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

entity cpu_clock_0_edge_to_pulse is 
        port (
              -- inputs:
                 signal clock : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity cpu_clock_0_edge_to_pulse;


architecture europa of cpu_clock_0_edge_to_pulse is
                signal data_in_d1 :  STD_LOGIC;

begin

  process (clock, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clock'event and clock = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  data_out <= data_in XOR data_in_d1;

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

entity cpu_clock_0_slave_FSM is 
        port (
              -- inputs:
                 signal master_read_done_token : IN STD_LOGIC;
                 signal master_write_done_token : IN STD_LOGIC;
                 signal slave_clk : IN STD_LOGIC;
                 signal slave_read : IN STD_LOGIC;
                 signal slave_reset_n : IN STD_LOGIC;
                 signal slave_write : IN STD_LOGIC;

              -- outputs:
                 signal slave_read_request : OUT STD_LOGIC;
                 signal slave_waitrequest : OUT STD_LOGIC;
                 signal slave_write_request : OUT STD_LOGIC
              );
end entity cpu_clock_0_slave_FSM;


architecture europa of cpu_clock_0_slave_FSM is
                signal internal_slave_read_request :  STD_LOGIC;
                signal internal_slave_write_request :  STD_LOGIC;
                signal next_slave_read_request :  STD_LOGIC;
                signal next_slave_state :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal next_slave_write_request :  STD_LOGIC;
                signal slave_state :  STD_LOGIC_VECTOR (2 DOWNTO 0);

begin

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      internal_slave_read_request <= std_logic'('0');
    elsif slave_clk'event and slave_clk = '1' then
      if true then 
        internal_slave_read_request <= next_slave_read_request;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      internal_slave_write_request <= std_logic'('0');
    elsif slave_clk'event and slave_clk = '1' then
      if true then 
        internal_slave_write_request <= next_slave_write_request;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      slave_state <= std_logic_vector'("001");
    elsif slave_clk'event and slave_clk = '1' then
      if true then 
        slave_state <= next_slave_state;
      end if;
    end if;

  end process;

  process (internal_slave_read_request, internal_slave_write_request, master_read_done_token, master_write_done_token, slave_read, slave_state, slave_write)
  begin
      case slave_state is -- synthesis parallel_case
          when std_logic_vector'("001") => 
              --read request: go from IDLE state to READ_WAIT state
              if std_logic'(slave_read) = '1' then 
                next_slave_state <= std_logic_vector'("010");
                slave_waitrequest <= std_logic'('1');
                next_slave_read_request <= NOT(internal_slave_read_request);
                next_slave_write_request <= internal_slave_write_request;
              elsif std_logic'(slave_write) = '1' then 
                next_slave_state <= std_logic_vector'("100");
                slave_waitrequest <= std_logic'('1');
                next_slave_read_request <= internal_slave_read_request;
                next_slave_write_request <= NOT(internal_slave_write_request);
              else
                next_slave_state <= slave_state;
                slave_waitrequest <= std_logic'('0');
                next_slave_read_request <= internal_slave_read_request;
                next_slave_write_request <= internal_slave_write_request;
              end if;
          -- when std_logic_vector'("001") 
      
          when std_logic_vector'("010") => 
              --stay in READ_WAIT state until master passes read done token
              if std_logic'(master_read_done_token) = '1' then 
                next_slave_state <= std_logic_vector'("001");
                slave_waitrequest <= std_logic'('0');
              else
                next_slave_state <= std_logic_vector'("010");
                slave_waitrequest <= std_logic'('1');
              end if;
              next_slave_read_request <= internal_slave_read_request;
              next_slave_write_request <= internal_slave_write_request;
          -- when std_logic_vector'("010") 
      
          when std_logic_vector'("100") => 
              --stay in WRITE_WAIT state until master passes write done token
              if std_logic'(master_write_done_token) = '1' then 
                next_slave_state <= std_logic_vector'("001");
                slave_waitrequest <= std_logic'('0');
              else
                next_slave_state <= std_logic_vector'("100");
                slave_waitrequest <= std_logic'('1');
              end if;
              next_slave_read_request <= internal_slave_read_request;
              next_slave_write_request <= internal_slave_write_request;
          -- when std_logic_vector'("100") 
      
          when others => 
              next_slave_state <= std_logic_vector'("001");
              slave_waitrequest <= std_logic'('0');
              next_slave_read_request <= internal_slave_read_request;
              next_slave_write_request <= internal_slave_write_request;
          -- when others 
      
      end case; -- slave_state

  end process;

  --vhdl renameroo for output signals
  slave_read_request <= internal_slave_read_request;
  --vhdl renameroo for output signals
  slave_write_request <= internal_slave_write_request;

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

entity cpu_clock_0_master_FSM is 
        port (
              -- inputs:
                 signal master_clk : IN STD_LOGIC;
                 signal master_reset_n : IN STD_LOGIC;
                 signal master_waitrequest : IN STD_LOGIC;
                 signal slave_read_request_token : IN STD_LOGIC;
                 signal slave_write_request_token : IN STD_LOGIC;

              -- outputs:
                 signal master_read : OUT STD_LOGIC;
                 signal master_read_done : OUT STD_LOGIC;
                 signal master_write : OUT STD_LOGIC;
                 signal master_write_done : OUT STD_LOGIC
              );
end entity cpu_clock_0_master_FSM;


architecture europa of cpu_clock_0_master_FSM is
                signal internal_master_read1 :  STD_LOGIC;
                signal internal_master_read_done :  STD_LOGIC;
                signal internal_master_write1 :  STD_LOGIC;
                signal internal_master_write_done :  STD_LOGIC;
                signal master_state :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal next_master_read :  STD_LOGIC;
                signal next_master_read_done :  STD_LOGIC;
                signal next_master_state :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal next_master_write :  STD_LOGIC;
                signal next_master_write_done :  STD_LOGIC;

begin

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      internal_master_read_done <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if true then 
        internal_master_read_done <= next_master_read_done;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      internal_master_write_done <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if true then 
        internal_master_write_done <= next_master_write_done;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      internal_master_read1 <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if true then 
        internal_master_read1 <= next_master_read;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      internal_master_write1 <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if true then 
        internal_master_write1 <= next_master_write;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      master_state <= std_logic_vector'("001");
    elsif master_clk'event and master_clk = '1' then
      if true then 
        master_state <= next_master_state;
      end if;
    end if;

  end process;

  process (internal_master_read1, internal_master_read_done, internal_master_write1, internal_master_write_done, master_state, master_waitrequest, slave_read_request_token, slave_write_request_token)
  begin
      case master_state is -- synthesis parallel_case
          when std_logic_vector'("001") => 
              --if read request token from slave then goto READ_WAIT state
              if std_logic'(slave_read_request_token) = '1' then 
                next_master_state <= std_logic_vector'("010");
                next_master_read <= std_logic'('1');
                next_master_write <= std_logic'('0');
              elsif std_logic'(slave_write_request_token) = '1' then 
                next_master_state <= std_logic_vector'("100");
                next_master_read <= std_logic'('0');
                next_master_write <= std_logic'('1');
              else
                next_master_state <= master_state;
                next_master_read <= std_logic'('0');
                next_master_write <= std_logic'('0');
              end if;
              next_master_read_done <= internal_master_read_done;
              next_master_write_done <= internal_master_write_done;
          -- when std_logic_vector'("001") 
      
          when std_logic_vector'("010") => 
              --stay in READ_WAIT state until master wait is deasserted
              if std_logic'(NOT(master_waitrequest)) = '1' then 
                next_master_state <= std_logic_vector'("001");
                next_master_read_done <= NOT(internal_master_read_done);
                next_master_read <= std_logic'('0');
              else
                next_master_state <= std_logic_vector'("010");
                next_master_read_done <= internal_master_read_done;
                next_master_read <= internal_master_read1;
              end if;
              next_master_write_done <= internal_master_write_done;
              next_master_write <= std_logic'('0');
          -- when std_logic_vector'("010") 
      
          when std_logic_vector'("100") => 
              --stay in WRITE_WAIT state until slave wait is deasserted
              if std_logic'(NOT(master_waitrequest)) = '1' then 
                next_master_state <= std_logic_vector'("001");
                next_master_write <= std_logic'('0');
                next_master_write_done <= NOT(internal_master_write_done);
              else
                next_master_state <= std_logic_vector'("100");
                next_master_write <= internal_master_write1;
                next_master_write_done <= internal_master_write_done;
              end if;
              next_master_read_done <= internal_master_read_done;
              next_master_read <= std_logic'('0');
          -- when std_logic_vector'("100") 
      
          when others => 
              next_master_state <= std_logic_vector'("001");
              next_master_write <= std_logic'('0');
              next_master_write_done <= internal_master_write_done;
              next_master_read <= std_logic'('0');
              next_master_read_done <= internal_master_read_done;
          -- when others 
      
      end case; -- master_state

  end process;

  --vhdl renameroo for output signals
  master_read <= internal_master_read1;
  --vhdl renameroo for output signals
  master_read_done <= internal_master_read_done;
  --vhdl renameroo for output signals
  master_write <= internal_master_write1;
  --vhdl renameroo for output signals
  master_write_done <= internal_master_write_done;

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

entity cpu_clock_0_bit_pipe is 
        port (
              -- inputs:
                 signal clk1 : IN STD_LOGIC;
                 signal clk2 : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_clk1_n : IN STD_LOGIC;
                 signal reset_clk2_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity cpu_clock_0_bit_pipe;


architecture europa of cpu_clock_0_bit_pipe is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-to ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON";

begin

  process (clk1, reset_clk1_n)
  begin
    if reset_clk1_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk1'event and clk1 = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  process (clk2, reset_clk2_n)
  begin
    if reset_clk2_n = '0' then
      data_out <= std_logic'('0');
    elsif clk2'event and clk2 = '1' then
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

--Clock Domain Crossing Adaptercpu_clock_0


entity cpu_clock_0 is 
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
end entity cpu_clock_0;


architecture europa of cpu_clock_0 is
component cpu_clock_0_edge_to_pulse is 
           port (
                 -- inputs:
                    signal clock : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component cpu_clock_0_edge_to_pulse;

component cpu_clock_0_slave_FSM is 
           port (
                 -- inputs:
                    signal master_read_done_token : IN STD_LOGIC;
                    signal master_write_done_token : IN STD_LOGIC;
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;

                 -- outputs:
                    signal slave_read_request : OUT STD_LOGIC;
                    signal slave_waitrequest : OUT STD_LOGIC;
                    signal slave_write_request : OUT STD_LOGIC
                 );
end component cpu_clock_0_slave_FSM;

component cpu_clock_0_master_FSM is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_read_request_token : IN STD_LOGIC;
                    signal slave_write_request_token : IN STD_LOGIC;

                 -- outputs:
                    signal master_read : OUT STD_LOGIC;
                    signal master_read_done : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_write_done : OUT STD_LOGIC
                 );
end component cpu_clock_0_master_FSM;

component cpu_clock_0_bit_pipe is 
           port (
                 -- inputs:
                    signal clk1 : IN STD_LOGIC;
                    signal clk2 : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_clk1_n : IN STD_LOGIC;
                    signal reset_clk2_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component cpu_clock_0_bit_pipe;

                signal internal_master_read :  STD_LOGIC;
                signal internal_master_write :  STD_LOGIC;
                signal internal_slave_endofpacket :  STD_LOGIC;
                signal internal_slave_waitrequest :  STD_LOGIC;
                signal master_read_done :  STD_LOGIC;
                signal master_read_done_sync :  STD_LOGIC;
                signal master_read_done_token :  STD_LOGIC;
                signal master_write_done :  STD_LOGIC;
                signal master_write_done_sync :  STD_LOGIC;
                signal master_write_done_token :  STD_LOGIC;
                signal slave_address_d1 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal slave_byteenable_d1 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal slave_nativeaddress_d1 :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal slave_read_request :  STD_LOGIC;
                signal slave_read_request_sync :  STD_LOGIC;
                signal slave_read_request_token :  STD_LOGIC;
                signal slave_readdata_p1 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal slave_write_request :  STD_LOGIC;
                signal slave_write_request_sync :  STD_LOGIC;
                signal slave_write_request_token :  STD_LOGIC;
                signal slave_writedata_d1 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal unxmaster_read_donexx0 :  STD_LOGIC;
                signal unxmaster_write_donexx1 :  STD_LOGIC;
                signal unxslave_read_requestxx2 :  STD_LOGIC;
                signal unxslave_write_requestxx3 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of master_address : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of master_byteenable : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of master_nativeaddress : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of master_read_done_sync : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of master_write_done_sync : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of master_writedata : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of slave_address_d1 : signal is "{-to ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of slave_byteenable_d1 : signal is "{-to ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of slave_nativeaddress_d1 : signal is "{-to ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of slave_read_request_sync : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of slave_readdata : signal is "{-from ""*""} CUT=ON";
attribute ALTERA_ATTRIBUTE of slave_write_request_sync : signal is "PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of slave_writedata_d1 : signal is "{-to ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of unxmaster_read_donexx0 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of unxmaster_write_donexx1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of unxslave_read_requestxx2 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of unxslave_write_requestxx3 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";

begin

  --in, which is an e_avalon_slave
  --out, which is an e_avalon_master
  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      unxmaster_read_donexx0 <= std_logic'('0');
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        unxmaster_read_donexx0 <= master_read_done;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      master_read_done_sync <= std_logic'('0');
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        master_read_done_sync <= unxmaster_read_donexx0;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      unxmaster_write_donexx1 <= std_logic'('0');
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        unxmaster_write_donexx1 <= master_write_done;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      master_write_done_sync <= std_logic'('0');
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        master_write_done_sync <= unxmaster_write_donexx1;
      end if;
    end if;

  end process;

  --read_done_edge_to_pulse, which is an e_instance
  read_done_edge_to_pulse : cpu_clock_0_edge_to_pulse
    port map(
      data_out => master_read_done_token,
      clock => slave_clk,
      data_in => master_read_done_sync,
      reset_n => slave_reset_n
    );


  --write_done_edge_to_pulse, which is an e_instance
  write_done_edge_to_pulse : cpu_clock_0_edge_to_pulse
    port map(
      data_out => master_write_done_token,
      clock => slave_clk,
      data_in => master_write_done_sync,
      reset_n => slave_reset_n
    );


  --slave_FSM, which is an e_instance
  slave_FSM : cpu_clock_0_slave_FSM
    port map(
      slave_read_request => slave_read_request,
      slave_waitrequest => internal_slave_waitrequest,
      slave_write_request => slave_write_request,
      master_read_done_token => master_read_done_token,
      master_write_done_token => master_write_done_token,
      slave_clk => slave_clk,
      slave_read => slave_read,
      slave_reset_n => slave_reset_n,
      slave_write => slave_write
    );


  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      unxslave_read_requestxx2 <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        unxslave_read_requestxx2 <= slave_read_request;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      slave_read_request_sync <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        slave_read_request_sync <= unxslave_read_requestxx2;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      unxslave_write_requestxx3 <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        unxslave_write_requestxx3 <= slave_write_request;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      slave_write_request_sync <= std_logic'('0');
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        slave_write_request_sync <= unxslave_write_requestxx3;
      end if;
    end if;

  end process;

  --read_request_edge_to_pulse, which is an e_instance
  read_request_edge_to_pulse : cpu_clock_0_edge_to_pulse
    port map(
      data_out => slave_read_request_token,
      clock => master_clk,
      data_in => slave_read_request_sync,
      reset_n => master_reset_n
    );


  --write_request_edge_to_pulse, which is an e_instance
  write_request_edge_to_pulse : cpu_clock_0_edge_to_pulse
    port map(
      data_out => slave_write_request_token,
      clock => master_clk,
      data_in => slave_write_request_sync,
      reset_n => master_reset_n
    );


  --master_FSM, which is an e_instance
  master_FSM : cpu_clock_0_master_FSM
    port map(
      master_read => internal_master_read,
      master_read_done => master_read_done,
      master_write => internal_master_write,
      master_write_done => master_write_done,
      master_clk => master_clk,
      master_reset_n => master_reset_n,
      master_waitrequest => master_waitrequest,
      slave_read_request_token => slave_read_request_token,
      slave_write_request_token => slave_write_request_token
    );


  --endofpacket_bit_pipe, which is an e_instance
  endofpacket_bit_pipe : cpu_clock_0_bit_pipe
    port map(
      data_out => internal_slave_endofpacket,
      clk1 => slave_clk,
      clk2 => master_clk,
      data_in => master_endofpacket,
      reset_clk1_n => slave_reset_n,
      reset_clk2_n => master_reset_n
    );


  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      slave_readdata_p1 <= std_logic_vector'("0000000000000000");
    elsif master_clk'event and master_clk = '1' then
      if std_logic'((internal_master_read AND NOT master_waitrequest)) = '1' then 
        slave_readdata_p1 <= master_readdata;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      slave_readdata <= std_logic_vector'("0000000000000000");
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        slave_readdata <= slave_readdata_p1;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      slave_writedata_d1 <= std_logic_vector'("0000000000000000");
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        slave_writedata_d1 <= slave_writedata;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      master_writedata <= std_logic_vector'("0000000000000000");
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        master_writedata <= slave_writedata_d1;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      slave_address_d1 <= std_logic_vector'("0000");
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        slave_address_d1 <= slave_address;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      master_address <= std_logic_vector'("0000");
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        master_address <= slave_address_d1;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      slave_nativeaddress_d1 <= std_logic_vector'("000");
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        slave_nativeaddress_d1 <= slave_nativeaddress;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      master_nativeaddress <= std_logic_vector'("000");
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        master_nativeaddress <= slave_nativeaddress_d1;
      end if;
    end if;

  end process;

  process (slave_clk, slave_reset_n)
  begin
    if slave_reset_n = '0' then
      slave_byteenable_d1 <= std_logic_vector'("00");
    elsif slave_clk'event and slave_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        slave_byteenable_d1 <= slave_byteenable;
      end if;
    end if;

  end process;

  process (master_clk, master_reset_n)
  begin
    if master_reset_n = '0' then
      master_byteenable <= std_logic_vector'("00");
    elsif master_clk'event and master_clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        master_byteenable <= slave_byteenable_d1;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  master_read <= internal_master_read;
  --vhdl renameroo for output signals
  master_write <= internal_master_write;
  --vhdl renameroo for output signals
  slave_endofpacket <= internal_slave_endofpacket;
  --vhdl renameroo for output signals
  slave_waitrequest <= internal_slave_waitrequest;

end europa;

