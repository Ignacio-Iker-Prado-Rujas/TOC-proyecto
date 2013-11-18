--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_mult_struct IS
END tb_mult_struct;

ARCHITECTURE TB OF tb_mult_struct IS 
  COMPONENT mult_struct
    Port (
      fact1   : in  unsigned (3 downto 0);
      fact2   : in  unsigned (3 downto 0);
      prod    : out unsigned (7 downto 0)
    );
  END COMPONENT;

  signal fact1, fact2 : unsigned (3 downto 0);
  signal prod         : unsigned (7 downto 0);

BEGIN

  uut: mult_struct
  port map(
    fact1  => fact1,
    fact2  => fact2,
    prod   => prod
  );
    
	
  P_stim: Process
  begin
    fact1 <= "0001";
    fact2  <= "0101";
    wait for 100 ns;
    fact1 <= "0010";
    fact2  <= "0101";
    wait for 100 ns;
    fact1 <= "0101";
    fact2  <= "0011";
    wait for 100 ns;
    fact1 <= "0101";
    fact2  <= "0100";
    wait for 100 ns;
    fact1 <= "0111";
    fact2  <= "0100";
    wait for 100 ns;
    fact1 <= "0001";
    fact2  <= "1101";
    wait for 100 ns;
    fact1 <= "1001";
    fact2  <= "0101";
    wait for 100 ns;
    fact1 <= "1001";
    fact2  <= "1101";
    wait for 100 ns;
    fact1 <= "1001";
    fact2  <= "1111";
    wait for 100 ns;
    fact1 <= "1001";
    fact2  <= "0000";
    wait for 100 ns;
    fact1 <= "0000";
    fact2  <= "1101";
    wait for 100 ns;
    fact1 <= "0000";
    fact2  <= "0000";
    wait for 100 ns;
    fact1 <= "1111";
    fact2  <= "1101";
    wait for 100 ns;
    fact1 <= "1111";
    fact2  <= "1111";
    wait for 100 ns;
    fact1 <= "0111";
    fact2  <= "1101";
    wait for 100 ns;
    fact1 <= "0111";
    fact2  <= "0101";
    wait;
  end process;

END;
