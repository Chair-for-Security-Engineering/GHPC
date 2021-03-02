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
ENTITY mixcolumns IS
    GENERIC (ORDER : NATURAL := 0);
    PORT ( din  : IN  STD_LOGIC_VECTOR ((32 * ORDER) + 31 DOWNTO 0);
           dout : OUT STD_LOGIC_VECTOR ((32 * ORDER) + 31 DOWNTO 0));
END mixcolumns;

-- ARCHITECTURE
--------------------------------------------------------------------
ARCHITECTURE DataFlow OF mixcolumns IS

   -- SIGNALS ------------------------------------------------------
   SIGNAL MSB0, MSB1, MSB2, MSB3 : STD_LOGIC_VECTOR(( 1 * (ORDER + 1) - 1) DOWNTO 0);
   SIGNAL X1, X2, X3             : STD_LOGIC_VECTOR((32 * (ORDER + 1) - 1) DOWNTO 0);

BEGIN
   
   -- MULTIPLICATION BY 1 ---------------------------------------
   X1((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) <= din((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1)));
   X1((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) <= din((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1)));
   X1((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) <= din((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1)));
   X1((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1))) <= din((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1)));

   -- MULTIPLICATION BY 2 ---------------------------------------
   MUL2 : FOR I IN 0 TO ORDER GENERATE
      MSB0(I) <= din((4 * 8 * (ORDER + 1) - 8 * I - 1));
      MSB1(I) <= din((3 * 8 * (ORDER + 1) - 8 * I - 1));
      MSB2(I) <= din((2 * 8 * (ORDER + 1) - 8 * I - 1));
      MSB3(I) <= din((1 * 8 * (ORDER + 1) - 8 * I - 1));
      
      X2((4 * 8 * (ORDER + 1) - 8 * I - 1) DOWNTO (4 * 8 * (ORDER + 1) - 8 * (I + 1))) <= (din((4 * 8 * (ORDER + 1) - 8 * I - 2) DOWNTO (4 * 8 * (ORDER + 1) - 8 * (I + 1))) & "0") XOR ("000" & MSB0(I) & MSB0(I) & "0" & MSB0(I) & MSB0(I));
      X2((3 * 8 * (ORDER + 1) - 8 * I - 1) DOWNTO (3 * 8 * (ORDER + 1) - 8 * (I + 1))) <= (din((3 * 8 * (ORDER + 1) - 8 * I - 2) DOWNTO (3 * 8 * (ORDER + 1) - 8 * (I + 1))) & "0") XOR ("000" & MSB1(I) & MSB1(I) & "0" & MSB1(I) & MSB1(I));
      X2((2 * 8 * (ORDER + 1) - 8 * I - 1) DOWNTO (2 * 8 * (ORDER + 1) - 8 * (I + 1))) <= (din((2 * 8 * (ORDER + 1) - 8 * I - 2) DOWNTO (2 * 8 * (ORDER + 1) - 8 * (I + 1))) & "0") XOR ("000" & MSB2(I) & MSB2(I) & "0" & MSB2(I) & MSB2(I));
      X2((1 * 8 * (ORDER + 1) - 8 * I - 1) DOWNTO (1 * 8 * (ORDER + 1) - 8 * (I + 1))) <= (din((1 * 8 * (ORDER + 1) - 8 * I - 2) DOWNTO (1 * 8 * (ORDER + 1) - 8 * (I + 1))) & "0") XOR ("000" & MSB3(I) & MSB3(I) & "0" & MSB3(I) & MSB3(I));
   END GENERATE;

   -- MULTIPLICATION BY 3 ---------------------------------------
   X3((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) <= din((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) XOR X2((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1)));
   X3((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) <= din((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) XOR X2((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1)));
   X3((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) <= din((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) XOR X2((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1)));
   X3((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1))) <= din((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1))) XOR X2((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1)));
         
   -- RESULT ----------------------------------------------------
   dout((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) <= X2((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) XOR X3((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) XOR X1((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) XOR X1((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1)));
   dout((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) <= X1((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) XOR X2((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) XOR X3((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) XOR X1((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1)));
   dout((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) <= X1((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) XOR X1((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) XOR X2((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) XOR X3((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1)));
   dout((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1))) <= X3((4 * 8 * (ORDER + 1) - 1) DOWNTO (3 * 8 * (ORDER + 1))) XOR X1((3 * 8 * (ORDER + 1) - 1) DOWNTO (2 * 8 * (ORDER + 1))) XOR X1((2 * 8 * (ORDER + 1) - 1) DOWNTO (1 * 8 * (ORDER + 1))) XOR X2((1 * 8 * (ORDER + 1) - 1) DOWNTO (0 * 8 * (ORDER + 1)));
          
END DataFlow;
