library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity frogGenerator is
port( clock        : in STD_LOGIC;
		reset        : in STD_LOGIC;
		xPixel       : in UNSIGNED (9 downto 0);
		yPixel       : in UNSIGNED (8 downto 0);
		update		 : in STD_LOGIC;
		isDead       : in STD_LOGIC;
		frogXa       : in UNSIGNED (9 downto 0);
		frogXb       : in UNSIGNED (9 downto 0);
		frogYa       : in UNSIGNED (8 downto 0);
		frogYb       : in UNSIGNED (8 downto 0);
		frogColorOut : out STD_LOGIC_VECTOR (7 downto 0)
		);
		
end frogGenerator;


architecture Behavioral of frogGenerator is

	constant frogGreen : STD_LOGIC_VECTOR(7 downto 0) := "00010000"; -- bbgggrrr
	constant black     : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; -- bbgggrrr
	constant red       : STD_LOGIC_VECTOR(7 downto 0) := "00000111";
	constant white     : STD_LOGIC_VECTOR(7 downto 0) := "11111111";
	
	signal deadFrogColorCounter : UNSIGNED(4 downto 0);
	
begin

	-- Process inputs
	process(clock, reset)
		variable validX : boolean;
		variable validY : boolean;
	begin
	
		validY := (yPixel >= frogYa and yPixel <= frogYb);
		validX := (xPixel >= frogXa and xPixel <= frogXb)
				 or (frogXa >  frogXb and xPixel <= frogXb);
	
	
		if (reset = '1') then
			frogColorOut <= black;
			
		elsif (rising_edge(clock)) then
		
			if (update = '1') then
				deadFrogColorCounter <= deadFrogColorCounter + 1;
			end if;
		
			if (validX and validY) then
			
				if (isDead = '1') then
			
					if (deadFrogColorCounter(4) = '1') then frogColorOut <= red;
					else frogColorOut <= white;
					end if;
					
				else
					frogColorOut <= frogGreen;
				end if;
				
			else
				frogColorOut <= black;
			end if;
					

		end if;
	
	end process;
	

end Behavioral;

