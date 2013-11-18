--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
--------------------------------------------------------------------------------
-- multiplicacion hecha combinacionalmente
-- sin los prefijos para simplificar
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult_comb is
 Port (
   fact1   : in  unsigned (3 downto 0);
   fact2   : in  unsigned (3 downto 0);
   prod    : out unsigned (7 downto 0)
  );
end mult_comb;

architecture behavioral of mult_comb is

  signal sum_anded1 : unsigned(3 downto 0);
  signal sum_anded2 : unsigned(3 downto 0);
  signal sum_anded3 : unsigned(3 downto 0);
  signal sum_anded4 : unsigned(3 downto 0);

  signal resul1    : unsigned(4 downto 0);
  signal resul2    : unsigned(4 downto 0);
  signal resul3    : unsigned(4 downto 0);
  signal resul4    : unsigned(4 downto 0);


begin

  -- primera etapa
  sum_anded1 <= fact1 when fact2(0) = '1' else
                (others => '0');
  resul1     <= '0' & sum_anded1;
  prod(0)    <= resul1(0);

  -- segunda etapa
  sum_anded2 <= fact1 when fact2(1) = '1' else
                (others => '0');
  resul2     <= ('0' & resul1(4 downto 1)) + ('0' & sum_anded2);
  prod(1)    <= resul2(0);

  -- tercera etapa
  sum_anded3 <= fact1 when fact2(2) = '1' else
                (others => '0');
  resul3     <= ('0' & resul2(4 downto 1)) + ('0' & sum_anded3);
  prod(2)    <= resul3(0);

  -- cuarta etapa
  sum_anded4 <= fact1 when fact2(3) = '1' else
                (others => '0');
  resul4     <= ('0' & resul3(4 downto 1)) + ('0' & sum_anded4);

  -- final:
  prod(7 downto 3) <= resul4;

end behavioral;

