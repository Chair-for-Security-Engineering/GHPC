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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.PINI_pkg.all;

entity PINI_Step1 is
   Port(
		in0 		: in  std_logic_vector(in_size-1    downto 0);
		r   		: in  std_logic_vector(fresh_size-1 downto 0);
		clk 		: in  std_logic;
		Step1_reg	: out array4(0 to out_size-1));
end PINI_Step1;

architecture Behavioral of PINI_Step1 is 

	signal in0_comb		: array1(0 to 2**in_size-1);
	signal Sboxout 		: array2(0 to 2**in_size-1);
	
	signal Step1		: array4(0 to out_size-1);

begin

	GEN_in0_comb: for I in 0 to 2**in_size-1 generate
		GEN_in0_bit: for J in 0 to in_size-1 generate
			in0_comb(I)(j) <= in0(J) when GetBit(I,in_size,J) = '0' else (not in0(J));
		end generate;
		
	Sboxout(I) <= 
            X"C" WHEN in0_comb(I)= X"0" ELSE
            X"5" WHEN in0_comb(I)= X"1" ELSE
            X"6" WHEN in0_comb(I)= X"2" ELSE
            X"B" WHEN in0_comb(I)= X"3" ELSE
            X"9" WHEN in0_comb(I)= X"4" ELSE
            X"0" WHEN in0_comb(I)= X"5" ELSE
            X"A" WHEN in0_comb(I)= X"6" ELSE
            X"D" WHEN in0_comb(I)= X"7" ELSE
            X"3" WHEN in0_comb(I)= X"8" ELSE
            X"E" WHEN in0_comb(I)= X"9" ELSE
            X"F" WHEN in0_comb(I)= X"A" ELSE
            X"8" WHEN in0_comb(I)= X"B" ELSE
            X"4" WHEN in0_comb(I)= X"C" ELSE
            X"7" WHEN in0_comb(I)= X"D" ELSE
            X"1" WHEN in0_comb(I)= X"E" ELSE
            X"2";
	end generate;

	---------------------------------

	GEN_out: for X in 0 to out_size-1 generate
		GEN_Step1_1: for I in 0 to 2**in_size-1 generate
		   GEN_normal: if (low_latency = 0) generate
                      Step1(X)(I) <= r(X) xor Sboxout(I)(X);
                   end generate;

		   GEN_LL: if (low_latency /= 0) generate
                      Step1(X)(I) <= r(I+X*(2**in_size)) xor Sboxout(I)(X);
                   end generate;
			
 		   reg_ins: entity work.reg
		   Port map(
		     clk	=> clk,
		     D		=> Step1(X)(I),
		     Q		=> Step1_reg(X)(I));
		end generate;	
	end generate;	
	
end Behavioral;
