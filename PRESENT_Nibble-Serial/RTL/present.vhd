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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.PINI_pkg.all;

entity present is
    Port ( clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
	   fresh    : in  STD_LOGIC_VECTOR (fresh_size-1   downto 0);
	   data_in  : in  STD_LOGIC_VECTOR (64*(ORDER+1)-1 downto 0);
           key      : in  STD_LOGIC_VECTOR (80*(ORDER+1)-1 downto 0);
           data_out : out STD_LOGIC_VECTOR (64*(ORDER+1)-1 downto 0);
           done     : out STD_LOGIC);
end present;

architecture dfl of present is

	----------------------------------------------------------
	-- data signals
	----------------------------------------------------------
	signal sboxIn  : STD_LOGIC_VECTOR (4*(ORDER+1)-1 downto 0);
	signal sboxOut : STD_LOGIC_VECTOR (4*(ORDER+1)-1 downto 0);
	signal roundkey: STD_LOGIC_VECTOR (4*(ORDER+1)-1 downto 0);
	signal keyRegKS: STD_LOGIC_VECTOR (4*(ORDER+1)-1 downto 0);

	signal serialIn  		  : STD_LOGIC_VECTOR (4*(ORDER+1)-1 downto 0);
	signal state			  : STD_LOGIC_VECTOR (4*(ORDER+1)-1 downto 0);
	signal stateXORroundkey: STD_LOGIC_VECTOR (4*(ORDER+1)-1 downto 0);

	signal intDone : STD_LOGIC;
	signal final   : STD_LOGIC;

	signal parallelState : STD_LOGIC_VECTOR (64*(ORDER+1)-1 downto 0);

	----------------------------------------------------------
	-- control signals
	----------------------------------------------------------
	signal selSbox : STD_LOGIC;
	signal counter : STD_LOGIC_VECTOR (5*(ORDER+1)-1 downto 0) := (others => '0');
	signal ctrlData: STD_LOGIC_VECTOR (2 downto 0);
	signal ctrlKey:  STD_LOGIC_VECTOR (2 downto 0);

begin

	----------------------------------------------------------
	-- FSM
	----------------------------------------------------------
	fsm: entity work.controler
	Generic Map(LATENCY)
	Port map(
		clk 		=> clk,
		reset 	=> reset,
		selSbox	=> selSbox,
		ctrlData => ctrlData,
		ctrlKey 	=> ctrlKey,
		round 	=> counter(4 downto 0),
		done 		=> intDone,
		final 	=> final);

	GEN_order: FOR i in 0 to ORDER GENERATE
		----------------------------------------------------------
		-- STATE register
		----------------------------------------------------------
		stateFF: entity work.dataBody
		Port map ( 
			clk 		=> clk,
			ctrl 		=> ctrlData,
			inputA 	=> data_in (64*(i+1)-1 downto 64*i),
			inputB 	=> serialIn( 4*(i+1)-1 downto  4*i),
			outputA 	=> state   ( 4*(i+1)-1 downto  4*i),
			outputB 	=> parallelState(64*(i+1)-1 downto 64*i));

		----------------------------------------------------------
		-- Key register
		----------------------------------------------------------
		keyFF: entity work.keyschedule
		Port map ( 
			clk 		=> clk,
			ctrl 		=> ctrlKey,
			counter 	=> counter ( 5*(i+1)-1 downto  5*i),
			inputA 	=> key     (80*(i+1)-1 downto 80*i),
			inputB 	=> sboxOut ( 4*(i+1)-1 downto  4*i),
			outputA 	=> roundkey( 4*(i+1)-1 downto  4*i),
			outputB 	=> keyRegKS( 4*(i+1)-1 downto  4*i));
	END GENERATE;

	----------------------------------------------------------
	-- S-box component
	----------------------------------------------------------
	sboxInst: entity work.Sbox_PINI
	Port map (
		in0 	=> sboxIn(3 downto 0),
		in1 	=> sboxIn(7 downto 4),
		r	=> fresh,
		clk  	=> clk,
		out0 	=> sboxOut(3 downto 0),
		out1 	=> sboxOut(7 downto 4));

	----------------------------------------------------------
	-- XOR sums for the S-Box input
	----------------------------------------------------------
	stateXORroundkey <= state XOR roundkey;

	----------------------------------------------------------
	-- Sbox input MUXes
	----------------------------------------------------------
	sboxIn <= stateXORroundkey when selSbox = '0' else keyRegKS;
				
	serialIn <= stateXORroundkey when intDone = '1'	else sboxOut;
			  
	----------------------------------------------------------
	-- making of the output
	----------------------------------------------------------
	done 		<= final;
	data_out <= parallelState;

end dfl;

