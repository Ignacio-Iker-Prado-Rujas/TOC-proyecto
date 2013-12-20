library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity objectGenerator is
port( clock         : in STD_LOGIC;
	   reset        : in STD_LOGIC;
	   update       : in STD_LOGIC;
	   level        : in STD_LOGIC_VECTOR (1 downto 0);
	   row          : in UNSIGNED (3 downto 0);
	   xPixel       : in UNSIGNED (9 downto 0);
	   yPixel       : in UNSIGNED (8 downto 0);
	   randomStream : in STD_LOGIC_VECTOR (11 downto 0);
	   rowSpeed     : out UNSIGNED (2 downto 0);
	   rowDirection : out STD_LOGIC;
	   colorOut     : out STD_LOGIC_VECTOR (7 downto 0)
		);
		
end objectGenerator;


architecture Behavioral of objectGenerator is

	constant black : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
	constant brown : STD_LOGIC_VECTOR(7 downto 0) := "00010100";
		
	constant left  : STD_LOGIC := '0';
	constant right : STD_LOGIC := '1';
	
	signal direction : STD_LOGIC;
		
	signal objectYa  : UNSIGNED (8 downto 0); -- 0 to 480 any yPixel
	signal objectYb  : UNSIGNED (8 downto 0); -- 0 to 480 any yPixel
	
	signal fast  : UNSIGNED (2 downto 0); 
	signal slow  : UNSIGNED (2 downto 0);
	signal speed : UNSIGNED (2 downto 0);
	signal speedSelect : STD_LOGIC;
	
	signal isLog : BOOLEAN;
	
	signal colorRND1 : STD_LOGIC_VECTOR (7 downto 0);
	signal colorRND2 : STD_LOGIC_VECTOR (7 downto 0);
	signal color1    : STD_LOGIC_VECTOR (7 downto 0);
	signal color2    : STD_LOGIC_VECTOR (7 downto 0);
	
	signal size1     : UNSIGNED (7 downto 0);
	signal size2     : UNSIGNED (7 downto 0);
		
	signal object1Xa : UNSIGNED (9 downto 0); -- 0 to 640 any xPixel
	signal object1Xb : UNSIGNED (9 downto 0); -- 0 to 640 any xPixel
	
	signal object2Xa : UNSIGNED (9 downto 0); -- 0 to 640 any xPixel
	signal object2Xb : UNSIGNED (9 downto 0); -- 0 to 640 any xPixel
	
	signal randomSLV : STD_LOGIC_VECTOR (11 downto 0);
	signal randomU : UNSIGNED (11 downto 0);
	
begin

	-- These values don't change accept for the random values.
	randomSLV <= randomStream(11 downto 0) xor ("01010101" & STD_LOGIC_VECTOR(row));
	randomU   <= UNSIGNED(randomStream(11 downto 0)) + row;
			
	objectYa <= (row & "00011");
	objectYb <= (row & "11100");
			
	rowSpeed <= speed;
	rowDirection <= direction;

	isLog <= true when( row < 7 ) else false;
		
	slow <= "001" when level = "00" else
			"010" when level = "01" else
			"011";
			
	fast <= "010" when level = "00" else
			"011" when level = "01" else
			"100";
			
	speed <= slow when speedSelect = '1' else fast;
	
	-- a Latch signal to catch values for this round. value change with reset
	process(clock, reset)
	begin
		if (reset = '1') then	
		
			-- Choose the direction for this lane
			if (isLog = false and (row = 8 or row = 9 or row = 10) ) then
				direction <= left;
			elsif (isLog = false and (row = 11 or row = 12 or row = 13) ) then
				direction <= right;
			else
				direction <= randomStream(1); 
			end if;
			
			-- Choose a speed for this lane
			if (randomStream(0) = '0') then
				speedSelect <= '1'; 
			else 
				speedSelect <= '0';  
			end if;
			
			-- choose a random starting location
			object1Xa <= "00" & randomU(9 downto 2); -- 0 to 255
			object2Xa <= "10" & randomU(10 downto 3); -- 512 to 768
			
			-- Choose a random size
			if (isLog) then
				size1 <= '1' & randomU( 9 downto 3); 
				size2 <= '1' & randomU(10 downto 4);
			else
				size1 <= '0' & randomU(9 downto 3) + 32; 
				size2 <= '0' & randomU(10 downto 4)+ 32;
			end if;
			
			
			-- choose a random color
			color1 <= randomSLV(7 downto 0); 
			color2 <= randomSLV(9 downto 2);			
		
		
		elsif (rising_edge(clock)) then
			
			if (update = '1') then

				if (object1Xa = 766 or object1Xa = 767 or object1Xa = 768 or object1Xa = 769 or object1Xa = 770 or object1Xa = 771) then
					color1 <= randomSLV(7 downto 0); 
					
					if (direction = right) then
						object1Xa <= object1Xa + randomU(8 downto 3);
					else
						object1Xa <= object1Xa - randomU(8 downto 3);
					end if;
								
					if (isLog) then
						size1 <= '1' & randomU( 9 downto 3); 
					else
						size1 <= '0' & randomU(9 downto 3) + 32;  
					end if;
					
				else
					if (direction = right) then
						object1Xa <= object1Xa + speed;
					else
						object1Xa <= object1Xa - speed;
					end if;
				
				end if;
			
				
				if (object2Xa = 766 or object2Xa = 767 or object2Xa = 768 or object2Xa = 769 or object2Xa = 770 or object2Xa = 771) then
					color2 <= randomSLV(9 downto 2); 
					
					if (direction = right) then
						object2Xa <= object2Xa + randomU(6 downto 1);
					else
						object2Xa <= object2Xa - randomU(6 downto 1);
					end if;
								
					if (isLog) then
						size2 <= '1' & randomU(10 downto 4);
					else
						size2 <= '0' & randomU(10 downto 4)+ 32;
					end if;
					
				else
					if (direction = right) then
						object2Xa <= object2Xa + speed;
					else
						object2Xa <= object2Xa - speed;
					end if;
				
				end if;
				
				object1Xb <= object1Xa + size1;
				object2Xb <= object2Xa + size2;
				
			end if;
			
		end if;
		
	end process;
	

			

			
	

	process(clock, reset)
		variable valid1X : boolean;
		variable valid2X : boolean;
		variable validY  : boolean;
	begin
		if (reset = '1') then
			colorOut <= black;

		elsif (rising_edge(clock)) then
			
			validY := (yPixel  >= objectYa and yPixel <= objectYb);
			
			valid1X := (xPixel  >= object1Xa and xPixel <= object1Xb)
					 or (object1Xa > object1Xb and xPixel <= object1Xb);			
			
			valid2X := (xPixel  >= object2Xa and xPixel <= object2Xb)
					 or (object2Xa > object2Xb and xPixel <= object2Xb);

			if    (validY and (valid1X or valid2X) and isLog ) then
				colorOut <= brown;
			elsif (validY and valid1X ) then
				colorOut <= color1;
			elsif (validY and valid2X ) then
				colorOut <= color2;
			else
				colorOut <= black;
			end if;
			
		end if;
	end process;


end Behavioral;

