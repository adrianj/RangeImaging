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
  generic (ACC_WIDTH : integer   := 12;  -- default of 22 is for 16 bit inputs, and N=8.
           logN      : integer   := 3;
           SMALL_RAM : std_logic := '0');                     
  port (
    clk         : in std_logic;
    reset_n     : in std_logic;
    pixel_a     : in std_logic_vector(15 downto 0);
    pixel_b     : in std_logic_vector(15 downto 0);
    pixel_addr  : in std_logic_vector(14 downto 0);
    pixel_valid : in std_logic;
    frame_index : in std_logic_vector(15 downto 0);

    -- The old way had specified output channels with shared address
    --output_phase : out std_logic_vector(15 downto 0);
    --output_mag   : out std_logic_vector(15 downto 0);
    --output_addr  : out std_logic_vector(14 downto 0);
    --output_valid : out std_logic;

    -- The new way has independent output channels, with the data selectable by
    -- register 0x
    output_valid_1 : out std_logic                     := '0';
    output_data_1  : out std_logic_vector(15 downto 0) := (others => '0');
    output_addr_1  : out std_logic_vector(14 downto 0) := (others => '0');
    output_valid_2 : out std_logic                     := '0';
    output_data_2  : out std_logic_vector(15 downto 0) := (others => '0');
    output_addr_2  : out std_logic_vector(14 downto 0) := (others => '0');
    output_valid_3 : out std_logic                     := '0';
    output_data_3  : out std_logic_vector(15 downto 0) := (others => '0');
    output_addr_3  : out std_logic_vector(14 downto 0) := (others => '0');
    output_valid_4 : out std_logic                     := '0';
    output_data_4  : out std_logic_vector(15 downto 0) := (others => '0');
    output_addr_4  : out std_logic_vector(14 downto 0) := (others => '0');
    -- (7:4) for OB_2, (3:0) for OB_1.
    -- X"0" = Phase, X"1" = Mag, X"2" = Raw_a, X"3" = Raw_b.
    output_select  : in  std_logic_vector(15 downto 0) := X"2301";

    -- extra channel for outputting whatever I like.
    --debug_data  : out std_logic_vector(15 downto 0);
    --debug_addr  : out std_logic_vector(14 downto 0);
    --debug_valid : out std_logic;
    frames_per_output_frame : in std_logic_vector(15 downto 0);
    sine                    : in std_logic_vector(15 downto 0);
    cosine                  : in std_logic_vector(15 downto 0);
    pixel_scale             : in std_logic_vector(3 downto 0);
    dc_offset               : in std_logic_vector(15 downto 0);
    saturation_level        : in std_logic_vector(15 downto 0);
    phase_correction        : in std_logic_vector(15 downto 0)
    );

end ranger_process;

