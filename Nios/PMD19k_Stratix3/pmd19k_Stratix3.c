/*
 * Application for Ranger.
 * Assumes the following SOPC instances:
 * BL       : nios_slave.vhd
 * BR       : nios_slave.vhd
 * TL       : nios_slave.vhd
 * TR       : nios_slave.vhd
 * CONTROL  : nios_slave.vhd
 * DM9000A  : dm9000a_if.v
 * FRAME_RECIVED    : pio input. level triggered interrupt.
 *
 */
 
 #include <stdio.h>
 #include <system.h>
 #include <io.h>
 #include "sys/alt_irq.h"
 #include "altera_avalon_pio_regs.h"
 #include "altera_avalon_jtag_uart_regs.h"
 #include "DM9000A.h"
 //#include "ranger_functions.h"
 
#include <string.h>
//#include <ctype.h> 
#include <fcntl.h>
//#include <math.h>


 #define N_ROWS 40//64    // must be some multiple of ROWS_PER_PACKET
 #define START_ROW 41//20
 #define N_COLUMNS 64//80
 #define START_COLUMN 42//40
 // this array of size N_REGIONS specifies which regions are saved and sent.
 int selected_regions [] = {BL_BASE};
 #define N_REGIONS 1
 #define N_FRAMES 3000   // ~15.4 MB = N_REGIONS * N_FRAMES * N_COLUMNS * N_ROWS * 2 Bytes
 #define ROWS_PER_PACKET 10//8   // This is 1280 / 2 / N_COLUMNS
 /* Data packets consist of frame number (2 bytes), row number (2 bytes)
  * and 1280 bytes of data (1280 bytes)
  */
#define PACKET_DATA_SIZE 1286   
// Non data fields are:
// 0x00-0x01 = Region number 
// 0x02-0x03 = Frame number
// 0x04-0x05 = Row number
#define US_PER_FRAME 

/* Variables related to automatic capturing */
    int doShutdown = 0;
    int capture_complete = 0;
    int do_auto_capture = 1;
    int f = 0;
    int t = 0;
    int n = 0;
    int r = 0;
    int p_2 = 0;
    int p_1 = 0;
    int Ts_length = 1;
    int Fs_length = 4;
    int Ns_length = 1;
    int Rs_length = 1;
    int Ps_1_length = 1;
    int Ps_1[40];
    int Ps_2_length = 1;
    int Ps_2[40];
    //int Ts[] = {5000*120, 7500*120, 10000*120, 12500*120, 15000*120, 20000*120, 25000*120, 30000*120, 35000*120, 40000*120, 50000*120, 60000*120, 75000*120};
    //int Ms_1[] =    {105, 102, 99, 96, 93, 90, 87, 84, 81, 78, 75, 72, 69, 132, 126, 120, 114, 108, 102, 96, 90, 84, 78, 72, 69, 132, 126, 120, 114, 108, 96, 84, 72, 60, 120, 90, 60, 60, 48};
    //int Ms_2[] =    {105, 102, 99, 96, 93, 90, 87, 84, 81, 78, 75, 72, 69, 132, 126, 120, 114, 108, 102, 96, 90, 84, 78, 72, 69, 132, 126, 120, 114, 108, 96, 84, 72, 60, 120, 90, 60, 60, 48};
    //double Fs_1[] = { 70,  68, 66, 64, 62, 60, 58, 56, 54, 52, 50, 48, 46,  44,  42,  40,  38,  36, 34,  32, 30, 28, 26, 24, 23,  22,  21,  20,  19,  18, 16, 14, 12, 10, 8,  6,  4,   2,   1};
    //double Fs_2[] = { 70,  68, 66, 64, 62, 60, 57, 56, 54, 52, 50, 48, 46,  44,  42,  40,  38,  36, 34,  32, 30, 28, 26, 24, 23,  22,  21,  20,  19,  18, 16, 14, 12, 10, 8,  6,  4,   2,   1};
    //int Ts[] = {16667*60, 20000*60, 25000*60, 33334*60, 40000*60, 50000*60, 66667*60};
    int Ts[] = {40000};
    //int Ms_1[] =    {48,60,60, 60, 90, 60, 75};
    //int Ms_2[] =    {48,60,60, 60, 90, 60, 75};
    //double Fs_1[] = {1, 4, 10, 20, 30, 40, 50};
    //double Fs_2[] = {1, 4, 10, 20, 30, 40, 50};
    int Ms_1[] = {114, 120, 126, 132};
    int Ms_2[] = {114, 120, 126, 132};
    double Fs_1[] = {19, 20, 21, 22};
    double Fs_2[] = {19, 20, 21, 22};
    double Ns_1[] = {1};
    double Ns_2[] = {1};
    int Rs[] = {0};//, 255, 13, 26, 38, 51, 64, 77, 90, 102, 115, 128, 141, 154, 166, 179, 192, 205, 218, 230, 243};
    //int Rs[] = {0, 255, 26, 51, 77, 102, 128, 154, 179, 205, 230};
    
    int set_number = 0;
    int MAX_SETS = 1;


/* FrameBuffer temporarily stores frame data during interrupt handler.
 * Main function reads it and transmits to PC if enabled.
 */
static unsigned int frameBuffer [N_REGIONS][N_FRAMES][N_ROWS][N_COLUMNS+1];

void updateAutoCapture();

