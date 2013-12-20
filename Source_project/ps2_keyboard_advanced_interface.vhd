-- Advanced PS2 keyboard interface

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2_keyboard_advanced_interface is
    Port ( clk : in std_logic; -- global clock
			  reset : in std_logic; -- global reset
			  kbdata : in std_logic; -- keyboard data
			  kbclk : in std_logic; -- keyboard clock
           new_data : out std_logic;  -- it indicates that a new data from the keyboard has arrived
           data : out std_logic_vector(7 downto 0); -- the data received from the keyboard
			  parity_error : out std_logic; -- it indicates a parity error in the last data received from the keyboard
           new_key : out std_logic;  -- it indicates that a new key has been pressed
           end_key : out std_logic;  -- it indicates that a key previously pressed has been released
           key : out std_logic_vector(7 downto 0) -- the key code corresponding to the key pressed
			  );
end ps2_keyboard_advanced_interface;

architecture Behavioral of ps2_keyboard_advanced_interface is

-- Señales internas
signal end_data: std_logic;
signal pressed_key: std_logic;
signal released_key: std_logic;
signal data_aux: std_logic_vector (7 downto 0);

-- Declaracion del circuito de interfaz basico del teclado PS2
	COMPONENT ps2_keyboard_basic_interface
	PORT(
		kbclk : IN std_logic;
		reset : IN std_logic;
		kbdata : IN std_logic;    
		end_data : OUT std_logic;      
		parity_error : OUT std_logic;
		data : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

-- Declaracion del circuito identificador de teclas
	COMPONENT key_identifier
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		end_data : IN std_logic;
		data : IN std_logic_vector(7 downto 0);    
		new_data : OUT std_logic;
		key : OUT std_logic_vector(7 downto 0);      
		new_key : OUT std_logic;
		end_key : OUT std_logic;
      pressed_key : out std_logic;
      released_key : out std_logic
		);
	END COMPONENT;


begin

data <= data_aux;

-- Instanciacion del circuito de interfaz basico del teclado PS2
	Inst_ps2_keyboard_basic_interface: ps2_keyboard_basic_interface PORT MAP(
		kbclk => kbclk,
		reset => reset,
		kbdata => kbdata,
		end_data => end_data,
		parity_error => parity_error,
		data => data_aux
	);

-- Declaracion del circuito identificador de teclas
	Inst_key_identifier: key_identifier PORT MAP(
		clk => clk,
		reset => reset,
		end_data => end_data,
		data => data_aux,
		new_data => new_data,
		new_key => new_key,
		end_key => end_key,
		pressed_key => pressed_key,
		released_key => released_key,
		key => key
	);


end Behavioral;
