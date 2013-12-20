-- PS2 keyboard basic interface circuit

library IEEE;
use IEEE.std_logic_1164.all;

entity ps2_keyboard_basic_interface is
    port (
        kbclk: in STD_LOGIC; -- keyboard clock
        reset: in STD_LOGIC; -- global reset
        kbdata: in STD_LOGIC; -- keyboard data
        end_data: out STD_LOGIC; -- it indicates that a new data from the keyboard has arrived
        parity_error: out STD_LOGIC; -- it indicates a parity error in the last data received from the keyboard
        data: out STD_LOGIC_VECTOR (7 downto 0) -- the data corresponding to the key pressed
    );
end ps2_keyboard_basic_interface;

architecture ps2_keyboard_basic_interface_arch of ps2_keyboard_basic_interface is

-- Internal signals
signal SHIFT: STD_LOGIC_VECTOR (8 downto 0);
signal Q_BIT_CTR: integer range 0 to 9; 
signal GSHIFT: STD_LOGIC;
signal RESETINT: STD_LOGIC;
signal SHIFT_RESET: STD_LOGIC;
signal SHIFT_CLK: STD_LOGIC;
signal end_data_aux: std_logic;

-- 9 bit right shift register component declaration
	COMPONENT shift9
	PORT(
		ms_in : IN std_logic;
		reset : IN std_logic;
		ce : IN std_logic;
		clk : IN std_logic;       
		q : OUT std_logic_vector(8 downto 0)
		);
	END COMPONENT;

begin

end_data <= end_data_aux;

-- Start bit detection
start: process (KBCLK, KBDATA, GSHIFT, RESET, RESETINT)
begin
	if RESET='1' or RESETINT='1' then
		GSHIFT<='0';
	elsif (KBCLK'event and KBCLK='0') then
		if (GSHIFT='0' and KBDATA='0') then
		GSHIFT <='1';
		end if;
	end if;
end process;

-- Bit counter
counter: process (KBCLK, GSHIFT, RESET, RESETINT, Q_BIT_CTR)
begin
	if RESET='1' or RESETINT='1' then
		Q_BIT_CTR <= 0;
		end_data_aux <= '0';
	elsif (KBCLK'event and KBCLK='0') then
		if (GSHIFT='1') then
			-- Increments received bits counter
			Q_BIT_CTR <= Q_BIT_CTR + 1;
		end if;
	end if;
	
-- Data end detection
	if Q_BIT_CTR = 9 then
		end_data_aux <= '1';
	else
		end_data_aux <= '0';
	end if;
end process;

-- Shift register inputs
SHIFT_CLK <= not KBCLK;
SHIFT_RESET <= RESET or RESETINT;

-- 9 bit right shift register component instantiation
	shift_register: shift9 PORT MAP(
		ms_in => KBDATA,
		reset => SHIFT_RESET,
		ce => GSHIFT,
		clk => SHIFT_CLK,
		q => SHIFT
		);

-- Parity error detector
error_detection: process (KBCLK, RESET, end_data_aux)
begin
	if RESET='1' then
		PARITY_ERROR<='0';
	elsif (KBCLK'event and KBCLK='1') then
		if (end_data_aux='1') then
			PARITY_ERROR <= not(SHIFT(0) xor SHIFT(1) xor SHIFT(2) xor SHIFT(3)
			xor SHIFT(4) xor SHIFT(5) xor SHIFT(6) xor SHIFT(7) xor SHIFT(8));
		end if;
	end if;
end process;

-- Internal reset circuit, at the end of each data reception
ending: process (KBCLK,end_data_aux,RESETINT,RESET)
begin	
	if RESET='1' then
		DATA <= "00000000";
		RESETINT <='0';
	elsif (KBCLK'event and KBCLK='1') then
		if end_data_aux='1' then 
			-- It stores the received data
			DATA (7 downto 0) <= SHIFT (7 downto 0);
			-- It signals the end of the reception
			RESETINT <= '1';
		else
			RESETINT <= '0';
		end if;
	end if;
end process;

end ps2_keyboard_basic_interface_arch;
