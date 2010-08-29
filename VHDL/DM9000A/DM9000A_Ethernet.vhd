-- VHDL Controller for DM9000A Ethernet Controller
-- UDP protocol only at this stage.     
-- Clk input must be 100 MHz.

-- Dependencies: fifo4096x16.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DM9000A_Ethernet is
  port (
    clk     : in std_logic;
    reset_n : in std_logic;             -- async reset

    sfr_din  : in  std_logic_vector(15 downto 0);
    sfr_addr : in  std_logic_vector(3 downto 0);
    sfr_we   : in  std_logic;
    sfr_dout : out std_logic_vector(15 downto 0);

    tx_fifo_we   : in  std_logic;                      -- tx FIFO write enable
    tx_fifo_din  : in  std_logic_vector(15 downto 0);  -- tx fifo data in
    tx_fifo_full : out std_logic;

    -- Connections to DM9000A IC
    DM_IOR_n : out   std_logic;
    DM_IOW_n : out   std_logic;
    DM_CS_n  : out   std_logic;
    DM_CMD   : out   std_logic;
    DM_INT   : in    std_logic;
    DM_CLK   : out   std_logic;
    DM_SD    : inout std_logic_vector(15 downto 0);
	
	debug : out std_logic_vector(15 downto 0)
    );

end DM9000A_Ethernet;

architecture rtl of DM9000A_Ethernet is

  -----------------------------------------------------------------------------
  -- Special Function Registers
  signal   mac_addr           : std_logic_vector(47 downto 0) := X"01606E11020F";  -- A(7:5)
  constant MAC_ADDR_D         : std_logic_vector(47 downto 0) := X"01606E11020F";
  -- Default destination address is 192.168.0.1
  signal   ip_dest_addr       : std_logic_vector(31 downto 0) := X"C0A80001";  -- A(9:8)
  constant IP_DEST_ADDR_D     : std_logic_vector(31 downto 0) := X"C0A80001";
-- Default source address is 192.168.0.2
  signal   ip_src_addr        : std_logic_vector(31 downto 0) := X"C0A80002";  -- A(11:10)
  constant IP_SRC_ADDR_D      : std_logic_vector(31 downto 0) := X"C0A80002";
  -- Default source port is 54155
  signal   source_port        : std_logic_vector(15 downto 0) := X"D38B";  -- A(12)
  constant SOURCE_PORT_D      : std_logic_vector(15 downto 0) := X"D38B";
  -- Default destination port is 2223
  signal   dest_port          : std_logic_vector(15 downto 0) := X"08AF";  -- A(13)
  constant DEST_PORT_D        : std_logic_vector(15 downto 0) := X"08AF";
  signal   s_reset            : std_logic                     := '1';  -- A(0), bit(0)
  signal   tx_flush           : std_logic                     := '0';  -- A(0), bit(1)
  signal   dm_ready           : std_logic                     := '0';  -- A(0), bit(2)
  -- default packet length is 1328 Bytes = 14 MAC, 20 IP, 8 UDP, 1286 Data
  signal   tx_packet_length   : std_logic_vector(15 downto 0) := X"0530";  -- = DATA_LENGTH + 42
  constant TX_PACKET_LENGTH_D : std_logic_vector(15 downto 0) := X"0045";
  signal   tx_data_length     : std_logic_vector(15 downto 0) := X"0506";  -- A(1)
  constant TX_DATA_LENGTH_D   : std_logic_vector(15 downto 0) := X"0030";
  signal   tx_header_length   : std_logic_vector(15 downto 0) := X"0015";
  constant TX_HEADER_LENGTH_D : std_logic_vector(15 downto 0) := X"0015";  -- = 21 (This counted in int16s)
  constant MAC_LENGTH         : std_logic_vector(15 downto 0) := X"0007";
  constant IP_LENGTH          : std_logic_vector(15 downto 0) := X"000A";
  constant UDP_LENGTH         : std_logic_vector(15 downto 0) := X"0004";
  -----------------------------------------------------------------------------

  -- Registering external inputs, and tristate control
  signal DM_INTi : std_logic                     := '0';
  signal DM_SDi  : std_logic_vector(15 downto 0) := (others => '0');
  signal DM_SDo  : std_logic_vector(15 downto 0) := (others => '0');
  signal DM_tri  : std_logic                     := '0';  -- '1' = 'Z'
  -----------------------------------------------------------------------------
  -- Various DM9000 Registers
  signal NSR     : std_logic_vector(15 downto 0) := (others => '0');

  -- Fifo signals
  signal tx_fifo_re    : std_logic                     := '0';
  signal tx_fifo_dout  : std_logic_vector(15 downto 0) := (others => '0');
  signal tx_fifo_empty : std_logic                     := '0';
  signal tx_fifo_count : std_logic_vector(11 downto 0) := (others => '0');
