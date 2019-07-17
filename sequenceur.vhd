library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity sequenceur is

port(H,R: in std_logic;
	 C3EQREG4In : in std_logic;
	 C3EQ13In   : in std_logic;
	 C3EQ14In   : in std_logic;
	 EofIn      : in std_logic;
	 SofIn      : in std_logic;
	 emptyIn    : in std_logic;
	 C2EQFIn    : in std_logic;
	 C2EQ144In  : in std_logic;
	 ---------------------------
	 readOut    : out std_logic;
	 LD1Out     : out std_logic;
	 LD2Out     : out std_logic;
	 LD3Out     : out std_logic;							
	 DEC1Out    : out std_logic;
	 selOut     : out std_logic_vector(1 downto 0);
	 init_prOut : out std_logic;
	 dec_prOut  : out std_logic;
	 INC2Out     : out std_logic;
	 RAZ2Out    : out std_logic;
	 INC3Out    : out std_logic;
	 RAZ3Out    : out std_logic;
	 LD4Out     : out std_logic;
	 RAZ4Out    : out std_logic;
	 Decregout : out std_logic);
	 
	-----------------------------------
end sequenceur;

architecture asequenceur of sequenceur is 

type etat_13 is (m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17);
				 
signal etat, etat_suiv: etat_13;

begin
process(h, R)
begin
if R = '1' then etat <= m0;
elsif falling_edge(h) then etat <= etat_suiv;
end if;
end process;
		
process(etat, emptyIn, C2EQFIn, 
		c2eq144In, C3EQ13In, C3EQ14In,  				 
		C3EQREG4In, SofIn, EofIn)
begin

readOut <= '0' ;
		readOut <= '0' ;
		init_prOut <= '0' ;
		SelOut <= "00" ;
		INC2Out <= '0' ;
		INC3Out <= '0' ;
		RAZ4Out <= '0';
		RAZ2Out <= '0';
		RAZ3Out <= '0';
		dec_prOut <= '0' ;
		LD1Out <= '0' ;
		DEC1Out <= '0' ;
		LD2Out <=  '0' ;  
		LD3Out <= '0' ;
		LD4Out <= '0' ;
		Decregout <= '0' ;


case etat is 
	when m0 =>
		init_prOut <= '0' ;
		RAZ4Out <= '1';
		RAZ2Out <= '1';
		RAZ3Out <= '1';
		
		
		if emptyIn = '1' then etat_suiv <= m0;
		else etat_suiv <= m1;
		end if;
		
	when m1 =>
		init_prOut <= '1';
		
		etat_suiv <= m2;
		
	when m2 =>
		
		Decregout <= '1'; 
		INC2Out <= '1';
		
		
		
		if c2eq144In = '1' then etat_suiv <= m4;
		else etat_suiv <= m3;
		end if;
	when m3 =>
		dec_prOut <= '1';
		etat_suiv <= m2;
		
	when m4 =>			
		
		INC2Out <= '0';
		readOut <= '1';
		INC3Out <= '1'; 
		RAZ2Out <= '1';
		etat_suiv <= m5;
	
	when m5 =>
		readOut <= '0';
		INC3Out <= '0';
		LD1Out <= '1' ;
		
		etat_suiv <= m6;
		
	when m6 =>
		SelOut <= "01";
		LD1Out <= '0';
		etat_suiv <= m7;
		

		
	when m7 =>
		
		SelOut <= "01";
		DEC1Out <= '1' ;
		Decregout <= '1' ;
		INC2Out <= '1';

		if C2EQFIn = '1' then etat_suiv <= m8;
		else etat_suiv <= m7;
		end if; 

	when m8 =>
		Decregout <= '0' ;
		DEC1Out <= '0' ;

		if C3EQ13In= '1' then 
		etat_suiv <= m9;
		else etat_suiv <= m10;
		end if;
		
	when m9 =>
		LD2Out <= '1';
		etat_suiv <= m10; 
		
		 						
	when m10 => 
	if C3EQ14In = '1' then etat_suiv <= m12;
	else etat_suiv <= m11;
	end if;
	
	when m11 => 
		if C3EQREG4In = '1' then etat_suiv <= m13;
		else
		etat_suiv <= m14;
		end if ;
	when m12 =>
		LD3Out <= '1';
		
		etat_suiv <= m15;					
			
	when m13 =>
		SelOut <= "10";
		Decregout <= '1';
	
		if SofIn = '1' then etat_suiv <= m17;
		else etat_suiv <= m13;				
		end if;

	when m14 =>
		LD2Out <= '0';
		if emptyIn = '1' then etat_suiv <= m14;
		else etat_suiv <=m4;
		end if;

	when m15 =>
		LD3Out <= '0';
		LD4Out <= '1';
		
		etat_suiv <= m16;				
	when m16 =>
		LD4Out <= '0';
		if emptyIn = '1' then etat_suiv <= m16;
		else etat_suiv <=m4;
		end if;
	
	when m17 =>
		Decregout <= '1';
		if EofIn = '1' then etat_suiv <= m0;
		else etat_suiv <= m17;
		end if;
		
	end case;
end process;

end architecture;