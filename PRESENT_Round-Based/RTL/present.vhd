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

library work;
use work.PINI_pkg.all;

-- ENTITY
--------------------------------------------------------------------
ENTITY present IS
	PORT ( 
          clk   : IN  STD_LOGIC;
	  rst   : IN  STD_LOGIC;
	  done  : OUT STD_LOGIC;
          key   : IN  STD_LOGIC_VECTOR ((128 * (ORDER + 1) - 1) DOWNTO 0);
          fresh : IN  STD_LOGIC_VECTOR ((fresh_size * 18 - 1)   DOWNTO 0);
	  din	: IN  STD_LOGIC_VECTOR (( 64 * (ORDER + 1) - 1) DOWNTO 0);
          dout	: OUT STD_LOGIC_VECTOR (( 64 * (ORDER + 1) - 1) DOWNTO 0));
END present;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF present IS

   SIGNAL roundkey : STD_LOGIC_VECTOR((64 * (ORDER + 1) - 1) DOWNTO 0);
   SIGNAL rcon     : STD_LOGIC_VECTOR(( 5 * (ORDER + 1) - 1) DOWNTO 0);
   SIGNAL ken, seld, selk : STD_LOGIC;

BEGIN

   -- round function
   RF : ENTITY work.round 
   PORT MAP (
      clk  => clk,
      rst  => seld,
      key  => roundkey,
      din  => din,
      fresh=> fresh((fresh_size * 16 - 1) DOWNTO 0),
      dout => dout
   );

   -- key expansion
   KE : ENTITY work.expansion
   PORT MAP (
      clk  => clk,
      rst  => selk,
      en   => ken,
      fresh=> fresh((fresh_size * 18 - 1) DOWNTO (fresh_size * 16)),
      rcon => rcon,
      kin  => key,
      kout => roundkey
   );
   
   CL : ENTITY work.controller
   PORT MAP (
      clk  => clk,
      rst  => rst,
      seld => seld,
      selk => selk,
      done => done,
      ken  => ken,
      rcon => rcon
   );
   
END Structural;
