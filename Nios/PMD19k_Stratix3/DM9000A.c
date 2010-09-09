/*
  DM9000A Ethernet Controller Routines.
  First written by Tony Cimino, 2008. Modified by Adrian Jongenelen 2009
  ReceivePacket is NOT tested.
  See DM9000A.h for source MAC, source + dest IPs and port numbers.
  See TransmitPacket function for example of how to use this.
 */

#include <stdio.h>
#include "DM9000A.H"
 #include <io.h>

#include "system.h"


unsigned int aaa,rx_len,i,packet_num;
unsigned char RXT[68];




/* Basic IO Write operation. Writes address byte followed by data byte */
void iow(unsigned int reg, unsigned int data)
{
  IOWR(DM9000A_BASE,IO_addr,reg);
  IOWR(DM9000A_BASE,IO_data,data);
}

/* Basic read operation. Writes address byte followed by read
 * Does the read a couple of times to be sure... I'm still not convinced it works :S */
unsigned int ior(unsigned int reg)
{
    unsigned int value = 0;
  IOWR(DM9000A_BASE,IO_addr,reg);
  IORD(DM9000A_BASE, IO_data);
  value = IORD(DM9000A_BASE, IO_data);
  
  return value;
}

/* Writes to PHYs. Only used during init routine */
void phy_write (unsigned int reg, unsigned int value)
{ 
  /* set PHY register address into EPAR REG. 0CH */
  iow(0x0C, reg | 0x40);              /* PHY register address setting, and DM9000_PHY offset = 0x40 */
  
  /* fill PHY WRITE data into EPDR REG. 0EH & REG. 0DH */
  iow(0x0E, ((value >> 8) & 0xFF));   /* PHY data high_byte */
  iow(0x0D, value & 0xFF);            /* PHY data low_byte */

  /* issue PHY + WRITE command = 0xa into EPCR REG. 0BH */
  iow(0x0B, 0x8);                     /* clear PHY command first */
  /* issue PHY + WRITE command */
  IOWR(DM9000A_BASE, IO_data, 0x0A);
  usleep(STD_DELAY);
  /* clear PHY command again */
  IOWR(DM9000A_BASE, IO_data, 0x08);
  usleep(50);  /* wait 1~30 us (>20 us) for PHY + WRITE completion */
}

/* DM9000_init I/O routine 
 * Returns DMFE_SUCCESS (0) or DMFE_FAIL (1) (who came up with that!?)
 * If successful, ethernet link and status lights should be on */
