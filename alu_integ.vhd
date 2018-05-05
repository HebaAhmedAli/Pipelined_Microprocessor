LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity alu_integ is
		generic ( n: integer :=16 );
		port(A,B : in std_logic_vector (n-1 downto 0);
		     ALU_op : in std_logic_vector (3 downto 0);
		     cin : in std_logic;
		     immediate_val: in std_logic_vector(3 downto 0);
		     ALU_out : out std_logic_vector (2*n-1 downto 0);
		     cout,overflow,neg : out std_logic );
end entity alu_integ;



architecture alu_integ_arch of alu_integ is


component alu_partA is 
		   GENERIC (n : integer := 16);

	PORT ( a,b: IN std_logic_vector (n-1 DOWNTO 0);
	sel_op : IN std_logic_vector (1 DOWNTO 0);
	result: OUT std_logic_vector (n-1 DOWNTO 0);
	cout,overflow,neg: OUT std_logic);
end component; 

component alu_partB is 
		   GENERIC (n : integer := 16);

	PORT ( a,b: IN std_logic_vector (n-1 DOWNTO 0);
	sel_op : IN std_logic_vector (1 DOWNTO 0);
	result: OUT std_logic_vector (n-1 DOWNTO 0));
end component;

component alu_partC is 
	GENERIC (n : integer := 16);
		PORT ( a,b: IN std_logic_vector (n-1 DOWNTO 0);
sel_op : IN std_logic_vector (1 DOWNTO 0);
cin : in std_logic;
immediate_val: in std_logic_vector(3 downto 0);
result: OUT std_logic_vector (n-1 DOWNTO 0);
cout : out std_logic);

end component;

component alu_partMul is
	GENERIC (n : integer := 16); 
		PORT ( a,b: IN std_logic_vector (n-1 DOWNTO 0);
	sel_op : IN std_logic_vector (1 DOWNTO 0);
	result: OUT std_logic_vector (2*n-1 DOWNTO 0);
	neg:out std_logic);
end component;

component mux2_1 is
		GENERIC ( n : integer := 16); 
		PORT (in1,in2 : IN std_logic_vector(n-1 DOWNTO 0);
                    s	:  IN std_logic;
  		   out1 : OUT std_logic_vector(n-1 DOWNTO 0));    
end component;

signal result_mul,result_a_b_mux,result_c_mul_mux,result_a_32,result_b_32,result_c_32: std_logic_vector (2*n-1 downto 0);
signal concat_zeroes: std_logic_vector (n-1 downto 0) := (others => '0');
signal result_a,result_b,result_c: std_logic_vector (n-1 downto 0);
signal xcout_a,xcout_c,xoverflow,x_neg_a,x_neg_mul : std_logic;
begin

	
	u0: alu_partA generic map (n => 16) PORT MAP  (A,B,ALU_op(1 downto 0),result_a,xcout_a,xoverflow, x_neg_a);
	u1: alu_partB generic map (n => 16) PORT MAP  (A,B,ALU_op(1 downto 0),result_b);
	u2: alu_partC generic map (n => 16) PORT MAP (A,B,ALU_op(1 downto 0),cin,immediate_val,result_c ,xcout_c);

	result_a_32 <= concat_zeroes & result_a;
	result_b_32 <= concat_zeroes & result_b;
	result_c_32 <= concat_zeroes & result_c;

	u3: alu_partMul generic map (n => 16) port map (A,B,ALU_op(1 downto 0),result_mul,x_neg_mul);
	u4: mux2_1 generic map (n => 32) PORT MAP (result_a_32,result_b_32,ALU_op(2),result_a_b_mux);
	u5: mux2_1 generic map (n => 32) port map (result_c_32,result_mul,ALU_op(2),result_c_mul_mux);
	u6: mux2_1 generic map (n => 32) port map (result_a_b_mux,result_c_mul_mux,ALU_op(3),ALU_out);

	cout <= xcout_a when ALU_op(3)='0' and ALU_op(2)='0'
	else xcout_c when ALU_op(3)='1' and ALU_op(2)='0';
	--else '0';

	overflow <= xoverflow when ALU_op(3)='0' and ALU_op(2)='0';
	--else '0';
	
	neg <= x_neg_a when ALU_op(3)='0' and ALU_op(2)='0'
	else x_neg_mul when ALU_op(3)='1' and ALU_op(2)='1';
	--else '0';
	-- latck=h 34an m8yar4 el value elly fel flag

end  alu_integ_arch;
