library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity vgacore is
	port
	(

		PS2CLK: in std_logic;
		PS2DATA: in std_logic;
		reset: in std_logic;	-- reset
		clock: in std_logic;
		hsyncb: inout std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;	-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0) -- red,green,blue colors
	);
end vgacore;

architecture vgacore_arch of vgacore is


type estado_movimiento is (XpositivoYpositivo, XpositivoYnegativo, XnegativoYpositivo, XnegativoYnegativo);


signal hcnt, px, r_px, r_bx, bx: std_logic_vector(8 downto 0);	-- horizontal pixel counter
signal vcnt, py, r_py: std_logic_vector(9 downto 0);	-- vertical line counter
signal rectangulo, bola, barra, obstaculo: std_logic;

signal movimiento_pelota, aux_movimiento: estado_movimiento;

signal saltado: std_logic;--señal que recibe pulsado

--Añadir las señales intermedias necesarias
signal clk: std_logic;
signal clk_100M, clk_1: std_logic; --Relojes auxiliares

signal RelojPelota: std_logic;--Reloj de las pelotas


--Descomentar para implementación
component divisor is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

--Component del divisor de la bola

component divisor_bola is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

--Component del controlador del teclado para dar al espacio

component control_teclado is
	port (PS2CLK, reset, PS2DATA: in std_logic;
	pulsado: out std_logic);
end component;
begin
--Descomentar para implementación
Nuevo_reloj: divisor port map(reset, clk_100M, clk_1);
clk_100M <= clock;
clk <= clk_1;
Otro_reloj: divisor_bola port map(reset, clk_100M, RelojPelota);





Teclado: control_teclado port map(PS2CLK, reset, PS2DATA, saltado);

-------------------------------

RP: process (RelojPelota, reset)

begin

	if reset='1' then--inicializacion de las coordenadas

		r_px <= "000111100";

		r_py <= "0010000000";

		r_bx <= "000110000";

		movimiento_pelota <= XnegativoYpositivo;

	elsif RelojPelota'event and RelojPelota = '1' then 

		r_px <= px;

		r_py <= py;

		r_bx <= bx;

		movimiento_pelota <= aux_movimiento;

	end if;

end process;

---------------------------------


