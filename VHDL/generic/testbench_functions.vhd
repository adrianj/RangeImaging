library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


use std.textio.all;

package testbench_functions is

  type lut_array is array(integer range <>) of std_logic_vector(7 downto 0);	
  type lut_array_16 is array(integer range <>) of std_logic_vector(15 downto 0);

  signal cos_lut_5 : lut_array(4 downto 0) := (X"68", X"d8", X"80", X"d8", X"68");
  signal sin_lut_5 : lut_array(4 downto 0) := (X"b5", X"86", X"00", X"7a", X"4b");
  
  signal sin_lut_37 : lut_array(36 downto 0) := (X"F5", X"DF", X"CB", X"B8", X"A7",
                                                 X"99", X"8D", X"85", X"81", X"80", X"82", X"89", X"93", X"9F", X"AF", X"C1", X"D5",
                                                 X"EA", X"00", X"15", X"2A", X"3E", X"50", X"60", X"6C", X"76", X"7D", X"7F", X"7E",
                                                 X"7A", X"72", X"66", X"58", X"47", X"34", X"20", X"0A");         

  signal cos_lut_37 : lut_array(36 downto 0) := (X"7F", X"7B", X"74", X"6A", X"5C",
                                                 X"4C", X"39", X"25", X"10", X"FA", X"E5", X"D0", X"BC", X"AB", X"9C", X"90", X"87",
                                                 X"81", X"80", X"81", X"87", X"90", X"9C", X"AB", X"BC", X"D0", X"E5", X"FA", X"10",
                                                 X"25", X"39", X"4C", X"5C", X"6A", X"74", X"7B", X"7F");

  signal cos_lut_3 : lut_array_16(0 to 2) := (X"7FFF", X"C000", X"C000");
  signal sin_lut_3 : lut_array_16(0 to 2) := (X"0000", X"6ED9", X"9126");   
  signal cos_lut_4 : lut_array_16(0 to 3) := (X"4000", X"0000", X"C000", X"0000");
  signal sin_lut_4 : lut_array_16(0 to 3) := (X"0000", X"4000", X"0000", X"C000");

  procedure niosWrite (
    constant addr      : in  std_logic_vector(15 downto 0);
    constant data      : in  std_logic_vector(31 downto 0);
    signal   clk       : in  std_logic;
    signal   nios_addr : out std_logic_vector(15 downto 0);
    signal   nios_din  : out std_logic_vector(31 downto 0);
    signal   we_n      : out std_logic);

  procedure niosRead (
    constant addr      : in  std_logic_vector(15 downto 0);
    signal   clk       : in  std_logic;
    signal   nios_addr : out std_logic_vector(15 downto 0);
    signal   re_n      : out std_logic);


--  procedure niosWriteLuts (
--    constant fpb       :     integer;
--    signal   clk       : in  std_logic;
--    signal   nios_addr : out std_logic_vector(15 downto 0);
--    signal   nios_din  : out std_logic_vector(31 downto 0);
--    signal   we_n      : out std_logic);


  function hex2slv (
    hex : character)
    return std_logic_vector;

  function slv2char (
    slv : std_logic_vector(3 downto 0))
    return character;

  function slv2string (
    slv : std_logic_vector(31 downto 0))
    return string;

  function slv2string16 (
    slv : std_logic_vector(15 downto 0))
    return string;

  -----------------------------------------------------------------------------
  -- For reading text from a file first need a file variable
  -- eg: file inFile : text is in "filename.txt";
  -----------------------------------------------------------------------------
  function file2slv64 (
    file inFile : text)
    return std_logic_vector;

  function file2slv32 (
    file inFile : text)
    return std_logic_vector;

  function file2slv16 (
    file inFile : text)
    return std_logic_vector;

  function string2complex (
    hexstring : string(17 downto 1))
    return std_logic_vector;

  function string2real (
    hexstring : string(8 downto 1))
    return std_logic_vector;

  -----------------------------------------------------------------------------
  -- For writeFile functions, you need a file variable opened in write_mode
  -- eg: file outFile  : text open write_mode is "filename.txt";
  -----------------------------------------------------------------------------
  procedure writeFile64 (
    signal slv   : in std_logic_vector(63 downto 0);
    file outFile :    text);

  procedure writeFile32 (
    signal slv   : in std_logic_vector(31 downto 0);
    file outFile :    text);

  procedure writeFile16 (
    signal slv   : in std_logic_vector(15 downto 0);
    file outFile :    text);

  function slv2real (
    signal slv : std_logic_vector(31 downto 0))
    return real;

  function string2slv64 (
    hexstring : string(16 downto 1))
    return std_logic_vector;

  function string2slv32 (
    hexstring : string(8 downto 1))
    return std_logic_vector;

  function string2slv16 (
    hexstring : string(4 downto 1))
    return std_logic_vector;

  procedure UART_transmit (
    constant to_send   : in  std_logic_vector(7 downto 0);
    signal   tx        : out std_logic;
    constant baud_time : in  time);


