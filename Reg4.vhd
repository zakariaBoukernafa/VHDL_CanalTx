LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
--/* A REGISTER THAT HOLDS THE SIZE OF THE TRAM COMING 
-- TO CONTROL THE START AND THE TRANSMISSION OF TX */
ENTITY Reg4 IS
	PORT
	(
		H, RAZ4, LD4 : IN std_logic;
		C3 : IN std_logic_vector(15 DOWNTO 0);
		RegL : IN std_logic_vector(7 DOWNTO 0);
		RegH : IN std_logic_vector(7 DOWNTO 0);
		C3eqREG4 : OUT std_logic
	);
END ENTITY;

ARCHITECTURE Areg4 OF Reg4 IS
	SIGNAL Dout_reg : std_logic_vector(15 DOWNTO 0);
BEGIN

	PROCESS (H, RAZ4, LD4)
	BEGIN
		IF RAZ4 = '1' THEN
			Dout_reg <= (OTHERS => '0');
			C3eqREG4 <= '0';
		ELSIF rising_edge(H) THEN
			IF LD4 = '1' THEN
				Dout_reg <= (RegL & regH) + 4 + C3;
			END IF;
			IF (C3 = Dout_reg AND C3 /= 0) THEN
				C3eqREG4 <= '1';
			ELSE
				C3eqREG4 <= '0';
			END IF;
		END IF;

	END PROCESS;
END ARCHITECTURE;