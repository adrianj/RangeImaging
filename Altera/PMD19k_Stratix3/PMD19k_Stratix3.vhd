-- Top level for PMD Ranger design - Targetting Stratix III EP3SL150 F1152C2 Kit

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PMD19k_Stratix3 is
  port (
    -- Global signals
    clk50   : in std_logic;
    clk125  : in std_logic;
    reset_n : in std_logic;


    -- the_ddr_deva
    ddr2_deva_a     : out   std_logic_vector (12 downto 0);
    ddr2_deva_ba    : out   std_logic_vector (1 downto 0);
    ddr2_deva_casn  : out   std_logic;
    ddr2_deva_cke   : out   std_logic;
    ddr2_deva_ck_n  : inout std_logic;
    ddr2_deva_ck_p  : inout std_logic;
    ddr2_deva_csn   : out   std_logic;
    ddr2_deva_dm    : out   std_logic;
    ddr2_deva_dq    : inout std_logic_vector (7 downto 0);
    ddr2_deva_dqs_p : inout std_logic;
    ddr2_deva_dqs_n : inout std_logic;
    ddr2_deva_odt   : out   std_logic;
    ddr2_deva_rasn  : out   std_logic;
    ddr2_deva_wen   : out   std_logic;
        -- the_ddr_devb
    ddr2_devb_a     : out   std_logic_vector (12 downto 0);
    ddr2_devb_ba    : out   std_logic_vector (1 downto 0);
    ddr2_devb_casn  : out   std_logic;
    ddr2_devb_cke   : out   std_logic;
    ddr2_devb_ck_n  : inout std_logic;
    ddr2_devb_ck_p  : inout std_logic;
    ddr2_devb_csn   : out   std_logic;
    ddr2_devb_dm    : out   std_logic;
    ddr2_devb_dq    : inout std_logic_vector (7 downto 0);
    ddr2_devb_dqs_p : inout std_logic;
    ddr2_devb_dqs_n : inout std_logic;
    ddr2_devb_odt   : out   std_logic;
    ddr2_devb_rasn  : out   std_logic;
    ddr2_devb_wen   : out   std_logic;
    
    	--to DM9000A
		ENET_CMD : OUT	std_logic; 
		ENET_CS_N : OUT	std_logic;
		ENET_WR_N : OUT	std_logic;
		ENET_RD_N : out std_logic;
		ENET_CLK : OUT	std_logic;	-- 25 MHz clock.
		ENET_INT : in std_logic;		
		ENET_DATA : INOUT std_logic_vector(15 downto 0);


    -- PMD Mainboard connections
    laser_mod_1     : out std_logic;	-- Red Diodes
    laser_mod_2     : out std_logic;	-- IR Diodes
    laser_tx        : out std_logic;
    laser_rx        : in  std_logic;
    ADC_sdata_read  : in  std_logic;
    ADC_sdata_write : out std_logic;
    ADC_sdata_we_n  : out std_logic;
    ADC_sclk        : out std_logic;
    ADC_sload       : out std_logic;
    ADC_d           : in  std_logic_vector(7 downto 0);
    ADC_adcclk      : out std_logic;
    ADC_cdsclk      : out std_logic;
    PMD_end_r       : in  std_logic;
    PMD_end_c       : in  std_logic;
    PMD_start_c     : out std_logic;
    PMD_start_r     : out std_logic;
    PMD_clk_c       : out std_logic;
    PMD_clk_r       : out std_logic;
    PMD_clear_c     : out std_logic;
    PMD_clear_r     : out std_logic;
    PMD_hold        : out std_logic;
    PMD_reset_n     : out std_logic;
    PMD_mod         : out std_logic;
    spare_rx        : in  std_logic;
    spare_tx        : out std_logic;
    
    -- VGA Connections
    VGA_CLK : out std_logic;
    VGA_R : out std_logic_vector(9 downto 0);
    VGA_G : out std_logic_vector(9 downto 0);
    VGA_B : out std_logic_vector(9 downto 0);
    VGA_HS : out std_logic;
    VGA_VS : out std_logic;
    VGA_blank : out std_logic;
    VGA_sync : out std_logic;

    -- Other
    leds     : out std_logic_vector(7 downto 0);
    buttons  : in  std_logic_vector(3 downto 0);
    switches : in  std_logic_vector(7 downto 0);
    ssd_a    : out std_logic_vector(3 downto 0);
    ssd_c    : out std_logic_vector(8 downto 0);
    debug : out std_logic_vector(7 downto 0)
    );
end PMD19k_Stratix3;

