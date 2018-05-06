LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY R_type_component IS 
GENERIC ( n : integer := 16); 
		PORT ( inputReg,execResultHEM,execResultLEM,execResultHMW,execResultLMW,
			memResultMW,inPortEM,inPortMW,immedMW : IN std_logic_vector(n-1 DOWNTO 0);
			execResultLSelMW,execResultHSelEM,
			execResultHSelMW,memResSelMW,inPortMWSel,immedMWSel,
			forwarINLDM,forwardSel:  IN std_logic;
			rBuf : OUT std_logic_vector(n-1 DOWNTO 0));    
END ENTITY R_type_component;


ARCHITECTURE toBuff OF R_type_component IS

component mux2_1 IS 
GENERIC ( n : integer := 16); 
		PORT (in1,in2 : IN std_logic_vector(n-1 DOWNTO 0);
            s	:  IN std_logic;
  		   out1 : OUT std_logic_vector(n-1 DOWNTO 0));    
END component;

component mux4 is 
	Generic (m : integer :=16);
port ( s1,s0: in std_logic;
	input1,input2,input3,input4: in std_logic_vector(m-1 downto 0);
	output: out std_logic_vector(m-1 downto 0));
end component;

signal execInput,memORexec,EMorMW_In,immedORin,tolastMUX:std_logic_vector(n-1 DOWNTO 0); 
signal bufDESel,sel0,sel1:std_logic;   
BEGIN
	sel0<=execResultLSelMW or	execResultHSelMW;
	sel1<=execResultHSelEM or	execResultHSelMW;
	chooseInputLbl: mux4 GENERIC MAP (m=>16) port map (sel1,sel0,execResultLEM,execResultLMW,execResultHEM,execResultHMW,execInput);
	memORresult: mux2_1 GENERIC MAP (n=>16) port map (execInput,memResultMW,memResSelMW,memORexec);

	INEMorMW: mux2_1 GENERIC MAP (n=>16) port map (inPortEM,inPortMW,inPortMWSel,EMorMW_In);
	highORlow: mux2_1 GENERIC MAP (n=>16) port map (EMorMW_In,immedMW,immedMWSel,immedORin);
	abla5er: mux2_1 GENERIC MAP (n=>16) port map (memORexec,immedORin,forwarINLDM,tolastMUX);

	bufDESel<=forwarINLDM or forwardSel;
	toReg:mux2_1 GENERIC MAP (n=>16) port map (inputReg,tolastMUX,bufDESel,rBuf);
     
END toBuff;
