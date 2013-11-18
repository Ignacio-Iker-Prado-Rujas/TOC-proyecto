--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_mult_struct_gen IS
 Generic (
   g_bits   : natural := 8
 );
END tb_mult_struct_gen;

ARCHITECTURE TB OF tb_mult_struct_gen IS 
  COMPONENT mult_struct_gen
    Generic (
      g_bits   : natural := 4
    );
    Port (
      fact1   : in  unsigned (g_bits-1 downto 0);
      fact2   : in  unsigned (g_bits-1 downto 0);
      prod    : out unsigned (2*g_bits-1 downto 0)
    );
  END COMPONENT;

  signal fact1, fact2 : unsigned (g_bits-1 downto 0);
  signal prod         : unsigned (2*g_bits-1 downto 0);

BEGIN

  uut: mult_struct_gen
  generic map (
    g_bits  => g_bits
  )
  port map(
    fact1  => fact1,
    fact2  => fact2,
    prod   => prod
  );
    
	
  P_stim: Process
  begin
    for i in 0 to 2**g_bits-1 loop
      fact1 <= to_unsigned (i, g_bits);
      for j in 0 to 2**g_bits-1 loop
        fact2 <= to_unsigned (j, g_bits);
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
