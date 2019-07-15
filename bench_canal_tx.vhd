library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity bench_canal_tx is
port(
clk,reset : in std_logic; 
--etat : out std_logic_vector(3 downto 0);
--regout_7_0 ,
dataout
--,data8p
: out std_logic_vector(7 downto 0);
--data_16p : out std_logic_vector(15 downto 0);
--setincp,incp : out std_logic;
--countp : out std_logic_vector(4 downto 0);
--tx,
recu : out std_logic
);
end bench_canal_tx ;
architecture bhv of bench_canal_tx is
component data_generator is
port(
clk,reset,full : in std_logic;
writ_e : out std_logic;
data_out : out std_logic_vector(7 downto 0)
);
end component;
component canal_tx is
port (
h,R,write_fifo : in std_logic;
full,tx : out std_logic;
--etat : out std_logic_vector(3 downto 0);
--regout_7_0 : out std_logic_vector(7 downto 0);
din : in std_logic_vector(7 downto 0)
 );
end component;

component decod_manchester is
port(datain : in std_logic_vector(15 downto 0); dataout : out std_logic_vector(7 downto 0));
end component ;

signal data,data_8 : std_logic_vector(7 downto 0);
signal ecris,plein,txp,rx,setinc,inc,recup : std_logic;
signal data_16 : std_logic_vector(15 downto 0);
signal count : std_logic_vector(4 downto 0);

begin

------------------------
--data_16p <= data_16;
--setincp <= setinc;
--incp <= inc;
----countp <= count;
--tx <= txp;
---------------------



comp1 : data_generator port map(clk,reset,plein,ecris,data);
comp2 : canal_tx port map(clk,reset,ecris,plein,txp,data);
--comp2 : canal_tx port map(clk,reset,ecris,plein,txp,etat,regout_7_0,data);


comp3 : decod_manchester port map(data_16,data_8);

process(data_8,count)
begin
if data_8 = "10101010" then setinc <= '1'; else setinc <= '0'; end if;
if count= "10000" then recup <= '1' ; 
elsif count="00000" and data_8="10101010" then 
recup <= '1' ;
else recup <= '0'; 
end if;
end process;

recu <= recup;

process(setinc,reset)
begin
if setinc='1' and reset='0' then
inc <= '1';
elsif setinc='0' and reset='1' then
inc <= '0';
else
inc <= inc;
end if;
end process;

process(clk,reset)
begin
if reset='1' then 
count <= (others =>'0');
elsif falling_edge(clk) then
if inc='1' and count < "10000" then count <= count + 1;
elsif inc ='1' and count = "10000" then count <= "00001";
else
count <= count ;
end if;
end if;
end process; 

rx <= txp;

process(clk,reset)
begin
if reset='1' then 
data_16 <= (others =>'0');
elsif falling_edge(clk) then
data_16(14 downto 0) <= data_16(15 downto 1);
data_16(15) <= RX;
end if;
end process; 

process(clk,reset)
begin
if reset='1' then
dataout <= (others =>'0');
elsif falling_edge(clk) then
if recup='1' then
dataout <= data_8;
end if;
end if;
end process;
--data8p <= data_8;
end bhv;





