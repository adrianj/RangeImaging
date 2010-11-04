
import java.io.*;
import javax.swing.*;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * RangerSettingsDialog.java
 *
 * Created on 31/03/2009, 2:27:25 PM
 */
/**
 *
 * @author jongenad
 */
public class RangerSettingsDialog extends javax.swing.JDialog {

    private int mMCount1;
    private int mMCount2;
    private int mCCount1Hi;
    private int mCCount1Lo;
    private int mCCount2Hi;
    private int mCCount2Lo;
    private int mIntTime;
    private int mFrameTime;
    private double mFPB1;
    private double mFPB2;
    private int mFPOutput;
    private double mMF1;
    private double mMF2;
    private int mModRatio;
    private int mNCaptures;
    private File setFile;
    private String filePath;
    private int mAdcOffsetLeft;
    private int mAdcOffsetRight;
    private int mAdcGainLeft;
    private int mAdcGainRight;
    private double mDutyCycleCamera;
    private double mDutyCycleLaser;
    private int mPhaseStepInit1;
    private int mPhaseStepInit2;
    private int mPhaseStep1;
    private int mPhaseStep2;
    private int fileIncrement = 0;
    private int fileIncrementInit = 0;
    private boolean isDialog = false;

    /** Creates new form RangerSettingsDialog */
    public RangerSettingsDialog(java.awt.Frame parent, boolean modal, String path) {
        super(parent, modal);
        isDialog = true;
        filePath = path;
        initComponents();

        openSettingsFile();
    }


    /* Create a RSD from existing one.
     * No dialog interface required, simply copies all the settings and creates a new file with given name
     */
    public RangerSettingsDialog(RangerSettingsDialog d, String newFilename)
    {
        openSettingsFile(newFilename);
        this.mMF1 = d.getMF1();
        this.mMF2 = d.getMF2();
        this.mFPB1 = d.getFPB1();
        this.mFPB2 = d.getFPB2();
        this.mFPOutput = d.getFPOutput();
        this.mNCaptures = d.getNCaptures();
        this.mIntTime = d.getIntTime();
        this.mFrameTime = d.getFrameTime();
        this.mModRatio = d.getModRatio();
        this.mAdcOffsetLeft = d.getAdcOffsetLeft();
        this.mAdcOffsetRight = d.getAdcOffsetRight();
        this.mAdcGainLeft = d.getAdcGainLeft();
        this.mAdcGainRight = d.getAdcGainRight();
        this.mDutyCycleCamera = d.getDutyCycleCamera();
        this.mDutyCycleLaser = d.getDutyCycleLaser();
        this.mPhaseStepInit1 = d.getPhaseStepInit1();
        this.mPhaseStepInit2 = d.getPhaseStepInit2();
        this.mPhaseStep1 = d.getPhaseStep1();
        this.mPhaseStep2 = d.getPhaseStep2();
        this.fileIncrement = d.getFileIncrement();
        this.fileIncrementInit = d.getFileIncrementInit();
        this.mMCount1 = d.getMCount1();
        this.mMCount2 = d.getMCount2();
        this.mCCount1Hi = d.getCCount1Hi();
        this.mCCount1Lo = d.getCCount1Lo();
        this.mCCount2Hi = d.getCCount2Hi();
        this.mCCount2Lo = d.getCCount2Lo();
    }