architecture top of PMD19k_Stratix3 is
  
  
--    signal ddr2_devices_a     :   std_logic_vector (12 downto 0);
--    signal ddr2_devices_ba    :   std_logic_vector (1 downto 0);
--    signal ddr2_devices_casn  : std_logic;
--    signal ddr2_devices_cke   : std_logic_vector(1 downto 0);
--    signal ddr2_devices_ck_n  : std_logic_vector(1 downto 0);
--    signal ddr2_devices_ck_p  : std_logic_vector(1 downto 0);
--    signal ddr2_devices_csn   : std_logic_vector(1 downto 0);
--    signal ddr2_devices_dm    : std_logic_vector(1 downto 0);
--    signal ddr2_devices_dq    : std_logic_vector (15 downto 0);
--    signal ddr2_devices_dqs_p : std_logic_vector(1 downto 0);
--    signal ddr2_devices_dqs_n : std_logic_vector(1 downto 0);
--    signal ddr2_devices_odt   : std_logic_vector(1 downto 0);
--    signal ddr2_devices_rasn  : std_logic;
--    signal ddr2_devices_wen   : std_logic;
  
  

  signal ex_clk     : std_logic := '0';
  signal ex_reset_n : std_logic := '0';
  signal reset_debounced : std_logic := '0';
  signal reset_debounced_count : std_logic_vector(7 downto 0) := (others => '0');
  
  signal adcclk : std_logic := '0';
  
  
  signal vga_addr : std_logic_vector(14 downto 0) := (others => '0');
  signal vga_TL_dout : std_logic_vector(15 downto 0) := (others => '0');
  signal vga_TR_dout : std_logic_vector(15 downto 0) := (others => '0');
  signal vga_BL_dout : std_logic_vector(15 downto 0) := (others => '0');
  signal vga_BR_dout : std_logic_vector(15 downto 0) := (others => '0');

  signal control_addr : std_logic_vector(15 downto 0) := (others => '0');
  signal control_din  : std_logic_vector(31 downto 0) := (others => '0');
  signal control_dout : std_logic_vector(31 downto 0) := (others => '0');
  signal control_we_n : std_logic                     := '1';
  signal control_re_n : std_logic                     := '1';

  signal TL_addr : std_logic_vector(15 downto 0) := (others => '0');
  signal TL_din  : std_logic_vector(31 downto 0) := (others => '0');
  signal TL_dout : std_logic_vector(31 downto 0) := (others => '0');
  signal TL_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal TL_we_n : std_logic                     := '1';

  signal TR_addr : std_logic_vector(15 downto 0) := (others => '0');
  signal TR_din  : std_logic_vector(31 downto 0) := (others => '0');
  signal TR_dout : std_logic_vector(31 downto 0) := (others => '0');
  signal TR_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal TR_we_n : std_logic                     := '1';

  signal BL_addr : std_logic_vector(15 downto 0) := (others => '0');
  signal BL_din  : std_logic_vector(31 downto 0) := (others => '0');
  signal BL_dout : std_logic_vector(31 downto 0) := (others => '0');
  signal BL_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal BL_we_n : std_logic                     := '1';

  signal BR_addr : std_logic_vector(15 downto 0) := (others => '0');
  signal BR_din  : std_logic_vector(31 downto 0) := (others => '0');
  signal BR_dout : std_logic_vector(31 downto 0) := (others => '0');
  signal BR_dout_nios : std_logic_vector(31 downto 0) := (others => '0');
  signal BR_we_n : std_logic                     := '1';
  
  signal frame_received : std_logic := '0';
  
  
  
  
