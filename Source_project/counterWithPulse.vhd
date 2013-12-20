--Counter with Pulse
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity counterWithPulse is port(
	clk : in std_logic;
	reset : in std_logic;
	MaxCounter : in unsigned(15 downto 0);
	Pulse : out std_logic);
end counterWithPulse;

architecture behavioral of counterWithPulse is

signal cntr : unsigned(15 downto 0);
signal syncReset : std_logic;

begin
	process(clk, reset)
		begin
		if(reset = '1') then
			cntr <= (others => '0');
		elsif(rising_edge(clk)) then
			if(syncReset = '1') then
				cntr <= (others => '0');
			else
			cntr <= cntr + 1;
			end if;
		end if;
end process;
	
	syncReset <= '1' when (cntr = MaxCounter) else '0';
	Pulse <= syncReset;
end behavioral;