-- Really simple logarithm.
-- Works for inputs up to 16 bits wide.

-- Inputs treated as unsigned integers.
-- Upper 4 bits of output determined by position of MSB
-- Middle 4 bits based on a 16x8 bit LUT
-- Bottom 4 bits are linear

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity simple_logarithm is
  port (
    linear_in : in  std_logic_vector(15 downto 0);
    log_out   : out std_logic_vector(15 downto 0));

end simple_logarithm;

architecture rtl of simple_logarithm is

  signal MSB_int     : integer                      := 0;
  signal MSB_sig     : std_logic_vector(3 downto 0) := (others => '0');
  signal remd        : std_logic_vector(3 downto 0) := (others => '0');
  signal last4 		: std_logic_vector(3 downto 0) := (others => '0');
  signal lut_address : integer                      := 0;
  type   LUT8 is array (natural range <>) of std_logic_vector(7 downto 0);
  type LUT6 is array (natural range <>) of std_logic_vector(5 downto 0);
  signal linear_shifted : LUT6(15 downto 0) := (others => (others => '0'));
  signal log_lut : LUT8(15 downto 0) := (0  => X"00",
                           1  => X"16",
                           2  => X"2B",
                           3  => X"3F",
                           4  => X"52",
                           5  => X"64",
                           6  => X"75",
                           7  => X"86",
                           8  => X"95",
                           9  => X"A4",
                           10 => X"B3",
                           11 => X"C1",
                           12 => X"CE",
                           13 => X"DB",
                           14 => X"E8",
                           15 => X"F4");

begin  -- rtl

	MAKE_SHIFTED : for i in 6 to 15 generate
		linear_shifted(i) <= linear_in(i-1 downto i-6);
	end generate;
	linear_shifted(5) <= linear_in(4 downto 0) & '0';
	linear_shifted(4) <= linear_in(3 downto 0) & "00";
	linear_shifted(3) <= linear_in(2 downto 0) & "000";
	linear_shifted(2) <= linear_in(1 downto 0) & "0000";
	linear_shifted(1) <= linear_in(0) & "00000";
	linear_shifted(0) <= (others => '0');
	--linear_shifted(3 downto 0) <= (others => (others =>'0'));

  MSB_int <= conv_integer(MSB_sig);
  MSB_sig <= X"F" when linear_in(15) = '1'
             else X"E" when linear_in(14) = '1'
             else X"D" when linear_in(13) = '1'
             else X"C" when linear_in(12) = '1'
             else X"B" when linear_in(11) = '1'
             else X"A" when linear_in(10) = '1'
             else X"9" when linear_in(9) = '1'
             else X"8" when linear_in(8) = '1'
             else X"7" when linear_in(7) = '1'
             else X"6" when linear_in(6) = '1'
             else X"5" when linear_in(5) = '1'
             else X"4" when linear_in(4) = '1'
             else X"3" when linear_in(3) = '1'
             else X"2" when linear_in(2) = '1'
             else X"1" when linear_in(1) = '1'
             else X"0";

--  FIND_REMD_RANGE : process (MSB_int, linear_shifted)
--  begin  -- process FIND_REMD_RANGE	 
--  	if MSB_int = 0 then
--		remd <= linear_shifted(0);
--		else
--		remd <= linear_shifted(MSB_int-1);
--		end if;
--		if MSB_int <= 4	 then
--		last4 <= linear_shifted(0);
--		else
--		last4 <= linear_shifted(MSB_int-5);
--		end if; 
--  end process FIND_REMD_RANGE;		 
--  
--
--  
--  lut_address <= conv_integer(remd);

  log_out(15 downto 12) <= MSB_sig;
  --log_out(11 downto 4)  <= log_lut(lut_address);
  --log_out(3 downto 0) <= last4;
  log_out(11 downto 6) <= linear_shifted(MSB_int);
  log_out(5 downto 0) <= (others => '0');
end rtl;
