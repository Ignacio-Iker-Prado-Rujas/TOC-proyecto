
Red iterativa que calcula la paridad de un número a través de puertas XOR, la salida de cada puerta XOR se conecta a la puerta XOR contigua.


entity xor_par is
	generic( N: integer := 32; retardo: time := 1 ns);
	port(A: in std_logic_vector(N-1 downto 0); par: out std_logic); 
end xor_par;

architecture Behavioral of xor_par is

signal par_aux: std_logic_vector(N downto 0);

begin

	par_aux(0)<='0';

	iterativo: for i in 0 to N-1 generate

		par_aux(i+1)<=par_aux(i) xor A(i) after retardo; 

	end generate iterativo;
	
	par<=par_aux(N);

end Behavioral;

Simulación



















Red que calcula la paridad de un número a través de puertas XOR, la salida de cada puerta XOR se conecta a la puerta XOR de la fila inferior formando un triángulo.



entity xor_par is
   generic(K: integer :=5; --K es log(32) en base 2
		retardo: time := 1 ns);
   port (A: in std_logic_vector(2**K-1 downto 0); par: out std_logic); 
end xor_par;

architecture Behavioral of xor_par is

type aux is array (0 to K) of std_logic_vector(2**K-1 downto 0);
signal par_aux: aux;

begin

   par_aux(K)<= A;
   par<=par_aux(0)(0);

   triangulo: for j in K downto 1 generate
     iterativo: for i in 0 to ((2**j)/2)-1 generate
	par_aux(j-1)(i)<= par_aux(j)(2*i) xor par_aux(j)(2*i+1) after retardo; 
	end generate iterativo;
   end generate triangulo;

end Behavioral;


