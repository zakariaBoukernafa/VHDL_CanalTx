LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
-- A BASIC REGISTER TO HOLD THE BYTE NUMBER 13 OF DATA COMING FROM FIFO 

ENTITY RegL IS
	PORT
	(
		H, R, LD : IN std_logic;
		fifo13 : IN std_logic_vector(7 DOWNTO 0);
		data_out : OUT std_logic_vector(7 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE aRegL OF RegL IS

BEGIN

	PROCESS (H, R, LD)
	BEGIN
		IF R = '1' THEN
			data_out <= (OTHERS => '0');
		ELSIF rising_edge(H) THEN
			IF LD = '1' THEN
				data_out <= fifo13;
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;