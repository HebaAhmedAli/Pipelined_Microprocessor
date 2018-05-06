

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY memory IS
	
	port (Clk,Reset : IN std_logic;
		in_port_IE_IM : in std_logic_vector (15 downto 0);

		mem_read_IE_IM,int_en,std,push,exc_int,en_mem_wr,int_pc_sel,sp_address,inc_sp,en_sp: in std_logic;
		s1_wb_ie_im,so_wb_ie_im,out_en_reg_ie_im,en_write_Rdst_IE_IM,en_write_Rsrc_IE_IM: in std_logic;
		pc_call,pc_int,Rdst_buf_ie_im,immediate_ie_m,Exc_result_H_IE_IM,Exc_result_L_IE_IM: IN std_logic_vector(15 DOWNTO 0);

		Rsrc_add_ie_im,Rdst_add_ie_im : IN std_logic_vector(2 DOWNTO 0);

		mem_result,pc_mem,immediate_im_iw,Rdst_buf_im_iw,Exc_result_H_IM_IW,Exc_result_L_IM_IW: out std_logic_vector(15 DOWNTO 0);
		Rsrc_add_im_iw,Rdst_add_im_iw: out std_logic_vector(2 DOWNTO 0);
		s1_wb,so_wb,out_en_reg_im_iw,en_write_Rdst_IM_IW,en_write_Rsrc_IM_IW,mem_read_IM_IW: out std_logic;
          in_port_IM_IW : out std_logic_vector (15 downto 0)

	); 
		
END memory;

ARCHITECTURE memoryy OF memory IS

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


component my_nDFF_sp is
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));
END component;


component  my_DFF IS
     PORT(clk,rst,en,d : IN std_logic;   q : OUT std_logic);
END component;


signal  sp_out,sp_mux_out,sp_inc,sp_dec,data_mem_in,data_mem_out,mem_address,mem_mux2_out,mem_mux3_out,mem_mux4_out,mem_in_mux2_out: std_logic_vector(15 DOWNTO 0);
signal  en_mem,enable_sp,mem_mux1_s,mem_mux2_s,mem_in_mux1_s: std_logic;

BEGIN

en_mem <= exc_int or en_mem_wr;
mem: ram port map (Clk,en_mem,mem_address(8 downto 0),data_mem_in,data_mem_out);
enable_sp <= en_sp or exc_int;
sp_inc <= sp_out+1;
sp_dec <= sp_out-1;
sp_reg: my_nDFF_sp port map (Clk,Reset,enable_sp ,sp_mux_out,sp_out);
sp_mux: mux2_1 port map(sp_dec,sp_inc,inc_sp,sp_mux_out);

mem_mux1_s <= int_pc_sel or Reset;
mem_mux1: mux2_1 port map(mem_mux2_out,mem_mux4_out,mem_mux1_s,mem_address);
mem_mux2_s <= sp_address or exc_int;
mem_mux2: mux2_1 port map(immediate_ie_m,mem_mux3_out,mem_mux2_s,mem_mux2_out);
mem_mux3: mux2_1 port map(sp_out,sp_inc,inc_sp,mem_mux3_out);
mem_mux4: mux2_1 port map("0000000000000000","0000000000000001",int_pc_sel,mem_mux4_out);

mem_in_mux1_s <= std or push;
mem_in_mux1: mux2_1 port map(mem_in_mux2_out,Rdst_buf_ie_im,mem_in_mux1_s,data_mem_in);
mem_in_mux2: mux2_1 port map(pc_call,pc_int,int_en,mem_in_mux2_out);

memm_result: my_nDFF port map(Clk,Reset,'1',data_mem_out,mem_result);

pcc_mem: my_nDFF port map(Clk,'0','1',data_mem_out,pc_mem);

--immediate_im_iw <= immediate_ie_m;
immediate_im_iww: my_nDFF port map(Clk,Reset,'1',immediate_ie_m,immediate_im_iw);

--Rdst_buf_im_iw <= Rdst_buf_ie_im;
Rdst_buf_im_iww:my_nDFF port map(Clk,Reset,'1', Rdst_buf_ie_im,Rdst_buf_im_iw);

--Rsrc_add_im_iw <= Rsrc_add_ie_im;
Rsrc_add_im_iww: my_nDFF_fall generic map(n=>3) port map(Clk,Reset,'1', Rsrc_add_ie_im,Rsrc_add_im_iw );

--Rdst_add_im_iw <= Rdst_add_ie_im;
Rdst_add_im_iww:  my_nDFF_fall generic map(n=>3) port map(Clk,Reset,'1', Rdst_add_ie_im ,Rdst_add_im_iw);

--s1_wb <=  s1_wb_ie_im;
s1_wbb: my_DFF port map( Clk,Reset,'1',s1_wb_ie_im,s1_wb);

--so_wb <= so_wb_ie_im;
s0_wbb: my_DFF port map(Clk,Reset,'1',so_wb_ie_im, so_wb);

--out_en_reg_im_iw <= out_en_reg_ie_im;
out_en_reg_im_iww: my_DFF port map(Clk,Reset,'1', out_en_reg_ie_im,out_en_reg_im_iw );

mem_read_reg_im_iw: my_DFF port map(Clk,Reset,'1',mem_read_IE_IM, mem_read_IM_IW );

exc_h:my_nDFF port map(Clk,Reset,'1',Exc_result_H_IE_IM, Exc_result_H_IM_IW);
exc_l:my_nDFF port map(Clk,Reset,'1',Exc_result_L_IE_IM, Exc_result_L_IM_IW);

rdst_wr:my_DFF port map(Clk,Reset,'1',en_write_Rdst_IE_IM,en_write_Rdst_IM_IW);
rsrc_wr:my_DFF port map(Clk,Reset,'1',en_write_Rsrc_IE_IM,en_write_Rsrc_IM_IW);

inn_port: my_nDFF port map(Clk,'0','1',in_port_IE_IM,in_port_IM_IW);

END memoryy;