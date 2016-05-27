library ieee;
use ieee.std_logic_1164.all;

-- Control Unit
-- 	 regDst   - 0 (instruction(5 downto 4)) for load (Rs)
-- 	            1 (instruction(1 downto 0)) for add and sub (Rd)
-- 	            X for all others (i.e., beq/skip and print)
-- 	 branch   - 0 for load, add, sub, and print (i.e., all except beq/skip)
-- 	            1 for beq/skip
-- 	 ALUOp    - 000 for load
-- 	            010 for add
-- 	            100 for sub
-- 	            110 for beq/skip
-- 	            111 for print
-- 	 ALUSrc   - 0 (read data 2) for add, sub, and beq/skip
-- 	            1 (sign extended immediate) for load
-- 	            X for print
-- 	 regWrite - 0 (do nothing) for beq/skip and print
-- 	            1 (write) for load, add, and sub
entity control_unit is
	port(
		-- Control Signals
		c_enable 	 : in  std_logic;
		
		-- Input Instruction
		i_control 	 : in  std_logic_vector (2 downto 0);
		
		-- Outputs
		o_regDst  	 : out std_logic := 'X';
		o_branch  	 : out std_logic := '0';
		o_ALUOp   	 : out std_logic_vector (2 downto 0) := "XXX";
		o_ALUSrc  	 : out std_logic := 'X';
		o_regWrite	 : out std_logic := '0'
	);
end control_unit;

architecture structural of control_unit is
	
	-- state types
	type STATE_TYPE is (load, add, sub, print, beq, noop);
	
begin
	
	-- logic below
	process (c_enable, i_control) is
		variable state : STATE_TYPE;
	begin
		if c_enable = '1' then
			
			state_machine_case: case i_control(2 downto 1) is
				when "00"	=> state := load;
				when "01"	=> state := add;
				when "10"	=> state := sub;
				when "11"	=>
					special_state_case: case i_control(0) is
						when '0'	=> state := beq;
						when '1'	=> state := print;
						when others	=> state := noop;
					end case special_state_case;
				when others	=> state := noop;
			end case state_machine_case;
			
			logic_case: case state is
				when load =>
					o_regDst  	 <= '0';
					o_branch  	 <= '0';
					o_ALUOp   	 <= "000";
					o_ALUSrc  	 <= '1';
					o_regWrite	 <= '1';
				when add =>
					o_regDst  	 <= '1';
					o_branch  	 <= '0';
					o_ALUOp   	 <= "010";
					o_ALUSrc  	 <= '0';
					o_regWrite	 <= '1';
				when sub =>
					o_regDst  	 <= '1';
					o_branch  	 <= '0';
					o_ALUOp   	 <= "100";
					o_ALUSrc  	 <= '0';
					o_regWrite	 <= '1';
				when beq =>
					o_regDst  	 <= 'X';
					o_branch  	 <= '1';
					o_ALUOp   	 <= "110";
					o_ALUSrc  	 <= '0';
					o_regWrite	 <= '0';
				when print =>
					o_regDst  	 <= 'X';
					o_branch  	 <= '0';
					o_ALUOp   	 <= "111";
					o_ALUSrc  	 <= 'X';
					o_regWrite	 <= '0';
				when noop =>
					o_regDst  	 <= 'X';
					o_branch  	 <= '0';
					o_ALUOp   	 <= "XXX";
					o_ALUSrc  	 <= 'X';
					o_regWrite	 <= '0';
			end case logic_case;
			
		end if;
	end process;
	
end structural;
