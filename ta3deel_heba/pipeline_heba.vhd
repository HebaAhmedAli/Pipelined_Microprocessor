LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY pipeline IS
GENERIC ( n : integer := 16);
PORT( Clk,Rst,INTERUPT : IN std_logic;
		  in_port : IN std_logic_vector(n-1 DOWNTO 0);
		  out_port: OUT std_logic_vector(n-1 DOWNTO 0));
END pipeline;

ARCHITECTURE a_pipeline OF pipeline IS

component fetch IS
	
	port (Clk : IN std_logic;
              Reset,Int_en,select_offset,delay_jmp,RTI,RET,Int_pc_sel,stall_ld,jmp_cond,imm_buf: in std_logic;
           pc_mem,Rdst_buf_ie_im,Rdst : IN std_logic_vector(15 DOWNTO 0);
          counter: IN std_logic_vector(2 DOWNTO 0);
counter_RT: IN std_logic_vector(1 DOWNTO 0);
            ir_fetch,ir_buf,pc_call: out std_logic_vector(15 DOWNTO 0)
           ); 
		
END component;



component  Decode IS
	Generic (m : integer :=16);
	port (	clk,rst: in std_logic ;
		IR_Buff , write_data_Rdst, Exec_Result_H , IR,PC_Call:in std_logic_vector (m-1 downto 0);
		Rdst_add_IM_IW, Rsrc_add_IM_IW: in std_logic_vector(2 downto 0);
		write_en_Rsrc_IM_IW,write_en_Rdst_IM_IW ,Imm_control_signal , JMP_cond , Stall_LD : in std_logic;
		Rsrc_buff_ID_IE , Rdst_buff_ID_IE , IR_Immediate_ID_IM ,PC_Call_ID_IM: out std_logic_vector(m-1 downto 0 );
		Rsrc_add_ID_IE,Rdst_add_ID_IE: out std_logic_vector (2 downto 0);
		Imm_buff_ID_IE: out std_logic
		);
END component ;

component  execute is
generic ( n : integer := 16);  

PORT ( Clk,RESET,RTI_sig,SETC_sig,CLRC_sig,SETC_or_CLRC_sig,en_flag_buf_sig,en_exec_result_sig: in std_logic;

	
	Rdst_buf_in,Rsrc_buf_in: in std_logic_vector(n-1 downto 0); --pass it also 
	ALU_op_ctrl,immediate_val_in: in std_logic_vector (3 downto 0); --pass immediate_val also
	
	write_en_Rsrc_in,write_en_Rdst_in,inc_SP_in,en_SP_in,SP_address_in,en_mem_write_in,mem_read_in,LDD_or_pop_in,out_en_reg_in,S1_WB_in,S0_WB_in: in std_logic;
	--pass these registers 
	Rdst_add_in,Rsrc_add_in: in std_logic_vector (2 downto 0); 
	PC_call_in: in std_logic_vector (n-1 downto 0);
	-- outputs of IE_IM buffer
	write_en_Rsrc_IE_IM,write_en_Rdst_IE_IM,inc_SP_IE_IM,en_SP_IE_IM,SP_address_IE_IM,en_mem_write_IE_IM,mem_read_IE_IM,LDD_or_pop_IE_IM,out_en_reg_IE_IM,S1_WB_IE_IM,S0_WB_IE_IM:out std_logic;
	
	
	Rdst_add_IE_IM,Rsrc_add_IE_IM: out std_logic_vector (2 downto 0); 
	PC_call_IE_IM,Rdst_buf_IE_IM,Rsrc_buf_IE_IM: out std_logic_vector (n-1 downto 0);
	immediate_val_IE_IM: out std_logic_vector (3 downto 0);

	execute_result_H_IE_IM,execute_result_L_IE_IM : out std_logic_vector(n-1 downto 0);
	flags_IE_IM: out std_logic_vector (3 downto 0)
);
end component;




