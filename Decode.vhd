
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity Decode IS
	Generic (m : integer :=16);
	port (	clk,rst: in std_logic ;
		IR_Buff , write_data_Rdst, Exec_Result_H , IR,PC_Call:in std_logic_vector (m-1 downto 0);
		Rdst_add_IM_IW, Rsrc_add_IM_IW: in std_logic_vector(2 downto 0);
		write_en_Rsrc_IM_IW,write_en_Rdst_IM_IW ,Imm_control_signal , JMP_cond , Stall_LD : in std_logic;
		
		 Rsrc_Buff_in,Rdst_Buff_in   : in std_logic_vector(m-1 downto 0 );

		-- from CU 
		rtype_cu,mem_read_sig,RTI_sig,SETC_sig,CLRC_sig,SETC_or_CLRC_sig,en_exec_result_sig : in std_logic;
		ALU_op_ctrl : in std_logic_vector (3 downto 0);
		write_en_Rsrc,write_en_Rdst,inc_SP,en_SP,en_mem_write,out_en_reg,S1_WB,S0_WB: in std_logic;

	
		mem_read_sig_ID_IE,write_en_Rsrc_ID_IE,write_en_Rdst_ID_IE,inc_SP_ID_IE,en_SP_ID_IE,en_mem_write_ID_IE,out_en_reg_ID_IE,S1_WB_ID_IE,S0_WB_ID_IE: out std_logic;
		RTI_sig_ID_IE,SETC_sig_ID_IE,CLRC_sig_ID_IE,SETC_or_CLRC_sig_ID_IE,en_exec_result_sig_ID_IE,rtype_ID_IE : out std_logic;
		ALU_op_ctrl_ID_IE : out std_logic_vector (3 downto 0);
		-- end out CU signals 
		Rsrc_out_RegFile,Rdst_out_RegFile	: out std_logic_vector(m-1 downto 0 );
		Rsrc_buff_ID_IE , Rdst_buff_ID_IE , IR_Immediate_ID_IE ,PC_Call_ID_IE,ReadinFetch_dataBus: out std_logic_vector(m-1 downto 0 );
		Rsrc_add_ID_IE,Rdst_add_ID_IE: out std_logic_vector (2 downto 0);
		Imm_buff_ID_IE: out std_logic;
	------------------------- feryal ----- added signal form FU delay_JMP----------------------
		delay_JMP_fu : in std_logic;
		delay_JMP_ID_IE: out std_logic;
		IN_OR_LDM_cu,LDM_cu: in std_logic;
		IN_OR_LDM_ID_IE,LDM_ID_IE: out std_logic;
		writeEnrDst_ecxept_LDM_IN_cu : in std_logic;
		writeEnrDst_ecxept_LDM_IN_DE : out std_logic;
		selOffsetPc : in std_logic;
		selOffsetPc_ID_IE : out std_logic;
		RTI_cu,RET_cu : in std_logic;
		RTI_ID_IE,RET_ID_IE : out std_logic
		
	);
END Decode;



ARCHITECTURE my_Decode of Decode is 

component tristatebuff IS
	Generic (m : integer :=16);
	port ( input : in std_logic_vector (m-1 downto 0);
		output : out std_logic_vector (m-1 downto 0);
			enable: in std_logic);
END component;

component  my_nDFF IS
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));
END component ;


component my_DFF IS
     PORT(clk,rst,en,d : IN std_logic;   q : OUT std_logic);
end component;

component my_DFF_rise IS
     PORT( clk,rst,en,d: IN std_logic;   q : OUT std_logic);
end component;

component  my_dec8 IS

PORT( in_dec : in std_logic_vector (3 downto 0);
      out_dec: out std_logic_vector (7 downto 0));
END component ;


component mux2_1 IS 
GENERIC ( n : integer := 16); 
		PORT (in1,in2 : IN std_logic_vector(n-1 DOWNTO 0);
                    s	:  IN std_logic;
  		   out1 : OUT std_logic_vector(n-1 DOWNTO 0));    
END component;

component my_nDFF3 IS
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic;
		   q : OUT std_logic);
END component;

component my_nDFF_fall IS
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));
end component ;


signal out_dec_read_in_fetch,out_dec_read_Rsrc,out_dec_read_Rdst,out_dec_write_Rsrc,out_dec_write_Rdst:std_logic_vector (7 downto 0);

