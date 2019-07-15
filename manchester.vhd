library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--/* THIS UNIT CONVERSTS THE TRAM VALUE TO MANCHESTER ENCODING
--   0 INTO 01 AND 1 TO 10 */
entity manchester is
port(datain : in std_logic_vector(7 downto 0); dataout : out std_logic_vector(15 downto 0));
end manchester ;
architecture bhv of manchester is
begin
process(datain)
begin
for i in 0 to 7 loop
if datain(i)='0' then
dataout(2*i) <= '0';
dataout(2*i+1) <= '1';
else
dataout(2*i) <= '1';
dataout(2*i+1) <= '0';
end if;
end loop;
end process;
end bhv;