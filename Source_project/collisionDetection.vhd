library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity collisionDetection is 
port( clock    	  : in  STD_LOGIC;
	   reset			  : in  STD_LOGIC;
		objectColor	  : in  STD_LOGIC_VECTOR(7 downto 0);
		backColor	  : in  STD_LOGIC_VECTOR(7 downto 0);
		xPixel 		  : in  UNSIGNED (9 downto 0);
		yPixel 		  : in  UNSIGNED (8 downto 0);
		frogXa     	  : in  UNSIGNED (9 downto 0);
		frogXb     	  : in  UNSIGNED (9 downto 0);
		frogYa     	  : in  UNSIGNED (8 downto 0);
		frogYb     	  : in  UNSIGNED (8 downto 0);
		frogRow    	  : in  UNSIGNED (3 downto 0);
		isDead     	  : out STD_LOGIC;
		isOnLog    	  : out STD_LOGIC;
		frogReset	  : out STD_LOGIC;
		win			  : out STD_LOGIC
	 );

end collisionDetection;

Architecture behavioral of collisionDetection is

signal corner1_color : STD_LOGIC_VECTOR(7 downto 0);
signal corner2_color : STD_LOGIC_VECTOR(7 downto 0);
signal corner3_color : STD_LOGIC_VECTOR(7 downto 0);
signal corner4_color : STD_LOGIC_VECTOR(7 downto 0);
signal bg1_color		: STD_LOGIC_VECTOR(7 downto 0);
signal bg2_color		: STD_LOGIC_VECTOR(7 downto 0);
signal bg3_color		: STD_LOGIC_VECTOR(7 downto 0);
signal bg4_color		: STD_LOGIC_VECTOR(7 downto 0);
signal reset_timer 	: STD_LOGIC;
signal cntr			 	: UNSIGNED (27 downto 0);

TYPE state IS (onGrass_state, onRoad_state,onRiver_state, win_state, dead_state);
signal m_state   : STATE;						--Current FSM state
signal next_state: STATE;					--Next FSM state
constant MaxCounter: UNSIGNED (27 downto 0) := x"2FAF080";

constant black : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; -- bbgggrrr
constant brown : STD_LOGIC_VECTOR(7 downto 0) := "00010100";
constant green : STD_LOGIC_VECTOR(7 downto 0) := "00111000";
constant blue  : STD_LOGIC_VECTOR(7 downto 0) := "11000000";

begin

	process(clock, reset)
	begin
		if reset='1' then
			corner1_color <= (others=>'0');
			corner2_color <= (others=>'0');
			corner3_color <= (others=>'0');
			corner4_color <= (others=>'0');
		elsif rising_edge(clock) then
			if (xPixel=frogXa and yPixel=frogYa) then
				corner1_color <= objectColor;
				bg1_color <= backColor;
			elsif (xPixel=frogXa and yPixel=frogYb) then
				corner2_color <= objectColor;
				bg2_color <= backColor;
			elsif (xPixel=frogXb and yPixel=frogYa) then
				corner3_color <= objectColor;
				bg3_color <= backColor;
			elsif (xPixel=frogXb and yPixel=frogYb) then
				corner4_color <= objectColor;
				bg4_color <= backColor;
			end if;
		end if;
	end process;
	
	--Output Signals
	isDead <= '1' when (m_state=dead_state) and (cntr < MaxCounter) else
				 '0';
				 
	isOnLog <= '1' when ((m_state=onRiver_state) and (corner1_color/=black or corner2_color/=black or corner3_color/=black or corner4_color/=black)) else
				  '0';
				  
	frogReset<= '1' when (m_state=dead_state and (cntr=MaxCounter)) or (m_state=win_state and (cntr=MaxCounter)) else
					'0';
			win<= '1' when (m_state=win_state and cntr=MaxCounter) else
					'0';

	--State register
	process(clock,reset)
	begin
		if (reset='1') then
			m_state <= onGrass_state;
		elsif (rising_edge(clock)) then
			m_state <= next_state;
		end if;
	end process;
	
	--FSM
	Process (cntr, m_state, corner1_color, corner2_color,corner3_color,corner4_color,bg1_color,bg2_color,bg3_color,bg4_color,frogRow) 
	begin
		next_state <= m_state;
		case m_state is
			when onGrass_state =>
				if (bg1_color=black and bg2_color=black and bg3_color=black and bg4_color=black) then
					next_state <= onRoad_state;
				elsif (bg1_color=blue and bg2_color=blue and bg3_color=blue and bg4_color=blue) then
					next_state <= onRiver_state;
				else
					next_state <= onGrass_state;
				end if;
			when onRoad_state =>
				if (corner1_color/=black or corner2_color/=black or corner3_color/=black or corner4_color/=black) then
					next_state<= dead_state;
				elsif (bg1_color=green and bg2_color=green and bg3_color=green and bg4_color=green) then
					next_state <= onGrass_state;
				else
					next_state <= onRoad_state;
				end if;
			when dead_state =>
				if (cntr >= MaxCounter) then
					next_state <= onGrass_state;
				else
					next_state <= dead_state;
				end if;
			when onRiver_state =>
				if (bg1_color=green or bg2_color=green or bg3_color=green or bg4_color=green) and (frogRow=x"0") then
					next_state <= win_state;
				elsif	(bg1_color=green and bg2_color=green and bg3_color=green and bg4_color=green) then
					next_state <= onGrass_state;
				elsif (corner1_color=black and corner2_color=black and corner3_color=black and corner4_color=black) then
					next_state <= dead_state;
				else
					next_state <= onRiver_state;
				end if;
			when win_state =>
				if (cntr >= MaxCounter) then
					next_state <= onGrass_state;
				else
					next_state <= win_state;
				end if;
		end case;
	end process;


--Timer
	process (clock, reset)
	begin
		if reset='1' then
			cntr <= (others=>'0');
		elsif rising_edge(clock) then
			if (reset_timer='1') then
				cntr <= (others=>'0');
			else
				cntr <= cntr + 1;
			end if;
		end if;
	end process;
	
reset_timer <='0' when (m_state=dead_state or m_state=win_state) and (cntr/=MaxCounter) else '1';		
					
end behavioral;