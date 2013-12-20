--Seven-Segment LED Display Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity led_decoder is Port (
digit : in STD_LOGIC_VECTOR (3 downto 0);
seg7 : out STD_LOGIC_VECTOR (6 downto 0)); --Send
end led_decoder;

architecture Behavioral of led_decoder is

begin

with digit select

seg7 <=
"1000000" when x"0" , -- low = enable 
"1111001" when x"1" ,  
"0100100" when x"2" ,
"0110000" when x"3" ,
"0011001" when x"4" ,
"0010010" when x"5" ,
"0000010" when x"6" ,
"1111000" when x"7" ,
"0000000" when x"8" ,
"0010000" when x"9" ,
"1000000" when others;

end Behavioral;