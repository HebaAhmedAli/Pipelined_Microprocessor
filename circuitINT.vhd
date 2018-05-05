
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;  

ENTITY intCircuit IS 
GENERIC ( n : integer := 16); 
        PORT (pc : IN std_logic_vector(n-1 DOWNTO 0);
       int,stallLD,clk,rstHard:IN std_logic;      
        intEn,excINT,selINTPC,flagBuffEn : OUT std_logic;
        counterIntout:OUT std_logic_vector (2 downto 0);
        pcINTOut: OUT std_logic_vector(n-1 DOWNTO 0)
        );    
END ENTITY intCircuit;

ARCHITECTURE circuitINT OF intCircuit IS


component my_DFF IS
     PORT(clk,rst,en,d : IN std_logic;   q : OUT std_logic);
END component;

component my_nDFF IS
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));
END component;

component counterINT is
    generic (n:integer :=3); 
    Port ( rst,clk : in STD_LOGIC;
     up: in STD_LOGIC;                             
     z : out STD_LOGIC_vector( n-1 downto 0 ));
  end component;

signal counterEnSig,counterRstSig,pcINTEnSig,intEnSig,excINTSig,selINTPCSig,flagBuffEnSig: std_logic ;
signal counterOut:std_logic_vector (2 downto 0);
signal pcINTIn:std_logic_vector (n-1 downto 0);

BEGIN


    --intBuffL: my_DFF port map(int,clk,int,counterRstSig,intBuffSig);
    counterINTReg: counterINT GENERIC MAP (n=>3) port map (counterRstSig,clk,counterEnSig,counterOut);
    pcINTL: my_nDFF GENERIC MAP (n=>16) port map(clk,rstHard,pcINTEnSig,pcINTIn,pcINTOut);



    counterRstSig<='1' when counterOut="101" or rstHard='1'
    else '0';

    excINTSig<='1' when counterOut="100" or intEnSig='1'
    else '0';

    selINTPCSig<='1' when counterOut="011" or intEnSig='1'
    else '0';

    flagBuffEnSig<='1' when counterOut="001" or intEnSig='1'
    else '0';

    pcINTEnSig<= '1' when counterOut="001" or intEnSig='1'
    else '0';

    --intBuff<=intBuffSig;
    intEn<=intEnSig;
    excINT<=excINTSig;
    selINTPC<=selINTPCSig;
    flagBuffEn<=flagBuffEnSig;
    counterIntOut<=counterOut;
    
    intEnSig<='1' when int='1'
    else '0' when counterRstSig='1';
    
    counterEnSig<= intEnSig and (not stallLD);
    pcINTIn<= std_logic_vector(unsigned(pc)+1);
    
END circuitINT;

