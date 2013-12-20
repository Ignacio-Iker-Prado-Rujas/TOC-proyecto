library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity vgaSyncGenerator is
port( clock : in  STD_LOGIC;
      reset : in  STD_LOGIC;
	   hSync : out  STD_LOGIC;
	   vSync : out  STD_LOGIC;
	   inVisibleArea : out STD_LOGIC;
		update : out STD_LOGIC;
	   xPixel : out  unsigned (9 downto 0);
	   yPixel : out  unsigned (8 downto 0)
	  );
		
end vgaSyncGenerator;

architecture Behavioral of vgaSyncGenerator is

	signal clk25Hz : STD_LOGIC := '0';
	signal notZero : STD_LOGIC;
	signal xCount : unsigned(9 downto 0);
	signal yCount : unsigned(19 downto 0);
	signal xPixelCount : unsigned(9 downto 0);
	signal yPixelCount : unsigned(8 downto 0);

begin

	xPixel <= xPixelCount;
	yPixel <= yPixelCount;


	-- setup 25Mhz clock
	process (clock)
	begin
		if (rising_edge(clock)) then
			clk25Hz <= not clk25Hz; 
		end if;
	end process;

	-- Setup Horizontal Sync x counter and the x pixel
	process (clock, reset)
	begin
		if (reset = '1')then
			hSync  <= '1';
			vSync  <= '1';
			inVisibleArea <= '0';
			xCount <= (others => '0');
			yCount <= (others => '0');
			xPixelCount <= (others => '0');
			yPixelCount <= (others => '0');
			
		elsif (rising_edge(clock)) then
			if (clk25HZ = '0') then
				
				-- Impliment the x counter (800 points 0 to 799)
				if (xCount < 799) then
					xCount <= xCount + 1;
				else
					xCount <= (others => '0'); 
				end if;
				
				-- Impliment Horizontal sync (low for first 96 points 1 to 96, high for the rest.)
				if (xCount < 96) then
					hSync <= '0'; 
				else
					hSync <= '1';
				end if;
				
				-- Impliment x pixel (pulse width 96 and back porch 48 = 144
				-- start xPixel counting (0 to 639) after point 144
				if (xCount > 143 and xCount < 783) then
					xPixelCount <= xPixelCount + 1;
				else
					xPixelCount <= (others => '0');  
				end if;
				
				-- Impliment the y counter (521 lines 0 to 520)
				if (yCount < 521) then
					if (xCount = 799) then
						yCount <= yCount + 1; 
					end if;
				else
					yCount <= (others => '0');
				end if;
				
				-- Impliment Vertical sync (low for first 2 lines 0 to 1, high for the rest.
				if (yCount < 2) then
					vSync <= '0'; 
				else
					vSync <= '1';
				end if;
								
				-- Impliment y pixel (pulse width 2 and back porch 29 = 31
				-- start yPixel counting (0 to 479) after point 31
				if (yCount > 30 and yCount < 511) then
					if (xCount = 799) then
						yPixelCount <= yPixelCount + 1;
					end if;
				else
					yPixelCount <= (others => '0');  
				end if;
				
				if (xCount > 143 and xCount < 783 and yCount > 30 and yCount < 511) then
					inVisibleArea <= '1';
				else
					inVisibleArea <= '0';
				end if;
				
				
			end if;	
		end if;
	end process;

	process (clock)
	begin
		if (rising_edge(clock)) then
			
			if (yCount = 0) then 
				notZero <= '1';
			else
				notZero <= '0';
			end if;
			
			if (yCount = 0 and notZero = '0') then 
				update <= '1';
			else
				update <= '0';
			end if;
			
		end if;
	
	end process;
	

end Behavioral;

