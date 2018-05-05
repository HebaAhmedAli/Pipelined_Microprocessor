LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity alu_with_flags is
generic ( n : integer := 16);  

PORT ( Clk,RESET,RTI_sig,SETC_sig,CLRC_sig,SETC_or_CLRC_sig,en_flag_buf_sig,en_Exec_Res: in std_logic;

	Rdst_buf,Rsrc_buf: in std_logic_vector(n-1 downto 0);
	ALU_op_ctrl,immediate_val: in std_logic_vector (3 downto 0);

	execute_result_H,execute_result_L : out std_logic_vector(n-1 downto 0);
	flags: out std_logic_vector (3 downto 0)

);
end entity alu_with_flags;


architecture alu_with_flags_arch of alu_with_flags is


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

component mux2_1 is
		GENERIC ( n : integer := 16); 
		PORT (in1,in2 : IN std_logic_vector(n-1 DOWNTO 0);
                    s	:  IN std_logic;
  		   out1 : OUT std_logic_vector(n-1 DOWNTO 0));    
end component;

component mux_2x1_1_bit is
		GENERIC ( n : integer := 16); 
		PORT (in1,in2 : IN std_logic;
                    s	:  IN std_logic;
  		   out1 : OUT std_logic);    
end component;




component alu_integ is
		generic ( n: integer :=16 );
		port(A,B : in std_logic_vector (n-1 downto 0);
		     ALU_op : in std_logic_vector (3 downto 0);
		     cin : in std_logic;
		     immediate_val: in std_logic_vector(3 downto 0);
		     ALU_out : out std_logic_vector (2*n-1 downto 0);
		     cout,overflow,neg : out std_logic );
end  component;
signal flags_in,flags_out,flags_in_buf,flags_out_buf : std_logic_vector(3 downto 0);
signal ALU_out : std_logic_vector (2*n-1 downto 0);

signal zero_flag_alu,overflow_flag_alu,carry_flag_alu,neg_flag_alu,set_carry,carry_vs_alu: std_logic;   --set_carry de htb2a 1 aw 0
signal SETC_or_CLRC: std_logic;

signal zero_compare : std_logic_vector (2*n-1 downto 0) := (others => '0');
begin


alu0: alu_integ generic map (n=>16) port map (Rdst_buf,Rsrc_buf,ALU_op_ctrl,flags_out(2),immediate_val,ALU_out,carry_flag_alu,overflow_flag_alu,neg_flag_alu);

--SETC_or_CLRC_sig <= SETC_sig or CLRC_sig;
mux_carry_set_reset: mux_2x1_1_bit generic map (n=>1) port map ('0','1',SETC_sig,set_carry);
mux_carry_alu_set: mux_2x1_1_bit generic map (n=>1) port map (carry_flag_alu,set_carry,SETC_or_CLRC_sig,carry_vs_alu);

mux_alu_flagBuf_carry: mux_2x1_1_bit generic map (n=>1) port map (carry_vs_alu,flags_out_buf(2),RTI_sig,flags_in(2));

mux_alu_flagBuf_ov: mux_2x1_1_bit generic map (n=>1) port map (overflow_flag_alu,flags_out_buf(0),RTI_sig,flags_in(0));

mux_alu_flagBuf_neg: mux_2x1_1_bit generic map (n=>1) port map (neg_flag_alu,flags_out_buf(1),RTI_sig,flags_in(1));

zero_flag_alu <= '1' when ALU_out = zero_compare
	else '0';

mux_alu_flagBuf_zero: mux_2x1_1_bit generic map (n=>1) port map (zero_flag_alu,flags_out_buf(3),RTI_sig,flags_in(3));


---------------- feryal bdl ma el enable bta3 el flag reg '1' 5aletoh en_Exec_Res

flag:  my_nDFF generic map (n=>4) port map (Clk,RESET,en_Exec_Res,flags_in,flags_out);
flag_buf: my_nDFF_fall  generic map (n=>4) port map (Clk,RESET,en_flag_buf_sig,flags_out,flags_out_buf);

execute_result_H <= ALU_out(2*n-1 downto n);
execute_result_L <= ALU_out(n-1 downto 0);
flags <= flags_out;

end alu_with_flags_arch;