component memory IS
	
	port (Clk : IN std_logic;
              Reset,int_en,std,push,exc_int,en_mem_wr,int_pc_sel,sp_address,inc_sp,en_sp: in std_logic;
            s1_wb_ie_im,so_wb_ie_im,out_en_reg_ie_im: in std_logic;
           pc_call,pc_int,Rdst_buf_ie_im,immediate_ie_m: IN std_logic_vector(15 DOWNTO 0);

            Rsrc_add_ie_im,Rdst_add_ie_im : IN std_logic_vector(2 DOWNTO 0);

            mem_result,pc_mem,immediate_im_iw,Rdst_buf_im_iw: out std_logic_vector(15 DOWNTO 0);
            Rsrc_add_im_iw,Rdst_add_im_iw: out std_logic_vector(2 DOWNTO 0);
             s1_wb,so_wb,out_en_reg_im_iw: out std_logic
           );  
		
END component;



component WB IS
	port (	clk,rst: in std_logic ;
		Mem_Result,Exec_ResH,Immediate,In_Port,Rdst_buf_IM_IW: in std_logic_vector(15 downto 0);
		S1_WB,S0_WB,Out_en_Reg: in std_logic;
		Write_Data_Rdst,OUT_Port: out std_logic_vector(15 downto 0)
		);
END component;


component controlUnit IS 
GENERIC ( n : integer := 16); 
        PORT (IR,IRBuff : IN std_logic_vector(n-1 DOWNTO 0);
        flagReg : IN std_logic_vector(3 DOWNTO 0);
        clk,stallLD,delayJMP,delayJMPDE:in std_logic; --nsal fatema
        jmpCondBuff,
        stallRT,stallRTbuff,offsetSel,jmpCondReg,
        twoOp,jmpCond,incSp,enSP ,enMemWr,lddORpop,setcORclrc,
        imm,wrEnRdst,enExecRes,wrEnRsrc,memRead,outEnReg,
        alu1,alu2,alu3,s1Wb,s0Wb,RET,RTI,STD,PUSH: OUT std_logic;
        counterRTout:OUT std_logic_vector (1 downto 0));    
END component;


component forwardingUnit IS 
GENERIC ( n : integer := 16); 
		PORT (	IR,IRBuff : IN std_logic_vector(n-1 DOWNTO 0);
				rSrcAddress_DE,rSrcAddress_EM,rDstAddress_DE,rDstAddress_EM :IN std_logic_vector(2 DOWNTO 0);
				writeEnrSrcDE,writeEnrDstDE,writeEnrRsrcEM,writeEnrDstEM:IN std_logic;
                memReadEM,memReadMW:  IN std_logic;
                MulDE,RtypeDE,Clk:  IN std_logic;
				rSrc,rDst : IN std_logic_vector(n-1 DOWNTO 0);
				execResultHigh,execResultLow,memoryResult : IN std_logic_vector(n-1 DOWNTO 0);
				execResultLowSelSrc,forwardSelSrc:  IN std_logic;
				execResultLowSelDst,forwardSelDst:  IN std_logic;
				rSrcBuf,rDstBuf : OUT std_logic_vector(n-1 DOWNTO 0); 
				stallLD,stallLDBuff,delayJmp: OUT std_logic);       
END component;

component intCircuit IS 
GENERIC ( n : integer := 16); 
        PORT (pc : IN std_logic_vector(n-1 DOWNTO 0);
       int,stallLD,clk,rstHard:IN std_logic;
        
        counterEn,counterRst,intBuff,pcINTEn,intEn,excINT,selINTPC,flagBuffEn : OUT std_logic
        --counterIntout:OUT std_logic_vector (2 downto 0)
        );    
