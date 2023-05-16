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
entity ksa_Quarter1 is
  port(clk : in  std_logic;  -- Clock pin
		 finished : out std_logic; -- Finish flag 
		 error: out std_logic; -- Error flag
		 key : out std_logic_vector(23 downto 0); -- Secret key output
		 outarray : out outputBuffer); -- Array output
end ksa_Quarter1;

-- Architecture part of the description

architecture rtl of ksa_Quarter1 is

   -- Declare the component for the ram.  This should match the entity description 
	-- in the entity created by the megawizard. If you followed the instructions in the 
	-- handout exactly, it should match.  If not, look at s_memory.vhd and make the
	-- changes to the component below
	
	-- Calling s_memory component
   COMPONENT s_memory IS
	   PORT (
		   address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   clock		: IN STD_LOGIC  := '1';
		   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   wren		: IN STD_LOGIC ;
		   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END component;
	
	-- Calling d_memory component
	COMPONENT d_memory IS
	PORT (
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
	END component;
	
	-- Calling message component
	COMPONENT message IS
	PORT (
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
	END component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	type state_type is (state_init, 
                       state_fill, -- States that fill memory in the order of the secret key
								Read_MemS_i_Delay,
								Read_MemS_i,
								Read_MemS_j_Delay,
								Read_Write_MemS_j,
								Write_MemS_j_Delay,
								Write_MemS_i,
								Write_MemS_i_Delay,
								state_decryption, -- States that decrypt the message
								Read_MemS_i_Delay2,
								Read_MemS_i2,
								Read_MemS_j_Delay2,
								Read_Write_MemS_j2,
								Write_MemS_j_Delay2,
								Write_MemS_i2,
								Write_MemS_i_Delay2,
								Read_MemS_Rom,
								Read_MemS_Rom_Delay,
								Validate_Write_MemD,
								Write_MemD_Delay,
   	 					  state_done);
	signal Current_state : state_type := state_init;
								
    -- These are signals that are used to connect to the memory													 
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren : STD_LOGIC;
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);

	 -- These are signals that are used to connect to the decryped memory
	 signal address_d : STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal data_d : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren_d : STD_LOGIC;
	 signal q_d : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 -- These are signals that are used to connect to the ROM
	 signal address_m : STD_LOGIC_VECTOR (4 DOWNTO 0);
	 signal q_m : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 -- Array signal that will output what was stored in the decryption memory
	 signal outputBuffer_r : outputBuffer;
	 
	 begin
	    -- Port mapping RAM and ROM components
	    u0: message port map (address_m, clk, q_m);
	
       u1: s_memory port map (address, clk, data, wren, q);

		 u2: d_memory port map (address_d, clk, data_d, wren_d, q_d);
		
		-- Decryption process
		process(clk)
			variable i, j, k, temp_s_f, temp_s_i, temp_s_j : integer range 0 to 256 := 0;
			variable secret_byte_selector : integer range 0 to 2 := 0;
			variable secret_byte : std_logic_vector (7 downto 0);
			variable secret_key : std_logic_vector (23 downto 0) := (others => '0');
		begin
		
		if(rising_edge(clk)) then
			case Current_state is 
				when state_init => -- Initializes the working memory
					if(i > 255) then -- Check if we have completed initializing all of the memory 
						wren <= '0'; -- Enable reading to memoryS
						i := 0;
						address <= std_logic_vector(to_unsigned(i, address'length));
						Current_state <= state_fill;
					else
						wren <= '1'; -- Enable writing to memory
						address <= std_logic_vector(to_unsigned(i, address'length)); -- Selecting the memory address to write to
						data <= std_logic_vector(to_unsigned(i, data'length)); -- inputting the data associated to that memory address
					
						i := i + 1; -- Iterate to the next point in memoryS
					end if;
					
					
				when state_fill => -- Starts the process of arranging the memory around based on the secret key
					if(i > 255) then -- When all addresses have been arranded it modes on to decryption
						i := 0;
						j := 0;
						temp_s_i := 0;
						temp_s_j := 0;
						Current_state <= state_decryption;
					else -- Selects the set of bytes from the secret key and calls to read memory at s[i]
						secret_byte_selector := i mod 3;
						if secret_byte_selector = 0 then
							secret_byte := secret_key(23 downto 16);
						elsif secret_byte_selector = 1 then
							secret_byte := secret_key(15 downto 8);
						elsif secret_byte_selector = 2 then
							secret_byte := secret_key(7 downto 0);
						end if;
						address <= std_logic_vector(to_unsigned(i, address'length));
						wren <= '0'; -- Enable reading to memoryS
						Current_state <= Read_MemS_i_Delay;
					end if;
				
				when Read_MemS_i_Delay =>
						Current_state <= Read_MemS_i;
				
				when Read_MemS_i => -- Reads the memory at s[i], calculates j and calls to read memory from s[j]
						temp_s_i := to_integer(unsigned(q));
						j := (j + temp_s_i + to_integer(unsigned(secret_byte))) mod 256;
						address <= std_logic_vector(to_unsigned(j, address'length));
						wren <= '0'; -- Enable reading to memoryS
						Current_state <= Read_MemS_j_Delay;
						
				when Read_MemS_j_Delay =>
						Current_state <= Read_Write_MemS_j;
						
				when Read_Write_MemS_j => -- Reads the memory at s[j] and calls to write the value stored in s[i] to s[j]
						temp_s_j := to_integer(unsigned(q));
						data <= std_logic_vector(to_unsigned(temp_s_i, data'length));
						wren <= '1'; -- Enable writing to memoryS
						Current_state <= Write_MemS_j_Delay;
				
				when Write_MemS_j_Delay =>
						Current_state <= Write_MemS_i;
						
				when Write_MemS_i => -- Writes the memory at s[j] and calls to write the value stored in s[j] to s[i]
						address <= std_logic_vector(to_unsigned(i, address'length));
						data <= std_logic_vector(to_unsigned(temp_s_j, data'length));
						wren <= '1'; -- Enable writing to memoryS
						i := i + 1; -- Iterate to the next point in memoryS
						Current_state <= Write_MemS_i_Delay;
				
				when Write_MemS_i_Delay => -- Writes the memory at s[i]
						Current_state <= state_fill;
				
				
				
				when state_decryption => -- Starts the process of decrypting the input message
						wren_d <= '0'; -- Enable reading to memoryD
						if (k > 31) then -- If the counter has 32 valid inputs in the decryption memory 
							finished <= '1'; -- Set active the finished flag
							key <= secret_key; -- Output the secret key found
							outarray <= outputBuffer_r; -- Output the array storing the message
							Current_state <= state_done;
						else
							finished <= '0'; -- Set inactive the finished flag
							i := (i+1) mod 256;
							address <= std_logic_vector(to_unsigned(i, address'length));
							wren <= '0'; -- Enable reading to memoryS
							Current_state <= Read_MemS_i_Delay2;
						end if;
						
				when Read_MemS_i_Delay2 =>
						Current_state <= Read_MemS_i2;
				
				when Read_MemS_i2 => -- Reads the memory at s[i], calculates j and calls to read memory from s[j]
						temp_s_i := to_integer(unsigned(q));
						j := (j + temp_s_i) mod 256;
						address <= std_logic_vector(to_unsigned(j, address'length));
						wren <= '0'; -- Enable reading to memoryS
						Current_state <= Read_MemS_j_Delay2;
						
				when Read_MemS_j_Delay2 =>
						Current_state <= Read_Write_MemS_j2;
						
				when Read_Write_MemS_j2 => -- Reads the memory at s[j] and calls to write the value stored in s[i] to s[j]
						temp_s_j := to_integer(unsigned(q));
						data <= std_logic_vector(to_unsigned(temp_s_i, data'length));
						wren <= '1'; -- Enable writing to memoryS
						Current_state <= Write_MemS_j_Delay2;
				
				when Write_MemS_j_Delay2 =>
						Current_state <= Write_MemS_i2;
						
				when Write_MemS_i2 => -- Writes the memory at s[j] and calls to write the value stored in s[j] to s[i]
						address <= std_logic_vector(to_unsigned(i, address'length));
						data <= std_logic_vector(to_unsigned(temp_s_j, data'length));
						wren <= '1'; -- Enable writing to memoryS
						Current_state <= Write_MemS_i_Delay2;
						
				when Write_MemS_i_Delay2 =>
						Current_state <= Read_MemS_Rom;
						
				when Read_MemS_Rom => -- calls to read the value stored in s[temp_s_f] and message[k]
						temp_s_f := (temp_s_i + temp_s_j) mod 256;
						address <= std_logic_vector(to_unsigned(temp_s_f, address'length));
						wren <= '0'; -- Enable reading to memoryS
						address_m <= std_logic_vector(to_unsigned(k, address_m'length));
						Current_state <= Read_MemS_Rom_Delay;
				
				when Read_MemS_Rom_Delay =>
						Current_state <= Validate_Write_MemD;
				
				when Validate_Write_MemD =>
						--S[i]+s[f] mod 256 is read here
						address_d <= std_logic_vector(to_unsigned(k, address_d'length));
						data_d <= q xor q_m;
						wren_d <= '1'; -- Enable writing to memoryD
						-- If the message data address value decrypted is of a valid range of lowercase letters or of a space 
						if ((((unsigned(q xor q_m) >= 97) AND (unsigned(q xor q_m)) <= 122)) OR (unsigned(q xor q_m) = 32)) then
							wren_d <= '1';-- Enable writing to memoryD
							outputBuffer_r(k) <= (q xor q_m); -- Adds the value to the assocated position in the array
							k := k + 1; -- Iterates to the next address in the message signal for decryptions
							Current_state <= Write_MemD_Delay; -- returns to decrypt the data address in the message
						else -- If not within the valid decrypted value range
							if to_integer(unsigned(secret_key)) = 4194303 then -- When the max possible keys have been reached
								error <= '1'; -- Set activate error flag
								Current_state <= state_done;
							else
								error <= '0';
								secret_key := std_logic_vector(unsigned(secret_key) + 1); -- Increment to the next even valued key
								-- Reset counters
								i := 0;
								k := 0;
								j := 0;
								Current_state <= state_init;
							end if;
						end if;
							
				when Write_MemD_Delay =>
						Current_state <= state_decryption;
				
				when state_done =>
				
			end case;
		end if;
			
		end process; 

end RTL;