volatile unsigned int frame_received_count = 0;
unsigned int frame_sent_index = 0;
int ether_capturing = 0;
int capturing = 0;
double fpb_1 = 5;
double fpb_2 = 5;
unsigned int fp_output = 5;
double mf1 = 40;
double mf2 = 40;
unsigned int mod_ratio = 0;
unsigned int adcOffsetLeft = 255;
unsigned int adcOffsetRight = 255;
unsigned int adcGainLeft = 20;
unsigned int adcGainRight = 20;
double dutyCycleCamera = 50;
double dutyCycleLaser = 50;
unsigned int intTime = 50000;
unsigned int frameTime = 50000;
unsigned int phaseStepInit1 = 0;
unsigned int phaseStepInit2 = 0;
unsigned int phaseStep1 = 4;
unsigned int phaseStep2 = 4;
unsigned int phaseInc1 = 4;
unsigned int phaseInc2 = 4;
unsigned int pll_count1_hi = 13;
unsigned int pll_count1_lo = 12;
unsigned int pll_count2_hi = 13;
unsigned int pll_count2_lo = 12;
unsigned int pll_c_rsel_1 = 0;
unsigned int pll_c_rsel_2 = 0;
unsigned int pll_m_count1 = 120;
unsigned int pll_m_count2 = 120;
unsigned int pll_vco1 = 1200;
unsigned int pll_vco2 = 1200;
unsigned int correction_x = 55;
unsigned int correction_y = 60;
unsigned int correction_z = 1530;
unsigned int testPixels [] = {75,70,62,70,75,45,62,45,75,32,62,32};
unsigned int maxPixels = 6;
unsigned int nPixels = 6;
double output_scale = 10;
int cycles_per_capture = 52;
int readoutTime = 3000;  // Minimum is 3200 us = 3.2 ms.


// These variables relate to untested implementation
// of capturing and sending frames in blocks.
int framesPerBlock;
int totalFrames;

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
    //printf("Restarting...\n");
    //IOWR(CONTROL_BASE, 7, 1);   // Pause
    
    frame_received_count = 0;   // Reset frame counter
    frame_sent_index = 0;
    IOWR(CONTROL_BASE, 7, 0);   // unpause
    IOWR(CONTROL_BASE, 10, 1);   // Reset
    //usleep(10);
    
}

void pause()
{
    
    IOWR(CONTROL_BASE, 7, 1); 
    //printf("Pausing...\n"); 
    //usleep(10); 
}

void setCapture(unsigned int c, int verbose)
{
    if(ether_capturing == DMFE_SUCCESS)
    {
    if(c == 0)
    {
        //pause();
        capturing = 0;
        IOWR(CONTROL_BASE, 3, 0);
        if(verbose)printf("Capturing disabled\n"); 
        restart();  
    }   
    else
    {
        //pause();
        capturing = c;
        //usleep(1000);
        if(verbose)printf("Capturing %d frames\n", c);
        IOWR(CONTROL_BASE, 3, c);
        restart(); 
    }
    }
    else
        if(verbose)printf("Ethernet unavailable. Capturing disabled\n");
}


/* Applies a phase correction to each of the individual phase values.
 * Expected distance is in mm for pixel(c_x,c_y) */
void phaseCorrect(unsigned int c_x, unsigned int c_y, unsigned int expected_distance)
{
    double du1 = 150000/mf1;
    double expected_phase1 = expected_distance;
    while(expected_phase1 > du1) expected_phase1 -= du1;
    expected_phase1 = expected_phase1*65536/du1;
    double du2 = 150000/mf2;
    double expected_phase2 = expected_distance;
    while(expected_phase2 > du2) expected_phase2 -= du2;
    expected_phase2 = expected_phase2*65536/du2;
    correction_x = c_x;
    correction_y = c_y;
    correction_z = expected_distance;
    unsigned int ps1 = readPixel(correction_x,correction_y,2);
    unsigned int ps2 = readPixel(correction_x,correction_y,3);
    ps1 = (unsigned int)(expected_phase1)-ps1;
    ps1 = ps1+IORD(CONTROL_BASE,13);
    IOWR(CONTROL_BASE, 13, ps1);
    ps2 = (unsigned int)(expected_phase2)-ps2; 
    ps2 = ps2+IORD(CONTROL_BASE,14);
    IOWR(CONTROL_BASE, 14, ps2);
    //printf("Expected phase 1: %.0f\tExpected phase 2: %.0f\n", expected_phase1, expected_phase2);
}

/* Changes frames per beat.
 * Finished with a phase correction */
void setFPB(double f_1, double f_2, unsigned int fpo, int verbose)
{
    
    fpb_1 = f_1;
    fpb_2 = f_2;
    IOWR(CONTROL_BASE, 16, fpo);
    IOWR(CONTROL_BASE, 17, fpo);
    phaseStep1 = (unsigned int)(((pll_count1_hi+pll_count1_lo) * 8)/f_1);
    phaseStep2 = (unsigned int)(((pll_count2_hi+pll_count2_lo) * 8)/f_2);
    if(phaseStep1<1)phaseStep1 = 1;
    if(phaseStep2<1)phaseStep2 = 1;
    IOWR(CONTROL_BASE, 18, phaseStep1);
    IOWR(CONTROL_BASE, 19, phaseStep2);
    fpb_1 = (8*(pll_count1_hi+pll_count1_lo))/phaseStep1;
    fpb_2 = (8*(pll_count2_hi+pll_count2_lo))/phaseStep2;
    if(verbose)printf("Changing FPB: fpb1: %3.1f, fpb2: %3.1f, step1: %d, step2: %d, N: %d\n",
        fpb_1, fpb_2, phaseStep1, phaseStep2, fpo);
    
    fp_output = fpo;
    IOWR(CONTROL_BASE, 8, fp_output); 
    setCapture(0,verbose);
    /*if(verbose)printf("Please wait for phase correction");
    for(fpo = 0; fpo < 8; fpo++){
        usleep(intTime*fp_output/2); 
        if(verbose)printf(".");
    }
    
    phaseCorrect(correction_x,correction_y,correction_z);
    if(verbose)printf("complete\n");
    */
}

void setTime(unsigned int framePeriod, unsigned int integrationPeriod, int verbose)
{
    if(framePeriod == integrationPeriod) integrationPeriod = framePeriod - readoutTime;
    if(framePeriod < 3200)
    {
        printf("Frame period is less than readout period. No change!\n");
        return;
    }
    frameTime = framePeriod;
    
  
    IOWR(CONTROL_BASE, 0, frameTime);
    IOWR(CONTROL_BASE, 1, integrationPeriod);
    // Get actual integration period, which is reduced due to readout time.
    intTime = IORD(CONTROL_BASE, 2);
    if(verbose)printf("Changing Frame Period: %d us, Integration Time: %d us\n", frameTime, intTime);
  
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
    printf("Changing ADC Params: o/s left: %d, o/s right: %d, g left: %d, g right: %d\n", offset_left, offset_right, gain_left, gain_right);
}

