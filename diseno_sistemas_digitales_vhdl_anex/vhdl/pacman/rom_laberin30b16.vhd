--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--

------ Puertos -------------------------------------------
-- Entradas ----------------------------------------------
--    Clk  :  senal de reloj
--    Addr :  direccion de la memoria
-- Salidas  ----------------------------------------------
--    Dout :  dato de 16 bits de la direccion Addr (un ciclo despues)

-- es el campo de juego (laberinto) del pacman, si cada celda es de 16x16
-- cabe en 640x480
-- El campo es simetrico y solo esta guardada la parte izquierda, que habra
-- que poner la derecha, se ha hecho asi para ahorrar memoria
-- por lo que el campo es de 32 de ancho por 30 de alto
-- 32x16= 512 de ancho < 640
-- 30x16= 480 justo


library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.PACMAN_PKG.ALL;

entity ROM_laberin is
  port (
    clk  : in  std_logic;   
    addra : in  std_logic_vector(c_nb_fila_cuad-1 downto 0);
    addrb : in  std_logic_vector(c_nb_fila_cuad-1 downto 0);
    douta : out std_logic_vector(c_cuadscol/2-1 downto 0);
    doutb : out std_logic_vector(c_cuadscol/2-1 downto 0) 
  );
end ROM_laberin;

architecture BEHAVIORAL of ROM_laberin is
  type memostruct is array (natural range<>) of
                   std_logic_vector(c_cuadscol/2-1 downto 0);

  constant img : memostruct := (
   -- FEDCBA9876543210
     "1111111111111111",-- 0
     "1000000000000001",-- 1
     "1011110111111101",-- 2
     "1011110111111101",-- 3
     "1011110111111101",-- 4
     "1000000000000000",-- 5
     "1011110110111111",-- 6
     "1011110110111111",-- 7
     "1000000110000001",-- 8
     "1111110111111101",-- 9
     "1111110111111101",--10
     "1111110110000000",--11
     "1111110110111100",--12
     "0000000000100000",--13
     "1111110110100000",--14
     "1111110110111111",--15
     "1111110110000000",--16
     "1111110110111111",--17
     "1111110110111111",--18
     "1000000000000001",--19
     "1011110111111101",--20
     "1011110111111101",--21
     "1000110000000000",--22
     "1110110110111111",--23
     "1110110110111111",--24
     "1000000110000001",--25
     "1011111111111101",--26
     "1011111111111101",--27
     "1000000000000000",--28
     "1111111111111111" --29
    );

begin

  P_ROM: process (clk)
  begin
    if clk'event and clk='1' then
      douta <= img(to_integer(unsigned(addra)));
      doutb <= img(to_integer(unsigned(addrb)));
    end if;
  end process;

end BEHAVIORAL;

