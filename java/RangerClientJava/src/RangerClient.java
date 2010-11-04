
import java.io.*;
import jpcap.JpcapCaptor;
import jpcap.NetworkInterface;
import jpcap.packet.*;
import javax.swing.*;

public class RangerClient {

    /* variables */
    JpcapCaptor captor;
    NetworkInterface[] list;
    int x, choice;
    int N_ROWS = 120;
    int N_COLUMNS = 160;
    int rowsPerPacket = 1280/2/N_COLUMNS;
    int actualFrameNum = 0;
    int actualRowNum = 0;
    int pixel0 = 0;
    BufferedWriter out;
    FileOutputStream outStream;
    FileOutputStream outStream1;
    FileOutputStream outStream2;
    FileOutputStream outStream3;
    File outFile;
    File outFile1;
    File outFile2;
    File outFile3;
    boolean writeEnable = true;
    int sourcePort = 54155;
    int destPort = 2223;
    String avi_folder = "D:/AVIs/I2MTC_final/";
    int askUser = 0;
    int interfaceChoice = 1;
    int capture_complete = 0;

    public static void main(String args[]) {
        new RangerClient();
    }

    public RangerClient() {

        RangerSettingsDialog rsd = new RangerSettingsDialog((JFrame) null, false, avi_folder);
        rsd.setLocation(300, 300);
        rsd.setVisible(true);
        File setFile = rsd.getSetFile();
        System.out.println("" + setFile);
        if (setFile == null) {
            System.out.println("Error opening Settings File: Exiting");
            System.exit(-1);
        }


        /* first fetch available interfaces to listen on */
        list = JpcapCaptor.getDeviceList();
        System.out.println("Available interfaces: ");

        for (x = 0; x < list.length; x++) {
            System.out.println(x + " -> " + list[x].description);
        }
        System.out.println("-------------------------\n");
        if (askUser == 1) {
            choice = Integer.parseInt(getInput("Choose interface (0,1..): "));
        } else {
            choice = interfaceChoice;
        }
        System.out.println("Listening on interface -> " + list[choice].description);
        System.out.println("-------------------------\n");


        /*Setup device listener */
        try {
            captor = JpcapCaptor.openDevice(list[choice], 65535, false, 20);
            /* listen for UDP only */
            captor.setFilter("udp", true);
        //  captor.setFilter("ip and tcp", true);
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }

        System.out.println("Settings:\n" + rsd);


        System.out.println("\t" + rsd.getSetFile().getParent() + "\t" + rsd.getSetFile().getName());
        File dirFile = new File("" + rsd.getSetFileFolder() + "\\" + rsd.getSetFileName());
        dirFile.mkdir();

        RangerSettingsDialog rsd_c = null;

        while (true) {


            Packet info = captor.getPacket();
            int rowNum = 0;
            int frameNum = 0;
            int regionNum = 0;
            if (info != null) {
                if (info instanceof UDPPacket) {
                    UDPPacket udpInfo = (UDPPacket) info;
                    byte[] b = udpInfo.data;
                    if (udpInfo.src_port == sourcePort && udpInfo.dst_port == destPort) {
                        regionNum = bytesToInt(b[1],b[0]);
                        rowNum = bytesToInt(b[5], b[4]);
                        frameNum = bytesToInt(b[3], b[2]);

                        //System.out.println(" " + frameNum + " " + rowNum);
                        if (rowNum == 65535 && frameNum == 65535 && regionNum == 65535) {
                            //System.out.println("Parameter Packet Received!");
                            int nCyclesPerCapture = bytesToInt(b[7], b[6]);
                            int pll_m_count_2 = bytesToInt(b[8]);
                            int pll_m_count_1 = bytesToInt(b[9]);
                            int pll_c_count_2_lo = bytesToInt(b[10]);
                            int pll_c_count_2_hi = bytesToInt(b[11]);
                            int pll_c_count_1_lo = bytesToInt(b[12]);
                            int pll_c_count_1_hi = bytesToInt(b[13]);
                            double mf1 = (double) pll_m_count_1 * 10 / (double) (pll_c_count_1_hi + pll_c_count_1_lo);
                            double mf2 = (double) pll_m_count_2 * 10 / (double) (pll_c_count_2_hi + pll_c_count_2_lo);
                            int pll_c_rsel_2 = bytesToInt(b[14]);
                            int pll_c_rsel_1 = bytesToInt(b[15]);
                            int ratio = bytesToInt(b[16]);
                            int nOutput = bytesToInt(b[17]);
                            int phaseStep2Init = bytesToInt(b[19], b[18]);
                            int phaseStep1Init = bytesToInt(b[21], b[20]);
                            int phaseStep2 = bytesToInt(b[23], b[22]);
                            int phaseStep1 = bytesToInt(b[25], b[24]);
                            double n1 = ((double) (pll_c_count_1_hi + pll_c_count_1_lo) * 8) / (double) phaseStep1;
                            double n2 = ((double) (pll_c_count_2_hi + pll_c_count_2_lo) * 8) / (double) phaseStep2;
                            int frameTime = bytesToInt(b[29], b[28], b[27], b[26]);
                            int intTime = bytesToInt(b[33], b[32], b[31], b[30]);
                            int adc_gain_right = bytesToInt(b[34]);
                            int adc_gain_left = bytesToInt(b[35]);
                            int adc_offset_right = bytesToInt(b[36]);
                            int adc_offset_left = bytesToInt(b[37]);

                            try {
                                if (outStream != null) {
                                    closeStreams(false);
                                }

                                    String dirName = "" + rsd.getSetFileFolder() + "\\" + rsd.getSetFileName() + "\\" + (int) mf1 + "_" + (int) mf2 + "_" + (int) n1 + "_" + (int) n2 + "_" + (int) (nOutput * frameTime) / 1000;
                                    dirFile = new File(dirName);
                                    dirFile.mkdir();
                                    String fileName = dirName + "\\" + ratio + "_" + phaseStep2Init + "_" + phaseStep1Init + ".set";
                                    //System.out.println("" + fileName);
                                    rsd_c = new RangerSettingsDialog(rsd, fileName);

                                    rsd_c.setFileIncrement(0);
                                    rsd_c.setMF1(mf1);
                                    rsd_c.setMF2(mf2);
                                    rsd_c.setFPB1(n1);
                                    rsd_c.setFPB2(n2);
                                    rsd_c.setFPOutput(nOutput);
                                    rsd_c.setPhaseStep1(phaseStep1);
                                    rsd_c.setPhaseStep2(phaseStep2);
                                    rsd_c.setPhaseStepInit1(phaseStep1Init);
                                    rsd_c.setPhaseStepInit2(phaseStep2Init);
                                    rsd_c.setMCount1(pll_m_count_1);
                                    rsd_c.setMCount2(pll_m_count_2);
                                    rsd_c.setCCount1Hi(pll_c_count_1_hi);
                                    rsd_c.setCCount1Lo(pll_c_count_1_lo);
                                    rsd_c.setCCount2Hi(pll_c_count_2_hi);
                                    rsd_c.setCCount2Lo(pll_c_count_2_lo);
                                    rsd_c.setNCaptures(nOutput * nCyclesPerCapture);
                                    rsd_c.setFrameTime(frameTime);
                                    rsd_c.setIntTime(intTime);
                                    rsd_c.setAdcGainLeft(adc_gain_left);
                                    rsd_c.setAdcGainRight(adc_gain_right);
                                    rsd_c.setAdcOffsetLeft(adc_offset_left);
                                    rsd_c.setAdcOffsetRight(adc_offset_right);
                                    rsd_c.setModRatio(ratio);

                                    rsd_c.writeSettingsFile();
                                    outFile = rsd_c.getNextFile();
                                    outStream = new FileOutputStream(outFile);
                                    String s = outFile.getAbsolutePath();
                                    s = s.substring(0,s.length()-4);
                                    outFile1 = new File(s+"_r1.dat");
                                    outFile2 = new File(s+"_r2.dat");
                                    outFile3 = new File(s+"_r3.dat");
                                    outStream1 = new FileOutputStream(outFile1);
                                    outStream2 = new FileOutputStream(outFile2);
                                    outStream3 = new FileOutputStream(outFile3);

                                    System.out.println("Capturing Packets to file: " + outFile.getPath() + "...");

                                } catch  (Exception e) {
                                System.out.println("Exception opening outputStream\n");
                                e.printStackTrace();
                                System.exit(-1);
                            }
                        } else {
                            try {
                                if (outStream != null) {
                                    if(regionNum==0) outStream.write(udpInfo.data, 6, udpInfo.data.length - 6);
                                    if(regionNum==1) outStream1.write(udpInfo.data, 6, udpInfo.data.length - 6);
                                    if(regionNum==2) outStream2.write(udpInfo.data, 6, udpInfo.data.length - 6);
                                    if(regionNum==3) outStream3.write(udpInfo.data, 6, udpInfo.data.length - 6);
                                }
                            } catch (IOException e) {
                                e.printStackTrace();
                                System.exit(-5);
                            }
                        }

                    } // end port accepted
                }
            }
            // Attempt to read quit command from terminal
            try {
                BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
                if (br.ready()) {
                    String line = br.readLine();
                    if (line != null && line.contains("q")) {
                        break;
                    }
                }
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }

        } // end while(true)
        closeStreams(true);
        
        System.out.println("Program End.");

    }

