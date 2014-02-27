library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

--NivelesPrueba

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

type estado_movimiento is (quieto, arriba, abajo, fin, flotar, acelerar);
type estado_choques is (inicializa, comprueba_cabeza, comprueba_frente, comprueba_pies, comprueba_espalda);
type estados_juego is (playing, game_over, pause);
type estados_niveles is (nivel1, nivel2, nivel3, nivel4, nivel5);

signal state, next_state : estado_choques := inicializa;
signal contador_sub, aux_contador_sub, contador_baj, aux_contador_baj: std_logic_vector(9 downto 0);
signal movimiento_munyeco, next_movimiento: estado_movimiento;
signal ralentizar: std_logic;
signal hcnt: std_logic_vector(8 downto 0);	-- horizontal pixel counter
signal vcnt, my, r_my: std_logic_vector(9 downto 0);	-- vertical line counter
signal obstaculo, bordes, munyeco, fondo: std_logic;					-- rectangulo signal

--Direcciones para las rom
signal dir_mem: std_logic_vector(18-1 downto 0);
signal dir_mem_fondo: std_logic_vector(15-1 downto 0);
signal dir_mem_marcador: std_logic_vector(11-1 downto 0);
signal dir_mem_game_over: std_logic_vector(11 downto 0);

--Colores
signal color_obstaculo, color_marcador,  imagen_game_over, color_fondo: std_logic_vector(8 downto 0);
signal color1, color2, color3, color4, color5: std_logic_vector(8 downto 0);
signal color_choque: std_logic;
---------

signal posy, posy_choque: std_logic_vector(7 downto 0);
signal posx, posx_choque, avanza_obstaculos: std_logic_vector(9 downto 0);

--SEÑALES DE BARRY TROTTER
signal posx_munyeco: std_logic_vector(3 downto 0);
signal posy_munyeco: std_logic_vector(4 downto 0);
signal dir_mem_munyeco: std_logic_vector(9-1 downto 0);
signal color_munyeco: std_logic_vector(9-1 downto 0);
--señales ram
--signal we : std_logic;

--Señales para los choques (contadores y direccion de choque):
signal i, aux_i: std_logic_vector(9 downto 0);
signal j, aux_j: std_logic_vector(7 downto 0);
signal dir_mem_choque: std_logic_vector(18-1 downto 0);

--Añadir las señales intermedias necesarias
signal relojChoques: std_logic;
signal relojPintaObstaculos: std_logic; --Refresca los obstáculos
signal relojMovFondo: std_logic; --Mueve los obstáculos
signal clk, relojMovimiento, relojMunyeco: std_logic;
signal clk_100M, clk_1: std_logic; --Relojes auxiliares
signal pulsado: std_logic;
signal pausado: std_logic;--señal de pausa

--Señales de los marcadores
signal cuenta_metros : integer;
signal paint_marcador : std_logic;
--Estados del juego
signal estado_juego, next_estado_juego: estados_juego;
signal paint_game_over: std_logic;

--Posiciones
signal pos_go_y: std_logic_vector(4 downto 0);
signal pos_go_x: std_logic_vector(6 downto 0); 
signal pos_co_y: std_logic_vector(3 downto 0);
signal pos_co_x: std_logic_vector(6 downto 0); 

signal posy_fondo: std_logic_vector(7 downto 0);
signal posx_fondo, cuenta_fondo: std_logic_vector(6 downto 0);

----Conversor de un bit a nueve de los obstáculos
signal salida_obstaculos: std_logic;

signal debug_choque: std_logic;

--Estado del nivel
signal estado_nivel, sig_estado_nivel: estados_niveles;--Conectamos el color a rgb y a color
	-- el color de cada nivel, con un with select o lo que sea, que este cada uno conectado con
	-- su ROM correspondiente.
 
-- Reloj para la pantalla
component divisor is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

-- Reloj para los choques
component divisor_choques is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

-- Reloj para el movimiento de los obstáculos
component divisor_movimiento_obstaculos is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

