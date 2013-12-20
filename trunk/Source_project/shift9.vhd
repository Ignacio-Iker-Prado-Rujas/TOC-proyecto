-- 9 bit right shift register
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shift9 is
    Port ( ms_in : in std_logic; -- Most significant bit serial input
           reset : in std_logic; -- global reset
           ce : in std_logic; -- shift enable
           clk : in std_logic; -- global clock
           q : out std_logic_vector(8 downto 0) -- shift register outputs
			  ); 
end shift9;

architecture Behavioral of shift9 is

signal q_aux: std_logic_vector(8 downto 0);

begin

q <= q_aux;

desplaza: process (reset,clk,ms_in,ce)
begin
	if reset='1' then
		-- Register reset
		q_aux <= "000000000";
	elsif (clk'event and clk='1') then
		if (ce='1') then
			-- It stores a new bit and shifts right the other bits
			q_aux(8) <= ms_in;
			q_aux(7 downto 0) <= q_aux(8 downto 1);
		end if;
	end if;
end process;

end Behavioral;