END component;




	signal Int_en_int_cir_sig,offsetSel_cu_sig,delayJMP_cu_sig,RTI_cu_sig,
		RET_cu_sig,selINTPC_int_cir_sig,stallLD_fu_sig,jmpCond_cu_sig,imm_cu_sig: std_logic;
        signal counter_RT_sig :std_logic_vector(1 downto 0);
        signal counter_sig :std_logic_vector(2 downto 0);
	signal pc_mem_m_sig,Rdst_buf_if_id_sig , Rdst_dec_sig : std_logic_vector(15 downto 0 );
	signal counter_int_cir_sig,counter_RT_cir_sig : std_logic_vector(2 downto 0);
	signal ir_fetch_sig,ir_buf_ID_IF_sig,pc_call_ID_IF_sig : std_logic_vector(15 DOWNTO 0);
	signal write_data_Rdst_WB_sig, Exec_Result_H_IM_IW_sig : std_logic_vector(15 DOWNTO 0);
	signal Rdst_add_IM_IW_sig, Rsrc_add_IM_IW_sig : std_logic_vector(2 downto 0);
	signal write_en_Rsrc_IM_IW_sig,write_en_Rdst_IM_IW_sig , JMP_cond_CU_sig , Stall_LD_FU_sig : std_logic ;
	signal 	Rsrc_buff_ID_IE_sig,Rdst_buff_ID_IE_sig,IR_Immediate_ID_IM_sig,PC_Call_ID_IM_sig:  std_logic_vector(15 downto 0 );
	signal	Rsrc_add_ID_IE_sig,Rdst_add_ID_IE_sig:  std_logic_vector (2 downto 0);
	signal 	Imm_buff_ID_IE_sig:  std_logic;

        signal STD_IE_IM_sig,PUSH_IE_IM_sig,exc_int_IE_IM_sig,en_mem_wr_IE_IM_sig,
	inc_sp_IE_IM_sig,en_sp_IE_IM_sig,s1_wb_IE_IM_sig,so_wb_IE_IM_sig,out_en_reg_IE_IM_sig,
	s1_IM_IW_sig,so_IM_IW_sig,out_en_reg_IM_IW_sig : std_logic;
	
	signal pc_call_IE_IM_sig,pc_int_int_cir,Rdst_buf_IE_IM_sig,immediate_IE_IM_sig,
	mem_result_IM_IW_sig,immediate_IM_IW_sig,Rdst_buf_IM_IW_sig: std_logic_vector(15 DOWNTO 0);
        signal Rsrc_add_IE_IM_sig,Rdst_add_IE_IM_sig:  std_logic_vector (2 downto 0);
	
	
BEGIN


F:fetch port map(Clk,Rst,Int_en_int_cir_sig,offsetSel_cu_sig,delayJMP_cu_sig,RTI_cu_sig,
	RET_cu_sig,selINTPC_int_cir_sig,stallLD_fu_sig,jmpCond_cu_sig,imm_cu_sig,pc_mem_m_sig,Rdst_buf_IE_IM_sig , Rdst_dec_sig ,counter_sig,counter_RT_sig,ir_fetch_sig,ir_buf_ID_IF_sig,pc_call_ID_IF_sig );

D: Decode Generic map (m=>16) port map (Clk,Rst,ir_buf_ID_IF_sig,write_data_Rdst_WB_sig, Exec_Result_H_IM_IW_sig,ir_fetch_sig,pc_call_ID_IF_sig,Rdst_add_IM_IW_sig, Rsrc_add_IM_IW_sig,write_en_Rsrc_IM_IW_sig,write_en_Rdst_IM_IW_sig,imm_cu_sig,JMP_cond_CU_sig , Stall_LD_FU_sig,Rsrc_buff_ID_IE_sig,Rdst_buff_ID_IE_sig,IR_Immediate_ID_IM_sig,PC_Call_ID_IM_sig,Rsrc_add_ID_IE_sig,Rdst_add_ID_IE_sig,Imm_buff_ID_IE_sig);



M: memory port map(Clk,Rst,Int_en_int_cir_sig,STD_IE_IM_sig,PUSH_IE_IM_sig,exc_int_IE_IM_sig,en_mem_wr_IE_IM_sig,selINTPC_int_cir_sig,en_sp_IE_IM_sig,
inc_sp_IE_IM_sig,en_sp_IE_IM_sig,s1_wb_IE_IM_sig,so_wb_IE_IM_sig,out_en_reg_IE_IM_sig,pc_call_IE_IM_sig,pc_int_int_cir,Rdst_buf_IE_IM_sig,immediate_IE_IM_sig,
Rsrc_add_IE_IM_sig,Rdst_add_IE_IM_sig,mem_result_IM_IW_sig,pc_mem_m_sig,immediate_IM_IW_sig,Rdst_buf_IM_IW_sig,
Rsrc_add_IM_IW_sig,Rdst_add_IM_IW_sig,s1_IM_IW_sig,so_IM_IW_sig,out_en_reg_IM_IW_sig);

END a_pipeline;


