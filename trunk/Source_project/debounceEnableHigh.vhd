library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity debounceEnableHigh is
port( clock   : in  STD_LOGIC;
		reset   : in  STD_LOGIC;
		x       : in  STD_LOGIC;
		x_pulse : out STD_LOGIC
		);
		
end debounceEnableHigh;

architecture Behavioral of debounceEnableHigh is

	signal x_db : STD_LOGIC;
	
begin	


	debounce1 : entity debounce port map (clock => clock, reset => reset, x => x, x_out => x_db );
	enable1   : entity enableHigh port map   (clock => clock, reset => reset, x => x_db, x_pulse => x_pulse );


end Behavioral;

