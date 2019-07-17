LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
--/*THIS UNIT IS A SHIFT REGISTER MADE TO HOLD THE PREAMBULE DATA,
-- REG1 DATA AND TRANSMIT IT THROUGH Tx AS A SERIES DATA 
-- ALSO GENERATED A SIGNAL SOF WHEN THE TRAM FIRST REACHED THE LOWST BIT
-- OF THE REGISTERS AND ANOTHER SIGNAL WHEN THE TRANSMISSION IS COMPLETED.*/
ENTITY RegOut IS PORT
(
	H, R, Decregout, muxIn, C3EQREG4 : IN std_logic;
	C3 : IN std_logic_vector(15 DOWNTO 0);
	sof, eof, Tx : OUT std_logic);
END regout;
ARCHITECTURE areg_dec_Tx OF RegOut IS

	SIGNAL Container : std_logic_vector(1455 DOWNTO 0);

BEGIN
	PROCESS (H, R, decregout)
	BEGIN
		IF R = '1' THEN
			Container <= (OTHERS => '0');
		ELSIF rising_edge(H) THEN
			IF decregout = '1' THEN
	
				Container <= muxIn & Container(1455 DOWNTO 1);
			END IF;
			IF Container(1 DOWNTO 0) /= "00" THEN
				sof <= '1';
			ELSIF ( Container (2 DOWNTO 0) = "000" and (C3/=0) and  C3EQREG4='1'  )  THEN
				eof <= '1';
			ELSE
				sof <= '0';
				eof <= '0';
			END IF;
		Tx <= Container(0);
		END IF;
	END PROCESS;
END areg_dec_Tx;