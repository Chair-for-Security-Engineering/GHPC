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

-- ENTITY
--------------------------------------------------------------------
ENTITY Sbox IS
	PORT ( din	: IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
          dout	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END Sbox;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Dataflow OF Sbox IS

BEGIN

	dout  <= X"C" WHEN din = X"0" ELSE
            X"5" WHEN din = X"1" ELSE
            X"6" WHEN din = X"2" ELSE
            X"B" WHEN din = X"3" ELSE
            X"9" WHEN din = X"4" ELSE
            X"0" WHEN din = X"5" ELSE
            X"A" WHEN din = X"6" ELSE
            X"D" WHEN din = X"7" ELSE
            X"3" WHEN din = X"8" ELSE
            X"E" WHEN din = X"9" ELSE
            X"F" WHEN din = X"A" ELSE
            X"8" WHEN din = X"B" ELSE
            X"4" WHEN din = X"C" ELSE
            X"7" WHEN din = X"D" ELSE
            X"1" WHEN din = X"E" ELSE
            X"2";
	
END Dataflow;