library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity frogger_top is 
port(clock    	    : in  STD_LOGIC;
	  kbClock       : in STD_LOGIC;
	  kbData        : in STD_LOGIC;
	  pushButtons   : in  STD_LOGIC_VECTOR(3 downto 0);
	  sliderSwitch  : in  STD_LOGIC_VECTOR(7 downto 0); 
	  horizontalSync : out STD_LOGIC;
	  verticalSync   : out STD_LOGIC;
	  pixelColor	  : out STD_LOGIC_VECTOR(7 downto 0);
	  anodes			  : out STD_LOGIC_VECTOR(3 downto 0);
	  enc_char		  : out STD_LOGIC_VECTOR(6 downto 0)
	 );

end frogger_top;


architecture Behavioral of frogger_top is
	
	constant black : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; -- bbgggrrr
	constant brown : STD_LOGIC_VECTOR(7 downto 0) := "00010100";
	constant green : STD_LOGIC_VECTOR(7 downto 0) := "00111000";
	constant blue  : STD_LOGIC_VECTOR(7 downto 0) := "11000000";
	
	signal reset        : STD_LOGIC;
	signal userReset    : STD_LOGIC;
	signal resetCount   : NATURAL;
	signal frogReset    : STD_LOGIC;
	signal frogResetOrReset : STD_LOGIC;
	signal gameResetOrReset : STD_LOGIC;
	
	signal backColor   : STD_LOGIC_VECTOR(7 downto 0);
	signal objectColor : STD_LOGIC_VECTOR(7 downto 0);
	signal frogColor   : STD_LOGIC_VECTOR(7 downto 0);

	signal moveUp    : STD_LOGIC;
	signal moveDown  : STD_LOGIC;
	signal moveLeft  : STD_LOGIC;
	signal moveRight : STD_LOGIC;
	
	signal moveUpKB    : STD_LOGIC;
	signal moveDownKB  : STD_LOGIC;
	signal moveLeftKB  : STD_LOGIC;
	signal moveRightKB : STD_LOGIC;
	
	signal moveUpBT    : STD_LOGIC;
	signal moveDownBT  : STD_LOGIC;
	signal moveLeftBT  : STD_LOGIC;
	signal moveRightBT : STD_LOGIC;
	
	signal level : STD_LOGIC_VECTOR(1 downto 0);
	
	signal isDead     : STD_LOGIC;
	signal isOnLog    : STD_LOGIC;
	signal frogXa     : UNSIGNED (9 downto 0);
	signal frogXb     : UNSIGNED (9 downto 0);
	signal frogYa     : UNSIGNED (8 downto 0);
	signal frogYb     : UNSIGNED (8 downto 0);
	signal frogRow    : UNSIGNED (3 downto 0);
	signal rowSpeed   : UNSIGNED (2 downto 0);
	signal rowDirection : STD_LOGIC;
	
	signal xPixel : UNSIGNED (9 downto 0);
	signal yPixel : UNSIGNED (8 downto 0);
	signal inVisibleArea : STD_LOGIC;
	signal update : STD_LOGIC;
	
	signal win	  		: STD_LOGIC;
	signal totalScore : integer;
	
