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
		
		Sbox : PROCESS(in0_comb(I))
		BEGIN
			CASE in0_comb(I) IS
				WHEN X"00"  => Sboxout(I) <= X"63";
				WHEN X"01"  => Sboxout(I) <= X"7C";
				WHEN X"02"  => Sboxout(I) <= X"77";
				WHEN X"03"  => Sboxout(I) <= X"7B";
				WHEN X"04"  => Sboxout(I) <= X"F2";
				WHEN X"05"  => Sboxout(I) <= X"6B";
				WHEN X"06"  => Sboxout(I) <= X"6F";
				WHEN X"07"  => Sboxout(I) <= X"C5";
				WHEN X"08"  => Sboxout(I) <= X"30";
				WHEN X"09"  => Sboxout(I) <= X"01";
				WHEN X"0A"  => Sboxout(I) <= X"67";
				WHEN X"0B"  => Sboxout(I) <= X"2B";
				WHEN X"0C"  => Sboxout(I) <= X"FE";
				WHEN X"0D"  => Sboxout(I) <= X"D7";
				WHEN X"0E"  => Sboxout(I) <= X"AB";
				WHEN X"0F"  => Sboxout(I) <= X"76";
				WHEN X"10"  => Sboxout(I) <= X"CA";
				WHEN X"11"  => Sboxout(I) <= X"82";
				WHEN X"12"  => Sboxout(I) <= X"C9";
				WHEN X"13"  => Sboxout(I) <= X"7D";
				WHEN X"14"  => Sboxout(I) <= X"FA";
				WHEN X"15"  => Sboxout(I) <= X"59";
				WHEN X"16"  => Sboxout(I) <= X"47";
				WHEN X"17"  => Sboxout(I) <= X"F0";
				WHEN X"18"  => Sboxout(I) <= X"AD";
				WHEN X"19"  => Sboxout(I) <= X"D4";
				WHEN X"1A"  => Sboxout(I) <= X"A2";
				WHEN X"1B"  => Sboxout(I) <= X"AF";
				WHEN X"1C"  => Sboxout(I) <= X"9C";
				WHEN X"1D"  => Sboxout(I) <= X"A4";
				WHEN X"1E"  => Sboxout(I) <= X"72";
				WHEN X"1F"  => Sboxout(I) <= X"C0";
				WHEN X"20"  => Sboxout(I) <= X"B7";
				WHEN X"21"  => Sboxout(I) <= X"FD";
				WHEN X"22"  => Sboxout(I) <= X"93";
				WHEN X"23"  => Sboxout(I) <= X"26";
				WHEN X"24"  => Sboxout(I) <= X"36";
				WHEN X"25"  => Sboxout(I) <= X"3F";
				WHEN X"26"  => Sboxout(I) <= X"F7";
				WHEN X"27"  => Sboxout(I) <= X"CC";
				WHEN X"28"  => Sboxout(I) <= X"34";
				WHEN X"29"  => Sboxout(I) <= X"A5";
				WHEN X"2A"  => Sboxout(I) <= X"E5";
				WHEN X"2B"  => Sboxout(I) <= X"F1";
				WHEN X"2C"  => Sboxout(I) <= X"71";
				WHEN X"2D"  => Sboxout(I) <= X"D8";
				WHEN X"2E"  => Sboxout(I) <= X"31";
				WHEN X"2F"  => Sboxout(I) <= X"15";
				WHEN X"30"  => Sboxout(I) <= X"04";
				WHEN X"31"  => Sboxout(I) <= X"C7";
				WHEN X"32"  => Sboxout(I) <= X"23";
				WHEN X"33"  => Sboxout(I) <= X"C3";
				WHEN X"34"  => Sboxout(I) <= X"18";
				WHEN X"35"  => Sboxout(I) <= X"96";
				WHEN X"36"  => Sboxout(I) <= X"05";
				WHEN X"37"  => Sboxout(I) <= X"9A";
				WHEN X"38"  => Sboxout(I) <= X"07";
				WHEN X"39"  => Sboxout(I) <= X"12";
				WHEN X"3A"  => Sboxout(I) <= X"80";
				WHEN X"3B"  => Sboxout(I) <= X"E2";
				WHEN X"3C"  => Sboxout(I) <= X"EB";
				WHEN X"3D"  => Sboxout(I) <= X"27";
				WHEN X"3E"  => Sboxout(I) <= X"B2";
				WHEN X"3F"  => Sboxout(I) <= X"75";
				WHEN X"40"  => Sboxout(I) <= X"09";
				WHEN X"41"  => Sboxout(I) <= X"83";
				WHEN X"42"  => Sboxout(I) <= X"2C";
				WHEN X"43"  => Sboxout(I) <= X"1A";
				WHEN X"44"  => Sboxout(I) <= X"1B";
				WHEN X"45"  => Sboxout(I) <= X"6E";
				WHEN X"46"  => Sboxout(I) <= X"5A";
				WHEN X"47"  => Sboxout(I) <= X"A0";
				WHEN X"48"  => Sboxout(I) <= X"52";
				WHEN X"49"  => Sboxout(I) <= X"3B";
				WHEN X"4A"  => Sboxout(I) <= X"D6";
				WHEN X"4B"  => Sboxout(I) <= X"B3";
				WHEN X"4C"  => Sboxout(I) <= X"29";
				WHEN X"4D"  => Sboxout(I) <= X"E3";
				WHEN X"4E"  => Sboxout(I) <= X"2F";
				WHEN X"4F"  => Sboxout(I) <= X"84";
				WHEN X"50"  => Sboxout(I) <= X"53";
				WHEN X"51"  => Sboxout(I) <= X"D1";
				WHEN X"52"  => Sboxout(I) <= X"00";
				WHEN X"53"  => Sboxout(I) <= X"ED";
				WHEN X"54"  => Sboxout(I) <= X"20";
				WHEN X"55"  => Sboxout(I) <= X"FC";
				WHEN X"56"  => Sboxout(I) <= X"B1";
				WHEN X"57"  => Sboxout(I) <= X"5B";
				WHEN X"58"  => Sboxout(I) <= X"6A";
				WHEN X"59"  => Sboxout(I) <= X"CB";
				WHEN X"5A"  => Sboxout(I) <= X"BE";
				WHEN X"5B"  => Sboxout(I) <= X"39";
				WHEN X"5C"  => Sboxout(I) <= X"4A";
				WHEN X"5D"  => Sboxout(I) <= X"4C";
				WHEN X"5E"  => Sboxout(I) <= X"58";
				WHEN X"5F"  => Sboxout(I) <= X"CF";
				WHEN X"60"  => Sboxout(I) <= X"D0";
				WHEN X"61"  => Sboxout(I) <= X"EF";
				WHEN X"62"  => Sboxout(I) <= X"AA";
				WHEN X"63"  => Sboxout(I) <= X"FB";
				WHEN X"64"  => Sboxout(I) <= X"43";
				WHEN X"65"  => Sboxout(I) <= X"4D";
				WHEN X"66"  => Sboxout(I) <= X"33";
				WHEN X"67"  => Sboxout(I) <= X"85";
				WHEN X"68"  => Sboxout(I) <= X"45";
				WHEN X"69"  => Sboxout(I) <= X"F9";
				WHEN X"6A"  => Sboxout(I) <= X"02";
				WHEN X"6B"  => Sboxout(I) <= X"7F";
				WHEN X"6C"  => Sboxout(I) <= X"50";
				WHEN X"6D"  => Sboxout(I) <= X"3C";
				WHEN X"6E"  => Sboxout(I) <= X"9F";
				WHEN X"6F"  => Sboxout(I) <= X"A8";
				WHEN X"70"  => Sboxout(I) <= X"51";
				WHEN X"71"  => Sboxout(I) <= X"A3";
				WHEN X"72"  => Sboxout(I) <= X"40";
				WHEN X"73"  => Sboxout(I) <= X"8F";
				WHEN X"74"  => Sboxout(I) <= X"92";
				WHEN X"75"  => Sboxout(I) <= X"9D";
				WHEN X"76"  => Sboxout(I) <= X"38";
				WHEN X"77"  => Sboxout(I) <= X"F5";
				WHEN X"78"  => Sboxout(I) <= X"BC";
				WHEN X"79"  => Sboxout(I) <= X"B6";
				WHEN X"7A"  => Sboxout(I) <= X"DA";
				WHEN X"7B"  => Sboxout(I) <= X"21";
				WHEN X"7C"  => Sboxout(I) <= X"10";
				WHEN X"7D"  => Sboxout(I) <= X"FF";
				WHEN X"7E"  => Sboxout(I) <= X"F3";
				WHEN X"7F"  => Sboxout(I) <= X"D2";
				WHEN X"80"  => Sboxout(I) <= X"CD";
				WHEN X"81"  => Sboxout(I) <= X"0C";
				WHEN X"82"  => Sboxout(I) <= X"13";
				WHEN X"83"  => Sboxout(I) <= X"EC";
				WHEN X"84"  => Sboxout(I) <= X"5F";
				WHEN X"85"  => Sboxout(I) <= X"97";
				WHEN X"86"  => Sboxout(I) <= X"44";
				WHEN X"87"  => Sboxout(I) <= X"17";
				WHEN X"88"  => Sboxout(I) <= X"C4";
				WHEN X"89"  => Sboxout(I) <= X"A7";
				WHEN X"8A"  => Sboxout(I) <= X"7E";
				WHEN X"8B"  => Sboxout(I) <= X"3D";
				WHEN X"8C"  => Sboxout(I) <= X"64";
				WHEN X"8D"  => Sboxout(I) <= X"5D";
				WHEN X"8E"  => Sboxout(I) <= X"19";
				WHEN X"8F"  => Sboxout(I) <= X"73";
				WHEN X"90"  => Sboxout(I) <= X"60";
				WHEN X"91"  => Sboxout(I) <= X"81";
				WHEN X"92"  => Sboxout(I) <= X"4F";
				WHEN X"93"  => Sboxout(I) <= X"DC";
				WHEN X"94"  => Sboxout(I) <= X"22";
				WHEN X"95"  => Sboxout(I) <= X"2A";
				WHEN X"96"  => Sboxout(I) <= X"90";
				WHEN X"97"  => Sboxout(I) <= X"88";
				WHEN X"98"  => Sboxout(I) <= X"46";
				WHEN X"99"  => Sboxout(I) <= X"EE";
				WHEN X"9A"  => Sboxout(I) <= X"B8";
				WHEN X"9B"  => Sboxout(I) <= X"14";
				WHEN X"9C"  => Sboxout(I) <= X"DE";
				WHEN X"9D"  => Sboxout(I) <= X"5E";
				WHEN X"9E"  => Sboxout(I) <= X"0B";
				WHEN X"9F"  => Sboxout(I) <= X"DB";
				WHEN X"A0"  => Sboxout(I) <= X"E0";
				WHEN X"A1"  => Sboxout(I) <= X"32";
				WHEN X"A2"  => Sboxout(I) <= X"3A";
				WHEN X"A3"  => Sboxout(I) <= X"0A";
				WHEN X"A4"  => Sboxout(I) <= X"49";
				WHEN X"A5"  => Sboxout(I) <= X"06";
				WHEN X"A6"  => Sboxout(I) <= X"24";
				WHEN X"A7"  => Sboxout(I) <= X"5C";
				WHEN X"A8"  => Sboxout(I) <= X"C2";
				WHEN X"A9"  => Sboxout(I) <= X"D3";
				WHEN X"AA"  => Sboxout(I) <= X"AC";
				WHEN X"AB"  => Sboxout(I) <= X"62";
				WHEN X"AC"  => Sboxout(I) <= X"91";
				WHEN X"AD"  => Sboxout(I) <= X"95";
				WHEN X"AE"  => Sboxout(I) <= X"E4";
				WHEN X"AF"  => Sboxout(I) <= X"79";
				WHEN X"B0"  => Sboxout(I) <= X"E7";
				WHEN X"B1"  => Sboxout(I) <= X"C8";
				WHEN X"B2"  => Sboxout(I) <= X"37";
				WHEN X"B3"  => Sboxout(I) <= X"6D";
				WHEN X"B4"  => Sboxout(I) <= X"8D";
				WHEN X"B5"  => Sboxout(I) <= X"D5";
				WHEN X"B6"  => Sboxout(I) <= X"4E";
				WHEN X"B7"  => Sboxout(I) <= X"A9";
				WHEN X"B8"  => Sboxout(I) <= X"6C";
				WHEN X"B9"  => Sboxout(I) <= X"56";
				WHEN X"BA"  => Sboxout(I) <= X"F4";
				WHEN X"BB"  => Sboxout(I) <= X"EA";
				WHEN X"BC"  => Sboxout(I) <= X"65";
				WHEN X"BD"  => Sboxout(I) <= X"7A";
				WHEN X"BE"  => Sboxout(I) <= X"AE";
				WHEN X"BF"  => Sboxout(I) <= X"08";
				WHEN X"C0"  => Sboxout(I) <= X"BA";
				WHEN X"C1"  => Sboxout(I) <= X"78";
				WHEN X"C2"  => Sboxout(I) <= X"25";
				WHEN X"C3"  => Sboxout(I) <= X"2E";
				WHEN X"C4"  => Sboxout(I) <= X"1C";
				WHEN X"C5"  => Sboxout(I) <= X"A6";
				WHEN X"C6"  => Sboxout(I) <= X"B4";
				WHEN X"C7"  => Sboxout(I) <= X"C6";
				WHEN X"C8"  => Sboxout(I) <= X"E8";
				WHEN X"C9"  => Sboxout(I) <= X"DD";
				WHEN X"CA"  => Sboxout(I) <= X"74";
				WHEN X"CB"  => Sboxout(I) <= X"1F";
				WHEN X"CC"  => Sboxout(I) <= X"4B";
				WHEN X"CD"  => Sboxout(I) <= X"BD";
				WHEN X"CE"  => Sboxout(I) <= X"8B";
				WHEN X"CF"  => Sboxout(I) <= X"8A";
				WHEN X"D0"  => Sboxout(I) <= X"70";
				WHEN X"D1"  => Sboxout(I) <= X"3E";
				WHEN X"D2"  => Sboxout(I) <= X"B5";
				WHEN X"D3"  => Sboxout(I) <= X"66";
				WHEN X"D4"  => Sboxout(I) <= X"48";
				WHEN X"D5"  => Sboxout(I) <= X"03";
				WHEN X"D6"  => Sboxout(I) <= X"F6";
				WHEN X"D7"  => Sboxout(I) <= X"0E";
				WHEN X"D8"  => Sboxout(I) <= X"61";
				WHEN X"D9"  => Sboxout(I) <= X"35";
				WHEN X"DA"  => Sboxout(I) <= X"57";
				WHEN X"DB"  => Sboxout(I) <= X"B9";
				WHEN X"DC"  => Sboxout(I) <= X"86";
				WHEN X"DD"  => Sboxout(I) <= X"C1";
				WHEN X"DE"  => Sboxout(I) <= X"1D";
				WHEN X"DF"  => Sboxout(I) <= X"9E";
				WHEN X"E0"  => Sboxout(I) <= X"E1";
				WHEN X"E1"  => Sboxout(I) <= X"F8";
				WHEN X"E2"  => Sboxout(I) <= X"98";
				WHEN X"E3"  => Sboxout(I) <= X"11";
				WHEN X"E4"  => Sboxout(I) <= X"69";
				WHEN X"E5"  => Sboxout(I) <= X"D9";
				WHEN X"E6"  => Sboxout(I) <= X"8E";
				WHEN X"E7"  => Sboxout(I) <= X"94";
				WHEN X"E8"  => Sboxout(I) <= X"9B";
				WHEN X"E9"  => Sboxout(I) <= X"1E";
				WHEN X"EA"  => Sboxout(I) <= X"87";
				WHEN X"EB"  => Sboxout(I) <= X"E9";
				WHEN X"EC"  => Sboxout(I) <= X"CE";
				WHEN X"ED"  => Sboxout(I) <= X"55";
				WHEN X"EE"  => Sboxout(I) <= X"28";
				WHEN X"EF"  => Sboxout(I) <= X"DF";
				WHEN X"F0"  => Sboxout(I) <= X"8C";
				WHEN X"F1"  => Sboxout(I) <= X"A1";
				WHEN X"F2"  => Sboxout(I) <= X"89";
				WHEN X"F3"  => Sboxout(I) <= X"0D";
				WHEN X"F4"  => Sboxout(I) <= X"BF";
				WHEN X"F5"  => Sboxout(I) <= X"E6";
				WHEN X"F6"  => Sboxout(I) <= X"42";
				WHEN X"F7"  => Sboxout(I) <= X"68";
				WHEN X"F8"  => Sboxout(I) <= X"41";
				WHEN X"F9"  => Sboxout(I) <= X"99";
				WHEN X"FA"  => Sboxout(I) <= X"2D";
				WHEN X"FB"  => Sboxout(I) <= X"0F";
				WHEN X"FC"  => Sboxout(I) <= X"B0";
				WHEN X"FD"  => Sboxout(I) <= X"54";
				WHEN X"FE"  => Sboxout(I) <= X"BB";
				WHEN OTHERS => Sboxout(I) <= X"16"; -- in = 0xff
			END CASE;
		END PROCESS;
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
