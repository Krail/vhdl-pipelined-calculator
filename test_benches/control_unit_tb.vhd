library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity control_unit_tb is
end control_unit_tb;

architecture behav of control_unit_tb is
	--  Declaration of the component that will be instantiated.
	component control_unit
		port(
			c_enable     	 : in  std_logic;
			i_control    	 : in  std_logic_vector (2 downto 0);
			o_regDst     	 : out std_logic;
			o_branch     	 : out std_logic;
			o_ALUOp      	 : out std_logic_vector (2 downto 0);
			o_ALUSrc     	 : out std_logic;
			o_regWrite   	 : out std_logic
		);
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	signal s_enable     	 : std_logic := '0';
	signal s_control    	 : std_logic_vector (2 downto 0) := (others => 'X');
	signal s_regDst     	 : std_logic;
	signal s_branch     	 : std_logic;
	signal s_ALUOp      	 : std_logic_vector (2 downto 0);
	signal s_ALUSrc     	 : std_logic;
	signal s_regWrite   	 : std_logic;
	
	-- Predefined Instructions
	signal load 	 : std_logic_vector (2 downto 0) := "00X";
	signal add  	 : std_logic_vector (2 downto 0) := "01X";
	signal sub  	 : std_logic_vector (2 downto 0) := "10X";
	signal beq  	 : std_logic_vector (2 downto 0) := "110";
	signal print 	 : std_logic_vector (2 downto 0) := "111";
	
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	control_unit_0: control_unit
		port map (
			c_enable     	 => s_enable,
			i_control    	 => s_control,
			o_regDst     	 => s_regDst,
			o_branch     	 => s_branch,
			o_ALUOp      	 => s_ALUOp,
			o_ALUSrc     	 => s_ALUSrc,
			o_regWrite   	 => s_regWrite
		);
		
	-- Clock process definitions
	clock_process: process
	begin
		if end_of_sim = '0' then
			clock <= '0';
			wait for clock_period/2;
			clock <= '1';
			wait for clock_period/2;
		else
			wait;
		end if;
	end process clock_process;
	
	-- Stimulus process
	stim_proc: process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
		wait for clock_period*10;
		
		
		-- setup
		s_enable <= '1';
		
		-- test undefined
		wait for clock_period;
		if
				   'X'   /= s_regDst
				or '0'   /= s_branch
				or "XXX" /= s_ALUOp
				or 'X'   /= s_ALUSrc
				or '0'   /= s_regWrite then
			assert false report "bad output value undefined" severity error;
		end if;
		
		-- test load
		s_control <= load;
		wait for clock_period;
		if
				   '0'   /= s_regDst
				or '0'   /= s_branch
				or "000" /= s_ALUOp
				or '1'   /= s_ALUSrc
				or '1'   /= s_regWrite then
			assert false report "bad output value load" severity error;
		end if;
		
		-- test add
		s_control <= add;
		wait for clock_period;
		if
				   '1'   /= s_regDst
				or '0'   /= s_branch
				or "010" /= s_ALUOp
				or '0'   /= s_ALUSrc
				or '1'   /= s_regWrite then
			assert false report "bad output value add" severity error;
		end if;
		
		-- test sub
		s_control <= sub;
		wait for clock_period;
		if
				   '1'   /= s_regDst
				or '0'   /= s_branch
				or "100" /= s_ALUOp
				or '0'   /= s_ALUSrc
				or '1'   /= s_regWrite then
			assert false report "bad output value sub" severity error;
		end if;
		
		-- test beq/skip
		s_control <= beq;
		wait for clock_period;
		if
				   'X'   /= s_regDst
				or '1'   /= s_branch
				or "110" /= s_ALUOp
				or '0'   /= s_ALUSrc
				or '0'   /= s_regWrite then
			assert false report "bad output value beq/skip" severity error;
		end if;
		
		-- test print
		s_control <= print;
		wait for clock_period;
		if
				   'X'   /= s_regDst
				or '0'   /= s_branch
				or "111" /= s_ALUOp
				or 'X'   /= s_ALUSrc
				or '0'   /= s_regWrite then
			assert false report "bad output value print" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