unsigned int DM9000_init (void)  /* initialize DM9000 LAN chip */
{
  unsigned int i;

  /* set the internal PHY power-on (GPIOs normal settings) */
  iow(0x1E, 0x01);  /* GPCR REG. 1EH = 1 selected GPIO0 "output" port for internal PHY */
  iow(0x1F, 0x00);  /* GPR  REG. 1FH GEPIO0 Bit [0] = 0 to activate internal PHY */
  usleep(5000);        /* wait > 2 ms for PHY power-up ready */

  /* software-RESET NIC */
  iow(NCR, 0x03);   /* NCR REG. 00 RST Bit [0] = 1 reset on, and LBK Bit [2:1] = 01b MAC loopback on */
  usleep(20);       /* wait > 10us for a software-RESET ok */
  iow(NCR, 0x00);   /* normalize */
  iow(NCR, 0x03);
  usleep(20);
  iow(NCR, 0x00);
  
  /* set GPIO0=1 then GPIO0=0 to turn off and on the internal PHY */
  iow(0x1F, 0x01);  /* GPR PHYPD Bit [0] = 1 turn-off PHY */
  iow(0x1F, 0x00);  /* PHYPD Bit [0] = 0 activate phyxcer */
  usleep(10000);       /* wait >4 ms for PHY power-up */
  
  /* set PHY operation mode */
  phy_write(0,PHY_reset);   /* reset PHY: registers back to the default states */
  usleep(50);               /* wait >30 us for PHY software-RESET ok */
  phy_write(16, 0x404);     /* turn off PHY reduce-power-down mode only */
  phy_write(4, PHY_txab);   /* set PHY TX advertised ability: ALL + Flow_control */
  phy_write(0, 0x1200);     /* PHY auto-NEGO re-start enable (RESTART_AUTO_NEGOTIATION + AUTO_NEGOTIATION_ENABLE) to auto sense and recovery PHY registers */
  usleep(5000);               /* wait >2 ms for PHY auto-sense linking to partner */

  /* store MAC address into NIC */
  for (i = 0; i < 6; i++) 
  iow(16 + i, ether_addr[i]);
  
  /* clear any pending interrupts */
  iow(ISR, 0x3F);     /* clear the ISR status: PRS, PTS, ROS, ROOS 4 bits, by RW/C1 */
  iow(NSR, 0x2C);     /* clear the TX status: TX1END, TX2END, WAKEUP 3 bits, by RW/C1 */

  /* program operating registers~ */
  iow(NCR,  NCR_set);   /* NCR REG. 00 enable the chip functions (and disable this MAC loopback mode back to normal) */
  iow(0x08, BPTR_set);  /* BPTR  REG.08  (if necessary) RX Back Pressure Threshold in Half duplex moe only: High Water 3KB, 600 us */
  iow(0x09, FCTR_set);  /* FCTR  REG.09  (if necessary) Flow Control Threshold setting High/ Low Water Overflow 5KB/ 10KB */
  iow(0x0A, RTFCR_set); /* RTFCR REG.0AH (if necessary) RX/TX Flow Control Register enable TXPEN, BKPM (TX_Half), FLCE (RX) */
  iow(0x0F, 0x00);      /* Clear the all Event */
  iow(0x2D, 0x80);      /* Switch LED to mode 1 */

  /* set other registers depending on applications */
  iow(ETXCSR, ETXCSR_set); /* Early Transmit 75% */
  
  /* enable interrupts to activate DM9000 ~on */
  iow(IMR, INTR_set);   /* IMR REG. FFH PAR=1 only, or + PTM=1& PRM=1 enable RxTx interrupts */

  /* enable RX (Broadcast/ ALL_MULTICAST) ~go */
  iow(RCR , RCR_set | RX_ENABLE | PASS_MULTICAST);  /* RCR REG. 05 RXEN Bit [0] = 1 to enable the RX machine/ filter */

  /* RETURN "DEVICE_SUCCESS" back to upper layer */
  return  (ior(0x2D)==0x80) ? DMFE_SUCCESS : DMFE_FAIL;
  
  /* Should the above line actually refer to reg 0x01 Network Status Register, Bit 6: Link Status: 0=fail, 1=good.
   * ie, return ((ior(0x01)&&0x40)==0x40) ? DMFE_FAIL : DMFE_SUCCESS; */
}
//-------------------------------------------------------------------------

/* Prepare DM9000 for transmitting
 * All writes following this one would contain the data packet.
 * ie, a succession of IOWR(DM9000A_BASE, IO_data, data_16_bit)
 * Total IOWRs should equal tx_len / 2, otherwise get problems
 */
void DM9000_transmit_init(unsigned int tx_len)
{
    /* mask NIC interrupts IMR: PAR only */
  iow(IMR, PAR_set);
  
  /* issue TX packet's length into TXPLH REG. FDH & TXPLL REG. FCH */
  iow(0xFD, (tx_len >> 8) & 0xFF);  /* TXPLH High_byte length */
  iow(0xFC, tx_len & 0xFF);         /* TXPLL Low_byte  length */

  /* write transmit data to chip SRAM */
  /* set MWCMD REG. F8H TX I/O port ready */
  IOWR(DM9000A_BASE, IO_addr, MWCMD); 
}

/* Complete DM9000 transmission
 * Call this after last packet data has been written
 */
void DM9000_transmit_complete()
{
    unsigned int value = 0, i = 0;
     /* issue TX polling command activated */
  iow(TCR , TCR_set | TX_REQUEST);  /* TXCR Bit [0] TXREQ auto clear after TX completed */

  // Wait while TX is done.
  // This should break early, ie, as soon as NSR register says transmission complete
  // But, it doesn't tend to work that way. So it will check it 200 times before
  // carrying on, to ensure it doesn't hang.
  for(i = 0; i < 20; i++)
  {
    value = ior(NSR);
    // display NSR register on LEDs
    //IOWR(CONTROL_BASE, 9, value);
    if((value & 0x0C) == 0x0C) break; 
  }

  /* clear the NSR Register */
  iow(NSR,0x00);
  
  /* re-enable NIC interrupts */
  iow(IMR, INTR_set);
}


