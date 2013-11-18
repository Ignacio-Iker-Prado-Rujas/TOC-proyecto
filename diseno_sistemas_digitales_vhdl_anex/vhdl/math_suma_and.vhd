--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
--------------------------------------------------------------------------------
-- Se suman los sumandos, pero al segundo se le hace la and con el puerto
-- p_and. Es decir, si p_and = '0', el resultado sera el mismo que p_sum_us4
-- si p_and = '1' el resultado sera la suma de ambos

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity suma_and is
    port (
      sum      : in  unsigned (3 downto 0);
      sum_and  : in  unsigned (3 downto 0);
      p_and    : in  std_logic;
      resul    : out unsigned (4 downto 0)
    );
end suma_and;

architecture behavioral of suma_and is

  signal sum_anded : unsigned (3 downto 0);

begin

  sum_anded <= sum_and when p_and = '1' else
               (others => '0');

  resul <= ('0' & sum) + ('0' & sum_anded);

end behavioral;

