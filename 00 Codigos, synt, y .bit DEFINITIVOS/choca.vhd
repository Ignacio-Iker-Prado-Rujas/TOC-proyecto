----------------------------------------------------------------------------------
-- Company: 		Universidad Complutense de Madrid
--
-- Engineers: 		PiKey Team
-- Members:			Jesús Aguirre Pemán
--						Enrique Ballesteros Horcajo
--						Mayra Alexandra Castrosqui Florián
--						Jaime Dan Porras Rhee
--						Ignacio Iker Prado Rujas
--					
-- Project Name: 	Jetpack
-- Description: 	Game based on Jetpack Joyride running on a FPGA Spartan 3
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;



entity vgacore is
	port
	(	
		PS2CLK: in std_logic;														-- clock del teclado 
		PS2DATA: in std_logic;														-- datos del teclado
		reset: in std_logic;															-- reset
		clock: in std_logic;															-- clock de la FPGA
		hsyncb: inout std_logic;													-- horizontal (line) sync
		vsyncb: out std_logic;														-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0); 								-- red, green, blue colors
		displayizq, displaydcha: out std_logic_vector(6 downto 0)		-- displays 7 segmentos de la FPGA
	);
end vgacore;

architecture vgacore_arch of vgacore is




------------------------------------------------------------------------
-- SEÑALES
------------------------------------------------------------------------
-------------------
-- ESTADOS
-------------------
--Define el movimiento de Barry
type estado_movimiento is (quieto, arriba, abajo, fin);
--Define los estados de comprobación de choques con obstaculos
type estado_choques is (inicializa, comprueba_cabeza, comprueba_frente, comprueba_pies, comprueba_espalda);
--Define los estados en los que se encuentra el juego en cada momento
type estados_juego is (playing, game_over, pause);
--Define el nivel en el que se encuentra actualmente
type estados_niveles is (nivel1, nivel2, nivel3);
--Define los estados en los que puede estar una moneda
type estados_monedas is (quieto, invisible, subiendo, bajando, moneda_conseguida, cuenta);

-------------------
-- SEÑALES DE LOS ESTADOS
-------------------
--Estados de los movimientos de Barry
signal movimiento_munyeco, next_movimiento: estado_movimiento;
--Estados de los choques, comienza en la inicialización
signal state, next_state : estado_choques := inicializa;
--Estados del juego y del estado de movimiento de barry
signal estado_juego, next_estado_juego: estados_juego;
--Estado del nivel
signal estado_nivel, sig_estado_nivel: estados_niveles;
--Estados de las monedas 
signal state_coin, next_state_coin: estados_monedas := invisible; --pause_state_coin (no se usa)

-------------------
-- SEÑALES DE POSICIONES
-------------------
--Contador para el flotar de Barry (no se usa)
--signal contador_sub, aux_contador_sub, contador_baj, aux_contador_baj: std_logic_vector(9 downto 0);
--Cuenta horizontal de píxeles de la pantalla
signal hcnt: std_logic_vector(8 downto 0);	-- horizontal pixel counter
--Cuenta vertical de píxeles de pantalla
signal vcnt: std_logic_vector(9 downto 0);	-- vertical line counter
--Posición vertical de Barry, contando desde su cabeza
signal my, r_my: std_logic_vector(9 downto 0);

-------------------
-- SEÑALES DE OBSTACULOS Y FONDO
-------------------
--Indicadores para pintar obstáculos, bordes, Barry y fondo
signal obstaculo, salida_obstaculo,  bordes, munyeco, munyeco1, munyeco2, fondo, fondo_inter: std_logic;
--Distintos tipos de obstaculos
signal salida_obstaculo1, salida_obstaculo2, salida_obstaculo3: std_logic;
--Fondos intermedios para el nivel 3
signal fondo_inter1, fondo_inter2: std_logic;
--Para que no se pinten los obstaculos de golpe al iniciar un nivel
signal bloquea_obstaculo: std_logic;

-------------------
-- DIRECCIONES PARA LAS ROMs
-------------------
--Direccion de memoria para los obstaculos
signal dir_mem: std_logic_vector(18-1 downto 0);
--Direccion de memoria para el fondo
signal dir_mem_fondo, dir_mem_fondo_inter: std_logic_vector(15-1 downto 0);
--Direccion de memoria para el game over
signal dir_mem_game_over: std_logic_vector(11 downto 0);

