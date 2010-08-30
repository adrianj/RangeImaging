-- Arctangent and magnitude calculator using CORDIC
-- Inputs and outputs all N bit fixed point
-- Performs I iterations - latency of I+2 clock cycles  
-- I should not be greater than N+2                     
-- Modifying generic N greater than 16 isn't exactly correct,
-- ie, angle_lut is fixed at 16 bit.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cordic_atan is
  generic (
    N : integer := 16;                  -- bit width
    I : integer := 14);                 -- iterations
  port (
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    real_in     : in  std_logic_vector(N-1 downto 0);
    imag_in     : in  std_logic_vector(N-1 downto 0);
    phase_out   : out std_logic_vector(N-1 downto 0);
    mag_out     : out std_logic_vector(N-1 downto 0);
    nd          : in  std_logic;
    rdy         : out std_logic;
    storage_in  : in  std_logic_vector(15 downto 0);
    storage_out : out std_logic_vector(15 downto 0));

end cordic_atan;

architecture rtl of cordic_atan is


  constant ONES  : std_logic_vector(I downto 0)  := (others => '1');
  constant ZEROS : std_logic_vector(I downto 0)  := (others => '0');
  constant A     : std_logic_vector(15 downto 0) := X"9B74";  -- 0.607252935 * 2^16

  type   REG_FILE is array (I downto 0) of std_logic_vector(N+1 downto 0);
  -- Intermediate values need extra 2 bits of space.
  signal x : REG_FILE := (others => (others => '0'));
  signal y : REG_FILE := (others => (others => '0'));

  type   ANGLE_ARRAY is array (natural range <>) of std_logic_vector(15 downto 0);
  signal z : ANGLE_ARRAY(I downto 0)      := (others => (others => '0'));
  signal d : std_logic_vector(I downto 0) := (others => '0');
  signal angle_lut : ANGLE_ARRAY(5 downto 0) := (0 => X"2000",
                                                 1 => X"12e4",
                                                 2 => X"09fb",
                                                 3 => X"0511",
                                                 4 => X"028b",
                                                 5 => X"0146");
  signal ready : std_logic_vector(I downto 0) := (others => '0');

  signal storage_sreg : ANGLE_ARRAY(I downto 0) := (others => (others => '0'));

begin  -- rtl

  -- Preliminary rotation for negative real values
  PRE_SCALE : process (clk, reset_n) 
  	variable temp : std_logic_vector(N-1 downto 0) := (others => '0');
  begin  -- process PRE_SCALE
    if reset_n = '0' then               -- asynchronous reset (active low)
      x(0) <= (others => '0');
      y(0) <= (others => '0');
      z(0) <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if real_in(N-1) = '1' then        -- x < 0
        x(0)               <= "00" & (0 - real_in);	
		temp := 0 - imag_in;
		y(0) <= temp(N-1) & temp(N-1) & temp;
        --y(0)               <= (not imag_in(N-1)) & (not imag_in(N-1)) & (0 - imag_in);
        z(0)(N-1)          <= '1';
        z(0)(N-2 downto 0) <= (others => '0');
      else
        x(0) <= "00" & real_in;
        y(0) <= imag_in(N-1) & imag_in(N-1) & imag_in;
        z(0) <= (others => '0');
      end if;
    end if;
  end process PRE_SCALE;

  ROTATE_GEN : for K in 1 to I generate
    

    DO_ROTATION : process (clk, reset_n)
    begin  -- process DO_ROTATION
      if reset_n = '0' then             -- asynchronous reset (active low)
        x(K) <= (others => '0');
        y(K) <= (others => '0');
        z(K) <= (others => '0');
      elsif rising_edge(clk) then       -- rising clock edge
        if y(K-1)(N+1) = '1' then
          d(K-1) <= '1';
          x(K)   <= x(K-1) - (ONES(K-1 downto 0) & y(K-1)(N downto K-1));
          if x(K-1)(N+1) = '1' then
            y(K) <= y(K-1) + (ONES(K-1 downto 0) & x(K-1)(N downto K-1));
          else
            y(K) <= y(K-1) + (ZEROS(K-1 downto 0) & x(K-1)(N downto K-1));
          end if;

          if K < 7 then
            z(K) <= z(K-1) - angle_lut(K-1);
          else
            z(K) <= z(K-1) - (ZEROS(K-7 downto 0) & angle_lut(5)(N-1 downto K-6));
          end if;

          
        else

          
          d(K-1) <= '0';
          x(K)   <= x(K-1) + (ZEROS(K-1 downto 0) & y(K-1)(N downto K-1));
          if x(K-1)(N+1) = '1' then
            y(K) <= y(K-1) - (ONES(K-1 downto 0) & x(K-1)(N downto K-1));
          else
            y(K) <= y(K-1) - (ZEROS(K-1 downto 0) & x(K-1)(N downto K-1));
          end if;
          if K < 7 then
            z(K) <= z(K-1) + angle_lut(K-1);
          else
            z(K) <= z(K-1) + (ZEROS(K-7 downto 0) & angle_lut(5)(N-1 downto K-6));
          end if;
          
        end if;
      end if;
      
    end process DO_ROTATION;
    
  end generate ROTATE_GEN;

  -- Multiply magnitude by A to get correct magnitude.    
  -- Also produces rdy output
  SCALE_OUTPUT : process (clk, reset_n)
    variable mag_int : std_logic_vector(17+N downto 0) := (others => '0');
  begin  -- process SCALE_OUTPUT
    if reset_n = '0' then               -- asynchronous reset (active low)
      phase_out <= (others => '0');
      mag_out   <= (others => '0');
      rdy       <= '0';
      ready     <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      mag_int   := x(I) * A;
      mag_out   <= mag_int(15+N downto 16);
      phase_out <= z(I)(15 downto 16-N);
      ready     <= ready(I-1 downto 0) & nd;
      rdy       <= ready(I);
    end if;
  end process SCALE_OUTPUT;

  -- Transfer random user data to appear at the other end,
  -- eg, pixel_addr, shift information.
  SHIFT_STORAGE : process (clk, reset_n)
  begin  -- process SHIFT_STORAGE
    if reset_n = '0' then               -- asynchronous reset (active low)
      storage_sreg <= (others => (others => '0'));
      storage_out  <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      storage_sreg <= storage_sreg(I-1 downto 0) & storage_in;
      storage_out  <= storage_sreg(I);
    end if;
  end process SHIFT_STORAGE;

end rtl;