    public String toString() {
        String s = "MF1 " + mMF1 + "\nMF2 " + mMF2 +
                "\nFPB1 " + mFPB1 + "\nFPB2 " + mFPB2 + "\nFPOUTPUT " + mFPOutput +
                "\nINTTIME " + mIntTime + "\nFRAMETIME " + mFrameTime +
                "\nNCAPTURES " + mNCaptures + "\nMODRATIO " + mModRatio +
                "\nADCOLEFT " + mAdcOffsetLeft + "\nADCORIGHT " + mAdcOffsetRight +
                "\nADCGLEFT " + mAdcGainLeft + "\nADCGRIGHT " + mAdcGainRight +
                "\nDCCAMERA " + mDutyCycleCamera + "\nDCLASER " + mDutyCycleLaser +
                "\nPLLMCOUNT1 " + mMCount1 + "\nPLLMCOUNT2 " + mMCount2 +
                "\nPLLCOUNT1_HI " + mCCount1Hi + "\nPLLCOUNT1_LO " + mCCount1Lo +
                "\nPLLCOUNT2_HI " + mCCount2Hi + "\nPLLCOUNT2_LO " + mCCount2Lo +
                "\nPHASESTEP1 " + mPhaseStep1 + "\nPHASESTEP2 " + mPhaseStep2 +
                "\nPHASESTEPINIT1 " + mPhaseStepInit1 + "\nPHASESTEPINIT2 " + mPhaseStepInit2 + "\n";
        return s;
    }

    public void setFileIncrement(int i)
    {
        fileIncrement = i;
    }
    public int getFileIncrement()
    {
        return fileIncrement;
    }
    public void setFileIncrementInit(int i)
    {
        fileIncrementInit = i;
    }
    public int getFileIncrementInit()
    {
        return fileIncrementInit;
    }

    public void setPath(String path) {
        filePath = path;
    }

    public double getMF1() {
        return mMF1;
    }

    public void setMF1(double d) {
        mMF1 = d;
        if(isDialog)mod1.getModel().setValue(new Double(d));
    }

    public double getMF2() {
        return mMF2;
    }

    public void setMF2(double d) {
        mMF2 = d;
        if(isDialog)mod2.getModel().setValue(new Double(d));
    }

    public double getFPB1() {
        return mFPB1;
    }

    public void setFPB1(double i) {
        mFPB1 = i;
        if(isDialog)fpb1.getModel().setValue(new Double(i));
    }

    public double getFPB2() {
        return mFPB2;
    }

    public void setFPB2(double i) {
        mFPB2 = i;
        if(isDialog)fpb2.getModel().setValue(new Double(i));
    }
    public int getFPOutput() {
        return mFPOutput;
    }

    public void setFPOutput(int i) {
        mFPOutput = i;
        if(isDialog)fpoutput.getModel().setValue(new Integer(i));
    }

    public int getIntTime() {
        return mIntTime;
    }

    public void setIntTime(int i) {
        mIntTime = i;
        if(isDialog)intTime.getModel().setValue(new Integer(i));
    }

    public int getFrameTime() {
        return mFrameTime;
    }

    public void setFrameTime(int i) {
        mFrameTime = i;
        if(isDialog)frameTime.getModel().setValue(new Integer(i));
    }

    public int getModRatio() {
        return mModRatio;
    }

    public void setModRatio(int i) {
        mModRatio = i;
        if(isDialog)modRatio.getModel().setValue(new Integer(i));
    }

    public int getNCaptures() {
        return mNCaptures;
    }

    public void setNCaptures(int i) {
        mNCaptures = i;
        if(isDialog)nCaptures.getModel().setValue(new Integer(i));
    }

