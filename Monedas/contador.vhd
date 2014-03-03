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
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity contador is
generic (N: integer := 7);
port (var: in std_logic_vector (6 downto 0);
		displayi, displayd : out std_logic_vector (6 downto 0));
end contador;

architecture Behavioral of contador is
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

process(var)

begin
--var <= rout;
--rdesp: registro port map(PS2CLK, reset, PS2DATA, rout);
--numeros del 0 al 9

--1
if var = 1 or var = 11 or var = 21 or var = 31 or var = 41 or var = 51 or var = 61 or var = 71 or var = 81 or var = 91 then 
	displayd(0) <= '0';
	displayd(1) <= '1';
	displayd(2) <= '1';
	displayd(3) <= '0';
	displayd(4) <= '0';
	displayd(5) <= '0';
	displayd(6) <= '0';
	
--	2
elsif var = 2 or var = 12 or var = 22 or var = 32 or var = 42 or var = 52 or var = 62 or var = 72 or var = 82 or var = 92 then 
	displayd(0) <= '1';
	displayd(1) <= '1';
	displayd(6) <= '1';
	displayd(4) <= '1';
	displayd(3) <= '1';
	displayd(2) <= '0';
	displayd(5) <= '0';

--	3
elsif var = 3 or var = 13 or var = 23 or var = 33 or var = 43 or var = 53 or var = 63 or var = 73 or var = 83 or var = 93 then 
	displayd(0) <= '1';
	displayd(1) <= '1';
	displayd(6) <= '1';
	displayd(2) <= '1';
	displayd(3) <= '1';
	displayd(4) <= '0';
	displayd(5) <= '0';
--	4
elsif var = 4 or var = 14 or var = 24 or var = 34 or var = 44 or var = 54 or var = 64 or var = 74 or var = 84 or var = 94 then 
	displayd(0) <= '0';
	displayd(1) <= '1';
	displayd(2) <= '1';	
	displayd(3) <= '0';
	displayd(4) <= '0';		
	displayd(5) <= '1';
	displayd(6) <= '1';

--	5
elsif var = 5 or var = 15 or var = 25 or var = 35 or var = 45 or var = 55 or var = 65 or var = 75 or var = 85 or var = 95 then 
	displayd(0) <= '1';
	displayd(1) <= '0';
	displayd(2) <= '1';
	displayd(3) <= '1';
	displayd(4) <= '0';
	displayd(5) <= '1';
	displayd(6) <= '1';

--	6
elsif var = 6 or var = 16 or var = 26 or var = 36 or var = 46 or var = 56 or var = 66 or var = 76 or var = 86 or var = 96 then 
	displayd(0) <= '1';
	displayd(1) <= '0';
	displayd(2) <= '1';
	displayd(3) <= '1';
	displayd(4) <= '1';
	displayd(5) <= '1';
	displayd(6) <= '1';

--	7
elsif var = 7 or var = 17 or var = 27 or var = 37 or var = 47 or var = 57 or var = 67 or var = 77 or var = 87 or var = 97 then 
	displayd(0) <= '1';
	displayd(1) <= '1';
	displayd(2) <= '1';
	displayd(3) <= '0';
	displayd(4) <= '0';
	displayd(5) <= '0';
	displayd(6) <= '0';

--	8
elsif var = 8 or var = 18 or var = 28 or var = 38 or var = 48 or var = 58 or var = 68 or var = 78 or var = 88 or var = 98 then 
	displayd(0) <= '1';
	displayd(1) <= '1';
	displayd(2) <= '1';
	displayd(3) <= '1';
	displayd(4) <= '1';
	displayd(5) <= '1';
	displayd(6) <= '1';
--	9
elsif var = 9 or var = 19 or var = 29 or var = 39 or var = 49 or var = 59 or var = 69 or var = 79 or var = 89 or var = 99 then 
	displayd(0) <= '1';
	displayd(1) <= '1';
	displayd(2) <= '1';
	displayd(3) <= '1';
	displayd(4) <= '0';
	displayd(5) <= '1';
	displayd(6) <= '1';
--	0
elsif var = 0 or var = 10 or var = 20 or var = 30 or var = 40 or var = 50 or var = 60 or var = 70 or var = 80 or var = 90 then 

	displayd(0) <= '1';
	displayd(1) <= '1';
	displayd(2) <= '1';
	displayd(3) <= '1';
	displayd(4) <= '1';
	displayd(5) <= '1';
	displayd(6) <= '0';

