library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity debug_aluregfile_tb is
end debug_aluregfile_tb;

architecture behav of debug_aluregfile_tb is
	--  Declaration of the components that will be instantiated.
	component and2
		port(
			i_A	 : in  std_logic;
			i_B	 : in  std_logic;
			o_Z	 : out std_logic
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
	component control_unit
		port(
			c_enable     	 : in  std_logic;
			i_control   	 : in  std_logic_vector (2 downto 0);
			o_regDst     	 : out std_logic;
			o_branch     	 : out std_logic;
			o_ALUOp      	 : out std_logic_vector (2 downto 0);
			o_ALUSrc     	 : out std_logic;
			o_regWrite   	 : out std_logic
		);
	end component;
	component register_file
		generic (REG_VALUE	 : integer);
		port(
			c_enable    	 : in  std_logic := '0';
			c_reset     	 : in  std_logic := '0';
			c_regWrite  	 : in  std_logic := '0';
			c_clk       	 : in  std_logic := '0';
			i_read_reg1 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_read_reg2 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_write_reg 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_write_data	 : in  std_logic_vector (REG_VALUE-1 downto 0) := (others => 'X');
			o_read_data1	 : out std_logic_vector (REG_VALUE-1 downto 0);
			o_read_data2	 : out std_logic_vector (REG_VALUE-1 downto 0)
		);
	end component;
	component alu
	    port(
	        c_enable	 : in  std_logic;
	        c_ALUOp 	 : in  std_logic_vector (2 downto 0);
	        i_A     	 : in  std_logic_vector (7 downto 0);
	        i_B     	 : in  std_logic_vector (7 downto 0);
	        o_result	 : out std_logic_vector (7 downto 0);
	        o_print 	 : out std_logic_vector (7 downto 0);
	        o_oflow 	 : out std_logic;
	        o_uflow 	 : out std_logic;
	        o_zero  	 : out std_logic
	    );
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	-- state types
	type STATE_TYPE is (reset, execute);
	signal state : STATE_TYPE := reset;
	
	-- Control signals
	signal c_enable  : std_logic := '0';
	signal c_reset   : std_logic := '1';
	signal c_regDst  : std_logic := 'X';
	signal c_branch  : std_logic := 'X';
	signal c_ALUOp   : std_logic_vector (2 downto 0) := "XXX";
	signal c_ALUSrc  : std_logic := 'X';
	signal c_regWrite: std_logic := '0';
	signal c_zero    : std_logic := '0';
	signal c_oflow   : std_logic := '0';
	signal c_uflow   : std_logic := '0';
	signal c_pc_mux_select: std_logic := '0';
	
	-- PC registers
	signal s_pc     : std_logic_vector (7 downto 0) := (others => '0');
	signal s_pc_next: std_logic_vector (7 downto 0) := (others => '0');
	-- TODO make comparator
	signal s_max_pc : std_logic_vector (1 downto 0) := "XX"; -- "00" if at max pc
	
	-- IF/ID registers
	signal s_control: std_logic_vector (2 downto 0);
	signal s_pc_plus_1: std_logic_vector (7 downto 0);
	signal s_rs : std_logic_vector (1 downto 0);
	signal s_rt : std_logic_vector (1 downto 0);
	signal s_rd : std_logic_vector (1 downto 0);
	signal s_imm: std_logic_vector (3 downto 0);
	
	-- ID/EX registers
	signal s_read_data1: std_logic_vector (7 downto 0);
	signal s_read_data2: std_logic_vector (7 downto 0);
	signal s_alu_src  : std_logic_vector (7 downto 0);
	signal s_sign_extended: std_logic_vector (7 downto 0);
	
	-- EX/WB registers
	signal s_write_reg : std_logic_vector (1 downto 0);
	signal s_write_data: std_logic_vector (7 downto 0);
	signal s_pc_plus_branch: std_logic_vector (7 downto 0);
	signal s_print: std_logic_vector (7 downto 0);
	
	-- general intermediate signals
	signal s_skip_plus_1: std_logic_vector (1 downto 0);
	signal s_skip       : std_logic;
	
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
	dst_reg_mux: mux2
		generic map (LENGTH => 2)
		port map (
			i_A  	 => s_rs,
			i_B  	 => s_rd,
			i_SEL	 => c_regDst,
			o_Z  	 => s_write_reg
		);
	alu_src_mux: mux2
		generic map (LENGTH => 8)
		port map (
			i_A  	 => s_read_data2,
			i_B  	 => s_sign_extended,
			i_SEL	 => c_ALUSrc,
			o_Z  	 => s_alu_src
		);
	sign_extend_4_to_8: sign_extend
		generic map (IN_WORD_LENGTH  => 4,
					 OUT_WORD_LENGTH => 8)
		port map (
			i_A => s_imm,
			o_Z => s_sign_extended
		);
	control_unit_0: control_unit
		port map (
			c_enable     	 => c_enable,
			i_control    	 => s_control,
			o_regDst     	 => c_regDst,
			o_branch     	 => c_branch,
			o_ALUOp      	 => c_ALUOp,
			o_ALUSrc     	 => c_ALUSrc,
			o_regWrite   	 => c_regWrite
		);
	regfile_0: register_file
		generic map (REG_VALUE => 8)
		port map(
			c_enable    	 => c_enable,
			c_reset     	 => c_reset,
			c_regWrite  	 => c_regWrite,
			c_clk       	 => clock,
			i_read_reg1 	 => s_rs,
			i_read_reg2 	 => s_rt,
			i_write_reg 	 => s_write_reg,
			i_write_data	 => s_write_data,
			o_read_data1	 => s_read_data1,
			o_read_data2	 => s_read_data2
		);
	alu_0: alu
		port map(
			c_enable	 => c_enable,
			c_ALUOp 	 => s_control,
			i_A     	 => s_read_data1,
			i_B     	 => s_alu_src,
			o_result	 => s_write_data,
			o_print 	 => s_print,
			o_oflow 	 => c_oflow,
			o_uflow 	 => c_uflow,
			o_zero  	 => c_zero
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
		wait for clock_period/2;
		
		-- setup
		c_reset <= '1'; -- all regs are 0
		c_enable <= '0';
		s_control <= "XXX";
		s_rs <= "XX";
		s_rt <= "XX";
		s_rd <= "XX";
		s_imm <= "XXXX";
		wait for clock_period;
		
		
		-- 1st instruction: print 00 (11000001)
		report "instruction 1100 0001 (print 00)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "111";
		s_rs <= "00";
		s_rt <= "00";
		s_rd <= "01";
		s_imm <= "0001";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 1" severity error;
		end if;
		
		report "PRINT (expect 00000000): " & to_bstring(s_print) severity note;
		
		
		-- 2nd instruction: load 0011 into 00 (00000011)
		report "instruction 0000 0011 (load 00, 0011)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "001";
		s_rs <= "00";
		s_rt <= "00";
		s_rd <= "11";
		s_imm <= "0011";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 2" severity error;
		end if;
		
		report "PRINT (expect 00000000): " & to_bstring(s_print) severity note;
		
		
		-- 3rd instruction: print 00 (11000001)
		report "instruction 1100 0001 (print 00)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "111";
		s_rs <= "00";
		s_rt <= "00";
		s_rd <= "01";
		s_imm <= "0001";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 3" severity error;
		end if;
		
		report "PRINT (expect 00000011): " & to_bstring(s_print) severity note;
		
		
		-- 4th instruction: load 11111000 into 10 (00101000)
		report "instruction 0010 1000 (load 10, 1000)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "000";
		s_rs <= "10";
		s_rt <= "10";
		s_rd <= "00";
		s_imm <= "1000";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 4" severity error;
		end if;
		
		report "PRINT (expect 00000011): " & to_bstring(s_print) severity note;
		
		
		-- 5th instruction: print 10 (11100001)
		report "instruction 1110 0001 (print 10)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "111";
		s_rs <= "10";
		s_rt <= "00";
		s_rd <= "01";
		s_imm <= "0001";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 5" severity error;
		end if;
		
		report "PRINT (expect 11111000): " & to_bstring(s_print) severity note;
		
		
		-- 6th instruction: add 00 + 00 => 00 (01000000)
		report "instruction 0100 0000 (add 00, 00, [00])" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "010";
		s_rs <= "00";
		s_rt <= "00";
		s_rd <= "00";
		s_imm <= "0000";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 6" severity error;
		end if;
		
		report "PRINT (expect 11111000): " & to_bstring(s_print) severity note;
		
		
		-- 7th instruction: print 00 (11000001)
		report "instruction 1100 0001 (print 00)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "111";
		s_rs <= "00";
		s_rt <= "00";
		s_rd <= "01";
		s_imm <= "0001";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 7" severity error;
		end if;
		
		report "PRINT (expect 00000110): " & to_bstring(s_print) severity note;
		
		
		-- 8th instruction: skip 0, 00 vs 00 (11000000)
		report "instruction 1100 0000 (skip 0, 00 vs 00)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "110";
		s_rs <= "00";
		s_rt <= "00";
		s_rd <= "00";
		s_imm <= "0000";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '1' /= c_zero then
			assert false report "bad output value 8" severity error;
		end if;
		
		report "PRINT (expect 00000110): " & to_bstring(s_print) severity note;
		report "c_zero (expect 1): " & to_bstring(c_zero) severity note;
		
		
		-- 9th instruction: skip 0, 00 vs 01 (11000100)
		report "instruction 1100 0100 (skip 0, 00 vs 00)" severity note;
		c_reset <= '0';
		c_enable <= '1';
		s_control <= "110";
		s_rs <= "00";
		s_rt <= "01";
		s_rd <= "00";
		s_imm <= "0100";
		wait for clock_period;
		if '0' /= c_oflow or '0' /= c_uflow or '0' /= c_zero then
			assert false report "bad output value 9" severity error;
		end if;
		
		report "PRINT (expect 00000110): " & to_bstring(s_print) severity note;
		report "c_zero (expect 0): " & to_bstring(c_zero) severity note;
		
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
