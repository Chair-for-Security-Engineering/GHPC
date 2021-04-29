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

-- IMPORTS
--------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.LOG2;
USE IEEE.MATH_REAL.CEIL;

-- ENTITY
--------------------------------------------------------------------
ENTITY controller IS
   GENERIC (ORDER    : NATURAL := 0;
            LATENCY  : NATURAL := 0);
	PORT ( clk  : IN  STD_LOGIC;
	       rst  : IN  STD_LOGIC;
	       done : OUT STD_LOGIC;
          seld : OUT STD_LOGIC;
	       den  : OUT STD_LOGIC;
	       sr   : OUT STD_LOGIC;
	       mc   : OUT STD_LOGIC;
	       selk : OUT STD_LOGIC;
          ken  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          exp  : OUT STD_LOGIC;
	       rot  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	       add  : OUT STD_LOGIC;
	       rcon : OUT STD_LOGIC_VECTOR((8 * (ORDER + 1) - 1) DOWNTO 0));
END controller;

-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE FSM OF controller IS

   -- STATES ---------------------------------------------------------------------
   TYPE STATES IS (S_IDLE, S_INIT, S_SUB, S_DELAY, S_SHIFT, S_MIX, S_KEY, S_DONE);
   SIGNAL STATE : STATES;

   -- COUNTER --------------------------------------------------------------------
   SIGNAL round : UNSIGNED(3 DOWNTO 0);
   SIGNAL delay : UNSIGNED(INTEGER(CEIL(LOG2(REAL(21+LATENCY+1)))) - 1 DOWNTO 0);

   -- SIGNALS --------------------------------------------------------------------
   SIGNAL const : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
BEGIN

   -- ROUND CONSTANT -------------------------------------------------------------
   const <= X"01" WHEN round = X"0" ELSE
            X"02" WHEN round = X"1" ELSE
            X"04" WHEN round = X"2" ELSE
            X"08" WHEN round = X"3" ELSE
            X"10" WHEN round = X"4" ELSE
            X"20" WHEN round = X"5" ELSE
            X"40" WHEN round = X"6" ELSE
            X"80" WHEN round = X"7" ELSE
            X"1b" WHEN round = X"8" ELSE X"36";

   -- 1-PROCESS FSM --------------------------------------------------------------
   PROCESS(clk, rst)
   BEGIN            
      -- finite state machine
      IF RISING_EDGE(CLK) THEN
            
         -- synchronous reset
         IF (rst = '1') THEN
            done  <= '0';     
            seld  <= '1';          
            den   <= '1';
            sr    <= '0';
            mc    <= '0';        
            exp   <= '0'; 
            selk  <= '1';
            ken   <= "1111";
            rot   <= "0000";
            add   <= '0';
            rcon  <= (OTHERS => '0');
            
            round <= (OTHERS => '0');
            delay <= (4 => '1', OTHERS => '0');
            
            IF (LATENCY = 0) THEN
               STATE <= S_SHIFT;
            ELSE
               STATE <= S_DELAY;
            END IF;
            
         ELSE 
            -- default assignments
            done  <= '0';
            seld  <= '0';    
            den   <= '0';
            sr    <= '0';
            mc    <= '0';
            selk  <= '0';
            ken   <= "0000";
            exp   <= '0';
            rot   <= "0000";
            add   <= '0';
            rcon  <= (OTHERS => '0');
            
            round <= round;
            delay <= delay + 1;
            
            -- case evaluation
            CASE STATE IS
               ----------------------------------------------------------------------
               WHEN S_IDLE  => 
               ----------------------------------------------------------------------
               WHEN S_SUB   => den   <= '1';
                               ken   <= "1111";
                               add   <= NOT(delay(0) AND delay(1));
                               IF (delay = 15) THEN
                                  IF (LATENCY = 0) THEN
                                     STATE <= S_SHIFT;
                                  ELSE
                                     STATE <= S_DELAY;
                                  END IF;
                               END IF;
               ----------------------------------------------------------------------
               WHEN S_INIT  => seld  <= '0';
                               den   <= '0';
                               selk  <= '0';
                               ken   <= "0000";
                               exp   <= '0';
                               rot   <= "0000";
                               delay <= delay + 1;
                               IF (delay = (15 + LATENCY)) THEN                                                              
                                  STATE <= S_SHIFT; 
                               END IF;
               ----------------------------------------------------------------------
               WHEN S_DELAY => den   <= '1';
                               IF (delay < 20) THEN
                                  ken   <= "0001";
                                  exp   <= '1';
                                  rot   <= "0001";
                               ELSE
                                  ken <= "0000";
                                  exp <= '0';
                                  rot <= "0000";
                               END IF;
                               delay <= delay + 1;
                               IF (delay = (15 + LATENCY)) THEN
                                  STATE <= S_SHIFT; 
                               END IF;
               ----------------------------------------------------------------------
               WHEN S_SHIFT => den   <= '1';
                               sr    <= '1';
                               IF (delay < 20) THEN
                                  ken   <= "1111";
                                  exp   <= '1';
                                  rot   <= "1111";
                               ELSE
                                  ken   <= "1110";
                                  exp   <= '0';
                                  rot   <= "1110";
                               END IF;
                               rcon(7 DOWNTO 0) <= const;
                               IF (ROUND = "1001") THEN
                                  STATE <= S_KEY;
                               ELSE                            
                                  STATE <= S_MIX;
                               END IF;
               ----------------------------------------------------------------------
               WHEN S_MIX   => den   <= '1';
                               mc    <= '1';
                               IF (delay < 20) THEN
                                  ken   <= "1111";
                                  exp   <= '1';
                                  rot   <= "1111";
                               ELSE
                                  ken   <= "1110";
                                  exp   <= '0';
                                  rot   <= "1110";
                               END IF;
                               IF (delay = (20 + LATENCY)) THEN
                                  ken   <= "0000";
                                  exp   <= '0';
                                  rot   <= "0000";             
                                  delay <= (OTHERS => '0');
                                  round <= round + 1;
                                  STATE <= S_SUB;
                               END IF;   
                ----------------------------------------------------------------------
                WHEN S_KEY   => IF (delay < 20) THEN
                                   ken   <= "1111";
                                   exp   <= '1';
                                   rot   <= "1111";
                                ELSE
                                   ken   <= "1110";
                                   exp   <= '0';
                                   rot   <= "1110";
                                END IF;
                                IF (delay = (20 + LATENCY)) THEN
                                   ken   <= "0000";
                                   exp   <= '0';                               
                                   delay <= (OTHERS => '0');
                                   round <= (OTHERS => '0');
                                   STATE <= S_DONE;
                                END IF;   
               ----------------------------------------------------------------------
               WHEN S_DONE  => done  <= '1';
                               den   <= '1';
                               add   <= NOT(delay(0) AND delay(1));
                               ken   <= "1111";
                               IF (delay = 15) THEN
                                  STATE <= S_IDLE; 
                               END IF;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
   -------------------------------------------------------------------------------
   
END FSM;