else 
	displayd(0) <= '0';
	displayd(1) <= '0';
	displayd(2) <= '0';
	displayd(3) <= '0';
	displayd(4) <= '0';
	displayd(5) <= '0';
	displayd(6) <= '0';
end if;

--1
if var = 10 or var = 11 or var = 12 or var = 13 or var = 14 or var = 15 or var = 16 or var = 17 or var = 18 or var = 19 then 
	displayi(0) <= '0';
	displayi(1) <= '1';
	displayi(2) <= '1';
	displayi(3) <= '0';
	displayi(4) <= '0';
	displayi(5) <= '0';
	displayi(6) <= '0';
	
--	2
elsif var = 20 or var = 21 or var = 22 or var = 23 or var = 24 or var = 25 or var = 26 or var = 27 or var = 28 or var = 29 then 
	displayi(0) <= '1';
	displayi(1) <= '1';
	displayi(6) <= '1';
	displayi(4) <= '1';
	displayi(3) <= '1';
	displayi(2) <= '0';
	displayi(5) <= '0';

--	3
elsif var = 30 or var = 31 or var = 32 or var = 33 or var = 34 or var = 35 or var = 36 or var = 37 or var = 38 or var = 39 then 
	displayi(0) <= '1';
	displayi(1) <= '1';
	displayi(6) <= '1';
	displayi(2) <= '1';
	displayi(3) <= '1';
	displayi(4) <= '0';
	displayi(5) <= '0';
--	4
elsif var = 40 or var = 41 or var = 42 or var = 43 or var = 44 or var = 45 or var = 46 or var = 47 or var = 48 or var = 49 then 
	displayi(0) <= '0';
	displayi(1) <= '1';
	displayi(2) <= '1';	
	displayi(3) <= '0';
	displayi(4) <= '0';		
	displayi(5) <= '1';
	displayi(6) <= '1';

--	5
elsif var = 50 or var = 51 or var = 52 or var = 53 or var = 54 or var = 55 or var = 56 or var = 57 or var = 58 or var = 59 then 
	displayi(0) <= '1';
	displayi(1) <= '0';
	displayi(2) <= '1';
	displayi(3) <= '1';
	displayi(4) <= '0';
	displayi(5) <= '1';
	displayi(6) <= '1';

--	6
elsif var = 60 or var = 61 or var = 62 or var = 63 or var = 64 or var = 65 or var = 66 or var = 67 or var = 68 or var = 69 then 
	displayi(0) <= '1';
	displayi(1) <= '0';
	displayi(2) <= '1';
	displayi(3) <= '1';
	displayi(4) <= '1';
	displayi(5) <= '1';
	displayi(6) <= '1';

--	7
elsif var = 70 or var = 71 or var = 72 or var = 73 or var = 74 or var = 75 or var = 76 or var = 77 or var = 78 or var = 79 then 
	displayi(0) <= '1';
	displayi(1) <= '1';
	displayi(2) <= '1';
	displayi(3) <= '0';
	displayi(4) <= '0';
	displayi(5) <= '0';
	displayi(6) <= '0';

--	8
elsif var = 80 or var = 81 or var = 82 or var = 83 or var = 84 or var = 85 or var = 86 or var = 87 or var = 88 or var = 89 then 
	displayi(0) <= '1';
	displayi(1) <= '1';
	displayi(2) <= '1';
	displayi(3) <= '1';
	displayi(4) <= '1';
	displayi(5) <= '1';
	displayi(6) <= '1';
--	9
elsif var = 90 or var = 91 or var = 92 or var = 93 or var = 94 or var = 95 or var = 96 or var = 97 or var = 98 or var = 99 then 
	displayi(0) <= '1';
	displayi(1) <= '1';
	displayi(2) <= '1';
	displayi(3) <= '1';
	displayi(4) <= '0';
	displayi(5) <= '1';
	displayi(6) <= '1';
--	0
elsif var = 0 or var = 1 or var = 2 or var = 3 or var = 4 or var = 5 or var = 6 or var = 7 or var = 8 or var = 9 then 

	displayi(0) <= '1';
	displayi(1) <= '1';
	displayi(2) <= '1';
	displayi(3) <= '1';
	displayi(4) <= '1';
	displayi(5) <= '1';
	displayi(6) <= '0';

else 
	displayi(0) <= '0';
	displayi(1) <= '0';
	displayi(2) <= '0';
	displayi(3) <= '0';
	displayi(4) <= '0';
	displayi(5) <= '0';
	displayi(6) <= '0';
end if;

end process;
end Behavioral;

