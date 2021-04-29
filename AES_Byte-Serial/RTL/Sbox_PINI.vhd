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

entity Sbox_PINI is
   Port(
		input		: in  std_logic_vector(in_size*(ORDER+1)-1  downto 0);
		fresh		: in  std_logic_vector(fresh_size-1         downto 0);
		clk 		: in  std_logic;
		output	: out std_logic_vector(out_size*(ORDER+1)-1 downto 0));
end Sbox_PINI;

architecture Behavioral of Sbox_PINI is 

	component Sbox_Canright
	Port(
		A			: in  STD_LOGIC_VECTOR(7 downto 0);
		encrypt	: in  STD_LOGIC;
		Q			: out STD_LOGIC_VECTOR(7 downto 0));
	end component;

begin

	Gen_ORDER_0: IF ORDER = 0 GENERATE
		SboxIns: Sbox_Canright
		Port map (
			A			=> input,
			encrypt	=> '1',
			Q			=> output);
	END GENERATE;

	------------------------------------------
	
	Gen_ORDER_1: IF ORDER = 1 GENERATE
		SboxIns: entity work.Sbox_PINI_1 
		Port map (
			clk	=> clk,
			in0 	=> input(in_size*1-1   downto in_size*0),
			in1 	=> input(in_size*2-1   downto in_size*1),
			r   	=> fresh,
			out0	=> output(out_size*1-1 downto out_size*0),
			out1 	=> output(out_size*2-1 downto out_size*1));
	END GENERATE;
	
	------------------------------------------
	
end Behavioral;
