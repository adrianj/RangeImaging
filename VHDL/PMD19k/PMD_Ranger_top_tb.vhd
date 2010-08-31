library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use std.textio.all;
use work.testbench_functions.all;

entity PMD_Ranger_top_tb is

end PMD_Ranger_top_tb;

architecture testbench of PMD_Ranger_top_tb is
						 
	constant outFileName : string :=  "D:\AVIs\test\rangerRiviera.hex";	
	constant useFile : std_logic := '1';

  signal clk100     : std_logic; 
  signal clk50   : std_logic;
  signal reset_n : std_logic;

  -- PMD Mainboard connections
  signal laser_mod_1     : std_logic;
  signal laser_mod_2     : std_logic;
  signal ADC_sdata_read  : std_logic                    := '0';
  signal ADC_sdata_write : std_logic;
  signal ADC_sdata_we_n  : std_logic;
  signal ADC_sclk        : std_logic;
  signal ADC_sload       : std_logic;
  signal ADC_d           : std_logic_vector(7 downto 0) := (others => '1');
  signal ADC_adcclk      : std_logic;
  signal ADC_cdsclk      : std_logic;
  signal PMD_end_r       : std_logic                    := '0';
  signal PMD_end_c       : std_logic                    := '0';
  signal PMD_start_c     : std_logic;
  signal PMD_start_r     : std_logic;
  signal PMD_clk_c       : std_logic;
  signal PMD_clk_r       : std_logic;									
  signal PMD_clear_c     : std_logic;
  signal PMD_clear_r     : std_logic;
  signal PMD_hold        : std_logic;
  signal PMD_reset_n     : std_logic;
  signal PMD_mod         : std_logic;

  -- VGA Module connections
  signal vga_addr    : std_logic_vector(14 downto 0) := (others => '0');
  signal vga_TL_dout : std_logic_vector(15 downto 0);
  signal vga_TR_dout : std_logic_vector(15 downto 0);
  signal vga_BL_dout : std_logic_vector(15 downto 0);
  signal vga_BR_dout : std_logic_vector(15 downto 0);

  -- Nios connections
  signal control_addr   : std_logic_vector(15 downto 0) := (others => '0');
  signal control_din    : std_logic_vector(31 downto 0) := (others => '0');
  signal control_dout   : std_logic_vector(31 downto 0);
  signal control_we_n   : std_logic                     := '1';
  signal control_re_n   : std_logic                     := '1';
  signal frame_received : std_logic                     := '0';
  signal TL_addr        : std_logic_vector(15 downto 0) := (others => '0');
  signal TL_din         : std_logic_vector(15 downto 0) := (others => '0');
  signal TL_dout        : std_logic_vector(15 downto 0);
  signal TL_we_n        : std_logic                     := '1';	 
  signal TL_re_n        : std_logic                     := '1';
  signal TR_addr        : std_logic_vector(14 downto 0) := (others => '0');
  signal TR_din         : std_logic_vector(15 downto 0) := (others => '0');
  signal TR_dout        : std_logic_vector(15 downto 0);
  signal TR_we_n        : std_logic                     := '1';
  signal BL_addr        : std_logic_vector(14 downto 0) := (others => '0');
  signal BL_din         : std_logic_vector(15 downto 0) := (others => '0');
  signal BL_dout        : std_logic_vector(15 downto 0);
  signal BL_we_n        : std_logic                     := '1';
  signal BR_addr        : std_logic_vector(14 downto 0) := (others => '0');
  signal BR_din         : std_logic_vector(15 downto 0) := (others => '0');
  signal BR_dout        : std_logic_vector(15 downto 0);
  signal BR_we_n        : std_logic                     := '1';	
  
  signal output_file_data : std_logic_vector(31 downto 0) := (others => '0');
  signal model_reset : std_logic := '1'; 
  signal s_reset : std_logic := '0';


  -- Other testing signals
  signal row_addr    : std_logic_vector(6 downto 0) := (others => '0');
  signal column_addr : std_logic_vector(7 downto 0) := (others => '0');
  