A: process(clk,reset)
begin
	-- reset asynchronously clears pixel counter
	if reset='1' then
		hcnt <= "000000000";
	-- horiz. pixel counter increments on rising edge of dot clock
	elsif (clk'event and clk = '1') then
		-- horiz. pixel counter rolls-over after 381 pixels
		if hcnt < 380 then
			hcnt <= hcnt + 1;
		else
			hcnt <= "000000000";
		end if;
	end if;
end process;

B: process(hsyncb,reset)
begin
	-- reset asynchronously clears line counter
	if reset='1' then
		vcnt <= "0000000000";
	-- vert. line counter increments after every horiz. line
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. line counter rolls-over after 528 lines
		if vcnt < 527 then
			vcnt <= vcnt + 1;
		else
			vcnt <= "0000000000";
		end if;
	end if;
end process;


--------------------------------------

--salidas para la fpga

-----------------------------------
C: process(clk,reset) 
begin
	-- reset asynchronously sets horizontal sync to inactive
	if reset='1' then
		hsyncb <= '1';
	-- horizontal sync is recomputed on the rising edge of every dot clock
	elsif (clk'event and clk='1') then
		-- horiz. sync is low in this interval to signal start of a new line
		if (hcnt >= 291 and hcnt < 337) then
			hsyncb <= '0';
		else
			hsyncb <= '1';
		end if;
	end if;
end process;

D: process(hsyncb,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if reset='1' then
		vsyncb <= '1';
	-- vertical sync is recomputed at the end of every line of pixels
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. sync is low in this interval to signal start of a new frame
		if (vcnt>=490 and vcnt<492) then
			vsyncb <= '0';
		else
			vsyncb <= '1';
		end if;
	end if;
end process;
----------------------------------------------------------------------------
--
-- A partir de aqui escribir la parte de dibujar en la pantalla
--
-- Tienen que generarse al menos dos process uno que actua sobre donde
-- se va a pintar, decide de qué pixel a que pixel se va a pintar
-- Puede haber tantos process como señales pintar (figuras) diferentes 
-- queramos dibujar
--
-- Otro process (tipo case para dibujos complicados) que dependiendo del
-- valor de las diferentes señales pintar genera diferentes colores (rgb)
-- Sólo puede haber un process para trabajar sobre rgb
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------




---------------------------

--pintar

---------------------------


-- pinta rectangulo
pinta_rectangulo: process(hcnt, vcnt)
begin
	rectangulo <= '0';
	if hcnt > 1 and hcnt < 263 then
		if vcnt >106 and vcnt < 370 then
			if hcnt < 4 or hcnt > 260 or vcnt < 110 or vcnt > 366 then
					rectangulo <= '1';
			end if;
		end if;
	end if;
end process pinta_rectangulo;




--pinta la barra
pinta_barra: process(hcnt, vcnt, r_bx)
begin
	barra <= '0';
	if vcnt < 365 and vcnt > 359 then
		if hcnt > r_bx - 10 and hcnt < r_bx + 10 then
			barra <= '1';
		end if;
	end if;
end process pinta_barra;




--pinta la bola
pinta_bola: process(hcnt, vcnt, r_px, r_py)
begin
	bola <= '0';
	if hcnt > r_px-1 and hcnt < r_px+1 then
		if vcnt > r_py-2 and vcnt < r_py+2 then
			bola<='1';
		end if;
	end if;
end process pinta_bola;





----------------------





--BARRA
mueve_barra: process(PS2CLK, saltado, r_bx)
begin

if saltado = '1' then

	if r_bx >= 250 then

		bx <= r_bx;

	else bx <= r_bx +2;

	end if;

else

	if r_bx <= 14 then

		bx <= r_bx;

	else bx <= r_bx -2;

	end if;

end if;
--	if pulsado = '1' then
--		if direccion = '0' then
--			bx <= r_bx - 2;
--		else bx <= r_bx + 2;
--		end if;
--	else bx <= r_bx;
--	end if;
--	bx <= r_bx + 2;

--	if r_bx >= 155 then

--		bx <= "000000100";

--	elsif r_bx <= 4 then

--		bx <= r_bx + 2;

	--end if;
end process mueve_barra;



--BOLA

mueve_bola: process(movimiento_pelota, r_px, r_py)
begin

	--EstadoPelota <= XnegativoYnegativo;



	if movimiento_pelota = XpositivoYpositivo then

		px <= r_px+1;

		py <= r_py+1;

	elsif movimiento_pelota = XnegativoYpositivo then

		px <= r_px-1;

		py <= r_py+1;

	elsif movimiento_pelota = XpositivoYnegativo then

		py <= r_py-1;

		px <= r_px+1;

	elsif movimiento_pelota = XnegativoYnegativo then 

		py <= r_py-1;

		px <= r_px-1;

	end if;
end process mueve_bola;



choque_bola:process(hcnt, vcnt, movimiento_pelota,r_px,r_py)
begin
	if r_px >= 260 then 

		if movimiento_pelota = XpositivoYnegativo then

			aux_movimiento <= XnegativoYnegativo;

		elsif movimiento_pelota = XpositivoYpositivo then

			aux_movimiento <= XnegativoYpositivo;

		else aux_movimiento <= movimiento_pelota;

		end if;

	elsif r_px <= 4 then

		if movimiento_pelota = XnegativoYnegativo then

			aux_movimiento <= XpositivoYnegativo;

		elsif movimiento_pelota = XnegativoYpositivo then

			aux_movimiento <= XpositivoYpositivo;

		else aux_movimiento <= movimiento_pelota;

		end if;

	elsif r_py <= 110 then 

		if movimiento_pelota = XpositivoYnegativo then

			aux_movimiento <= XpositivoYpositivo;

		elsif movimiento_pelota = XnegativoYnegativo then

			aux_movimiento <= XnegativoYpositivo;

		else aux_movimiento <= movimiento_pelota;

		end if;

	elsif r_py >= 366 then

		if movimiento_pelota = XnegativoYpositivo then

			aux_movimiento <= XnegativoYnegativo;

		elsif movimiento_pelota = XpositivoYpositivo then

			aux_movimiento <= XpositivoYnegativo;

		else aux_movimiento <= movimiento_pelota;

		end if;

	else aux_movimiento <= movimiento_pelota;

	end if;
end process choque_bola;





------------------------------------------------------------------
-- PARTE DE PRUEBA PARA CHOQUE CON OBSTACULOS (en fase beta):
-- TODO: Estaria bien cambiar los nombres de los estados a NO,NE, SE, SO, menos lioso no?
-- 
-- -- Pinta el obstaculo
-- pinta_obstaculo: process(hcnt, vcnt)
-- begin
-- 	obstaculo <= '0';
-- 	if hcnt > 100 and hcnt < 150 then
-- 		if vcnt > 100 and vcnt < 200 then
-- 			obstaculo <= '1';
-- 		end if;
-- 	end if;
-- end process pinta_obstaculo;
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
------------------------------------------------------------------



------------------------------------------------------------------


colorear: process(rectangulo, hcnt, vcnt, bola, barra)
begin
	if rectangulo = '1' then rgb <= "110110000";
	elsif bola = '1' then rgb <= "111111111";
	elsif barra = '1' then rgb <= "111111111";
	-- elsif obstaculo = '1' then rgb <= "000111000; -- Verde creo
	else rgb <= "000000000";
	end if;
end process colorear;


------------------------------------------------------------------

------------------------------------------------------------------
end vgacore_arch;