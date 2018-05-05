
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY forwardDetect IS 
GENERIC ( n : integer := 3); 
		PORT ( 	rSrcAddress_Buff,rSrcAddress_DE,rSrcAddress_EM 			:IN std_logic_vector(n-1 DOWNTO 0);
			rDstAddress_Buff,rDstAddress_DE,rDstAddress_EM,rDstAddress_IR 	:IN std_logic_vector(n-1 DOWNTO 0);
			writeEnrDstDE,writeEnrDst_ecxept_LDM_IN_DE,writeEnrDstEM					:IN std_logic;
			writeEnrSrcDE,twoOperand,forward				:IN std_logic;
			memReadEM,clk ,hardRst,Call_JMP_case				:IN std_logic;
			execResultLSrcSel,execResultLDstSel,
			forwSrc,forwDst,
			stallLD,stallLDBuff,delayJmp : OUT std_logic);    
END ENTITY forwardDetect;


ARCHITECTURE forwarding OF forwardDetect IS
component comparing_component IS 
GENERIC ( n : integer := 3); 
		PORT (  RegAddress_Buff,RegAddress_DE	: IN std_logic_vector(n-1 DOWNTO 0);
			WriteEn,twoOperand		:  IN std_logic;
  		   	execResSel			: OUT std_logic);      
END component;

component my_DFF IS
	 PORT(clk,rst,en,d : IN std_logic;
	    q : OUT std_logic);
END component;
--signal execResultLSrcCmp,execResultLDstCmp,memResSrcCmp,memResDstCmp,execResultHSrcCmp,execResultHDstCmp:std_logic;
signal memResSrcSel,memResDstSel,execResultHSrcSel,execResultHDstSel,execResultLSrcSelSig,execResultLDstSelSig:std_logic;
signal execResultLDstSel0,memResDstSel0,execResultHDstSel0:std_logic;
signal rstReg,regRes,regIn,rstDstRegs,rstSrcRegs:std_logic;
--signal stallLD,stallLDBuff,delayJmp :std_logic;

BEGIN

	-- rstDstRegs<=hardRst or writeEnrDstDE;
	-- rstSrcRegs<=hardRst or writeEnrSrcDE;

------------------------------- feryal shalt el '1' in case of JMP ya3ny lama ab2a bqaren b IR nafso  w 5letha writeEnrDst_ecxept_LDM_IN_DE bardo 34an fe 7alet el LDM el value btkon gahza no need to delay JMP ------------
	execResultSrcL: comparing_component GENERIC MAP (n=>3) port map (rSrcAddress_Buff,rDstAddress_DE,writeEnrDstDE,twoOperand,execResultLSrcSelSig);--,execResultLSrcCmp);

	execResultDstL: comparing_component GENERIC MAP (n=>3) port map (rDstAddress_Buff,rDstAddress_DE,writeEnrDstDE,'1',execResultLDstSelSig);--,execResultLDstCmp);
	execResultDstL0: comparing_component GENERIC MAP (n=>3) port map (rDstAddress_IR,rDstAddress_DE,writeEnrDstDE,writeEnrDst_ecxept_LDM_IN_DE,execResultLDstSel0);--,execResultLDstCmp);

	memResSrcSelL: comparing_component GENERIC MAP (n=>3) port map (rSrcAddress_Buff,rDstAddress_EM,writeEnrDstDE,twoOperand,memResSrcSel);--,memResSrcCmp);

	memResDstSelL: comparing_component GENERIC MAP (n=>3) port map (rDstAddress_Buff,rDstAddress_EM,writeEnrDstDE,'1',memResDstSel);--,memResDstCmp);
	memResDstSelL0: comparing_component GENERIC MAP (n=>3) port map (rDstAddress_IR,rDstAddress_EM,writeEnrDstDE,writeEnrDst_ecxept_LDM_IN_DE,memResDstSel0);--,memResDstCmp);
	
	chooseExecResultSrcL: comparing_component GENERIC MAP (n=>3) port map (rSrcAddress_Buff,rSrcAddress_DE,writeEnrSrcDE,twoOperand,execResultHSrcSel);--,execResultHSrcCmp);
	
	
	chooseExecResultDstL: comparing_component GENERIC MAP (n=>3) port map (rDstAddress_Buff,rSrcAddress_DE,writeEnrSrcDE,'1',execResultHDstSel);--,execResultHDstCmp);	
	chooseExecResultDstL0: comparing_component GENERIC MAP (n=>3) port map (rDstAddress_IR,rSrcAddress_DE,writeEnrSrcDE,twoOperand,execResultHDstSel0);--,execResultHDstCmp);	

	forwSrc<=(execResultLSrcSelSig or memResSrcSel or execResultHSrcSel) and forward;
	forwDst<=(execResultLDstSelSig or memResDstSel or execResultHDstSel) and forward;
	delayJmp<= (execResultLDstSel0 or memResDstSel0 or execResultHDstSel0 ) and Call_JMP_case;
	stallLD<=regIn;
	execResultLSrcSel<=execResultLSrcSelSig;
	execResultLDstSel<=execResultLDstSelSig;
	regIn<=(execResultLSrcSelSig or execResultLDstSelSig)and memReadEM;
	
	rstReg<=(regRes and clk)or hardRst;
	stallLDBuff<=regRes;
	stallLDBuffL: my_DFF port map(clk,rstReg,'1',regIn,regRes);
END forwarding;