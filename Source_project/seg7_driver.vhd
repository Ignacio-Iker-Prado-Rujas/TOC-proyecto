--to_bcd function is from http://vhdlguru.blogspot.com/2010/04/8-bit-binary-to-bcd-converter-double.html

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity seg7_driver is Port (

clock		  : in std_logic;
reset  	  : in std_logic;
totalScore : in integer;
anodes	  : out std_logic_vector (3 downto 0);
enc_char   : out std_logic_vector (6 downto 0));

end seg7_driver;

architecture Behavioral of seg7_driver is

signal sel 		: unsigned(1 downto 0);
signal p1		: std_logic;
signal m1		: std_logic_vector (3 downto 0);
signal to_digit	: std_logic_vector (3 downto 0);
signal to_anodes  : std_logic_vector (3 downto 0);
signal char0		: std_logic_vector (3 downto 0);
signal char1		: std_logic_vector (3 downto 0);
signal char2		: std_logic_vector (3 downto 0);
signal char3		: std_logic_vector (3 downto 0);
signal slv_totalScore		: std_logic_vector (15 downto 0);

function to_bcd (bin : unsigned(15 downto 0)) return std_logic_vector is
	variable i : integer :=0;
	variable bcd : unsigned (15 downto 0) := (others=> '0');
	variable bint: unsigned (15 downto 0) := bin;

	begin
		for i in 0 to 15 loop
			bcd(15 downto 1) := bcd (14 downto 0);
			bcd(0) := bint(15);
			bint(15 downto 1) := bint(14 downto 0);
			bint(0) := '0';

		if (i < 15 and bcd(3 downto 0) > "0100") then
			bcd(3 downto 0) := bcd(3 downto 0) + "0011";
		end if;

		if (i < 15 and bcd(7 downto 4) > "0100") then
			bcd(7 downto 4) := bcd(7 downto 4) + "0011";
		end if;
		
		if (i < 15 and bcd(11 downto 8) > "0100") then
			bcd(11 downto 8) := bcd(11 downto 8) + "0011";
		end if;
		
		if (i < 15 and bcd(15 downto 12) > "0100") then
			bcd(15 downto 12) := bcd(15 downto 12) + "0011";
		end if;
	end loop;
	return std_logic_vector(bcd);
end to_bcd;


begin

pulse_1k : entity counterWithPulse port map(
	clk 	=> clock ,
	reset => reset ,
	MaxCounter => "1100001101010000" , -- Binary value for 50,000
	Pulse => p1) ; 
	
process (clock, p1, reset)
	variable ctr : unsigned(1 downto 0);
	
	begin 
		if (reset = '1') then
			ctr := "00";
		elsif rising_edge (clock) then
			if (p1 = '1') then
				ctr := ctr + "01" ;
			end if;
		end if;
		sel <= ctr;
end process;

slv_totalScore <= to_bcd(to_unsigned(totalScore,16));

char0  <= slv_totalScore(15 downto 12);
			
char1  <= slv_totalScore(11 downto 8);
			
char2  <= slv_totalScore(7 downto 4);
char3  <= slv_totalScore(3 downto 0);

process (sel, char0, char1, char2, char3)	
	begin
		case sel is
			when "00" => 
				to_anodes <= "0111";
				to_digit <= char0;
			when "01" =>
				to_anodes <= "1011";
				to_digit <= char1;
			when "10" =>
				to_anodes <= "1101";
				to_digit <= char2;
			when others =>	
				to_anodes <="1110";
				to_digit <= char3;
		end case;
end process;	

 
anodes <= "0000" when reset='1' else to_anodes;
m1		 <= "0000" when reset='1' else to_digit;			

dc1: entity led_decoder port map ( digit => m1, seg7 => enc_char);

end Behavioral;