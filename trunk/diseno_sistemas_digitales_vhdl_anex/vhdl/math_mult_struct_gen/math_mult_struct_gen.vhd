--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
--------------------------------------------------------------------------------
-- multiplicacion estructural con generate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult_struct_gen is
 generic (
   g_bits   : natural := 32
 );
 port (
   fact1   : in  unsigned (g_bits-1 downto 0);
   fact2   : in  unsigned (g_bits-1 downto 0);
   prod    : out unsigned (2*g_bits-1 downto 0)
  );
end mult_struct_gen;

architecture behavioral of mult_struct_gen is

  type   t_vector_resul is array (0 to g_bits) of unsigned (g_bits downto 0);
  signal resul   : t_vector_resul;

  component suma_and is
    generic (
      g_bits   : natural := 4
    );
    port (
      sum     : in  unsigned (g_bits-1 downto 0);
      sum_and : in  unsigned (g_bits-1 downto 0);
      p_and   : in  std_logic;
      resul   : out unsigned (g_bits downto 0)
    );
  end component;

begin

  resul(0) <= (others => '0');

  GEN_SUMA: for i in 0 to g_bits-1 generate

    C_SUM_AND: suma_and
      generic map (
        g_bits  => g_bits
      )
      port map (
        sum     => resul(i)(g_bits downto 1),
        sum_and => fact1,
        p_and   => fact2(i),
        resul   => resul(i+1)
      );

      prod(i) <= resul(i+1)(0);

  end generate;

  prod(2*g_bits-1 downto g_bits) <= resul(g_bits)(g_bits downto 1);


end behavioral;

