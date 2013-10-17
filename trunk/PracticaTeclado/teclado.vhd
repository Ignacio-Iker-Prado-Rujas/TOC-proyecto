----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:57:35 10/15/2013 
-- Design Name: 
-- Module Name:    teclado - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity conversor is
port (var: in std_logic_vector (7 downto 0);
		display : out std_logic_vector (6 downto 0));
end conversor;

architecture Behavioral of conversor is
--#Display 7-segmentos 
--#
--#		   S0
--#		   ---
--#	    S5	|	|s1
--#		    S6
--#		   ---
--#	    S4	|	|S2
--#
--#		   ---
--#		   S3
--
--
--#Display 7-segmentos de la placa superior
--
--net display(0) loc=R10;
--net display(1) loc=P10;
--net display(2) loc=M11;
--NET display(3) loc=M6;
--NET display(4) loc=N6;
--NET display(5) loc=T7;
--NET display(6) loc=R7;

begin



process (var)

begin
--var <= rout;
--rdesp: registro port map(PS2CLK, reset, PS2DATA, rout);
--numeros del 0 al 9

--1
if var = "00010110" or var = "01101001"then 
	display(0) <= '0';
	display(1) <= '1';
	display(2) <= '1';
	display(3) <= '0';
	display(4) <= '0';
	display(5) <= '0';
	display(6) <= '0';
	
--	2
elsif var = "00011110" or var = "01110010" then 
	display(0) <= '1';
	display(1) <= '1';
	display(6) <= '1';
	display(4) <= '1';
	display(3) <= '1';
	display(2) <= '0';
	display(5) <= '0';

--	3
elsif var = "00100110" or var = "01111010" then 
	display(0) <= '1';
	display(1) <= '1';
	display(6) <= '1';
	display(2) <= '1';
	display(3) <= '1';
	display(4) <= '0';
	display(5) <= '0';
--	4
elsif var = "00100101" or var = "01101011" then 
	display(0) <= '0';
	display(1) <= '1';
	display(2) <= '1';	
	display(3) <= '0';
	display(4) <= '0';		
	display(5) <= '1';
	display(6) <= '1';

--	5
elsif var = "00101110" or var = "01110011" then 
	display(0) <= '1';
	display(1) <= '0';
	display(2) <= '1';
	display(3) <= '1';
	display(4) <= '0';
	display(5) <= '1';
	display(6) <= '1';

--	6
elsif var = "00110110" or var = "01110100" then 
	display(0) <= '1';
	display(1) <= '0';
	display(2) <= '1';
	display(3) <= '1';
	display(4) <= '1';
	display(5) <= '1';
	display(6) <= '1';

--	7
elsif var = "00111101" or var = "01101100" then 
	display(0) <= '1';
	display(1) <= '1';
	display(2) <= '1';
	display(3) <= '0';
	display(4) <= '0';
	display(5) <= '0';
	display(6) <= '0';

--	8
elsif var = "00111110" or var = "01110101" then 
	display(0) <= '1';
	display(1) <= '1';
	display(2) <= '1';
	display(3) <= '1';
	display(4) <= '1';
	display(5) <= '1';
	display(6) <= '1';
--	9
elsif var = "01000110" or var = "01111101" then 
	display(0) <= '1';
	display(1) <= '1';
	display(2) <= '1';
	display(3) <= '1';
	display(4) <= '0';
	display(5) <= '1';
	display(6) <= '1';
--	0
elsif var = "01110000" or var = "01000101" then 
	display(0) <= '1';
	display(1) <= '1';
	display(2) <= '1';
	display(3) <= '1';
	display(4) <= '1';
	display(5) <= '1';
	display(6) <= '0';
--P
elsif var = "01001101" then
	display <= "1110011";
--U
elsif var = "00111100" then
	display <= "0111110";
--T
elsif var = "00101100" then
	display <= "0110001";
--A
elsif var = "00011100" then
	display <= "1110111";
else 
	display(0) <= '0';
	display(1) <= '0';
	display(2) <= '0';
	display(3) <= '0';
	display(4) <= '0';
	display(5) <= '0';
	display(6) <= '0';
--1
--elsif var = "01101001" then 
--	display(1) <= '1';
--	display(2) <= '1';
----	2
--elsif var = "01110010" then 
--	display(0) <= '1';
--	display(1) <= '1';
--	display(6) <= '1';
--	display(4) <= '1';
--	display(3) <= '1';
--
----	3
--elsif var = "01111010" then 
--	display(0) <= '1';
--	display(1) <= '1';
--	display(6) <= '1';
--	display(2) <= '1';
--	display(3) <= '1';
----	4
--elsif var = "01101011" then 
--	display(5) <= '1';
--	display(1) <= '1';
--	display(6) <= '1';
--	display(2) <= '1';
----	5
--elsif var = "01110011" then 
--	display(0) <= '1';
--	display(5) <= '1';
--	display(6) <= '1';
--	display(2) <= '1';
--	display(3) <= '1';
----	6
--elsif var = "01110100" then 
--	display(0) <= '1';
--	display(5) <= '1';
--	display(6) <= '1';
--	display(2) <= '1';
--	display(4) <= '1';
--	display(3) <= '1';
----	7
--elsif var = "01101100" then 
--	display(0) <= '1';
--	display(1) <= '1';
--	display(2) <= '1';
----	8
--elsif var = "01110101" then 
--	display(0) <= '1';
--	display(1) <= '1';
--	display(2) <= '1';
--	display(3) <= '1';
--	display(4) <= '1';
--	display(5) <= '1';
--	display(6) <= '1';
----	9
--elsif var = "01111101" then 
--	display(0) <= '1';
--	display(1) <= '1';
--	display(2) <= '1';
--	display(3) <= '1';
--	display(5) <= '1';
--	display(6) <= '1';
	end if;
end process;
end Behavioral;

