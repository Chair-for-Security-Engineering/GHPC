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
use work.GHPC_pkg.all;

entity GHPC_Step2 is
   Generic (
      in_size	    : integer;
      out_size	    : integer; 
      low_latency   : integer);
   Port(
	Step1_reg	: in  bus_array(0 to out_size-1, 2**in_size-1 downto 0);
	input		: in  std_logic_vector(in_size-1  downto 0);
	clk 		: in  std_logic;
	output		: out std_logic_vector(out_size-1 downto 0));
end GHPC_Step2;

architecture Behavioral of GHPC_Step2 is 

	type in_array  is array(natural range <>) of std_logic_vector(2**in_size-1  downto 0);

	signal in_comb	: std_logic_vector(2**in_size-1 downto 0);
	signal Step2	: in_array(0 to out_size-1);
	signal Step2_reg: in_array(0 to out_size-1);

begin

        GEN_normal: if (low_latency = 0) generate
  	   GEN_in_comb: for I in 0 to 2**in_size-1 generate
		in_comb(I) <= '1' when (input = (std_logic_vector(to_unsigned(I, in_size)))) else '0';
	   end generate;

	   GEN_out: for X in 0 to out_size-1 generate
		GEN_Step2: for I in 0 to 2**in_size-1 generate
			step2_ins: entity work.GHPC_AND_reg
			Port map (in_comb(I), Step1_reg(X, I), clk, Step2_reg(X)(I));
		end generate;	

                output(X) <= xor_all(Step2_reg(X));
	   end generate;	
        end generate;

   	GEN_LL: if (low_latency /= 0) generate
	   GEN_out: for X in 0 to out_size-1 generate
	      tp: Process (input)
	      begin
	         output(X) <= Step1_reg(X, to_integer(unsigned(input)));
 	      end process;
           end generate;
        end generate;
	
end Behavioral;
