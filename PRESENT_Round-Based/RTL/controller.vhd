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
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.LOG2;
USE IEEE.MATH_REAL.CEIL;

library work;
use work.PINI_pkg.all;

-- ENTITY
--------------------------------------------------------------------
ENTITY controller IS
	PORT ( clk  : IN  STD_LOGIC;
	       rst  : IN  STD_LOGIC;
	       done : OUT STD_LOGIC;
	       seld : OUT STD_LOGIC;
	       selk : OUT STD_LOGIC;
	       ken  : OUT STD_LOGIC;
	       rcon : OUT STD_LOGIC_VECTOR((5 * (ORDER + 1) - 1) DOWNTO 0));
END controller;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE FSM OF controller IS

   -- STATES ---------------------------------------------------------------------
   TYPE STATES IS (S_IDLE, S_ROUND, S_DELAY, S_DONE);
   SIGNAL STATE : STATES;

   -- COUNTER --------------------------------------------------------------------
   SIGNAL round : UNSIGNED(4 DOWNTO 0);
   SIGNAL delay : UNSIGNED(INTEGER(CEIL(LOG2(REAL(LATENCY + 1)))) - 1 DOWNTO 0);
   
   -- SIGNALS --------------------------------------------------------------------
  
BEGIN

   -- 1-PROCESS FSM --------------------------------------------------------------
   PROCESS(clk, rst)
   BEGIN   
      -- finite state machine
      IF RISING_EDGE(CLK) THEN
         -- synchronous reset
         IF (rst = '1') THEN
            done <= '0';
            seld <= '1';
            selk <= '1';
            ken  <= '1';
            rcon <= (OTHERS => '0');
            
            round <= (0 => '1', OTHERS => '0');
            delay <= (0 => '1', OTHERS => '0');
                     
            IF (LATENCY = 1) THEN
               STATE <= S_ROUND;
            ELSE
               STATE <= S_DELAY;
            END IF;
                    
         ELSE
            -- default assignments
            done  <= '0';
            seld  <= '0';
            selk  <= '0';
            ken   <= '0';
            rcon  <= (OTHERS => '0');
            
            round <= round;
            delay <= delay + 1;
            
            -- case evaluation
            CASE STATE IS
               ----------------------------------------------------------------------
               WHEN S_IDLE  => 
               ----------------------------------------------------------------------
               WHEN S_ROUND => round <= round + 1;
                               ken   <= '1';
                               rcon(4 DOWNTO 0) <= STD_LOGIC_VECTOR(round);
                               IF (LATENCY > 1) THEN
                                  STATE <= S_DELAY;
                               ELSE
                                  IF (round = "11110") THEN
                                     STATE <= S_DONE;
                                  END IF;
                               END IF;
               ----------------------------------------------------------------------
               WHEN S_DELAY => IF (delay = (LATENCY - 1)) THEN
                                  delay <= (OTHERS => '0'); 
                                  IF (round = "11111") THEN
                                     STATE <= S_DONE;
                                  ELSE                 
                                     STATE <= S_ROUND;                               
                                  END IF;             
                               ELSE
                                  delay <= delay + 1;
                               END IF;
               ----------------------------------------------------------------------
               WHEN S_DONE  => done  <= '1';
                               rcon(4 DOWNTO 0) <= STD_LOGIC_VECTOR(round);
                               STATE <= S_IDLE;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
   -------------------------------------------------------------------------------
   
END FSM;