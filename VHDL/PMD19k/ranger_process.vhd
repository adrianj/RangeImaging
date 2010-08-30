-- Inner product calculation for depth ranging.
-- Sine and Cosine must be provided by modulation scheme.
-- Uses cordic_atan.			
-- Input bit width is B
-- Sine/Cosine width is B + logN, to ensure quantisation error is less than the round off error after multiplication.
-- Multiplication output therefore is 2B + logN - 1, since both inputs are signed.
-- Accumulator must account for logN extra bits at the top to prevent overflow (slightly more complex than this, ie, overspecified)
-- and also logN extra bits at the bottom to minimise the accumulation of round-off errors.
-- So, RAM width for each real and imaginary part is B + 2*logN.
-- Width of CORDIC should be at least B + log(2*PI) + log(N)/2 [averaging] ~= B + 5 for N = 16,
--
-- In actuality, RAM is scarce, logic is plentiful. So do full scale multiplication always, and use large sine/cosine values.
-- But scale result into RAM of B + 2logN wide, logN bits extra at the top, logN bits at the bottom.
--
-- CORDIC is also quite cheap, so just use CORDIC width equal to accumulator width.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ranger_process is
  generic ( ACC_WIDTH : integer := 22;	  -- default of 22 is for 16 bit inputs, and N=8.
  			logN : integer := 3);			  
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    pixel_a      : in  std_logic_vector(15 downto 0);
    pixel_b      : in  std_logic_vector(15 downto 0);
    pixel_addr   : in  std_logic_vector(14 downto 0);
    pixel_valid  : in  std_logic;
    frame_index  : in  std_logic_vector(15 downto 0);
    output_phase : out std_logic_vector(15 downto 0);
    output_mag   : out std_logic_vector(15 downto 0);
    output_addr  : out std_logic_vector(14 downto 0);
    output_valid : out std_logic;

    -- extra channel for outputting whatever I like.
    debug_data  : out std_logic_vector(15 downto 0);
    debug_addr  : out std_logic_vector(14 downto 0);
    debug_valid : out std_logic;

    sine        : in std_logic_vector(15 downto 0);
    cosine      : in std_logic_vector(15 downto 0);
    pixel_scale : in std_logic_vector(3 downto 0);
    dc_offset   : in std_logic_vector(15 downto 0);
    saturation_level : in std_logic_vector(15 downto 0);
    phase_correction : in std_logic_vector(15 downto 0)
    );

end ranger_process;

architecture rtl of ranger_process is
  
  constant W : integer := ACC_WIDTH; 
  constant logN_ZEROS : std_logic_vector(logN-1 downto 0) := (others => '0');	
  signal CORDIC_WIDTH : integer := 16;

  signal sat1 : std_logic := '0';
  signal sat2 : std_logic := '0';
  signal pixel_diff     : std_logic_vector(15 downto 0) := (others => '0');
  signal pixel_real     : std_logic_vector(30 downto 0) := (others => '0');
  signal pixel_imag     : std_logic_vector(30 downto 0) := (others => '0');		
  signal pixel_real_scaled : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_imag_scaled : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_real_acc : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_imag_acc : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_real_old : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_imag_old : std_logic_vector(W-1 downto 0) := (others => '0');

  -- 1 is acc read addr. 3 is acc write addr.
  signal pixel_addr_0 : std_logic_vector(14 downto 0) := (others => '0');
  signal pixel_addr_1 : std_logic_vector(14 downto 0) := (others => '0');
  signal pixel_addr_2 : std_logic_vector(14 downto 0) := (others => '0');
  signal pixel_addr_3 : std_logic_vector(14 downto 0) := (others => '0');

  signal valid_0 : std_logic := '0';
  signal valid_1 : std_logic := '0';
  signal valid_2 : std_logic := '0';
  signal valid_3 : std_logic := '0';

  signal atan_storage_in  : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_storage_out : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_real        : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_imag        : std_logic_vector(15 downto 0) := (others => '0');	
  signal atan_phase : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_mag : std_logic_vector(15 downto 0) := (others => '0');	
  signal atan_mag_log : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_valid : std_logic := '0';
  signal atan_addr : std_logic_vector(14 downto 0) := (others => '0');

  signal offset_result : std_logic_vector(15 downto 0) := (others => '0');	 
  
  --signal mag_log_test : std_logic_vector(15 downto 0) := (others => '0');  
  --signal atan_mag_test : std_logic_vector(15 downto 0) := (others => '0');
  
  																					   