signal en_sel_D_read_in_fetch,en_sel_D_read_Rsrc,en_sel_D_read_Rdst,en_sel_D_write_Rsrc,en_sel_D_write_Rdst:std_logic_vector(3 downto 0);

signal R0_input,R1_input,R2_input,R3_input,R4_input,R5_input,R0_output,R1_output,R2_output,R3_output,R4_output,R5_output: std_logic_vector(15 downto 0);
signal en_w_R0 , en_w_R1 , en_w_R2 , en_w_R3 , en_w_R4 , en_w_R5 : std_logic;
signal en_dec_read_in_fetch,en_dec_read_Rsrc,en_dec_read_Rdst:std_logic;
signal sel_mux_data_ExcH_muxR0,sel_mux_data_ExcH_muxR1,sel_mux_data_ExcH_muxR2,sel_mux_data_ExcH_muxR3,sel_mux_data_ExcH_muxR4,sel_mux_data_ExcH_muxR5 : std_logic;
signal JMP_cond_OR_Stall_LD : std_logic;
signal Rsrc_add,Rdst_add:  std_logic_vector (2 downto 0);

------------------------ feryal --------------------------

signal imm_buff_rst,Imm_buff_ID_IE_temp: std_logic;
----------------------------
begin 


D_read_in_fetch : my_dec8 port map (en_sel_D_read_in_fetch,out_dec_read_in_fetch);
D_read_Rsrc : my_dec8 port map (en_sel_D_read_Rsrc,out_dec_read_Rsrc);
D_read_Rdst : my_dec8 port map (en_sel_D_read_Rdst,out_dec_read_Rdst);
D_write_Rsrc : my_dec8 port map (en_sel_D_write_Rsrc,out_dec_write_Rsrc);
D_write_Rdst : my_dec8 port map (en_sel_D_write_Rdst,out_dec_write_Rdst);


R0:my_nDFF generic map (n=>16) port map (clk,rst,en_w_R0,R0_input,R0_output);
R1:my_nDFF generic map (n=>16) port map (clk,rst,en_w_R1,R1_input,R1_output);
R2:my_nDFF generic map (n=>16) port map (clk,rst,en_w_R2,R2_input,R2_output);
R3:my_nDFF generic map (n=>16) port map (clk,rst,en_w_R3,R3_input,R3_output);
R4:my_nDFF generic map (n=>16) port map (clk,rst,en_w_R4,R4_input,R4_output);
R5:my_nDFF generic map (n=>16) port map (clk,rst,en_w_R5,R5_input,R5_output);



T0_read_in_fetch : tristatebuff generic map (m=>16) port map (R0_output,ReadinFetch_dataBus,out_dec_read_in_fetch(0));
T1_read_in_fetch : tristatebuff generic map (m=>16) port map (R1_output,ReadinFetch_dataBus,out_dec_read_in_fetch(1));
T2_read_in_fetch : tristatebuff generic map (m=>16) port map (R2_output,ReadinFetch_dataBus,out_dec_read_in_fetch(2));
T3_read_in_fetch : tristatebuff generic map (m=>16) port map (R3_output,ReadinFetch_dataBus,out_dec_read_in_fetch(3));
T4_read_in_fetch : tristatebuff generic map (m=>16) port map (R4_output,ReadinFetch_dataBus,out_dec_read_in_fetch(4));
T5_read_in_fetch : tristatebuff generic map (m=>16) port map (R5_output,ReadinFetch_dataBus,out_dec_read_in_fetch(5));



T0_read_Rsrc : tristatebuff generic map (m=>16) port map (R0_output,Rsrc_out_RegFile,out_dec_read_Rsrc(0));
T1_read_Rsrc : tristatebuff generic map (m=>16) port map (R1_output,Rsrc_out_RegFile,out_dec_read_Rsrc(1));
T2_read_Rsrc : tristatebuff generic map (m=>16) port map (R2_output,Rsrc_out_RegFile,out_dec_read_Rsrc(2));
T3_read_Rsrc : tristatebuff generic map (m=>16) port map (R3_output,Rsrc_out_RegFile,out_dec_read_Rsrc(3));
T4_read_Rsrc : tristatebuff generic map (m=>16) port map (R4_output,Rsrc_out_RegFile,out_dec_read_Rsrc(4));
T5_read_Rsrc : tristatebuff generic map (m=>16) port map (R5_output,Rsrc_out_RegFile,out_dec_read_Rsrc(5));

