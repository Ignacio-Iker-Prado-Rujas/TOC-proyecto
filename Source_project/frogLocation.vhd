library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity frogLocation is
port( clock        : in STD_LOGIC;
		reset        : in STD_LOGIC;
		moveUp       : in STD_LOGIC;
		moveDown     : in STD_LOGIC;
		moveRight    : in STD_LOGIC;
		moveLeft     : in STD_LOGIC;
		update       : in STD_LOGIC;
		isDead       : in STD_LOGIC;
		isOnLog      : in STD_LOGIC;
		rowDirection : in STD_LOGIC;
		rowSpeed     : in UNSIGNED (2 downto 0);
		frogXaOut   : out UNSIGNED (9 downto 0);
		frogXbOut   : out UNSIGNED (9 downto 0);
		frogYaOut   : out UNSIGNED (8 downto 0);
		frogYbOut   : out UNSIGNED (8 downto 0);
		frogRowOut  : out UNSIGNED (3 downto 0)
		);
		
end frogLocation;


architecture Behavioral of frogLocation is

	signal frogRow : UNSIGNED(3 downto 0); -- 0 to 14
	signal frogX : UNSIGNED (9 downto 0); -- 0 to 640 any xPixel
	
begin

	-- Process inputs
	process(clock, reset)
	begin
		if (reset = '1') then
			frogRow <= x"E";
			frogX <= "0100110011"; -- 307
			
		elsif (rising_edge(clock)) then
			
			if (isDead = '0') then
			-- Update for moving up
				if (moveUp = '1') then
					if (frogRow = 0) then frogRow <= "0000";
					else frogRow <= frogRow - 1;
					end if;
				end if;
					
				-- Update for moving down
				if (moveDown = '1') then
					if (frogRow = 14 ) then frogRow <= "1110";
					else frogRow <= frogRow + 1;
					end if;
				end if;
							
				-- Update for moving Left
				if (moveLeft = '1') then
					frogX <= frogX - 32;
				end if;
							
				-- Update for moving Right
				if (moveRight = '1') then
					frogX <= frogX + 32;
				end if;
				
				-- Update for moving on a log
				if (update = '1' and isOnLog = '1') then
					if    (rowDirection = '0') then
						frogX <= frogX - rowSpeed;
					else 
						frogX <= frogX + rowSpeed;
					end if;
				end if;
				
				-- keep the frog on the screen and push it off the log
				if    (frogX = 0 or frogX > 700) then
					frogX <= "0000000001"; -- 1
				elsif (frogX > 614) then
					frogX <= "1001100110"; -- 614
				end if;
					
					
					
			end if;
			
			if (update = '1') then
			
				-- Update the frogRow Output
				frogRowOut <= frogRow;
				
				-- Update the Xa and Xb outputs
				frogXaOut <= frogX;
				frogXbOut <= frogX + 25;
				
				-- Update the Ya and Yb outputs
				case frogRow is
					when x"1" => 
						frogYaOut <= "000100011";
						frogYbOut <= "000111100";
					when x"2" => 
						frogYaOut <= "001000011";
						frogYbOut <= "001011100";
					when x"3" => 
						frogYaOut <= "001100011";
						frogYbOut <= "001111100";
					when x"4" =>
						frogYaOut <= "010000011";
						frogYbOut <= "010011100";
					when x"5" =>
						frogYaOut <= "010100011";
						frogYbOut <= "010111100";
					when x"6" => 
						frogYaOut <= "011000011";
						frogYbOut <= "011011100";
					when x"7" => 
						frogYaOut <= "011100011";
						frogYbOut <= "011111100";
					when x"8" => 
						frogYaOut <= "100000011";
						frogYbOut <= "100011100";
					when x"9" => 
						frogYaOut <= "100100011";
						frogYbOut <= "100111100";
					when x"A" => 
						frogYaOut <= "101000011";
						frogYbOut <= "101011100";
					when x"B" => 
						frogYaOut <= "101100011";
						frogYbOut <= "101111100";
					when x"C" => 
						frogYaOut <= "110000011";
						frogYbOut <= "110011100";
					when x"D" => 
						frogYaOut <= "110100011";
						frogYbOut <= "110111100";
					when x"E" => 
						frogYaOut <= "111000011";
						frogYbOut <= "111011100";
					when others  => 
						frogYaOut <= "000000011";
						frogYbOut <= "000011100";
				end case;
			end if;
			
		end if;
	end process;


end Behavioral;

