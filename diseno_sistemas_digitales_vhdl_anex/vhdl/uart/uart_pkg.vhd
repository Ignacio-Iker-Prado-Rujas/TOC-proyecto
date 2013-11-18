--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
-- 
-- Paquete de constantes de la UART

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- las funciones tienen que estar en otro paquete para poder usarlo con modelsim
library WORK;
use WORK.UART_PKG_FUN.all;


package UART_PKG is

  ------------------ declaracion de constantes ------------------

  -- c_on: indica el tipo de logica de los pulsadores, interruptores y LEDS
  -- si es '1' indica que es logica directa -> PLACA NEXYS2
  -- si es '0' indica que es logica directa -> PLACA XUPV2P
  constant c_on        : std_logic := '0'; -- XUPV2P
  constant c_off       : std_logic := not c_on; 
  
  -- c_freq_clk: indica la frecuencia a la que funciona el reloj de la placa
  -- para la Nexys2 el reloj va a  50MHz -> 5*10**7;
  -- para la XUPV2P el reloj va a 100MHz -> 10**8;  
  constant c_freq_clk  : natural   := 10**8; -- XUPV2P

  -- el periodo del reloj en ns (pero de tipo natural)
  -- luego lo tendremos que multiplicar por un nanosegundo
  constant c_period_ns_clk : natural := 10**9/c_freq_clk;
  
  -- c_baud: indica los baudios a los que transmite la UART, algunos valores
  -- tipicos son 9600, 19200, 57600, 115200, ...
  -- Este valor depende
  constant c_baud                : natural   := 115200;
  -- el tiempo que transcurre para la transmision de cada bit de la UART 
  constant c_period_ns_baud      : natural   := 10**9/c_baud;

  constant c_fin_cont_baud  : natural := div_redondea (c_freq_clk, c_baud) - 1;
  
  -- el numero de bits (menos 1) necesarios para representar c_fin_cont_baud
  constant c_nb_cont_baud : natural := log2i(c_fin_cont_baud);

end UART_PKG;

