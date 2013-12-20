library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity objects is
port( clock     : in STD_LOGIC;
	   reset     : in STD_LOGIC;
	   update    : in STD_LOGIC;
	   xPixel    : in UNSIGNED (9 downto 0);
	   yPixel    : in UNSIGNED (8 downto 0);
	   level     : in STD_LOGIC_VECTOR (1 downto 0);
		userInput : in STD_LOGIC;
	   frogRow   : in UNSIGNED(3 downto 0);
	   colorOut     : out STD_LOGIC_VECTOR(7 downto 0);
	   rowSpeed     : out UNSIGNED (2 downto 0);
	   rowDirection : out STD_LOGIC
	);
		
end objects;


architecture Behavioral of objects is

	signal color_1 : STD_LOGIC_VECTOR(7 downto 0);
	signal color_2 : STD_LOGIC_VECTOR(7 downto 0);
	signal color_3 : STD_LOGIC_VECTOR(7 downto 0);
	signal color_4 : STD_LOGIC_VECTOR(7 downto 0);
	signal color_5 : STD_LOGIC_VECTOR(7 downto 0);
	signal color_6 : STD_LOGIC_VECTOR(7 downto 0);
	
	signal color_8 : STD_LOGIC_VECTOR(7 downto 0);
	signal color_9 : STD_LOGIC_VECTOR(7 downto 0);
	signal color_A : STD_LOGIC_VECTOR(7 downto 0);
	signal color_B : STD_LOGIC_VECTOR(7 downto 0);
	signal color_C : STD_LOGIC_VECTOR(7 downto 0);
	signal color_D : STD_LOGIC_VECTOR(7 downto 0);

	signal rowSpeed1 : UNSIGNED (2 downto 0);
	signal rowSpeed2 : UNSIGNED (2 downto 0);
	signal rowSpeed3 : UNSIGNED (2 downto 0);
	signal rowSpeed4 : UNSIGNED (2 downto 0);
	signal rowSpeed5 : UNSIGNED (2 downto 0);
	signal rowSpeed6 : UNSIGNED (2 downto 0);
	
	signal rowDirection1 : STD_LOGIC;
	signal rowDirection2 : STD_LOGIC;
	signal rowDirection3 : STD_LOGIC;
	signal rowDirection4 : STD_LOGIC;
	signal rowDirection5 : STD_LOGIC;
	signal rowDirection6 : STD_LOGIC;
		
	signal randomStream : STD_LOGIC_VECTOR(11 downto 0);
	
	signal randomStream1 : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStream2 : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStream3 : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStream4 : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStream5 : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStream6 : STD_LOGIC_VECTOR(11 downto 0);
	
	signal randomStream8 : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStream9 : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStreamA : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStreamB : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStreamC : STD_LOGIC_VECTOR(11 downto 0);
	signal randomStreamD : STD_LOGIC_VECTOR(11 downto 0);
	
	signal levelAtStart  : STD_LOGIC_VECTOR (1 downto 0);
	
begin


	randomGenerator1 : entity randomGenerator 
		port map(clock  => clock, 
				 userInput => userInput,
				 random_out => randomStream
		        );

	process(clock)
	begin
		if (rising_edge(clock)) then
			
			randomStream1 <= randomStream(11 downto 0);
			randomStream2 <= randomStream(10 downto 0) & randomStream(11);
			randomStream3 <= randomStream( 9 downto 0) & randomStream(11 downto 10);
			randomStream4 <= randomStream( 8 downto 0) & randomStream(11 downto  9);
			randomStream5 <= randomStream( 7 downto 0) & randomStream(11 downto  8);
			randomStream6 <= randomStream( 6 downto 0) & randomStream(11 downto  7);
			
			randomStream8 <= randomStream( 5 downto 0) & randomStream(11 downto  6);
			randomStream9 <= randomStream( 4 downto 0) & randomStream(11 downto  5);
			randomStreamA <= randomStream( 3 downto 0) & randomStream(11 downto  4);
			randomStreamB <= randomStream( 2 downto 0) & randomStream(11 downto  3);
			randomStreamC <= randomStream( 1 downto 0) & randomStream(11 downto  2);
			randomStreamD <= randomStream( 0 downto 0) & randomStream(11 downto  1);
			
			if (frogRow = x"E") then
				levelAtStart <= level;
			end if;
			
			
		end if;
	end process;
	
	
	-- Logs lane 1
	object_row1 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"1",
				 randomStream => randomStream1,
				 rowSpeed => rowSpeed1,
				 rowDirection => rowDirection1,
				 colorOut  => color_1
		        );
	
	-- Logs lane 2
	object_row2 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"2",
				 randomStream => randomStream2,
				 rowSpeed => rowSpeed2,
				 rowDirection => rowDirection2,
				 colorOut  => color_2
		        );
	
	-- Logs lane 3
	object_row3 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"3",
				 randomStream => randomStream3,
				 rowSpeed => rowSpeed3,
				 rowDirection => rowDirection3,
				 colorOut  => color_3
		        );
	
	-- Logs lane 4
	object_row4 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"4",
				 randomStream => randomStream4,
				 rowSpeed => rowSpeed4,
				 rowDirection => rowDirection4,
			     colorOut  => color_4
		        );
				
	-- Logs lane 5
	object_row5 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"5",
				 randomStream => randomStream5,
				 rowSpeed => rowSpeed5,
				 rowDirection => rowDirection5,
			     colorOut  => color_5
		        );	
				 
	-- Logs lane 6
	object_row6 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"6",
				 randomStream => randomStream6,
				 rowSpeed => rowSpeed6,
				 rowDirection => rowDirection6,
			     colorOut  => color_6
		        );
				  
	rowSpeed <= rowSpeed1 when frogRow = x"1" else
					rowSpeed2 when frogRow = x"2" else
					rowSpeed3 when frogRow = x"3" else
					rowSpeed4 when frogRow = x"4" else
					rowSpeed5 when frogRow = x"5" else
					rowSpeed6 when frogRow = x"6" else
					"000";
									  
	rowDirection <= rowDirection1 when frogRow = x"1" else
					rowDirection2 when frogRow = x"2" else
					rowDirection3 when frogRow = x"3" else
					rowDirection4 when frogRow = x"4" else
					rowDirection5 when frogRow = x"5" else
					rowDirection6 when frogRow = x"6" else
					'0';
	
	-- Cars lane 8
	object_row8 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"8",
				 randomStream => randomStream8,
			     colorOut  => color_8
		        );
				 
	-- Cars lane 9
	object_row9 : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"9",
				 randomStream => randomStream9,
			     colorOut  => color_9
		        );
				  
	-- Cars lane A
	object_rowA : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"A",
				 randomStream => randomStreamA,
			     colorOut  => color_A
		        );
				 
	-- Cars lane B
	object_rowB : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"B",
				 randomStream => randomStreamB,
			     colorOut  => color_B
		        );
				  
	-- Cars lane C
	object_rowC : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"C",
				 randomStream => randomStreamC,
			     colorOut  => color_C
		        );
				
	-- Cars lane D
	object_rowD : entity objectGenerator 
		port map(clock  => clock, reset  => reset, update => update, level => levelAtStart, xPixel => xPixel, yPixel => yPixel,
				 row       => x"D",
				 randomStream => randomStreamD,
			     colorOut  => color_D
		        );
				  				  	

	
				  
	colorOut <= (others => '0') when reset = '1' else   
					color_1 or color_2 or color_3 or color_4 or color_5 or color_6 
				or color_8 or color_9 or color_A or color_B or color_C or color_D;



end Behavioral;