-------------------
-- COLORES
-------------------
--Salidas de colores de las respectivas ROMs 
signal color_obstaculo, imagen_game_over, color_fondo, color_inter_fondo: std_logic_vector(8 downto 0);
--Color de cada nivel de obstáculo. El color fondo 3 son los arboles o nubes, 2 y 3 
signal color_fondo1, color_fondo2, color_fondo3: std_logic_vector(8 downto 0);
--Color de los obstaculos que estarán conectados a las rom
--signal color_obs_1, color_obs_2, color_obs_3: std_logic_vector(8 downto 0);
--Salida de la rom de obstaculos, en función de la posición de Barry
--Vale 1 si hay un obstáculo y 0 si no lo hay.
signal color_choque: std_logic;
signal color_choque1, color_choque2, color_choque3: std_logic;

-------------------
-- COORDENADAS MAPA
-------------------
--Posición de refresco de los obstáculos, sirve para construir dir_mem
signal posy: std_logic_vector(7 downto 0);
signal posx, avanza_obstaculos: std_logic_vector(9 downto 0);

-------------------
-- COORDENADAS MONEDA
-------------------
--Posición de la moneda, coordenada y
signal posy_moneda, next_posy_moneda, inicio_aleatorio_moneda: std_logic_vector(9 downto 0);
--Posición de la moneda, coordenada x
signal posx_moneda, next_posx_moneda: std_logic_vector(9 downto 0); --avanza_moneda (no se usa)
--Coordenada y aleatoria de la salida de la moneda
signal salida_aleatoria: std_logic_vector(6 downto 0);

-------------------
-- COORDENADAS BARRY TROTTER
-------------------
--Posiciones y colores de Barry que permiten pintarlo de la ROM.
signal posx_munyeco: std_logic_vector(3 downto 0);
signal posy_munyeco: std_logic_vector(4 downto 0);
signal dir_mem_munyeco: std_logic_vector(9-1 downto 0);

-------------------
-- COLORES BARRY TROTTER
-------------------
signal color_munyeco: std_logic_vector(9-1 downto 0);
signal color_munyeco1: std_logic_vector(9-1 downto 0);
signal color_munyeco2: std_logic_vector(9-1 downto 0);
--Señal que controla el movimiento de las piernas de Barry
signal pasa_tiempo: std_logic;		
--Para tener en cuenta game over y pausa (no se usa)
--signal controla_pasa_tiempo: std_logic; 

-------------------
-- SEÑALES PARA LOS CHOQUES CON OBSTACULOS
-------------------
--Señales para los choques (contadores y direccion de choque)
signal i, aux_i: std_logic_vector(9 downto 0);
signal j, aux_j: std_logic_vector(7 downto 0);
signal dir_mem_choque: std_logic_vector(18-1 downto 0);

-------------------
-- RELOJES
-------------------
--Relojes a distintas velocidades
--Reloj para el control de choques con obstaculos
signal relojChoques: std_logic;
--Reloj para el control del pintado de obstaculos (no se usa)
--signal relojPintaObstaculos: std_logic; --Refresca los obstáculos
--Relojes para el movimiento del fondo y la moneda
signal relojMovFondo, relojMovFondoInter, relojMovMoneda: std_logic;
--Reloj para el control del movimiento
signal clk, relojMovimiento, relojMunyeco: std_logic;
signal clk_100M, clk_1: std_logic; --Relojes auxiliares

-------------------
-- TECLADO y BARRY
-------------------
--Para controlar si esta pulsada la barra espaciadora
signal pulsado: std_logic;
--Para controlar si esta pulsada la P para pausa
signal pausado: std_logic;
--Señal que indica si Barry se tiene que mover o no (las piernas)
signal freeze: std_logic;
--Señal que indica si Barry vuela
signal vuela: std_logic;

-------------------
-- NIVELES
-------------------
signal cambio_nivel: std_logic := '0';

-------------------
-- PAINT PARA RGB
-------------------
signal paint_game_over: std_logic;
signal paint_coin: std_logic;

