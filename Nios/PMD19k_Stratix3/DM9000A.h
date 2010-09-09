#ifndef   __DM9000A_H__
#define   __DM9000A_H__

// Sizes are in 16-bit words, as appropriate for DM9000 and Packet_Header
#define MAC_HL 7
#define IP_HL 10
#define UDP_HL 4
//source (this) MAC address
static unsigned char ether_addr[] = { 0x01, 0x60, 0x6E, 0x11, 0x02, 0x0F };
// Place to store the packet header, since it doesn't need to be recomputed that often.
// User CreateHeader function to build it.
static unsigned int Packet_Header [MAC_HL + IP_HL + UDP_HL];
// source (this) ip_addr
static unsigned char IP_ADDR [] = { 192, 168, 1, 2 };
// destination ip (target computer)
static unsigned char DST_IP_ADDR [] = { 192, 168, 1, 1 };
static unsigned int sourcePort = 54155;
static unsigned int destPort = 2223;


#define IO_addr     0
#define IO_data     1

#define NCR         0x00  /* Network  Control Register REG. 00 */
#define NSR         0x01  /* Network  Status Register  REG. 01 */
#define TCR         0x02  /* Transmit Control Register REG. 02 */
#define RCR         0x05  /* Receive  Control Register REG. 05 */
#define ETXCSR      0x30  /* TX early Control Register REG. 30 */
#define MRCMDX      0xF0  /* RX FIFO I/O port command READ  for dummy read a byte from RX SRAM */
#define MRCMD       0xF2  /* RX FIFO I/O port command READ  from RX SRAM */
#define MWCMD       0xF8  /* TX FIFO I/O port command WRITE into TX FIFO */
#define ISR         0xFE  /* NIC Interrupt Status Register REG. FEH */
#define IMR         0xFF  /* NIC Interrupt Mask   Register REG. FFH */

#define NCR_set         0x00
#define TCR_set         0x00
#define TX_REQUEST      0x01  /* TCR REG. 02 TXREQ Bit [0] = 1 polling Transmit Request command */
#define TCR_long        0x40  /* packet disable TX Jabber Timer */
#define RCR_set         0x30  /* skip CRC_packet and skip LONG_packet */
#define RX_ENABLE       0x01  /* RCR REG. 05 RXEN Bit [0] = 1 to enable RX machine */
#define RCR_long        0x40  /* packet disable RX Watchdog Timer */
#define PASS_MULTICAST  0x08  /* RCR REG. 05 PASS_ALL_MULTICAST Bit [3] = 1: RCR_set value ORed 0x08 */
#define BPTR_set        0x3F  /* BPTR REG. 08 RX Back Pressure Threshold: High Water Overflow Threshold setting 3KB and Jam_Pattern_Time = 600 us */
#define FCTR_set        0x5A  /* FCTR REG. 09 High/ Low Water Overflow Threshold setting 5KB/ 10KB */
#define RTFCR_set       0x29  /* RTFCR REG. 0AH RX/TX Flow Control Register enable TXPEN + BKPM(TX_Half) + FLCE(RX) */
#define ETXCSR_set      0x83  /* Early Transmit Bit [7] Enable and Threshold 0~3: 12.5%, 25%, 50%, 75% */
#define INTR_set        0x81  /* IMR REG. FFH: PAR +PRM, or 0x83: PAR + PRM + PTM */
#define PAR_set         0x80  /* IMR REG. FFH: PAR only, RX/TX FIFO R/W Pointer Auto Return enable */

#define PHY_reset       0x8000  /* PHY reset: some registers back to default value */
#define PHY_txab        0x05e1  /* set PHY TX advertised ability: Full-capability + Flow-control (if necessary) */
#define PHY_mode        0x3100  /* set PHY media mode: Auto negotiation (AUTO sense) */

#define STD_DELAY       20      /* standard delay 20 us */

#define DMFE_SUCCESS    0
#define DMFE_FAIL       1

#define TRUE            1
#define FALSE           0

#define DM9000_PKT_READY  0x01  /* packets ready to receive */
#define PACKET_MIN_SIZE   0x40  /* Received packet min size */
#define MAX_PACKET_SIZE   1522  /* RX largest legal size packet with fcs & QoS */
#define DM9000_PKT_MAX    3072  /* TX 1 packet max size without 4-byte CRC */

unsigned int DM9000_init (void);
void iow(unsigned int reg, unsigned int data);
unsigned int ior(unsigned int reg);
void DM9000_transmit_init(unsigned int);
void DM9000_transmit_complete(void);
void createHeader(unsigned int* packet, int data_length_in_bytes);

#endif
