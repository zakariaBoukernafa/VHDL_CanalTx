library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-- A BASIC UNIT MUX(3 INTO 1) THROUGH A 2 BITS VECTOR 
entity mux is 

port(H,R,	 Reg1in : in std_logic;
	 sel : in std_logic_vector(1 downto 0);
	 emetteurPreambule: in std_logic;
	 mux_out : out std_logic);
	 
end entity;

architecture amux of mux is 
begin
with sel select mux_out <=
emetteurPreambule when "00",
reg1in when "01",
'0' when "10",
'0' when others ;
end amux ;	 


	 
	 