-- Authors:
-- Lab Group 11:
-- Sahaj Singh Student#: 301437700
-- Bryce Leung Student#: 301421630 
-- Sukha Lee 	Student#: 301380632

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
         LEDG : out std_logic_vector(7 downto 0);
         LEDR : out std_logic_vector(17 downto 0);
			LCD_EN : out std_logic;
			LCD_RS : out std_logic;
			LCD_ON : out std_logic;
			LCD_BLON : out std_logic;
			LCD_RW : out std_logic;
			LCD_DATA : out std_logic_vector(7 downto 0));
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

	-- Calling clkDivider component
	component clkDivider IS
    PORT ( 
		 clkIn     : IN STD_LOGIC;
		 clkOut    : OUT STD_LOGIC) ;
    END component;

	 -- Calling ksa_Quarter1 component
    component ksa_Quarter1 is
      port(clk : in  std_logic;  -- Clock pin
             finished : out std_logic;
             error: out std_logic;
             key : out std_logic_vector(23 downto 0);
				 outarray : out outputBuffer); 
    end component;
    
	 -- Calling ksa_Quarter2 component
    component ksa_Quarter2 is
      port(clk : in  std_logic;  -- Clock pin
             finished : out std_logic;
             error: out std_logic;
             key : out std_logic_vector(23 downto 0);
				 outarray : out outputBuffer); 
    end component;
	 
	 -- Calling ksa_Quarter3 component
    component ksa_Quarter3 is
      port(clk : in  std_logic;  -- Clock pin
             finished : out std_logic;
             error: out std_logic;
             key : out std_logic_vector(23 downto 0);
				 outarray : out outputBuffer); 
    end component;
	 
	 -- Calling ksa_Quarter4 component
    component ksa_Quarter4 is
      port(clk : in  std_logic;  -- Clock pin
             finished : out std_logic;
             error: out std_logic;
             key : out std_logic_vector(23 downto 0);
				 outarray : out outputBuffer); 
    end component;
    
	 -- Declaring signals for the decryption core components 
    signal finished_q1, error_q1 : std_logic := '0';
    signal finished_q2, error_q2 : std_logic := '0';
	 signal finished_q3, error_q3 : std_logic := '0';
	 signal finished_q4, error_q4 : std_logic := '0';
    signal key_q1, key_q2, key_q3, key_q4 : std_logic_vector(23 downto 0) := (others => '0');
    
	 -- Declaring array signals 
	 signal outputBuffer_r, outputBuffer_r_q1, outputBuffer_r_q2, outputBuffer_r_q3, outputBuffer_r_q4 : outputBuffer;
	 
	 -- Declaring slow clock signal 
	 signal slow_clock : std_logic := '0';
	 
	 -- Declaring the LCD_run signal that starts the LCD printing
	 signal LCD_run : std_logic := '0';

     TYPE CodeSet IS (I1, I2, I3, I4, I5, I6, C_Get, I_swap1, I_swap2);
    SIGNAL LCD_DataS : CodeSet;
	 
