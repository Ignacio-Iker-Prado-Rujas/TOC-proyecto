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

	signal F: std_logic_vector(10 downto 0); 
	signal rout: std_logic_vector(7 downto 0);
	signal aux: std_logic;
	begin
		rout <= F(8 downto 1);
		aux <= PS2DATA;
process(F, rout)
	begin
	if rout="00101001" then pulsado <= '1';
	else pulsado <= '0';
	end if;

end process;
		
process(PS2CLK, reset, aux, PS2DATA, F)
	begin
	
	if (PS2CLK'event and PS2CLK='1') then
		F <=  aux & F(10 downto 1); 
	end if;
end process;
		
	
end estructural;