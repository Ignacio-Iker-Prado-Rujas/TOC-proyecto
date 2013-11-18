library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity vgacore is
	port
	(
		reset: in std_logic;	-- reset
		clock: in std_logic;
		hsyncb: inout std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;	-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0) -- red,green,blue colors
	);
end vgacore;

architecture vgacore_arch of vgacore is

type Movimiento is (XpositivoYpositivo, XpositivoYnegativo, XnegativoYpositivo, XnegativoYnegativo);

signal hcnt, px, r_px: std_logic_vector(8 downto 0);	-- horizontal pixel counter
signal vcnt, py, r_py: std_logic_vector(9 downto 0);	-- vertical line counter
signal rectangulo: std_logic;					-- rectangulo signal
signal bola: std_logic;
signal EstadoPelota: Movimiento;


--Añadir las señales intermedias necesarias
signal clk: std_logic;
signal clk_100M, clk_1: std_logic; --Relojes auxiliares
signal RelojPelota: std_logic;--Reloj de las pelotas

--Descomentar para implementación
component divisor is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;
begin
--Descomentar para implementación

Nuevo_reloj: divisor port map(reset, clk_100M, clk_1);
clk_100M <= clock;
clk <= clk_1;
RelojPelota <= clk;

RP: process (RelojPelota)
begin
	if reset='1' then
		r_px <= "000000100";
		r_py <= "0010000000";
	elsif RelojPelota'event and RelojPelota = '1' then 
		r_px <= px;
		r_py <= py;
	end if;
end process;

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
--
-- Ejemplo
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

pinta_bola: process(hcnt, vcnt)
begin
	bola <= '0';
	if hcnt > r_px-1 and hcnt < r_px+1 then
		if vcnt > r_py-2 and vcnt < r_py+2 then
			bola<='1';
		end if;
	end if;
end process pinta_bola;

mueve_bola: process(hcnt, vcnt)
begin

	
	EstadoPelota <= XnegativoYnegativo;
	case EstadoPelota is
	when XpositivoYpositivo => 
		px <= r_px+1;
		py <= r_py+1;
	when XpositivoYnegativo =>
		px <= r_px+1;
		py <= r_py-1;
	when XnegativoYpositivo =>
		px <= r_px-1;
		py <= r_py+1;
	when XnegativoYnegativo =>
		px <= r_px-1;
		py <= r_py-1;
	end case;
end process mueve_bola;


colorear: process(rectangulo, hcnt, vcnt)
begin
	if rectangulo = '1' then rgb <= "110110000";
	elsif bola = '1' then rgb <= "111111111";
	else rgb <= "000000000";
	end if;
end process colorear;
---------------------------------------------------------------------------
end vgacore_arch;