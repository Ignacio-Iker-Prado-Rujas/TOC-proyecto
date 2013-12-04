----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:51:25 10/15/2013 
-- Design Name: 
-- Module Name:    registro - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control_teclado is
	port (PS2CLK, reset, PS2DATA: in std_logic;
	pulsado: out std_logic);
end control_teclado;

architecture estructural of control_teclado is

	signal F: std_logic_vector(21 downto 0); 
	signal rout, levanta: std_logic_vector(7 downto 0);
	signal aux: std_logic;

begin

		rout <= F(8 downto 1);
		levanta <= F(19 downto 12);
		aux <= PS2DATA;
		
process(PS2CLK, reset, aux, PS2DATA, F)
	begin
	if (PS2CLK'event and PS2CLK='1') then
		F <=  aux & F(21 downto 1); 
	end if;
end process;
 

process(F, rout, levanta)
	begin	
	if rout = "00100011" then 
		if levanta = "11110000" then 
			pulsado <= '0';
		else pulsado <= '1';
		end if;
	else pulsado <= '0';
	end if;

end process;
		

		
	
end estructural;