begin  -- testbench
  
  PMD_INT : entity work.PMD_Ranger_top	
  	generic map (IS_CYCLONE3 => '1',
		OB_WIDTH => 10,
		SMALL_RAM => '1')
    port map (	 
      clk     => clk100,
	  clk50		=> clk50,
      reset_n => reset_n, 
	  s_reset => s_reset,

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
      ADC_adcclk      => ADC_adcclk,
      ADC_cdsclk      => ADC_cdsclk,
      ADC_sdata_write => ADC_sdata_write,
      ADC_sdata_read  => ADC_sdata_read,
      ADC_sclk        => ADC_sclk,
      ADC_sload       => ADC_sload,
      ADC_sdata_we_n  => ADC_sdata_we_n,

      vga_addr    => vga_addr,
      vga_TL_dout => vga_TL_dout,
      vga_TR_dout => vga_TR_dout,
      vga_BL_dout => vga_BL_dout,
      vga_BR_dout => vga_BR_dout,

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

      TR_addr => TR_addr(14 downto 0),
      TR_din  => TR_din(15 downto 0),
      TR_dout => TR_dout(15 downto 0),
      TR_we_n => TR_we_n,

      BL_addr => BL_addr(14 downto 0),
      BL_din  => BL_din(15 downto 0),
      BL_dout => BL_dout(15 downto 0),
      BL_we_n => BL_we_n,

      BR_addr => BR_addr(14 downto 0),
      BR_din  => BR_din(15 downto 0),
      BR_dout => BR_dout(15 downto 0),
      BR_we_n => BR_we_n
      ); 

	GEN_FILES : if useFile = '1' generate
    PMD_MODEL : entity work.PMD19k_model	
	generic map (   inFileName => "D:\AVIs\test\testpattern_19k.hex")	 
	--generic map (   inFileName => "")
    port map (		  
	  reset_n => model_reset,
      clk_c    => PMD_clk_c,
      clk_r    => PMD_clk_r,
      clear_c  => PMD_clear_c,
      clear_r  => PMD_clear_r,
      end_c    => open,--PMD_end_c,
      end_r    => open,--PMD_end_r,
      adcclk   => ADC_adcclk,
      cdsclk   => ADC_cdsclk,
      adc_data => ADC_d); 	   
	  PMD_end_c <= '0';
	  PMD_end_r <= '1';
	  end generate;	
	  
	  GEN_NOT_FILE : if useFile = '0' generate
	  	PMD_end_c <= '0';
		PMD_end_r <= '0';
	  end generate;
	  
  model_reset <= not s_reset;


  --THE_VGA : entity work.vga_tester
    --generic map (testing => '0')
    --port map (
      --clk     => clk,
      --reset_n => reset_n,

      --video_address => vga_addr,
      --ram_dout_TL   => vga_TL_dout,
      --ram_dout_TR   => vga_TR_dout,
      --ram_dout_BL   => vga_BL_dout,
      --ram_dout_BR   => vga_BR_dout

      --VGA_CLK   => VGA_CLK,
      --VGA_R     => VGA_R,
      --VGA_G     => VGA_G,
      --VGA_B     => VGA_B,
      --VGA_VS    => VGA_VS,
      --VGA_HS    => VGA_HS,
      --VGA_blank => VGA_blank,
      --VGA_sync  => VGA_sync
      --);          
				   
  				   
  --PMD_end_c <= '0';
  --PMD_end_r <= '1';

  SYS_CLK : process
  begin  -- process SYS_CLK
    clk100 <= '0';
    wait for 5 ns;
    clk100 <= '1';
    wait for 5 ns;
  end process SYS_CLK;
  
  SYS_CLK50 : process
  begin  -- process SYS_CLK
    clk50 <= '0';
    wait for 10 ns;
    clk50 <= '1';
    wait for 10 ns;
  end process SYS_CLK50;  

  D_RESET : process	  
  	variable col_address : std_logic_vector(7 downto 0) := (others => '0');
	variable row_address : std_logic_vector(6 downto 0) := (others => '0');
    file outFile      : text open write_mode is outFileName;
  begin  -- process D_RESET
    reset_n <= '0';	 
	TL_addr <= (others => '0');
	TL_din <= (others => '0');
	TL_we_n <= '1';
    wait for 500 ns;
    reset_n <= '1';
    wait until clk100 = '1';
    -- Set max_frames
    niosWrite(X"0003", X"00000100", clk100, control_addr, control_din, control_we_n);
    -- Set Frame period
    niosWrite(X"0000", X"00000C80", clk100, control_addr, control_din, control_we_n);
	-- Set Integration period
    niosWrite(X"0001", X"00000C80", clk100, control_addr, control_din, control_we_n); 
	-- Set FPB_1
    niosWrite(X"0010", X"00000004", clk100, control_addr, control_din, control_we_n);
	-- Set phase step_1	   CHANGED (was 2^16/fpb) Now is 240/fpb.
    niosWrite(X"0012", X"0000003C", clk100, control_addr, control_din, control_we_n);
	-- Set phase scale 1   CHANGED, this is 2^16 / (cHi + cLo)
	niosWrite(X"0018", X"00000111", clk100, control_addr, control_din, control_we_n);
	-- Set FPB_2
    niosWrite(X"0011", X"00000004", clk100, control_addr, control_din, control_we_n);
	-- Set phase step_2
    niosWrite(X"0013", X"0000003C", clk100, control_addr, control_din, control_we_n);
	-- Set phase scale 2
	niosWrite(X"0019", X"00000111", clk100, control_addr, control_din, control_we_n);
	-- Set FPOF
    --niosWrite(X"0008", X"00000005", clk100, control_addr, control_din, control_we_n);
    -- Set Integration Ratio
    --niosWrite(X"0014", X"00000000", clk100, control_addr, control_din, control_we_n); 
	-- Set Process select
    --niosWrite(X"0015", X"00000001", clk100, control_addr, control_din, control_we_n);
   					 
	
	-- modulation c0 hi count	   (80 MHz output, 50% DC)
    --niosWrite(X"0024", X"00000008", clk100, control_addr, control_din, control_we_n);
	wait for 100 ns;
	-- modulation c0 low count			
	--niosWrite(X"0025", X"00000007", clk100, control_addr, control_din, control_we_n); 
	wait for 100 ns;  
	-- modulation c1 hi count	
    --niosWrite(X"0026", X"00000008", clk100, control_addr, control_din, control_we_n);
	wait for 100 ns;
	-- modulation c1 low count			
	--niosWrite(X"0027", X"00000007", clk100, control_addr, control_din, control_we_n); 
	wait for 100 ns; 	  
	-- r_sel_odd to give 50% duty cycle
	--niosWrite(X"002A", X"00000003", clk100, control_addr, control_din, control_we_n); 
	--wait for 100 ns; 
	-- change initial step
	--niosWrite(X"0021", X"00000078", clk100, control_addr, control_din, control_we_n);
	wait for 100 ns;   
	-- initiate pll1 reconfig
	--niosWrite(X"0023", X"00000001", clk100, control_addr, control_din, control_we_n);
	wait for 10 us;
		 	
		
	-- Set frequency of second source  
    --niosWrite(X"0034", X"0000000F", clk100, control_addr, control_din, control_we_n);
	--wait for 100 ns;
	--niosWrite(X"0035", X"0000000F", clk100, control_addr, control_din, control_we_n); 
	--wait for 100 ns;  	
    --niosWrite(X"0036", X"0000000F", clk100, control_addr, control_din, control_we_n);
	--wait for 100 ns;		
	--niosWrite(X"0037", X"0000000F", clk100, control_addr, control_din, control_we_n); 
	--wait for 100 ns;  
	-- modulation m hi count	
    --niosWrite(X"0038", X"0000000A", clk100, control_addr, control_din, control_we_n);
	--wait for 100 ns;
	-- modulation m low count			
	--niosWrite(X"0039", X"0000000A", clk100, control_addr, control_din, control_we_n); 
	--wait for 6000 ns;  
	-- initiate pll1 reconfig
	--niosWrite(X"0023", X"00000001", clk100, control_addr, control_din, control_we_n);
	--wait for 100 ns;
	-- initiate pll2 reconfig
	--niosWrite(X"0033", X"00000001", clk100, control_addr, control_din, control_we_n);
	--wait for 100 ns;	 
	--wait for 120 us;		 
	-- Pause
	--niosWrite(X"0007", X"00000001", clk100, control_addr, control_din, control_we_n);  
	--wait for 10 us;												   
	-- Set max_frames
    --niosWrite(X"0003", X"0000000A", clk100, control_addr, control_din, control_we_n);
	--wait for 10 us;
	-- S_reset 
    --niosWrite(X"000A", X"00000001", clk100, control_addr, control_din, control_we_n);	
	--wait for 10 us;
	-- Unpause
	--niosWrite(X"0007", X"00000000", clk100, control_addr, control_din, control_we_n);
	
 		wait;			     
		wait for 500 us;
		-- change initial step
		--niosWrite(X"0021", X"00000096", clk100, control_addr, control_din, control_we_n);
		wait for 100 ns;  
		wait for 10 us;	
		-- Unpause
		niosWrite(X"0007", X"00000000", clk100, control_addr, control_din, control_we_n);
		-- S_reset 
    	niosWrite(X"000A", X"00000001", clk100, control_addr, control_din, control_we_n); 
		
		wait for 500 us;
		-- change initial step
		niosWrite(X"0021", X"000000B4", clk100, control_addr, control_din, control_we_n);
		wait for 100 ns;  
		wait for 10 us;	
		-- Unpause
		niosWrite(X"0007", X"00000000", clk100, control_addr, control_din, control_we_n);
		-- S_reset 
    	niosWrite(X"000A", X"00000001", clk100, control_addr, control_din, control_we_n);

	   wait for 500 us;
		-- change initial step
		niosWrite(X"0021", X"000000D2", clk100, control_addr, control_din, control_we_n);
		wait for 100 ns;  
		wait for 10 us;	
		-- Unpause
		niosWrite(X"0007", X"00000000", clk100, control_addr, control_din, control_we_n);
		-- S_reset 
    	niosWrite(X"000A", X"00000001", clk100, control_addr, control_din, control_we_n); 
		
		wait for 500 us;
		-- change initial step
		niosWrite(X"0021", X"00000000", clk100, control_addr, control_din, control_we_n);
		wait for 100 ns;  
		wait for 10 us;	
		-- Unpause
		niosWrite(X"0007", X"00000000", clk100, control_addr, control_din, control_we_n);
		-- S_reset 
    	niosWrite(X"000A", X"00000001", clk100, control_addr, control_din, control_we_n);
	
	
    loop
      wait for 1000 ns;
      if frame_received = '1' then 	 
	  
	    if useFile = '1' then
	  	row_address   := (others => '0');
        -- Read from output buffer
        for i in 0 to 119 loop		
			col_address := (others => '0');
			for j in 0 to 159 loop
          		niosRead('0' & row_address & col_address, clk100, TL_addr, TL_re_n);
          		writeFile32(output_file_data, outFile);	
				col_address := col_address + 1;
		  end loop;
          row_address := row_address + 1;
        end loop;  
		end if;
        niosWrite(X"0006", X"00000000", clk100, control_addr, control_din, control_we_n);
      end if;
    end loop; 

      wait;
  end process D_RESET;	
  
  output_file_data <= BR_dout & BL_dout;

