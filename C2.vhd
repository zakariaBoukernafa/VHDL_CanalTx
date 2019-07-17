LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
-- /* THIS UNIT COUNTS HOW MANY TIMES THE SHIFT REGISTER 
--  GOT SHIFTED AND GENERATE A SIGNAL IF THE PREAMBULE REACHED 144 */
ENTITY C2 IS

	PORT
	(
		H, INC2, RAZ2 : IN std_logic;
		C2EQF, C2EQ144 : OUT std_logic
		
	);

END ENTITY;
ARCHITECTURE AC2 OF C2 IS
	SIGNAL counter : std_logic_vector(7 DOWNTO 0);
BEGIN

	PROCESS (H, INC2, RAZ2)

	BEGIN

		IF (RAZ2 = '1') THEN
			counter <= (OTHERS => '0');
		ELSIF Rising_edge(H) THEN
			IF (INC2 = '1') THEN
				counter <= counter + 1;
			END IF;
			IF (counter = 15) THEN
				C2EQF <= '1';
			ELSE
				C2EQF <= '0';
			END IF;
			IF (counter = 143) THEN
				C2EQ144 <= '1';
			ELSE
				C2EQ144 <= '0';
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;