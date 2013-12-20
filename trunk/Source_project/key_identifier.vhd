-- Key identifier

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity key_identifier is
    Port ( 	clk : in std_logic; -- global clock
	 			reset : in std_logic;
				end_data : in std_logic;
				data: in std_logic_vector (7 downto 0);
				new_data : out std_logic;
           	new_key : out std_logic;
           	end_key : out std_logic;
           	pressed_key : out std_logic;
           	released_key : out std_logic;
           	key : out std_logic_vector(7 downto 0)
			  	);
end key_identifier;

architecture Behavioral of key_identifier is

-- Internal signals
signal end_data_s: std_logic;
signal end_data_t_1: std_logic;
signal new_data_aux, pressed_key_aux, released_key_aux: std_logic;
signal key_aux: std_logic_vector (7 downto 0);

begin

new_data <= new_data_aux;
pressed_key <= pressed_key_aux;
released_key <= released_key_aux;
key <= key_aux;

-- Rising edge detector for signal "end_data", which generates the "new_data" output
edge_detector_end_data: process (reset,clk,end_data_s,end_data_t_1)
begin
	if reset = '1' then 	end_data_s <= '0';
								end_data_t_1 <= '0';
	elsif clk = '1' and clk'event then 	end_data_t_1 <= end_data_s;
													end_data_s <= end_data;
	end if;

	new_data_aux <= not end_data_s and end_data_t_1;

end process;

-- Data identification

identification: process (reset,clk,new_data_aux,data,pressed_key_aux,released_key_aux,key_aux)
begin
	if reset = '1' then 		new_key <= '0';
									pressed_key_aux <= '0';
									released_key_aux <= '0';
									end_key <= '0';
									key_aux <= "00000000";

	elsif clk = '1' and clk'event then
		
		if new_data_aux = '1' then

			-- It stores the action of pressing (and keeping pressed) a key
			if (data /= x"F0") and (pressed_key_aux = '0') and (released_key_aux ='0') then pressed_key_aux <= '1';
			elsif
				(data = x"F0") and (pressed_key_aux = '1') then pressed_key_aux <= '0';
			else pressed_key_aux <= pressed_key_aux;
			end if;

			-- It stores the code of the new key pressed
			if (data /= x"F0") and (pressed_key_aux = '0') then key_aux <= data;
			else key_aux <= key_aux;
			end if;

			-- It stores the action of releasing a key
			if (data = x"F0") and (released_key_aux = '0') and (pressed_key_aux = '1') then released_key_aux <= '1';
			elsif
				(data=key_aux) and (released_key_aux = '1') then released_key_aux <= '0';
			else released_key_aux <= released_key_aux;
			end if;

		end if;

		-- It activates the "new_key" output, which indicates that a new key have been pressed
		if (new_data_aux = '1') and (data /= x"F0") and (pressed_key_aux = '0') and (released_key_aux ='0') then new_key <= '1';
			else new_key <= '0';
		end if;

		-- It activates the "end_key" output, which indicates that a key have been released
		if (new_data_aux = '1') and (data=key_aux) and (released_key_aux = '1') then end_key <= '1';
			else end_key <= '0';
		end if;

	end if;

end process;

end Behavioral;
