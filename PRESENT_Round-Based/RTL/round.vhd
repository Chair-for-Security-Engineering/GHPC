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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

library work;
use work.PINI_pkg.all;

-- ENTITY
--------------------------------------------------------------------
ENTITY round IS
	PORT ( clk  : IN  STD_LOGIC;
	       rst  : IN  STD_LOGIC;
	       key  : IN  STD_LOGIC_VECTOR((64 * (ORDER + 1) - 1) DOWNTO 0);
	       din  : IN  STD_LOGIC_VECTOR((64 * (ORDER + 1) - 1) DOWNTO 0);
          fresh: IN  STD_LOGIC_VECTOR((fresh_size * 16 - 1)  DOWNTO 0);
          dout : OUT STD_LOGIC_VECTOR((64 * (ORDER + 1) - 1) DOWNTO 0));
END round;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF round IS

   -- SIGNALS --------------------------------------------------------------------
   SIGNAL mux, add, sin, sout, sub, perm : STD_LOGIC_VECTOR((64 * (ORDER + 1) - 1) DOWNTO 0);
   
BEGIN

   -- input multiplexer
   MX : ENTITY work.multiplexer
   GENERIC MAP (
      SIZE  => 64,
      ORDER => ORDER
   ) PORT MAP (
      sel   => rst,
      din0  => perm,
      din1  => din,
      dout  => mux
   );
   
   -- key addition
   KA : ENTITY work.addition
   GENERIC MAP (
      SIZE  => 64,
      ORDER => ORDER
   ) PORT MAP (
      din0  => key,
      din1  => mux,
      dout  => add
   );
   
   -- substitution
   S : FOR I IN 0 TO 15 GENERATE
      -- signal reordering
      GEN : FOR J IN 0 TO ORDER GENERATE
         sin((4 * (ORDER + 1) * I + 4 * (J + 1) - 1) DOWNTO (4 * (ORDER + 1) * I + 4 * J)) <= add((64 * J + 4 * (I + 1) - 1) DOWNTO (64 * J + 4 * I));
         sub((64 * J + 4 * (I + 1) - 1) DOWNTO (64 * J + 4 * I)) <= sout((4 * (ORDER + 1) * I + 4 * (J + 1) - 1) DOWNTO (4 * (ORDER + 1) * I + 4 * J));
      END GENERATE;
		  
      -- (protected) sbox
      SBOX : ENTITY work.Sbox_PINI
      PORT MAP (
         clk  		=> clk,
         input  	=> sin  ((4 * (ORDER + 1) * (I + 1) - 1) DOWNTO (4 * (ORDER + 1) * I)),
         fresh    => fresh((fresh_size * (I + 1) - 1)      DOWNTO (fresh_size * I)),
         output 	=> sout ((4 * (ORDER + 1) * (I + 1) - 1) DOWNTO (4 * (ORDER + 1) * I))
      );         
   END GENERATE;
   
   -- permutation
   P : ENTITY work.permutation
   GENERIC MAP (
      ORDER => ORDER
   ) PORT MAP (
      din  => sub,
      dout => perm
   );
   
   -- final result
   dout <= add;


END Dataflow;
