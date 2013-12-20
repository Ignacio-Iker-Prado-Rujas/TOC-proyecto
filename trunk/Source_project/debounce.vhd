library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity debounce is 
port( clock : in  STD_LOGIC;
      reset : in  STD_LOGIC;
		x     : in  STD_LOGIC;
		x_out : out STD_LOGIC
		);
			
end debounce;

architecture Behavioral of debounce is
	
	signal counter : unsigned (23 downto 0);
	signal x_db : STD_LOGIC;
	
begin	

	process(clock, reset)
	begin
		if (reset = '1') then
			counter <= (others => '0');
			x_db <= x;
			
		elsif (rising_edge(clock)) then
			
			if (x = x_db) then
				counter <= (others => '0');
			else
			
				if (counter < 2000000) then
					counter <= counter + 1;
				else
					x_db <= x;
				end if;
			
			end if;			
				
		end if;
	end process;
	
	x_out <= x_db;

end Behavioral;