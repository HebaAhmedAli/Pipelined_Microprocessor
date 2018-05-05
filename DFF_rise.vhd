LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY my_DFF_rise IS
     PORT( clk,rst,en,d: IN std_logic;   q : OUT std_logic);
END my_DFF_rise;

ARCHITECTURE a_my_DFF_rise OF my_DFF_rise IS
BEGIN
	PROCESS(clk,rst)
	BEGIN
		IF(rst = '1') THEN
        		q <= '0';
		ELSIF rising_edge(clk) and en='1' THEN     
 	    		q <= d;
		END IF;
	END PROCESS;
END a_my_DFF_rise;