architecture rtl of ranger_process is
  
  constant W            : integer                           := ACC_WIDTH;
  constant logN_ZEROS   : std_logic_vector(logN-1 downto 0) := (others => '0');
  signal   CORDIC_WIDTH : integer                           := 16;

  signal sat1              : std_logic                      := '0';
  signal sat2              : std_logic                      := '0';
  signal pixel_diff        : std_logic_vector(15 downto 0)  := (others => '0');
  signal pixel_real        : std_logic_vector(30 downto 0)  := (others => '0');
  signal pixel_imag        : std_logic_vector(30 downto 0)  := (others => '0');
  signal pixel_real_scaled : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_imag_scaled : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_real_acc    : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_imag_acc    : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_real_old    : std_logic_vector(W-1 downto 0) := (others => '0');
  signal pixel_imag_old    : std_logic_vector(W-1 downto 0) := (others => '0');

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
  signal atan_phase       : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_mag         : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_mag_log     : std_logic_vector(15 downto 0) := (others => '0');
  signal atan_valid       : std_logic                     := '0';
  signal atan_addr        : std_logic_vector(14 downto 0) := (others => '0');
  signal atan_nd          : std_logic                     := '0';

  signal offset_result : std_logic_vector(15 downto 0) := (others => '0');


  -- These signals are concatenations of (valid & addr & data)
  signal output_1 : std_logic_vector(31 downto 0) := (others => '0');
  signal output_2 : std_logic_vector(31 downto 0) := (others => '0');
  signal output_3 : std_logic_vector(31 downto 0) := (others => '0');
  signal output_4 : std_logic_vector(31 downto 0) := (others => '0');

  signal phase_valid : std_logic                     := '0';
  signal phase_out   : std_logic_vector(15 downto 0) := (others => '0');
  signal mag_out     : std_logic_vector(15 downto 0) := (others => '0');
  signal phase_addr  : std_logic_vector(14 downto 0) := (others => '0');
  signal raw_valid   : std_logic                     := '0';
  signal raw_a       : std_logic_vector(15 downto 0) := (others => '0');
  signal raw_b       : std_logic_vector(15 downto 0) := (others => '0');
  signal raw_addr    : std_logic_vector(14 downto 0) := (others => '0');
  
  signal subtract_valid : std_logic := '0';
  signal subtract_data : std_logic_vector(15 downto 0) := (others => '0');
  signal subtract_addr : std_logic_vector(14 downto 0) := (others => '0');
  
  
