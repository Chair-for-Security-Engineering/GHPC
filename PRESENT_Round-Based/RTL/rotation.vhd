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
ENTITY rotation IS
   GENERIC ( ORDER : NATURAL := 1);
	PORT ( din  : IN  STD_LOGIC_VECTOR ((128 * (ORDER + 1) - 1) DOWNTO 0);
          dout : OUT STD_LOGIC_VECTOR ((128 * (ORDER + 1) - 1) DOWNTO 0));
END rotation;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF rotation IS

BEGIN

   GEN : FOR I IN 0 TO ORDER GENERATE
      dout((128 * I + 127) DOWNTO (128 * I)) <= din((128 * I + 66) DOWNTO (128 * I + 0)) & din((128 * I + 127) DOWNTO (128 * I + 67));
   END GENERATE;
   
END Dataflow;
