--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_mult_comb_gen IS
 Generic (
   gbits   : natural := 5
 );
END tb_mult_comb_gen;

ARCHITECTURE TB OF tb_mult_comb_gen IS 
  COMPONENT mult_comb_gen
    Generic (
      gbits   : natural := 4
    );
    Port (
      fact1   : in  unsigned (gbits-1 downto 0);
      fact2   : in  unsigned (gbits-1 downto 0);
      prod    : out unsigned (2*gbits-1 downto 0)
    );
  END COMPONENT;

  signal fact1, fact2 : unsigned (gbits-1 downto 0);
  signal prod         : unsigned (2*gbits-1 downto 0);

BEGIN

  uut: mult_comb_gen
  generic map (
    gbits  => gbits
  )
  port map(
    fact1  => fact1,
    fact2  => fact2,
    prod   => prod
  );
    
	
  P_stim: Process
  begin
    for i in 0 to 2**gbits-1 loop
      fact1 <= to_unsigned (i, gbits);
      for j in 0 to 2**gbits-1 loop
        fact2 <= to_unsigned (j, gbits);
        wait for 50 ns;
        assert prod = i*j 
           report "Fallo en la multiplicacion"
           severity ERROR;
        wait for 50 ns;
      end loop;
    end loop;
    wait;
  end process;

END;