    public int getAdcOffsetLeft(){
        return mAdcOffsetLeft;
    }
    public void setAdcOffsetLeft(int i){
        mAdcOffsetLeft = i;
        if(isDialog)adcOffsetLeft.getModel().setValue(new Integer(i));
    }
    public int getAdcOffsetRight(){
        return mAdcOffsetRight;
    }
    public void setAdcOffsetRight(int i){
        mAdcOffsetRight = i;
        if(isDialog)adcOffsetRight.getModel().setValue(new Integer(i));
    }
    public int getAdcGainLeft(){
        return mAdcGainLeft;
    }
    public void setAdcGainLeft(int i){
        mAdcGainLeft = i;
        if(isDialog)adcGainLeft.getModel().setValue(new Integer(i));
    }
    public int getAdcGainRight(){
        return mAdcGainRight;
    }
    public void setAdcGainRight(int i){
        mAdcGainRight = i;
        if(isDialog)adcGainRight.getModel().setValue(new Integer(i));
    }
    public double getDutyCycleCamera(){
        return mDutyCycleCamera;
    }
    public void setDutyCycleCamera(double i){
        mDutyCycleCamera = i;
        if(isDialog)dutyCycleCamera.getModel().setValue(new Double(i));
    }
    public double getDutyCycleLaser(){
        return mDutyCycleLaser;
    }
    public void setDutyCycleLaser(double i){
        mDutyCycleLaser = i;
        if(isDialog)dutyCycleLaser.getModel().setValue(new Double(i));
    }
    public int getPhaseStepInit1(){
        return mPhaseStepInit1;
    }
    public void setPhaseStepInit1(int i){
        mPhaseStepInit1 = i;
        if(isDialog)phaseStep1.getModel().setValue(new Integer(i));
    }
    public int getPhaseStepInit2(){
        return mPhaseStepInit2;
    }
    public void setPhaseStepInit2(int i){
        mPhaseStepInit2 = i;
        if(isDialog)phaseStep2.getModel().setValue(new Integer(i));
    }
    public int getPhaseStep1(){
        return mPhaseStep1;
    }
    public void setPhaseStep1(int i){
        mPhaseStep1 = i;
    }
    public int getPhaseStep2(){
        return mPhaseStep2;
    }
    public void setPhaseStep2(int i){
        mPhaseStep2 = i;
    }
    public int getMCount1(){
        return mMCount1;
    }
    public void setMCount1(int i){
        mMCount1 = i;
    }
    public int getMCount2(){
        return mMCount2;
    }
    public void setMCount2(int i){
        mMCount2 = i;
    }
    public int getCCount1Hi(){
        return mCCount1Hi;
    }
    public void setCCount1Hi(int i){
        mCCount1Hi = i;
    }
    public int getCCount1Lo(){
        return mCCount1Lo;
    }
    public void setCCount1Lo(int i){
        mCCount1Lo = i;
    }
    public int getCCount2Hi(){
        return mCCount2Hi;
    }
    public void setCCount2Hi(int i){
        mCCount2Hi = i;
    }
    public int getCCount2Lo(){
        return mCCount2Lo;
    }
    public void setCCount2Lo(int i){
        mCCount2Lo = i;
    }
    
    public File getSetFile() {
        return setFile;
    }
    public String getSetFileName() {
        if(setFile != null)
        {
            String s = setFile.getName();
            s = s.substring(0, s.length()-4);
            return s;
        }
        else
            return "";
    }

    public String getSetFileFolder()
    {
        if(setFile != null)
        {
            String s = setFile.getParent();
            return s;
        }
        else
            return "";
    }
    
    

