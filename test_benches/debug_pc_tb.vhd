library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity debug_pc_tb is
end debug_pc_tb;

architecture behav of debug_pc_tb is
	--  Declaration of the components that will be instantiated.
	component add2
		generic (LENGTH : integer);
		port(
			c_op  	 : in  std_logic;
			i_A   	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B   	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_Z   	 : out std_logic_vector (LENGTH-1 downto 0) := (others => 'X');
			o_flow	 : out std_logic
		);
	end component;
	component and2
		port(
			i_A	 : in  std_logic;
			i_B	 : in  std_logic;
			o_Z	 : out std_logic
		);
	end component;
	component comparator2
		generic (LENGTH : integer);
		port(
			i_A	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_A	 : out std_logic_vector (LENGTH-1 downto 0);
			o_Z	 : out std_logic_vector (1 downto 0)
		);
	end component;
	component mux2
		generic (LENGTH : integer);
		port(
			i_A   : in  std_logic_vector (LENGTH-1 downto 0);
			i_B   : in  std_logic_vector (LENGTH-1 downto 0);
			i_SEL : in  std_logic := 'X';
			o_Z   : out std_logic_vector (LENGTH-1 downto 0) := (others => 'X')
		);
	end component;
	component sign_extend
		generic (IN_WORD_LENGTH  : integer;
				 OUT_WORD_LENGTH : integer);
		port(
			i_A   : in  std_logic_vector (IN_WORD_LENGTH-1 downto 0);
			o_Z   : out std_logic_vector (OUT_WORD_LENGTH-1 downto 0) := (others => 'X')
		);
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	-- Control signals
	signal c_branch  : std_logic := 'X';
	signal c_zero    : std_logic := '0';
	signal c_pc_mux_select: std_logic := '0';
	
	-- PC registers
	signal s_pc     : std_logic_vector (7 downto 0) := (others => '0');
	signal s_pc_next_buffer: std_logic_vector (7 downto 0) := (others => '0');
	signal s_pc_next: std_logic_vector (7 downto 0) := (others => '0');
	signal s_num_instructions : std_logic_vector (7 downto 0) := (others => '0');
	signal s_max_pc : std_logic_vector (1 downto 0) := "XX"; -- "00" if at max pc
	signal s_pc_plus_1: std_logic_vector (7 downto 0);
	signal s_skip_plus_1: std_logic_vector (1 downto 0);
	
	-- IF/ID registers
	signal s_imm: std_logic_vector (3 downto 0);
	
	-- ID/EX registers
	signal s_sign_extended: std_logic_vector (7 downto 0);
	
	-- EX/WB registers
	signal s_pc_plus_branch: std_logic_vector (7 downto 0);
	
	-- Clock period definitions
	constant clock_period : time := 10 ns;
	
	
	function to_bstring(sl : std_logic) return string is
	  variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
	begin
	  sl_str_v := std_logic'image(sl);
	  return "" & sl_str_v(2);  -- "" & character to get string
	end function;
	function to_bstring(slv : std_logic_vector) return string is
	  alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
	  variable sl_str_v : string(1 to 1);  -- String of std_logic
	  variable res_v    : string(1 to slv'length);
	begin
	  for idx in slv_norm'range loop
	    sl_str_v := to_bstring(slv_norm(idx));
	    res_v(idx) := sl_str_v(1);
	  end loop;
	  return res_v;
	end function;
	
	
begin

	branch_and_gate: and2
		port map (
			i_A	 => c_branch,
			i_B	 => c_zero,
			o_Z	 => c_pc_mux_select
		);
	pc_src_mux: mux2
		generic map (LENGTH => 8)
		port map (
			i_A  	 => s_pc_plus_1,
			i_B  	 => s_pc_plus_branch,
			i_SEL	 => c_pc_mux_select,
			o_Z  	 => s_pc_next_buffer
		);
	pc_adder: add2
	generic map (LENGTH => 8)
	port map (
		c_op  	 => '0',
		i_A => s_pc,
		i_B   	 => "00000001",
		o_Z => s_pc_plus_1,
		o_flow	 => open -- TODO on overflow, set s_max_pc high
	);
	branch_adder: add2
		generic map (LENGTH => 8)
		port map (
			c_op  	 => '0',
			i_A => s_pc_plus_1,
			i_B(7 downto 2) => "000000",
			i_B(1 downto 0) => s_skip_plus_1,
			o_Z => s_pc_plus_branch,
			o_flow	 => open  -- TODO on overflow, set s_max_pc high
		);
	skip_adder: add2
		generic map (LENGTH => 2)
		port map (
			c_op  	 => '0',
			i_A(1)	 => '0',
			i_A(0)	 => s_sign_extended(1),
			i_B   	 => "01",
			o_Z   	 => s_skip_plus_1,
			o_flow	 => open
		);
	max_pc_comparator: comparator2
		generic map (LENGTH => 8)
		port map (
			i_A   	 => s_pc_next_buffer,  -- not sure if this is right
			i_B   	 => s_num_instructions,
			o_A   	 => s_pc_next,
			o_Z   	 => s_max_pc
		);
	sign_extend_4_to_8: sign_extend
		generic map (IN_WORD_LENGTH  => 4,
					 OUT_WORD_LENGTH => 8)
		port map (
			i_A => s_imm,
			o_Z => s_sign_extended
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
		wait for clock_period/2; -- clock is low while setting signals
		
		
		-- setup
		s_num_instructions <= "00001000";
		
		
		-- # instruction (pc = #) (beq?, zero?, skip2?)
		
		
		-- Not BEQ/SKIP instruction
		
		-- 1st instruction (pc = 0) (0,0,0)
		s_pc <= x"00";
		c_branch <= '0';
		c_zero <= '0';
		s_imm <= "0000";
		wait for clock_period;
		if '0' /= c_pc_mux_select
				or "00000000" /= s_pc
				or "00000001" /= s_pc_next
				or "10" /= s_max_pc then
			assert false report "bad output value 1" severity error;
		end if;
		
		
		-- 2nd instruction (pc = 1) (0,0,1)
		s_pc <= s_pc_next;
		c_branch <= '0';
		c_zero <= '0';
		s_imm <= "0010";
		wait for clock_period;
		if '0' /= c_pc_mux_select
				or "00000001" /= s_pc
				or "00000010" /= s_pc_next
				or "10" /= s_max_pc then
			assert false report "bad output value 2" severity error;
		end if;
		
		
		-- 3rd instruction (pc = 2) (0,1,0)
		s_pc <= s_pc_next;
		c_branch <= '0';
		c_zero <= '1';
		s_imm <= "0000";
		wait for clock_period;
		if '0' /= c_pc_mux_select
				or "00000010" /= s_pc
				or "00000011" /= s_pc_next
				or "10" /= s_max_pc then
			assert false report "bad output value 3" severity error;
		end if;
		
		
		-- 4th instruction (pc = 3) (0,1,1)
		s_pc <= s_pc_next;
		c_branch <= '0';
		c_zero <= '1';
		s_imm <= "0010";
		wait for clock_period;
		if '0' /= c_pc_mux_select
				or "00000011" /= s_pc
				or "00000100" /= s_pc_next
				or "10" /= s_max_pc then
			assert false report "bad output value 4" severity error;
		end if;
		
		
		
		-- BEQ/SKIP instruction
		
		-- 5th instruction (pc = 4) (1,0,0)
		s_pc <= s_pc_next;
		c_branch <= '1';
		c_zero <= '0';
		s_imm <= "0000";
		wait for clock_period;
		if '0' /= c_pc_mux_select
				or "00000100" /= s_pc
				or "00000101" /= s_pc_next
				or "10" /= s_max_pc then
			assert false report "bad output value 5" severity error;
		end if;
		
		
		-- 6th instruction (pc = 5) (1,0,1)
		s_pc <= s_pc_next;
		c_branch <= '1';
		c_zero <= '0';
		s_imm <= "0010";
		wait for clock_period;
		if '0' /= c_pc_mux_select
				or "00000101" /= s_pc
				or "00000110" /= s_pc_next
				or "10" /= s_max_pc then
			assert false report "bad output value 6" severity error;
		end if;
		
		
		-- skip 1
		
		-- 7th instruction (pc = 6) (1,1,0)
		s_pc <= s_pc_next;
		c_branch <= '1';
		c_zero <= '1';
		s_imm <= "0000";
		wait for clock_period;
		if '1' /= c_pc_mux_select
				or "00000110" /= s_pc
				or "00001000" /= s_pc_next
				or "00" /= s_max_pc then
			assert false report "bad output value 7" severity error;
		end if;
		
		
		-- skip 2
		
		-- 9th instruction (pc = 7) (1,1,1)
		s_pc <= s_pc_next;
		c_branch <= '1';
		c_zero <= '1';
		s_imm <= "0010";
		wait for clock_period;
		if '1' /= c_pc_mux_select
				or "00001000" /= s_pc
				or "00001011" /= s_pc_next
				or "01" /= s_max_pc then
			assert false report "bad output value 9" severity error;
		end if;
		
		
		-- 12th instruction (pc = 7) (0,0,0)
		s_pc <= s_pc_next;
		c_branch <= '0';
		c_zero <= '0';
		s_imm <= "0000";
		wait for clock_period;
		if '0' /= c_pc_mux_select
				or "00001011" /= s_pc
				or "00001100" /= s_pc_next
				or "01" /= s_max_pc then
			assert false report "bad output value 12" severity error;
		end if;
		
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
