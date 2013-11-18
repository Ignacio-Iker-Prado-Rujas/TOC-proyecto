--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado

-------- Puertos -------------------------------------------
-- Entradas ----------------------------------------------
--    Clk  :  senal de reloj
--    Addr :  direccion de la memoria
-- Salidas  ----------------------------------------------
--    Dout :  dato de 8 bits de la direccion Addr (un ciclo despues)


library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.PACMAN_PKG.ALL;


entity ROM_pacman16b16 is
  port (
    clk  : in  std_logic;  
    addr : in  std_logic_vector(c_nb_pxlcuad-1 downto 0);
    dout : out std_logic_vector(c_pxlscuad-1 downto 0) 
  );
end ROM_pacman16b16;

architecture BEHAVIORAL of ROM_pacman16b16 is
  type memostruct is array (natural range<>) of
                     std_logic_vector(c_pxlscuad-1 downto 0);

  constant img : memostruct := (
   -- FEDCBA9876543210
     "0000000111100000",-- 0
     "0000011111111000",-- 1
     "0000111111111100",-- 2
     "0001111011111110",-- 3
     "0011111111111100",-- 4
     "0011111111110000",-- 5
     "0111111110000000",-- 6
     "0111111000000000",-- 7
     "0111111000000000",-- 8
     "0111111110000000",-- 9
     "0011111111110000",-- A
     "0011111111111100",-- B
     "0001111111111110",-- C
     "0000111111111100",-- D
     "0000011111111000",-- E
     "0000000111100000" -- F
    );

begin

  P_ROM: process (clk)
  begin
    if clk'event and clk='1' then
      dout <= img(to_integer(unsigned(addr)));
    end if;
  end process;

end BEHAVIORAL;