end testbench_functions;

package body testbench_functions is



  -- Reads a line from a text file, and produces a 64-bit slv.
  -- Expect line to have one word of 16 hex characters
  function file2slv64 (
    file inFile : text)
    return std_logic_vector is
    variable inline   : line;
    variable textline : string(16 downto 1);
    variable slv      : std_logic_vector(63 downto 0) := (others => 'X');
  begin  -- file2slv64
    if endfile(inFile) then
      slv := (others => 'X');
    else
      readline(inFile, inline);
      read(inline, textline);
      slv := string2slv64(textline);
    end if;
    return slv;
  end file2slv64;

  -- Reads a line from a text file, and produces a 32-bit slv.
  -- Expect line to have one word of 8 hex characters
  function file2slv32 (
    file inFile : text)
    return std_logic_vector is
    variable inline   : line;
    variable textline : string(8 downto 1);
    variable slv      : std_logic_vector(31 downto 0) := (others => 'X');
  begin  -- file2slv64
    if endfile(inFile) then
      slv := (others => 'X');
    else
      readline(inFile, inline);
      read(inline, textline);
      slv := string2slv32(textline);
    end if;
    return slv;
  end file2slv32;

  function file2slv16 (
    file inFile : text)
    return std_logic_vector is
    variable inline   : line;
    variable textline : string(4 downto 1);
    variable slv      : std_logic_vector(15 downto 0) := (others => 'X');
  begin  -- file2slv16
    if endfile(inFile) then
      slv := (others => 'X');
    else
      readline(inFile, inline);
      read(inline, textline);
      slv := string2slv16(textline);
    end if;
    return slv;
  end file2slv16;

  function slv2real (
    signal slv : std_logic_vector(31 downto 0))
    return real is
    variable exp      : integer := 0;
    variable sign     : std_logic;
    variable sig      : std_logic_vector(22 downto 0);
    variable real_sig : real    := 2.0;
    variable real_int : real    := 0.5;
    variable num_int  : real    := 0.0;
  begin  -- process
    exp  := conv_integer(slv(30 downto 23))-127;
    sign := slv(31);
    sig  := slv(22 downto 0);
    if exp < -126 then
      num_int := 0.0;
    else
      real_sig := 1.0;
      real_int := 0.5;
      for i in 22 downto 0 loop
        if sig(i) = '1' then
          real_sig := real_sig + real_int;
        end if;
        real_int := real_int * 0.5;
      end loop;  -- i
      num_int := real_sig * (2.0 ** exp);
      if sign = '1' then
        num_int := -1.0 * num_int;
      end if;
    end if;
    return num_int;

  end slv2real;

  procedure writeFile32 (
    signal slv   : in std_logic_vector(31 downto 0);
    file outFile :    text) is
    variable word    : string(8 downto 1);
    variable outLine : line;
  begin  -- writeFile32                             
    word := slv2string(slv);
    write(outLine, word);
    writeline(outFile, outLine);

  end writeFile32;

  procedure writeFile16 (
    signal slv   : in std_logic_vector(15 downto 0);
    file outFile :    text) is
    variable word    : string(4 downto 1);
    variable outLine : line;
  begin  -- writeFile16                             
    word := slv2string16(slv);
    write(outLine, word);
    writeline(outFile, outLine);

  end writeFile16;

  procedure writeFile64 (
    signal slv   : in std_logic_vector(63 downto 0);
    file outFile :    text) is
    variable word    : string(8 downto 1);
    variable outLine : line;
  begin  -- writeFile64
    word := slv2string(slv(63 downto 32));
    write(outLine, word);
    word := slv2string(slv(31 downto 0));
    write(outLine, word);
    writeline(outFile, outLine);
  end writeFile64;

  function slv2char (slv : std_logic_vector(3 downto 0)) return character is
    variable letter : character := '0';
  begin
    if slv = "0000" then letter    := '0';
    elsif slv = "0001" then letter := '1';
    elsif slv = "0010" then letter := '2';
    elsif slv = "0011" then letter := '3';
    elsif slv = "0100" then letter := '4';
    elsif slv = "0101" then letter := '5';
    elsif slv = "0110" then letter := '6';
    elsif slv = "0111" then letter := '7';
    elsif slv = "1000" then letter := '8';
    elsif slv = "1001" then letter := '9';
    elsif slv = "1010" then letter := 'A';
    elsif slv = "1011" then letter := 'B';
    elsif slv = "1100" then letter := 'C';
    elsif slv = "1101" then letter := 'D';
    elsif slv = "1110" then letter := 'E';
    else letter                    := 'F';
    end if;
    return letter;
  end slv2char;


  function hex2slv (hex : character) return std_logic_vector is
    variable slv : std_logic_vector(3 downto 0);
  begin
    if hex = '0' then slv                 := "0000";
    elsif hex = '1' then slv              := "0001";
    elsif hex = '2' then slv              := "0010";
    elsif hex = '3' then slv              := "0011";
    elsif hex = '4' then slv              := "0100";
    elsif hex = '5' then slv              := "0101";
    elsif hex = '6' then slv              := "0110";
    elsif hex = '7' then slv              := "0111";
    elsif hex = '8' then slv              := "1000";
    elsif hex = '9' then slv              := "1001";
    elsif hex = 'a' or hex = 'A' then slv := "1010";
    elsif hex = 'b' or hex = 'B' then slv := "1011";
    elsif hex = 'c' or hex = 'C' then slv := "1100";
    elsif hex = 'd' or hex = 'D' then slv := "1101";
    elsif hex = 'e' or hex = 'E' then slv := "1110";
    else slv                              := "1111";
    end if;
    return slv;
  end hex2slv;

  function slv2string16 (slv : std_logic_vector(15 downto 0)) return string is
    variable word : string(4 downto 1);
  begin
    for num in 0 to 3 loop
      word(num+1) := slv2char(slv(num*4+3 downto num*4));
    end loop;
    return word;
  end slv2string16;


  function slv2string (slv : std_logic_vector(31 downto 0)) return string is
    variable word : string(8 downto 1);
  begin
    for num in 0 to 7 loop
      word(num+1) := slv2char(slv(num*4+3 downto num*4));
    end loop;
    return word;
  end slv2string;

  -- input is a 17 character string, 8 chars for real, space, 8 chars for imag.
  function string2complex (hexstring : string(17 downto 1)) return std_logic_vector is
    variable slv : std_logic_vector(63 downto 0);
  begin
    for num in 0 to 7 loop
      slv(num*4+3 downto num*4)     := hex2slv(hexstring(num+1));
      slv(num*4+35 downto num*4+32) := hex2slv(hexstring(num+10));
    end loop;
    return slv;
  end string2complex;

  function string2real (
    hexstring : string(8 downto 1)) return std_logic_vector is
    variable slv : std_logic_vector(31 downto 0);
  begin
    for num in 0 to 7 loop
      slv(num*4+3 downto num*4) := hex2slv(hexstring(num+1));
    end loop;
    return slv;
  end string2real;

  function string2slv64 (
    hexstring : string(16 downto 1))
    return std_logic_vector is
    variable slv : std_logic_vector(63 downto 0) := (others => '0');
  begin  -- string2slv64
    for num in 0 to 15 loop
      slv(num*4+3 downto num*4) := hex2slv(hexstring(num+1));
    end loop;
    return slv;
  end string2slv64;

  function string2slv32 (
    hexstring : string(8 downto 1))
    return std_logic_vector is
    variable slv : std_logic_vector(31 downto 0) := (others => '0');
  begin  -- string2slv64
    for num in 0 to 7 loop
      slv(num*4+3 downto num*4) := hex2slv(hexstring(num+1));
    end loop;
    return slv;
  end string2slv32;

  function string2slv16 (
    hexstring : string(4 downto 1))
    return std_logic_vector is
    variable slv : std_logic_vector(15 downto 0) := (others => '0');
  begin  -- string2slv64
    for num in 0 to 3 loop
      slv(num*4+3 downto num*4) := hex2slv(hexstring(num+1));
    end loop;
    return slv;
  end string2slv16;

  procedure UART_transmit (
    constant to_send   : in  std_logic_vector(7 downto 0);
    signal   tx        : out std_logic;
    constant baud_time : in  time) is
  begin  -- UART_transmit
    tx <= '0';                          -- start bit
    wait for baud_time;
    for i in 0 to 7 loop
      tx <= to_send(i);
      wait for baud_time;
    end loop;
    tx <= '1';                          -- stop bit
    wait for baud_time;
  end UART_transmit;


  -- purpose: Read periph register like the nios
  -- Data will appear on nios_dout immediately after procedure
  procedure niosRead (
    constant addr      : in  std_logic_vector(15 downto 0);
    signal   clk       : in  std_logic;
    signal   nios_addr : out std_logic_vector(15 downto 0);
    signal   re_n      : out std_logic) is
  begin  -- niosReadPeriph
    wait until clk = '1';
    re_n      <= '0';
    nios_addr <= addr;
    wait until clk = '1';
    re_n      <= '1';
    wait until clk = '1';
  end niosRead;

  -- purpose: Write periph register like the nios
  procedure niosWrite (
    constant addr      : in  std_logic_vector(15 downto 0);
    constant data      : in  std_logic_vector(31 downto 0);
    signal   clk       : in  std_logic;
    signal   nios_addr : out std_logic_vector(15 downto 0);
    signal   nios_din  : out std_logic_vector(31 downto 0);
    signal   we_n      : out std_logic) is
  begin  -- niosWritePeriph
    wait until clk = '1';
    we_n      <= '0';
    nios_addr <= addr;
    nios_din  <= data;
    wait until clk = '1';
    we_n      <= '1';
    
  end niosWrite;