/* Alternative setFrequency method. One frequency only (ie, ratio = 0)
 * Directly sets m1, c_hi, c_lo.
 * Also, does not restart sensor if paused.
 */
void setFreq(unsigned int m1, unsigned int c_hi, unsigned int c_lo, int verbose)
{
    
    if(m1*10 > 1450 || m1*10 < 400) m1 = 120; // See Stratix 3 Handbook!
    unsigned int VCO = m1*10;  // Ensures m1_hi = m1_lo
    mf1 = (double)VCO/(c_hi+c_lo);
    
    mf2 = mf1;
    pll_count1_hi = c_hi;
    pll_count1_lo = c_lo;
    pll_count2_hi = c_hi;
    pll_count2_lo = c_lo;
    pll_m_count1 = m1;
    pll_m_count2 = m1;
    mod_ratio = 0;
    pll_vco1 = VCO;
    pll_vco2 = VCO;
    
    IOWR(CONTROL_BASE, 36, pll_count1_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 37, pll_count1_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 38, pll_count1_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 39, pll_count1_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 40, m1/2);
    usleep(100);
    IOWR(CONTROL_BASE, 41, m1-m1/2);
    usleep(100);
    if(c_hi != c_lo) pll_c_rsel_1 = 3; else pll_c_rsel_1 = 0;
    IOWR(CONTROL_BASE, 42, pll_c_rsel_1);
    usleep(100); 
    IOWR(CONTROL_BASE, 35, 1);
    usleep(1000);
     
     // Update PLL2
    IOWR(CONTROL_BASE, 52, pll_count2_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 53, pll_count2_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 54, pll_count2_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 55, pll_count2_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 56, m1/2);
    usleep(100);
    IOWR(CONTROL_BASE, 57, m1-m1/2);
    usleep(100);
    if(c_hi != c_lo) pll_c_rsel_2 = 3; else pll_c_rsel_2 = 0;
    IOWR(CONTROL_BASE, 58, pll_c_rsel_2);
    usleep(100); 
    IOWR(CONTROL_BASE, 51, 1);
    
    IOWR(CONTROL_BASE,20,0);
    unsigned int scale = (unsigned int)65536/(pll_count1_hi+pll_count1_lo)/8;
    IOWR(CONTROL_BASE, 24, scale);
    scale = (unsigned int)65536/(pll_count2_hi+pll_count2_lo)/8;
    IOWR(CONTROL_BASE, 25, scale);
    
    
    if(verbose)printf("Changed frequencies: %3.3f and %3.3f MHz, ratio: %d\n", mf1, mf1, mod_ratio);
    if(verbose)printf("PLL parameters: m1: %d\tm2: %d\tVCO1: %d\tVCO2: %d\tc_hi: %d\tc_lo: %d\n",m1,m1,pll_vco1, pll_vco2, c_hi,c_lo);
    setFPB(fpb_1,fpb_2,fp_output,verbose);
}


/*  Pauses ranging, changes frequency, updates PLL, restarts.
 *  Prints out actual frequency using integer divider of VCO,
 *  and actual duty cycles, where rselodd is always 'even'
 * EDIT:  DC fixed at 50%. Parameters are now <freq1> <freq2> <ratio>
 * If frequency1 or 2 inputs are greater than 1000, they are assumed to be in kHz.
 * MAJOR CHANGE:
 * Attempts to keep c counters equal, changes frequency by changing m counters.
 * frequency1 MUST be greater than frequency2.
 */
