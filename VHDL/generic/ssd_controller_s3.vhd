-- Controller for Stratix III Dev. Kit SSDs
-- Cathodes are arranged (8 downto 0) <= minus & dp & g & f & e & d & c & b & a
-- Least significant anode is right most display

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity ssd_controller_s3 is
  
  port (
    clk   : in  std_logic;
    bin   : in  std_logic_vector(15 downto 0);
    dp    : in  std_logic_vector(3 downto 0);
    minus : in  std_logic;
    ssd_a : out std_logic_vector(3 downto 0);
    ssd_c : out std_logic_vector(8 downto 0));

end ssd_controller_s3;

architecture rtl of ssd_controller_s3 is

  signal count : std_logic_vector(27 downto 0) := (others => '0');
  signal count_portion : std_logic_vector(1 downto 0) := (others => '0');
  signal temp  : std_logic_vector(3 downto 0) := (others => '0');
  
begin  -- rtl

  ssd_c(8) <= minus;
  count_portion <= count(19 downto 18);

  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      count <= count + 1;
      if count_portion = "00" then
        ssd_a <= "0001";
        temp  <= bin(3 downto 0);
        ssd_c(7) <= dp(0);
      elsif count_portion = "01" then
        ssd_a <= "0010";
        temp  <= bin(7 downto 4);
        ssd_c(7) <= dp(1);
      elsif count_portion = "10" then
        ssd_a <= "0100";
        temp  <= bin(11 downto 8);
        ssd_c(7) <= dp(2);
      else
        ssd_a <= "1000";
        temp  <= bin(15 downto 12);
        ssd_c(7) <= dp(3);
      end if;
    end if;
  end process;

  with temp select ssd_c(6 downto 0) <=
    "1000000" when "0000",
    "1111001" when "0001",
    "0100100" when "0010",
    "0110000" when "0011",
    "0011001" when "0100",
    "0010010" when "0101",
    "0000010" when "0110",
    "1111000" when "0111",
    "0000000" when "1000",
    "0010000" when "1001",
    "0001000" when "1010",
    "0000011" when "1011",
    "1000110" when "1100",
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when others;

end rtl;

