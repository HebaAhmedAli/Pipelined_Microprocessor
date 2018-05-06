library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;  
entity counterINT is
  generic (n:integer :=3); 
  Port ( rst,clk : in STD_LOGIC;
   up: in STD_LOGIC;                             
   z : out STD_LOGIC_vector( n-1 downto 0 ));
end counterINT;

architecture Behavioral of counterINT is
  signal zint:  unsigned( n-1 downto 0 ) ;   
begin
  z<= std_logic_vector(zint);             
  process (clk)
  begin
    if rising_edge(clk) then              
      if rst ='1' then                   
        zint <= "000";
    --elsif zint = "100" then
      --  zint <= "100";        
      elsif (up='1')then
        zint <= zint+1;
     
      end if;
    end if;
  end process;
end Behavioral;