/*  Transmit one Packet TX I/O routine. tx_len = packet length in 'int' (16-bit data)
 *  This must include the header data.
 *  Alternatively, build your own code in a similar manner if you want to split the
 *  packet header and data as coming from different parts of memory */
unsigned int  TransmitPacket(unsigned char *data_ptr,unsigned int tx_len)
{
  unsigned int  i;

    DM9000_transmit_init(tx_len);
   
  for (i = 0; i < tx_len; i += 2)
  {
    IOWR(DM9000A_BASE, IO_data, (data_ptr[i+1]<<8)|data_ptr[i] );
  }
    
   DM9000_transmit_complete();
  
  /* RETURN "TX_SUCCESS" to upper layer */
  
  
  return  DMFE_SUCCESS;
}
//-------------------------------------------------------------------------
/* Receive One Packet I/O routine (NOT tested/used by Adrian)*/
unsigned int  ReceivePacket (unsigned char *data_ptr,unsigned int *rx_len)
{
  unsigned char rx_READY,GoodPacket;
  unsigned int  Tmp, RxStatus, i;
  
  RxStatus = rx_len[0] = 0;
  GoodPacket=FALSE;

   /* mask NIC interrupts IMR: PAR only */
  iow(IMR, PAR_set);
  
  /* dummy read a byte from MRCMDX REG. F0H */
  rx_READY = ior(MRCMDX);
  
  /* got most updated byte: rx_READY */
  rx_READY = IORD(DM9000A_BASE,IO_data)&0x03;
  usleep(STD_DELAY);
  
  /* check if (rx_READY == 0x01): Received Packet READY? */
  if (rx_READY == DM9000_PKT_READY)
  {
    /* got RX_Status & RX_Length from RX SRAM */
    IOWR(DM9000A_BASE, IO_addr, MRCMD); /* set MRCMD REG. F2H RX I/O port ready */
    usleep(STD_DELAY);
    RxStatus = IORD(DM9000A_BASE,IO_data);
    usleep(STD_DELAY);
    rx_len[0] = IORD(DM9000A_BASE,IO_data);

    /* Check this packet_status GOOD or BAD? */
    if ( !(RxStatus & 0xBF00) && (rx_len[0] < MAX_PACKET_SIZE) )
    {
      /* read 1 received packet from RX SRAM into RX buffer */
      for (i = 0; i < rx_len[0]; i += 2)
      {
        usleep(STD_DELAY);
        Tmp = IORD(DM9000A_BASE, IO_data);
        data_ptr[i] = Tmp&0xFF;
        data_ptr[i+1] = (Tmp>>8)&0xFF;
      }
      GoodPacket=TRUE;
    } /* end if (GoodPacket) */
    else
    {
      /* this packet is bad, dump it from RX SRAM */
      for (i = 0; i < rx_len[0]; i += 2)
      {
        usleep(STD_DELAY);
        Tmp = IORD(DM9000A_BASE, IO_data);        
      }
      printf("\nError\n");
      rx_len[0] = 0;
    } /* end if (!GoodPacket) */
  } /* end if (rx_READY == DM9000_PKT_READY) ok */
  else if(rx_READY) /* status check first byte: rx_READY Bit[1:0] must be "00"b or "01"b */
  {
    /* software-RESET NIC */
    iow(NCR, 0x03);   /* NCR REG. 00 RST Bit [0] = 1 reset on, and LBK Bit [2:1] = 01b MAC loopback on */
    usleep(20);       /* wait > 10us for a software-RESET ok */
    iow(NCR, 0x00);   /* normalize */
    iow(NCR, 0x03);
    usleep(20);
    iow(NCR, 0x00);    
    /* program operating registers~ */
    iow(NCR,  NCR_set);   /* NCR REG. 00 enable the chip functions (and disable this MAC loopback mode back to normal) */
    iow(0x08, BPTR_set);  /* BPTR  REG.08  (if necessary) RX Back Pressure Threshold in Half duplex moe only: High Water 3KB, 600 us */
    iow(0x09, FCTR_set);  /* FCTR  REG.09  (if necessary) Flow Control Threshold setting High/ Low Water Overflow 5KB/ 10KB */
    iow(0x0A, RTFCR_set); /* RTFCR REG.0AH (if necessary) RX/TX Flow Control Register enable TXPEN, BKPM (TX_Half), FLCE (RX) */
    iow(0x0F, 0x00);      /* Clear the all Event */
    iow(0x2D, 0x80);      /* Switch LED to mode 1 */
    /* set other registers depending on applications */
    iow(ETXCSR, ETXCSR_set); /* Early Transmit 75% */
    /* enable interrupts to activate DM9000 ~on */
    iow(IMR, INTR_set);   /* IMR REG. FFH PAR=1 only, or + PTM=1& PRM=1 enable RxTx interrupts */
    /* enable RX (Broadcast/ ALL_MULTICAST) ~go */
    iow(RCR , RCR_set | RX_ENABLE | PASS_MULTICAST);  /* RCR REG. 05 RXEN Bit [0] = 1 to enable the RX machine/ filter */
  } /* end NIC H/W system Data-Bus error */
  
  return GoodPacket ? DMFE_SUCCESS : DMFE_FAIL;
}

