-----------------------------------------------------------------
-- COMPANY : Ruhr University Bochum
-- AUTHOR  : David Knichel david.knichel@rub.de, Pascal Sasdrich pascal.sasdrich@rub.de and Amir Moradi amir.moradi@rub.de 
-- DOCUMENT: [Generic Hardware Private Circuits - Towards Automated Generation of Composable Secure Gadgets] https://eprint.iacr.org/2021/247
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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

library work;
use work.PINI_pkg.all;

-- ENTITY
----------------------------------------------------------------------------------
ENTITY tb_aes IS
END tb_aes;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Simulation OF tb_aes IS
    
   -- CLOCK PERIOD DEFINITION ----------------------------------------------------
   CONSTANT PERIOD : TIME := 10 ns;
   
   -- FILE IO SIGNALS ------------------------------------------------------------
   FILE TESTVECTORS : TEXT;
   
   -- INPUTS ---------------------------------------------------------------------
   SIGNAL clk 	: STD_LOGIC := '0';
   SIGNAL rst	: STD_LOGIC := '0';
   SIGNAL fresh: STD_LOGIC_VECTOR (fresh_size-1          DOWNTO 0) := (OTHERS => '0');
   SIGNAL key  : STD_LOGIC_VECTOR ((8 * (ORDER + 1) - 1) DOWNTO 0) := (OTHERS => '0');
   SIGNAL din  : STD_LOGIC_VECTOR ((8 * (ORDER + 1) - 1) DOWNTO 0) := (OTHERS => '0');

 	-- OUTPUTS --------------------------------------------------------------------
   SIGNAL done : STD_LOGIC;
   SIGNAL dout : STD_LOGIC_VECTOR ((8 * (ORDER + 1) - 1) DOWNTO 0);

	SIGNAL XOR_dout : STD_LOGIC_VECTOR(8 * (ORDER + 1) - 1 DOWNTO 0);
   
BEGIN

	-- UNIT UNDER TEST
   UUT : ENTITY work.aes
   PORT MAP (
	  clk   => clk,
	  rst   => rst,
	  done  => done,
	  key   => key,
	  fresh => fresh,
	  din   => din,
	  dout  => dout);

	XOR_dout(8*1-1 downto 0) <= dout(8*1-1 downto 0);

	GEN: FOR i in 1 TO ORDER GENERATE
		XOR_dout(8*(i+1)-1 downto 8*i)<= XOR_dout(8*i-1 downto 8*(i-1)) XOR dout(8*(i+1)-1 downto 8*i);
	END GENERATE;
	
   -- CLOCK PROCESS
   CLOCK : PROCESS
   BEGIN
      clk <= '0'; WAIT FOR PERIOD/2;
      clk <= '1'; WAIT FOR PERIOD/2;
   END PROCESS;
   
   -- STIMULUS PROCESS
   STIMULUS : PROCESS
      VARIABLE WRONG 			: INTEGER;
      VARIABLE TV_LINE        : LINE;
      VARIABLE SUCCESS        : BOOLEAN;      
      
      VARIABLE CURRENT         : STD_LOGIC_VECTOR(127 DOWNTO 0);
      
      VARIABLE TV_KEY   : STD_LOGIC_VECTOR(128*(ORDER + 1) - 1 DOWNTO 0) := (others => '0');
      VARIABLE TV_DIN	: STD_LOGIC_VECTOR(128*(ORDER + 1) - 1 DOWNTO 0) := (others => '0');

      VARIABLE TV_DOUT	: STD_LOGIC_VECTOR(128 - 1 DOWNTO 0) := (others => '0');
		
   BEGIN
      -- open testvectors for reading
      FILE_OPEN(TESTVECTORS, "../TestBench/tv.txt", READ_MODE);
   
      WHILE NOT ENDFILE(TESTVECTORS) LOOP
      
         -- read next line from test vector file
         READLINE(TESTVECTORS, TV_LINE);
         
         -- skip empty lines or single-line comments
         IF TV_LINE.ALL'LENGTH = 0 or TV_LINE.ALL(1) = '#' THEN NEXT; END IF;              
              
         -- read input
         HREAD(TV_LINE, CURRENT, SUCCESS);
         ASSERT SUCCESS
         REPORT "Could not read 'share in' for line: " & TV_LINE.ALL
         SEVERITY FAILURE;
         TV_DIN(128 - 1 DOWNTO 0) := CURRENT;
            
         -- read key
         HREAD(TV_LINE, CURRENT, SUCCESS);
         ASSERT SUCCESS
         REPORT "Could not read 'key' for line: " & TV_LINE.ALL
         SEVERITY FAILURE;         
         TV_KEY(128 - 1 DOWNTO 0) := CURRENT;
         
         -- read output
			HREAD(TV_LINE, CURRENT, SUCCESS);
			ASSERT SUCCESS
			REPORT "Could not read 'share out' for line: " & TV_LINE.ALL
			SEVERITY FAILURE;            
			TV_DOUT(128 - 1 DOWNTO 0) := CURRENT;
            
         -- start computation
         rst <= '1';
         WAIT FOR 10 * PERIOD;
         FOR C IN 0 TO 3 LOOP   
            FOR R IN 0 TO 3 LOOP
               WAIT FOR PERIOD;
               FOR I IN 0 TO ORDER LOOP
                  din((8 * (I + 1) - 1) DOWNTO (8 * I)) <= TV_DIN((128 * (I + 1) - 32 * R - 8 * C - 1) DOWNTO (128 * (I + 1) - 32 * R - 8 * (C + 1)));
                  key((8 * (I + 1) - 1) DOWNTO (8 * I)) <= TV_KEY((128 * (I + 1) - 32 * R - 8 * C - 1) DOWNTO (128 * (I + 1) - 32 * R - 8 * (C + 1)));
               END LOOP;
            END LOOP;
         END LOOP;
         rst <= '0';
         
         -- computation
         WAIT UNTIL DONE = '1'; WAIT FOR PERIOD / 2;
         
			WRONG := 0;
			
         -- check results
         FOR C IN 0 TO 3 LOOP   
            FOR R IN 0 TO 3 LOOP
					IF (XOR_dout((8 * (ORDER + 1) - 1) DOWNTO (8 * ORDER)) /= TV_DOUT((128 - 32 * R - 8 * C - 1) DOWNTO (128 - 32 * R - 8 * (C + 1)))) THEN
						WRONG := 1;
					END IF;

               WAIT FOR PERIOD;
            END LOOP;
         END LOOP;             
						
			IF (WRONG = 0) THEN
				ASSERT FALSE
				REPORT "Pass!"
				SEVERITY note;
			ELSE 
				ASSERT FALSE
				REPORT "Fail!"
				SEVERITY error;
		  END IF;
						
        WAIT FOR 10*PERIOD;
						
      END LOOP;

     WAIT;
  END PROCESS;

END;