--  procedure niosWriteLuts (
--    constant fpb       :     integer;
--    signal   clk       : in  std_logic;
--    signal   nios_addr : out std_logic_vector(15 downto 0);
--    signal   nios_din  : out std_logic_vector(31 downto 0);
--    signal   we_n      : out std_logic) is
--    variable fpb_slv : std_logic_vector(7 downto 0);
--  begin
--    fpb_slv := conv_std_logic_vector(fpb, 8);
--
--    niosWrite(X"000C", X"000000" & fpb_slv, clk, nios_addr, nios_din, we_n);
--    for i in 0 to fpb-1 loop
--      fpb_slv := conv_std_logic_vector(i, 8);
--      if fpb = 5 then
--        niosWrite(X"01" & fpb_slv, X"000000" & cos_lut_5(i), clk, nios_addr, nios_din, we_n);
--        niosWrite(X"02" & fpb_slv, X"000000" & sin_lut_5(i), clk, nios_addr, nios_din, we_n);
--      elsif fpb = 37 then
--        niosWrite(X"01" & fpb_slv, X"000000" & cos_lut_37(i), clk, nios_addr, nios_din, we_n);
--        niosWrite(X"02" & fpb_slv, X"000000" & sin_lut_37(i), clk, nios_addr, nios_din, we_n);
--      end if;
--    end loop;
--    
--  end niosWriteLuts;
  

end testbench_functions;
