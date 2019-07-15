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
	SIGNAL sel0, sel1, sel2 : std_logic;-- MUX
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
	--------------------------------------------------------------
	SIGNAL r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23 : std_logic; --SEQUENCEUR
	SIGNAL e0, e1, e2, e3 : std_logic;
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
			h, R, sel0, sel1, sel2 : IN std_logic;
			Reg1in : IN std_logic;
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
	-------------------------------SEQUENCEUR-------------------------- 

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
			C2EQF, C2EQ144 : OUT std_logic;
			C2out : OUT std_logic_vector(7 DOWNTO 0)
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
BEGIN
	r1 <= NOT(e3) AND NOT(e2) AND NOT(e1) AND NOT(e0);
	r2 <= empty AND NOT(e3) AND NOT(e2) AND NOT(e1) AND e0;
	r3 <= NOT(empty) AND NOT(e3) AND NOT(e2) AND NOT(e1) AND e0;
	r4 <= NOT(e3) AND NOT(e2) AND e1 AND NOT(e0);
	r5 <= NOT(C2EQ144) AND NOT(e3) AND NOT(e2) AND e1 AND e0;
	r6 <= C2EQ144 AND NOT(e3) AND NOT(e2) AND e1 AND e0;
	r7 <= NOT(e3) AND e2 AND NOT(e1) AND NOT(e0);
	r8 <= NOT(e3) AND e2 AND NOT(e1) AND e0;
	r9 <= NOT(C2EQF) AND NOT(e3) AND e2 AND e1 AND NOT(e0);
	r10 <= C2EQF AND NOT(e3) AND e2 AND e1 AND NOT(e0);
	r11 <= C3EQ13 AND NOT(e3) AND e2 AND e1 AND e0;
	r12 <= NOT(C3EQ13) AND NOT(e3) AND e2 AND e1 AND e0;
	r13 <= NOT(empty) AND e3 AND NOT(e2) AND NOT(e1) AND NOT(e0);
	r14 <= empty AND e3 AND NOT(e2) AND NOT(e1) AND NOT(e0);
	r15 <= C3EQ14 AND e3 AND NOT(e2) AND NOT(e1) AND e0;
	r16 <= e3 AND NOT(e2) AND e1 AND NOT(e0);
	r17 <= NOT(C3EQ14) AND e3 AND NOT(e2) AND NOT(e1) AND e0;
	r18 <= C3EQREG4 AND e3 AND NOT(e2) AND e1 AND e0;
	r19 <= NOT(C3EQREG4) AND e3 AND NOT(e2) AND e1 AND e0;
	r20 <= NOT(sof) AND e3 AND e2 AND NOT(e1) AND NOT(e0);
	r21 <= sof AND e3 AND e2 AND NOT(e1) AND NOT(e0);
	r22 <= NOT(eof) AND e3 AND e2 AND NOT(e1) AND e0;
	r23 <= e3 AND e2 AND e1 AND NOT(e0);
	PROCESS (h, R)
	BEGIN
		IF R = '1' THEN
			e0 <= '0';
			e1 <= '0';
			e2 <= '0';
			e3 <= '0';
			RAZ2 <= '0';
			RAZ3 <= '0';
			RAZ4 <= '0';
			ld2 <= '0';
			ld3 <= '0';
			ld4 <= '0';
			init_pr <= '0';
			dec_pr <= '0';
			read_fifo <= '0';
			Decregout <= '0';
			LD1 <= '0';
			DEC1 <= '0';
			sel0 <= '0';
			sel1 <= '0';
			sel2 <= '0';
			inc3 <= '0';
			INC2 <= '0';
		ELSIF falling_edge(h) THEN
			e0 <= r1 OR r2 OR r4 OR r7 OR r9 OR r10 OR r12 OR r17 OR r21 OR r22;--
			e1 <= r3 OR r4 OR r5 OR r6 OR r8 OR r10 OR r13 OR r15 OR r17;
			e2 <= r6 OR r7 OR r8 OR r9 OR r10 OR r13 OR r18 OR r20 OR r21 OR r22 OR r23;--
			e3 <= r6 OR r11 OR r12 OR r13 OR r14 OR r15 OR r16 OR r17 OR r18 OR r19 OR r20 OR r21 OR r22; -- 
			raz2 <= r1 OR r23;
			raz3 <= r1;
			raz4 <= r1;
			init_pr <= r3;
			Decregout <= r4 OR r8 OR r20 OR r21 OR r22;--
			dec_pr <= r4;
			ld2 <= r11;
			ld3 <= r15;
			ld4 <= r16;
			inc2 <= r4 OR r8;
			sel0 <= r4;
			sel2 <= r20 OR r21;
			read_fifo <= r23;
			ld1 <= r7;
			dec1 <= r8;
			sel1 <= r8;
			inc3 <= r7;

		END IF;
	END PROCESS;
--------------------COMPONENTS-----------------------------------------------------------
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
	MAP (h, R, sel0, sel1, sel2, Reg1_out, PreaumbuleDout, mux_out);
	U6 : RegOut PORT
	MAP (h, R, DecRegout, mux_out, C3EQREG4, C3_out, sof, eof, Tx);
	U7 : C3 PORT
	MAP (h, INC3, RAZ3, C3EQ13, C3EQ14, C3_out);
	U8 : C2 PORT
	MAP (h, INC2, RAZ2, C2EQF, C2EQ144, C2_out);
	U9 : RegL PORT
	MAP (h, R, LD2, fifo_out, RegLOut);
	U10 : RegH PORT
	MAP (h, R, LD3, fifo_out, RegHOut);
	U11 : Reg4 PORT
	MAP (h, RAZ4, LD4, C3_out, RegLOut, RegHOut, C3EQREG4);

END ARCHITECTURE;