LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY irSignals IS 
GENERIC ( n : integer := 16); 
		PORT (IRBuff : IN std_logic_vector(n-1 DOWNTO 0);
        twoOp,incSp,enSP ,enMemWr,lddORpop,setcORclrc,
        imm,wrEnRdst,enExecRes,wrEnRsrc,outEnReg,
        alu1,alu2,alu3,alu4,s1Wb,s0Wb,
        rType,RET,RTI,PUSH,STD,SETC,CLRC,memRead,IN_OR_LDM_out,LDM_out,writeEnrDst_ecxept_LDM_IN,IN_out,POP,LDD_out,Jmp_or_Call : OUT std_logic);    -- feryal added  IN_OR_LDM_out,LDM_out

END ENTITY irSignals;


ARCHITECTURE controlIR OF irSignals IS

--signal twoOp,jmpCond,incSp,enSP ,enMemWr,lddORpop,setcORclrc,
--imm,wrEnRdst,enExecRes,wrEnRsrc,memRead,outEnReg :std_logic;
constant addOp :std_logic_vector(6 downto 0):= "0010000";
constant subOp :std_logic_vector(6 downto 0):= "0010001";
constant movOp :std_logic_vector(6 downto 0):= "0010100";
constant andOp :std_logic_vector(6 downto 0):= "0010101";
constant orOp :std_logic_vector(6 downto 0):= "0010110";
constant shlOp :std_logic_vector(6 downto 0):= "0011000";
constant shrOp :std_logic_vector(6 downto 0):= "0011001";
constant mulOp :std_logic_vector(6 downto 0):= "0011100";

--signal jmpCond :std_logic;
constant jzOp :std_logic_vector(6 downto 0):= "0000110";
constant jnOp :std_logic_vector(6 downto 0):= "0000001";
constant jcOp :std_logic_vector(6 downto 0):= "0000010";
constant jmpOp :std_logic_vector(6 downto 0):= "0000011";
--signal incSp :std_logic;
constant retOp :std_logic_vector(6 downto 0):= "0100000";
constant rtiOp :std_logic_vector(6 downto 0):= "0100001";
constant lddOp :std_logic_vector(6 downto 0):= "0100010";
constant popOp :std_logic_vector(6 downto 0):= "0100011";

--signal enSP :std_logic; 
constant callOp :std_logic_vector(6 downto 0):= "1000000";
constant pushOp :std_logic_vector(6 downto 0):= "1000001";
constant stdOp :std_logic_vector(6 downto 0):=  "1000010";

--signal enMemWr,lddORpop,setcORclrc,imm :std_logic;
constant setcOp :std_logic_vector(6 downto 0):=  "0000100";
constant clrcOp :std_logic_vector(6 downto 0):= "0000101";
constant ldmOp :std_logic_vector(6 downto 0):=  "0110010";

--signal wrEnRdst,enExecRes,wrEnRsrc,memRead,outEnReg :std_logic;
constant inOp :std_logic_vector(6 downto 0):=  "0110000";
constant outOp :std_logic_vector(6 downto 0):= "0110001";
constant nopOp :std_logic_vector(6 downto 0):= "0000000";

signal tempIncSP,tempEnSP,tempOutEnReg:std_logic;

--------------------- feryal ---------------------
signal SHLopcode,SHRopcode,LDMopcode,LDDopcode,STDopcode,IN_OR_LDM : std_logic;
signal wrEnRdst_temp: std_logic;

BEGIN

---------------------------- feryal -------------------------------------

	LDD_out <= '1' when IRBuff(15 downto 9) =lddOp
		else '0';
	SHLopcode <= (not IRBuff(15) )and (not IRBuff(14) ) and  IRBuff(13) and IRBuff(12) and not IRBuff(11) 
			and not IRBuff(10) and not IRBuff(9);


	SHRopcode <= (not IRBuff(15) )and (not IRBuff(14) ) and  IRBuff(13) and IRBuff(12) and not IRBuff(11) 
			and not IRBuff(10) and IRBuff(9);



	LDMopcode <= (not IRBuff(15) )and ( IRBuff(14) ) and  IRBuff(13) and (not IRBuff(12)) and not IRBuff(11) 
			and IRBuff(10) and not IRBuff(9);


	LDDopcode <= (not IRBuff(15) )and ( IRBuff(14) ) and  not IRBuff(13) and not IRBuff(12) and not IRBuff(11) 
			and IRBuff(10) and not IRBuff(9);


	STDopcode <= ( IRBuff(15) )and (not IRBuff(14) ) and not IRBuff(13) and not IRBuff(12) and not IRBuff(11) 
			and IRBuff(10) and not IRBuff(9);

