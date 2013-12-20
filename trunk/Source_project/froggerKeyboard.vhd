library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity froggerKeyboard is
port (clock         : in STD_LOGIC;
	   reset         : in STD_LOGIC;
	   kbClock       : in STD_LOGIC;
	   kbData        : in STD_LOGIC;
	   moveUp_out    : out STD_LOGIC;
	   moveDown_out  : out STD_LOGIC;
	   moveRight_out : out STD_LOGIC;
	   moveLeft_out  : out STD_LOGIC
	  );
		
end froggerKeyboard;



architecture Behavioral of froggerKeyboard is

	signal new_data     : STD_LOGIC; -- it indicates that a new data from the keyboard has arrived
	signal data         : STD_LOGIC_VECTOR(7 downto 0); -- the data received from the keyboard
	signal parity_error : STD_LOGIC; -- it indicates a parity error in the last data received from the keyboard
	signal new_key      : STD_LOGIC; -- it indicates that a new key has been pressed
	signal end_key      : STD_LOGIC; -- it indicates that a key previously pressed has been released
	signal key          : STD_LOGIC_VECTOR(7 downto 0); -- the key code corresponding to the key pressed

	signal keyPressed : STD_LOGIC_VECTOR(7 downto 0);
	signal state      : STD_LOGIC;

	signal moveUp    : STD_LOGIC;
	signal moveDown  : STD_LOGIC;
	signal moveRight : STD_LOGIC;
	signal moveLeft  : STD_LOGIC;
	
begin


	---------------------------------------------------------------------------------------------
	-- Connect Keyboard
	-----------------
	keyBoardInterface : entity ps2_keyboard_advanced_interface 
		port map(clk => clock,
					reset => reset,
					kbdata => kbData,
					kbclk => kbClock,
					
					new_data => new_data,
					data => data,
					parity_error => parity_error,
					new_key => new_key,
					end_key => end_key,
					key => key		
				  );
				 

process (clock, reset)
	begin
		if (reset = '1') then
			keyPressed <= x"00";
			state <= '0';
		
		elsif (rising_edge(clock)) then
		
			if (new_data = '1' and state = '0') then
				keyPressed <= data;
				state <= '1';
			
			elsif (end_key = '1' and state = '1') then
				keyPressed <= x"00";
				state <= '0';
			
			end if;
			
		end if;
	end process;
	
	
	
	moveUp    <= '1' when (keyPressed = x"75") else '0';
	moveDown  <= '1' when (keyPressed = x"72") else '0';
	moveRight <= '1' when (keyPressed = x"74") else '0';
	moveLeft  <= '1' when (keyPressed = x"6B") else '0';
	
	
	enableUp : entity enableHigh
		port map(clock   => clock,
					reset   => reset,
					x       => moveUp,
					x_pulse => moveUp_out
				  );

	enableDown : entity enableHigh 
		port map(clock   => clock,
					reset   => reset,
					x       => moveDown,
					x_pulse => moveDown_out
				  );
				  	
	enableRight : entity enableHigh 
		port map(clock   => clock,
					reset   => reset,
					x       => moveRight,
					x_pulse => moveRight_out
				  );
				  
	enableLeft : entity enableHigh 
		port map(clock   => clock,
					reset   => reset,
					x       => moveLeft,
					x_pulse => moveLeft_out
				  );		
				  
	



end Behavioral;

