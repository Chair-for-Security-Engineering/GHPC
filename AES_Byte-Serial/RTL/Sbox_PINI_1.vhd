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

entity Sbox_PINI_1 is
   Port(
		in0 : in  std_logic_vector(in_size-1    downto 0);
		in1 : in  std_logic_vector(in_size-1    downto 0);
		r   : in  std_logic_vector(fresh_size-1 downto 0);
		clk : in  std_logic;
		out0: out std_logic_vector(out_size-1   downto 0);
		out1: out std_logic_vector(out_size-1   downto 0));
end Sbox_PINI_1;

architecture Behavioral of Sbox_PINI_1 is 

	signal in1_reg			: std_logic_vector(in_size-1    downto 0);

	--===============================================================
	
	signal Step1_reg		: array4(0 to out_size-1);

	--===============================================================

	signal out0_mid2		: std_logic_vector(0 to out_size-1);

begin

	GEN_in: for I in 0 to in_size-1 generate
           GEN_pp: if (pipeline /= 0) generate
		reg_ins1: entity work.reg
		Port map(
			clk	=> clk,
			D	=> in1(I),
			Q	=> in1_reg(I));
           end generate;

           GEN_npp: if (pipeline = 0) generate
		in1_reg(I) <= in1(I);
           end generate;
	end generate;	

	--===============================

	Step1_ins: entity work.PINI_Step1
	Port map (in0, r, clk, Step1_reg);

	---------------------------------

	Step3_inst: entity work.PINI_Step3
	Port map (Step1_reg, in1_reg, clk, out1);
	
	--===============================

	GEN_out: for X in 0 to out_size-1 generate
           GEN_normal: if (low_latency = 0) generate
              GEN_pp: if (pipeline /= 0) generate
	         reg_out0_ins1: entity work.reg
		   Port map(
		      clk => clk,
		      D	  => r(X),
 		      Q	  => out0_mid2(X));

                reg_out0_ins2: entity work.reg
                  Port map(
	             clk => clk,
	             D	 => out0_mid2(X),
	             Q	 => out0(X));
              end generate;

              GEN_npp: if (pipeline = 0) generate
	  	out0(X) <= r(X);
              end generate;
           end generate;

   	   GEN_LL: if (low_latency /= 0) generate
	      tp: Process (in1)
	      begin
	         out0_mid2(X) <= r(X*(2**in_size) + to_integer(unsigned(in1)));
 	      end process;

              reg_out0_ins2: entity work.reg
              Port map(
                 clk => clk,
	         D   => out0_mid2(X),
	         Q   => out0(X));
           end generate;
	end generate;		
	
end Behavioral;
