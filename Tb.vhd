--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:30:35 09/05/2021
-- Design Name:   
-- Module Name:   C:/Users/ASUS/Desktop/eti/M-sem-3/mag/Program/Sterowanie/v2/Sterowanie_v2/Tb.vhd
-- Project Name:  Sterowanie_v2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY Tb IS
END Tb;
 
ARCHITECTURE behavior OF Tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Main
    PORT(
         clk_i : IN  std_logic;
         start : IN  std_logic;
         rst_i : IN  std_logic;
         SW0 : IN  std_logic;
         SW1 : IN  std_logic;
         LD0 : OUT  std_logic;
         LD1 : OUT  std_logic;
         LD2 : OUT  std_logic;
         LD3 : OUT  std_logic;
         led7_poz : OUT  std_logic_vector(3 downto 0);
         led7_inf : OUT  std_logic_vector(7 downto 0);
         CS : OUT  std_logic;
         SCLK : OUT  std_logic;
         clk_o1 : OUT  std_logic;
         clk_o2 : OUT  std_logic;
         RB : OUT  std_logic;
         CLB : OUT  std_logic;
         SHB : OUT  std_logic;
         TG : OUT  std_logic;
			--trigger_1 : out  STD_LOGIC;
			--trigger_2 : out  STD_LOGIC;
			trigger_3 : out  STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal start : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal SW0 : std_logic := '0';
   signal SW1 : std_logic := '0';

 	--Outputs
   signal LD0 : std_logic;
   signal LD1 : std_logic;
   signal LD2 : std_logic;
   signal LD3 : std_logic;
   signal led7_poz : std_logic_vector(3 downto 0);
   signal led7_inf : std_logic_vector(7 downto 0);
   signal CS : std_logic;
   signal SCLK : std_logic;
   signal clk_o1 : std_logic;
   signal clk_o2 : std_logic;
   signal RB : std_logic;
   signal CLB : std_logic;
   signal SHB : std_logic;
   signal TG : std_logic;
	--signal trigger_1 : STD_LOGIC;
	--signal trigger_2 : STD_LOGIC;
	signal trigger_3 : STD_LOGIC;

   -- Clock period definitions
   constant clk_i_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Main PORT MAP (
          clk_i => clk_i,
          start => start,
          rst_i => rst_i,
          SW0 => SW0,
          SW1 => SW1,
          LD0 => LD0,
          LD1 => LD1,
          LD2 => LD2,
          LD3 => LD3,
          led7_poz => led7_poz,
          led7_inf => led7_inf,
          CS => CS,
          SCLK => SCLK,
          clk_o1 => clk_o1,
          clk_o2 => clk_o2,
          RB => RB,
          CLB => CLB,
          SHB => SHB,
          TG => TG,
			 --trigger_1 => trigger_1,
			 --trigger_2 => trigger_2,
			 trigger_3 => trigger_3
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 
   

   -- Stimulus process
   stim_proc: process
   begin		
      rst_i <= '0' ; -- wciœniêty reset
		 wait for 100 ns;
		 
		rst_i <= '1' ; -- odpuszczony reset
		wait for 500 ns;
		
--		SW1 <= '1'; 
--		wait for 2 ms;
--		
--		start <= '0'; -- wciœniêty przycisk startu
--	wait for 2 ms; -- czekanie na debuncer
		
--		start <= '1';-- odpuszczony przycisk 
--		wait for 3 ms;
				
--		SW1 <= '0'; 
--		wait for 2 ms;
		
		 start <= '0'; -- wciœniêty przycisk startu
		wait for 10 ms; -- czekanie na debuncer
		
		start <= '1';-- odpuszczony przycisk 
		wait for 3 ms; -- czas na wykonanie algorytmu 
		
		 start <= '0'; -- wciœniêty przycisk
		wait for 10 ms; -- czekanie na debuncer
		
		start <= '1';-- odpuszczony przycisk 
		 wait for 2 ms;
		 
		 SW0 <= '1'; -- przesuniêcie SW0 tryb ci¹g³y pracy 
		  wait for 2 ms;
		  
		  start <= '0';-- wciœniêty przycisk startu
		  wait for 10 ms;-- czekanie na debuncer
		  
		   start <= '1';-- odpuszczony przycisk 
			 wait for 5 ms;-- czas na wykonanie algorytmu 
			 
			 start <= '0';-- wciœniêty przycisk startuzakoñczenie ci¹g³ej pracy			 
		 wait for 10 ms;-- czekanie na debuncer
		 
		   start <= '1';-- odpuszczony przycisk 
			 wait for 2 ms;
	-------------------------------------------------------------------		 
			 SW1 <= '1' ;--  przesuniêcie SW0 w trym zgodny z DS
			 SW0 <= '0'; -- przesuniêcie SW0 tryb pojedyñczej pracy 
			wait for 2 ms;
			
			start <= '0'; -- wciœniêty przycisk startu || WD=1
		wait for 10 ms; -- czekanie na debuncer
		
		start <= '1';-- odpuszczony przycisk 
		wait for 2 ms; -- czas na wykonanie algorytmu 
		
		 start <= '0'; -- wciœniêty przycisk  || WD=2
		wait for 10 ms; -- czekanie na debuncer
		
		start <= '1';-- odpuszczony przycisk 
		 wait for 2 ms; 		 
		  
		  start <= '0';-- wciœniêty przycisk startu  || WD=4
		  wait for 10 ms;-- czekanie na debuncer
		  
		   start <= '1';-- odpuszczony przycisk 
			 wait for 2 ms;-- czas na wykonanie algorytmu 
			 
			 start <= '0';-- wciœniêty przycisk startu  || WD=8		 
		 wait for 10 ms;-- czekanie na debuncer
		 
		 start <= '1';-- odpuszczony przycisk 
			 wait for 2 ms;-- czas na wykonanie algorytmu 
			 
			  start <= '0';-- wciœniêty przycisk startu  || WD=0		 
		 wait for 10 ms;-- czekanie na debuncer
		 
		   start <= '0';-- odpuszczony przycisk 
			SW1 <= '0' ;
			wait for 2 ms;
			start <= '0';-- wciœniêty przycisk startu  || WD=8		 
		 wait for 10 ms;-- czekanie na debuncer
		 
		 start <= '1';-- odpuszczony przycisk 
			 wait for 2 ms;-- czas na wykonanie algorytmu 
			 
      wait;
   end process;

END;
