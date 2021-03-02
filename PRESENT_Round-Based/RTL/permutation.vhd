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

-- ENTITY
--------------------------------------------------------------------
ENTITY permutation IS
   GENERIC (ORDER : NATURAL := 1);
	PORT ( din  : IN  STD_LOGIC_VECTOR ((64 * (ORDER + 1) - 1) DOWNTO 0);
          dout : OUT STD_LOGIC_VECTOR ((64 * (ORDER + 1) - 1) DOWNTO 0));
END permutation;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF permutation IS

BEGIN

   GEN : FOR I IN 0 TO ORDER GENERATE
      dout(64 * I +  0) <= din(64 * I +  0);
      dout(64 * I +  1) <= din(64 * I +  4);
      dout(64 * I +  2) <= din(64 * I +  8);
      dout(64 * I +  3) <= din(64 * I + 12);
      dout(64 * I +  4) <= din(64 * I + 16);
      dout(64 * I +  5) <= din(64 * I + 20);
      dout(64 * I +  6) <= din(64 * I + 24);
      dout(64 * I +  7) <= din(64 * I + 28);
      dout(64 * I +  8) <= din(64 * I + 32);
      dout(64 * I +  9) <= din(64 * I + 36);
      dout(64 * I + 10) <= din(64 * I + 40);
      dout(64 * I + 11) <= din(64 * I + 44);
      dout(64 * I + 12) <= din(64 * I + 48);
      dout(64 * I + 13) <= din(64 * I + 52);
      dout(64 * I + 14) <= din(64 * I + 56);
      dout(64 * I + 15) <= din(64 * I + 60);
      dout(64 * I + 16) <= din(64 * I +  1);
      dout(64 * I + 17) <= din(64 * I +  5);
      dout(64 * I + 18) <= din(64 * I +  9);
      dout(64 * I + 19) <= din(64 * I + 13);
      dout(64 * I + 20) <= din(64 * I + 17);
      dout(64 * I + 21) <= din(64 * I + 21);
      dout(64 * I + 22) <= din(64 * I + 25);
      dout(64 * I + 23) <= din(64 * I + 29);
      dout(64 * I + 24) <= din(64 * I + 33);
      dout(64 * I + 25) <= din(64 * I + 37);
      dout(64 * I + 26) <= din(64 * I + 41);
      dout(64 * I + 27) <= din(64 * I + 45);
      dout(64 * I + 28) <= din(64 * I + 49);
      dout(64 * I + 29) <= din(64 * I + 53);
      dout(64 * I + 30) <= din(64 * I + 57);
      dout(64 * I + 31) <= din(64 * I + 61);
      dout(64 * I + 32) <= din(64 * I +  2);
      dout(64 * I + 33) <= din(64 * I +  6);
      dout(64 * I + 34) <= din(64 * I + 10);
      dout(64 * I + 35) <= din(64 * I + 14);
      dout(64 * I + 36) <= din(64 * I + 18);
      dout(64 * I + 37) <= din(64 * I + 22);
      dout(64 * I + 38) <= din(64 * I + 26);
      dout(64 * I + 39) <= din(64 * I + 30);
      dout(64 * I + 40) <= din(64 * I + 34);
      dout(64 * I + 41) <= din(64 * I + 38);
      dout(64 * I + 42) <= din(64 * I + 42);
      dout(64 * I + 43) <= din(64 * I + 46);
      dout(64 * I + 44) <= din(64 * I + 50);
      dout(64 * I + 45) <= din(64 * I + 54);
      dout(64 * I + 46) <= din(64 * I + 58);
      dout(64 * I + 47) <= din(64 * I + 62);
      dout(64 * I + 48) <= din(64 * I +  3);
      dout(64 * I + 49) <= din(64 * I +  7);
      dout(64 * I + 50) <= din(64 * I + 11);
      dout(64 * I + 51) <= din(64 * I + 15);
      dout(64 * I + 52) <= din(64 * I + 19);
      dout(64 * I + 53) <= din(64 * I + 23);
      dout(64 * I + 54) <= din(64 * I + 27);
      dout(64 * I + 55) <= din(64 * I + 31);
      dout(64 * I + 56) <= din(64 * I + 35);
      dout(64 * I + 57) <= din(64 * I + 39);
      dout(64 * I + 58) <= din(64 * I + 43);
      dout(64 * I + 59) <= din(64 * I + 47);
      dout(64 * I + 60) <= din(64 * I + 51);
      dout(64 * I + 61) <= din(64 * I + 55);
      dout(64 * I + 62) <= din(64 * I + 59);
      dout(64 * I + 63) <= din(64 * I + 63);
   END GENERATE;
   
END Dataflow;

