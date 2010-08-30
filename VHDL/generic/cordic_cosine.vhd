-- Sine and Cosine generator using CORDIC.
-- Given an unsigned input phase of 16-bits (0 to 2*pi)
-- Calculates sin(phase) and cos(phase).
-- I iterations, latency of I + 2 clock cycles.
-- Output is signed with selectable bit width

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cordic_cosine is
  generic (                             -- bit width
    I : integer := 6);                  -- iterations
  port (
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    phase_in    : in  std_logic_vector(15 downto 0);
    sin_out     : out std_logic_vector(15 downto 0);
    cos_out     : out std_logic_vector(15 downto 0);
    nd          : in  std_logic;
    rdy         : out std_logic;
    storage_in  : in  std_logic_vector(15 downto 0);
    storage_out : out std_logic_vector(15 downto 0));

end cordic_cosine;

architecture rtl of cordic_cosine is


  constant ONES  : std_logic_vector(I downto 0)  := (others => '1');
  constant ZEROS : std_logic_vector(I downto 0)  := (others => '0');
  constant A     : std_logic_vector(17 downto 0) := "00" & X"9B72";  -- 1/0.607252935 * 2^14  
  constant AN    : std_logic_vector(17 downto 0) := "11" & X"648D";  -- -0.607

  type REG_FILE is array (I downto 0) of std_logic_vector(17 downto 0);

  signal x : REG_FILE := (others => (others => '0'));
  signal y : REG_FILE := (others => (others => '0'));

  type   ANGLE_ARRAY is array (natural range <>) of std_logic_vector(15 downto 0);
  signal z     : ANGLE_ARRAY(I downto 0) := (others => (others => '0'));
  signal phase : ANGLE_ARRAY(I downto 0) := (others => (others => '0'));

  signal d : std_logic_vector(I downto 0) := (others => '0');
  signal angle_lut : ANGLE_ARRAY(5 downto 0) := (0 => X"2000",
                                                 1 => X"12e4",
                                                 2 => X"09fb",
                                                 3 => X"0511",
                                                 4 => X"028b",
                                                 5 => X"0146");
  signal ready : std_logic_vector(I downto 0) := (others => '0');

  signal storage_sreg : ANGLE_ARRAY(I downto 0) := (others => (others => '0'));
  
  --signal sin_int : std_logic_vector(26 downto 0) := (others => '0');
  --signal cos_int : std_logic_vector(26 downto 0) := (others => '0');

