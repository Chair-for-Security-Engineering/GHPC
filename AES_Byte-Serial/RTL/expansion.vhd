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

-- ENTITY
--------------------------------------------------------------------
ENTITY expansion IS
   GENERIC (ORDER : NATURAL  := 0);
	PORT ( clk  : IN  STD_LOGIC;
	       rst  : IN  STD_LOGIC;
	       en   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
	       rot  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
	       add  : IN  STD_LOGIC;
          rcon : IN  STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0);
          kin  : IN  STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0);
          kout : OUT STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0);
          sin  : OUT STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0);
          sout : IN  STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0));
END expansion;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF expansion IS

   SIGNAL state : STD_LOGIC_VECTOR((128 * (ORDER + 1) - 1) DOWNTO 0);
   SIGNAL mux, sbadd, rcadd, ksadd, fback : STD_LOGIC_VECTOR((  8 * (ORDER + 1) - 1) DOWNTO 0);
   
BEGIN

   -- input multiplexer
   MX : ENTITY work.multiplexer
   GENERIC MAP (
      SIZE  => 8,
      ORDER => ORDER
   ) PORT MAP (
      sel   => rst,
      din0  => state((16 * 8 * (ORDER + 1) - 1) DOWNTO (15 * 8 * (ORDER + 1))),
      din1  => kin,
      dout  => mux
   );
      
   -- substitution
   sin <= state(( 9 * 8 * (ORDER + 1) - 1) DOWNTO ( 8 * 8 * (ORDER + 1)));
            
   -- sbox addition
   SBX : ENTITY work.addition
   GENERIC MAP (
      SIZE  => 8,
      ORDER => ORDER
   ) PORT MAP (
      din0 => state((16 * 8 * (ORDER + 1) - 1) DOWNTO (15 * 8 * (ORDER + 1))),
      din1 => sout,
      dout => sbadd
   );
   
   -- rcon addition
   RCX : ENTITY work.addition
   GENERIC MAP (
      SIZE  => 8,
      ORDER => ORDER
   ) PORT MAP (
      din0 => sbadd,
      din1 => rcon,
      dout => rcadd
   );
   
   -- key state addition
   FBX : ENTITY work.addition
   GENERIC MAP (
      SIZE  => 8,
      ORDER => ORDER
   ) PORT MAP (
      din0 => state((15 * 8 * (ORDER + 1) - 1) DOWNTO (14 * 8 * (ORDER + 1))),
      din1 => state((16 * 8 * (ORDER + 1) - 1) DOWNTO (15 * 8 * (ORDER + 1))),
      dout => ksadd
   );
   
   -- feedback multiplexer
   FB : ENTITY work.multiplexer
   GENERIC MAP (
      SIZE  => 8,
      ORDER => ORDER
   ) PORT MAP (
      sel   => add,
      din0  => state((15 * 8 * (ORDER + 1) - 1) DOWNTO (14 * 8 * (ORDER + 1))),
      din1  => ksadd,
      dout  => fback
   );
                     
   -- state : line 0
   C00 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(3), sel => rot(3), din0 => fback(( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1))), din1 => state((12 * 8 * (ORDER + 1) - 1) DOWNTO (11 * 8 * (ORDER + 1))), dout => state((16 * 8 * (ORDER + 1) - 1) DOWNTO (15 * 8 * (ORDER + 1))));
   C01 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(2), sel => rot(2), din0 => state((14 * 8 * (ORDER + 1) - 1) DOWNTO (13 * 8 * (ORDER + 1))), din1 => state((11 * 8 * (ORDER + 1) - 1) DOWNTO (10 * 8 * (ORDER + 1))), dout => state((15 * 8 * (ORDER + 1) - 1) DOWNTO (14 * 8 * (ORDER + 1))));
   C02 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(1), sel => rot(1), din0 => state((13 * 8 * (ORDER + 1) - 1) DOWNTO (12 * 8 * (ORDER + 1))), din1 => state((10 * 8 * (ORDER + 1) - 1) DOWNTO ( 9 * 8 * (ORDER + 1))), dout => state((14 * 8 * (ORDER + 1) - 1) DOWNTO (13 * 8 * (ORDER + 1))));
   C03 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(0), sel => rot(0), din0 => state((12 * 8 * (ORDER + 1) - 1) DOWNTO (11 * 8 * (ORDER + 1))), din1 => state(( 9 * 8 * (ORDER + 1) - 1) DOWNTO ( 8 * 8 * (ORDER + 1))), dout => state((13 * 8 * (ORDER + 1) - 1) DOWNTO (12 * 8 * (ORDER + 1))));
   
   -- state : line 1
   C10 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(3), sel => rot(3), din0 => state((11 * 8 * (ORDER + 1) - 1) DOWNTO (10 * 8 * (ORDER + 1))), din1 => state(( 8 * 8 * (ORDER + 1) - 1) DOWNTO ( 7 * 8 * (ORDER + 1))), dout => state((12 * 8 * (ORDER + 1) - 1) DOWNTO (11 * 8 * (ORDER + 1))));
   C11 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(2), sel => rot(2), din0 => state((10 * 8 * (ORDER + 1) - 1) DOWNTO ( 9 * 8 * (ORDER + 1))), din1 => state(( 7 * 8 * (ORDER + 1) - 1) DOWNTO ( 6 * 8 * (ORDER + 1))), dout => state((11 * 8 * (ORDER + 1) - 1) DOWNTO (10 * 8 * (ORDER + 1))));
   C12 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(1), sel => rot(1), din0 => state(( 9 * 8 * (ORDER + 1) - 1) DOWNTO ( 8 * 8 * (ORDER + 1))), din1 => state(( 6 * 8 * (ORDER + 1) - 1) DOWNTO ( 5 * 8 * (ORDER + 1))), dout => state((10 * 8 * (ORDER + 1) - 1) DOWNTO ( 9 * 8 * (ORDER + 1))));
   C13 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(0), sel => rot(0), din0 => state(( 8 * 8 * (ORDER + 1) - 1) DOWNTO ( 7 * 8 * (ORDER + 1))), din1 => state(( 5 * 8 * (ORDER + 1) - 1) DOWNTO ( 4 * 8 * (ORDER + 1))), dout => state(( 9 * 8 * (ORDER + 1) - 1) DOWNTO ( 8 * 8 * (ORDER + 1))));
   
   -- state : line 2
   C20 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(3), sel => rot(3), din0 => state(( 7 * 8 * (ORDER + 1) - 1) DOWNTO ( 6 * 8 * (ORDER + 1))), din1 => state(( 4 * 8 * (ORDER + 1) - 1) DOWNTO ( 3 * 8 * (ORDER + 1))), dout => state(( 8 * 8 * (ORDER + 1) - 1) DOWNTO ( 7 * 8 * (ORDER + 1))));
   C21 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(2), sel => rot(2), din0 => state(( 6 * 8 * (ORDER + 1) - 1) DOWNTO ( 5 * 8 * (ORDER + 1))), din1 => state(( 3 * 8 * (ORDER + 1) - 1) DOWNTO ( 2 * 8 * (ORDER + 1))), dout => state(( 7 * 8 * (ORDER + 1) - 1) DOWNTO ( 6 * 8 * (ORDER + 1))));
   C22 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(1), sel => rot(1), din0 => state(( 5 * 8 * (ORDER + 1) - 1) DOWNTO ( 4 * 8 * (ORDER + 1))), din1 => state(( 2 * 8 * (ORDER + 1) - 1) DOWNTO ( 1 * 8 * (ORDER + 1))), dout => state(( 6 * 8 * (ORDER + 1) - 1) DOWNTO ( 5 * 8 * (ORDER + 1))));
   C23 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(0), sel => rot(0), din0 => state(( 4 * 8 * (ORDER + 1) - 1) DOWNTO ( 3 * 8 * (ORDER + 1))), din1 => state(( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1))), dout => state(( 5 * 8 * (ORDER + 1) - 1) DOWNTO ( 4 * 8 * (ORDER + 1))));
   
   -- state : line 3
   C30 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(3), sel => rot(3), din0 => state(( 3 * 8 * (ORDER + 1) - 1) DOWNTO ( 2 * 8 * (ORDER + 1))), din1 => rcadd(( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1))), dout => state(( 4 * 8 * (ORDER + 1) - 1) DOWNTO ( 3 * 8 * (ORDER + 1))));
   C31 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(2), sel => rot(2), din0 => state(( 2 * 8 * (ORDER + 1) - 1) DOWNTO ( 1 * 8 * (ORDER + 1))), din1 => state((15 * 8 * (ORDER + 1) - 1) DOWNTO (14 * 8 * (ORDER + 1))), dout => state(( 3 * 8 * (ORDER + 1) - 1) DOWNTO ( 2 * 8 * (ORDER + 1))));
   C32 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(1), sel => rot(1), din0 => state(( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1))), din1 => state((14 * 8 * (ORDER + 1) - 1) DOWNTO (13 * 8 * (ORDER + 1))), dout => state(( 2 * 8 * (ORDER + 1) - 1) DOWNTO ( 1 * 8 * (ORDER + 1))));
   C33 : ENTITY work.cell GENERIC MAP (8, ORDER) PORT MAP (clk => clk, en => en(0), sel => rot(0), din0 => mux  (( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1))), din1 => state((13 * 8 * (ORDER + 1) - 1) DOWNTO (12 * 8 * (ORDER + 1))), dout => state(( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1))));
   
   -- round key
   kout <= mux;
        
END Structural;