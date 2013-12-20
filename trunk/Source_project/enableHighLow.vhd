library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity enableHighLow is
port( clock   : in  STD_LOGIC;
		reset   : in  STD_LOGIC;
		x       : in  STD_LOGIC;
		x_pulse : out STD_LOGIC
		);
		
end enableHighLow;

architecture Behavioral of enableHighLow is

	signal x_trailer : STD_LOGIC;
	
begin	

	process(clock, reset)
	begin
		if (reset = '1')then
			x_trailer <= x;
			x_pulse <= '0';
			
		elsif (rising_edge(clock)) then

			-- Set the trailer line of x.
			x_trailer <= x;
			
			-- Set the pulse high when x and x_not are NOT the same.
			x_pulse <= x XOR x_trailer;
				
		end if;
	end process;

end Behavioral;

