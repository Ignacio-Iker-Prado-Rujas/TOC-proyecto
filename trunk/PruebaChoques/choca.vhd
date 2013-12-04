library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

--Pasos: Arreglar el teclado. Hacer los choques. Independizar relojes. Estado quieto.

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

type estado_movimiento is (quieto, arriba, abajo);

signal movimiento_munyeco, next_movimiento: estado_movimiento;

signal hcnt: std_logic_vector(8 downto 0);	-- horizontal pixel counter
signal vcnt, my, r_my: std_logic_vector(9 downto 0);	-- vertical line counter
signal dibujo, bordes, munyeco: std_logic;					-- rectangulo signal
signal dir_mem: std_logic_vector(18-1 downto 0);
signal color: std_logic_vector(8 downto 0);
signal posy: std_logic_vector(7 downto 0);
signal posx, cuenta_pantalla: std_logic_vector(9 downto 0);
--Añadir las señales intermedias necesarias
signal clk, relojMovimiento, relojMunyeco: std_logic;
signal clk_100M, clk_1: std_logic; --Relojes auxiliares
signal pulsado: std_logic;
 
--Descomentar para implementación
component divisor is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

component divisor_pantalla is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

component divisor_bola is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

component control_teclado is
	port (PS2CLK, reset, PS2DATA: in std_logic;
	pulsado: out std_logic);
end component;

component ROM_RGB_9b_prueba_obstaculos is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(18-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component ROM_RGB_9b_prueba_obstaculos;
--Descomentar para implementación

begin
Reloj_pantalla: divisor port map(reset, clk_100M, clk_1);
Reloj_de_movimiento: divisor_pantalla port map(reset, clk_100M, relojMovimiento);
Rom: ROM_RGB_9b_prueba_obstaculos port map(clk, dir_mem, color);
Reloj_pelota: divisor_bola port map(reset, clk_100M, relojMunyeco);
Controla_teclado: control_teclado port map(PS2CLK , reset, PS2DATA, pulsado);
clk_100M <= clock;
clk <= clk_1;

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
--Movimientos:
----------------------------------------------------------------------------
--
posy <= vcnt-110;
posx <= hcnt-4+cuenta_pantalla;
dir_mem <=  posy & posx;

mueve_pantalla: process(reset,relojMovimiento, cuenta_pantalla)
begin
	if reset='1' then
		cuenta_pantalla <= "0000000000";
	elsif (relojMovimiento'event and relojMovimiento='1') then
		cuenta_pantalla <= cuenta_pantalla + 1;
		-- el reloj a usar es relojDeVelocidadPantalla
	end if;
end process mueve_pantalla;

mueve_munyeco: process (relojMunyeco, reset)

begin

	if reset='1' then
		r_my <= "0100000000"; -- 128 en decimal
		movimiento_munyeco <= quieto;
	elsif RelojMunyeco'event and RelojMunyeco = '1' then 
		r_my <= my;
		movimiento_munyeco <= next_movimiento;
	end if;

end process;

mov_munyeco: process(movimiento_munyeco, r_my)
begin
	if movimiento_munyeco = quieto then
		my <= r_my;
	elsif movimiento_munyeco = arriba then
		my <= r_my-1;
	else --movimiento_munyeco = abajo
		my <= r_my+1;
	end if;
end process mov_munyeco;

choque_munyeco:process(hcnt, vcnt,r_my, pulsado, color)
begin
	if r_my <= 110+6 then 
		if pulsado = '1' then
			next_movimiento <= quieto;
		else next_movimiento <= abajo;
		end if;
	elsif r_my >= 366-6 then
		if pulsado = '0' then
			next_movimiento <= quieto;
		else next_movimiento <= arriba;
		end if;
	elsif pulsado = '1' then
	next_movimiento <= arriba;
	else
	next_movimiento <= abajo;
	end if;
	--Choque: color(dirreccionMemoria(r_px,r_py)) = amarillo.Vale ver que chocan
end process choque_munyeco;

------------------------------------------------------
--Pintar:
-------------------------------------------------------
pinta_dibujo: process(hcnt, vcnt)
begin
	dibujo <= '0';
	if hcnt > 4 and hcnt <= 260 and vcnt >= 110 and vcnt < 366 then
			dibujo <= '1';
	end if;
end process pinta_dibujo;

-- pinta bordes
pinta_bordes: process(hcnt, vcnt)
begin
	bordes <= '0';
	if hcnt > 2 and hcnt < 263 then
		if vcnt >106 and vcnt < 370 then
			if hcnt <= 4 or hcnt > 260 or vcnt < 110 or vcnt > 366 then
					bordes <= '1';
			end if;
		end if;
	end if;
end process pinta_bordes;


pinta_munyeco: process(hcnt, vcnt, r_my)
begin
	munyeco <= '0';
	if hcnt > 15 and hcnt < 21 then
		if vcnt > r_my-6 and vcnt < r_my+6 then
			munyeco<='1';
		end if;
	end if;
end process pinta_munyeco;

----------------------------------------------------------------------------
--Colorea
----------------------------------------------------------------------------
colorear: process(hcnt, vcnt, dibujo, color, bordes, munyeco)
begin
	if bordes = '1' then rgb <= "110110000";
	elsif munyeco = '1' then rgb <= "111001100";
	elsif dibujo = '1' then rgb <= color;
	else rgb <= "000000000";
	end if;
end process colorear;
---------------------------------------------------------------------------
end vgacore_arch;