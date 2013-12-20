library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity enableHigh is
port( clock   : in  STD_LOGIC;
		reset   : in  STD_LOGIC;
		x       : in  STD_LOGIC;
		x_pulse : out STD_LOGIC
		);
		
end enableHigh;

architecture Behavioral of enableHigh is

	signal not_x : STD_LOGIC;
	
begin	

	process(clock, reset)
	begin
		if (reset = '1')then
			x_pulse <= '0';
			
		elsif (rising_edge(clock)) then

			-- Create the NOT line of x.
			not_x <= not x;
			
			-- Create the pulse when x an not_x are the same.
			if (x = '1' and not_x = '1') then
				x_pulse <= '1';
			else
				x_pulse <= '0';
			end if;
				
		end if;
	end process;

end Behavioral;

