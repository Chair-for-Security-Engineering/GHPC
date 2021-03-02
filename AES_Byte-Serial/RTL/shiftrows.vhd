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
ENTITY shiftrows IS
    GENERIC (ORDER : NATURAL := 0);
    PORT ( din  : IN  STD_LOGIC_VECTOR ((ORDER * 128) + 127 DOWNTO 0);
           dout : OUT STD_LOGIC_VECTOR ((ORDER * 128) + 127 DOWNTO 0));
END shiftrows;

-- ARCHITECTURE
--------------------------------------------------------------------
ARCHITECTURE DataFlow OF shiftrows IS

BEGIN
   
   -- RESULT -------------------------------------------------------
   dout((16 * 8 * (ORDER + 1) - 1) DOWNTO (15 * 8 * (ORDER + 1))) <= din((16 * 8 * (ORDER + 1) - 1) DOWNTO (15 * 8 * (ORDER + 1)));
   dout((15 * 8 * (ORDER + 1) - 1) DOWNTO (14 * 8 * (ORDER + 1))) <= din((15 * 8 * (ORDER + 1) - 1) DOWNTO (14 * 8 * (ORDER + 1)));
   dout((14 * 8 * (ORDER + 1) - 1) DOWNTO (13 * 8 * (ORDER + 1))) <= din((14 * 8 * (ORDER + 1) - 1) DOWNTO (13 * 8 * (ORDER + 1)));
   dout((13 * 8 * (ORDER + 1) - 1) DOWNTO (12 * 8 * (ORDER + 1))) <= din((13 * 8 * (ORDER + 1) - 1) DOWNTO (12 * 8 * (ORDER + 1)));
   
   dout((12 * 8 * (ORDER + 1) - 1) DOWNTO (11 * 8 * (ORDER + 1))) <= din((11 * 8 * (ORDER + 1) - 1) DOWNTO (10 * 8 * (ORDER + 1)));
   dout((11 * 8 * (ORDER + 1) - 1) DOWNTO (10 * 8 * (ORDER + 1))) <= din((10 * 8 * (ORDER + 1) - 1) DOWNTO ( 9 * 8 * (ORDER + 1)));
   dout((10 * 8 * (ORDER + 1) - 1) DOWNTO ( 9 * 8 * (ORDER + 1))) <= din(( 9 * 8 * (ORDER + 1) - 1) DOWNTO ( 8 * 8 * (ORDER + 1)));
   dout(( 9 * 8 * (ORDER + 1) - 1) DOWNTO ( 8 * 8 * (ORDER + 1))) <= din((12 * 8 * (ORDER + 1) - 1) DOWNTO (11 * 8 * (ORDER + 1)));
   
   dout(( 8 * 8 * (ORDER + 1) - 1) DOWNTO ( 7 * 8 * (ORDER + 1))) <= din(( 6 * 8 * (ORDER + 1) - 1) DOWNTO ( 5 * 8 * (ORDER + 1)));
   dout(( 7 * 8 * (ORDER + 1) - 1) DOWNTO ( 6 * 8 * (ORDER + 1))) <= din(( 5 * 8 * (ORDER + 1) - 1) DOWNTO ( 4 * 8 * (ORDER + 1)));
   dout(( 6 * 8 * (ORDER + 1) - 1) DOWNTO ( 5 * 8 * (ORDER + 1))) <= din(( 8 * 8 * (ORDER + 1) - 1) DOWNTO ( 7 * 8 * (ORDER + 1)));
   dout(( 5 * 8 * (ORDER + 1) - 1) DOWNTO ( 4 * 8 * (ORDER + 1))) <= din(( 7 * 8 * (ORDER + 1) - 1) DOWNTO ( 6 * 8 * (ORDER + 1)));
   
   dout(( 4 * 8 * (ORDER + 1) - 1) DOWNTO ( 3 * 8 * (ORDER + 1))) <= din(( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1)));
   dout(( 3 * 8 * (ORDER + 1) - 1) DOWNTO ( 2 * 8 * (ORDER + 1))) <= din(( 4 * 8 * (ORDER + 1) - 1) DOWNTO ( 3 * 8 * (ORDER + 1)));
   dout(( 2 * 8 * (ORDER + 1) - 1) DOWNTO ( 1 * 8 * (ORDER + 1))) <= din(( 3 * 8 * (ORDER + 1) - 1) DOWNTO ( 2 * 8 * (ORDER + 1)));
   dout(( 1 * 8 * (ORDER + 1) - 1) DOWNTO ( 0 * 8 * (ORDER + 1))) <= din(( 2 * 8 * (ORDER + 1) - 1) DOWNTO ( 1 * 8 * (ORDER + 1)));

END DataFlow;