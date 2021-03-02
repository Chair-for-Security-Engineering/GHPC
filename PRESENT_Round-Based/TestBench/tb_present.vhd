-----------------------------------------------------------------
-- COMPANY : Ruhr University Bochum
-- AUTHOR  : David Knichel david.knichel@rub.de, Pascal Sasdrich pascal.sasdrich@rub.de and Amir Moradi amir.moradi@rub.de 
-- DOCUMENT: [Generic Hardware Private Circuits - Towards Automated Generation of Composable Secure Gadgets] https://eprint.iacr.org/2021/
-- -----------------------------------------------------------------
--
-- Copyright c 2021, David Knichel, Pascal Sasdrich, Amir Moradi, 
--
-- All rights reserved.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTERS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- INCLUDING NEGLIGENCE OR OTHERWISE ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- Please see LICENSE and README for license and further instructions.
--


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

USE ieee.std_logic_textio.all;
LIBRARY STD;
USE STD.TEXTIO.ALL;

library work;
use work.PINI_pkg.all;
 
ENTITY tb_present IS
END tb_present;
 
ARCHITECTURE bench OF tb_present IS 
 
   signal clk 			: std_logic := '0';
   signal rst 		   : std_logic := '0';
   signal plaintext  : std_logic_vector( 63 downto 0) := (others => '0');
   signal key 			: std_logic_vector(127 downto 0) := (others => '0');
   signal ciphertext : std_logic_vector( 63 downto 0);
    
	signal data_in  : std_logic_vector( 64*(ORDER+1)-1    downto 0);
	signal key_in   : std_logic_vector(128*(ORDER+1)-1    downto 0);
	signal data_out : std_logic_vector( 64*(ORDER+1)-1    downto 0);
	signal fresh	 : std_logic_vector(fresh_size*18-1 downto 0);
   signal done 	 : std_logic;

	signal XOR_data_out : std_logic_vector(64*(ORDER+1)-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	fresh <= (others => '0');
 
	data_in( 64*1-1 downto 0) 		<= plaintext;
	key_in (128*1-1 downto 0) 		<= key;
	XOR_data_out(64*1-1 downto 0) <= data_out(64*1-1 downto 0);

	GEN: FOR i in 1 TO ORDER GENERATE
		data_in( 64*(i+1)-1 downto  64*i) 		<= (others => '0');
		key_in (128*(i+1)-1 downto 128*1) 		<= (others => '0');
		XOR_data_out(64*(i+1)-1 downto 64*i)<= XOR_data_out(64*i-1 downto 64*(i-1)) XOR data_out(64*(i+1)-1 downto 64*i);
	END GENERATE;
	
	ciphertext <= XOR_data_out(64*(ORDER+1)-1 downto 64*ORDER);
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.PRESENT
	PORT MAP (
          clk => clk,
          rst => rst,
			 fresh => fresh,
          din => data_in,
          key => key_in,
          dout => data_out,
          done => done
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	-- mixed (event-driven/cycle-based) result check
	check_results : process
	
		variable lineIn			: line;
		variable good_number		: boolean;
		variable space				: character;
		variable tv_key			: std_logic_vector(127 downto 0);
		variable tv_plaintext	: std_logic_vector( 63 downto 0);
		variable tv_ciphertext	: std_logic_vector( 63 downto 0);
		variable out_temp			: std_logic_vector( 63 downto 0);
		
		file vector_file: text open read_mode is "../TestBench/tv.txt";
		
		procedure assertMatch(testResult, correctResult : in std_logic_vector) is
			variable msg : line;
		begin

			if (testResult'length mod 8 = 0) then
				hwrite(msg, testResult);
				write (msg, string'(" should be "));
				hwrite(msg, correctResult);
			else
				write(msg, testResult);
				write(msg, string'(" should be "));
				write(msg, correctResult);
			end if;
			
			-- by assert, the message is displayed when the condition is NOT met

			assert (testResult  = correctResult) report msg.all severity error;
         		assert (testResult /= correctResult) report "CORRECT RESULT!" severity note;

		end procedure assertMatch;
		
		procedure testCipher (tv_plain, tv_key, tv_out : std_logic_vector) is
		begin
			-- set reset and start cipher
			rst <= '1';
			
			plaintext <= tv_plain;
			key  		 <= tv_key;
				
			wait for clk_period*1;		
			rst <= '0';
			
			-- wait for cipher to finish
			wait until done = '1';
			wait for clk_period*0.5;
			
			out_temp := ciphertext;
			wait for clk_period*0.5;
			
			-- test result
			assertMatch(out_temp,tv_out);
			-- wait one cycle before next (possible) reset
			wait for 10*clk_period;
		end procedure testCipher;

	begin
		-- system init
		wait for 1.0 * clk_period;
		
		report "---------- Test using testvector file ----------";
	
		read_loop: while not endfile(vector_file) loop
			readline(vector_file, lineIn);
			next when (lineIn(lineIn'left) = '-'); -- comment line
			
			-- read plaintext
			hread(lineIn, tv_plaintext, good => good_number);
			assert (good_number) report "Incorrect test vector format (plaintext)" severity error;
			-- read space character
			read(lineIn, space);
			
			-- read key
			hread(lineIn, tv_key, good => good_number);
			assert (good_number) report "Incorrect test vector format (key)" severity error;
			-- read space character
			read(lineIn, space);

			-- read ciphertext
			hread(lineIn, tv_ciphertext, good => good_number);
			assert (good_number) report "Incorrect test vector format (ciphertext)" severity error;
			-- read space character
			
			testCipher(tv_plaintext, tv_key, tv_ciphertext);

		end loop read_loop;
		report "---------- End of testvector file ----------";
		wait;
	end process check_results;	
END;