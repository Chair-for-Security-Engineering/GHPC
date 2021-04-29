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

-- IMPORTS
--------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.LOG2;
USE IEEE.MATH_REAL.CEIL;

library work;
use work.PINI_pkg.all;

-- ENTITY
--------------------------------------------------------------------
ENTITY expansion IS
	PORT ( clk  : IN  STD_LOGIC;
	       rst  : IN  STD_LOGIC;
	       en   : IN  STD_LOGIC;
          fresh: IN  STD_LOGIC_VECTOR ((fresh_size * 2 - 1)    DOWNTO 0);
	       rcon : IN  STD_LOGIC_VECTOR ((  5 * (ORDER + 1) - 1) DOWNTO 0);
	       kin	: IN  STD_LOGIC_VECTOR ((128 * (ORDER + 1) - 1) DOWNTO 0);
          kout	: OUT STD_LOGIC_VECTOR (( 64 * (ORDER + 1) - 1) DOWNTO 0));
END expansion;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF expansion IS

   -- SIGNALS --------------------------------------------------------------------
   SIGNAL mux, rot, add : STD_LOGIC_VECTOR((128 * (ORDER + 1) - 1) DOWNTO 0);
   SIGNAL reg           : STD_LOGIC_VECTOR((120 * (ORDER + 1) - 1) DOWNTO 0);
   SIGNAL sin1, sin2, sout1, sout2 : STD_LOGIC_VECTOR((  4 * (ORDER + 1) - 1) DOWNTO 0);         
   
BEGIN

   -- input multiplexer
   MX : ENTITY work.multiplexer
   GENERIC MAP (
      SIZE  => 128,
      ORDER => ORDER
   ) PORT MAP (
      sel   => rst,
      din0  => add,
      din1  => kin,
      dout  => mux
   );
   
   -- rotation
   RT : ENTITY work.rotation
   GENERIC MAP (
     ORDER => ORDER
   ) PORT MAP (
      din  => mux,
      dout => rot
   );
   
   -- substitution
   SIN : FOR I IN 0 TO ORDER GENERATE
      sin1((4 * I + 3) DOWNTO (4 * I)) <= rot((128 * I + 127) DOWNTO (128 * I + 124));
      sin2((4 * I + 3) DOWNTO (4 * I)) <= rot((128 * I + 123) DOWNTO (128 * I + 120));
   END GENERATE;
   
   SB1 : ENTITY work.Sbox_PINI
   PORT MAP (
      clk  		=> clk,
      input		=> sin1,
      fresh 	=> fresh(fresh_size-1 DOWNTO 0),
      output	=> sout1); 

   SB2 : ENTITY work.Sbox_PINI
   PORT MAP (
      clk  		=> clk,
      input  	=> sin2,
      fresh  	=> fresh(fresh_size*2-1 DOWNTO fresh_size*1),
      output 	=> sout2); 
   
   -- register stage
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         IF (en = '1') THEN
            FOR I IN 0 TO ORDER LOOP
               reg((120 * I + 119) DOWNTO (120 * I + 0)) <= rot((128 * I + 119) DOWNTO (128 * I + 0));
            END LOOP;
         END IF;
      END IF;
   END PROCESS;   
      
   -- addition
   RCADD : FOR I IN 0 TO ORDER GENERATE
      add((128 * I + 127) DOWNTO (128 * I + 124)) <= sout1((4 * I + 3) DOWNTO (4 * I));
      add((128 * I + 123) DOWNTO (128 * I + 120)) <= sout2((4 * I + 3) DOWNTO (4 * I));
      add((128 * I + 119) DOWNTO (128 * I +  67)) <= reg((120 * I + 119) DOWNTO (120 * I + 67));
      add((128 * I +  66) DOWNTO (128 * I +  62)) <= reg((120 * I +  66) DOWNTO (120 * I + 62)) XOR rcon((5 * I + 4) DOWNTO (5 * I + 0));
      add((128 * I +  61) DOWNTO (128 * I +   0)) <= reg((120 * I +  61) DOWNTO (120 * I +  0));
   END GENERATE;   
      
   -- final result
   RKEY : FOR I IN 0 TO ORDER GENERATE
      kout((64 * I + 63) DOWNTO (64 * I + 0)) <= mux((128 * I + 127) DOWNTO (128 * I + 64));   
   END GENERATE;
      
END Structural;