-- Reloj para el movimiento del fondo
component divisor_movimiento_fondo is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

-- Reloj para Barry
component divisor_munyeco is 
port (ralentizar, reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

-- Controlador del teclado
component control_teclado is
	port (PS2CLK, reset, PS2DATA: in std_logic;
	pulsado: out std_logic;
	pausado: out std_logic);
end component;

-- ROM para las imagenes
component ROM_RGB_9b_mapa_facil is
    port (
    clk					  : in  std_logic;   -- reloj
    addr, addr_munyeco : in  std_logic_vector(18-1 downto 0);
    dout, dout_munyeco : out std_logic
  );
end component;--ROM_RGB_9b_nivel_1_0;

-- ROM para el fondo
component ROM_RGB_9b_fondo is
    port (
    clk					  : in  std_logic;   -- reloj
    addr: in  std_logic_vector(15-1 downto 0);
    dout: out std_logic_vector(9-1 downto 0) 
  );
end component;

--ROM de barry trotter
component ROM_RGB_9b_Joyride is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

--Rom del game over
component ROM_RGB_9b_game_over_negro is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(12-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

--Rom del marcador
component ROM_RGB_9b_marcador is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(11-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0)
  );
end component;

begin

---Reloj
Reloj_choque: divisor_choques port map(reset, clk_100M, relojChoques);
Reloj_pantalla: divisor port map(reset, clk_100M, clk_1);
Reloj_pantallaObstaculos: divisor port map(reset, clk_100M, relojPintaObstaculos);
Reloj_de_movimiento_obstaculos: divisor_movimiento_obstaculos port map(reset, clk_100M, relojMovimiento);
Reloj_munyeco: divisor_munyeco port map(ralentizar, reset, clk_100M, relojMunyeco);
Controla_teclado: control_teclado port map(PS2CLK , reset, PS2DATA, pulsado, pausado);
clk_100M <= clock;
clk <= clk_1;
--Reloj para el movimiento de los obstáculos
Reloj_de_movimiento_fondo: divisor_movimiento_fondo port map(reset, clk_100M, relojMovFondo);

---Rom
Rom: ROM_RGB_9b_mapa_facil port map(relojPintaObstaculos, dir_mem, dir_mem_choque, salida_obstaculos, color_choque); 
Rom_barry: ROM_RGB_9b_Joyride port map(clk, dir_mem_munyeco, color_munyeco);
Rom_game_over: ROM_RGB_9b_game_over_negro port map(clk, dir_mem_game_over,imagen_game_over);

Rom_marcador: ROM_RGB_9b_marcador port map(clk, dir_mem_marcador, color_marcador);
Rom_fondo: ROM_RGB_9b_fondo port map(clk, dir_mem_fondo, color_fondo);

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

--Posiciones de los obstaculos (Restar 4 a hcnt)
posy <= vcnt - 111;
posx <= hcnt - 4 + avanza_obstaculos;
dir_mem <=  posy & posx;

--Posiciones de memoria del fondo
posy_fondo <= vcnt - 111;
posx_fondo <= hcnt - 4 + cuenta_fondo;
dir_mem_fondo <=  posy_fondo & posx_fondo;

--Posiciones para el choque
--<= r_my - 110;				--Posicion y del choque
--posx_choque <= 40 + avanza_obstaculos; 		--Posicion x del choque
--dir_mem_choque_arriba <= posy_choque & posx_choque;  --Posicion arriba:  (4 + avanza_obstaculos, rm_y)
--dir_mem_choque_abajo <= "00" & r_my & "101000";  --Posicion abajo:   (40, 142 + rm_y) CAMBIAR
--dir_mem_choque_derecha <= "00" & r_my & "110000"; --Posicion derecha: (48, 126 + rm_y) CAMBIAR


--Posiciones de barry trotter
posx_munyeco <= hcnt - 32;
posy_munyeco <= vcnt - r_my;
dir_mem_munyeco <= posy_munyeco & posx_munyeco;

--Posiciones del game over
pos_go_y <= vcnt - 222;
pos_go_x <= hcnt - 68;
dir_mem_game_over <=  pos_go_y & pos_go_x;


--Posiciones del marcador
pos_co_y <= vcnt - 50;
pos_co_x <= hcnt - 200;
dir_mem_marcador <=  pos_co_y & pos_co_x;

mueve_obstaculos: process(reset,relojMovimiento, avanza_obstaculos, estado_juego)
begin
	if reset='1' then
		avanza_obstaculos <= "0000000000";
	elsif (relojMovimiento'event and relojMovimiento='1') then
		if estado_juego = playing then 
			avanza_obstaculos <= avanza_obstaculos + 1;
		else 
			avanza_obstaculos <= avanza_obstaculos;
		end if;
		-- el reloj a usar es relojDeVelocidadPantalla
	end if;
end process mueve_obstaculos;

mueve_fondo:process(reset,relojMovFondo, estado_juego, cuenta_fondo)
begin
	if reset='1' then
		cuenta_fondo <= "0000000";
	elsif (relojMovFondo'event and relojMovFondo='1') then
		if estado_juego = playing then 
			cuenta_fondo <= cuenta_fondo + 1;
		else 
			cuenta_fondo <= cuenta_fondo;
		end if;
		-- el reloj a usar es relojDeVelocidadPantalla
	end if;
end process mueve_fondo;

mueve_munyeco: process (relojMunyeco, reset)

begin
	if reset='1' then
		r_my <= "0100000000"; -- 128 en decimal
		movimiento_munyeco <= quieto;
	elsif RelojMunyeco'event and RelojMunyeco = '1' then 
--		contador_sub <= aux_contador_sub;
--		contador_baj <= aux_contador_baj;
		r_my <= my;
		movimiento_munyeco <= next_movimiento;
	end if;

end process;

mov_munyeco: process(movimiento_munyeco, r_my, contador_sub, contador_baj)
begin
	if movimiento_munyeco = quieto then
		my <= r_my;
--		ralentizar <= '0';
--		aux_contador_sub <= (others => '0');
--		aux_contador_baj <= (others => '0');

	elsif movimiento_munyeco = arriba then
		my <= r_my-1;
--		ralentizar <= '0';
--		aux_contador_sub <= (others => '0');
--		aux_contador_baj <= (others => '0');	

	elsif movimiento_munyeco = abajo then
		my <= r_my+1;
--		ralentizar <= '0';
--		aux_contador_sub <= (others => '0');	
--		aux_contador_baj <= (others => '0');

		
--	elsif movimiento_munyeco = acelerar then
--		my <= r_my-1;
--		ralentizar <= '1';
--		aux_contador_sub <= contador_sub +1;
		
--	elsif movimiento_munyeco = flotar then
--		my <= r_my+1;
--		ralentizar <= '1';
--		aux_contador_baj <= contador_baj +1;
		
	else -- movimiento_munyeco = fin
		my <= r_my;
	end if;
end process mov_munyeco;


------Controlador de los estados del juego
clock_estado_juego: process (reset, clk)
begin
	if reset = '1' then
		estado_juego <= playing;
	elsif clk' event and clk = '1' then
		estado_juego <= next_estado_juego;
	end if;
end process clock_estado_juego;

controla_juego: process(estado_juego, pulsado, color_choque, pausado)
	begin
	if color_choque = '1'  then
		next_estado_juego <= game_over;
	elsif pulsado = '1' then
		next_estado_juego <= playing;
	elsif pausado = '1' then
		next_estado_juego <= pause;
		--if estado_juego = playing then next_estado_juego <= pause;
		--elsif estado_juego = pause then next_estado_juego <= playing;
		--end if;
	else
		next_estado_juego <= estado_juego;
	end if;
		
end process controla_juego;

--------------------------------------------
estado_munyeco:process(hcnt, vcnt, r_my, pulsado, color_obstaculo, color_choque, movimiento_munyeco, contador_sub, contador_baj, estado_juego)
begin
	if estado_juego = game_over then
		next_movimiento <= fin;
	elsif estado_juego = pause then
		next_movimiento <= fin;
	elsif r_my <= 110 then 
		if pulsado = '1' then
			next_movimiento <= quieto;
		else 
--			next_movimiento <= flotar;
			next_movimiento <= abajo;
		end if;
	elsif r_my >= 302 then
		if pulsado = '0' then
			next_movimiento <= quieto;
		else 
--			next_movimiento <= acelerar;
		next_movimiento <= arriba;
		end if;
	elsif pulsado = '1' then
		next_movimiento <= arriba;
--		if movimiento_munyeco = abajo then
--			next_movimiento <= acelerar;	
--		elsif movimiento_munyeco = flotar then
--			next_movimiento <= acelerar;
--		elsif movimiento_munyeco = quieto then 
--			next_movimiento <= acelerar;
--		elsif movimiento_munyeco = acelerar and contador_sub < "000011111" then
--			next_movimiento <= acelerar;
--		elsif movimiento_munyeco = acelerar and contador_sub = "000011111" then
--			next_movimiento <= arriba;
--		else next_movimiento <= movimiento_munyeco;
		--end if;
	else
		next_movimiento <= abajo;
--		if movimiento_munyeco = acelerar then
--			next_movimiento <= flotar;
--		elsif movimiento_munyeco = arriba then 
--			next_movimiento <= flotar;
--		elsif movimiento_munyeco = quieto then 
--			next_movimiento <= quieto;
--		elsif movimiento_munyeco = flotar and contador_baj < "000011111" then
--			next_movimiento <= flotar;
--		elsif movimiento_munyeco = flotar and contador_baj = "000011111" then
--			next_movimiento <= abajo;

--		else next_movimiento <= movimiento_munyeco;
--		end if;
	end if;
	
end process estado_munyeco;
------------------------------------------------------
--Choques:
------------------------------------------------------
--Process de los estados
state_choques: process(relojChoques, next_state, aux_i, aux_j)
begin
	if(relojChoques'event and relojChoques = '1') then
		state <= next_state;
		i <= aux_i;
		j <= aux_j;
	end if;
end process state_choques;
		
		
dir_mem_choque <= j & (i + avanza_obstaculos);
--Process que actualiza estados
comprueba_choques: process(avanza_obstaculos, r_my, i, j, color_choque, state)
begin
	aux_i <= "0000011011"; --Valor 27 (10 bits)
	aux_j <= r_my - "01101011"; --Valor 107 (8 bits)
	if state = inicializa then
		aux_i <= "0000011011"; --Valor 27 (10 bits)
		aux_j <= r_my - "01101011"; --Valor 107 (8 bits)
		--if(relojMunyeco'event and relojMunyeco = '1') --Para no estar siempre comprobando se podria a-adir este if, PREGUNTAR A MARCOS			
		next_state <= comprueba_cabeza;
	elsif state = comprueba_cabeza then
--		aux_i <= "0000101000";
--		aux_j <= r_my - "01101011";
--		next_state <= comprueba_frente;	
		aux_j <= r_my - "01101011";
		if i < 40  then
			aux_i <= i + 1;
			next_state <= comprueba_cabeza;
		else
			aux_i <= i;
			next_state <= comprueba_frente;
		end if;
	elsif state = comprueba_frente then
--		aux_i <= "0000101000";
--		aux_j <= r_my - "01010010";
--		next_state <= comprueba_pies;	
		aux_i <= "0000101000";
		if j < r_my - 82 then
			aux_j <= j + 1;
			next_state <= comprueba_frente;
		else
			aux_j <= j;
			next_state <= comprueba_pies;
		end if;
	elsif state = comprueba_pies then
--		aux_i <= "0000011011";
--		aux_j <= r_my - "01010010";
--		next_state <= inicializa;	
		aux_j <= r_my - "01010010";
		if i > 27 then
			aux_i <= i - 1;
			next_state <= comprueba_pies;
		else
			aux_i <= i;
			next_state <= comprueba_espalda;
		end if;
	elsif state = comprueba_espalda then
		aux_i <= "0000011011";
		if j > r_my - 107 then
			aux_j <= j - 1;
			next_state <= comprueba_espalda;
		else
			aux_j <= j;
			next_state <= comprueba_cabeza;
		end if;
	end if;
end process comprueba_choques;
------------------------------------------------------
--Pintar:
-------------------------------------------------------
pinta_obstaculos: process(hcnt, vcnt, salida_obstaculos)
begin
	obstaculo <= '0';
	fondo <= '0';
	color_obstaculo <= "111111111";
	if hcnt > 4 and hcnt <= 260 and vcnt > 110 and vcnt <= 366 then
		if salida_obstaculos = '1' then 
			color_obstaculo <= "111111000";
			obstaculo <= '1';
		else 
			--El mapa de obstaculos no pinta el blanco y se pinta el fondo
			fondo <= '1';
		end if;
	end if;
end process pinta_obstaculos;

-- pinta bordes
pinta_bordes: process(hcnt, vcnt)
begin
	bordes <= '0';
	if hcnt > 2 and hcnt < 263 then
		if vcnt >107 and vcnt < 370 then
			if hcnt <= 4 or hcnt > 260 or vcnt <= 110 or vcnt > 366 then
					bordes <= '1';
			end if;
		end if;
	end if;
end process pinta_bordes;


pinta_munyeco: process(hcnt, vcnt, r_my, color_munyeco)
begin
	munyeco <= '0';
	if hcnt >= 32 and hcnt < 48 then
		if vcnt >= r_my and vcnt < r_my+32 then
			if color_munyeco = "111111111" then
				munyeco<='0';
			else munyeco <='1';
			end if;
		end if;
	end if;
end process pinta_munyeco;



pinta_game_over: process(hcnt, vcnt, estado_juego, imagen_game_over)
begin
	paint_game_over <= '0';
	--Buscar zona para pintar game over
	if hcnt >= 68 and hcnt < 196 then
		if vcnt >= 222 and vcnt < 254	then
			if estado_juego = game_over then
				if imagen_game_over = "000000000" then
					paint_game_over <= '0';
				else
					paint_game_over <= '1';
				end if;
			end if;
		end if;
	end if;
end process pinta_game_over;

pinta_marcador: process(hcnt, vcnt)
begin
	paint_marcador <= '0';
	if hcnt >= 200 and hcnt < 208 then
		if vcnt >= 50 and vcnt < 66 then
			paint_marcador <= '1';
		end if;
	end if;
end process pinta_marcador;

----Deugueo de los choques-----------
p_ch: process (dir_mem_choque, vcnt, hcnt, j, i)
begin
	debug_choque <= '0';
	if ((j)&(i+4)) = vcnt & hcnt then
		debug_choque <= '1';
	end if;
end process p_ch;
----------------------------------------------------------------------------
--Colorea
----------------------------------------------------------------------------
colorear: process(hcnt, vcnt, obstaculo, color_obstaculo, bordes, munyeco,
		color_munyeco, paint_game_over, imagen_game_over, fondo, color_fondo,
			paint_marcador, color_marcador, debug_choque)
begin
	if debug_choque = '1' then rgb <= "111000000";
	elsif bordes = '1' then rgb <= "110110000";
	elsif paint_game_over = '1' then rgb <= imagen_game_over;
	elsif munyeco = '1' then rgb <= color_munyeco;
	elsif obstaculo = '1' then rgb <= color_obstaculo;
	elsif fondo = '1' then rgb <= color_fondo;
	elsif paint_marcador = '1' then rgb <= color_marcador;
	else rgb <= "000000000";
	end if;
end process colorear;
--
--pintamarcador: process(avanza_obstaculos)
--cuenta_metros <= 7;
--
--end process;
--
----MARCADOR---
--actualiza_metros: process(avanza_obstaculos)
--	cuenta_metros <= cuenta_metros+1;
--	
--
--end process;
---------------------------------------------------------------------------
end vgacore_arch;