-------------------
-- POSICIONES GAME OVER
-------------------
signal pos_go_y: std_logic_vector(4 downto 0);
signal pos_go_x: std_logic_vector(6 downto 0);

-------------------
-- POSICIONES FONDO
-------------------
signal posy_fondo, posy_fondoi: std_logic_vector(7 downto 0);
signal posx_fondo, posx_fondoi, cuenta_fondo, cuenta_fondo_inter: std_logic_vector(6 downto 0);

-------------------
-- CONTADOR MONEDAS
-------------------
signal cuenta_monedas, next_cuenta_monedas, save_cuenta_monedas: std_logic_vector(6 downto 0) := "0000000"; --limite_nivel (no se usa)
signal reset_monedas: std_logic := '0';
signal catched, next_catched: std_logic;







------------------------------------------------------------------------
-- COMOPONENTS
------------------------------------------------------------------------
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

--Reloj para el movimiento del inter fondo
component divisor_inter_fondo is
    port (
        reset, clk_entrada: in STD_LOGIC; 
        clk_salida: out STD_LOGIC 
    );
end component;

-- Reloj para el movimiento de las monedas
component divisor_movimiento_moneda is 
port (reset, clk_entrada: in STD_LOGIC;
		clk_salida: out STD_LOGIC);
end component;

-- Reloj para Barry
component divisor_munyeco is 
port (reset, clk_entrada: in STD_LOGIC; --ralentizar (no se usa)
		clk_salida: out STD_LOGIC
		);
end component;

--Reloj de moverse para barry (para el movimiento de piernas)
component divisor_corre is
 port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        clk_salida: out STD_LOGIC -- reloj que se utiliza en los process del programa principal
    );
end component;

-- Controlador del teclado
component control_teclado is
	port (PS2CLK, reset, PS2DATA: in std_logic;
	pulsado: out std_logic;
	pausado: out std_logic);
end component;

-- ROM con los obstaculos del nivel 1
component ROM_RGB_9b_mapa_facil is
    port (
    clk					  : in  std_logic;   -- reloj
	 bloquea				  : in std_logic; 	--señal que indica si se bloquean las primeras 256 posiciones
    addr, addr_munyeco : in  std_logic_vector(18-1 downto 0);
    dout, dout_munyeco : out std_logic
  );
end component;

