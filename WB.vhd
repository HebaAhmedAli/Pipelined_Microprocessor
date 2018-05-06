
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity  WB IS
	port (	clk,rst: in std_logic ;
		 Mem_Result,Exec_ResH,Immediate,in_port_IM_IW,Rdst_buf_IM_IW: in std_logic_vector(15 downto 0);
		S1_WB,S0_WB,Out_en_Reg: in std_logic;
		Write_Data_Rdst,OUT_Port: out std_logic_vector(15 downto 0)
		);

END WB;


ARCHITECTURE  my_WB of WB is 

component  mux4 is 
	Generic (m : integer :=16);
port ( s1,s0: in std_logic;
	input1,input2,input3,input4: in std_logic_vector(m-1 downto 0);
	output: out std_logic_vector(m-1 downto 0));
end component;



component my_nDFF IS
GENERIC ( n : integer := 16);
PORT( Clk,Rst,enb : IN std_logic;
		   d : IN std_logic_vector(n-1 DOWNTO 0);
		   q : OUT std_logic_vector(n-1 DOWNTO 0));
END component;



begin 

mux_WB: mux4 generic map (m=>16) port map (S1_WB,S0_WB,Mem_Result,Exec_ResH,Immediate,in_port_IM_IW,Write_Data_Rdst);

R_OUT_PORT : my_nDFF generic map (n=>16) port map (clk,rst,Out_en_Reg,Rdst_buf_IM_IW,OUT_Port);



end my_WB;