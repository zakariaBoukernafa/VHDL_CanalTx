LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
--/*CREATED BY ZAKARIA BOUKERNAFA,BOUCHIBA NAZIHA
--M1 ESE 2018-2019 USTO'S UNIVERSITY */ 

ENTITY canal_tx IS
	PORT
	(
		h, R : IN std_logic;
		full : OUT std_logic;
		Din : IN std_logic_vector(7 DOWNTO 0);
		write_fifo : IN std_logic; -- fifo
		Tx : OUT std_logic

	);

END ENTITY;

ARCHITECTURE acanal_tx OF canal_tx IS
	-------------------------- Signal -------------------------------
	SIGNAL fifo_out : std_logic_vector(7 DOWNTO 0); -- fifo
	SIGNAL read_fifo : std_logic; -- fifo
	SIGNAL empty : std_logic; -- fifo
	SIGNAL manchester_out : std_logic_vector(15 DOWNTO 0); --manchester
	SIGNAL LD1, DEC1 : std_logic; -- REG1 
	SIGNAL sel : std_logic_vector(1 downto 0);-- MUX
	SIGNAL mux_out : std_logic;
	SIGNAL init_pr, dec_pr : std_logic; -- Preambule
	SIGNAL Decregout : std_logic; -- Regout
	SIGNAL SOF, EOF : std_logic; -- Regout
	SIGNAL LD2, LD3 : std_logic; -- 13,14 bits of fifo
	SIGNAL INC3, RAZ3 : std_logic; -- C3
	SIGNAL INC2, RAZ2 : std_logic; -- C2
	SIGNAL LD4, RAZ4 : std_logic; -- REG4
	SIGNAL C3EQREG4 : std_logic; -- C3 equales Reg4
	SIGNAL C3EQ13 : std_logic; -- C3 equales 13
	SIGNAL C3EQ14 : std_logic; -- C3 equales 14
	SIGNAL C2EQ144 : std_logic; -- C3 Equales 144
	SIGNAL C2EQF : std_logic; -- C2 Equales 15
	SIGNAL C3_out : std_logic_vector(15 DOWNTO 0); -- C3
	SIGNAL C2_out : std_logic_vector (7 DOWNTO 0); -- C2
	SIGNAL adder_out : std_logic_vector(15 DOWNTO 0); -- Adder
	SIGNAL Reg1_out : std_logic; -- Reg1
	SIGNAL Dout4 : std_logic_vector(15 DOWNTO 0); --  REG4 
	SIGNAL PreaumbuleDout : std_logic; -- Preambule
	SIGNAL RegLOut : std_logic_vector(7 DOWNTO 0); -- REGL
	SIGNAL RegHOut : std_logic_vector (7 DOWNTO 0); -- REGH
		------------------------ component --------------------------
	-----  manchester -----
	COMPONENT manchester
		PORT
		(
			datain : IN std_logic_vector(7 DOWNTO 0);
			dataout : OUT std_logic_vector(15 DOWNTO 0));

	END COMPONENT;
	------------------------------- fifo -----------------------
	COMPONENT fifo
		PORT
		(
			clock : IN STD_LOGIC;
			data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdreq : IN STD_LOGIC;
			wrreq : IN STD_LOGIC;
			empty : OUT STD_LOGIC;
			full : OUT STD_LOGIC;
			q : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT BM_Tx
		PORT
		(
			Din, h, reset : IN std_logic;
			PR : OUT std_logic_vector(1311 DOWNTO 0)
		);
	END COMPONENT;
	------------------------Reg1 -----------------------------
	COMPONENT Reg1
		PORT
		(
			h, r, ld1, dec1 : IN std_logic;
			din_reg1 : IN std_logic_vector(15 DOWNTO 0);
			dout_reg1 : OUT std_logic);
	END COMPONENT;
	----------------------------mux----------------------------
	COMPONENT mux
		PORT
		(
			h, R : IN std_logic;
			Reg1in : IN std_logic;
		 sel : in std_logic_vector(1 downto 0);
			emetteurPreambule : IN std_logic;
			mux_out : OUT std_logic);

	END COMPONENT;
	------------------------------ preaumbule -----------------------
	COMPONENT p_emetteur
		PORT
		(
			H, R, dec_pr, Init_pr : IN std_logic;
		pr : OUT std_logic);
	END COMPONENT;
	-----------------------------REGOUT----------------------------	
	COMPONENT RegOut
		PORT
		(
			h, r, decregout, muxIn, C3EQREG4 : IN std_logic;
			C3 : IN std_logic_vector(15 DOWNTO 0);
			sof, eof, Tx : OUT std_logic);
	END COMPONENT;

	----------------------C3---------------------------
	COMPONENT C3

		PORT
		(
			H, INC3, Raz3 : IN std_logic;
			C3eq13, C3eq14 : OUT std_logic;
			C3out : OUT std_logic_vector(15 DOWNTO 0)
		);

	END COMPONENT;
	-----------------------C2-----------------------------
	COMPONENT C2
		PORT
		(
			H, INC2, RAZ2 : IN std_logic;
			C2EQF, C2EQ144 : OUT std_logic
		);
	END COMPONENT;
	----------------------RegH---------------------------
	COMPONENT RegH
		PORT
		(
		H, R, LD : IN std_logic;
		fifo14 : IN std_logic_vector(7 DOWNTO 0);
		data_out : OUT std_logic_vector(7 DOWNTO 0)
		);
	END COMPONENT;
	----------------------RegL-----------------------------	 
	COMPONENT RegL IS
		PORT
		(
		H, R, LD : IN std_logic;
		fifo13 : IN std_logic_vector(7 DOWNTO 0);
		data_out : OUT std_logic_vector(7 DOWNTO 0)
		);
	END COMPONENT;
	----------------------Reg4----------------------------------
	COMPONENT Reg4 IS
		PORT
		(
			H, RAZ4, LD4 : IN std_logic;
			C3 : IN std_logic_vector(15 DOWNTO 0);
			RegL : IN std_logic_vector(7 DOWNTO 0);
			RegH : IN std_logic_vector(7 DOWNTO 0);
			C3eqREG4 : OUT std_logic
		);
	END COMPONENT;
	-----------------------adder--------------------------------
	COMPONENT adder IS
		PORT
		(
			RegL : IN std_logic_vector(7 DOWNTO 0);
			RegH : IN std_logic_vector(7 DOWNTO 0);
			C3 : IN std_logic_vector(15 DOWNTO 0);
			adder_out : OUT std_logic_vector(15 DOWNTO 0)
		);
	END COMPONENT;
	------------------------------------SEQUENCEUR------------------------------------------------
--/* THIS UNIT IS MADE TO CONTROL EVERY SIGNAL COMING 
--   FROM-TO ALL OTHER UNITS DEPENDING ON THE RESAULT OF EACH UNIT OPERATIONSµ
--   AND COMMAND THE ACTIVATION BY CHANING FLAGS IN FORM OF A SIGNAL */ 
COMPONENT sequenceur is
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
end component;
begin 
--------------------PORTMAPS-----------------------------------------------------------
--/* THIS UNIT IS MADE TO GET DATA FROM FIFO,
--   PASS IT INTO MANCHESTER ENCODER,
--   AND PASS THE RESULT TO A SHIFT REGISTER FOR PARALLER-SERIES CONVERSION 
--   CHECKES THE MULTIPLEXOR VALUES AND PASS IT FOR THE TRANSMATION SHIFT REGISTER
--   DEPENDING ON VALUES OF THE COUNTERS C2 AND C3 AND THE CONDITIONS OF TREATING THE START
--   AND THE END OF THE INFORMATION */ 
	U1 : fifo PORT MAP
		(h, Din, read_fifo, write_fifo, empty, full, fifo_out);
	U2 : manchester PORT
	MAP(fifo_out, manchester_out);
	U3 : Reg1 PORT
	MAP (h, R, ld1, Dec1, manchester_out, Reg1_out);
	U4 : p_emetteur PORT
	MAP (h, R, Dec_pr, init_pr, PreaumbuleDout);
	U5 : mux PORT
	MAP (h, R,  Reg1_out,sel, PreaumbuleDout, mux_out);
	U6 : RegOut PORT
	MAP (h, R, DecRegout, mux_out, C3EQREG4, C3_out, sof, eof, Tx);
	U7 : C3 PORT
	MAP (h, INC3, RAZ3, C3EQ13, C3EQ14, C3_out);
	U8 : C2 PORT
	MAP (h, INC2, RAZ2, C2EQF, C2EQ144);
	U9 : RegL PORT
	MAP (h, R, LD2, fifo_out, RegLOut);
	U10 : RegH PORT
	MAP (h, R, LD3, fifo_out, RegHOut);
	U11 : Reg4 PORT
	MAP (h, RAZ4, LD4, C3_out, RegLOut, RegHOut, C3EQREG4);
	U12 : sequenceur PORT
		MAP (	h,R,C3EQREG4,
				C3EQ13,C3EQ14,
				EOF, SOF, empty,C2EQF, C2EQ144, read_fifo, LD1, LD2, LD3, DEC1, sel, init_pr, dec_pr, INC2, RAZ2, INC3, Raz3, LD4, RAZ4, Decregout);
END ARCHITECTURE;