T0_read_Rdst : tristatebuff generic map (m=>16) port map (R0_output,Rdst_out_RegFile,out_dec_read_Rdst(0));
T1_read_Rdst : tristatebuff generic map (m=>16) port map (R1_output,Rdst_out_RegFile,out_dec_read_Rdst(1));
T2_read_Rdst : tristatebuff generic map (m=>16) port map (R2_output,Rdst_out_RegFile,out_dec_read_Rdst(2));
T3_read_Rdst : tristatebuff generic map (m=>16) port map (R3_output,Rdst_out_RegFile,out_dec_read_Rdst(3));
T4_read_Rdst : tristatebuff generic map (m=>16) port map (R4_output,Rdst_out_RegFile,out_dec_read_Rdst(4));
T5_read_Rdst : tristatebuff generic map (m=>16) port map (R5_output,Rdst_out_RegFile,out_dec_read_Rdst(5));

M0_write_reg : mux2_1 generic map (n=>16) port map (write_data_Rdst, Exec_Result_H,sel_mux_data_ExcH_muxR0,R0_input);
M1_write_reg : mux2_1 generic map (n=>16) port map (write_data_Rdst, Exec_Result_H,sel_mux_data_ExcH_muxR1,R1_input);
M2_write_reg : mux2_1 generic map (n=>16) port map (write_data_Rdst, Exec_Result_H,sel_mux_data_ExcH_muxR2,R2_input);
M3_write_reg : mux2_1 generic map (n=>16) port map (write_data_Rdst, Exec_Result_H,sel_mux_data_ExcH_muxR3,R3_input);
M4_write_reg : mux2_1 generic map (n=>16) port map (write_data_Rdst, Exec_Result_H,sel_mux_data_ExcH_muxR4,R4_input);
M5_write_reg : mux2_1 generic map (n=>16) port map (write_data_Rdst, Exec_Result_H,sel_mux_data_ExcH_muxR5,R5_input);



en_sel_D_write_Rsrc<=write_en_Rsrc_IM_IW & Rsrc_add_IM_IW;
en_sel_D_write_Rdst<=write_en_Rdst_IM_IW & Rdst_add_IM_IW;

en_sel_D_read_in_fetch <='1' & IR_Buff(2 downto 0);
en_sel_D_read_Rsrc <= '1' & IR_Buff(5 downto 3);
en_sel_D_read_Rdst <= '1' & IR_Buff(2 downto 0);


Rsrc_add<=IR_Buff(5 downto 3);
Rdst_add<=IR_Buff(2 downto 0);


en_w_R0 <= out_dec_write_Rsrc(0) or out_dec_write_Rdst(0);
en_w_R1 <= out_dec_write_Rsrc(1) or out_dec_write_Rdst(1);
en_w_R2 <= out_dec_write_Rsrc(2) or out_dec_write_Rdst(2);
en_w_R3 <= out_dec_write_Rsrc(3) or out_dec_write_Rdst(3); 
en_w_R4 <= out_dec_write_Rsrc(4) or out_dec_write_Rdst(4);
en_w_R5 <= out_dec_write_Rsrc(5) or out_dec_write_Rdst(5);

sel_mux_data_ExcH_muxR0<=out_dec_write_Rsrc(0) and  write_en_Rsrc_IM_IW;
sel_mux_data_ExcH_muxR1<=out_dec_write_Rsrc(1) and  write_en_Rsrc_IM_IW;
sel_mux_data_ExcH_muxR2<=out_dec_write_Rsrc(2) and  write_en_Rsrc_IM_IW;
sel_mux_data_ExcH_muxR3<=out_dec_write_Rsrc(3) and  write_en_Rsrc_IM_IW;
sel_mux_data_ExcH_muxR4<=out_dec_write_Rsrc(4) and  write_en_Rsrc_IM_IW;
sel_mux_data_ExcH_muxR5<=out_dec_write_Rsrc(5) and  write_en_Rsrc_IM_IW;

-- ID_IE
------------------ feryal ------------------------
Imm_buff_ID_IE <= Imm_buff_ID_IE_temp;
imm_buff_rst <= rst or (Imm_buff_ID_IE_temp and clk);

R1_Imm_buff : my_DFF port map (clk,imm_buff_rst,'1',Imm_control_signal,Imm_buff_ID_IE_temp);

