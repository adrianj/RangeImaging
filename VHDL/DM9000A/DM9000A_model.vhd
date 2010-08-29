-- VHDL Model for DM9000A Ethernet Controller


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DM9000A_model is
  
  port (
    clk     : in std_logic;
    reset_n : in std_logic;             -- async reset

    -- Connections to DM9000A IC
    DM_IOR_n : in    std_logic;
    DM_IOW_n : in    std_logic;
    DM_CS_n  : in    std_logic;
    DM_CMD   : in    std_logic;
    DM_INT   : out   std_logic;
    DM_SD    : inout std_logic_vector(15 downto 0)
    );

end DM9000A_model;

architecture rtl of DM9000A_model is

  signal tri         : std_logic                     := '0';
  signal din         : std_logic_vector(15 downto 0) := (others => '0');
  signal dout        : std_logic_vector(15 downto 0) := (others => '0');
  signal addr        : std_logic_vector(15 downto 0)  := (others => '0');
  signal dm_ready    : std_logic                     := '0';	  
  signal tx_done1 : std_logic := '0';
  signal tx_done2 : std_logic := '0';
  signal ready_count : std_logic_vector(7 downto 0)  := (others => '0');  	 
  																	   
  signal tx_packet_length : std_logic_vector(15 downto 0) := (others => '0');																	   
  signal tx_counter : std_logic_vector(15 downto 0) := (others => '0');		 
  signal tx_inprogress : std_logic := '0';
  
begin  -- rtl

  DM_SD <= dout when tri = '0' else (others => 'Z');

  RDY_DELAY : process (clk, reset_n)
  begin  -- process RDY_DELAY
    if reset_n = '0' then               -- asynchronous reset (active low)
      ready_count <= (others => '0');
      dm_ready    <= '0';
    elsif falling_edge(clk) then         -- rising clock edge
      ready_count <= ready_count + 1;
      if ready_count = X"FF" then
        dm_ready <= '1';
      end if;
    end if;
  end process RDY_DELAY;

  REGISTERS : process (clk, reset_n)
  begin  -- process REGISTERS
    if reset_n = '0' then               -- asynchronous reset (active low)
      tri  <= '1';
      dout <= (others => '0');
      addr <= (others => '0');	 
	  tx_packet_length <= (others => '0');	
	  tx_counter <= (others => '0');
    elsif falling_edge(clk) then         -- rising clock edge
      -------------------------------------------------------------------------
      -- Reads
      tri <= '1';	  	  
      if DM_IOR_n = '0' then
        tri <= '0';
      end if;
      if DM_CMD = '0' then
        dout <= addr;
      else
        case addr is
          when X"0001"  => dout <= (6 => dm_ready, 3 => tx_done2, 2 => tx_done1, others => '0');
          when others => dout <= X"ABCD";
        end case;
      end if;

      -------------------------------------------------------------------------
      -- Writes
      if DM_IOW_n = '0' then
        if DM_CMD = '0' then
          addr <= DM_SD;
        else		
		  if addr = X"0002" then
		  	if DM_SD(0) = '1' then
				tx_counter <= (others => '0');
				tx_inprogress <= '1';
				tx_done1 <= '0';
				tx_done2 <= '0';
			end if;		
		  elsif addr = X"00FC" then
		  	tx_packet_length <= DM_SD;
		  end if;
          -- do nothing yet.
        end if;
      end if;  
	  
	  -- TX Counter
	  if tx_inprogress = '1' then
	  	tx_counter <= tx_counter + 1;	
		if tx_counter = tx_packet_length then
			tx_done1 <= '1';		 
			tx_inprogress <= '0';
		end if;
	  else
	    tx_counter <= (others => '0');
	  end if;
    end if;
  end process REGISTERS;

end rtl;
