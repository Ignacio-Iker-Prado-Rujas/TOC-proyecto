-- ESBOZO DEL PROCESS PARA COMPROBAR LOS CHOQUES	

Rom: ROM_RGB_9b_nivel_1_0 port map(clk, clk_100M, dir_mem, dir_mem_choque, color, color_choque);

--------------------------------------------------------------------------------------------------------
comprueba_choques: process(relojMovimiento, clk_100M, cuenta_pantalla, r_my)
begin
	if (relojMovimiento'event and relojMovimiento = '1') then
		if 0 <= contador <= 50 then 
			if clk_100M'event and clk_100M = '1' then
				contador <= contador + 1; -- Habria que poner un contador_aux
				if contador = '0' then 
					dir_mem_choque = pixel_choque1; --se calcula manualmente, no es una señal
				elsif contador = '1' then 
					dir_mem_choque = pixel_choque2; --se calcula manualmente, no es una señal
				end if;
			end if;
		end if;			
	end if;
end process comprueba_choques;
--------------------------------------------------------------------------------------------------------
--MAQUINA ESTADOS KIKE:
--
--estado1 := if (relojMovimiento'event and relojMovimiento = '1') then paso a estado2
--estado2 := if (clk_100M'event and clk_100M = '1'){
--					if  (0 <= contador <= 50) then incrementa y comprueba pixel correspondiente
--			 		else pasa a estado1
--------------------------------------------------------------------------------------------------------
-- VERSION SIN ESTADOS:

--1: Version pseudocodigo
i = 28;
j = r_my-106;
while(28 <= i <= 41) 
	while(r_my-106 <= j <= r_my-80)
		if(j & (i + cuenta_pantalla) = amarillo)	
			encontrado := 1;
			
--2: La ROM 
Rom: ROM_RGB_9b_nivel_1_0 port map(clk, dir_mem, dir_mem_choque, color, color_choque); --QUITAR UN RELOJ
			
--3: Donde corresponda
if(relojMunyeco'event and relojMunyeco = '1') then
	activar_barrido = '1';
			
--4: Process nuevo
comprueba_choques: process(relojMunyeco, cuenta_pantalla, r_my)
begin
	if(activar_barrido = '1') then
		for i in 28 to 41 loop
			for j in r_my-106 to r_my-80 loop
				if(clk'event and clk = '1') then
					dir_mem_choque <= j & (i + cuenta_pantalla);
					if color_choque = "111111000" then -- Amarillo = Obstaculo
						game_over <= '1';
					else 
						game_over <= game_over OR '0';
					end if;
				end if;
			end loop;
		end loop;
	end if;
end process comprueba_choques;
			
--5: A–adir el cambio de estados
estado_munyeco:process(hcnt, vcnt, r_my, pulsado, color, color_choque, movimiento_munyeco, contador_sub, contador_baj)
begin
	if game_over = '1'; then
		next_movimiento <= fin;
	end if;
	
	-- Falta lo demas...
	
end process comprueba_choques;
--------------------------------------------------------------------------------------------------------
-- VERSION CON ESTADOS, parece la buena, NO TOCAR, CONSULTAR CON KIKE O IKER O KIKER

--1: La ROM, QUITAR UN RELOJ
Rom: ROM_RGB_9b_nivel_1_0 port map(clk, dir_mem, dir_mem_choque, color, color_choque); 
			
--2: Process de los estados
state_choques: process(clk, cuenta_pantalla, r_my)
begin
	if(clk'event and clk = '1') then
		state <= next_state;
	end if;
end process state_choques;
		
--3: Process combinacional
comprueba_choques: process(cuenta_pantalla, r_my)
begin
	dir_mem_choque <= j & (i + cuenta_pantalla);
	if color_choque = "111111000" then -- Amarillo = Obstaculo
		game_over <= '1';
	else 
		game_over <= game_over OR '0';
	end if;

	if(state = inicializa) then
		i <= 28;
		j <= r_my-106;
		--if(relojMunyeco'event and relojMunyeco = '1') --Para no estar siempre comprobando se podria a–adir este if, PREGUNTAR A MARCOS	
			next_state <= comprueba_cabeza;	
	elsif(state = comprueba_cabeza)
		if(i <= 41) then
			i <= i + 1;
			next_state = comprueba_cabeza;
		else
			next_state = comprueba_frente;
	elsif(state = comprueba_frente)
		if(j <= r_my-80) then
			j <= j + 1;
			next_state = comprueba_frente;
		else
			next_state = comprueba_pies;
	elsif(state = comprueba_pies)
		if(i >= 28) then
			i <= i - 1;
			next_state = comprueba_pies;
		else
			next_state = inicializa;
	end if;
end process comprueba_choques;

--4: A–adir el cambio de estados
estado_munyeco:process(hcnt, vcnt, r_my, pulsado, color, color_choque, movimiento_munyeco, contador_sub, contador_baj)
begin
	if game_over = '1'; then
		next_movimiento <= fin;
	end if;
	
	-- Falta lo demas...
	
end process comprueba_choques;