--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.DCSE_PKG.ALL;

package VGA_PKG is

--  Orden:
--  1) video activo, 2) porche delantero, 3) sincro 4) porche trasero
--  Empezamos por el visible para que sea mas facil saber en que pixel visible
--  estamos, ya que si no, habria que realizar una resta

--  Por ejemplo para 640x480@60 Hz:
---------- Pixeles (horizontal, columnas) ---------------------------------|
-- |                        |             |                 |              |
-- |      video activo      |   porche    |     sincro      |    porche    |
-- |                        | delantero   |   horizontal    |    trasero   |
-- |                        |             |                 |              |
-- |<--------- 640 -------->|<--- 16 ---->|<------ 96 ----->|<---- 48 ---->|
-- |                        |             |                 |              |
-- |      c_pxl_visible     |c_pxl_fporch |  c_pxl_synch    | c_pxl_bporch |
-- |                        |             |                 |              |
-- |                                      |                 |              |
-- |<----- c_pxl_2_fporch: 656 ---------->|                 |              |
-- |                                                        |              |
-- |<------------- c_pxl_2_synch: 752 --------------------->|              |
-- |                                                                       |
-- |<------------------------- c_pxl_total: 800 -------------------------->| 

---------- Lineas (vertical) ----------------------------------------------|
-- |                        |             |                 |              |
-- |      video activo      |   porche    |     sincro      |    porche    |
-- |                        | delantero   |   horizontal    |    trasero   |
-- |                        |             |                 |              |
-- |<--------- 480 -------->|<--- 9  ---->|<------ 2  ----->|<---- 29 ---->|
-- |                        |             |                 |              |
-- |      c_line_visible    |c_line_fporch|  c_line_synch   | c_line_bporch|
-- |                        |             |                 |              |
-- |                                      |                 |              |
-- |<----- c_line_2_fporch: 489 --------->|                 |              |
-- |                                                        |              |
-- |<------------- c_line_2_synch: 491 -------------------->|              |
-- |                                                                       |
-- |<------------------------- c_line_total: 520 ------------------------->| 

  -- Pixeles (horizontal o columnas):
  constant   c_pxl_visible    : natural := 640;
  constant   c_pxl_fporch     : natural := 16;
  -- del inicio hasta el porche delantero:
  constant   c_pxl_2_fporch   : natural := c_pxl_visible + c_pxl_fporch; -- 656
  constant   c_pxl_synch      : natural := 96;
  -- del inicio hasta la sincronizacion  
  constant   c_pxl_2_synch    : natural := c_pxl_2_fporch + c_pxl_synch; -- 752
  -- total de pixeles horizontales:
  constant   c_pxl_total      : natural := 800;
  -- el porche trasero:
  constant   c_pxl_bporch     : natural := c_pxl_total - c_pxl_2_synch;  --  48

  -- Filas (vertical):
  constant   c_line_visible    : natural := 480;
  constant   c_line_fporch     : natural := 9;
  -- del inicio hasta el porche delantero:
  constant   c_line_2_fporch   : natural := c_line_visible + c_line_fporch; -- 489
  constant   c_line_synch      : natural := 2;
  -- del inicio hasta la sincronizacion  
  constant   c_line_2_synch    : natural := c_line_2_fporch + c_line_synch; -- 491
  -- total de pixeles horizontales:
  constant   c_line_total      : natural := 520;
  -- el porche trasero:
  constant   c_line_bporch     : natural := c_line_total - c_line_2_synch;  --  29


  -- numero de bits para la cuenta de pixeles(columnas) y filas
  -- el logaritmo devuelve un bit menos, por eso se pone + 1
  -- y hay que ponerle un -1, porque en el caso de que la cuenta sea justo
  -- potencia de dos, vale con un bit menos, porque se cuenta el cero
  -- por ejemplo, 8: log2i(8)= 3 | + 1 = 4, pero con 3 bits, tengo de 0 a 7 (cuento 8)
  --              7: log2i(7)= 2 | + 1 = 3
  constant c_nb_pxls : natural := log2i(c_pxl_total-1) + 1 ;
  constant c_nb_lines: natural := log2i(c_line_total-1) + 1 ;

  -- numero de bits para cada color (RGB)
  constant c_nb_red   : natural := 8;
  constant c_nb_green : natural := 8;
  constant c_nb_blue  : natural := 8;

  -- frecuencia de la VGA
  constant c_freq_vga : natural := 25*10**6; -- VGA 25MHz

  -- nivel activo de sincronismo
  constant c_synch_act : std_logic := '0';

end VGA_PKG;