void setFrequency(unsigned int m1, unsigned int m2, double frequency1, double frequency2, unsigned int ratio, int verbose)
{
    setCapture(0,verbose);
    if(m1*10 > 1400 || m1*10 < 400) m1 = 120; // See Stratix 3 Handbook!
    if(m2*10 > 1400 || m2*10 < 400) m2 = 120; // See Stratix 3 Handbook!
    double f1 = (double)frequency1;
    if(f1 > 1000) f1 = f1/1000;
    double f2 = (double)frequency2;
    if(f2 > 1000) f2 = f2/1000;
   
    // Recalculate to get actual VCO1.
    unsigned int VCO1 = m1*10;  // Ensures m1_hi = m1_lo
    unsigned int c1 = (unsigned int)(VCO1/f1);
    unsigned int VCO2 = m2*10;
    unsigned int c2 = (unsigned int)(VCO2/f2);
  
    pll_count1_hi = c1-c1/2;
    pll_count1_lo = c1/2;
    pll_count2_hi = c2-c2/2;
    pll_count2_lo = c2/2;
    pll_m_count1 = m1;
    pll_m_count2 = m2;
    
    // Update phase scale values.
    unsigned int scale = (unsigned int)65536/(pll_count1_hi+pll_count1_lo)/8;
    IOWR(CONTROL_BASE, 24, scale);
    scale = (unsigned int)65536/(pll_count2_hi+pll_count2_lo)/8;
    IOWR(CONTROL_BASE, 25, scale);
    
    mf1 = (double)(VCO1)/c1;
    mf2 = (double)(VCO2)/c2;
    
    //pause();
    // Update PLL1. Ensuring if c1/c2 ~= c1 - c1/c2 that hi count is larger.
    IOWR(CONTROL_BASE, 36, pll_count1_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 37, pll_count1_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 38, pll_count1_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 39, pll_count1_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 40, m1/2);
    usleep(100);
    IOWR(CONTROL_BASE, 41, m1-m1/2);
    usleep(100);
    // Set r_sel_odd to ensure 50% duty cycle.
    if((c1-c1/2) != c1/2) pll_c_rsel_1 = 3; else pll_c_rsel_1 = 0;
    IOWR(CONTROL_BASE, 42, pll_c_rsel_1);
    usleep(100); 
    IOWR(CONTROL_BASE, 35, 1);
    usleep(1000);
     
     // Update PLL2
    IOWR(CONTROL_BASE, 52, pll_count2_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 53, pll_count2_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 54, pll_count2_hi);
    usleep(100);
    IOWR(CONTROL_BASE, 55, pll_count2_lo);
    usleep(100);
    IOWR(CONTROL_BASE, 56, m2/2);
    usleep(100);
    IOWR(CONTROL_BASE, 57, m2-m2/2);
    usleep(100);
    if((c2-c2/2) != c2/2) pll_c_rsel_2 = 3; else pll_c_rsel_2 = 0;
    IOWR(CONTROL_BASE, 58, pll_c_rsel_2);
    usleep(100); 
    IOWR(CONTROL_BASE, 51, 1);
    
    pll_vco1 = VCO1;
    pll_vco2 = VCO2;
    
    mod_ratio = ratio;
    IOWR(CONTROL_BASE,20,mod_ratio);
    dutyCycleCamera = 50;
    dutyCycleLaser = 50;
    
    // Now update disambiguation parameters.
    double m1_d = m1*c2;
    //if(c1 > c2) m1_d = m1_d*c2/c1;
    double m2_d = m2*c1;
    //if(c2 > c1) m2_d = m2_d*c1/c2;
    double g = (double)(gcd((unsigned int)m1_d,(unsigned int)m2_d));
    //printf("GCD: %.0f\tM: %.0f\tN: %.0f\n",g,m1_d,m2_d);
    m1_d = m1_d/g;
    m2_d = m2_d/g;
    //printf("GCD: %.0f\tM: %.0f\tN: %.0f\n",g,m1_d,m2_d);
    IOWR(CONTROL_BASE, 26, (unsigned int)m1_d);
    IOWR(CONTROL_BASE, 27, (unsigned int)m2_d);
    // Calculate weighting values
    double r = 20;
    double temp = (1500000/mf1)/m2_d;
    while(temp > 4095){
         temp /= 2;
         r /= 2;
    }
    output_scale = r;
    IOWR(CONTROL_BASE,30,(unsigned int)temp);
    IOWR(CONTROL_BASE,31,(unsigned int)temp);
    
    if(verbose)printf("Output Scale: %.2f = 1mm\n",r);
    //if(verbose)
        printf("Changed frequencies: %3.3f and %3.3f MHz, ratio: %d\n", mf1, mf2, mod_ratio);
    //if(verbose)
        printf("PLL parameters: m1: %d\tm2: %d\tVCO1: %d\tVCO2: %d\tc1: %d\tc2: %d\trso: %d+%d\n",m1,m2,pll_vco1, pll_vco2, c1,c2,pll_c_rsel_1,pll_c_rsel_2);
    setFPB(fpb_1,fpb_2,fp_output,verbose);
    
    
    
   
}

void setPhaseStep(unsigned int ps1, unsigned int ps2, int verbose)
{
    IOWR(CONTROL_BASE, 33, ps1);
    phaseStepInit1 = ps1;
    IOWR(CONTROL_BASE, 49, ps2);
    phaseStepInit2 = ps2;
    if(verbose)printf("Changed Initial Phase Steps: %d and %d\n", phaseStepInit1, phaseStepInit2);
    usleep(100);   
    restart();
}

