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

entity PINI_Step3 is
	Port(
		Step2_reg	: in  array4(0 to out_size-1);
		input		: in  std_logic_vector(in_size-1  downto 0);
		clk 		: in  std_logic;
		output		: out std_logic_vector(out_size-1 downto 0));
end PINI_Step3;

architecture Behavioral of PINI_Step3 is 

	signal in_comb	: std_logic_vector(2**in_size-1 downto 0);

	signal Step3	: array4(0 to out_size-1);
	signal Step3_reg: array4(0 to out_size-1);

begin

	GEN_in_comb: for I in 0 to 2**in_size-1 generate
		in_comb(I)	<= '1' when (input = (std_logic_vector(to_unsigned(I, in_size)))) else '0';
	end generate;

	GEN_out: for X in 0 to out_size-1 generate
		GEN_Step3: for I in 0 to 2**in_size-1 generate
			step3_ins: entity work.PINI_AND_reg
			Port map (in_comb(I), Step2_reg(X)(I), clk, Step3_reg(X)(I));
		end generate;	

		XOR_all_inst: entity work.XOR_all_module
		Generic map (2**in_size)
		Port map (Step3_reg(X), output(X));
	end generate;	
	
end Behavioral;
