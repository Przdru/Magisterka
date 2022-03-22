----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:23:49 04/18/2021 
-- Design Name: 
-- Module Name:    Debuncer2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Debouncer2 is
    Port ( clk_i : in  STD_LOGIC;
           debounce : out  STD_LOGIC;
			  rst_i : in  STD_LOGIC;
           input : in  STD_LOGIC);
end Debouncer2;

architecture Behavioral of Debouncer2 is

signal delay2:  STD_LOGIC_vector (7 downto 0); 

begin

process(clk_i, rst_i) is 
	variable count : positive range 1 to 60001 := 1;
	begin
	if rst_i = '0' then 
		count := 1;
		delay2 <= (others => '0');
	else 
		if rising_edge (clk_i) then			
				if (count < 60000) then 
						count := count + 1;
				else 
						count := 1;
						delay2 (7 downto 1) <= delay2 (6 downto 0);
						delay2 (0) <= not(input);
				end if; 
			end if;
		end if; 
end process; 

debounce <= '1' when delay2 = "11111111" else '0'; 

end Behavioral;

