--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library WORK;
use WORK.MULT_PKG.ALL;

entity tb_mult_seq_gen_libro is
 Generic (
   g_bits   : natural := 4
 );
END tb_mult_seq_gen_libro;

architecture TB of tb_mult_seq_gen_libro is 

  COMPONENT mult_seq_gen_libro is
    Generic (
      g_bits   : natural := 16
    );
    Port (
      rst     : in  std_logic;
      clk     : in  std_logic;
      start   : in  std_logic;  -- orden de empezar multiplicacion
      fact1   : in  unsigned (g_bits-1 downto 0);
      fact2   : in  unsigned (g_bits-1 downto 0);
      finmult : out std_logic;  -- fin de multiplicacion
      prod    : out unsigned (2*g_bits-1 downto 0)
     );
  end component;

  signal rst, clk, start, finmult : std_logic;
  signal fact1, fact2 : unsigned (g_bits-1 downto 0);
  signal prod         : unsigned (2*g_bits-1 downto 0);

  signal finsimul   : std_logic := '0';

BEGIN

  uut: mult_seq_gen_libro
  generic map (
    g_bits  => g_bits
  )
  port map(
    rst     => rst,
    clk     => clk,
    start   => start,
    fact1   => fact1,
    fact2   => fact2,
    finmult => finmult,
    prod    => prod
  );
    
  P_clk: Process
  begin
    if finsimul = '0' then
      clk  <= '0';
      wait for 5 ns;
      clk  <= '1';
      wait for 5 ns;
    else
      wait;
    end if;
  end process;
	
  P_stim: Process
  begin
    start <= '0';
    fact1 <= (others => '0');
    fact2 <= (others => '0');
    -- reset
    rst <= c_off;
    wait for 35 ns;
    rst <= c_on;
    wait for 40 ns;
    rst <= c_off;
    wait for 136 ns;
    -- fin reset
    -- factores sin start --------------
    fact1 <= to_unsigned (2**g_bits-1, g_bits);
    fact2 <= to_unsigned (2**g_bits-2, g_bits);
    wait for 20 ns;
    -- start largo --------------
    start <= '1';
    wait for 300 ns;
    start <= '0';
    wait for 221 ns;
    -- factores con start --------------
    fact1 <= to_unsigned (2**g_bits-2, g_bits);
    fact2 <= to_unsigned (2**g_bits-2, g_bits);
    start <= '1';
    wait until clk'event and clk='1';
    start <= '0';
    wait until clk'event and clk='1';
    start <= '1';
    wait until clk'event and clk='1';
    start <= '0';
    wait for 151 ns;
    -- pruebas de multiplicacion
    for i in 0 to 2**g_bits-1 loop
      fact1 <= to_unsigned (i, g_bits);
      for j in 0 to 2**g_bits-1 loop
        fact2 <= to_unsigned (j, g_bits);
        start <= '1';
        wait until clk'event and clk='1';
        start <= '0';
        wait until finmult = '1';
        assert prod = i*j 
           report "Fallo en la multiplicacion"
           severity ERROR;
        wait until clk'event and clk='1';
      end loop;
    end loop;
    finsimul <= '1';
    wait;
  end process;
	
END;
