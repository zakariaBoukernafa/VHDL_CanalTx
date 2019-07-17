LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
-- A SIMPLE SHIFT REGISTER THAT HOLDS DATA COMING FROM FIFO ENCODED BY MANCHESTER ENCODER
ENTITY reg1 IS
	PORT
	(
		h, r, ld1, dec1 : IN std_logic;
		din_reg1 : IN std_logic_vector(15 DOWNTO 0);
		dout_reg1 : OUT std_logic);
END reg1;

ARCHITECTURE areg1 OF reg1 IS
	SIGNAL Container : std_logic_vector(15 DOWNTO 0);
	SIGNAL tester    : std_logic;
BEGIN
	PROCESS (h, ld1)
	BEGIN
		IF rising_edge(h) THEN

			IF ld1 = '1' THEN
				Container <= din_reg1;
			ELSIF dec1 = '1' THEN
				Container <= '0' & Container(15 DOWNTO 1);
				tester <=Container(0);
			END IF;
			
		END IF;
	END PROCESS;
dout_reg1 <= tester;
END areg1;