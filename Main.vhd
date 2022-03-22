----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:46:59 03/15/2021 
-- Design Name: 
-- Module Name:    Main - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Main is
    Port ( ----------- zegar g³ówny -----
				clk_i : in  STD_LOGIC;
				------ Przyciski 
			  start : in  STD_LOGIC;
			  rst_i:  in  STD_LOGIC;
			  -- Suwak-------
			  SW0  :  in  STD_LOGIC;
			  SW1  :  in  STD_LOGIC;
			  ------	Diody sygnalizacyjne
			  LD0    : out  STD_LOGIC;
			  LD1    : out  STD_LOGIC;
			  LD2    : out  STD_LOGIC;
			  LD3    : out  STD_LOGIC;
			  --------Wyœwietlacz 8-segmentowy
			  led7_poz : out std_logic_vector (3 downto 0);
			  led7_inf : out std_logic_vector (7 downto 0);
			  -----ADC--------
			  CS 		: out  STD_LOGIC;
			  SCLK 	: out  STD_LOGIC;
			  --- CCD -------
           clk_o1 : out  STD_LOGIC;
           clk_o2 : out  STD_LOGIC;
           RB     : out  STD_LOGIC;
           CLB    : out  STD_LOGIC;
           SHB    : out  STD_LOGIC;
			  TG     : out  STD_LOGIC;
			  ---------Trigger-------------- 
			  trigger_3 : out  STD_LOGIC
			  );
end Main;

architecture Behavioral of Main is
component Debouncer2 Port ( clk_i : in  STD_LOGIC; 
           debounce : out  STD_LOGIC;
			  rst_i : in  STD_LOGIC;
           input : in  STD_LOGIC);
end component Debouncer2;

signal  trybCiaglyStartStop : std_logic; 
signal  debounceStart : std_logic; 
signal  flaga :std_logic;
signal  flaga2 :std_logic;
signal procesTrwa :std_logic;
signal RBsygnal :std_logic;
--------------------Dzielnik Zegara-----------------------
signal count: positive range 1 to 129;
signal clock_procesu : std_logic := '0';
signal Wspolczynnik_Dzielnika :positive range 1 to 128 := 1 ;
-------------------------------------------
signal  liczniksyg : std_logic_vector (5 downto 0); --      0| 1 | 1 | 1 -> licznik do 8 bo od 0 => 0000 do 7 => 0111
signal  ciag : std_Logic_Vector(9 downto 0); -- 898 iloœæ powtórzeñ 
signal  HistoriaStanuPrzycisku : std_Logic_Vector (1 downto 0);
signal  HistoriaStanuPrzycisku2 : std_Logic_Vector (1 downto 0);
signal  TypSygnalow : std_logic_vector (5 downto 0); --46
signal  pojedynczy_cykl_i_pum : std_logic;
signal PDM_licznik : std_Logic_Vector(2 downto 0);
------------------ADC-------------------------
signal  proces_ADC_trwa : std_logic; 
signal  HistoriaStanuRB : std_Logic_Vector (1 downto 0);
signal  flaga_RB : std_logic; 
signal countADC: positive range 1 to 16;
signal wartosciowe_bity : std_logic; 
----------------Sterowanie wyœwietlaczem 8-segmentowym------------------
signal count_wyswietlacz: positive range 1 to 50000;
signal led7_poz_licznik :positive range 1 to 4;
signal wyswietlana_wartosc : std_logic_vector (31 downto 0);

signal pomocniczy : std_logic; 

begin

