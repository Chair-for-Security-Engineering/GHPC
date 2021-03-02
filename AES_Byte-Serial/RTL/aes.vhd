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

-- IMPORTS
--------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

library work;
use work.PINI_pkg.all;

-- ENTITY
--------------------------------------------------------------------
ENTITY aes IS
	PORT ( clk  : IN  STD_LOGIC;
	       rst  : IN  STD_LOGIC;
	       done : OUT STD_LOGIC;
          key  : IN  STD_LOGIC_VECTOR ((8 * (ORDER + 1) - 1) DOWNTO 0);
			 fresh: in  STD_LOGIC_VECTOR (fresh_size-1          DOWNTO 0);
	       din	: IN  STD_LOGIC_VECTOR ((8 * (ORDER + 1) - 1) DOWNTO 0);
          dout	: OUT STD_LOGIC_VECTOR ((8 * (ORDER + 1) - 1) DOWNTO 0));
END aes;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF aes IS

   -- SIGNALS --------------------------------------------------------------------
   SIGNAL rkey, rcon                         : STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0);
   SIGNAL sin, sout, sin_rnd, sin_key        : STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0); 
        
   SIGNAL seld, den, sr, mc, exp, add, selk  : STD_LOGIC;   
   SIGNAL ken, rot                           : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

   -- s-box multiplexer
   MX : ENTITY work.multiplexer
   GENERIC MAP (
      SIZE  => 8,
      ORDER => ORDER
   ) PORT MAP (
      sel  => exp,
      din0 => sin_rnd,
      din1 => sin_key,
      dout => sin
   );

	SB: entity work.Sbox_PINI
   Port map (
		clk  		=> clk,
		input		=> sin,
      fresh		=> fresh,
		output	=> sout);
	
   -- round function
   RF : ENTITY work.round
   GENERIC MAP (
      ORDER => ORDER
   ) PORT MAP (
      clk   => clk,
      rst   => seld,
      en    => den,
      sr    => sr,
      mc    => mc,
      key   => rkey,
      din   => din,
      dout  => dout,
      sin   => sin_rnd,
      sout  => sout
   );
   
   -- key expansion
   KE : ENTITY work.expansion
   GENERIC MAP (
      ORDER   => ORDER
   ) PORT MAP (
      clk     => clk,
      rst     => selk,
      en      => ken,
      rot     => rot,
      add     => add,
      rcon    => rcon,
      kin     => key,
      kout    => rkey,
      sin     => sin_key,
      sout    => sout
   );
  
   -- control logic
   CL : ENTITY work.controller
   GENERIC MAP (
      ORDER   => ORDER,
      LATENCY => LATENCY
   ) PORT MAP (
      clk  => clk,
      rst  => rst,
      done => done,
      seld => seld,
      den  => den,
      sr   => sr,
      mc   => mc,
      selk => selk,
      ken  => ken,
      exp  => exp,
      rot  => rot,
      add  => add,
      rcon => rcon
   );
   
   END Structural;
