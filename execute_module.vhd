LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity execute is
generic ( n : integer := 16);  

PORT ( Clk,RESET,pop_ID_IE,LDM_ID_IE,LDD_ID_IE,in_ID_IE,IN_OR_LDM_ID_IE,mem_read_in,RTI_sig,SETC_sig,CLRC_sig,SETC_or_CLRC_sig,en_flag_buf_sig,en_exec_result_sig: in std_logic;

	
	in_port_ID_IE,Rdst_buf_in,Rsrc_buf_in,immediate_val_in: in std_logic_vector(n-1 downto 0); --pass it also 
	ALU_op_ctrl: in std_logic_vector (3 downto 0); --pass immediate_val also
	flags_reg : out std_logic_vector (3 downto 0);
	-------------------------------------------------------------

	--pass these control signals 
	rtype_ID_IE,write_en_Rsrc_in,write_en_Rdst_in,inc_SP_in,en_SP_in,en_mem_write_in,out_en_reg_in,S1_WB_in,S0_WB_in,PUSH_sig,STD_sig: in std_logic;
	--pass these registers 
	Rdst_add_in,Rsrc_add_in: in std_logic_vector (2 downto 0); 
	PC_call_in: in std_logic_vector (n-1 downto 0);

	-- outputs of IE_IM buffer
	rtype_IE_IM,mem_read_IE_IM,write_en_Rsrc_IE_IM,write_en_Rdst_IE_IM,inc_SP_IE_IM,en_SP_IE_IM,
	en_mem_write_IE_IM,out_en_reg_IE_IM,S1_WB_IE_IM,S0_WB_IE_IM,PUSH_IE_IM,STD_IE_IM:out std_logic;
	
	
	Rdst_add_IE_IM,Rsrc_add_IE_IM: out std_logic_vector (2 downto 0); 
	PC_call_IE_IM,Rdst_buf_IE_IM,Rsrc_buf_IE_IM: out std_logic_vector (n-1 downto 0);
	immediate_val_IE_IM: out std_logic_vector (n-1 downto 0);
	--------------------------------------------------------

	
	execute_result_H_IE_IM,execute_result_L_IE_IM : out std_logic_vector(n-1 downto 0);
	flags_IE_IM: out std_logic_vector (3 downto 0);
	RTI_ID_IE,RET_ID_IE : in std_logic;
	RTI_IE_IM,RET_IE_IM : out std_logic;

	pop_IE_IM,LDM_IE_IM,LDD_IE_IM,in_IE_IM,IN_OR_LDM_IE_IM:out std_logic;
	in_port_IE_IM : out std_logic_vector (n-1 downto 0)


);
end entity execute;


architecture execute_arch of execute is

component alu_with_flags is 
generic ( n : integer := 16);  

PORT ( Clk,RESET,RTI_sig,SETC_sig,CLRC_sig,SETC_or_CLRC_sig,en_flag_buf_sig,en_Exec_Res: in std_logic;

	Rdst_buf,Rsrc_buf: in std_logic_vector(n-1 downto 0);
	ALU_op_ctrl,immediate_val: in std_logic_vector (3 downto 0);

	execute_result_H,execute_result_L : out std_logic_vector(n-1 downto 0);
	flags: out std_logic_vector (3 downto 0));

end component;

component my_nDFF IS
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));

end component;

component my_nDFF_fall IS
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));

end component;

component my_DFF is 
PORT( clk,rst,en,d : IN std_logic;   q : OUT std_logic);
end component;

signal execute_result_H,execute_result_L : std_logic_vector(n-1 downto 0);
signal	flags,immediate_val_4bits: std_logic_vector (3 downto 0);

begin
immediate_val_4bits <= immediate_val_in(3 downto 0);
alu_module: alu_with_flags generic map (n=>16) port map (Clk,RESET,RTI_sig,SETC_sig,CLRC_sig,SETC_or_CLRC_sig,en_flag_buf_sig,en_exec_result_sig,Rdst_buf_in,Rsrc_buf_in,ALU_op_ctrl,immediate_val_4bits,execute_result_H,execute_result_L,flags);

IE_IM_exec_res_H: my_nDFF generic map (n=>16) port map (Clk,RESET,en_exec_result_sig,execute_result_H,execute_result_H_IE_IM);
IE_IM_exec_res_L: my_nDFF generic map (n=>16) port map (Clk,RESET,en_exec_result_sig,execute_result_L,execute_result_L_IE_IM);

