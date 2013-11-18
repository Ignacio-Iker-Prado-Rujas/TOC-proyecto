--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_mult_comb_gen_clkpipe IS
 Generic (
   g_bits   : natural := 5
 );
END tb_mult_comb_gen_clkpipe;

ARCHITECTURE TB OF tb_mult_comb_gen_clkpipe IS 
  COMPONENT mult_comb_gen_clkpipe
    Generic (
      g_bits   : natural := 4
    );
    Port (
      clk     : in  std_logic;
      fact1   : in  unsigned (g_bits-1 downto 0);
      fact2   : in  unsigned (g_bits-1 downto 0);
      prod    : out unsigned (2*g_bits-1 downto 0)
    );
  END COMPONENT;

  signal clk          : std_logic;
  signal fact1, fact2 : unsigned (g_bits-1 downto 0);
  signal prod         : unsigned (2*g_bits-1 downto 0);

  signal finsim       : std_logic := '0';

BEGIN

  uut: mult_comb_gen_clkpipe
  generic map (
    g_bits => g_bits
  )
  port map(
    clk    => clk,
    fact1  => fact1,
    fact2  => fact2,
    prod   => prod
  );

  P_clk: Process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    if finsim = '1' then
      wait;
    end if;
  end process;
    
	
  P_stim: Process
  begin
    for i in 0 to 2**g_bits-1 loop
      fact1 <= to_unsigned (i, g_bits);
      for j in 0 to 2**g_bits-1 loop
        fact2 <= to_unsigned (j, g_bits);
        for k in 0 to g_bits loop
          -- esperamos g_bits +1 ciclos de reloj
          wait until clk'event and clk='1';
        end loop;
        -- hay que esperar algo para que se actualicen
        wait for 1 ns;
        assert prod = i*j 
           report "Fallo en la multiplicacion"
           severity ERROR;
        wait for 23 ns;
      end loop;
    end loop;
    wait for 50 ns;
    finsim <= '1';
    wait for 20 ns;
    wait;
  end process;

END;
