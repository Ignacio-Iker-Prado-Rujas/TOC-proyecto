----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:26:00 03/06/2014 
-- Design Name: 
-- Module Name:    gestorCambioNivel - Behavioral 
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

--Bloque los obstáculos la primera vez que se muestran cada nivel

entity gestorCambioNivel is
	port( reset: in std_logic;
			cambio_nivel: in std_logic;
			counter: in std_logic_vector(9 downto 0);
			clk : in std_logic;
			salida_obstaculo: out std_logic);
end gestorCambioNivel;

architecture Behavioral of gestorCambioNivel is
	type	estados is (bloqueaObstaculos, permiteObstaculos);
	signal	contadorLimite: std_logic_vector(6 downto 0);
	signal	next_estado, estado: estados;
	signal reinicio: std_logic;
begin
reloj:	process (clk, reset, next_estado)
	begin
	reinicio <= '0';
	if reset = '1' then
		estado <= bloqueaObstaculos;
		reinicio <= '1';
	elsif clk' event and clk = '1' then
		estado <= next_estado;
	end if;
end process;
combinational:	process(cambio_nivel, estado, counter, reinicio)
	begin
		if reinicio = '1' then
			next_estado <= bloqueaObstaculos;
		elsif counter = "1100000000" and estado = bloqueaObstaculos then
			next_estado <= permiteObstaculos;
		elsif estado = permiteObstaculos and cambio_nivel = '1' then
			next_estado <= bloqueaObstaculos;
		else 
			next_estado <= estado;
		end if;
end process;

gestorSalida: process(estado)
begin
	if estado = bloqueaObstaculos then
		salida_obstaculo <= '1';
	else
		salida_obstaculo <= '0';
	end if;
end process;

end Behavioral;

