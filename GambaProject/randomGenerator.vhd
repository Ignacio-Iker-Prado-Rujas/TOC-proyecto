library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity randomGenerator is
port(clock      : in  STD_LOGIC;
	  userInput  : in  STD_LOGIC;
	  random_out : out STD_LOGIC_VECTOR(2 downto 0)
	 );
		
end randomGenerator;

architecture Behavioral of randomGenerator is

	signal random : STD_LOGIC_VECTOR(2 downto 0);
	signal reset  : STD_LOGIC;
	signal resetCount : UNSIGNED(1 downto 0);
	
begin	

	---------------------------------------------------------------------------------------------
	-- initial reset line
	-----------------
	process (clock)
	begin
		if (rising_edge(clock)) then
		
			if (resetCount < 2) then
				reset <= '1';
				resetCount <= resetCount + 1;
			else
				reset <= '0';
			end if;
			
		end if;
	end process;
	
	process(clock, reset)
	begin
		if (reset = '1') then
		
			random <= "101";
			
		elsif (rising_edge(clock)) then
		
			random <= random(1 downto 0) & (userInput xor random(2) xor random(1) xor random(0) );
			
		end if;
	end process;
	
	random_out <= random;
	
end Behavioral;

