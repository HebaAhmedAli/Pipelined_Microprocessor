LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY forwardingUnit IS 
GENERIC ( n : integer := 16); 
		PORT (	IR,IRBuff : IN std_logic_vector(n-1 DOWNTO 0);
				rSrcAddress_Buff,rSrcAddress_DE,rSrcAddress_EM,
				rDstAddress_Buff,rDstAddress_DE,rDstAddress_EM,rDstAddress_IR :IN std_logic_vector(2 DOWNTO 0);
				rSrc,rDst : IN std_logic_vector(n-1 DOWNTO 0);
				execResultHighEM,execResultLowEM,execResultHighMW,execResultLowMW,
				memoryResultMW,inPortEM,inPortMW,immedMW : IN std_logic_vector(n-1 DOWNTO 0);
				-- writeEnrSrcDE,writeEnrDstDE,writeEnrDst_ecxept_LDM_IN_DE,writeEnrDstEM,twoOp:IN std_logic;

                clk ,hardRst,RtypeEM,RtypeDE,RtypeIR,LDM_EM,IN_EM,IN_DE,LDD_EM,POP_DE,
				twoOperand,memReadEM,memReadDE,
				writeEnrDstEM,writeEnrSrcMW,writeEnrDstDE,writeEnrSrcEM,
				writeEnrDstIR,writeEnrSrcIR	: IN std_logic;
				-- execResultHigh,execResultLow,memoryResult : IN std_logic_vector(n-1 DOWNTO 0);

				rSrcBuf,rDstBuf : OUT std_logic_vector(n-1 DOWNTO 0); 
				stallLDout,stallLDReg,delayJMP: OUT std_logic);       
END ENTITY forwardingUnit;


ARCHITECTURE forwardUnit OF forwardingUnit IS

component forwardDetect IS 
GENERIC ( n : integer := 3); 
	
PORT ( rSrcAddress_Buff,rSrcAddress_DE,rSrcAddress_EM 			:IN std_logic_vector(n-1 DOWNTO 0);
	rDstAddress_Buff,rDstAddress_DE,rDstAddress_EM,rDstAddress_IR 	:IN std_logic_vector(n-1 DOWNTO 0);

	clk ,hardRst,RtypeEM,RtypeDE,RtypeIR,LDM_EM,IN_EM,IN_DE,LDD_EM,POP_DE,
	twoOperand,memReadEM,memReadDE,
	writeEnrDstEM,writeEnrSrcMW,writeEnrDstDE,writeEnrSrcEM,
	writeEnrDstIR,writeEnrSrcIR	: IN std_logic;

	stallLDout,stallLDReg,delayJMP,execResultLSrcSelMW, execResultLDstSelMW,execResultHDstSelEM,execResultHSrcSelEM,
	execResultHSrcSelMW,execResultHDstSelMW,inPortMWSrc,inPortMWDst,
	memResSrcSelMW,memResDstSelMW,immedMWSrc,immedMWDst,inPortEMSrc,inPortEMDst	:OUT std_logic); 

END component;

component R_type IS 
GENERIC ( n : integer := 16); 
PORT ( 	rSrc,rDst : IN std_logic_vector(n-1 DOWNTO 0);
			execResultHighEM,execResultLowEM,execResultHighMW,execResultLowMW,
			memoryResultMW,inPortEM,inPortMW,immedMW : IN std_logic_vector(n-1 DOWNTO 0);

			execResultLSrcSelMW, execResultLDstSelMW,execResultHSrcSelEM,execResultHDstSelEM,
			execResultHSrcSelMW,execResultHDstSelMW,memResSrcSelMW,memResDstSelMW,
			inPortMWSrc,inPortMWDst,immedMWSrc,immedMWDst,inPortEMSrc,inPortEMDst,
			forwardIN_LDMsrc,forwardIN_LDMdst,forwardSelSrc,forwardSelDst :  IN std_logic;
			rSrcBuf,rDstBuf : OUT std_logic_vector(n-1 DOWNTO 0)); 
  
END component;

------------------- feryal added Call_JMP_case_sig ------------------------------------

signal execResultLSrcSelMW, execResultLDstSelMW,execResultHDstSelEM,execResultHSrcSelEM,
	execResultHSrcSelMW,execResultHDstSelMW,inPortMWSrc,inPortMWDst,memResSrcSelMW,
	memResDstSelMW,immedMWSrc,immedMWDst,inPortEMSrc,inPortEMDst,
	forwardIN_LDMsrc,forwardIN_LDMdst,forwardSelSrc,forwardSelDst : std_logic;

BEGIN

	forwardIN_LDMsrc<=immedMWSrc or inPortMWSrc or inPortEMSrc or immedMWSrc;
	forwardIN_LDMdst<= immedMWDst or  inPortMWDst or inPortEMDst or immedMWDst;
	
	forwardSelSrc<=execResultHSrcSelMW or  execResultHSrcSelEM or execResultLSrcSelMW or memResSrcSelMW;
	forwardSelDst<= execResultLDstSelMW or execResultHDstSelEM or execResultHDstSelMW or memResDstSelMW;
	ForwardDetection: forwardDetect port map (IRBuff(5 downto 3),rSrcAddress_DE,rSrcAddress_EM,IRBuff(2 downto 0),
		rDstAddress_DE,rDstAddress_EM,IR(5 downto 3),
		------------------------
		clk ,hardRst,RtypeEM,RtypeDE,RtypeIR,LDM_EM,IN_EM,IN_DE,LDD_EM,POP_DE,
		twoOperand,memReadEM,memReadDE,
		writeEnrDstEM,writeEnrSrcMW,writeEnrDstDE,writeEnrSrcEM,
		writeEnrDstIR,writeEnrSrcIR,
		----------------------------------
		stallLDReg,delayJMP,execResultLSrcSelMW, execResultLDstSelMW,execResultHDstSelEM,execResultHSrcSelEM,
		execResultHSrcSelMW,execResultHDstSelMW,inPortMWSrc,inPortMWDst,memResSrcSelMW,
		memResDstSelMW,immedMWSrc,immedMWDst,inPortEMSrc,inPortEMDst);
	
	Rtype: R_type GENERIC MAP (n=>16) port map (rSrc,rDst, execResultHighEM,execResultLowEM,execResultHighMW,execResultLowMW,
		memoryResultMW,inPortEM,inPortMW,immedMW,	
		-------------------------
		execResultLSrcSelMW, execResultLDstSelMW,execResultHSrcSelEM,execResultHDstSelEM,
		execResultHSrcSelMW,execResultHDstSelMW,memResSrcSelMW,memResDstSelMW,
		inPortMWSrc,inPortMWDst,immedMWSrc,immedMWDst,inPortEMSrc,inPortEMDst,
		forwardIN_LDMsrc,forwardIN_LDMdst,forwardSelSrc,forwardSelDst,
		-------------------------
		rSrcBuf,rDstBuf);
     
END forwardUnit;

	-- rSrcAddress_DE->IR(5 downto 3)
	-- rSrcAddress_EM->IRBuff(5 downto 3)
	-- rDstAddress_DE->IR(2 downto 0)
	-- rDstAddress_EM->IRBuff(2 downto 0)