begin

    DO_RESET : process (clk125, reset_n)
  begin  -- process DO_RESET
    if reset_n = '0' then               -- asynchronous reset (active low)
      reset_debounced_count      <= (others => '0');
      reset_debounced <= '0';
    elsif rising_edge(clk125) then         -- rising clock edge
      if reset_debounced_count = X"AA" then
        reset_debounced <= '1';
      else
        reset_debounced_count      <= reset_debounced_count + 1;
        reset_debounced <= '0';
      end if;
    end if;
  end process DO_RESET;

  -- Not sure timing is correct here.
  ADC_adcclk <= not adcclk;
  
  PMD_TOP : entity work.PMD_Ranger_top
	generic map (OB_WIDTH => 16)
    port map (
      clk50   => clk50,
      clk     => ex_clk,
      reset_n => reset_debounced,
      s_reset => open,
      leds => leds,
      laser_mod_1     => laser_mod_1,
      laser_mod_2     => laser_mod_2,
      PMD_clk_r       => PMD_clk_r,
      PMD_clk_c       => PMD_clk_c,
      PMD_clear_r     => PMD_clear_r,
      PMD_clear_c     => PMD_clear_c,
      PMD_start_r     => PMD_start_r,
      PMD_start_c     => PMD_start_c,
      PMD_hold        => PMD_hold,
      PMD_reset_n     => PMD_reset_n,
      PMD_end_r       => PMD_end_r,
      PMD_end_c       => PMD_end_c,
      PMD_mod         => PMD_mod,
      ADC_d           => ADC_d,
      ADC_adcclk      => adcclk,
      ADC_cdsclk      => ADC_cdsclk,
      ADC_sdata_write => ADC_sdata_write,
      ADC_sdata_read  => ADC_sdata_read,
      ADC_sclk        => ADC_sclk,
      ADC_sload       => ADC_sload,
      ADC_sdata_we_n  => ADC_sdata_we_n,

      vga_addr      => vga_addr,
      vga_TL_dout   => vga_TL_dout,
      vga_TR_dout   => vga_TR_dout,
      vga_BL_dout   => vga_BL_dout,
      vga_BR_dout   => vga_BR_dout,

      control_addr => control_addr,
      control_din  => control_din,
      control_dout => control_dout,
      control_we_n => control_we_n,
      control_re_n => control_re_n,
      
      frame_received => frame_received,

      TL_addr => TL_addr(14 downto 0),
      TL_din  => TL_din(15 downto 0),
      TL_dout => TL_dout(15 downto 0),
      TL_we_n => TL_we_n,

      TR_addr => TL_addr(14 downto 0),
      TR_din  => TR_din(15 downto 0),
      TR_dout => TR_dout(15 downto 0),
      TR_we_n => TR_we_n,

      BL_addr => BL_addr(14 downto 0),
      BL_din  => BL_din(15 downto 0),
      BL_dout => BL_dout(15 downto 0),
      BL_we_n => BL_we_n,

      BR_addr => BL_addr(14 downto 0),
      BR_din  => BR_din(15 downto 0),
      BR_dout => BR_dout(15 downto 0),
      BR_we_n => BR_we_n
      ); 

TL_dout_nios <= TR_dout(15 downto 0) & TL_dout(15 downto 0);
	TR_dout_nios <= TL_dout(15 downto 0) & TR_dout(15 downto 0);
	BL_dout_nios <= BR_dout(15 downto 0) & BL_dout(15 downto 0);
	BR_dout_nios <= BL_dout(15 downto 0) & BR_dout(15 downto 0);
  
  THE_VGA : entity work.vga_tester
	generic map (testing => '0',
			clk_div => "0011")
	port map (
		clk => ex_clk,
		reset_n => reset_debounced,
		
		video_address => vga_addr,
		ram_dout_TL => vga_TL_dout,
		ram_dout_TR => vga_TR_dout,
		ram_dout_BL => vga_BL_dout,
		ram_dout_BR => vga_BR_dout,
		
		VGA_CLK => VGA_CLK,
		VGA_R => VGA_R,
		VGA_G => VGA_G,
		VGA_B => VGA_B,
		VGA_VS => VGA_VS,
		VGA_HS => VGA_HS,
		VGA_blank => VGA_blank,
		VGA_sync => VGA_sync
		);
		
		

