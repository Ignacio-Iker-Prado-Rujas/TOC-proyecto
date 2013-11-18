--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
-- Representa una imagen de 16x16 en blanco y negro
-- cada fila esta en una direccion de memoria, por eso solo tiene
-- 16 direcciones de memoria y el ancho de palabra es de 16

------ Puertos -------------------------------------------
-- Entradas ----------------------------------------------
--    Clk  :  senal de reloj
--    Addr :  direccion de la memoria,
-- Salidas  ----------------------------------------------
--    Dout :  dato de 8 bits de la direccion Addr (un ciclo despues)
--            representa a toda una fila de la imagen

library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;


entity ROM16b_16 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(3 downto 0);
    dout : out std_logic_vector(15 downto 0) 
  );
end ROM16b_16;

architecture BEHAVIORAL of ROM16b_16 is
  type memostruct is array (natural range<>) of std_logic_vector(15 downto 0);

  constant img : memostruct := (
   -- FEDCBA9876543210
     "0111111111111110",-- 0
     "1111111111111111",-- 1
     "1111000000001111",-- 2
     "1110000000001111",-- 3
     "1110001111111111",-- 4
     "1110011111111111",-- 5
     "1110011111111111",-- 6
     "1110011111111111",-- 7
     "1110011111111111",-- 8
     "1110011111111111",-- 9
     "1110011111111111",-- A
     "1110001111111111",-- B
     "1110000000001111",-- C
     "1111000000001111",-- D
     "1111111111111111",-- E
     "0111111111111110" -- F
    );

begin

  P_ROM: process (clk)
  begin
    if clk'event and clk='1' then
      dout <= img(to_integer(unsigned(addr)));
    end if;
  end process;

end BEHAVIORAL;