/* Insert header information to a packet.
 * Creates a UDP packet header for data length of data_length_in_bytes.
 * For src MAC, IP addresses, ports, etc, see DM9000A.h
 */
void createHeader(unsigned int* packet, int data_length_in_bytes)
{
    unsigned int total_length = data_length_in_bytes + (MAC_HL + IP_HL + UDP_HL)*2;
    unsigned int udp_length = data_length_in_bytes + 8;
    unsigned int TXT[] = { 0xFFFF,0xFFFF,0xFFFF,    //destination (broadcast)
                          // Tony's PC MAC: 0x00,0x14,0x22,0x53,0x25,0x8F,    //destination
                          //0x00,0x21,0x70,0x7A,0x68,0xD1,    //destination (Adrian's PC)
                          (ether_addr[0]<<8)+ether_addr[1],
                          (ether_addr[2]<<8)+ether_addr[3],
                          (ether_addr[4]<<8)+ether_addr[5],
                          //0x0160,0x6E11,0x020F,    //source (This NIC)
                          
                          0x0800,    //type (IP)
                          
                          // IP HEADER
                          0x4500,         //version 4, 5*32bits = 20 bytes. TOS default
                         
                          //length (data + UDP header + IP header)
                          total_length,
                          0xa004,    //Identification, meh.
                          0x0000,    //fragment offset
                          0x4011,         //time to live, protocol: UDP
                          0x0000,   //checksum, calculated later
                          (IP_ADDR[0]<<8)+IP_ADDR[1],
                          (IP_ADDR[2]<<8)+IP_ADDR[3],  //source IP address 130.195.162.31
                          (DST_IP_ADDR[0]<<8)+DST_IP_ADDR[1],
                          (DST_IP_ADDR[2]<<8)+DST_IP_ADDR[3],  //dest IP address 130.195.162.34
                          
                          //length of above = 34 bytes
                          
                          // UDP HEADER
                          sourcePort,    //source port
                          destPort,    //destination port
                          //length (UDP header + padding + data) 8+22+256=286=0x108
                          udp_length,
                          0x0000 };    //checksum (00,00 ignore)
    int i = 0;
    unsigned int sum = 0;
    // Insert ethernet header. Swapping bytes.
    for(i = 0; i < MAC_HL; i++)
    {
        packet[i] = ((TXT[i] & 0xff) << 8) + (TXT[i] >> 8);
    }
    // Insert IPv4 header and calculate checksum.
    for(i = MAC_HL; i < MAC_HL + IP_HL; i++)
    {
        sum = sum + TXT[i];

        packet[i] = ((TXT[i] & 0xff) << 8) + (TXT[i] >> 8);
    }
    // One's complement and add back carries.
    sum = sum + (sum >> 16);
    sum = (0xffff - sum) & 0xffff;
    packet[12] = ((sum & 0xff) << 8) + (sum >> 8);
    
    // Insert UDP header
    for(i = MAC_HL + IP_HL; i < MAC_HL + IP_HL + UDP_HL; i++)
    {
        packet[i] = ((TXT[i] & 0xff) << 8) + (TXT[i] >> 8);
    }
    
}