-- ROM con el fondo laboratorio
component ROM_RGB_9b_lab is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(15-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

-- ROM con el fondo nubes
component ROM_RGB_9b_nubes is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(15-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

-- ROM con el fondo arboles
component ROM_RGB_9b_arboles is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(15-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

-- ROM con los obstaculos flappy (tuberias)
component ROM_RGB_9b_flappynivelBW is
  port (
    clk  				: in  std_logic;   -- reloj
	 bloquea				  : in std_logic; 	--señal que indica si se bloquean las primeras 256 posiciones
    addr, addr_munyeco  : in  std_logic_vector(18-1 downto 0);
    dout, dout_munyeco  : out std_logic 
  );
end component;

-- ROM con los obstaculo dragon ball (bolas de fuego rojas)
component ROM_RGB_9b_nivelfuegoBW is
  port (
    clk  				: in  std_logic;   -- reloj
	 bloquea				  : in std_logic; 	--señal que indica si se bloquean las primeras 256 posiciones
    addr, addr_munyeco  : in  std_logic_vector(18-1 downto 0);
    dout, dout_munyeco  : out std_logic 
  );
end component;

-- ROM de Barry Trotter (antiguo, ahora se usan barryair y barryair25)
--component ROM_RGB_9b_Joyride is
--  port (
--    clk  : in  std_logic;   -- reloj
--    addr : in  std_logic_vector(9-1 downto 0);
--    dout : out std_logic_vector(9-1 downto 0) 
--  );
--end component;

-- ROM de Barry Trotter corriendo
component ROM_RGB_9b_barryair is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

-- ROM de Barry Trotter corriendo
component ROM_RGB_9b_barryair25 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

-- ROM del Game Over
component ROM_RGB_9b_game_over_negro is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(12-1 downto 0);
    dout : out std_logic_vector(9-1 downto 0) 
  );
end component;

-- Controlador 7 segmentos
component contador is
port (var: in std_logic_vector (6 downto 0);
		displayi, displayd : out std_logic_vector (6 downto 0));
end component;

-- Generador aleatorio (para la posicion inicial de la moneda)
component randomGenerator is
port(clock      : in  STD_LOGIC;
	  userInput  : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
	  random_out : out STD_LOGIC_VECTOR(6 downto 0)
	 );
		
end component;

-- Gestiona el cambio entre niveles
component gestorCambioNivel is
	port( reset: in std_logic;
			cambio_nivel: in std_logic;
			counter: in std_logic_vector(9 downto 0);
			clk : in std_logic;
			salida_obstaculo: out std_logic);
end component;


------------------------------------------------------------------------
-- BEGIN
------------------------------------------------------------------------

begin

-------------------
-- PORT MAPs
-------------------

--Gestor que bloquea los obstáculos en las transiciones de nivel
GestorChangeLevel: gestorCambioNivel port map( reset, cambio_nivel, avanza_obstaculos, clk_1, bloquea_obstaculo);
--Controlador del teclado
Controla_teclado: control_teclado port map(PS2CLK , reset, PS2DATA, pulsado, pausado);

--Relojes auxiliares
clk_100M <= clock;
clk <= clk_1;
--Reloj para el movimiento del fondo
Reloj_de_movimiento_fondo: divisor_movimiento_fondo port map(reset, clk_100M, relojMovFondo);
Reloj_de_movimiento_inter_fondo: divisor_inter_fondo port map(reset, clk_100M, relojMovFondoInter);
--Reloj que comprueba los choques de barry
Reloj_choque: divisor_choques port map(reset, clk_100M, relojChoques);
--Reloj de refresco de la pantalla
Reloj_pantalla: divisor port map(reset, clk_100M, clk_1);
--Reloj_pantallaObstaculos: divisor port map(reset, clk_100M, relojPintaObstaculos); --(no se usa)
Reloj_munyeco: divisor_munyeco port map(reset, clk_100M, relojMunyeco); --ralentizar (no se usa)
--Reloj para el movimiento de las monedas
Reloj_de_movimiento_moneda: divisor_movimiento_moneda port map(reset, clk_100M, relojMovMoneda);
--Reloj para el movimiento de los obstaculos
Reloj_de_movimiento_obstaculos: divisor_movimiento_obstaculos port map(reset, clk_100M, relojMovimiento);
--Reloj para movimiento Simple de Barry JAIME
Corre_barry: divisor_corre port map(reset, clk_100M, pasa_tiempo);

--Rom_barry: ROM_RGB_9b_Joyride port map(clk, dir_mem_munyeco, color_munyeco);
--ROM barry corre
Rom_barrycorre: ROM_RGB_9b_barryair port map(clk, dir_mem_munyeco, color_munyeco1);
Rom_barrycorre2: ROM_RGB_9b_barryair25 port map(clk, dir_mem_munyeco, color_munyeco2);
--Game over
Rom_game_over: ROM_RGB_9b_game_over_negro port map(clk, dir_mem_game_over,imagen_game_over);


--PORT map fondo lab
Rom_fondo1: ROM_RGB_9b_lab port map(clk, dir_mem_fondo, color_fondo1);
--port map fondo nubes
Rom_fondo2: ROM_RGB_9b_nubes port map(clk, dir_mem_fondo, color_fondo2);
--port map fondo reloj
Rom_fondo3: ROM_RGB_9b_arboles port map(clk, dir_mem_fondo_inter, color_fondo3);

--PORT MAP OBSTACULOS
---Rom port map mapafacil
Romobs1: ROM_RGB_9b_mapa_facil port map(clk_1, bloquea_obstaculo,dir_mem, dir_mem_choque, salida_obstaculo1, color_choque1); 
Romobs2: ROM_RGB_9b_flappynivelBW port map(clk_1, bloquea_obstaculo, dir_mem, dir_mem_choque, salida_obstaculo2, color_choque2); 
Romobs3: ROM_RGB_9b_nivelfuegoBW port map(clk_1, bloquea_obstaculo,dir_mem, dir_mem_choque, salida_obstaculo3, color_choque3); 

--7 segmentos
SieteSeg: contador port map(cuenta_monedas, displayizq, displaydcha);
--Generador aleatorio para la posicion de inicio de la moneda
GenAleatorio: randomGenerator port map(relojMovMoneda, cuenta_fondo(3 downto 0), salida_aleatoria);



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
posy <= vcnt(7 downto 0) - 111;
posx <= hcnt - 4 + avanza_obstaculos;
dir_mem <=  posy & posx;

--Posiciones de memoria del fondo
posy_fondo <= vcnt (7 downto 0) - 111;
posx_fondo <= hcnt (8 downto 0) - 4 + cuenta_fondo;
dir_mem_fondo <=  posy_fondo & posx_fondo;

--Posiciones de memoria del fondo intermedio
posy_fondoi <= vcnt(7 downto 0) - 111;
posx_fondoi <= hcnt(6 downto 0) - 4 + cuenta_fondo_inter;
dir_mem_fondo_inter <=  posy_fondoi & posx_fondoi;

--Posiciones para el choque (ANTIGUO, no se usa)
--<= r_my - 110;				--Posicion y del choque
--posx_choque <= 40 + avanza_obstaculos; 		--Posicion x del choque
--dir_mem_choque_arriba <= posy_choque & posx_choque;  --Posicion arriba:  (4 + avanza_obstaculos, rm_y)
--dir_mem_choque_abajo <= "00" & r_my & "101000";  --Posicion abajo:   (40, 142 + rm_y) CAMBIAR
--dir_mem_choque_derecha <= "00" & r_my & "110000"; --Posicion derecha: (48, 126 + rm_y) CAMBIAR


--Posiciones de Barry Trotter
posx_munyeco <= hcnt - 32;
posy_munyeco <= vcnt - r_my;
dir_mem_munyeco <= posy_munyeco & posx_munyeco;

--Posiciones del game over
pos_go_y <= vcnt - 222;
pos_go_x <= hcnt - 68;
dir_mem_game_over <=  pos_go_y & pos_go_x;

--fondo inter conectado
fondo_inter <= fondo_inter1 and fondo_inter2;





----------------------------------------------------------------------------
--MUEVE MUNYECO, FONDO Y OBSTACULOS
----------------------------------------------------------------------------
--Process que se encarga de la gestión del avance de los obstaculos
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
		-- el reloj a usar es relojMovimienro
	end if;
end process mueve_obstaculos;


--Process que se ocupa de la gestión del avance del fondo de la pantalla
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
		-- el reloj a usar es relojMovFondo
	end if;
end process mueve_fondo;

--Process que mueve el fondo intermedio
mueve_fondo_inter: process(reset, relojMovFondoInter, estado_juego, cuenta_fondo_inter)
begin
	if reset='1' then
		cuenta_fondo_inter <= "0000000";
	elsif (relojMovFondoInter'event and relojMovFondoInter='1') then
		if estado_juego = playing then 
			cuenta_fondo_inter <= cuenta_fondo_inter + 1;
		else 
			cuenta_fondo_inter <= cuenta_fondo_inter;
		end if;
		-- el reloj a usar es relojMovFondo
	end if;
end process mueve_fondo_inter;


--Process que se encarga de actualizar estado y movimiento del munyeco
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

--Process pasa_tiempo
--Conexion control pasa_tiempo 
--controla_pasa_tiempo <= pasa_tiempo or pausado or color_choque;
--controla_pasa_tiempo(pasa_tiempo, control_pasa_tiempo, pausado, color_choque)


--Process corre munyeco 
corre_munyeco: process(vuela, color_munyeco,
							color_munyeco1, color_munyeco2,
							munyeco1, munyeco2, munyeco, freeze, pasa_tiempo)

begin
--si el munyeco esta volando debemos colorear el munyeco quieto
	if vuela = '1' or freeze = '1' then						
		color_munyeco <= color_munyeco1;	
		munyeco <= munyeco1;
	--si no alteraremos entre el quieto y el que está en movimiento
	else 
		if pasa_tiempo = '1' then
			color_munyeco <= color_munyeco1;
			munyeco <= munyeco1;
		else
			color_munyeco <= color_munyeco2;
			munyeco <= munyeco2;
		end if;
	end if;
	
end process;

--Process para el movimiento de las piernas de Barry Trotter
mov_munyeco: process(pulsado, movimiento_munyeco, r_my, vuela)
begin
	if movimiento_munyeco = quieto then
		my <= r_my;
		if pulsado = '1' and r_my <= 110 then
			vuela <= '1';
		else vuela <= '0';
		end if;
		
--		ralentizar <= '0';
--		aux_contador_sub <= (others => '0');
--		aux_contador_baj <= (others => '0');

	elsif movimiento_munyeco = arriba then
		my <= r_my-1;
		vuela <= '1';
--		ralentizar <= '0';
--		aux_contador_sub <= (others => '0');
--		aux_contador_baj <= (others => '0');	

	elsif movimiento_munyeco = abajo then
		my <= r_my+1;
		vuela <= '1';
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
		
	elsif movimiento_munyeco = fin then -- movimiento_munyeco = fin
		my <= r_my;
		vuela <= '0';
	else
		vuela <= '0';
		my <= r_my+1;
	end if;
end process mov_munyeco;


----------------------------------------------------------------------------
--LEVELS
----------------------------------------------------------------------------
--------PROCESS CON LOS NIVELES estado_nivel, sig_estado_nivel
clock_estado_nivel: process (reset, clk, sig_estado_nivel)
begin
	if reset = '1' then
		estado_nivel <= nivel1;
	elsif clk' event and clk = '1' then
		estado_nivel <= sig_estado_nivel;
	end if;
end process clock_estado_nivel;
--jajajaj
--	elsif obstaculo = '1' then rgb <= color_obstaculo;
	--elsif fondo = '1' then rgb <= color_fondo;
	
	
--Process que gestiona los niveles del juego-----------------

niveles: process(reset, clk, estado_nivel, sig_estado_nivel,
				color_fondo1, salida_obstaculo1, avanza_obstaculos, 
				salida_obstaculo2, salida_obstaculo3, color_fondo2, salida_obstaculo,
				color_choque, color_choque1, color_choque2, color_choque3,
				fondo_inter1, color_fondo3,
				cuenta_monedas)--Añadir game over
begin
	cambio_nivel <= '0';
	color_inter_fondo <= "111111111";
	if estado_nivel = nivel1 then
		fondo_inter1 <= '0';
		color_choque <= color_choque1;
		color_fondo <= color_fondo1;
		color_obstaculo <= "111111000";
		salida_obstaculo <= salida_obstaculo1;
		if cuenta_monedas = "0000101" or cuenta_monedas = "0010100" or cuenta_monedas = "0100011" or cuenta_monedas = "0110010" then
			sig_estado_nivel <= nivel2;
			cambio_nivel <= '1';
		else sig_estado_nivel <= estado_nivel;
		end if;
	elsif estado_nivel = nivel2 then
		fondo_inter1 <= '0';
		color_choque <= color_choque2;
		color_fondo <= color_fondo1;
		color_obstaculo <= "000111000";
		salida_obstaculo <= salida_obstaculo2;
		if cuenta_monedas = "0001010" or cuenta_monedas = "0011001" or cuenta_monedas = "0101000" or cuenta_monedas = "0110111"  then
			sig_estado_nivel <= nivel3;
			cambio_nivel <= '1';
		else sig_estado_nivel <= estado_nivel;
		end if;
	else-- estado_nivel = nivel3 then
		color_choque <= color_choque3;
		color_fondo <= color_fondo2;
		if color_fondo3 = "111111111" then 
			fondo_inter1 <= '0';
		else
			fondo_inter1 <= '1';
			color_inter_fondo <= color_fondo3;
		end if;
		color_obstaculo <= "111000000";
		salida_obstaculo <= salida_obstaculo3;
		if cuenta_monedas = "0001111" or cuenta_monedas = "0011110" or cuenta_monedas = "0101101"  then
--			limite_nivel <= limite_nivel + "0001111";
			sig_estado_nivel <= nivel1;
			cambio_nivel <= '1';
		else sig_estado_nivel <= estado_nivel;
		end if;
	--elsif estado_nivel = nivel4 then
	
	--elsif estado_nivel = nivel5 then
	
	end if;

end process niveles;


------Controlador de los estados del juego
clock_estado_juego: process (reset, clk)
begin
	if reset = '1' then
		estado_juego <= playing;
	elsif clk' event and clk = '1' then
		estado_juego <= next_estado_juego;
	end if;
end process clock_estado_juego;

--Process que gestiona el cambio de estado del juego

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





----------------------------------------------------------------------------
--MOVIMIENTO BARRY (piernas)
----------------------------------------------------------------------------
estado_munyeco:process(hcnt, vcnt, r_my, pulsado, color_obstaculo, color_choque, 
								movimiento_munyeco, estado_juego
								, freeze)
begin
	if estado_juego = game_over then
		next_movimiento <= fin;
		freeze <= '1';
	elsif estado_juego = pause then
		next_movimiento <= fin;
		freeze <= '1';
	elsif r_my <= 110 then 
		freeze <= '0';
		if pulsado = '1' then
			next_movimiento <= quieto;
		else 
--			next_movimiento <= flotar;
			next_movimiento <= abajo;
		end if;
	elsif r_my >= 302 then
		freeze <= '0';
		if pulsado = '0' then
			next_movimiento <= quieto;
		else 
--			next_movimiento <= acelerar;
			next_movimiento <= arriba;
		end if;
	elsif pulsado = '1' then
		freeze <= '0';
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
		freeze <= '0';
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





----------------------------------------------------------------------------
--CHOQUES
----------------------------------------------------------------------------
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





----------------------------------------------------------------------------
--PINTAR: Gestiona el fondo y los obstáculos
----------------------------------------------------------------------------
pinta_obstaculos: process(hcnt, vcnt, salida_obstaculo)
begin
	obstaculo <= '0';
	fondo <= '0';
	fondo_inter2 <= '0';
	--color_obstaculo <= "111111111";
	if hcnt > 4 and hcnt <= 260 and vcnt > 110 and vcnt <= 366 then--TODO mirar si se puede conectar directamente JAIME
		if salida_obstaculo = '1' then 
			--color_obstaculo <= "111111000";
			obstaculo <= '1';
			--fondo <= '0';
		else fondo <= '1';
			fondo_inter2 <= '1';
		end if;
	end if;
end process pinta_obstaculos;


-- pinta bordes: Pinta los limites de la pantalla
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


--pinta a barry corriendo(munyeco1 y 2) JAIME
pinta_munyeco1: process(hcnt, vcnt, r_my, color_munyeco1)
begin
	munyeco1 <= '0';
	if hcnt >= 32 and hcnt < 48 then
		if vcnt >= r_my and vcnt < r_my+32 then
			if color_munyeco1 = "111111111" then
				munyeco1<='0';
			else munyeco1 <='1';
			end if;
		end if;
	end if;
end process pinta_munyeco1;


pinta_munyeco2: process(hcnt, vcnt, r_my, color_munyeco2)
begin
	munyeco2 <= '0';
	if hcnt >= 32 and hcnt < 48 then
		if vcnt >= r_my and vcnt < r_my+32 then
			if color_munyeco2 = "111111111" then
				munyeco2<='0';
			else munyeco2 <='1';
			end if;
		end if;
	end if;
end process pinta_munyeco2;


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


--Process encargado de pintar las monedas y modificar estados_monedas
pinta_moneda: process(state_coin, hcnt, vcnt, posx_moneda, posy_moneda)
begin 
	paint_coin <= '0';
	if hcnt >= posx_moneda and hcnt <= posx_moneda + 4 then 
		if vcnt >= posy_moneda and vcnt <= posy_moneda + 8 then
			if state_coin = bajando or state_coin = subiendo or state_coin = quieto then
				paint_coin <= '1';
			else 
				paint_coin <= '0';
			end if;
		end if;
	end if;
end process pinta_moneda;




----------------------------------------------------------------------------
--MONEDA
----------------------------------------------------------------------------

inicio_aleatorio_moneda <= salida_aleatoria+1;
--Hace avanzar a la moneda, tanto hacia arriba como hacia abajo
mueve_moneda: process (relojMovMoneda, reset, avanza_obstaculos, inicio_aleatorio_moneda)
begin
	if reset = '1' then
		reset_monedas <= '1';
		posy_moneda <= inicio_aleatorio_moneda+150;--"0011000000"; -- 192 en decimal
		posx_moneda <= "0100000000"; -- 256 en decimal
		state_coin <= bajando;
		--catched <= '0';
		cuenta_monedas <= "0000000";
	elsif RelojMovMoneda'event and RelojMovMoneda = '1' then 
		reset_monedas <= '0';
		cuenta_monedas <= save_cuenta_monedas;
		save_cuenta_monedas <= next_cuenta_monedas;
		posy_moneda <= next_posy_moneda;
		posx_moneda <= next_posx_moneda;
		state_coin <= next_state_coin;
		catched <= next_catched;
	end if;
end process;


estado_moneda: process(avanza_obstaculos, state_coin, posy_moneda, 
					posx_moneda, estado_juego, paint_coin, munyeco, 
					save_cuenta_monedas, cuenta_monedas, reset_monedas, catched)
begin                                                                  
	--Tenemos un latch simpático aquí para catched y otro para cuenta_monedas.
	if reset_monedas = '1' then
		next_cuenta_monedas <= "0000000";
		next_state_coin <= bajando;
	elsif avanza_obstaculos = "1111111111" then
		next_catched <= '0';
		next_state_coin <= bajando;
	elsif catched = '1' then 
		next_state_coin <= invisible;
	elsif state_coin = invisible then
		next_catched <= '1';
		next_state_coin <= state_coin;
	elsif state_coin = subiendo and posy_moneda <= 115 then
		next_state_coin <= bajando;
	elsif state_coin = bajando and posy_moneda >= 310 then
		next_state_coin <= subiendo;
	elsif posx_moneda <= 5 then
		next_state_coin <= invisible;
	elsif estado_juego = pause and state_coin /= invisible then
		next_state_coin <= quieto;
	elsif estado_juego = playing and state_coin = quieto then
		next_state_coin <= bajando;
	elsif paint_coin = '1' and munyeco = '1' and catched = '0' then
		next_catched <= '1';
		next_state_coin <= invisible;
		next_cuenta_monedas <= cuenta_monedas + 1;
	else 
		next_state_coin <= state_coin;
	end if;
end process estado_moneda;

--Process que modifica lo que hace la moneda en función de sus estados
direccion_moneda:process(state_coin, posy_moneda, posx_moneda, avanza_obstaculos, inicio_aleatorio_moneda)
begin
	if avanza_obstaculos = "1111111111"then
		next_posy_moneda <=  inicio_aleatorio_moneda+150;
		next_posx_moneda <= "0100000000"; -- 256 en decimal
	elsif state_coin = invisible or state_coin = quieto then
		next_posy_moneda <= posy_moneda;
		next_posx_moneda <= posx_moneda;
	elsif state_coin = subiendo then
		next_posy_moneda <= posy_moneda-2;
		next_posx_moneda <= posx_moneda-1;
	elsif state_coin = bajando then
		next_posy_moneda <= posy_moneda+2;
		next_posx_moneda <= posx_moneda-1;
	else 
		next_posy_moneda <= posy_moneda;
		next_posx_moneda <= posx_moneda;
	end if;
end process direccion_moneda;





----------------------------------------------------------------------------
--COLOREAR
----------------------------------------------------------------------------
colorear: process(hcnt, vcnt, obstaculo, color_obstaculo, bordes, munyeco,
		color_munyeco, paint_game_over, imagen_game_over, fondo, color_fondo,
		fondo_inter, color_inter_fondo, paint_coin)
begin
	if bordes = '1' then rgb <= "110110000";
	elsif paint_game_over = '1' then rgb <= imagen_game_over;
	elsif munyeco = '1' then rgb <= color_munyeco;
	elsif paint_coin = '1' 		 then 	rgb <= "000111000";
	elsif obstaculo = '1' then rgb <= color_obstaculo;
	elsif fondo_inter = '1' then rgb <= color_inter_fondo;
	elsif fondo = '1' then rgb <= color_fondo;
	else rgb <= "000000000";
	end if;
end process colorear;



end vgacore_arch;