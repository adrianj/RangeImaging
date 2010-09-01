/*
 * Application for Ranger.
 * Very much simplified due to very small memory available.
 * No ethernet functionality at all. I expect this will be built into the VHDL hardware at some point.
 * Assumes the following SOPC instances:
 * BL       : nios_slave.vhd
 * BR       : nios_slave.vhd
 * TL       : nios_slave.vhd
 * TR       : nios_slave.vhd
 * CONTROL  : nios_slave.vhd
 * FRAME_RECIVED    : pio input. level triggered interrupt.
 *
 */
 
 #include <stdio.h>
 #include <system.h>
 #include <io.h>
 #include "sys/alt_irq.h"
 #include "altera_avalon_pio_regs.h"
 #include "altera_avalon_jtag_uart_regs.h"

 
#include <string.h>
#include <fcntl.h>


double fpb_1 = 4;
unsigned int fp_output = 4;
double mf1 = 40;
unsigned int adcOffsetLeft = 255;
unsigned int adcOffsetRight = 255;
unsigned int adcGainLeft = 20;
unsigned int adcGainRight = 20;
unsigned int intTime = 50000;
unsigned int frameTime = 50000;
unsigned int phaseStepInit1 = 0;
unsigned int phaseStep1 = 4;
unsigned int phaseInc1 = 4;
unsigned int pll_count1_hi = 13;
unsigned int pll_count1_lo = 12;
unsigned int pll_c_rsel_1 = 0;
unsigned int pll_m_count1 = 120;
unsigned int pll_vco1 = 1200;
int cycles_per_capture = 52;
int readoutTime = 2500;  // Minimum is 3200 us = 3.2 ms.

int frame_received_count = 0;
int frame_sent_index = 0;


/* Euclid's algorithm for calculating greatest common divisor */
int gcd(int a, int b)
{
  int c = a % b;
  while(c != 0)
  {
    a = b;
    b = c;
    c = a % b;
  }
  return b;
}

/*
 * Write a value to a given pixel in a given region
 */
void writePixel(int col, int row, int region, int data)
{
    int address = (row<<8) + col;
    if(region == 0)
        IOWR(TL_BASE, address, data);
    else if(region == 1)
        IOWR(TR_BASE, address, data);
    else if(region == 2)
        IOWR(BL_BASE, address, data);
    else if(region == 3)
        IOWR(BR_BASE, address, data);   
}

unsigned short readPixel(int col, int row, int region)
{
    int address = (row<<8) + col;
    if(region == 0)
        return IORD(TL_BASE, address);
    else if(region == 1)
        return IORD(TR_BASE, address);
    else if(region == 2)
        return IORD(BL_BASE, address);
    else if(region == 3)
        return IORD(BR_BASE, address);    
    return 0;
}

/* Reads a \n terminated string from stdin, stored in s, returns length.
 * This to avoid spaces breaking up the input string.
 * Blocks program until correctly ended string is received */
int readStdin(char * s)
{
    
    int i = 0;
    char ch = '\0';
    while(1)
    {
     fscanf(stdin, "%c", &ch);  
     if(ch == '\n' || ch == '\r')
     {
        break;
     }
     s[i] = ch;
     i++;
     //OSTimeDly(0);
    }
    s[i] = 0;
    return i;
}


/*
 * Pauses frame capture, 
 * signals s_reset, 
 * resets frame_counter,
 * restarts
 */
void restart()
{
    frame_received_count = 0;   // Reset frame counter
    frame_sent_index = 0;
    IOWR(CONTROL_BASE, 7, 0);   // unpause
    IOWR(CONTROL_BASE, 10, 1);   // Reset
    
}

void pause()
{
    
    IOWR(CONTROL_BASE, 7, 1); 
}


void setCapture(unsigned int c, unsigned int verbose)
{
    pause();
    IOWR(CONTROL_BASE, 3, c);
    restart();   
}