    public void closeStreams(boolean verbose)
    {
    try {

            if (outStream != null) {
                outStream.close();
                if (outFile.length() < 50000) {
                    if(verbose)System.out.print("File " + outFile + " has no full frames. Deleting... ");
                    if (outFile.delete()) {
                        if(verbose)System.out.println("Successful.");
                    } else {
                        if(verbose)System.out.println("Failed.");
                    }
                }
            }
            if (outStream1 != null) {
                outStream1.close();
                if (outFile1.length() < 50000) {
                    if(verbose)System.out.print("File " + outFile1 + " has no full frames. Deleting... ");
                    if (outFile1.delete()) {
                        if(verbose)System.out.println("Successful.");
                    } else {
                        if(verbose)System.out.println("Failed.");
                    }
                }
            }
            if (outStream2 != null) {
                outStream2.close();
                if (outFile2.length() < 50000) {
                    if(verbose)System.out.print("File " + outFile2 + " has no full frames. Deleting... ");
                    if (outFile2.delete()) {
                        if(verbose)System.out.println("Successful.");
                    } else {
                        if(verbose)System.out.println("Failed.");
                    }
                }
            }
            if (outStream3 != null) {
                outStream3.close();
                if (outFile3.length() < 50000) {
                    if(verbose)System.out.print("File " + outFile3 + " has no full frames. Deleting... ");
                    if (outFile3.delete()) {
                        if(verbose)System.out.println("Successful.");
                    } else {
                        if(verbose)System.out.println("Failed.");
                    }
                }
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }

    }

    public static int bytesToInt(byte b0) {
        return (int) b0 & 0xFF;
    }

    public static int bytesToInt(byte b1, byte b0) {
        int i = bytesToInt(b0) + (bytesToInt(b1) << 8);
        return i;
    }

    public static int bytesToInt(byte b3, byte b2, byte b1, byte b0) {
        int i0 = bytesToInt(b1, b0);
        int i1 = bytesToInt(b3, b2);
        return (i1 << 16) + i0;
    }


    /* get user input */
    public static String getInput(
            String q) {
        String input = "";
        System.out.print(q);
        BufferedReader bufferedreader = new BufferedReader(new InputStreamReader(System.in));
        try {
            input = bufferedreader.readLine();
        } catch (IOException ioexception) {
            ioexception.printStackTrace();
        }
        return input;
    }
}