----------------------------------------------------------------------------------
-- Company: Universidad Complutense de Madrid
-- Engineer: Pikey Team
-- 
-- Design Name: divisor 
-- Module Name:    divisor - divisor_arch 
-- Project Name: Jetpack
-- Target Devices: 
-- Description: Creaci—n de un reloj de 12'5 MHz a partir de uno de 100 MHz, dividiendo por 8 (1 ciclo cada 80 ns).
--				Ojo, se cuenta de 0 a 3, se cambia el flaco de subida a bajada (o viceversa),
--				se vuelve a contar de 0 a 3 y se vuelve a cambiar, luego un ciclo es como de 0 a 7.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.ALL;

entity divisor is
    port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        clk_salida: out STD_LOGIC -- reloj que se utiliza en los process del programa principal
    );
end divisor;

architecture divisor_arch of divisor is
 SIGNAL cuenta: std_logic_vector(3 downto 0);
 SIGNAL clk_aux, clk: std_logic;
  
  begin

clk <= clk_entrada; 
clk_salida <= clk_aux;
  contador:
  PROCESS(reset, clk)
  BEGIN
    IF (reset = '1') THEN
      cuenta <= (OTHERS=>'0');
    ELSIF(clk'EVENT AND clk = '1') THEN
      IF (cuenta="0011") THEN 
			clk_aux <= not clk_aux;
        cuenta <= (OTHERS=>'0');
      ELSE
        cuenta <= cuenta + '1';
      END IF;
    END IF;
  END PROCESS contador;

end divisor_arch;
