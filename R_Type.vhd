LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY R_type IS 
GENERIC ( n : integer := 16); 
		PORT ( 	rSrc,rDst : IN std_logic_vector(n-1 DOWNTO 0);
			execResultHighEM,execResultLowEM,execResultHighMW,execResultLowMW,
			memoryResultMW,inPortEM,inPortMW,immedMW : IN std_logic_vector(n-1 DOWNTO 0);

			execResultLSrcSelMW, execResultLDstSelMW,execResultHSrcSelEM,execResultHDstSelEM,
			execResultHSrcSelMW,execResultHDstSelMW,memResSrcSelMW,memResDstSelMW,
			inPortMWSrc,inPortMWDst,immedMWSrc,immedMWDst,inPortEMSrc,inPortEMDst,
			forwardIN_LDMsrc,forwardIN_LDMdst,forwardSelSrc,forwardSelDst :  IN std_logic;
			rSrcBuf,rDstBuf : OUT std_logic_vector(n-1 DOWNTO 0));   
			 
END ENTITY R_type;


ARCHITECTURE SrcDstRType OF R_type IS

component R_type_component IS 
GENERIC ( n : integer := 16);
		PORT ( inputReg,execResultHEM,execResultLEM,execResultHMW,execResultLMW,
			memResultMW,inPortEM,inPortMW,immedMW : IN std_logic_vector(n-1 DOWNTO 0);
			execResultLSelMW,execResultHSelEM,
			execResultHSelMW,memResSelMW,inPortMWSel,immedMWSel,
			forwarINLDM,forwardSel:  IN std_logic;
			rBuf : OUT std_logic_vector(n-1 DOWNTO 0));   
END component;

BEGIN
	srcRType: R_type_component GENERIC MAP (n=>16) port map (rSrc,
	execResultHighEM,execResultLowEM,execResultHighMW,
	execResultLowMW,memoryResultMW,inPortEM,inPortMW,immedMW,
	execResultLSrcSelMW,execResultHSrcSelEM,execResultHSrcSelMW,memResSrcSelMW,inPortEMSrc,immedMWSrc,forwardIN_LDMsrc,forwardSelSrc,
	rSrcBuf);
	
	dstRType: R_type_component GENERIC MAP (n=>16) port map (rDst,execResultHighEM,execResultLowEM,execResultHighMW,
	execResultLowMW,memoryResultMW,inPortEM,inPortMW,immedMW,
	execResultLDstSelMW,execResultHDstSelEM,execResultHDstSelMW,memResDstSelMW,inPortEMDst,immedMWDst,forwardIN_LDMdst,forwardSelDst
	,rDstBuf);
	
     
END SrcDstRType;
