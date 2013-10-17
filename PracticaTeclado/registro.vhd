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

entity registro is
	port (PS2CLK, reset, PS2DATA: in std_logic;
		displayout: out std_logic_vector(6 downto 0));
end registro;

architecture estructural of registro is
	--component biestable
	--	port(PS2CLK, reset, c: in std_logic; d: out std_logic);
	--end component biestable;
component conversor is
port (var: in std_logic_vector (7 downto 0);
		display : out std_logic_vector (6 downto 0));
end component;

	signal F: std_logic_vector(10 downto 0); 
	signal rout, invert: std_logic_vector(7 downto 0);
	signal aux: std_logic;
	begin
		rout <= F(9 downto 2);
		aux<=PS2DATA;
		invert(0) <= rout(7);
		invert(1) <= rout(6);
		invert(2) <= rout(5);
		invert(3) <= rout(4);
		invert(4) <= rout(3);		
		invert(5) <= rout(2);
		invert(6) <= rout(1);
		invert(7) <= rout(0);
		
		u: conversor port map(invert, displayout);
		
		process(PS2CLK, reset, aux, PS2DATA, F)
		
		begin
		
		if (PS2CLK'event and PS2CLK='1') then
			F<=  F(9 downto 0) & aux; 
		end if;
		end process;
		
	
		--u_0: biestable port map(PS2CLK, reset, PS2DATA,F(0));
		--gen: for i in 1 to 10 generate
		--	u: biestable port map(PS2CLK, reset, F(i-1),F(i));
		--end generate gen;
		--B <= F;
end estructural;