begin  -- rtl

  -- Preliminary rotation
  PRE_SCALE : process (clk, reset_n)
  begin  -- process PRE_SCALE
    if reset_n = '0' then               -- asynchronous reset (active low)
      x(0) <= (others => '0');
      y(0) <= (others => '0');
      z(0) <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge

      -- phase = 0 -> pi/2
      if phase_in(15 downto 14) = "00" then	 
	  	x(0) <= A;
         y(0) <= (others => '0');
        z(0) <= (others => '0');

        -- phase = pi/2 -> pi
      elsif phase_in(15 downto 14) = "01" then
        x(0) <= (others => '0');			 
		y(0) <= AN;
        z(0) <= (14     => '1', others => '0');

        -- phase = pi -> 3*pi/2
      elsif phase_in(15 downto 14) = "10" then
        x(0) <= AN;
        y(0) <= (others => '0');
        z(0) <= (15     => '1', others => '0');

        -- phase = 3*pi/2 -> 2*pi
      else
        x(0) <= (others => '0');					   
		y(0) <= A;
        z(0) <= (15     => '1', 14 => '1', others => '0');
      end if;

    end if;
  end process PRE_SCALE;

  HOLD_INPUT_PHASE : process (clk, reset_n)
  begin  -- process HOLD_INPUT_PHASE
    if reset_n = '0' then               -- asynchronous reset (active low)
      phase <= (others => (others => '0'));
    elsif rising_edge(clk) then         -- rising clock edge
      phase <= phase(I-1 downto 0) & phase_in;
    end if;
  end process HOLD_INPUT_PHASE;

  ROTATE_GEN : for K in 1 to I generate
    

    DO_ROTATION : process (clk, reset_n)	
		variable diff : std_logic_vector(15 downto 0) := (others => '0');
    begin  -- process DO_ROTATION
      if reset_n = '0' then             -- asynchronous reset (active low)
        x(K) <= (others => '0');
        y(K) <= (others => '0');
        z(K) <= (others => '0');
      elsif rising_edge(clk) then       -- rising clock edge	 
	  
	  	diff := z(K-1) - phase(K-1);

        -- if z > phase
        if diff(15) = '1' then
          d(K-1) <= '1';

          if y(K-1)(17) = '1' then
            x(K) <= x(K-1) + (ONES(K-1 downto 0) & y(K-1)(16 downto K-1));
          else
            x(K) <= x(K-1) + (ZEROS(K-1 downto 0) & y(K-1)(16 downto K-1));
          end if;

          if x(K-1)(17) = '1' then
            y(K) <= y(K-1) - (ONES(K-1 downto 0) & x(K-1)(16 downto K-1));
          else
            y(K) <= y(K-1) - (ZEROS(K-1 downto 0) & x(K-1)(16 downto K-1));
          end if;

          if K < 7 then
            z(K) <= z(K-1) + angle_lut(K-1);
          else
            z(K) <= z(K-1) + (ZEROS(K-7 downto 0) & angle_lut(5)(15 downto K-6));
          end if;

          
        else

          
          d(K-1) <= '0';

          if y(K-1)(17) = '1' then
            x(K) <= x(K-1) - (ONES(K-1 downto 0) & y(K-1)(16 downto K-1));
          else
            x(K) <= x(K-1) - (ZEROS(K-1 downto 0) & y(K-1)(16 downto K-1));
          end if;
          
          if x(K-1)(17) = '1' then
            y(K) <= y(K-1) + (ONES(K-1 downto 0) & x(K-1)(16 downto K-1));
          else
            y(K) <= y(K-1) + (ZEROS(K-1 downto 0) & x(K-1)(16 downto K-1));
          end if;
          if K < 7 then
            z(K) <= z(K-1) - angle_lut(K-1);
          else
            z(K) <= z(K-1) - (ZEROS(K-7 downto 0) & angle_lut(5)(15 downto K-6));
          end if;
          
        end if;
      end if;
      
    end process DO_ROTATION;
    
  end generate ROTATE_GEN;

  SET_OUTPUTS: process (clk, reset_n) 
  	variable mult_x : std_logic_vector(25 downto 0) := (others => '0');	
	variable mult_y : std_logic_vector(25 downto 0) := (others => '0');
  begin  -- process SET_OUTPUTS
    if reset_n = '0' then               -- asynchronous reset (active low)
      rdy <= '0';
      ready <= (others => '0');
      sin_out <= (others => '0');
      cos_out <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      ready <= ready(I-1 downto 0) & nd;
      rdy <= ready(I); 
	  --mult_y := y(I) * A;
      --sin_out <= mult_y(23 downto 16); 
	  --mult_x := x(I) * A;		   
	  if x(I)(17) = '1' and x(I)(16) = '0' then
      	cos_out <= 0 - x(I)(16 downto 1);
	  else
	  	cos_out <= x(I)(16 downto 1);
	  end if;
	   if y(I)(17) = '1' and y(I)(16) = '0' then
      	sin_out <= y(I)(16 downto 1);
	  else
	  	sin_out <= 0 - y(I)(16 downto 1);
	  end if;
	  
    end if;
  end process SET_OUTPUTS; 
  
--  SIN_MULTIPLIER : entity work.signedmult8x17
--  	port map (
--		clk => clk,
--		a => y(I)(8 downto 1),
--		b => A,
--		q => sin_int);	
--		
--  COS_MULTIPLIER : entity work.signedmult8x17
--  	port map (
--		clk => clk,
--		a => x(I)(8 downto 1),
--		b => A,
--		q => cos_int);											

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
