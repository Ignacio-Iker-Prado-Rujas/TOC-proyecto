--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
--------------------------------------------------------------------------------
-- multiplicacion hecha secuencialmente
-- sin los prefijos para simplificar
-- Resultado valido solo cuando finmult se pone a uno. durante un
-- solo ciclo de reloj

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.MULT_PKG.ALL;

entity mult_seq_gen_libro is
 Generic (
   g_bits   : natural := 8
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
end mult_seq_gen_libro;

architecture behavioral of mult_seq_gen_libro is

  -- para 7, el logaritmo da 2: 2 downto 0 -> 3 bits
  -- para 8, el logaritmo da 3: 2 downto 0 es suficiente
  -- para 9, el logaritmo da 3: 2 downto 0 no es suficiente
  -- por eso se hace el logaritmo de los bits menos 1
  constant c_nb_contbits : natural := log2i(g_bits-1);
  signal   contbits_us   : unsigned (c_nb_contbits downto 0);
  signal   contbits      : natural range 0 to 2**(c_nb_contbits+1)-1;
  signal   fincontbits   : std_logic;
  signal   cargafact     : std_logic;

  signal   fact1_rg      : unsigned (g_bits-1 downto 0);
  signal   fact2_rg      : unsigned (g_bits-1 downto 0);
  signal   sum_anded     : unsigned (g_bits-1 downto 0);
  signal   resul         : unsigned (g_bits downto 0);
  -- resul_rg tiene un bit menos, porque no guarda el bit menos significativo
  -- ya que va a prod_rg
  signal   resul_rg      : unsigned (g_bits-1 downto 0);
  signal   prod_rg       : unsigned (2*g_bits-1 downto 0);

  type     estados_mult is (e_init, e_mult, e_fin);
  signal   estado_act, estado_sig  : estados_mult;

begin

  P_control_seq: Process(rst,clk)
  begin
    if rst = c_on then
      estado_act <= e_init;
    elsif clk'event and clk='1' then
      estado_act <= estado_sig;
    end if;
  end process;

  P_control_comb: Process (estado_act, start, fincontbits)
  begin
    cargafact <= '0';
    finmult    <= '0';
    case estado_act is
      when e_init =>
        if start = '1' then
          estado_sig <= e_mult;
          cargafact  <= '1';
        else
          estado_sig <= e_init;
        end if;
      when e_mult =>
        if fincontbits = '1' then
          estado_sig <= e_fin;
        else
          estado_sig <= e_mult;
        end if;
      when e_fin =>
        estado_sig <= e_init;
        finmult    <= '1';
    end case;
  end process;


  -- Carga los factores con la orden de multiplicar
  P_cargafact: Process (rst, clk)
  begin
    if rst = c_on then
      fact1_rg <= (others => '0');
      fact2_rg <= (others => '0');
    elsif clk'event and clk='1' then
      if cargafact = '1' then
        fact1_rg <= fact1;
        fact2_rg <= fact2;
      elsif estado_act = e_fin then
        fact1_rg <= (others => '0');
        fact2_rg <= (others => '0');
      end if;
    end if;
  end process;
 
  -- cuenta los bits que se van multiplicando
  P_cuenta_bits: Process (rst, clk)
  begin
    if rst = c_on then
      contbits_us <= (others =>'0');
    elsif clk'event and clk='1' then
      if estado_act = e_mult then
        contbits_us <= contbits_us + 1;
      else
        contbits_us <= (others =>'0');
      end if;
    end if;
  end process;

  fincontbits <= '1' when contbits=g_bits-1 else '0';

  -- para los rangos se necesita un entero
  contbits <= to_integer(contbits_us);

  -- la multiplicacion parcial del bit de fact2 con fact1,
  -- teniendo en cuenta el desplzamiento
  sum_anded <= fact1_rg when fact2_rg(contbits) = '1' else
               (others => '0');
  resul     <= ('0' & resul_rg) + ('0' & sum_anded);


  -- Acumula las sumas parciales de las multiplicaciones de bits
  P_acum_mult: Process (rst, clk)
  begin
    if rst = c_on then
      resul_rg <= (others => '0');
      prod_rg  <= (others => '0');
    elsif clk'event and clk='1' then
      case estado_act is
        when e_init | e_fin =>
          resul_rg <= (others => '0');
          prod_rg  <= (others => '0');
        when e_mult =>
          if fincontbits = '0' then
            resul_rg <= resul(g_bits downto 1);
            prod_rg(contbits) <= resul(0);
          else
            resul_rg <= (others => '0'); -- ya no hace falta resul_rg
            prod_rg(2*g_bits-1 downto contbits) <= resul; --se guarda en prod_rg
          end if;
      end case;
    end if;
  end process;

  prod <= prod_rg;

end behavioral;

