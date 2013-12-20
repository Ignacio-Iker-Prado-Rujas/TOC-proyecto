library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity score is 
port( clock    	  : in STD_LOGIC;
	   reset			  : in STD_LOGIC;
		level			  : in STD_LOGIC_VECTOR (1 downto 0);
		win	    	  : in STD_LOGIC;
		frogRow		  : in UNSIGNED (3 downto 0);
		totalScore	  : out integer
	 );

end score;

architecture behavioral of score is

signal runningScore : INTEGER;
signal addpoints	  : INTEGER;

begin

	process(clock)
	begin
		if rising_edge(clock) then
			if frogRow=x"E" then
				if level="00" then
					addpoints <= 10;
				elsif level="01" then
					addpoints <= 20;
				elsif level="10" or level="11" then
					addpoints <= 50;
				end if;
			end if;
		end if;
	end process;
	
	totalScore <= runningScore;
	
	process(clock, reset)
	begin
		if (reset='1') then
			runningScore <= 0;
		elsif rising_edge(clock) then
			if win='1' then
				if runningScore >= 5000 then
					runningScore <= 5000;
				else
					runningScore <= runningScore + addpoints;
				end if;
			end if;
		end if;
	end process; 

end behavioral;