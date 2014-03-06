library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity randomGenerator is
port(clock      : in  STD_LOGIC;
	  userInput  : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
	  random_out : out STD_LOGIC_VECTOR(6 downto 0)
	 );
		
end randomGenerator;

architecture Behavioral of randomGenerator is

	signal random : STD_LOGIC_VECTOR(6 downto 0);
	signal reset  : STD_LOGIC;
	signal resetCount : UNSIGNED(1 downto 0);
	
begin	

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
		
			random <= "1110001";
			
		elsif (rising_edge(clock)) then
		
			random <= random(5 downto 0) & (userInput(0) xor userInput(2) xor userInput(1) xor random(3) );
			
		end if;
	end process;
	
	random_out <= random;
	
end Behavioral;

