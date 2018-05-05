
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY fetch IS
	
	port (Clk : IN std_logic;
              Reset,Int_en,select_offset,delay_jmp,RTI,RET,Int_pc_sel,stall_ld,jmp_cond,imm_buf,IN_OR_LDM_ID_IE,LDM_ID_IE: in std_logic;
           pc_mem,Rdst_buf_ie_im,Rdst,IN_Port,Imm_val_ID_IE : IN std_logic_vector(15 DOWNTO 0);
          counter: IN std_logic_vector(2 DOWNTO 0);
counter_RT: IN std_logic_vector(1 DOWNTO 0);
            ir_fetch,ir_buf,pc_call,pc_to_int: out std_logic_vector(15 DOWNTO 0)
           ); 
		
END fetch;

ARCHITECTURE fetchh OF fetch IS
	
component my_nDFF 
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));
end component;

component my_nDFF_fall 
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));
end component;

component ram
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(8 DOWNTO 0);
		datain  : IN  std_logic_vector(15 DOWNTO 0);
		dataout : OUT std_logic_vector(15 DOWNTO 0));
end component;


component mux2_1 IS 
GENERIC ( n : integer := 16); 
		PORT (in1,in2 : IN std_logic_vector(n-1 DOWNTO 0);
                    s	:  IN std_logic;
  		   out1 : OUT std_logic_vector(n-1 DOWNTO 0));    
end component;

component my_nDFF3 IS
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic;
		   q : OUT std_logic);
END component;


signal pc_out,pc_in,pc_mux2_out,pc_mux3_out,ir,pc_inc,pc_mux4_out,pc_mux5_out : std_logic_vector(15 DOWNTO 0);
signal en_pc,counter_0_1_2_3,counter_1_2_3,counter_rt_1_2,pc_mux1_s,pc_mux2_s,pc_mux3_s,jmp_ir,call_ir,rst_ir_buf,rst_pcc_cal  : std_logic;
signal ir_buf_en:std_logic; --fatema
SIGNAL Clk2 :  std_logic;
CONSTANT timestep : time :=70 ps;

BEGIN

  

ramm: ram port map (Clk,'0',pc_out(8 downto 0),"0000000000000000",ir);
ir_fetch <= ir;
counter_0_1_2_3 <= (not(counter(2)) and not(counter(1)) and not(counter(0)))
                  or counter_1_2_3 ;

counter_1_2_3 <= (not(counter(2)) and not(counter(1)) and (counter(0)))
                  or (not(counter(2)) and (counter(1)) and not(counter(0)))
                  or (not(counter(2)) and (counter(1)) and (counter(0)));

counter_rt_1_2 <= ( not(counter_RT(1)) and (counter_RT(0)))
                  or ((counter_RT(1)) and not(counter_RT(0)));


en_pc <= stall_ld nor (Int_en and counter_0_1_2_3 );
pc: my_nDFF_fall port map(Clk,'0',en_pc,pc_in,pc_out);
pc_to_int<=pc_out;
pc_mux1_s<= int_pc_sel or Reset or RET or RTI;

pc_mux1: mux2_1 port map(pc_mux2_out,pc_mem,pc_mux1_s,pc_in);
pc_inc <= pc_out + 1;
jmp_ir <= not(ir(15)) and not(ir(14)) and not(ir(13)) and not(ir(12)) and not(ir(11)) and (ir(10)) and (ir(9));
call_ir <= not(ir(15)) and ir(14) and ir(13) and not(ir(12)) and not(ir(11)) and not(ir(10)) and not(ir(9));
pc_mux3_s <= (call_ir and not(delay_jmp)) or (jmp_ir and not(delay_jmp));
pc_mux2_s <= select_offset or pc_mux3_s;   
pc_mux2: mux2_1 port map(pc_inc,pc_mux3_out,pc_mux2_s,pc_mux2_out);
pc_mux3: mux2_1 port map(Rdst_buf_ie_im,pc_mux4_out,pc_mux3_s,pc_mux3_out);


--------------------------- feryal added dol 34an el LDM wel IN case ------------------
pc_mux4: mux2_1 port map(Rdst,pc_mux5_out,IN_OR_LDM_ID_IE,pc_mux4_out);
pc_mux5: mux2_1 port map(IN_Port,Imm_val_ID_IE,LDM_ID_IE,pc_mux5_out);


----------------------------------------------------------------------------


rst_ir_buf <= counter_1_2_3 or counter_rt_1_2 or jmp_cond or imm_buf or Reset;
rst_pcc_cal <= jmp_cond or Reset;
ir_buf_en<= "not"(stall_ld) or Reset;
irr_buf: my_nDFF_fall port map(Clk,rst_ir_buf,"not"(stall_ld),ir,ir_buf);
pcc_call: my_nDFF port map(Clk,rst_pcc_cal,'1',pc_inc,pc_call);


END fetchh;
