--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
-- Paquete general de libro Diseno de sistemas digitales
-- Se llama DCSE porque el origen del libro fueron las practicas de la 
--   asignatura Diseno de Circuitos y Sistemas Electronicos de 4o de Ing.
--   de Telecomunicaciones
-- Contiene constantes relativas a las placas utilizadas y funiones utiles
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package DCSE_PKG is

  -- c_on: indica el tipo de logica de los pulsadores, interruptores y LEDS
  -- si es '1' indica que es logica directa -> PLACA NEXYS2
  -- si es '0' indica que es logica directa -> PLACA XUPV2P
  constant c_on        : std_logic := '0'; -- XUPV2P
  -- constant c_on        : std_logic := '1'; -- NEXYS2
  constant c_off       : std_logic := not c_on; 
  
  -- c_freq_clk: indica la frecuencia a la que funciona el reloj de la placa
  -- para la Nexys2 el reloj va a  50MHz -> 5*10**7;
  -- para la XUPV2P el reloj va a 100MHz -> 10**8;  
  constant c_freq_clk  : natural   := 10**8; -- XUPV2P
  -- constant c_freq_clk  : natural   := 5*10**7; -- NEXYS2

  -- el periodo del reloj en ns (pero de tipo natural)
  -- en las simulaciones lo tendremos que multiplicar por un nanosegundo
  constant c_period_ns_clk : natural := 10**9/c_freq_clk;

  function log2i (valor : positive) return natural;

 ----------------------- funcion: div_redondea---------------------------------
  -- Descripcion: funcion que calcula la division entera con redondeo al numero
  --              entero mas cercano
  function div_redondea (dividendo, divisor: natural) return natural;

 
  function get_msbits (vect_in: std_logic_vector; nbits: natural)
     return std_logic_vector;


end DCSE_PKG;

package body DCSE_PKG is

 --------------------------- log2i ---------------------------------------
 -- Ejemplos de funcionamiento (valor = 6, 7 y 8)
 --  * valor = 6            |  * valor = 7          |  * valor = 8
 --      tmp = 6/2 = 3      |     tmp = 7/2 = 3     |     tmp = 8/2 = 4
 --      log2 = 0           |     log2 = 0          |     log2 = 0
 --    - loop 0: tmp 3 > 0  |   - loop 0: tmp 3>0   |   - loop 0: tmp 4>0
 --      tmp = 3/2 = 1      |     tmp = 3/2 = 1     |     tmp = 4/2 = 2
 --      log2 = 1           |     log2 = 1          |     log2 = 1
 --    - loop 1: tmp 1 > 0  |   - loop 1: tmp 1 > 0 |   - loop 1: tmp 2 > 0
 --      tmp = 1/2 = 0      |     tmp = 1/2 = 0     |     tmp = 2/2 = 1
 --      log2 = 2           |     log2 = 2          |     log2 = 2
 --    - end loop: tmp = 0  |   - end loop: tmp = 0 |   - loop 2: tmp 1 > 0
 --  * return log2 = 2      | * return log2 = 2     |     temp = 1/2 = 0
 --                                                 |     log2 = 3
 --                                                 |   - end loop: tmp = 0
 --                                                 | * return log2 = 3

  function log2i (valor : positive) return natural is
    variable tmp, log2: natural;
  begin
    tmp := valor / 2;  -- division entera, redondea al entero menor
    log2 := 0;
    while (tmp /= 0) loop
      tmp := tmp/2;
      log2 := log2 + 1;
    end loop;
    return log2;
  end function log2i;
  

  function div_redondea (dividendo, divisor: natural)
    return natural is
      variable division : integer;
      variable resto    : integer;
  begin
    division := dividendo/divisor;
    -- rem: calcula el resto de la division entera
    resto    := dividendo rem divisor;
    if (resto > (divisor/2)) then
      division := division + 1;
    end if;
    return (division);
  end;

  -- es como un resize, pero coge los bits mas significativos en vez
  -- de los menos significativos
  -- Ejemplo:
  -- vect_in'length = 8 (vect_in'left = 7) ; nbits = 3
  --                   rango de result: 2 downto 0;
  --     result <= vect_in(7 downto 5);
  --   generico:
  --     result <= vect_in(vect_in'left downto vect_in'left-nbits+1)
  --
  -- En caso de que vect_in'length sea menor, rellenamos la derecha con el
  -- bit mas significativo
  -- aunque esta funcion no tendria mucho sentido
  -- vect_in'length = 4 (vect_in'left = 3) ; nbits = 8
  --     result(7 downto 4) <= vect_in;
  --     result(3 downto 0) <= (others=>vect_in(3));
  --   generico:
  --     result(nbits-1 downto nbits-vect_in'length)<=vect_in;
  --     result(nbits-vect_in'length-1 downto 0) <= 
  --                                (others=>vect_in(vect_in'left));

  function get_msbits (vect_in: std_logic_vector; nbits: natural)
  return std_logic_vector is
    variable result: std_logic_vector(nbits-1 downto 0);
  begin
    if vect_in'length >= nbits then
      result := vect_in (vect_in'left downto vect_in'left-nbits+1);
    else
      -- el vector resultante tiene mas bits, rellenamos con 1 a la derecha
      result(nbits-1 downto nbits-vect_in'length) := vect_in;
      result(nbits-vect_in'length-1 downto 0) := 
                            (others=>vect_in(vect_in'left));
    end if;
    return result;
  end get_msbits;



end DCSE_PKG;