begin  -- rtl    
  
  MULT_REAL : entity work.signedmultXxY
    generic map (X => 16,
                 Y => 16)
    port map (
      clk => clk,
      a   => cosine,
      b   => pixel_diff,
      q   => pixel_real);

  MULT_IMAG : entity work.signedmultXxY
    generic map (X => 16,
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
      nd          => atan_nd,
      rdy         => atan_valid,
      storage_in  => atan_storage_in,
      storage_out => atan_storage_out);   

  atan_nd <= valid_3 when frame_index = (frames_per_output_frame-1) else '0';

  RAM_ACC_REAL : entity work.dualram160x128xN
    generic map (N         => W,
                 SMALL_RAM => SMALL_RAM)
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
    generic map (N         => W,
                 SMALL_RAM => SMALL_RAM)
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
  pixel_real_scaled(W-logN downto 0)     <= pixel_real(30 downto 30-W+logN);
  pixel_imag_scaled(W-1 downto W-logN+1) <= (others => pixel_imag(30));
  pixel_imag_scaled(W-logN downto 0)     <= pixel_imag(30 downto 30-W+logN);

  atan_storage_in <= '0' & pixel_addr_3;
  atan_addr       <= atan_storage_out(14 downto 0);

  GEN_BIG : if ACC_WIDTH >= 16 generate
    atan_real <= pixel_real_acc(W-1 downto W-16);
    atan_imag <= pixel_imag_acc(W-1 downto W-16);
  end generate;

  GEN_SMALL : if ACC_WIDTH < 16 generate
    atan_real(15 downto 16-W) <= pixel_real_acc;
    atan_real(15-W downto 0)  <= (others => '0');
    atan_imag(15 downto 16-W) <= pixel_imag_acc;
    atan_imag(15-W downto 0)  <= (others => '0');
  end generate;


  EVERYTHING : process (clk, reset_n)
    variable subResult : std_logic_vector(15 downto 0) := (others => '0');
    variable diff      : std_logic_vector(15 downto 0) := (others => '0');
    --variable sat : std_logic := '0';
  begin  -- process EVERYTHING
    if reset_n = '0' then               -- asynchronous reset (active low)
      sat1           <= '0';
      sat2           <= '0';
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

      --debug_data     <= (others => '0');
      --debug_valid    <= '0';
      --debug_addr     <= (others => '0');
      offset_result  <= (others => '0');
      -- Old Way


      raw_valid   <= '0';
      raw_a       <= (others => '0');
      raw_b       <= (others => '0');
      raw_addr    <= (others => '0');
      phase_out   <= (others => '0');
      mag_out     <= (others => '0');
      phase_valid <= '0';
      phase_addr  <= (others => '0');
      
      subtract_valid <= '0';
      subtract_data <= (others => '0');
      subtract_addr <= (others => '0');
      
    elsif rising_edge(clk) then         -- rising clock edge
      -- clk cycle 0
      raw_valid <= pixel_valid;
      raw_a     <= pixel_a;
      raw_b     <= pixel_b;
      raw_addr  <= pixel_addr;


      --if pixel_a < saturation_level or pixel_b < saturation_level then
      --        sat1 <= '1';
      --else
      --        sat1 <= '0';
      --end if;
      subResult     := pixel_a - pixel_b;
      --if dc_offset(15) = '1' then
      offset_result <= subResult + dc_offset;
      --else
      --offset_result <= subResult + ('0' & dc_offset);
      --end if;
      valid_0       <= pixel_valid;
      pixel_addr_0  <= pixel_addr;

      -- clk cycle 1
      diff         := shl(offset_result, pixel_scale);
      pixel_diff   <= diff;
      valid_1      <= valid_0;
      pixel_addr_1 <= pixel_addr_0;
      sat2         <= sat1;
      
      subtract_valid <= valid_0;
      subtract_addr <= pixel_addr_0;
      subtract_data <= offset_result;

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
	 

      -- clk cycle 4

      -- clk cycle XXX (after atan)
      phase_addr  <= atan_addr;
      phase_valid <= atan_valid;
      phase_out   <= atan_phase+phase_correction;
      mag_out     <= atan_mag_log;
      
    end if;
  end process EVERYTHING;

  LOG_CALC : entity work.simple_logarithm
    port map (
      linear_in => atan_mag,
      log_out   => atan_mag_log);


  -- Set outputs
  with output_select(3 downto 0) select
    output_1 <=
    raw_valid & raw_addr & raw_a         when X"2",
    raw_valid & raw_addr & raw_b         when X"3",
    phase_valid & phase_addr & phase_out when X"0",
    phase_valid & phase_addr & mag_out when X"1",
    subtract_valid & subtract_addr & subtract_data when X"4",
    (others => '0')                      when others;
  with output_select(7 downto 4) select
    output_2 <=
    raw_valid & raw_addr & raw_a         when X"2",
    raw_valid & raw_addr & raw_b         when X"3",
    phase_valid & phase_addr & phase_out when X"0",
    phase_valid & phase_addr & mag_out when X"1",
    subtract_valid & subtract_addr & subtract_data when X"4",
    (others => '0')                      when others;
  with output_select(11 downto 8) select
    output_3 <=
    raw_valid & raw_addr & raw_a         when X"2",
    raw_valid & raw_addr & raw_b         when X"3",
    phase_valid & phase_addr & phase_out when X"0",
    phase_valid & phase_addr & mag_out when X"1",
    subtract_valid & subtract_addr & subtract_data when X"4",
    (others => '0')                      when others;
  with output_select(15 downto 12) select
    output_4 <=
    raw_valid & raw_addr & raw_a         when X"2",
    raw_valid & raw_addr & raw_b         when X"3",
    phase_valid & phase_addr & phase_out when X"0",
    phase_valid & phase_addr & mag_out when X"1",
    subtract_valid & subtract_addr & subtract_data when X"4",
    (others => '0')                      when others;
  output_valid_1 <= output_1(31);
  output_addr_1  <= output_1(30 downto 16);
  output_data_1  <= output_1(15 downto 0);
  output_valid_2 <= output_2(31);
  output_addr_2  <= output_2(30 downto 16);
  output_data_2  <= output_2(15 downto 0);
  output_valid_3 <= output_3(31);
  output_addr_3  <= output_3(30 downto 16);
  output_data_3  <= output_3(15 downto 0);
  output_valid_4 <= output_4(31);
  output_addr_4  <= output_4(30 downto 16);
  output_data_4  <= output_4(15 downto 0);
  

end rtl;