--------------------- end feryal ------------------------------------

    twoOp<='1' when IRBuff(15 downto 9) =addOp
    or IRBuff(15 downto 9) =subOp
    or IRBuff(15 downto 9) =movOp
    or IRBuff(15 downto 9) =andOp
    or IRBuff(15 downto 9) =orOp
    or IRBuff(15 downto 9) =shlOp
    or IRBuff(15 downto 9) =shrOp
    or IRBuff(15 downto 9) =mulOp
    else '0';

    imm<= SHLopcode		-- '1' when IRBuff(15 downto 9) =shlOp
    or 	SHRopcode				--IRBuff(15 downto 9) =shrOp
    or 	LDMopcode				--IRBuff(15 downto 9) =ldmOp
    or 	LDDopcode				--IRBuff(15 downto 9) =lddOp
    or 	STDopcode;				--IRBuff(15 downto 9) =stdOp
    						--else '0';
    
    --jmpCond<='1' when IRBuff(15 downto 9) =jzOp
--    or IRBuff(15 downto 9) =jnOp
--    or IRBuff(15 downto 9) =jcOp
--    else '0';

    rType<=IRBuff(13) and not IRBuff(14) and not IRBuff(15);
    tempIncSP<='1' when IRBuff(15 downto 9)= rtiOp
    or IRBuff(15 downto 9) =  retOp
    or IRBuff(15 downto 9) =  popOp
    else '0';
    incSp<=tempIncSP;

    tempEnSP<= '1' when tempIncSP = '1'
    else '1' when IRBuff(15 downto 9) =  callOp
    or IRBuff(15 downto 9) =  pushOp
    else '0';

    enSP<=tempEnSP;
    enMemWr <='1' when tempEnSP= '1'
    else '1' when IRBuff(15 downto 9) =  stdOp
    else '0';
    

    lddORpop <='1' when IRBuff(15 downto 9) =  lddOp
    or IRBuff(15 downto 9) =  popOp
    else '0';

    setcORclrc <='1' when IRBuff(15 downto 9) = setcOp or  IRBuff(15 downto 9) = clrcOp
    else '0';

    SETC <='1' when IRBuff(15 downto 9) = setcOp 
    else '0';

    CLRC <='1' when  IRBuff(15 downto 9) = clrcOp
    else '0';

    IN_out <='1' when  IRBuff(15 downto 9) = inOp
    else '0';

    POP <='1' when  IRBuff(15 downto 9) = popOp
    else '0';

    enExecRes <='1' when IRBuff(15 downto 9) = nopOp
    or IRBuff(15 downto 13) = addOp(6 downto 4)
    else '0';

--heba

    Jmp_or_Call <= '1' when IRBuff(15 downto 9) = callOp
    or IRBuff(15 downto 9) = jmpOp
    else '0';
------------------------ feryal -------------------------
	IN_OR_LDM <= (not IRBuff(15) and IRBuff(14) and IRBuff(13)) and ( (not IRBuff(12) and not  IRBuff(11) and not IRBuff(10) and not IRBuff(9))
									   or (not IRBuff(12) and not  IRBuff(11) and  IRBuff(10) and not IRBuff(9)) );

	IN_OR_LDM_out <= IN_OR_LDM;

	LDM_out <= not IRBuff(15) and IRBuff(14) and IRBuff(13) and ( not IRBuff(12) and not  IRBuff(11) and  IRBuff(10) and not IRBuff(9));

	writeEnrDst_ecxept_LDM_IN <= wrEnRdst_temp and not IN_OR_LDM; 
----------------------------------------------------

    wrEnRdst_temp <='1' when IRBuff(15 downto 13) = addOp(6 downto 4)
    or (IRBuff(15 downto 13) = popOp(6 downto 4) and not(IRBuff(15 downto 9)= rtiOp or IRBuff(15 downto 9) =  retOp))
    or (IRBuff(15 downto 13) = ldmOp(6 downto 4) and tempOutEnReg='0')
    else '0';
wrEnRdst <= wrEnRdst_temp;

   memRead <='1' when IRBuff(15 downto 9) = popOp
   or IRBuff(15 downto 9) = lddOp
   else '0';

    outEnReg<=tempOutEnReg;
    tempOutEnReg  <='1' when IRBuff(15 downto 9) = outOp
    else '0';

    wrEnRsrc <='1' when IRBuff(15 downto 9) = mulOp
    else '0';

    RET<='1' when IRBuff(15 downto 9) =  retOp
    else '0';
    RTI<='1' when IRBuff(15 downto 9) =  rtiOp
    else '0';
    PUSH<='1' when IRBuff(15 downto 9) =  pushOp
    else '0';
    STD<='1' when IRBuff(15 downto 9) =  stdOp
    else '0';
    alu1<=IRBuff(12);
    alu2<=IRBuff(11);
    alu3<=IRBuff(10);
    alu4<=IRBuff(9);

    s1Wb<='1' when IRBuff(15 downto 9) =  inOp
    or IRBuff(15 downto 9) =  ldmOp
    else '0';
    s0Wb<='1' when IRBuff(15 downto 9) =  inOp
    or IRBuff(15 downto 13) =  addOp(6 downto 4)
    else '0';

END controlIR;