--  INIT_BUFFERS : process (clk, reset_n)
--  begin  -- process WRITE_BUFFERS
--    if reset_n = '0' then               -- asynchronous reset (active low)
--      row_addr    <= (others => '0');
--      column_addr <= (others => '0');
--      TL_addr     <= (others => '0');
--      TL_we_n     <= '1';
--      TL_din      <= (others => '0');
--    elsif rising_edge(clk) then         -- rising clock edge
--      if row_addr = 119 and column_addr = 160 then
--        TL_we_n <= '1';
--      else
--        if column_addr = 160 then
--          row_addr <= row_addr + 1;
--        end if;
--        column_addr <= column_addr + 1;
--        TL_we_n     <= '0';
--        TL_addr     <= row_addr & column_addr;
--        TL_din      <= "00" & row_addr(5 downto 0) & column_addr(7 downto 0);
--      end if;
--    end if;
--  end process INIT_BUFFERS;

  --TR_we_n <= TL_we_n;
  TR_addr <= TL_addr(14 downto 0);
  TR_din  <= "01" & TL_din(13 downto 0);
  BR_we_n <= TL_we_n;
  BR_addr <= TL_addr(14 downto 0);
  BR_din  <= "10" & TL_din(13 downto 0);
  BL_we_n <= TL_we_n;
  BL_addr <= TL_addr(14 downto 0);
  BL_din  <= "11" & TL_din(13 downto 0);

end testbench;
