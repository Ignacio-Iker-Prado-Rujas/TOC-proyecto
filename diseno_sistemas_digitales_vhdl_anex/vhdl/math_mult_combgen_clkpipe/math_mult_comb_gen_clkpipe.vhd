--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
--------------------------------------------------------------------------------
-- multiplicacion hecha combinacionalmente, con biestables en los puertos
-- para comprobar retardos
-- y con pipeline para disminuir tiempos
-- sin los prefijos para simplificar
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult_comb_gen_clkpipe is
 Generic (
   g_bits   : natural := 4
 );
 Port (
   clk     : in  std_logic;
   fact1   : in  unsigned (g_bits-1 downto 0);
   fact2   : in  unsigned (g_bits-1 downto 0);
   prod    : out unsigned (2*g_bits-1 downto 0)
  );
end mult_comb_gen_clkpipe;

architecture behavioral of mult_comb_gen_clkpipe is

  type t_vector_fact  is array (1 to g_bits) of unsigned (g_bits-1 downto 0);
  type t_vector_resul is array (1 to g_bits) of unsigned (g_bits downto 0);

  signal sum_anded    : t_vector_fact;
  -- la mitad inferior de prod, que se va manteniendo para abajo
  signal prod_rg      : t_vector_fact; 
  signal fact1_rg     : t_vector_fact; 
  signal fact2_rg     : t_vector_fact; 
  signal resul_rg     : t_vector_fact;
  signal resul        : t_vector_resul;

begin

  -- primera etapa
  sum_anded(1) <= fact1_rg(1) when fact2_rg(1)(0) = '1' else
                  (others => '0');
  resul(1)     <= '0' & sum_anded(1);

  P_reg_1e: Process (clk)  
  begin
    if clk'event and clk='1' then
      fact1_rg(1)    <= fact1;  -- registramos entradas
      fact2_rg(1)    <= fact2;
      resul_rg(1)    <= resul(1)(g_bits downto 1);  -- registramos resultados
      prod_rg (1)(0) <= resul(1)(0);
    end if;
  end process;

  -- resto de etapas

  gen_mult: for i in 2 to g_bits generate
  
    sum_anded(i) <= fact1_rg(i) when fact2_rg(i)(i-1)='1' else
                      (others =>'0');
    resul(i) <= ('0' & resul_rg(i-1)) + ('0' & sum_anded(i));

    P_resuli_rg: Process (clk)
    begin
      if clk'event and clk='1' then
        fact1_rg(i)     <= fact1_rg(i-1);
        fact2_rg(i)     <= fact2_rg(i-1);
        resul_rg(i)     <= resul(i)(g_bits downto 1);
        prod_rg(i)(i-1) <= resul(i)(0);
        prod_rg(i)(i-2 downto 0) <= prod_rg(i-1)(i-2 downto 0); 
      end if;
    end process;

  end generate;

  P_prod_rg: Process (clk)
  begin
    if clk'event and clk='1' then
      prod(2*g_bits-1 downto g_bits) <= resul(g_bits)(g_bits downto 1);  
    end if;
  end process;

  -- prod_rg ya esta registrado
  prod(g_bits-1 downto 0) <= prod_rg(g_bits)(g_bits-1 downto 0);

end behavioral;