IE_IM_Rdst_add: my_nDFF_fall generic map (n=>3) port map (Clk,RESET,'1',Rdst_add_in,Rdst_add_IE_IM);
IE_IM_Rsrc_add: my_nDFF_fall generic map (n=>3) port map (Clk,RESET,'1', Rsrc_add_in,Rsrc_add_IE_IM);
IE_IM_Rdst_buf: my_nDFF generic map (n=>16) port map (Clk,RESET,'1',Rdst_buf_in,Rdst_buf_IE_IM);
IE_IM_Rsrc_buf: my_nDFF generic map (n=>16) port map (Clk,RESET,'1',Rsrc_buf_in,Rsrc_buf_IE_IM);

IE_IM_immediate: my_nDFF generic map (n=>16) port map (Clk,RESET,'1',immediate_val_in,immediate_val_IE_IM);
IE_IM_PC_call : my_nDFF generic map (n=>16) port map (Clk,RESET,'1',PC_call_in,PC_call_IE_IM);

flags_reg <= flags;
IE_IM_flags: my_nDFF generic map (n=>4) port map (Clk,RESET,'1',flags,flags_IE_IM);


control_sig0: my_DFF generic map (n=>1) port map (Clk,RESET,'1',write_en_Rsrc_in,write_en_Rsrc_IE_IM);
control_sig1: my_DFF generic map (n=>1) port map (Clk,RESET,'1',write_en_Rdst_in,write_en_Rdst_IE_IM);
control_sig2: my_DFF generic map (n=>1) port map (Clk,RESET,'1',inc_SP_in,inc_SP_IE_IM);
control_sig3: my_DFF generic map (n=>1) port map (Clk,RESET,'1',en_SP_in,en_SP_IE_IM);
--control_sig4: my_DFF generic map (n=>1) port map (Clk,RESET,'1',SP_address_in,SP_address_IE_IM);
control_sig5: my_DFF generic map (n=>1) port map (Clk,RESET,'1',en_mem_write_in,en_mem_write_IE_IM);
control_sig6: my_DFF generic map (n=>1) port map (Clk,RESET,'1',mem_read_in,mem_read_IE_IM);

--control_sig7: my_DFF generic map (n=>1) port map (Clk,RESET,'1',LDD_or_pop_in,LDD_or_pop_IE_IM);
control_sig8: my_DFF generic map (n=>1) port map (Clk,RESET,'1',out_en_reg_in,out_en_reg_IE_IM);
control_sig9: my_DFF generic map (n=>1) port map (Clk,RESET,'1',S1_WB_in,S1_WB_IE_IM);
control_sig10: my_DFF generic map (n=>1) port map (Clk,RESET,'1',S0_WB_in,S0_WB_IE_IM);
control_sig11: my_DFF generic map (n=>1) port map (Clk,RESET,'1',STD_sig,STD_IE_IM);
control_sig12: my_DFF generic map (n=>1) port map (Clk,RESET,'1',PUSH_sig,PUSH_IE_IM);
control_sig13: my_DFF generic map (n=>1) port map (Clk,RESET,'1',rtype_ID_IE,rtype_IE_IM);
R_RET : my_DFF port map (Clk,RESET,'1',RET_ID_IE,RET_IE_IM);
R_RTI : my_DFF port map (Clk,RESET,'1',RTI_ID_IE,RTI_IE_IM);	





--R_rtype: my_DFF port map (Clk,RESET,'1',rType_ID_IE,rType_IE_IM);	
R_pop: my_DFF port map (Clk,RESET,'1',pop_ID_IE,pop_IE_IM);	
R_LDM: my_DFF port map (Clk,RESET,'1',LDM_ID_IE,LDM_IE_IM);	
R_LDD: my_DFF port map (Clk,RESET,'1',LDD_ID_IE,LDD_IE_IM);	
R_in: my_DFF port map (Clk,RESET,'1',in_ID_IE,in_IE_IM);	
R_in_or_ldm: my_DFF port map (Clk,RESET,'1',IN_OR_LDM_ID_IE,IN_OR_LDM_IE_IM);	
inn_port: my_nDFF port map(Clk,'0','1',in_port_ID_IE,in_port_IE_IM);



end execute_arch;
