--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
--------------------------------------------------------------------------------
-- multiplicacion hecha combinacionalmente
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult_struct is
 port (
   fact1   : in  unsigned (3 downto 0);
   fact2   : in  unsigned (3 downto 0);
   prod    : out unsigned (7 downto 0)
  );
end mult_struct;

architecture behavioral of mult_struct is

  constant c_cero : unsigned (3 downto 0) := "0000";
  signal resul0 : unsigned (4 downto 0);
  signal resul1 : unsigned (4 downto 0);
  signal resul2 : unsigned (4 downto 0);
  signal resul3 : unsigned (4 downto 0);

  component suma_and is
    port (
      sum     : in  unsigned (3 downto 0);
      sum_and : in  unsigned (3 downto 0);
      p_and   : in  std_logic;
      resul   : out unsigned (4 downto 0)
    );
  end component;

begin

  C_SUM_AND0: suma_and
    port map (
      sum     => c_cero,
      sum_and => fact1,
      p_and   => fact2(0),
      resul   => resul0
    );
  prod(0) <= resul0(0);

  C_SUM_AND1: suma_and
    port map (
      sum     => resul0 (4 downto 1),
      sum_and => fact1,
      p_and   => fact2(1),
      resul   => resul1
    );
  prod(1) <= resul1(0);

  C_SUM_AND2: suma_and
    port map (
      sum     => resul1 (4 downto 1),
      sum_and => fact1,
      p_and   => fact2(2),
      resul   => resul2
    );
  prod(2) <= resul2(0);

  C_SUM_AND3: suma_and
    port map (
      sum     => resul2 (4 downto 1),
      sum_and => fact1,
      p_and   => fact2(3),
      resul   => resul3
    );
  prod(7 downto 3) <= resul3;

end behavioral;