-- Ranger_cpu SOPC instance
  THE_RANGER_CPU : entity work.ranger_cpu
    port map (
      clk125  => clk125,
      clk50	  => clk50,
      reset_n => reset_debounced,

      -- the_ddr2_deva
      global_reset_n_to_the_ddr2_deva     => reset_n,
      mem_addr_from_the_ddr2_deva         => ddr2_deva_a,
      mem_ba_from_the_ddr2_deva          => ddr2_deva_ba,
      mem_cas_n_from_the_ddr2_deva        => ddr2_deva_casn,
      mem_cke_from_the_ddr2_deva          => ddr2_deva_cke,
      mem_clk_n_to_and_from_the_ddr2_deva => ddr2_deva_ck_n,
      mem_clk_to_and_from_the_ddr2_deva   => ddr2_deva_ck_p,
      mem_cs_n_from_the_ddr2_deva       => ddr2_deva_csn,
      mem_dm_from_the_ddr2_deva          => ddr2_deva_dm,
      mem_dq_to_and_from_the_ddr2_deva    => ddr2_deva_dq,
      mem_dqs_to_and_from_the_ddr2_deva   => ddr2_deva_dqs_p,
      mem_dqsn_to_and_from_the_ddr2_deva  => ddr2_deva_dqs_n,
      mem_odt_from_the_ddr2_deva          => ddr2_deva_odt,
      mem_ras_n_from_the_ddr2_deva       => ddr2_deva_rasn,
      mem_we_n_from_the_ddr2_deva        => ddr2_deva_wen,
      oct_ctl_rs_value_to_the_ddr2_deva   => (others => '0'),
      oct_ctl_rt_value_to_the_ddr2_deva  => (others => '0'),
      
      -- the_ddr2_devb
      global_reset_n_to_the_ddr2_devb     => reset_n,
      mem_addr_from_the_ddr2_devb         => ddr2_devb_a,
      mem_ba_from_the_ddr2_devb          => ddr2_devb_ba,
      mem_cas_n_from_the_ddr2_devb        => ddr2_devb_casn,
      mem_cke_from_the_ddr2_devb          => ddr2_devb_cke,
      mem_clk_n_to_and_from_the_ddr2_devb => ddr2_devb_ck_n,
      mem_clk_to_and_from_the_ddr2_devb   => ddr2_devb_ck_p,
      mem_cs_n_from_the_ddr2_devb       => ddr2_devb_csn,
      mem_dm_from_the_ddr2_devb          => ddr2_devb_dm,
      mem_dq_to_and_from_the_ddr2_devb    => ddr2_devb_dq,
      mem_dqs_to_and_from_the_ddr2_devb   => ddr2_devb_dqs_p,
      mem_dqsn_to_and_from_the_ddr2_devb  => ddr2_devb_dqs_n,
      mem_odt_from_the_ddr2_devb          => ddr2_devb_odt,
      mem_ras_n_from_the_ddr2_devb       => ddr2_devb_rasn,
      mem_we_n_from_the_ddr2_devb        => ddr2_devb_wen,
      oct_ctl_rs_value_to_the_ddr2_devb   => (others => '0'),
      oct_ctl_rt_value_to_the_ddr2_devb  => (others => '0'),
      
           ENET_CLK_from_the_dm9000a => ENET_CLK,
      ENET_CMD_from_the_dm9000a => ENET_CMD,
      ENET_CS_N_from_the_dm9000a => ENET_CS_N,
      ENET_DATA_to_and_from_the_dm9000a => ENET_DATA,
      ENET_INT_to_the_dm9000a => ENET_INT,
      ENET_RD_N_from_the_dm9000a => ENET_RD_N,
      ENET_WR_N_from_the_dm9000a => ENET_WR_N,
      ENET_RST_N_from_the_dm9000a => open,
      iOSC_50_to_the_dm9000a => clk50,

      ex_clk_from_the_control     => ex_clk,
      ex_reset_n_from_the_control => ex_reset_n,
      ex_addr_from_the_control   => control_addr,
      ex_din_from_the_control     => control_din,
      ex_we_n_from_the_control    => control_we_n,
      ex_re_n_from_the_control    => control_re_n,
      ex_dout_to_the_control      => control_dout,

      ex_dout_to_the_TL   => TL_dout_nios,
      ex_addr_from_the_TL => TL_addr,
      ex_din_from_the_TL  => TL_din,
      ex_we_n_from_the_TL => TL_we_n,
      
      ex_dout_to_the_TR   => TR_dout_nios,
      ex_addr_from_the_TR => TR_addr,
      ex_din_from_the_TR  => TR_din,
      ex_we_n_from_the_TR => TR_we_n,
      
      ex_dout_to_the_BL   => BL_dout_nios,
      ex_addr_from_the_BL => BL_addr,
      ex_din_from_the_BL  => BL_din,
      ex_we_n_from_the_BL => BL_we_n,
      
      ex_dout_to_the_BR   => BR_dout_nios,
      ex_addr_from_the_BR => BR_addr,
      ex_din_from_the_BR  => BR_din,
      ex_we_n_from_the_BR => BR_we_n,

      txd_from_the_laser_uart => open,
      rxd_to_the_laser_uart   => laser_rx,
      
      in_port_to_the_frame_received => frame_received
      );

--	ddr2_deva_a <= ddr2_devices_a;
--    ddr2_deva_ba <= ddr2_devices_ba;
--    ddr2_deva_casn <= ddr2_devices_casn; 
--    ddr2_deva_cke <= ddr2_devices_cke(0); 
--    ddr2_deva_csn <= ddr2_devices_csn(0); 
--    ddr2_deva_dm <= ddr2_devices_dm(0);  
--    ddr2_deva_odt <= ddr2_devices_odt(0);  
--    ddr2_deva_rasn <= ddr2_devices_rasn; 
--    ddr2_deva_wen <= ddr2_devices_wen; 
--    
--    ddr2_devb_a <= ddr2_devices_a;
--    ddr2_devb_ba <= ddr2_devices_ba;
--    ddr2_devb_casn <= ddr2_devices_casn; 
--    ddr2_devb_cke <= ddr2_devices_cke(1); 
--    ddr2_devb_csn <= ddr2_devices_csn(1); 
--    ddr2_devb_dm <= ddr2_devices_dm(1);  
--    ddr2_devb_odt <= ddr2_devices_odt(1);  
--    ddr2_devb_rasn <= ddr2_devices_rasn; 
--    ddr2_devb_wen <= ddr2_devices_wen; 

  
end top;