begin  -- rtl	 
										
  MULT_REAL : entity work.signedmultXxY
	generic map ( X => 16,
				  Y => 16)
    port map (
      clk => clk,
      a   => cosine,
      b   => pixel_diff,
      q   => pixel_real);

  MULT_IMAG : entity work.signedmultXxY
	generic map ( X => 16,
				  Y => 16)
	port map (
      clk => clk,
      a   => sine,
      b   => pixel_diff,
      q   => pixel_imag);
      
  THE_CORDIC : entity work.cordic_atan
    generic map (
      N => 16,
      I => 16)--ACC_WIDTH) -- 16 + logN	 
    port map (
      clk         => clk,
      reset_n     => reset_n,
      real_in     => atan_real,
      imag_in     => atan_imag,
      phase_out   => atan_phase,
      mag_out     => atan_mag,
      nd          => valid_3,
      rdy         => atan_valid,
      storage_in  => atan_storage_in,
      storage_out => atan_storage_out);	  
	  
	 

  RAM_ACC_REAL : entity work.dualram160x128xN
    generic map ( N => W )
    port map (
      address_a => pixel_addr_3,
      address_b => pixel_addr_1,
      clock     => clk,
      data_a    => pixel_real_acc,
      data_b    => (others => '0'),
      wren_a    => valid_3,
      wren_b    => '0',
      q_a       => open,
      q_b       => pixel_real_old);   

  RAM_ACC_IMAG : entity work.dualram160x128xN	
    generic map ( N => W )
    port map (
      address_a => pixel_addr_3,
      address_b => pixel_addr_1,
      clock     => clk,
      data_a    => pixel_imag_acc,
      data_b    => (others => '0'),
      wren_a    => valid_3,
      wren_b    => '0',
      q_a       => open,
      q_b       => pixel_imag_old); 
      						   		  
  pixel_real_scaled(W-1 downto W-logN+1) <= (others => pixel_real(30));
  pixel_real_scaled(W-logN downto 0) <= pixel_real(30 downto 30-W+logN);   
  pixel_imag_scaled(W-1 downto W-logN+1) <= (others => pixel_imag(30));
  pixel_imag_scaled(W-logN downto 0) <= pixel_imag(30 downto 30-W+logN);

  atan_storage_in <= '0' & pixel_addr_3;   
  atan_addr     <= atan_storage_out(14 downto 0); 	  
  
  GEN_BIG : if ACC_WIDTH >= 16 generate
  atan_real       <= pixel_real_acc(W-1 downto W-16);
  atan_imag       <= pixel_imag_acc(W-1 downto W-16); 
  end generate;	   
  
  GEN_SMALL : if ACC_WIDTH < 16 generate
  atan_real(15 downto 16-W) <= pixel_real_acc;
  atan_real(15-W downto 0) <= (others => '0');
  atan_imag(15 downto 16-W) <= pixel_imag_acc;
  atan_imag(15-W downto 0) <= (others => '0');
  end generate;
 										   

  EVERYTHING : process (clk, reset_n)
    variable subResult : std_logic_vector(15 downto 0) := (others => '0');
    variable diff : std_logic_vector(15 downto 0) := (others => '0');
    --variable sat : std_logic := '0';
  begin  -- process EVERYTHING
    if reset_n = '0' then               -- asynchronous reset (active low)
      sat1 <= '0';
      sat2 <= '0';
      pixel_diff     <= (others => '0');
      pixel_addr_0   <= (others => '0');
      pixel_addr_1   <= (others => '0');
      pixel_addr_2   <= (others => '0');
      pixel_addr_3   <= (others => '0');
      pixel_real_acc <= (others => '0');
      pixel_imag_acc <= (others => '0');
      valid_0        <= '0';
      valid_1        <= '0';
      valid_2        <= '0';
      valid_3        <= '0';

      debug_data    <= (others => '0');
      debug_valid   <= '0';
      debug_addr    <= (others => '0');
      offset_result <= (others => '0');
      
      output_phase <= (others => '0');
      output_mag <= (others => '0');
      output_valid <= '0';
      
    elsif rising_edge(clk) then         -- rising clock edge
      -- clk cycle 0
      
      
      --if pixel_a < saturation_level or pixel_b < saturation_level then
		--	sat1 <= '1';
		--else
		--	sat1 <= '0';
		--end if;
		subResult := pixel_a - pixel_b;
      --if dc_offset(15) = '1' then
        offset_result <= subResult + dc_offset;
      --else
        --offset_result <= subResult + ('0' & dc_offset);
      --end if;
      valid_0      <= pixel_valid;
      pixel_addr_0 <= pixel_addr;

      -- clk cycle 1
      diff   := shl(offset_result, pixel_scale);
      pixel_diff <= diff;
      valid_1      <= valid_0;
      pixel_addr_1 <= pixel_addr_0;
      sat2 <= sat1;

      -- clk cycle 2
      -- Multiplication happening in seperate process
      valid_2      <= valid_1;
      pixel_addr_2 <= pixel_addr_1;
      --debug_data  <= pixel_diff(B downto 1);
      --debug_addr   <= pixel_addr_1;
      --debug_valid  <= valid_1;

      -- clk cycle 3
      -- Multiplication result available.
      -- acc_old values available.
      valid_3 <= valid_2;
      if frame_index = X"0000" then
        pixel_real_acc <= pixel_real_scaled;
        pixel_imag_acc <= pixel_imag_scaled;
      else
        pixel_real_acc <= pixel_real_old + pixel_real_scaled;
        pixel_imag_acc <= pixel_imag_old + pixel_imag_scaled;
      end if;
      pixel_addr_3 <= pixel_addr_2;	  
	  
	  --debug_data  <= pixel_real_old(W-1 downto W-B);
      --debug_addr   <= pixel_addr_2;
      --debug_valid  <= valid_2;

      -- clk cycle 4
      -- acc values are available for atan.	
	  debug_data  <= pixel_real_acc(W-1 downto W-4)&X"000";
      debug_addr   <= pixel_addr_3;
      debug_valid  <= valid_3;
      
      -- clk cycle XXX (after atan)
      output_valid <= atan_valid;	   
	  
	  -- This line, select either atan_mag  or  atan_mag_log.
      output_mag <= atan_mag_log;
      output_addr <= atan_addr;
      output_phase <= atan_phase + phase_correction;
      
      
    end if;
  end process EVERYTHING;
		
	LOG_CALC : entity work.simple_logarithm	 
	port map (
		linear_in => atan_mag,
		log_out => atan_mag_log);
		
--	process(clk, reset_n)
--	begin
--		if reset_n = '0' then
--			atan_mag_test <= (others => '0');
--		elsif rising_edge(clk) then
--			atan_mag_test <= atan_mag_test + 1;
--		end if;
--	end process;

end rtl;
