library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-- A BASIC UNIT MUX(3 INTO 1) THROUGH A 2 BITS VECTOR 
entity mux is 

port(H,R,sel0,sel1,sel2 :in std_logic;
	 Reg1in : in std_logic;
	 emetteurPreambule: in std_logic;
	 mux_out : out std_logic);
	 
end entity;

architecture amux of mux is 
signal sel : std_logic_vector(1 downto 0);
begin 
process(H,R, sel0, sel1, sel2)
	begin
		if R = '1' then
			sel <= "00";
		elsif rising_edge(H) then
			if sel0 = '1' then
				sel <= "00";
			elsif sel1 = '1' then
				sel <= "01";
			elsif sel2 = '1' then
				sel <= "10";

			end if;
		end if ;
	end process;
process(h)
begin 
	if rising_edge(h) then
		if sel = "00" then
			mux_out <= emetteurPreambule;
		elsif sel = "01" then
			mux_out <= Reg1in;
		else
			mux_out <= '0';	
		end if;
	end if;
end process;
		 

end amux ;	 
	 
	 