begin	

	---------------------------------------------------------------------------------------------
	-- Connect inputs
	-----------------
	
	-- Link incoming push buttons to Debouncer-Enabelers.
	debounce_Reset     : entity debounce port map (clock => clock, reset => '0', x => sliderSwitch(7), x_out => userReset ); -- Reset

	debounceSpeed1 : entity debounce	port map (clock => clock, reset => '0', x => sliderSwitch(1), x_out => level(1) ); -- Speed 1
	debounceSpeed0 : entity debounce	port map (clock => clock, reset => '0', x => sliderSwitch(0), x_out => level(0) ); -- Speed 0


	-- Debounce the button inputs
	debounceE_Up    : entity debounceEnableHigh port map (clock => clock, reset => reset, x => pushButtons(0), x_pulse => moveUpBT ); -- Move Up	 
	debounceE_Down  : entity debounceEnableHigh port map (clock => clock, reset => reset, x => pushButtons(1), x_pulse => moveDownBT ); -- Move Down
	debounceE_Right : entity debounceEnableHigh port map (clock => clock, reset => reset, x => pushButtons(2), x_pulse => moveRightBT ); -- Move Right	 
	debounceE_Left  : entity debounceEnableHigh port map (clock => clock, reset => reset, x => pushButtons(3), x_pulse => moveLeftBT ); -- Move Left

	
	-- Get the keboard arrow movements
	froggerKeyboard1 : entity froggerKeyboard 
	port map(clock => clock,
				reset => reset,
				kbData => kbData,
				kbClock => kbClock,
				
				moveUp_out => moveUpKB,
				moveDown_out => moveDownKB,
				moveRight_out => moveRightKB,
				moveLeft_out => moveLeftKB	
			  );
	
	-- react to either the keybaord or the button presses.
	moveUp <= moveUpKB or moveUpBT;
	moveDown <= moveDownKB or moveDownBT;
	moveRight <= moveRightKB or moveRightBT;
	moveLeft <= moveLeftKB or moveLeftBT;

	
	---------------------------------------------------------------------------------------------
	-- initial reset line
	-----------------
	process (clock)
	begin
		if (rising_edge(clock)) then
		
			if (resetCount < 20) then
				reset <= '1';
				resetCount <= resetCount + 1;
			elsif (userReset = '1') then
				reset <= '1';
			else
				reset <= '0';
			end if;
			
		end if;
	end process;
	
	
	---------------------------------------------------------------------------------------------
	-- Logic
	-----------------
	vgaSyncGenerator1: entity vgaSyncGenerator 
		port map(clock  => clock, 
					reset  => reset,
					hSync  => horizontalSync,
					vSync  => verticalSync,
					inVisibleArea => inVisibleArea,
					update => update,
					xPixel => xPixel,
					yPixel => yPixel
		        );
				
	frogResetOrReset <= reset or frogReset;
	gameResetOrReset <= reset or win;
	
	frogLocation1: entity frogLocation
		port map(clock => clock,
					 reset     => frogResetOrReset,
					 moveUp    => moveUp,
					 moveDown  => moveDown,     
					 moveRight => moveRight,
					 moveLeft  => moveLeft,
					 update    => update,
					 isDead    => isDead,
					 isOnLog   => isOnLog,
					 rowDirection => rowDirection,
					 rowSpeed  => rowSpeed,
					 frogXaOut  => frogXa,
					 frogXbOut  => frogXb,
					 frogYaOut  => frogYa,
					 frogYbOut  => frogYb,
					 frogRowOut => frogRow
				);

	backGroundGenerator1: entity backGroundGenerator 
		port map(clock     => clock, 
					reset     => reset,
					xPixel    => xPixel,
					yPixel    => yPixel,
					backColor => backColor
		        );
				  	
	objects1: entity objects
		port map(clock    => clock, 
					reset    => gameResetOrReset,
					update   => update,
					xPixel   => xPixel,
					yPixel   => yPixel,	
					userInput => moveUp,
					level    => level,
					frogRow  => frogRow,
					rowSpeed => rowSpeed,
					rowDirection => rowDirection,
					colorOut => objectColor
		        );
				  
				  
	frogGenerator1: entity frogGenerator
		port map (clock  => clock, 
					 reset  => frogResetOrReset,
					 xPixel => xPixel,
					 yPixel => yPixel, 
					 update => update,
					 isDead => isDead,
					 frogXa => frogXa,
					 frogXb => frogXb,
					 frogYa => frogYa,
					 frogYb => frogYb,
					 frogColorOut => frogColor
					);
	
				  	
	
	process(clock, reset)
	begin
		if (reset = '1') then
			pixelColor <= black;
			
		elsif (rising_edge(clock)) then
			
			if (inVisibleArea = '1') then
			
				if    (frogColor   /= black) then 
					pixelColor <= frogColor;	
				elsif (objectColor /= black) then 
					pixelColor <= objectColor;
				else   
					pixelColor <= backColor;
				end if;
				
			else
				pixelColor <= black;
			end if;
			
		end if;
	end process;
	


	collisionDection1: entity collisionDetection 
		port map( clock => clock, 
					reset => reset,
					objectColor => objectColor,
					backColor => backColor,
					xPixel => xPixel,
					yPixel => yPixel,
					frogXa => frogXa,
					frogXb => frogXb,
					frogYa => frogYa,
					frogYb => frogYb,
					frogRow => frogRow,
					isDead  => isDead,
					isOnLog => isOnLog,
					frogReset => frogReset,
					win		 => win
					);
				
	score0:	entity score
		port map( clock => clock,
					reset => reset,
					level => level,
					win   => win,
					frogRow => frogRow,
					totalScore => totalScore
					);
	
	seg7_driver0: entity seg7_driver
		port map(clock 	  => clock,
					reset 	  => reset,
					totalScore => totalScore,
					anodes	  => anodes,
					enc_char	  => enc_char
					);
		
end Behavioral;