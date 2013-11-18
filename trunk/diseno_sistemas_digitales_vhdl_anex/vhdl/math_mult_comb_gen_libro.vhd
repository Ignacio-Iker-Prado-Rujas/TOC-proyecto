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

entity mult_comb_gen is
 Generic (
   gbits   : natural := 16
 );
 Port (
   fact1   : in  unsigned (gbits-1 downto 0);
   fact2   : in  unsigned (gbits-1 downto 0);
   prod    : out unsigned (2*gbits-1 downto 0)
  );
end mult_comb_gen;

architecture behavioral of mult_comb_gen is

  type t_vector_sumand is array (1 to gbits) of unsigned (gbits-1 downto 0);
  type t_vector_resul is array (1 to gbits) of unsigned (gbits downto 0);

  signal sum_anded : t_vector_sumand;
  signal resul : t_vector_resul;

begin

  -- primera etapa
  sum_anded(1) <= fact1 when fact2(0) = '1' else
                (others => '0');
  resul(1)     <= '0' & sum_anded(1);
  prod(0)    <= resul(1)(0);


  gen_mult: for i in 1 to gbits-1 generate
  
    sum_anded(i+1) <= fact1 when fact2(i)='1' else
                      (others =>'0');
    resul(i+1) <= ('0' & resul(i)(gbits downto 1)) + ('0' & sum_anded(i+1));
    prod(i)    <= resul(i+1)(0);

  end generate;

  prod(2*gbits-1 downto gbits) <= resul(gbits)(gbits downto 1);  



end behavioral;

