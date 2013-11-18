------- ROM creada automaticamente por ppm2rom -----------
------- Felipe Machado -----------------------------------
------- Departamento de Tecnologia Electronica -----------
------- Universidad Rey Juan Carlos ----------------------
------- http://gtebim.es ---------------------------------
----------------------------------------------------------
--------Datos de la imagen -------------------------------
--- Fichero original    : pacman10x10.ppm 
--- Filas    : 10 
--- Columnas : 10 
----------------------------------------------------------
--------Codificacion de la memoria------------------------
--- Palabras de 8 bits
--- De cada palabra hay 3 bits para rojo y verde y 2 para azul: "RRRGGGBB" 256 colores



------ Puertos -------------------------------------------
-- Entradas ----------------------------------------------
--    Clk  :  senal de reloj
--    Addr :  direccion de la memoria
-- Salidas  ----------------------------------------------
--    Dout :  dato de 8 bits de la direccion Addr (un ciclo despues)


library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
entity ROM_RGB_8b_pacman10x10 is
  port (
    clk  : in  std_logic;   
    addr : in  std_logic_vector(7-1 downto 0);
    dout : out std_logic_vector(8-1 downto 0) 
  );
end ROM_RGB_8b_pacman10x10;

architecture BEHAVIORAL of ROM_RGB_8b_pacman10x10 is
  type memostruct is array (natural range<>) of std_logic_vector(8-1 downto 0);
  constant filaimg : memostruct := (
 --"RRRGGGBB"
   "00000000", "00000000", "01001000", "10110100", "11111100", "11111100", "11011000",
   "10010000", "00100100", "00000000", "00000000", "10010000", "11111101", "11111101",
   "11111100", "11111100", "11111100", "11111101", "11011001", "01001000", "01001000",
   "11111101", "11111101", "11111100", "11111100", "11111100", "11111101", "11111101",
   "11111110", "11011001", "10111000", "11111101", "11111100", "11111100", "11111100",
   "11111100", "11111101", "11011001", "01101000", "00000000", "11111100", "11111100",
   "11111100", "11111100", "11111100", "11011000", "01101100", "00100100", "00100000",
   "00000000", "11111100", "11111100", "11111100", "11111100", "11111100", "11011000",
   "01101100", "00000000", "00000000", "00000000", "10111000", "11111101", "11111100",
   "11111100", "11111100", "11111100", "11111100", "11111101", "10010000", "00000000",
   "01001000", "11111101", "11111101", "11111100", "11111100", "11111100", "11111100",
   "11111101", "11111101", "11011001", "00000000", "01101100", "11111101", "11111101",
   "11111100", "11111100", "11111101", "11111101", "11011001", "01001000", "00000000",
   "00000000", "01001000", "10110100", "11111100", "11111100", "11111100", "10010000",
   "00100100", "00000000"); 
begin
  P_ROM: process (clk)
  begin
    if clk'event and clk='1' then
      dout <= filaimg(to_integer(unsigned(addr)));
    end if;
  end process;
end BEHAVIORAL;

