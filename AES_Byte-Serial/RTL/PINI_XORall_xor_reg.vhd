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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.PINI_pkg.all;

entity PINI_XORall_xor_reg is
	Generic (size : integer);
	Port(
		input1	: in  std_logic_vector(size-1  downto 0);
		input2	: in  std_logic;
		clk 		: in  std_logic;
		output	: out std_logic);
end PINI_XORall_xor_reg;

architecture Behavioral of PINI_XORall_xor_reg is 

	signal value		: std_logic;

begin
	
	value <= xor_all(input1) XOR input2;

	reg_gen: PROCESS(clk, value)
	BEGIN
		IF RISING_EDGE(clk) THEN
			output <= value;
		END IF;
	END PROCESS;		

end Behavioral;