begin
	-- Port mapping the components and linking to intermediate signals 
	 obj0: clkDivider port map (CLOCK_50, slow_clock);
    obj1 : ksa_Quarter1 port map (CLOCK_50, finished_q1, error_q1, key_q1, outputBuffer_r_q1);
    obj2 : ksa_Quarter2 port map (CLOCK_50, finished_q2, error_q2, key_q2, outputBuffer_r_q2);
	 obj3 : ksa_Quarter3 port map (CLOCK_50, finished_q3, error_q3, key_q3, outputBuffer_r_q3);
	 obj4 : ksa_Quarter4 port map (CLOCK_50, finished_q4, error_q4, key_q4, outputBuffer_r_q4);
    
	 -- Applying static settings to the LCD 
	 LCD_ON <= '1';
	 LCD_BLON <= '1';
	 LCD_RW <= '0';
	 
	 -- Process that checks the status of both decryption cores and outputs to the user a result based on which core completed and found the secret key first
    process(finished_q1, finished_q2, finished_q3, finished_q4, key_q1, key_q2, key_q3, key_q4, outputBuffer_r_q1, outputBuffer_r_q2, outputBuffer_r_q3, outputBuffer_r_q4, error_q1, error_q2, error_q3, error_q4)
    begin
		LEDR <= (others => '0'); -- Intilaize red LEDs to be off
		LEDG <= (others => '0'); -- Initilaize green LEDs to be off
		
		-- Initilize the decrypted message array to be 0
		for i in 31 downto 0 loop
			outputBuffer_r(i) <= (others => '0');
		end loop;
		 
	  if finished_q1 = '1' then -- Checks for the completion flag from the even key decryption core
			LEDG(0) <= '1';
			LEDG(7) <= '0';
			LCD_run <= '1';
			outputBuffer_r <= outputBuffer_r_q1;
			LEDR <= key_q1(17 downto 0);
	  elsif finished_q2 = '1' then -- Checks for the completion flag from the odd key decryption core
			LEDG(0) <= '1';
			LEDG(7) <= '0';
			LCD_run <= '1';
			outputBuffer_r <= outputBuffer_r_q2;
			LEDR <= key_q2(17 downto 0);
	  elsif finished_q3 = '1' then -- Checks for the completion flag from the even key decryption core
			LEDG(0) <= '1';
			LEDG(7) <= '0';
			LCD_run <= '1';
			outputBuffer_r <= outputBuffer_r_q3;
			LEDR <= key_q3(17 downto 0);
	  elsif finished_q4 = '1' then -- Checks for the completion flag from the odd key decryption core
			LEDG(0) <= '1';
			LEDG(7) <= '0';
			LCD_run <= '1';
			outputBuffer_r <= outputBuffer_r_q4;
			LEDR <= key_q4(17 downto 0);
	  elsif error_q1 = '1' and error_q2 = '1' and error_q3 = '1' and error_q4 = '1' then -- Checks if both decryption cores could not find a key 
			LEDG(0) <= '0';
			LEDG(7) <= '1';
			LCD_run <= '0';
			LEDR <= (others => '0');
	  else -- When no flags are set the leds and display remain unused 
			LCD_run <= '0';
			LEDG(0) <= '0';
			LEDG(7) <= '0';
	  end if;
    end process;
	 
	 -- Process to print the decrypted message to the LCD
	 process(slow_clock, LCD_run)
			Variable lcd_pos : integer range 0 to 32 := 0;
			variable switched1 : std_logic := '0';
		begin
			LCD_EN <= slow_clock;
			if(rising_edge(slow_clock) and LCD_run = '1') then
				CASE LCD_DataS IS
                WHEN I1 => -- Initialization state
						 LCD_RS <= '0'; -- Sets LCD to recieve instruction
						 LCD_DATA <= X"38";
						 LCD_DataS <= I2;
                WHEN I2 => -- Initialization state
						LCD_DATA <= X"38";
						LCD_DataS <= I3;
                WHEN I3 => -- Initialization state
						LCD_DATA <= X"0C";
						LCD_DataS <= I4;
                WHEN I4 => -- Initialization state
						LCD_DATA <= X"01";
						LCD_DataS <= I5;
                WHEN I5 => -- Initialization state
						LCD_DATA <= X"06";
						LCD_DataS <= I6;
                WHEN I6 => -- Initialization state
						LCD_DATA <= X"80";
						LCD_DataS <= C_Get;
					 WHEN C_Get => -- Writing state
						if(lcd_pos = 16 and switched1 = '0') then -- When it hits the visible end of the first row
							LCD_DataS <= I_swap1;
						
						elsif(lcd_pos = 32) then -- When it hits the visible end of the second row
							LCD_DataS <= I_swap2;
							
						else 
							LCD_RS <= '1'; -- Sets LCD to recieve character
							LCD_DATA <= outputBuffer_r(lcd_pos); -- grabs the data from the decrypted message character from array
							lcd_pos := lcd_pos + 1; -- increment position counter
							LCD_DataS <= C_Get;
						end if;
						
					 when I_swap1 => -- Switches to the bottom row of the LCD
						LCD_RS <= '0';
						LCD_DATA <= x"C0";
						switched1 := '1';
						LCD_DataS <= C_Get;
						
					when I_swap2 => -- Switches to the top row of the LCD
						lcd_pos := 0; -- reset counter
						switched1 := '0';
						LCD_RS <= '0';
						LCD_DATA <= x"80";
						LCD_DataS <= C_Get;
						
				end case;
			end if;
		end process;
	 
end RTL;