-------------------------------------------------------------------------------   

  -- Packet header, counter and checksum signals
  type   PACKET_ARRAY is array (natural range <>) of std_logic_vector(15 downto 0);
  signal header   : PACKET_ARRAY(31 downto 0);
  signal checksum : std_logic_vector(15 downto 0) := (others => '0');
  signal p_count  : std_logic_vector(15 downto 0) := (others => '0');

  -----------------------------------------------------------------------------
  -- State machine and other signals
  type   STATE_TYPE is (INIT, FLUSH_BUFFERS, TX_HOLD, TX_INIT, TX_SEND_HEADER, TX_SEND_DATA, TX_INITIATE, TX_WAIT_FOR_DONE, TX_DONE);
  signal state      : STATE_TYPE                    := INIT;
  signal clk_count  : std_logic_vector(7 downto 0)  := (others => '0');
  signal clk_count4 : std_logic_vector(7 downto 0)  := (others => '0');
  signal clk_count2 : std_logic_vector(7 downto 0)  := (others => '0');
  signal clk50      : std_logic                     := '0';
  signal ZERO       : std_logic_vector(15 downto 0) := (others => '0');  -- Use this signal for procedures that require a ZERO input signal.

  -----------------------------------------------------------------------------   
  -- IO_SET_INDEX         
  -- Writes to DM9000A INDEX register, ie, address (CMD = '0')
  -- Reads or writes from this index are available at clk_offset + 4.
  procedure IO_SET_INDEX (
    constant reg        : in  std_logic_vector(7 downto 0);
    constant clk_offset : in  std_logic_vector(7 downto 0);
    signal   clk_cnt    : in  std_logic_vector(7 downto 0);
    signal   DM_IOW_n   : out std_logic;
    signal   DM_CMD     : out std_logic;
    signal   DM_tri     : out std_logic;
    signal   DM_SDo     : out std_logic_vector(15 downto 0)) is
  begin  -- IO_SET_INDEX
    if clk_cnt = clk_offset then
      DM_IOW_n <= '0';
      DM_CMD   <= '0';
      DM_tri   <= '0';
      DM_SDo   <= X"00" & reg;
    elsif clk_cnt = clk_offset + 2 then
      DM_IOW_n <= '1';
    elsif clk_cnt = clk_offset + 3 then
      DM_tri <= '1';
    end if;
  end IO_SET_INDEX;

  -- IO_WRITE     
  -- Writes to DM9000A DATA register, ie, address (CMD = '1')             
  procedure IO_WRITE (
    constant data       : in  std_logic_vector(15 downto 0);
    constant clk_offset : in  std_logic_vector(7 downto 0);
    signal   clk_cnt    : in  std_logic_vector(7 downto 0);
    signal   DM_IOW_n   : out std_logic;
    signal   DM_CMD     : out std_logic;
    signal   DM_tri     : out std_logic;
    signal   DM_SDo     : out std_logic_vector(15 downto 0)) is
  begin  -- IO_WRITE
    if clk_cnt = clk_offset then
      DM_CMD   <= '1';
      DM_IOW_n <= '0';
      DM_SDo   <= data;
      DM_tri   <= '0';
    elsif clk_cnt = clk_offset + 2 then
      DM_IOW_n <= '1';
    elsif clk_cnt = clk_offset + 3 then
      DM_tri <= '1';
    end if;
  end IO_WRITE;

  -- IO_READ  
  -- Reads from DM9000A DATA register, ie, address (CMD = '1')            
  procedure IO_READ (
    signal   dout       : out std_logic_vector(15 downto 0);
    constant clk_offset : in  std_logic_vector(7 downto 0);
    signal   clk_cnt    : in  std_logic_vector(7 downto 0);
    signal   DM_IOR_n   : out std_logic;
    signal   DM_CMD     : out std_logic;
    signal   DM_tri     : out std_logic;
    signal   DM_SD      : in  std_logic_vector(15 downto 0)) is
  begin  -- IO_READ
    if clk_cnt = clk_offset then
      DM_CMD   <= '1';
      DM_tri   <= '1';
      DM_IOR_n <= '0';
    elsif clk_cnt = clk_offset + 2 then
      dout     <= DM_SD;
      DM_IOR_n <= '1';
    end if;
  end IO_READ;

  -- IO_WRITE_DATA procedure.
  -- Performs a write to INDEX reg, ie, sets address (CMD = '0')
  -- then writes to DATA (CMD = '1')
  procedure IO_WRITE_DATA (
    constant reg        : in  std_logic_vector(7 downto 0);
    constant data       : in  std_logic_vector(15 downto 0);
    constant clk_offset : in  std_logic_vector(7 downto 0);
    signal   clk_cnt    : in  std_logic_vector(7 downto 0);
    signal   DM_IOW_n   : out std_logic;
    signal   DM_CMD     : out std_logic;
    signal   DM_tri     : out std_logic;
    signal   DM_SDo     : out std_logic_vector(15 downto 0)) is
  begin  -- IO_WRITE_DATA         
    IO_SET_INDEX(reg, clk_offset, clk_cnt, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
    IO_WRITE(data, clk_offset+4, clk_cnt, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
  end IO_WRITE_DATA;

  -- IO_READ_DATA procedure.
  -- Performs a write to INDEX reg, ie, sets address (CMD = '0')
  -- then performs a read from data (CMD = '1')  
  -- Result written into 'dout' signal
  procedure IO_READ_DATA (
    constant reg        : in  std_logic_vector(7 downto 0);
    signal   dout       : out std_logic_vector(15 downto 0);
    constant clk_offset : in  std_logic_vector(7 downto 0);
    signal   clk_cnt    : in  std_logic_vector(7 downto 0);
    signal   DM_IOW_n   : out std_logic;
    signal   DM_IOR_n   : out std_logic;
    signal   DM_CMD     : out std_logic;
    signal   DM_tri     : out std_logic;
    signal   DM_SDo     : out std_logic_vector(15 downto 0);
    signal   DM_SD      : in  std_logic_vector(15 downto 0)) is
  begin  -- IO_READ_DATA
    IO_SET_INDEX(reg, clk_offset, clk_cnt, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
    IO_READ(dout, clk_offset+4, clk_cnt, DM_IOR_n, DM_CMD, DM_tri, DM_SD);
  end IO_READ_DATA;

begin  -- rtl                                                                                                     

  -----------------------------------------------------------------------------
  DM_SD <= DM_SDo when DM_tri = '0' else (others => 'Z');	 
  debug <= NSR;

  DO_SFRS : process (clk, reset_n)
  begin  -- process DO_SFRS
    if reset_n = '0' then               -- asynchronous reset (active low)
      mac_addr         <= MAC_ADDR_D;
      ip_dest_addr     <= IP_DEST_ADDR_D;
      ip_src_addr      <= IP_SRC_ADDR_D;
      source_port      <= SOURCE_PORT_D;
      dest_port        <= DEST_PORT_D;
      tx_packet_length <= TX_PACKET_LENGTH_D;
      tx_data_length   <= TX_DATA_LENGTH_D;
      sfr_dout         <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      -- These values are only pulsed.
      s_reset          <= '0';
      tx_flush         <= '0';
      tx_header_length <= MAC_LENGTH + IP_LENGTH + UDP_LENGTH;
      tx_packet_length <= tx_data_length + tx_header_length;

      -------------------------------------------------------------------------
      -- SFR Writes
      if sfr_we = '1' then
        case sfr_addr is
          when X"0"   => s_reset                    <= sfr_din(0); tx_flush <= sfr_din(1);
          when X"1"   => tx_data_length             <= sfr_din;
                         --when X"2"   => tx_data_length             <= sfr_din;
          when X"5"   => mac_addr(15 downto 0)      <= sfr_din;
          when X"6"   => mac_addr(31 downto 16)     <= sfr_din;
          when X"7"   => mac_addr(47 downto 32)     <= sfr_din;
          when X"8"   => ip_dest_addr(15 downto 0)  <= sfr_din;
          when X"9"   => ip_dest_addr(31 downto 16) <= sfr_din;
          when X"A"   => ip_src_addr(15 downto 0)   <= sfr_din;
          when X"B"   => ip_src_addr(31 downto 16)  <= sfr_din;
          when X"C"   => source_port                <= sfr_din;
          when X"D"   => dest_port                  <= sfr_din;
          when others => null;
        end case;
      end if;
      -------------------------------------------------------------------------
      -- SFR Reads
      case sfr_addr is
        when X"0"   => sfr_dout <= (2 => dm_ready, others => '0');
        when X"1"   => sfr_dout <= tx_data_length;
                       --when X"2"   => sfr_dout <= tx_data_length;
        when X"5"   => sfr_dout <= mac_addr(15 downto 0);
        when X"6"   => sfr_dout <= mac_addr(31 downto 16);
        when X"7"   => sfr_dout <= mac_addr(47 downto 32);
        when X"8"   => sfr_dout <= ip_dest_addr(15 downto 0);
        when X"9"   => sfr_dout <= ip_dest_addr(31 downto 16);
        when X"A"   => sfr_dout <= ip_src_addr(15 downto 0);
        when X"B"   => sfr_dout <= ip_src_addr(31 downto 16);
        when X"C"   => sfr_dout <= source_port;
        when X"D"   => sfr_dout <= dest_port;
        when others => null;
      end case;
    end if;
  end process DO_SFRS;

  DO_CLKDIV : process (clk, reset_n)
  begin  -- process DO_CLKDIV
    if reset_n = '0' then        -- asynchronous reset (active low)         
      clk_count <= (others => '0');
      clk50     <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      clk50 <= not clk50;
      if state = FLUSH_BUFFERS or state = TX_HOLD or state = TX_DONE then
        clk_count <= (others => '0');
      else
        clk_count <= clk_count + 1;
      end if;
    end if;
  end process DO_CLKDIV;
  clk_count4 <= X"0" & clk_count(3 downto 0);
  clk_count2 <= X"0" & "00" & clk_count(1 downto 0);

  DM_CLK <= clk50;

  -----------------------------------------------------------------------------
  -- Main Loop: INIT -> FLUSH_BUFFERS -> TX_HOLD -> TX_INIT -> TX_SEND_HEADER
  -- -> TX_SEND_DATA -> TX_INITIATE -> TX_DONE -> TX_HOLD.
  -- Resets to INIT on reset_n and s_reset.
  -- Resets to FLUSH_BUFFERS on tx_flush.
  -----------------------------------------------------------------------------
  DO_STATE_MACHINE : process (clk, reset_n)
  begin  -- process DO_STATE_MACHINE
    if reset_n = '0' then               -- asynchronous reset (active low)
      state      <= INIT;
      dm_ready   <= '0';
      tx_fifo_re <= '0';
    elsif rising_edge(clk) then         -- rising clock edge 
      tx_fifo_re <= '0';
      if s_reset = '1' then
        state <= INIT;
      elsif tx_flush = '1' then
        state <= FLUSH_BUFFERS;
      else
        case STATE is
          when INIT =>
            dm_ready <= '0';
            if NSR(6) = '1' then
              state <= FLUSH_BUFFERS;
            end if;
          when FLUSH_BUFFERS =>
            dm_ready <= '0';
            state    <= TX_HOLD;
          when TX_HOLD =>
            dm_ready <= '1';
            if tx_fifo_count >= tx_data_length(11 downto 0) then
              state <= TX_INIT;
            end if;
          when TX_INIT =>
            if clk_count = X"0D" then
              state <= TX_SEND_HEADER;
            end if;
          when TX_SEND_HEADER =>
            if p_count = tx_header_length and clk_count2 = "10" then
              tx_fifo_re <= '1';
            end if;
            if p_count = tx_header_length and clk_count2 = "11" then
              state <= TX_SEND_DATA;
            end if;
          when TX_SEND_DATA =>
            if clk_count2 = "10" and p_count < tx_packet_length then
              tx_fifo_re <= '1';
            end if;
            if p_count = tx_packet_length and clk_count2 = "11" then
              state <= TX_INITIATE;
            end if;
          when TX_INITIATE =>
            if clk_count4 = X"0A" then
              state <= TX_WAIT_FOR_DONE;
            end if;
          when TX_WAIT_FOR_DONE =>
            if NSR(2) = '1' or NSR(3) = '1' then
              state <= TX_DONE;
            end if;
          when TX_DONE =>
            state <= TX_HOLD;
          when others => state <= INIT;
        end case;
      end if;
    end if;
  end process DO_STATE_MACHINE;

  -----------------------------------------------------------------------------
  -- Set DM Outputs
  SET_DMO : process (clk, reset_n)
  begin  -- process SET_DMO
    if reset_n = '0' then               -- asynchronous reset (active low)
      DM_tri   <= '1';
      DM_IOW_n <= '1';
      DM_IOR_n <= '1';
      DM_CS_n  <= '1';
      DM_CMD   <= '0';
      DM_SDo   <= (others => '0');
      DM_SDi   <= (others => '0');
      NSR      <= (others => '0');
      p_count  <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      DM_CS_n <= '0';                   -- IC is always selected.
      case state is
        when INIT =>
          -- Repeatedly check Link active signal (Reg01 = X"40")
          IO_READ_DATA(X"01", NSR, X"00", clk_count4, DM_IOW_n, DM_IOR_n, DM_CMD, DM_tri, DM_SDo, DM_SD);
        when TX_INIT =>
          -- Write packet length into register X"FC"
          IO_WRITE_DATA(X"FC", tx_packet_length, X"00", clk_count, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
          -- Prepare INDEX for writing into X"F8" - TX SRAM with addr inc.                                 
          IO_SET_INDEX(X"F8", X"0A", clk_count, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
          p_count <= (others => '0');
        when TX_SEND_HEADER =>
          -- Write header data
          IO_WRITE(header(0), X"00", clk_count2, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
          if clk_count2 = "00" then
            p_count <= p_count + 1;
          end if;
        when TX_SEND_DATA =>
          -- Write packet data
          IO_WRITE(tx_fifo_dout, X"00", clk_count2, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
          if clk_count2 = "00" then
            p_count <= p_count + 1;
          end if;
        when TX_INITIATE =>
          -- write to Transmit Control Register (reg X"02). Value of X"01" initiates TX.
          -- Write packet length into register X"FC"
          IO_WRITE_DATA(X"02", X"0001", X"00", clk_count4, DM_IOW_n, DM_CMD, DM_tri, DM_SDo);
        when TX_WAIT_FOR_DONE =>
          -- Repeatedly check TX Done (Reg02 = X"08" or X"04")
          IO_READ_DATA(X"01", NSR, X"00", clk_count4, DM_IOW_n, DM_IOR_n, DM_CMD, DM_tri, DM_SDo, DM_SD);
          p_count <= (others => '0');
        when others => null;
      end case;
    end if;
  end process SET_DMO;

  CREATE_HEADER : process (clk, reset_n)
  begin  -- process CREATE_HEADER
    if reset_n = '0' then               -- asynchronous reset (active low)
      header   <= (others => (others => '0'));
      checksum <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if state = TX_INIT then
        -- destination MAC is broadcast
        header(0)  <= X"FFFF";
        header(1)  <= X"FFFF";
        header(2)  <= X"FFFF";
        -- source MAC
        header(3)  <= mac_addr(47 downto 32);
        header(4)  <= mac_addr(31 downto 16);
        header(5)  <= mac_addr(15 downto 0);
        -- type (IP)
        header(6)  <= X"0800";
        -- IP header length
        header(7)  <= X"4500";
        -- total packet length
        header(8)  <= tx_packet_length;
        -- ID, fragment, TTL
        header(9)  <= X"A004";
        header(10) <= X"0000";
        header(11) <= X"4011";
        -- checksum of IP packet
        header(12) <= checksum;
        -- source IP addr
        header(13) <= ip_src_addr(15 downto 0);
        header(14) <= ip_src_addr(31 downto 16);
        -- dest IP addr
        header(15) <= ip_dest_addr(15 downto 0);
        header(16) <= ip_dest_addr(31 downto 16);
        -- source port
        header(17) <= source_port;
        -- dest port
        header(18) <= dest_port;
        -- UDP length
        header(19) <= tx_data_length + UDP_LENGTH;
        -- UDP checksum (ignored)
        header(20) <= (others => '0');

        -- blank out all unsused header locations
        header(31 downto 21) <= (others => (others => '0'));
        checksum             <= (others => '0');
      elsif state = TX_SEND_HEADER then
        -- Shift header along
        -- calculate checksum as packet is being transmitted. 
        if clk_count2 = "00" then
          header <= X"0000" & header(31 downto 1);
          if p_count > MAC_LENGTH and p_count < MAC_LENGTH + IP_LENGTH then
            checksum <= checksum + header(0);
          end if;
        end if;
      end if;
    end if;
  end process CREATE_HEADER;

  -----------------------------------------------------------------------------
  -- Instantiate TX FIFO
  TX_FIFO : entity work.fifo4096x16
    port map (
      clock => clk,
      data  => tx_fifo_din,
      rdreq => tx_fifo_re,
      sclr  => tx_flush,
      wrreq => tx_fifo_we,
      empty => tx_fifo_empty,
      full  => tx_fifo_full,
      q     => tx_fifo_dout,
      usedw => tx_fifo_count);    


end rtl;
