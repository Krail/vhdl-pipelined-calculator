library ieee;
use ieee.std_logic_1164.all;

entity calculator is 
	port(
		clk               	 : in  std_logic;
		i_reset           	 : in  std_logic;
		i_enable          	 : in  std_logic;
		i_num_instructions	 : in  std_logic_vector (7 downto 0);
		i_instruction	  	 : in  std_logic_vector (7 downto 0);
		o_pc              	 : out std_logic_vector (7 downto 0);
		o_print           	 : out std_logic_vector (7 downto 0)
	);
end calculator;

architecture structural of calculator is
	
	-- Pipeline Registers
	component if_id
		port (
			c_clk   	 : in  std_logic;
			c_enable	 : in  std_logic;
			c_reset 	 : in  std_logic;
			c_flush 	 : in  std_logic;
			i_pc_plus_1  	 : in  std_logic_vector(7 downto 0);
			i_instruction	 : in  std_logic_vector(7 downto 0);
			o_pc_plus_1  	 : out std_logic_vector(7 downto 0);
			o_instruction	 : out std_logic_vector(7 downto 0)
		);
	end component;
	component id_ex
		port (
			c_clk   	 : in  std_logic;
			c_enable	 : in  std_logic;
			c_reset 	 : in  std_logic;
			c_flush 	 : in  std_logic;
			i_regDst  	 : in  std_logic;
			i_branch  	 : in  std_logic;
			i_ALUOp   	 : in  std_logic_vector(2 downto 0);
			i_ALUSrc  	 : in  std_logic;
			i_regWrite	 : in  std_logic;
			i_pc_plus_1    	 : in  std_logic_vector(7 downto 0);
			i_read_data1   	 : in  std_logic_vector(7 downto 0);
			i_read_data2   	 : in  std_logic_vector(7 downto 0);
			i_rs           	 : in  std_logic_vector(1 downto 0);
			i_rd           	 : in  std_logic_vector(1 downto 0);
			i_sign_extended	 : in  std_logic_vector(7 downto 0);
			o_regDst  	 : out std_logic := 'X';
			o_branch  	 : out std_logic := '0';
			o_ALUOp   	 : out std_logic_vector(2 downto 0) := "XXX";
			o_ALUSrc  	 : out std_logic := 'X';
			o_regWrite	 : out std_logic := '0';
			o_pc_plus_1    	 : out std_logic_vector(7 downto 0) := (others => '0');
			o_read_data1   	 : out std_logic_vector(7 downto 0) := (others => 'X');
			o_read_data2   	 : out std_logic_vector(7 downto 0) := (others => 'X');
			o_rs           	 : out std_logic_vector(1 downto 0) := (others => 'X');
			o_rd           	 : out std_logic_vector(1 downto 0) := (others => 'X');
			o_sign_extended	 : out std_logic_vector(7 downto 0) := (others => 'X')
		);
	end component;
	component ex_wb
		port (
			c_clk   	 : in  std_logic;
			c_enable	 : in  std_logic;
			c_reset 	 : in  std_logic;
			c_flush 	 : in  std_logic;
			i_branch  	 : in  std_logic;
			i_regWrite	 : in  std_logic;
			i_pc_plus_1_plus_branch	 : in  std_logic_vector(7 downto 0);
			i_zero                 	 : in  std_logic;
			i_write_data           	 : in  std_logic_vector (7 downto 0);
			i_write_reg            	 : in  std_logic_vector (1 downto 0);
			o_branch  	 : out std_logic;
			o_regWrite	 : out std_logic;
			o_pc_plus_1_plus_branch	 : out std_logic_vector(7 downto 0);
			o_zero                 	 : out std_logic;
			o_write_data           	 : out std_logic_vector (7 downto 0);
			o_write_reg            	 : out std_logic_vector (1 downto 0)
		);
	end component;
	
	-- components used
	component add2
		generic (LENGTH : integer);
		port(
			c_op  	 : in  std_logic;
			i_A   	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B   	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_Z   	 : out std_logic_vector (LENGTH-1 downto 0);
			o_flow	 : out std_logic
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
			o_Z   : out std_logic_vector (LENGTH-1 downto 0)
		);
	end component;
	component sign_extend
		generic (IN_WORD_LENGTH  : integer;
				 OUT_WORD_LENGTH : integer);
		port(
			i_A   : in  std_logic_vector (IN_WORD_LENGTH-1 downto 0);
			o_Z   : out std_logic_vector (OUT_WORD_LENGTH-1 downto 0)
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
			c_reset     	 : in  std_logic := '1';
			c_regWrite  	 : in  std_logic := '0';
			c_clk       	 : in  std_logic := '0';
			i_read_reg1 	 : in  std_logic_vector (1 downto 0);
			i_read_reg2 	 : in  std_logic_vector (1 downto 0);
			i_write_reg 	 : in  std_logic_vector (1 downto 0);
			i_write_data	 : in  std_logic_vector (REG_VALUE-1 downto 0);
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
	
	
	-- Control signals
	signal c_enable	 : std_logic := '0';
	signal c_reset 	 : std_logic := '1';
	signal c_flush 	 : std_logic := '1';
	
	
	------------------------------------------------------------------------
	-- Instruction Fetch Signals
	------------------------------------------------------------------------
	-- PC signals
	signal s_num_instructions	 : std_logic_vector(7 downto 0) := x"00";
	signal s_pc              	 : std_logic_vector(7 downto 0) := x"00";
	signal s_if_pc_plus_1    	 : std_logic_vector(7 downto 0) := x"00";
	
	------------------------------------------------------------------------
	-- Instruction Decode Signals
	------------------------------------------------------------------------
	-- Control signals
	signal c_id_regDst  	 : std_logic;
	signal c_id_branch  	 : std_logic;
	signal c_id_ALUOp   	 : std_logic_vector(2 downto 0);
	signal c_id_ALUSrc  	 : std_logic;
	signal c_id_regWrite	 : std_logic;
	-- PC signals
	signal s_id_pc_plus_1	 : std_logic_vector(7 downto 0);
	-- Instruction signals
	signal s_id_instruction	 : std_logic_vector(7 downto 0);
	signal s_control       	 : std_logic_vector(2 downto 0);
	signal s_id_rs         	 : std_logic_vector(1 downto 0);
	signal s_rt            	 : std_logic_vector(1 downto 0);
	signal s_id_rd         	 : std_logic_vector(1 downto 0);
	signal s_imm           	 : std_logic_vector(3 downto 0);
	-- Register file signals
	signal c_regfile_clk     	 : std_logic;
	signal s_id_read_data1   	 : std_logic_vector(7 downto 0);
	signal s_id_read_data2   	 : std_logic_vector(7 downto 0);
	signal s_id_sign_extended	 : std_logic_vector(7 downto 0);
	
	------------------------------------------------------------------------
	-- Execute Signals
	------------------------------------------------------------------------
	-- Control signals
	signal c_ex_regDst  	 : std_logic;
	signal c_ex_branch  	 : std_logic;
	signal c_ex_ALUOp   	 : std_logic_vector(2 downto 0);
	signal c_ex_ALUSrc  	 : std_logic;
	signal c_ex_regWrite	 : std_logic;
	signal c_ex_zero    	 : std_logic;
	signal c_oflow      	 : std_logic;
	signal c_uflow      	 : std_logic;
	-- PC signals
	signal s_ex_pc_plus_1            	 : std_logic_vector(7 downto 0);
	signal s_skip_plus_1             	 : std_logic_vector(1 downto 0);
	signal s_ex_pc_plus_1_plus_branch	 : std_logic_vector(7 downto 0);
	-- ALU signals
	signal s_ex_read_data1   	 : std_logic_vector(7 downto 0);
	signal s_ex_read_data2   	 : std_logic_vector(7 downto 0);
	signal s_ex_sign_extended	 : std_logic_vector(7 downto 0);
	signal s_alu_src         	 : std_logic_vector(7 downto 0);
	-- Register file signals
	signal s_ex_rs        	 : std_logic_vector(1 downto 0);
	signal s_ex_rd        	 : std_logic_vector(1 downto 0);
	signal s_ex_write_reg 	 : std_logic_vector(1 downto 0);
	signal s_ex_write_data	 : std_logic_vector(7 downto 0);
	
	------------------------------------------------------------------------
	-- Writeback Signals
	------------------------------------------------------------------------
	-- Control signals
	signal c_wb_branch  	 : std_logic;
	signal c_wb_regWrite	 : std_logic;
	signal c_wb_zero    	 : std_logic;
	-- PC signals
	signal s_wb_pc_plus_1_plus_branch	 : std_logic_vector(7 downto 0);
	signal c_pc_mux_select           	 : std_logic;
	signal s_pc_next_buffer          	 : std_logic_vector(7 downto 0);
	signal s_pc_next                 	 : std_logic_vector(7 downto 0);
	signal s_max_pc                  	 : std_logic_vector(1 downto 0);
	-- Register file signals
	signal s_wb_write_reg 	 : std_logic_vector (1 downto 0);
	signal s_wb_write_data	 : std_logic_vector (7 downto 0);
	
	------------------------------------------------------------------------
	
	
	
	-- Jose showed us this
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
	
	-- Ours
	function is_valid(i_vector : std_logic_vector) return boolean is
	begin
		for i in i_vector'range loop
			if i_vector(i) /= '0' and i_vector(i) /= '1' then
				return false;
			end if;
		end loop;
		return true;
	end function;
	
	
begin
	
	------------------------------------------------------------------------
	--  IF Components
	------------------------------------------------------------------------
	max_pc_comparator: comparator2
		generic map (LENGTH => 8)
		port map (
			i_A	 => s_pc_next_buffer,
			i_B	 => s_num_instructions,
			o_A	 => s_pc_next,
			o_Z	 => s_max_pc
		);
	pc_src_mux: mux2
		generic map (LENGTH => 8)
		port map (
			i_A  	 => s_if_pc_plus_1,
			i_B  	 => s_wb_pc_plus_1_plus_branch,
			i_SEL	 => c_pc_mux_select,
			o_Z  	 => s_pc_next_buffer
		);
	pc_adder: add2
		generic map (LENGTH => 8)
		port map (
			c_op  	 => '0',
			i_A   	 => s_pc,
			i_B   	 => x"01",
			o_Z   	 => s_if_pc_plus_1,
			o_flow	 => open  -- TODO on overflow, set s_max_pc high
		);
	------------------------------------------------------------------------
	if_id_regs : if_id
		port map (
			c_clk   	 => clk,
			c_enable	 => c_enable,
			c_reset 	 => c_reset,
			c_flush 	 => c_flush,
			i_pc_plus_1  	 => s_if_pc_plus_1,
			i_instruction	 => i_instruction,
			o_pc_plus_1  	 => s_id_pc_plus_1,
			o_instruction	 => s_id_instruction
		);
	------------------------------------------------------------------------
	--  ID Components
	------------------------------------------------------------------------
	control_unit_0: control_unit
		port map (
			c_enable  	 => c_enable,
			i_control 	 => s_control,
			o_regDst  	 => c_id_regDst,
			o_branch  	 => c_id_branch,
			o_ALUOp   	 => c_id_ALUOp,
			o_ALUSrc  	 => c_id_ALUSrc,
			o_regWrite	 => c_id_regWrite
		);
	regfile_0: register_file
		generic map (REG_VALUE => 8)
		port map(
			c_enable    	 => c_enable,
			c_reset     	 => c_reset,
			c_regWrite  	 => c_wb_regWrite,
			c_clk       	 => c_regfile_clk,
			i_read_reg1 	 => s_id_rs,
			i_read_reg2 	 => s_rt,
			i_write_reg 	 => s_wb_write_reg,
			i_write_data	 => s_wb_write_data,
			o_read_data1	 => s_id_read_data1,
			o_read_data2	 => s_id_read_data2
		);
	sign_extend_4_to_8: sign_extend
		generic map (IN_WORD_LENGTH  => 4,
					 OUT_WORD_LENGTH => 8)
		port map (
			i_A	 => s_imm,
			o_Z	 => s_id_sign_extended
		);
	------------------------------------------------------------------------
	id_ex_regs : id_ex
		port map (
			c_clk   	 => clk,
			c_enable	 => c_enable,
			c_reset 	 => c_reset,
			c_flush 	 => c_id_regDst,
			i_regDst  	 => c_id_regDst,
			i_branch  	 => c_id_branch,
			i_ALUOp   	 => c_id_ALUOp,
			i_ALUSrc  	 => c_id_ALUSrc,
			i_regWrite	 => c_id_regWrite,
			i_pc_plus_1    	 => s_id_pc_plus_1,
			i_read_data1   	 => s_id_read_data1,
			i_read_data2   	 => s_id_read_data2,
			i_rs           	 => s_id_rs,
			i_rd           	 => s_id_rd,
			i_sign_extended	 => s_id_sign_extended,
			o_regDst  	 => c_ex_regDst,
			o_branch  	 => c_ex_branch,
			o_ALUOp   	 => c_ex_ALUOp,
			o_ALUSrc  	 => c_ex_ALUSrc,
			o_regWrite	 => c_ex_regWrite,
			o_pc_plus_1    	 => s_ex_pc_plus_1,
			o_read_data1   	 => s_ex_read_data1,
			o_read_data2   	 => s_ex_read_data2,
			o_rs           	 => s_ex_rs,
			o_rd           	 => s_ex_rd,
			o_sign_extended	 => s_ex_sign_extended
		);
	------------------------------------------------------------------------
	--  EX Components
	------------------------------------------------------------------------
	branch_adder: add2
		generic map (LENGTH => 8)
		port map (
			c_op           	 => '0',
			i_A            	 => s_ex_pc_plus_1,
			i_B(7 downto 2)	 => "000000",
			i_B(1 downto 0)	 => s_skip_plus_1,
			o_Z            	 => s_ex_pc_plus_1_plus_branch,
			o_flow         	 => open  -- TODO on overflow, set s_max_pc high
		);
	skip_adder: add2
		generic map (LENGTH => 2)
		port map (
			c_op  	 => '0',
			i_A(1)	 => '0',
			i_A(0)	 => s_ex_sign_extended(1),
			i_B   	 => "01",
			o_Z   	 => s_skip_plus_1,
			o_flow	 => open
		);
	alu_0: alu
		port map(
			c_enable  => c_enable,
			c_ALUOp   => c_ex_ALUOp,
			i_A       => s_ex_read_data1,
			i_B       => s_alu_src,
			o_result  => s_ex_write_data,
			o_print   => o_print,
			o_oflow   => c_oflow,
			o_uflow   => c_uflow,
			o_zero    => c_ex_zero
		);
	alu_src_mux: mux2
		generic map (LENGTH => 8)
		port map (
			i_A  	 => s_ex_read_data2,
			i_B  	 => s_ex_sign_extended,
			i_SEL	 => c_ex_ALUSrc,
			o_Z  	 => s_alu_src
		);
	dst_reg_mux: mux2
		generic map (LENGTH => 2)
		port map (
			i_A  	 => s_ex_rs,
			i_B  	 => s_ex_rd,
			i_SEL	 => c_ex_regDst,
			o_Z  	 => s_ex_write_reg
		);
	------------------------------------------------------------------------
	ex_wb_regs : ex_wb
		port map (
			c_clk   	 => clk,
			c_enable	 => c_enable,
			c_reset 	 => c_reset,
			c_flush 	 => c_flush,
			i_branch  	 => c_ex_branch,
			i_regWrite	 => c_ex_regWrite,
			i_pc_plus_1_plus_branch	 => s_ex_pc_plus_1_plus_branch,
			i_zero                 	 => c_ex_zero,
			i_write_data           	 => s_ex_write_data,
			i_write_reg            	 => s_ex_write_reg,
			o_branch  	 => c_wb_branch,
			o_regWrite	 => c_wb_regWrite,
			o_pc_plus_1_plus_branch	 => s_wb_pc_plus_1_plus_branch,
			o_zero                 	 => c_wb_zero,
			o_write_data           	 => s_wb_write_data,
			o_write_reg            	 => s_wb_write_reg
		);
	------------------------------------------------------------------------
	--  WB Components
	------------------------------------------------------------------------
	branch_and_gate: and2
		port map (
			i_A	 => c_wb_branch,
			i_B	 => c_wb_zero,
			o_Z	 => c_pc_mux_select
		);
	------------------------------------------------------------------------
	
	
	
	s_control <= s_id_instruction(7 downto 6) & s_id_instruction(0);
	s_id_rs      <= s_id_instruction(5 downto 4);
	s_rt      <= s_id_instruction(3 downto 2);
	s_id_rd      <= s_id_instruction(1 downto 0);
	s_imm     <= s_id_instruction(3 downto 0);
	
	
	
	
	
	
	-- logic below
	process (clk, i_enable, i_reset) is
	begin
		if i_reset = '1' then
			c_regfile_clk <= '0';  -- set register file's clock low
			c_enable <= '0';
			c_reset <= '1';
			c_flush <= '1';
			-- update pc
			s_num_instructions <= i_num_instructions;
			s_pc <= x"00";
			
		else
			if rising_edge(clk) then
				
				if i_enable = '1' and is_valid(i_instruction) then
					-- check pc
					if not (s_max_pc = "10") then
						-- disable calculator
						c_enable <= '0';
					else
						-- enable calculator
						c_enable <= '1';
						c_reset <= '0';
					
						if c_pc_mux_select = '1' then
							c_flush <= '1';
						end if;
					
						-- decode instruction
						c_regfile_clk <= '1';  -- read from regfile (set regfile's clock high)
					
						-- update pc
						s_pc <= s_pc_next;
					
					end if;
				else
					-- disable calculator
					c_enable <= '0';
				end if;
			end if;
			if falling_edge(clk) then
				c_regfile_clk <= '0';  -- set register file's clock low
				c_flush <= '0';
				if c_enable = '1' and is_valid(s_id_instruction) then
					report "  "&to_bstring(s_pc)&"  "&to_bstring(s_id_instruction) severity note;
				end if;
			end if;
		end if;
	end process;
	
	
	-- Update o_pc when s_pc_next changes
	process (s_pc_next, s_max_pc) is
	begin
		if c_enable = '1' and (s_max_pc = "10") then
			o_pc <= s_pc_next;
		else
			o_pc <= x"00";
		end if;
	end process;

end structural;