R2_Rsrc_buff : my_nDFF_fall generic map (n=>16 ) port map (clk,JMP_cond_OR_Stall_LD,'1',Rsrc_Buff_in,Rsrc_buff_ID_IE );

R3_Rdst_buff : my_nDFF_fall generic map (n=>16 ) port map (clk,JMP_cond_OR_Stall_LD,'1',Rdst_Buff_in, Rdst_buff_ID_IE);

R4_Rsrc_add : my_nDFF_fall generic map (n=>3 ) port map (clk,rst,'1',Rsrc_add,Rsrc_add_ID_IE);

R5_Rdst_add : my_nDFF_fall generic map (n=>3 ) port map (clk,rst,'1',Rdst_add,Rdst_add_ID_IE);


R6_IR_immediate : my_nDFF_fall generic map (n=>16 ) port map (clk,JMP_cond_OR_Stall_LD,'1',IR,IR_Immediate_ID_IE);

R7_PC_Call : my_nDFF generic map (n=>16 ) port map (clk,JMP_cond_OR_Stall_LD,'1',PC_Call,PC_Call_ID_IE);


JMP_cond_OR_Stall_LD <= JMP_cond or Stall_LD ;

-- store the signals of the CU 

R_mem_read_sig:		 my_DFF port map (clk,rst,'1',mem_read_sig,mem_read_sig_ID_IE);
R_RTI_sig:			 my_DFF port map (clk,rst,'1',RTI_sig,RTI_sig_ID_IE);
R_SETC_sig:   		 my_DFF port map (clk,rst,'1',SETC_sig,SETC_sig_ID_IE);
R_CLRC_sig: 		 my_DFF port map (clk,rst,'1',CLRC_sig,CLRC_sig_ID_IE);
R_SETC_or_CLRC_sig : my_DFF port map (clk,rst,'1',SETC_or_CLRC_sig,SETC_or_CLRC_sig_ID_IE);
R_en_exec_result_sig : my_DFF port map (clk,rst,'1',en_exec_result_sig,en_exec_result_sig_ID_IE);
R_ALU_op_ctrl : my_nDFF_fall generic map (n=>4 ) port map (clk,rst,'1', ALU_op_ctrl,ALU_op_ctrl_ID_IE);
R_write_en_Rsrc : my_DFF port map (clk,rst,'1',write_en_Rsrc,write_en_Rsrc_ID_IE);
R_write_en_Rdst : my_DFF port map (clk,rst,'1',write_en_Rdst,write_en_Rdst_ID_IE);
R_rType : my_DFF port map (clk,rst,'1',rtype_cu,rtype_ID_IE);
R_inc_SP : my_DFF port map (clk,rst,'1',inc_SP,inc_SP_ID_IE);
R_en_SP : my_DFF port map (clk,rst,'1',en_SP,en_SP_ID_IE);
R_en_mem_write : my_DFF port map (clk,rst,'1',en_mem_write,en_mem_write_ID_IE);
--R_mem_read: my_DFF port map (clk,rst,'1',mem_read,mem_read_ID_IE);
--R_LDD_or_pop : my_DFF port map (clk,rst,'1',LDD_or_pop,LDD_or_pop_ID_IE);
R_out_en_re : my_DFF port map (clk,rst,'1',out_en_reg,out_en_reg_ID_IE);
R_S1_WB : my_DFF port map (clk,rst,'1',S1_WB,S1_WB_ID_IE);
R_S0_WB: my_DFF port map (clk,rst,'1',S0_WB,S0_WB_ID_IE);
R_delay_JMP: my_DFF port map (clk,rst,'1',delay_JMP_fu,delay_JMP_ID_IE);
R_LDM: my_DFF port map (clk,rst,'1',LDM_cu,LDM_ID_IE);
R_IN_OR_LDM: my_DFF port map (clk,rst,'1',IN_OR_LDM_cu,IN_OR_LDM_ID_IE);
R_writeEnRdst_except_LDM_IN: my_DFF port map (clk,rst,'1',writeEnrDst_ecxept_LDM_IN_cu,writeEnrDst_ecxept_LDM_IN_DE);
R_selOffsetPc : my_DFF port map (clk,rst,'1',selOffsetPc,selOffsetPc_ID_IE);
R_RET : my_DFF port map (clk,rst,'1',RET_cu,RET_ID_IE);
R_RTI : my_DFF port map (clk,rst,'1',RTI_cu,RTI_ID_IE);	
		
	
		

end my_Decode;