/* Prints system parameters in the same format as expected by a .set file.
 * Also sends a packet with parameter information to PC if ethernet_capturing is enabled
 */
 void printParameters(int verbose)
 {
    mod_ratio = IORD(CONTROL_BASE, 20);
    if(verbose){
    printf("MF1 %f\n",mf1);
    printf("MF2 %f\n",mf2);
    printf("FPB1 %5.1f\n",fpb_1);
    printf("FPB2 %5.1f\n",fpb_2);
    printf("FPOUTPUT %d\n",fp_output);
    printf("INTTIME %d\n",intTime);
    printf("FRAMETIME %d\n",frameTime);
    printf("NCAPTURES %d\n",capturing);
    printf("MODRATIO %d\n",mod_ratio);
    printf("ADCOLEFT %d\n",adcOffsetLeft);
    printf("ADCORIGHT %d\n",adcOffsetRight);
    printf("ADCGLEFT %d\n",adcGainLeft);
    printf("ADCGRIGHT %d\n",adcGainRight);
    printf("DCCAMERA %f\n",dutyCycleCamera);
    printf("DCLASER %f\n",dutyCycleLaser);
    printf("PLLCOUNT1_HI %d\n", pll_count1_hi);
    printf("PLLCOUNT1_LO %d\n", pll_count1_lo);
    printf("PLLCOUNT2_HI %d\n", pll_count2_hi);
    printf("PLLCOUNT2_LO %d\n", pll_count2_lo);
    printf("PLLMCOUNT1 %d\n", pll_m_count1);
    printf("PLLMCOUNT2 %d\n", pll_m_count2);
    printf("PHASESTEP1 %d\n", phaseStep1);
    printf("PHASESTEP2 %d\n", phaseStep2);
    printf("PHASESTEPINIT1 %d\n", phaseStepInit1);
    printf("PHASESTEPINIT2 %d\n", phaseStepInit2);
    }
    if(ether_capturing == DMFE_SUCCESS)
    {
        printf("Sending Parameter Packet\n");
        int j = 0; 
        DM9000_transmit_init(PACKET_DATA_SIZE + (MAC_HL + IP_HL + UDP_HL)*2);
    
        for(j = 0; j < MAC_HL + IP_HL + UDP_HL; j++)
        {
            IOWR(DM9000A_BASE, IO_data, Packet_Header[j]);
        }

        // Send special case region, frame and row numbers.       
        IOWR(DM9000A_BASE, IO_data, -1);
        IOWR(DM9000A_BASE, IO_data, -1); 
        IOWR(DM9000A_BASE, IO_data, -1);
                    
        // Send remainder of packet, padded out to 1280 bytes (640 * 16-bits).
        IOWR(DM9000A_BASE, IO_data, cycles_per_capture);
        IOWR(DM9000A_BASE, IO_data, (pll_m_count1<<8) + pll_m_count2);
        IOWR(DM9000A_BASE, IO_data, (pll_count2_hi<<8) + pll_count2_lo);
        IOWR(DM9000A_BASE, IO_data, (pll_count1_hi<<8) + pll_count1_lo);
        IOWR(DM9000A_BASE, IO_data, (pll_c_rsel_1<<8) + pll_c_rsel_2);
        IOWR(DM9000A_BASE, IO_data, (fp_output<<8) + mod_ratio);
        IOWR(DM9000A_BASE, IO_data, phaseStepInit2);
        IOWR(DM9000A_BASE, IO_data, phaseStepInit1);
        IOWR(DM9000A_BASE, IO_data, phaseStep2);
        IOWR(DM9000A_BASE, IO_data, phaseStep1);
        IOWR(DM9000A_BASE, IO_data, frameTime);
        IOWR(DM9000A_BASE, IO_data, frameTime>>16);
        IOWR(DM9000A_BASE, IO_data, intTime);
        IOWR(DM9000A_BASE, IO_data, intTime>>16);
        IOWR(DM9000A_BASE, IO_data, (adcGainLeft<<8) + adcGainRight);
        IOWR(DM9000A_BASE, IO_data, (adcOffsetLeft<<8) + adcOffsetRight);
        
        
        for(j = 0x26; j < PACKET_DATA_SIZE; j+=2)
        {
            IOWR(DM9000A_BASE, IO_data, -1);
        }
        // Complete packet
        DM9000_transmit_complete();
    }
 }
 
 /* Prints available user commands */
 void printHelp()
 {
    printf("\nUser Commands. All parameters are required where listed.\n");
    printf("For FPGA control register addresses, see PMD_register_map.xls.\n");
    printf("--------------------------------------------------------------\n");
    printf("help : prints this help text.\n");    
    printf("print params : prints current state of system parameters.\n");
    printf("wc <address> <data> : write to FPGA control register.\n");
    printf("rc <address> : read from FPGA control register.\n");
    printf("wtl <col> <row> <value> : writes to specified column/row of top left.\n");
    printf("wtr / wbl / wbr : same as wtl but for top right, bottom left and bottom right.\n");
    printf("rtl <col> <row> : reads pixel from specified column/row of top left.\n");
    printf("rtr / rbl / rbr : same as rtl but for top right, bottom left and bottom right.\n");
    printf("reinit : reinitialises DM9000A ethernet controller.\n");
    printf("set fpb <fpb_1> <fpb_2> <fpof> : sets frames per beat.\n");
    printf("set fpb <fpb_1> <fpof> : As above, but fpb_2 = fpb_1/2.\n");
    printf("set frequency <f_1> <f_2> <ratio> : Sets PLL frequencies and integration ratio\n");
    printf("(frequency less than 1000 is considered MHz, > 1000 is considered kHz)\n");
    printf("set phase <phase_1> <phase_2> : introduces a phase offset in PLLs.\n");
    printf("(These offsets are in raw phase steps - actual step dependent on pll counts)\n");
    printf("set time <frame time> <integration time> : all times in us\n");
    printf("set adc <left_offset> <right_offset> <left_gain> <right_gain>.\n");
    printf("phase correct <phase_1> <phase_2> : Adds a phase offset to processed values.\n");
    printf("c <nFrames> : captures given number of frames. 0 continues indefinitely.\n");
    printf("(nFrames != 0 sends frames out ethernet)\n");
    printf("pause : pauses frame capture.\n");
    printf("restart : restarts frame capture. Recommend using 'c <nFrames>' command\n");
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

void startAutoCapture(int cycles)
{
    
                cycles_per_capture = cycles;
                printf("Beginning Set %d. Capturing %d cycles\n", set_number, cycles_per_capture);
    f = 0;  n = 0; t = 0; r = 0; p_2 = 0; p_1 = 0; capture_complete = 0;
                
                setFrequency(Ms_1[f],Ms_2[f],Fs_1[f],Fs_2[f],Rs[r],0);
                setFPB(Ns_1[n],Ns_2[n],Ns_1[n],0);
                setTime(Ts[t]/Ns_1[n],Ts[t]/Ns_1[n],0);
                setPhaseStep(Ps_1[p_1],Ps_2[p_2],0);
                usleep(1000000); 
                printParameters(0);
                printf("* * * * %d %d %d %d %d %d %d %d * * * *\n", (int)Fs_1[f], 
                        (int)Fs_2[f], (int)Ns_1[n], (int)Ns_2[n], Ts[t]/1000, Rs[r], Ps_2[p_2], Ps_1[p_1]);
                setCapture(cycles_per_capture*fp_output,1);
}

int processCommand(char * userInput, int userInputLength)
{
       
    int userParams [50];
    int nParams = 0;
    if(userInputLength > 0)
    {
        nParams = getUserParams(userInput, userParams);
        //printf("ECHO: %s : nParams:%d\n", userInput,nParams);
        //printf("%d %d %d %d\n", userInputLength, nParams, userParams[0], userParams[1]);
        
        // Write Commands
        if(strncmp(userInput, "wtl ", 4) == 0)
            if(nParams == 3)
            {
                writePixel(userParams[0], userParams[1], 0, userParams[2]);
            }
            else
                printf("wtl: Incorrect number of parameters\n");
        else if(strncmp(userInput, "wtr ", 4) == 0)
            if(nParams == 3)
            {
                writePixel(userParams[0], userParams[1], 1, userParams[2]);
            }
            else
                printf("wtr: Incorrect number of parameters\n");
        else if(strncmp(userInput, "wbl ", 4) == 0)
            if(nParams == 3)
            {
                writePixel(userParams[0], userParams[1], 2, userParams[2]);
            }
            else
                printf("wbl: Incorrect number of parameters\n");
        else if(strncmp(userInput, "wbr ", 4) == 0)
            if(nParams == 3)
            {
                writePixel(userParams[0], userParams[1], 3, userParams[2]);
            }
            else
                printf("wbr: Incorrect number of parameters\n");
        else if(strncmp(userInput, "wc ", 3) == 0)
            if(nParams == 2)
            {
                IOWR(CONTROL_BASE, userParams[0], userParams[1]);
                printf("%s\n", userInput);
            }
            else
                printf("wc: Incorrect number of parameters\n");
        // Write DM9000
        else if(strncmp(userInput, "wn ", 3) == 0)
            if(nParams == 2)
            {
                iow(userParams[0], userParams[1]);
                printf("%s\n", userInput);
            }
            else
                printf("wn: Incorrect number of parameters\n");
        // Read Commands
        else if(strncmp(userInput, "rtl ", 4) == 0)
            if(nParams == 2)
            {
                userParams[4] = readPixel(userParams[0], userParams[1], 0);
                printf("%s: %d  %x\n", userInput, userParams[4], userParams[4]);
            }
            else
                printf("rtl: Incorrect number of parameters\n");
        else if(strncmp(userInput, "rtr ", 4) == 0)
            if(nParams%2 == 0 && nParams >= 2 && nParams < 20)
            {
                int i = 0;
                for(i = 0; i < nParams; i+=2)
                {
                    userParams[20] = readPixel(userParams[i], userParams[i+1], 1);
                    printf("rtr %d %d: ", userParams[i], userParams[i+1]);
                    printf("%d %x (%.1f mm)\n", userParams[20], userParams[20], (double)(userParams[20])/output_scale);
                }
            }
            else
                printf("rtr: Incorrect number of parameters\n");  
        else if(strncmp(userInput, "rbl ", 4) == 0)
            if(nParams == 2)
            {
                userParams[4] = readPixel(userParams[0], userParams[1], 2);
                printf("%s: %d  %x\n", userInput, userParams[4], userParams[4]);
            }
            else
                printf("rbl: Incorrect number of parameters\n"); 
        else if(strncmp(userInput, "rbr ", 4) == 0)
            if(nParams == 2)
            {
                userParams[4] = readPixel(userParams[0], userParams[1], 3);
                printf("%s: %d  %x\n", userInput, userParams[4], userParams[4]);
            }
            else
                printf("rbr: Incorrect number of parameters\n"); 
        else if(strncmp(userInput, "rc ", 3) == 0)
            if(nParams == 1)
            {
                userParams[4] = IORD(CONTROL_BASE, userParams[0]);
                printf("%s: %d  %x\n", userInput, userParams[4], userParams[4]);
            }
            else
                printf("rc: Incorrect number of parameters\n"); 
        // Read DM9000 register
        else if(strncmp(userInput, "rn ", 3) == 0)
            if(nParams == 1)
            {
                userParams[4] = ior(userParams[0]);
                printf("%s: %d  %x\n", userInput, userParams[4], userParams[4]);
            }
            else
                printf("rn: Incorrect number of parameters\n"); 
        // Read Frame Buffer
        else if(strncmp(userInput, "rb ", 3) == 0)   
            if(nParams == 3) 
            {
                userParams[4] = frameBuffer[userParams[0]][userParams[1]][userParams[2]][userParams[3]];
                printf("%s: %d  %x\n", userInput, userParams[4], userParams[4]);
            }
            else
                printf("rb: Incorrect number of parameters\n"); 
        
        else if(strncmp(userInput, "restart", 7) == 0)
            restart();
        else if(strncmp(userInput, "pause", 5) == 0)
            pause();
        else if(strncmp(userInput, "print params", 12) == 0)
        {
            printParameters(1);
        }
        else if(strncmp(userInput, "c ", 2) == 0)
        {
            if(nParams == 1)
            {
                capture_complete = 1;
                setCapture(userParams[0],1);
            }
            else
                printf("capture: Incorrect number of parameters\n");
        }
        else if(strncmp(userInput, "ac ", 3) == 0)
        {
            if(nParams == 1)
            {
                set_number = 0;
                startAutoCapture(userParams[0]);
            }
            else
                printf("auto capture: Incorrect number of parameters\nExpect 'ac <captures_per_cycle>'\n");
        }
        else if(strncmp(userInput, "reinit", 6) == 0)
        {
            ether_capturing = DM9000_init();
            if(ether_capturing == DMFE_SUCCESS) printf("DM9000 Initialisation successful\n");
            else printf("DM9000 Initialisation NOT successful\n");
        }
        else if(strncmp(userInput, "set fpb ", 8) == 0)
        {
            if(nParams == 2)
            {
                setFPB((double)userParams[0], ((double)(userParams[0]))/2, userParams[1],1); 
            }
            else if(nParams == 3)
            {
                setFPB((double)userParams[0], (double)userParams[1], userParams[2],1); 
            }
            else
               printf("set fpb: Incorrect number of parameters\nExpect 'set fpb <fpb_1> <frames per output>\n"); 
        }
        else if(strncmp(userInput, "set adc", 7) == 0)
        {
            if(nParams == 4)
            {
                setADCParams(userParams[0], userParams[1], userParams[2], userParams[3]);   
            }  
            else
               printf("set adc: Incorrect number of parameters\nExpect 'set adc <left_offset> <right_offset> <gain left> <gain right>\n"); 
         
        }
        else if(strncmp(userInput, "set phase ", 10) == 0)
        {
            if(nParams == 2)
            {
                setPhaseStep(userParams[0], userParams[1],1);   
            }  
            else
               printf("set phase: Incorrect number of parameters\nExpect 'set phase <phase_step1> <phase_step2>\n"); 
         
        }
        else if(strncmp(userInput, "phase inc", 9) == 0)
        {
            if(nParams == 2)
            {
                phaseInc1 = userParams[0];
                phaseInc2 = userParams[1];
            }   
            setPhaseStep(phaseStepInit1+phaseInc1, phaseStepInit2+phaseInc2,1);
        }
        else if(strncmp(userInput, "set frequency ", 14) == 0)
        {
            if(nParams == 5)
                setFrequency(userParams[0], userParams[1], userParams[2], userParams[3], userParams[4],1); 
            else if(nParams == 4)
                setFrequency(120,userParams[0], userParams[1], userParams[2], userParams[3],1); 
            else if(nParams == 3)
                setFrequency(120,120, userParams[0], userParams[1], userParams[2],1);  
            else if(nParams == 2)
                setFrequency(120,120, userParams[0], userParams[1], 128,1); 
            else if(nParams == 1)
                setFrequency(120,120, userParams[0], userParams[0], 0,1);   
            else
               printf("set frequency: Incorrect number of parameters\nExpect 'set frequency <frequency1> <frequency2> <ratio>\n"); 
         
        }
        else if(strncmp(userInput, "set freq ", 9) == 0)
        {
            if(nParams == 3)
                setFreq(userParams[0], userParams[1], userParams[2],1); 
            else
               printf("set freq: Incorrect number of parameters\nExpect 'set frequency <m> <c_hi> <c_lo>\n"); 
         
        }
        else if(strncmp(userInput, "set time ", 9) == 0)
        {
            if(nParams == 2)
            {
                setTime(userParams[0], userParams[1],1); 
            }
            else if(nParams == 1)
            {
                setTime(userParams[0],userParams[0],1);
            }
            else
               printf("set time: Incorrect number of parameters\nExpect 'set time <frame period (us)> <integration period (us)>\n");      
        }
        else if(strncmp(userInput, "test pixels", 11) == 0)
        {
            int i = 0;
            if(nParams % 2 == 0 && nParams <= maxPixels*2 && nParams > 0)
            {
                for(i = 0; i < nParams; i++)
                    testPixels[i] = userParams[i];   
                nPixels = nParams / 2; 
            }
            printf("Test pixel distances:\n");
            for(i = 0; i < nPixels; i++)
            {
                userParams[0] = readPixel(testPixels[i*2],testPixels[i*2+1],1);
                printf("(%d,%d)\t%d = %.1f mm\n",testPixels[i*2],testPixels[i*2+1],userParams[0],(double)(userParams[0])/output_scale);
            }
        }
        else if(strncmp(userInput, "help",4) == 0)
            printHelp();
        else if(strncmp(userInput, "phase correct",13) == 0)
        {
            if(nParams == 0)
            {
                phaseCorrect(correction_x, correction_y, correction_z);    
            }
            else if(nParams == 1)
            {
                phaseCorrect(correction_x, correction_y, userParams[0]); 
            }
            else if(nParams == 3)
            {
                phaseCorrect(userParams[0], userParams[1], userParams[2]); 
            }
            else
               printf("phase correct: Incorrect number of parameters\nExpect 'phase correct <expected_1> <expected_2>\n");      
        }
        // Invalid Command
        else
            printf("%s: Unknown Command. Type 'help' for list of commands.\n", userInput);  
            
                   
                 
    }
}

/*
 * Interrupt handler for new frame received by hardware.
 * Transfers new frame to frameBuffer and increments frame_count_ptr aka frame_received_count
 */
static void isr_frame_received(void* context, alt_u32 id)
{
    volatile unsigned int* frame_count_ptr = (volatile int*) context;
    int i = 0;
    int region = 0;
    int row = START_ROW * 1024;
    unsigned int frame = (*frame_count_ptr)%N_FRAMES;
   
    if(capturing)
    {
        // Read frame into frameBuffer
        for(region = 0; region < N_REGIONS; region++)
        {
            row = START_ROW * 1024;
        for(i = 0; i < N_ROWS; i++)
        {
            // Copy 640 bytes = 160 * 4 byte ints.
            memcpy(frameBuffer[region][frame][i], selected_regions[region] + row + 4*START_COLUMN, 4*N_COLUMNS);
            // Increment row by 256 * 4 bytes.
            row = row + 1024;
        }
        
        }
        *frame_count_ptr = *frame_count_ptr + 1;
    }
    // acknowledge
    IOWR(CONTROL_BASE, 6, 1);
}




int main()
{
    int i = 0, j = 0, k = 0, region = 0;
    //int address = 0;
    unsigned int index = 0;
    int data = 0;
    int readflags = O_RDWR | O_NONBLOCK | O_NOCTTY;
    int readFile = 0;
    char userInput [256];
    char prevInput [256];
    int userInputLength = 0;
    int prevLength = 0;
    void* frame_received_ptr = (void*) &frame_received_count;
    
    // These variables for automating the captures.
    unsigned int time_current = 0, time_previous = 0;
    unsigned int time_since_input = 0;
    
    
    
     
    // Fill out phases, equally spaced, dependent on steps_per_cycle
    for(p_1=0;p_1<Ps_1_length;p_1++)Ps_1[p_1]=p_1*Ms_1[0]*80/Fs_1[0]/Ps_1_length;
    for(p_2=0;p_2<Ps_2_length;p_2++)Ps_2[p_2]=p_2*Ms_2[0]*80/Fs_2[0]/Ps_2_length;
    p_1 = 0;
    p_2 = 0;
    
    
    
    ether_capturing = DMFE_FAIL;
    
    createHeader(Packet_Header, PACKET_DATA_SIZE);
    capturing = 0;
    // Initialise frame_received PIO interrupt
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(FRAME_RECEIVED_BASE, 0xf);
    alt_irq_register( FRAME_RECEIVED_IRQ, frame_received_ptr, isr_frame_received );
    frame_received_count = 0;
    frame_sent_index = 0;
    printf("Initialising DM9000...\n");
    ether_capturing = DM9000_init();
    ether_capturing = DM9000_init();
    if(ether_capturing == DMFE_SUCCESS) printf("DM9000 Initialisation successful\n");
    else printf("DM9000 Initialisation NOT successful\n");
 
    setCapture(0,1);
    setADCParams(adcOffsetLeft, adcOffsetRight, adcGainLeft, adcGainRight);
    setTime(Ts[0]/Ns_1[0],Ts[0]/Ns_1[0],1);
    
    setFrequency(Ms_1[0], Ms_2[0],Fs_1[0],Fs_2[0],Rs[0],1);
    setFPB(Ns_1[0],Ns_2[0],Ns_1[0],0);
    setPhaseStep(Ps_1[0],Ps_2[0],1);
    // Do this one again, because it doesn't seem to reliably go through.
    setADCParams(adcOffsetLeft, adcOffsetRight, adcGainLeft, adcGainRight);
    
    
    
    
    
    

    while(1)
    {
        // Check if any user input from terminal...
        readFile = open("/dev/jtag_uart", readflags);
        userInputLength = read(readFile,userInput,256);
        readFile = close(readFile);

        if(userInputLength > 0 && userInput[userInputLength-1] == '\n')
        {
            if(userInputLength == 3 && userInput[0] == 'p'){
                 processCommand(prevInput, prevLength);
            }
            else
            {
                userInput[userInputLength-1] = 0;
                userInput[userInputLength-2] = 0;
                processCommand(userInput, userInputLength);
                memcpy(prevInput,userInput,userInputLength);
                prevInput[userInputLength] = 0;
                prevInput[userInputLength-1] = 0;
                prevLength = userInputLength;  
            }
                     
            userInputLength = 0;
            userInput[0] = 0;
            time_since_input = 0;
            
        }
        // Send frames from frameBuffer, 2 rows per packet
        while(frame_received_count > frame_sent_index)
        {
            index = frame_sent_index % N_FRAMES; 
            if(capturing)
            {
           
                for(region = 0; region < N_REGIONS; region++)
                {
                for(i = 0; i < N_ROWS; i+=ROWS_PER_PACKET)
                {
                    DM9000_transmit_init(PACKET_DATA_SIZE + (MAC_HL + IP_HL + UDP_HL)*2);
    
                    for(j = 0; j < MAC_HL + IP_HL + UDP_HL; j++)
                    {
                        IOWR(DM9000A_BASE, IO_data, Packet_Header[j]);
                    }
                    // Data 0 = region number
                    IOWR(DM9000A_BASE, IO_data, region);
                    // Data 1 = frame number. Should match pixel0.        
                    IOWR(DM9000A_BASE, IO_data, frame_sent_index);
                    // Data 2 = row number.
                    IOWR(DM9000A_BASE, IO_data, i );
            
                    // Send ROWS_PER_PACKET rows.
                    for(k = 0; k < ROWS_PER_PACKET; k++)
                    {
                    for(j = 0; j < N_COLUMNS; j++)
                    {
                        data = frameBuffer[region][index][i+k][j];
                        IOWR(DM9000A_BASE, IO_data, data );
                    }
                    }
                 
                    DM9000_transmit_complete();
                    
                }
                }
                
            }// end if(capturing)
            else
            {
                int f = IORD(BR_BASE, 0);
                printf("%d ",f);
                if(f==0) printf("\n");
            }
            
            frame_sent_index++;
            time_current = IORD(CONTROL_BASE, 4);
            if(time_current - time_previous > 100000000)   // 100 MHz is counter frequency
            {
                
                time_previous = time_current;
                time_since_input++;
                //printf("%d\n", time_since_input);
            } 
        }// end while(frame_received_count > frame_sent_index)
        time_current = IORD(CONTROL_BASE, 4);
        if(do_auto_capture == 1 && (time_current - time_previous > 100000000))   // 100 MHz is counter frequency
            {
                
                time_previous = time_current;
                time_since_input++;
                // Work out if capture is likely complete.
                if(capturing > 0 && time_since_input*1000 > (frameTime*capturing/1000 + 1000))
                {
                    time_since_input = 0;
                    updateAutoCapture(0);
                }
                
            } 
        
            
    }// end while(1)

}

/* update parameters for autoCapture
 */
void updateAutoCapture()
{
     // Restart a capture

                    
    // Update counters. parameter heirarchy: f, n, t, r, p_2, p_1
    if (p_1 == Ps_1_length - 1) {
        for(p_1=0;p_1<Ps_1_length;p_1++)Ps_1[p_1]=p_1*Ms_1[f]*80/Fs_1[f]/Ps_1_length;
        p_1 = 0;
        if (p_2 == Ps_2_length - 1) {
            for(p_2=0;p_2<Ps_2_length;p_2++)Ps_2[p_2]=p_2*Ms_2[f]*80/Fs_2[f]/Ps_2_length;
            p_2 = 0;
            if (r == Rs_length - 1) {
                r = 0;
                if (t == Ts_length - 1) {
                    t = 0;
                    if (n == Ns_length - 1) {
                        n = 0;
                        if (f == Fs_length - 1) {
                                // End of set
                            setCapture(0,1);   
                            capture_complete = 1;
                            printf("Capturing Set Number %d Complete!\n", set_number);
                            set_number++;

                            if(set_number == MAX_SETS)
                            {
                                printf("All Sets complete\n");
                                setFrequency(60,60, 10, 10, 0,0);  
                                if(doShutdown == 1)
                                {
                                    printf("Turning off Lasers.\n");
                                    IOWR(CONTROL_BASE, 23, 0);
                                }
                            }
                            else if(set_number == 1)
                            {
                            // setup for next set
                                Ts_length = 3;
                                Rs_length = 21;
                                Fs_length = 2;
                                startAutoCapture(cycles_per_capture); 
                            }
                        } else {
                            f++;
                        }
                    } else {
                        n++;
                    }
                } else {
                    t++;
                }
            } else {
                r++;
            }

            setFrequency(Ms_1[f],Ms_2[f],Fs_1[f],Fs_2[f],Rs[r],0);
            setFPB(Ns_1[n],Ns_2[n],Ns_1[n],0);
            setTime(Ts[t]/Ns_1[n],Ts[t]/Ns_1[n],0);
            usleep(2000000); 

        } else {
            p_2++;
        }
    } else {
        p_1++;
    }

    if(!capture_complete)
    {
        //setPhaseStep(Ps_1[p_1],Ps_2[p_2],0);
        phaseStepInit1++;
        printParameters(0);
        printf("* * * * %d %d %d %d",(int)Fs_1[f],(int)Fs_2[f], (int)Ns_1[n], (int)Ns_2[n]);
        printf(" %d %d %d %d * * * *\n", 
        Ts[t]/1000, Rs[r], Ps_2[p_2], Ps_1[p_1]);
        usleep(2000000); 
        setCapture(Ns_1[n]*cycles_per_capture, 0); 
    }
} 

