library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;



entity backGroundGenerator is
port( clock  : in  STD_LOGIC;
	   reset  : in  STD_LOGIC;
	   xPixel : in  unsigned (9 downto 0);
	   yPixel : in  unsigned (8 downto 0);
	   backColor : out  STD_LOGIC_VECTOR(7 downto 0)
	 );
		
end backGroundGenerator;


architecture Behavioral of backGroundGenerator is

	constant green : STD_LOGIC_VECTOR(7 downto 0) := "00111000";
	constant blue  : STD_LOGIC_VECTOR(7 downto 0) := "11000000";
	constant yellow: STD_LOGIC_VECTOR(7 downto 0) := "00111111";
	constant white : STD_LOGIC_VECTOR(7 downto 0) := "11111111";
	constant black : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

	signal colNumber : UNSIGNED(4 downto 0);
	signal rowNumber : UNSIGNED(3 downto 0);
	signal blockRowPixel : UNSIGNED(4 downto 0);
	
begin
	
	colNumber <= xPixel(9 downto 5);
	rowNumber <= yPixel(8 downto 5);
	blockRowPixel <= yPixel(4 downto 0);


	process(clock, reset)
	begin
		if (reset = '1') then
			backColor <= black;
			
		elsif (rising_edge(clock)) then
			
			if    (rowNumber = 0) then 	-- Ending Grass
				if (colNumber(1 downto 0) = "00" OR colNumber(1 downto 0) = "11") then
					backColor <= green;
				else
					backColor <= blue;
				end if;
			elsif (rowNumber = 1 
					OR rowNumber = 2 
					OR rowNumber = 3 
					OR rowNumber = 4 
					OR rowNumber = 5
					OR rowNumber = 6) then 	-- River
				backColor <= blue;
			elsif (rowNumber = 7) then		-- Middle Grass
				backColor <= green;
			elsif (rowNumber = 8) then		-- Street
				if (blockRowPixel = 1) then
					backColor <= white;			-- Top white line
				else
					backColor <= black;				
				end if;
			elsif (rowNumber = 9 OR rowNumber = 12) then
				if ((blockRowPixel = 0 or blockRowPixel = 31) and xPixel(4) = '0') then
					backColor <= white;			-- Dashed white line
				else
					backColor <= black;				
				end if;
			elsif (rowNumber = 10) then
				if (blockRowPixel = 30) then
					backColor <= yellow;	-- Upper middle yellow line
				else
					backColor <= black;				
				end if;
			elsif (rowNumber = 11) then
				if (blockRowPixel = 1) then
					backColor <= yellow; -- lower middle yellow line
				else
					backColor <= black;				
				end if;
			elsif (rowNumber = 13) then
				if (blockRowPixel = 30) then
					backColor <= white;	-- lower white line
				else
					backColor <= black;				
				end if;
			else										-- Starting Grass
				backColor <= green;
			end if;
			

			
		end if;
	end process;

end Behavioral;