    /** Creates new form RangerSettingsDialog */
    public RangerSettingsDialog(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initComponents();
        openSettingsFile();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        saveButton = new javax.swing.JButton();
        cancelButton = new javax.swing.JButton();
        jLabel1 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();
        mod1 = new javax.swing.JSpinner();
        mod2 = new javax.swing.JSpinner();
        fpb1 = new javax.swing.JSpinner();
        jLabel4 = new javax.swing.JLabel();
        fpb2 = new javax.swing.JSpinner();
        jLabel5 = new javax.swing.JLabel();
        intTime = new javax.swing.JSpinner();
        jLabel6 = new javax.swing.JLabel();
        frameTime = new javax.swing.JSpinner();
        jLabel7 = new javax.swing.JLabel();
        jLabel8 = new javax.swing.JLabel();
        modRatio = new javax.swing.JSpinner();
        nCaptures = new javax.swing.JSpinner();
        filenameBox = new javax.swing.JTextField();
        changeFile = new javax.swing.JButton();
        adcOffsetLeft = new javax.swing.JSpinner();
        jLabel9 = new javax.swing.JLabel();
        jLabel10 = new javax.swing.JLabel();
        adcOffsetRight = new javax.swing.JSpinner();
        jLabel11 = new javax.swing.JLabel();
        adcGainLeft = new javax.swing.JSpinner();
        jLabel12 = new javax.swing.JLabel();
        adcGainRight = new javax.swing.JSpinner();
        jLabel13 = new javax.swing.JLabel();
        dutyCycleCamera = new javax.swing.JSpinner();
        jLabel14 = new javax.swing.JLabel();
        dutyCycleLaser = new javax.swing.JSpinner();
        phaseStep1 = new javax.swing.JSpinner();
        jLabel15 = new javax.swing.JLabel();
        fpoutput = new javax.swing.JSpinner();
        jLabel16 = new javax.swing.JLabel();
        jLabel17 = new javax.swing.JLabel();
        phaseStep2 = new javax.swing.JSpinner();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setAlwaysOnTop(true);
        setModal(true);

        saveButton.setText("Save");
        saveButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                saveButtonActionPerformed(evt);
            }
        });

        cancelButton.setText("Cancel");
        cancelButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                cancelButtonActionPerformed(evt);
            }
        });

        jLabel1.setText("Modulation 1 (MHz)");

        jLabel2.setText("Modulation 2 (MHz)");

        jLabel3.setText("Frames per Beat 1");

        mod1.setModel(new javax.swing.SpinnerNumberModel(Double.valueOf(0.0d), Double.valueOf(0.0d), null, Double.valueOf(10.0d)));

        mod2.setModel(new javax.swing.SpinnerNumberModel(Double.valueOf(0.0d), Double.valueOf(0.0d), null, Double.valueOf(10.0d)));

        fpb1.setModel(new javax.swing.SpinnerNumberModel(8.0d, 0.0d, 65535.0d, 1.0d));

        jLabel4.setText("Frames per Beat 2");

        fpb2.setModel(new javax.swing.SpinnerNumberModel(4.0d, 0.0d, 65535.0d, 1.0d));

        jLabel5.setText("Integration Time (us)");

        intTime.setModel(new javax.swing.SpinnerNumberModel(40000, 0, 1000000, 10000));

        jLabel6.setText("Frame Time (us)");

        frameTime.setModel(new javax.swing.SpinnerNumberModel(40000, 0, 1000000, 10000));

        jLabel7.setText("Modulation Ratio");

        jLabel8.setText("Frames per Capture");

        modRatio.setModel(new javax.swing.SpinnerNumberModel(128, 0, 255, 1));

        nCaptures.setModel(new javax.swing.SpinnerNumberModel(Integer.valueOf(300), Integer.valueOf(0), null, Integer.valueOf(100)));

        filenameBox.setEditable(false);
        filenameBox.setText("No File Selected");

        changeFile.setText("...");
        changeFile.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                changeFileActionPerformed(evt);
            }
        });

        adcOffsetLeft.setModel(new javax.swing.SpinnerNumberModel());
        adcOffsetLeft.setMinimumSize(new java.awt.Dimension(25, 18));
        adcOffsetLeft.setPreferredSize(new java.awt.Dimension(60, 18));

        jLabel9.setText("ADC Offset:   Left");

        jLabel10.setText("Right");

        adcOffsetRight.setModel(new javax.swing.SpinnerNumberModel());

        jLabel11.setText("ADC Gain:      Left");

        adcGainLeft.setModel(new javax.swing.SpinnerNumberModel());
        adcGainLeft.setMinimumSize(new java.awt.Dimension(25, 18));
        adcGainLeft.setPreferredSize(new java.awt.Dimension(25, 18));

        jLabel12.setText("Right");

        adcGainRight.setModel(new javax.swing.SpinnerNumberModel());

        jLabel13.setText("Duty Cycle:   Camera");

        dutyCycleCamera.setModel(new javax.swing.SpinnerNumberModel(50.0d, 20.0d, 80.0d, 1.0d));

        jLabel14.setText("Laser");

        dutyCycleLaser.setModel(new javax.swing.SpinnerNumberModel(50.0d, 20.0d, 80.0d, 1.0d));

        phaseStep1.setModel(new javax.swing.SpinnerNumberModel(0, 0, 65535, 1));

        jLabel15.setText("Phase Step 1");

        fpoutput.setModel(new javax.swing.SpinnerNumberModel(8, 0, 65535, 1));

        jLabel16.setText("Frames per Output Frame");

        jLabel17.setText("Phase Step 2");

        phaseStep2.setModel(new javax.swing.SpinnerNumberModel(0, 0, 65535, 1));

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(filenameBox, javax.swing.GroupLayout.PREFERRED_SIZE, 226, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(changeFile, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(jLabel7, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 172, Short.MAX_VALUE)
                            .addComponent(jLabel6, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 172, Short.MAX_VALUE)
                            .addComponent(jLabel5, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 172, Short.MAX_VALUE)
                            .addComponent(jLabel8, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 172, Short.MAX_VALUE)
                            .addGroup(javax.swing.GroupLayout.Alignment.LEADING, layout.createSequentialGroup()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                                        .addComponent(jLabel9, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(jLabel11, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                                    .addComponent(jLabel13, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(adcGainLeft, javax.swing.GroupLayout.DEFAULT_SIZE, 66, Short.MAX_VALUE)
                                    .addComponent(adcOffsetLeft, javax.swing.GroupLayout.DEFAULT_SIZE, 66, Short.MAX_VALUE)
                                    .addComponent(dutyCycleCamera, javax.swing.GroupLayout.DEFAULT_SIZE, 66, Short.MAX_VALUE))))
                        .addGap(10, 10, 10)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(nCaptures, javax.swing.GroupLayout.DEFAULT_SIZE, 116, Short.MAX_VALUE)
                            .addComponent(modRatio, javax.swing.GroupLayout.DEFAULT_SIZE, 116, Short.MAX_VALUE)
                            .addGroup(layout.createSequentialGroup()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                                    .addComponent(jLabel12)
                                    .addComponent(jLabel10)
                                    .addComponent(jLabel14))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(adcOffsetRight, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 86, Short.MAX_VALUE)
                                    .addComponent(adcGainRight, javax.swing.GroupLayout.DEFAULT_SIZE, 86, Short.MAX_VALUE)
                                    .addComponent(dutyCycleLaser, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 86, Short.MAX_VALUE)))
                            .addComponent(frameTime, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 116, Short.MAX_VALUE)
                            .addComponent(intTime, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 116, Short.MAX_VALUE)))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(layout.createSequentialGroup()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                                    .addComponent(jLabel2, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 173, Short.MAX_VALUE)
                                    .addComponent(jLabel3, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 173, Short.MAX_VALUE)
                                    .addComponent(jLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, 173, Short.MAX_VALUE)
                                    .addComponent(saveButton, javax.swing.GroupLayout.Alignment.LEADING))
                                .addGap(10, 10, 10))
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(jLabel4, javax.swing.GroupLayout.DEFAULT_SIZE, 175, Short.MAX_VALUE)
                                .addGap(8, 8, 8)))
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(fpb1, javax.swing.GroupLayout.DEFAULT_SIZE, 115, Short.MAX_VALUE)
                            .addComponent(mod2, javax.swing.GroupLayout.DEFAULT_SIZE, 115, Short.MAX_VALUE)
                            .addComponent(cancelButton, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 115, Short.MAX_VALUE)
                            .addComponent(mod1, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 115, Short.MAX_VALUE)
                            .addComponent(fpb2, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 115, Short.MAX_VALUE)))
                    .addGroup(layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(jLabel17, javax.swing.GroupLayout.DEFAULT_SIZE, 175, Short.MAX_VALUE)
                            .addComponent(jLabel15, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 175, Short.MAX_VALUE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(phaseStep1, javax.swing.GroupLayout.DEFAULT_SIZE, 119, Short.MAX_VALUE)
                            .addComponent(phaseStep2, javax.swing.GroupLayout.DEFAULT_SIZE, 119, Short.MAX_VALUE)))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addComponent(jLabel16, javax.swing.GroupLayout.DEFAULT_SIZE, 149, Short.MAX_VALUE)
                        .addGap(33, 33, 33)
                        .addComponent(fpoutput, javax.swing.GroupLayout.DEFAULT_SIZE, 116, Short.MAX_VALUE)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(filenameBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(changeFile))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel1)
                    .addComponent(mod1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel2)
                    .addComponent(mod2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel3)
                    .addComponent(fpb1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(fpb2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel4))
                .addGap(5, 5, 5)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(fpoutput, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel16))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel5)
                    .addComponent(intTime, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel6)
                    .addComponent(frameTime, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel7)
                    .addComponent(modRatio, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(nCaptures, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel8))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel9)
                    .addComponent(adcOffsetLeft, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(adcOffsetRight, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel10))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel11)
                    .addComponent(adcGainLeft, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(adcGainRight, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel12))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(dutyCycleCamera, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel13)
                    .addComponent(dutyCycleLaser, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel14))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(phaseStep1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel15))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel17)
                    .addComponent(phaseStep2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(saveButton)
                    .addComponent(cancelButton))
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void saveButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_saveButtonActionPerformed

        mMF1 = ((SpinnerNumberModel) (mod1.getModel())).getNumber().doubleValue();
        mMF2 = ((SpinnerNumberModel) (mod2.getModel())).getNumber().doubleValue();
        mFPB1 = ((SpinnerNumberModel) (fpb1.getModel())).getNumber().doubleValue();
        mFPB2 = ((SpinnerNumberModel) (fpb2.getModel())).getNumber().doubleValue();
        mFPOutput = ((SpinnerNumberModel) (fpoutput.getModel())).getNumber().intValue();
        mIntTime = ((SpinnerNumberModel) (intTime.getModel())).getNumber().intValue();
        mFrameTime = ((SpinnerNumberModel) (frameTime.getModel())).getNumber().intValue();
        mNCaptures = ((SpinnerNumberModel) (nCaptures.getModel())).getNumber().intValue();
        mModRatio = ((SpinnerNumberModel) (modRatio.getModel())).getNumber().intValue();
        mAdcOffsetLeft = ((SpinnerNumberModel) (adcOffsetLeft.getModel())).getNumber().intValue();
        mAdcOffsetRight = ((SpinnerNumberModel) (adcOffsetRight.getModel())).getNumber().intValue();
        mAdcGainLeft = ((SpinnerNumberModel) (adcGainLeft.getModel())).getNumber().intValue();
        mAdcGainRight = ((SpinnerNumberModel) (adcGainRight.getModel())).getNumber().intValue();
        mDutyCycleCamera = ((SpinnerNumberModel) (dutyCycleCamera.getModel())).getNumber().doubleValue();
        mDutyCycleLaser = ((SpinnerNumberModel) (dutyCycleLaser.getModel())).getNumber().doubleValue();
        mPhaseStepInit1 = ((SpinnerNumberModel) (phaseStep1.getModel())).getNumber().intValue();
        mPhaseStepInit2 = ((SpinnerNumberModel) (phaseStep2.getModel())).getNumber().intValue();
        //showMessage("" + toString());
        writeSettingsFile();
        this.dispose();
}//GEN-LAST:event_saveButtonActionPerformed

    private void cancelButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_cancelButtonActionPerformed
        setFile = null;
        this.dispose();
}//GEN-LAST:event_cancelButtonActionPerformed

    /* open file without a dialog. path is provided.
     */
    private void openSettingsFile(String path)
    {
        setFile = new File(path);
        if (!setFile.exists()) {
                try {
                    setFile.createNewFile();
                } catch (IOException ioe) {
                }
            }
    }

    /* Default open dialog - asks user for file path
     */
    private void openSettingsFile() {
        setFile = null;

        JFileChooser chooser = new JFileChooser(filePath);
        
        SimpleFileFilter filter = new SimpleFileFilter();
        filter.addExtension("set");
        filter.setDescription("Ranger Settings Files (*.set)");

        File directory = new File(filePath);
        // If directory exists, find last modified set file and begin with those settings.
        if (directory.exists()) {
            //SimpleFileFilter filter = new SimpleFileFilter();
            //filter.addExtension("set");
            //filter.setDescription("Ranger Settings Files (*.set)");
            directory.listFiles(filter);


            File[] dir_files = directory.listFiles(filter);
            File latestFile = null;
            long latest = 0;
            for (int i = 0; i < dir_files.length; i++) {
                //System.out.println("" + dir_files[i] + " " + dir_files[i].lastModified());
                if (dir_files[i].lastModified() > latest && !dir_files[i].isDirectory()) {
                    latest = dir_files[i].lastModified();
                    latestFile = dir_files[i];
                }
            }
            if (latestFile != null) {
                System.out.println("" + latestFile + " " + latestFile.lastModified());
                setFile = latestFile;
                readSettingsFile();
            }
        }
        chooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
        chooser.setFileFilter(filter);
        int returnVal = chooser.showOpenDialog(this);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            setFile = chooser.getSelectedFile();
            if (!setFile.exists()) {
                setFile = new File(setFile.getPath() + ".set");
                showMessage("Settings File \"" + setFile + "\" does not exist. Creating...");

                try {
                    setFile.createNewFile();
                } catch (IOException ioe) {
                }
                writeSettingsFile();
            }
            filenameBox.setText(setFile.getPath());
            saveButton.setEnabled(true);
            readSettingsFile();
            return;
        }
        disableSave();
    }

    private void disableSave() {
        saveButton.setEnabled(false);
        setFile = null;
    }

    private void showMessage(String s) {
        JOptionPane.showMessageDialog(null, s);
    }

    private void changeFileActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_changeFileActionPerformed
        openSettingsFile();
    }//GEN-LAST:event_changeFileActionPerformed
    private void readSettingsFile() {
        System.out.print("\n**"+setFile.getAbsolutePath());
        if (setFile == null || !setFile.exists()) {
            showMessage("Settings File is null. Cannot read.");
            disableSave();
        } else {
            try {

                BufferedReader br = new BufferedReader(new FileReader(setFile));
                String line;
                while((line = br.readLine()) != null)
                {
                    String[] ss = line.split(" ", 2);
                    if(ss[0].equalsIgnoreCase("MF1"))
                    {
                        setMF1(Double.parseDouble(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("MF2"))
                    {
                        setMF2(Double.parseDouble(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("FPB1"))
                    {
                        setFPB1(Double.parseDouble(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("FPB2"))
                    {
                        setFPB2(Double.parseDouble(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("FPOUTPUT"))
                    {
                        setFPOutput(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("INTTIME"))
                    {
                        this.setIntTime(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("FRAMETIME"))
                    {
                        this.setFrameTime(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("NCAPTURES"))
                    {
                        int n = Integer.parseInt(ss[1]);
                        if(n == 0) n = 300;
                        this.setNCaptures(n);
                    }
                    if(ss[0].equalsIgnoreCase("MODRATIO"))
                    {
                        this.setModRatio(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("ADCOLEFT"))
                    {
                        this.setAdcOffsetLeft(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("ADCORIGHT"))
                    {
                        this.setAdcOffsetRight(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("ADCGLEFT"))
                    {
                        this.setAdcGainLeft(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("ADCGRIGHT"))
                    {
                        this.setAdcGainRight(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("DCCAMERA"))
                    {
                        this.setDutyCycleCamera(Double.parseDouble(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("DCLASER"))
                    {
                        this.setDutyCycleLaser(Double.parseDouble(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PHASESTEP1"))
                    {
                        this.setPhaseStep1(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PHASESTEP2"))
                    {
                        this.setPhaseStep2(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PHASESTEPINIT1"))
                    {
                        this.setPhaseStepInit1(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PHASESTEPINIT2"))
                    {
                        this.setPhaseStepInit2(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PLLMCOUNT1"))
                    {
                        this.setMCount1(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PLLMCOUNT2"))
                    {
                        this.setMCount2(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PLLCOUNT1_HI"))
                    {
                        this.setCCount1Hi(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PLLCOUNT1_LO"))
                    {
                        this.setCCount1Lo(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PLLCOUNT2_HI"))
                    {
                        this.setCCount2Hi(Integer.parseInt(ss[1]));
                    }
                    if(ss[0].equalsIgnoreCase("PLLCOUNT2_LO"))
                    {
                        this.setCCount2Lo(Integer.parseInt(ss[1]));
                    }
                }
            } catch (Exception e) {
                showMessage("Error reading settings file: " + setFile.getPath() + "\n");
                e.printStackTrace();
                disableSave();
            }
        }
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {

            public void run() {
                RangerSettingsDialog dialog = new RangerSettingsDialog(new javax.swing.JFrame(), true);
                dialog.addWindowListener(new java.awt.event.WindowAdapter() {

                    public void windowClosing(java.awt.event.WindowEvent e) {
                        System.exit(0);
                    }
                });
                dialog.setVisible(true);
            }
        });
    }

    public void writeSettingsFile() {
        if (setFile == null || !setFile.exists()) {
            showMessage("Settings File is null. Cannot write.");
            disableSave();
        } else {
            try {
                BufferedWriter bw = new BufferedWriter(new FileWriter(setFile));
                bw.write(toString());
                bw.close();
            } catch (IOException ioe) {
                showMessage("Error writing to settings file.");
                disableSave();
            }

        }
    }


    public File getNextFile() {
        if (setFile == null || !setFile.exists()) {
            showMessage("Settings file is null. No new files created.");
            disableSave();
        } else {
            String filename = this.getSetFileFolder() + "\\" + this.getSetFileName();
            if(fileIncrement == 0) return new File(filename + ".dat");
            else{
            String outFilename = filename + "_"+fileIncrementInit+".dat";
            int i = fileIncrementInit;
            File outFile = new File(outFilename);
            while (outFile.exists()) {
                i = i + fileIncrement;
                outFilename = filename + "_" + i + ".dat";
                outFile = new File(outFilename);
            }
            return outFile;
            }
            //outFilename = filename;
            //outFile = new File(outFilename);
            
        }

        return null;
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JSpinner adcGainLeft;
    private javax.swing.JSpinner adcGainRight;
    private javax.swing.JSpinner adcOffsetLeft;
    private javax.swing.JSpinner adcOffsetRight;
    private javax.swing.JButton cancelButton;
    private javax.swing.JButton changeFile;
    private javax.swing.JSpinner dutyCycleCamera;
    private javax.swing.JSpinner dutyCycleLaser;
    private javax.swing.JTextField filenameBox;
    private javax.swing.JSpinner fpb1;
    private javax.swing.JSpinner fpb2;
    private javax.swing.JSpinner fpoutput;
    private javax.swing.JSpinner frameTime;
    private javax.swing.JSpinner intTime;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel10;
    private javax.swing.JLabel jLabel11;
    private javax.swing.JLabel jLabel12;
    private javax.swing.JLabel jLabel13;
    private javax.swing.JLabel jLabel14;
    private javax.swing.JLabel jLabel15;
    private javax.swing.JLabel jLabel16;
    private javax.swing.JLabel jLabel17;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JLabel jLabel5;
    private javax.swing.JLabel jLabel6;
    private javax.swing.JLabel jLabel7;
    private javax.swing.JLabel jLabel8;
    private javax.swing.JLabel jLabel9;
    private javax.swing.JSpinner mod1;
    private javax.swing.JSpinner mod2;
    private javax.swing.JSpinner modRatio;
    private javax.swing.JSpinner nCaptures;
    private javax.swing.JSpinner phaseStep1;
    private javax.swing.JSpinner phaseStep2;
    private javax.swing.JButton saveButton;
    // End of variables declaration//GEN-END:variables
}
