LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY controlUnit IS 
GENERIC ( n : integer := 16); 
        PORT (IR,IRBuff : IN std_logic_vector(n-1 DOWNTO 0);
        flagReg : IN std_logic_vector(3 DOWNTO 0);
        clk,rstHard,stallLD,delayJMPDE:in std_logic; 
        jmpCondBuff,
        offsetSel,
        twoOp,incSp,enSP ,enMemWr,lddORpop,setcORclrc,
        imm,wrEnRdst,enExecRes,wrEnRsrc,outEnReg,
        alu1,alu2,alu3,alu4,s1Wb,s0Wb,
        RET,RTI,PUSH,STD,SETC,CLRC,memRead,rType,IN_OR_LDM_out,LDM_out,writeEnrDst_ecxept_LDM_IN,IN_out,POP: OUT std_logic; --feryal
        counterRTout:OUT std_logic_vector (1 downto 0));    
END ENTITY controlUnit;

ARCHITECTURE controlU OF controlUnit IS

component rtCircuit IS 
GENERIC ( n : integer := 16); 
 PORT (IR,IR_Buff : IN std_logic_vector(n-1 DOWNTO 0);
        stallLD,clk,rstHard: IN std_logic;
        --stallRT : OUT std_logic;
        counterRTout:OUT std_logic_vector (1 downto 0));        
END component;

component jmpOffset IS 
GENERIC ( n : integer := 16); 
PORT (IRBuff: IN std_logic_vector(n-1 DOWNTO 0);
flagReg : IN std_logic_vector(3 DOWNTO 0);
delayJMPDE,clk,rstHard:in std_logic;
offsetSel,jmpCondDelayedReg : OUT std_logic);    
END component;


component irSignals IS 
GENERIC ( n : integer := 16); 
        PORT (IRBuff : IN std_logic_vector(n-1 DOWNTO 0);
        twoOp,incSp,enSP ,enMemWr,lddORpop,setcORclrc,
        imm,wrEnRdst,enExecRes,wrEnRsrc,outEnReg,
        alu1,alu2,alu3,alu4,s1Wb,s0Wb,
        rType,RET,RTI,PUSH,STD,SETC,CLRC,memRead,IN_OR_LDM_out,LDM_out,writeEnrDst_ecxept_LDM_INm,IN_out,POP : OUT std_logic);   --feryal
END component;


BEGIN
irSignalsL: irSignals GENERIC MAP (n=>16) port map (IRBuff,twoOp,incSp,enSP ,enMemWr,lddORpop,setcORclrc,
                imm,wrEnRdst,enExecRes,wrEnRsrc,outEnReg,alu1,alu2,alu3,alu4,s1Wb,s0Wb,rType,RET,RTI,PUSH,STD,SETC,CLRC,memRead,
		IN_OR_LDM_out,LDM_out,writeEnrDst_ecxept_LDM_IN,IN_out,POP);
RTcircuitL: rtCircuit GENERIC MAP (n=>16) port map (IR,IRBuff,stallLD,clk,rstHard,counterRTout);
jmpOffsetL: jmpOffset  GENERIC MAP (n=>16) port map (IRBuff,flagReg,delayJMPDE,clk,rstHard,offsetSel,jmpCondBuff);

END controlU;