dstart : Debouncer2 port map (clk_i, debounceStart, rst_i, start);
------------------------DZIELNIK ZEGARA generacja sygna³ów steruj¹cych -------------------------
dzielnik_zegara_sterujacego : process(clk_i,rst_i,SW1)

	begin
		if rst_i='0' then
			count<=1;
			clock_procesu<='0';
		elsif SW1 = '0' then		
			if  (clk_i'event) then			
					count <=count+1;
				if (count = Wspolczynnik_Dzielnika) then -- czas trwania po³ówki okresu = Wspó³czynnik_Dzielnika
						clock_procesu <= NOT clock_procesu; -- zmiana wartoœci sygna³u clock_procesu na przeciwn¹
						count <= 1; -- reset licznika 
				end if;
			end if;
		end if;
end process dzielnik_zegara_sterujacego;	
------------------------Dzielnik zegara do wyœwietlacza-----------------------------
dzielnik_zegara_wyswietlacza : process(clk_i,rst_i)
	begin
	 if rst_i='0'  then
		 led7_poz_licznik <= 1;
		 count_wyswietlacz  <= 1;
	 elsif  rising_edge(clk_i) then	-- zliczanie narastaj¹cych zboczy g³ównego sygna³u zegarowego 
	 
		 count_wyswietlacz <=  count_wyswietlacz + 1;
		 
			if (count_wyswietlacz = 25000) then -- czas trwania po³ówki okresu X*2, 50 MHZ / 25 000 = 2 kHz, a ca³y okres zegara steruj¹cego wyœwietlaczami wynosi 2 kHz/2 = 1kHz
				count_wyswietlacz <= 1;
				
				if (led7_poz_licznik = 4) then 				
						led7_poz_licznik <= 1;
				else
				led7_poz_licznik <= led7_poz_licznik + 1;
				
				end if;
			 end if;
			
	end if;
end process dzielnik_zegara_wyswietlacza ;
---------------------------Wybór wspó³czynnika dzielnika----------------------------
wybor_wspolczynnika_dzielnika : process(clk_i,rst_i)

	begin
		if rst_i='0' then
			Wspolczynnik_Dzielnika <= 1;
		elsif falling_edge(clk_i) and SW1 = '1' and flaga2 = '1' then -- sw1 = 1 -> tryb zmiany prêdkoœci odczytu, proces czu³y na opadaj¹ce zbocze zegara, poniewa¿ flaga2 zmienia stan wraz z narastaj¹cym zboczem zegara i trwa 1 cykl zegara
			if  Wspolczynnik_Dzielnika = 128 then 
					Wspolczynnik_Dzielnika <= 1 ;						
			else 
					Wspolczynnik_Dzielnika <= Wspolczynnik_Dzielnika + Wspolczynnik_Dzielnika ; 	-- zmiana Wspolczynnik_Dzielnika o kolejne potêgi liczby 2, zmniejsza to prêdkoœæ odczytu o po³owê				
			end if;
		end if;

end process wybor_wspolczynnika_dzielnika;	

---------------------------Generacja Sygna³u CCD------------------------------------------
generacjaCCD : process (rst_i, clock_procesu) is 

	begin															  
	if rst_i = '0'   then -- wciœniêty przycisku reset  		
		 ciag <= (others => '0');	
		 liczniksyg <= (others => '0');	
		 pojedynczy_cykl_i_pum <= '0';	
		 procesTrwa <= '0'; 
		 wartosciowe_bity <= '0';
		 PDM_licznik <= (others => '0');
	else	--0
			if rising_edge(clock_procesu)  then	--1
				if(flaga = '1' or procesTrwa = '1') and SW1 = '0' then 	--2||  Je¿eli przycisk BTN0 zosta³ wciœniêty a uk³ad nie znajduje siê w trybie zmiany prêdkoœci nastêpuje generacja sygna³ów		
					if ciag < "1110000010" then --11 1000 0010 = 898 	3||zliczanie okresów sygna³ów zegarowych linijki CCD
						if liczniksyg < TypSygnalow  then  --4
							liczniksyg <= liczniksyg + '1' ; -- Zliczanie do 46 (1 okres sygna³u zegarowego linijki CCD)
							procesTrwa <= '1'; 
								if    pojedynczy_cykl_i_pum = '1' and ciag = "0000010000" and RBsygnal= '0' then --5 - 
									wartosciowe_bity <= '1';-- Umo¿liwia generacjê sygna³ów steruj¹cych ADC
								elsif pojedynczy_cykl_i_pum = '1' and ciag = "1110000000" and RBsygnal= '0' then --5
									wartosciowe_bity <= '0';
								elsif pojedynczy_cykl_i_pum = '0' and ciag = "0000000000" and RBsygnal= '0' then --5 -- PUM start (PUM - Power Up Mode)
									wartosciowe_bity <= '1';
								elsif pojedynczy_cykl_i_pum = '0' and ciag = "0000000010" and RBsygnal= '0' then --5 -- PUM stop 
									wartosciowe_bity <= '0';
								end if;	--5
						else --4
							ciag <=  ciag + '1';
							liczniksyg <= (others => '0');
					end if; --4
					else--3
						if trybCiaglyStartStop = '0' and pojedynczy_cykl_i_pum = '0'  then 	--6 zakoñczenie cyklu 				
							pojedynczy_cykl_i_pum <= '1';
							ciag <= (others => '0'); --  						
	
						elsif trybCiaglyStartStop = '1' then 	-- Wykonano pe³n¹ seriê sygna³ów		6
							ciag <= (others => '0'); -- Po wykonaniu serii wszystkie zmienne s¹ zerowane i mo¿liwe jest ponowne wykonanie pêtli						
							procesTrwa <= '1'; 
							pojedynczy_cykl_i_pum <= '1';
						
						else --6
							if PDM_licznik < "011" then --7 -- PDM (Power Down Mode) Procedura usypiania przetwornika A/C
									PDM_licznik <=  PDM_licznik + '1';
									
							else --7									
									PDM_licznik <= (others => '0');
									ciag <= (others => '0'); 
									procesTrwa <= '0';
									pojedynczy_cykl_i_pum <= '0';						
							end if;--7
					end if ;--6
				liczniksyg <= (others => '0');	--3					
				end if;--3
				end if; --2
	    end if;--1
	end if ;--0
		
end process generacjaCCD;
---------------------------Generacja Sygna³u ADC------------------------------------------
generacjaADC : process (rst_i, clock_procesu) is 

	begin															  
	if rst_i = '0'   then -- wciœniêty przycisk  		
	proces_ADC_trwa <= '0' ; 
	countADC <= 1;
		elsif falling_edge(clock_procesu) 	then -- 
			if ((flaga_RB = '1' or proces_ADC_trwa = '1') and (countADC < 15)) and wartosciowe_bity='1'  then	-- Generacja sygna³ów steruj¹cych przetwornikiem A/C,
				proces_ADC_trwa <= '1' ; 
				countADC <= countADC + 1 ;
			else 
			proces_ADC_trwa <= '0' ; 
			countADC <= 1;
			end if; 
		end if; 		
end process generacjaADC ;

--------------------------Rejestr przesuwny pamiêtaj¹cy stan przycisku Start ------------------------
StawianieFlagi : process (rst_i,clock_procesu,SW1, clk_i) is 
begin	
	if rst_i = '0'   then 
	 HistoriaStanuPrzycisku <= "00" ;	 
	 trybCiaglyStartStop <= '0' ;
	elsif  SW1 = '0' then -- Tryb odczytu
		if rising_edge(clock_procesu) then 
			HistoriaStanuPrzycisku(1) <= HistoriaStanuPrzycisku(0);
			HistoriaStanuPrzycisku(0) <= debounceStart;
			if SW0 = '1' and flaga = '1' then --je¿eli tryb ci¹g³y 
				trybCiaglyStartStop <= trybCiaglyStartStop xor  '1'; -- (1) 1 i 1 -> 0 ||(2) 0 i 1 => 1 ||Je¿eli uk³ad by³ jest w stanie generacji sygnalów kolejne wciœniêcie przycisku BTN0 spowoduje zaprzestanie generacji kolejnych sygna³u po zakoñczeniu generacji obecnej serii sygna³ów (1), Je¿eli uk³ad nie generowa³ sygna³ów rozpocznie siê generacja sygna³ów która zakoñczy siê dopiero po kolejnym wciœniêciu przycisku BTN0
			elsif SW0 = '0' then
				trybCiaglyStartStop <= '0' ;
				
	end if;
	end if; 
	end if;

end process StawianieFlagi;
---------------------------Rejestr przesuwny pamiêtaj¹cy stan przycisku Start przy ustalaniu WD-------------
StawianieFlagi2 : process (rst_i,clk_i,SW1) is 
begin	
	if rst_i = '0'   then 
	 HistoriaStanuPrzycisku2 <= "00" ;
	elsif  SW1 = '1' then -- sw1 = 1 -> tryb zmiany prêdkoœci odczytu,
		if rising_edge(clk_i) then 
			HistoriaStanuPrzycisku2(1) <= HistoriaStanuPrzycisku2(0);-- Rejestr przesuwny 
			HistoriaStanuPrzycisku2(0) <= debounceStart;--	
			end if; 
			end if;

end process StawianieFlagi2;
---------------------------------------Detekcja narastaj¹cego zbocza RB---------------------------------------------------------------
StawianieFlagi3 : process (rst_i,clock_procesu) is  -- clk_i
begin	
	if rst_i = '0'   then 
	 HistoriaStanuRB <= "00" ;
	else 
		if rising_edge(clock_procesu) then  -- Rejestr przesuwny 
			HistoriaStanuRB(1) <= HistoriaStanuRB(0);
			HistoriaStanuRB(0) <= RBsygnal;--		
		end if; 
	end if;

end process StawianieFlagi3;

----------------------------------------------------------------------------

-- Wspó³bie¿ne wyra¿enia    
flaga <= '1' when HistoriaStanuPrzycisku = "01" else '0';
flaga2 <= '1' when HistoriaStanuPrzycisku2 = "01" else '0';
flaga_RB<= '1' when HistoriaStanuRB = "10" else '0';

TG <= '1' when  ciag = "0000000000"  and  liczniksyg < "010111"  and (flaga = '1' or procesTrwa = '1' ) and SW1 = '0' else '0' ; 
 
clk_o1 <= '1' when liczniksyg < "010111" else '0' ;	
		  
clk_o2 <= '0' when  liczniksyg < "010111" else '1' ; 
			 
CLB <= '0' when  (liczniksyg = "010101" or  liczniksyg = "101100") else '1' ; 
		 
RBsygnal <= '0' when (liczniksyg = "001100" or  liczniksyg = "100011") else '1';

RB <= RBsygnal;

 SHB <= '0' when  ((liczniksyg > "000111" and liczniksyg < "001100")or(liczniksyg > "011110" and liczniksyg < "100011")) else '1' ;

CS  <= '0' when  (flaga_RB = '1' or (countADC < 16 and proces_ADC_trwa = '1' )) and (wartosciowe_bity = '1' and pojedynczy_cykl_i_pum = '1' ) else -- tryb pracy ""pojedynczy_cykl_i_pum = '0'
		 '0' when  (flaga_RB = '1' or (countADC < 12 and proces_ADC_trwa = '1' )) and (wartosciowe_bity = '1' and pojedynczy_cykl_i_pum = '0' ) else  -- Power up mode
		 '0' when  PDM_licznik > "00" else  '1'	;
SCLK <= clock_procesu ;


LD3 <= '0' when SW1 = '1' else '1';
LD2 <= '0' when SW0 = '1' else '1';
LD1 <= '0' when rst_i = '0' else '1';
LD0 <= '0' when start = '0' else '1';



led7_poz(3 downto 0) <= "1110" when led7_poz_licznik = 1 else
				"1101" when led7_poz_licznik = 2 else
				"1011" when led7_poz_licznik = 3 else
				"0111" when led7_poz_licznik = 4 else
					"1111" ;

led7_inf( 7 downto 0) <= wyswietlana_wartosc( 7 downto 0)    when led7_poz_licznik = 1 else
								 wyswietlana_wartosc( 15 downto 8)   when led7_poz_licznik = 2 else
								 wyswietlana_wartosc( 23 downto 16)  when led7_poz_licznik = 3 else
								 wyswietlana_wartosc( 31 downto 24)  when led7_poz_licznik = 4 else
								 "11111111" ;	 
			  
wyswietlana_wartosc (31 downto 24)	<= "00100101" when Wspolczynnik_Dzielnika = 1 else --1 CCD
													"10011111" when Wspolczynnik_Dzielnika = 2 else --2 CCD												
													"11111111";
													
wyswietlana_wartosc (23 downto 16)	<= "10011111" when Wspolczynnik_Dzielnika = 1 or Wspolczynnik_Dzielnika = 16  else --1
													"00100101" when Wspolczynnik_Dzielnika = 8 else --2
													"00000011" when Wspolczynnik_Dzielnika = 2 else --0
													"01001001" when Wspolczynnik_Dzielnika = 4 else --5 ;													
													"11111111";
													
wyswietlana_wartosc (15 downto 8)	<= "10011111" when Wspolczynnik_Dzielnika = 128 else --1
													"00001101" when Wspolczynnik_Dzielnika = 16 or Wspolczynnik_Dzielnika = 64  else --3
													"10011001" when Wspolczynnik_Dzielnika = 4 else --4
													"01000001" when Wspolczynnik_Dzielnika = 32 else --6
													"00011111" when Wspolczynnik_Dzielnika = 1 or Wspolczynnik_Dzielnika = 8  else --7	
													"00000001" when Wspolczynnik_Dzielnika = 2 else --8
													"11111111";		

wyswietlana_wartosc (7 downto 0)	<= "10011111" when Wspolczynnik_Dzielnika = 8 else --1
													"00001101" when Wspolczynnik_Dzielnika = 1 or Wspolczynnik_Dzielnika = 4 or Wspolczynnik_Dzielnika = 64 else --3
													"01001001" when Wspolczynnik_Dzielnika = 16 else --5
													"01000001" when Wspolczynnik_Dzielnika = 2 or Wspolczynnik_Dzielnika = 128  else --6
													"00011111" when Wspolczynnik_Dzielnika = 32 else --7													
													"11111111";	

pomocniczy <= '0' when  (flaga_RB = '1' or (countADC < 16 and proces_ADC_trwa = '1' )) and (wartosciowe_bity = '1' and pojedynczy_cykl_i_pum = '1' ) else -- tryb pracy ""pojedynczy_cykl_i_pum = '0'
		 '0' when  (flaga_RB = '1' or (countADC < 12 and proces_ADC_trwa = '1' )) and (wartosciowe_bity = '1' and pojedynczy_cykl_i_pum = '0' ) else  -- Power up mode
		 '0' when  PDM_licznik > "00" else  '1'	;
												
trigger_3 <= '1' when pomocniczy = '1' else clock_procesu  ;

TypSygnalow <= "101101"; -- by³o 1101 13 || 101110 - 46				
					
end Behavioral;