void setADCParams(int offset_left, int offset_right, unsigned int gain_left, unsigned int gain_right)
{
    unsigned int temp1 = 0, temp2 = 0, temp3 = 0, temp4 = 0;
    adcOffsetLeft = offset_left;
    adcOffsetRight = offset_right;
    adcGainLeft = gain_left;
    adcGainRight = gain_right;
    temp1 = ((offset_left*2) & 0x1FF) + 0xE00;
    usleep(40000);
    IOWR(CONTROL_BASE, 11, temp1);
    usleep(40000);
    temp2 = ((offset_right*2) & 0x1FF) + 0xC00;
    IOWR(CONTROL_BASE, 11, temp2);
    usleep(40000);
    temp3 = (gain_right & 0x003F) + 0x600;
    IOWR(CONTROL_BASE, 11, temp3);
    usleep(40000);
    temp4 = (gain_left & 0x003F) + 0x800;
    IOWR(CONTROL_BASE, 11, temp4);
    usleep(40000);
    // Saturation level. Just fixed at 34000 for now.
    IOWR(CONTROL_BASE, 9, 0x8000);
    //printf("Changing ADC Params: o/s left: %d, o/s right: %d, g left: %d, g right: %d\n", offset_left, offset_right, gain_left, gain_right);
}

 
 /* Prints available user commands */
 void printHelp()
 {
    //printf("\nUser Commands. All parameters are required where listed.\n");
    printf("For control registers, see PMD_register_map.xls.\n");
    printf("--------------------------------------------------------------\n");
    printf("help : prints this help text.\n");    
    //printf("print params : prints current state of system parameters.\n");
    printf("wc <address> <data> : write to FPGA control register.\n");
    printf("rc <address> : read from FPGA control register.\n");
 }
/*
 * Finds up to 5 numbers in a string which are seperated by whitespace.
 * Stores these numbers in the given int array.
 * Returns the number of parameters: 0 if an error or none found.
 */
int getUserParams(char * s, int * params)
{
    int index = 0;
    int n = 0;
    while(s[index] != 0)
    {
        if(s[index] == ' ')
            if(s[index+1] >= '0' && s[index+1] <= '9')
            {
                params[n] = atoi(s+index+1);
                n++;   
            }
        index++;
    }
    return n;
}

/* Parses user input string and performs relevant method.
 */
void processCommand(char * userInput, int userInputLength)
{
       
    int userParams [50];
    int nParams = 0;
    int error = 0;
    if(userInputLength > 0)
    {
        nParams = getUserParams(userInput, userParams);
        
        if(strncmp(userInput, "help",4) == 0)
            printHelp();

        else if(strncmp(userInput, "wc ", 3) == 0)
            if(nParams == 2)
            {
                IOWR(CONTROL_BASE, userParams[0], userParams[1]);
                printf("%s\n", userInput);
            }
            else
            {
                error = 1;
            }


        else if(strncmp(userInput, "rc ", 3) == 0)
            if(nParams == 1)
            {
                userParams[4] = IORD(CONTROL_BASE, userParams[0]);
                printf("%s: %d  %x\n", userInput, userParams[4], userParams[4]);
            }
            else
                error = 1;

        else if(strncmp(userInput, "restart", 7) == 0)
            restart();
        else if(strncmp(userInput, "pause", 5) == 0)
            pause();

        else if(strncmp(userInput, "set adc", 7) == 0)
        {
            if(nParams == 4)
            {
                setADCParams(userParams[0], userParams[1], userParams[2], userParams[3]);   
            }  
            else
               error = 1;
         
        }
  
        else
        {
            error = 1;
        }
        // Invalid Command
        if(error == 1) printf("%s: Unknown Command. Type 'help' for list of commands.\n", userInput);    
                                       
    }
}


int main()
{
    unsigned int userInputLength = 0;
    int readflags = O_RDWR | O_NONBLOCK | O_NOCTTY;
    int readFile = 0;
    char userInput [64];

    setCapture(0,1);
    setADCParams(adcOffsetLeft, adcOffsetRight, adcGainLeft, adcGainRight);
    
    // Do this one again, because it doesn't seem to reliably go through.
    setADCParams(adcOffsetLeft, adcOffsetRight, adcGainLeft, adcGainRight);
    printHelp();
    
    
    while(1)
    {
        // Check if any user input from terminal...
        readFile = open("/dev/jtag_uart", readflags);
        userInputLength = read(readFile,userInput,64);
        readFile = close(readFile);

        if(userInputLength > 0 && userInput[userInputLength-1] == '\n')
        {
                userInput[userInputLength-1] = 0;
                //userInput[userInputLength-2] = 0;
                processCommand(userInput, userInputLength);
            userInputLength = 0;
            userInput[0] = 0;
            
        }
    }// end while(1)

}

