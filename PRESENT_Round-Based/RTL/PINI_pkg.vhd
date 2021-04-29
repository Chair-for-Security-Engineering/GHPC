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

package PINI_pkg is

	-- Functions

	function xor_all (
		input 	: std_logic_vector)
		return std_logic;
		
	function GetBit (
		input 	: integer;
		size     : integer;
		myBit    : integer)
		return std_logic;
		
	--------------------------------------------------------	
	-- Constants

	constant in_size	: integer := 4;  -- Sbox input  size
	constant out_size	: integer := 4;  -- Sbox output size

	constant low_latency 	: integer := 0; -- 0 / 1

	constant fresh_size 	: integer := out_size*(1 + low_latency*(2**in_size - 1));

	constant pipeline 	: integer := 1;
        
        constant ORDER          : integer := 1;
        constant LATENCY        : integer := 2 - low_latency;

	--------------------------------------------------------	
	-- Types
	type array1		is array(natural range <>) of std_logic_vector(in_size-1  		downto 0);
	type array2		is array(natural range <>) of std_logic_vector(out_size-1		downto 0);
	type array3		is array(natural range <>) of std_logic_vector(2**(2*in_size)-1 	downto 0);
	type array4		is array(natural range <>) of std_logic_vector(2**in_size-1 		downto 0);

end PINI_pkg;

package body PINI_pkg is
  
	function xor_all (
		input 	: std_logic_vector)
		return std_logic is
		variable res : std_logic := '0';
	begin
		for i in input'range loop
			res := res xor input(i);
		end loop;
		return res;
	end xor_all;

	--------------------------------------------------------

	function GetBit (
		input 	: integer;
		size     : integer;
		myBit    : integer)
		return std_logic is
		variable temp: std_logic_vector(size-1 downto 0);
		variable res : std_logic := '0';
	begin
		temp := std_logic_vector(to_unsigned(input, size));
		res := temp(myBit);
		return res;
	end GetBit;
  
end PINI_pkg;
