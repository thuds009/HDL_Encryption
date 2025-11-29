Library ieee;

use ieee.std_logic_1164.all;	 

entity mixColumn is
	port (
	shifted_key : in std_logic_vector(127 downto 0);
	mixed_state : out std_logic_vector(127 downto 0)
	);

end entity mixColumn;

architecture behavioral of mixColumn is

-- multiply by two
	function mul2(x : std_logic_vector(7 downto 0)) return std_logic_vector is 
	variable temp : std_logic_vector(7 downto 0);
	begin
		if x(7) = '1' then --if MSB reduction is necessary 
			temp := (x(6 downto 0) & '0') xor x"1B";
		else
			temp := (x(6 downto 0) & '0');
		end if;
		return temp;
	end function;

--multiply by 3 = mul2 XOR x 
	function mul3(x : std_logic_vector(7 downto 0)) return std_logic_vector is 
	begin
   		return mul2(x) xor x;
	end function;

-- column byte signals

signal a0, a1, a2, a3 : std_logic_vector(7 downto 0);
signal b0, b1, b2, b3 : std_logic_vector(7 downto 0);

signal c0, c1, c2, c3 : std_logic_vector(7 downto 0);
signal d0, d1, d2, d3 : std_logic_vector(7 downto 0);

signal e0, e1, e2, e3 : std_logic_vector(7 downto 0);
signal f0, f1, f2, f3 : std_logic_vector(7 downto 0);

signal g0, g1, g2, g3 : std_logic_vector(7 downto 0);
signal h0, h1, h2, h3 : std_logic_vector(7 downto 0);

begin

--column 0
a0 <= shifted_key(127 downto 120);
a1 <= shifted_key(95 downto 88);
a2 <= shifted_key(63 downto 56);
a3 <= shifted_key(31 downto 24); 

b0 <= mul2(a0) xor mul3(a1) xor      a2  xor      a3;
b1 <=      a0  xor mul2(a1) xor mul3(a2) xor      a3;
b2 <=      a0  xor      a1  xor mul2(a2) xor mul3(a3);
b3 <= mul3(a0) xor      a1  xor      a2  xor mul2(a3);


--column 1
c0 <= shifted_key(119 downto 112);
c1 <= shifted_key(87 downto 80);
c2 <= shifted_key(55 downto 48);
c3 <= shifted_key(23 downto 16); 

d0 <= mul2(c0) xor mul3(c1) xor      c2  xor      c3;
d1 <=      c0  xor mul2(c1) xor mul3(c2) xor      c3;
d2 <=      c0  xor      c1  xor mul2(c2) xor mul3(c3);
d3 <= mul3(c0) xor      c1  xor      c2  xor mul2(c3);


--column 2
e0 <= shifted_key(111 downto 104);
e1 <= shifted_key(79 downto 72);
e2 <= shifted_key(47 downto 40);
e3 <= shifted_key(15 downto 8);	

f0 <= mul2(e0) xor mul3(e1) xor      e2  xor      e3;
f1 <=      e0  xor mul2(e1) xor mul3(e2) xor      e3;
f2 <=      e0  xor      e1  xor mul2(e2) xor mul3(e3);
f3 <= mul3(e0) xor      e1  xor      e2  xor mul2(e3);


--column 3					   
g0 <= shifted_key(103 downto 96);
g1 <= shifted_key(71 downto 64);
g2 <= shifted_key(39 downto 32);
g3 <= shifted_key(7 downto 0);

h0 <= mul2(g0) xor mul3(g1) xor 	 g2	 xor	 g3; 
h1 <= 		g0 xor mul2(g1) xor mul3(g2) xor	 g3;
h2 <= 		g0 xor 	 	g1	xor mul2(g2) xor mul3(g3);
h3 <= mul3(g0) xor		g1	xor		 g2	 xor mul2(g3);

mixed_state <=
    b0 & c0 & e0 & h0 &
    b1 & c1 & e1 & h1 &
    b2 & c2 & e2 & h2 &
    b3 & c3 & e3 & h3;

end architecture behavioral;	