library ieee;
use ieee.std_logic_1164.all;

-- Instruction Decode to Execute Intermediate Registers
entity id_ex is
	port (
		-- Control Signals
		c_clk   	 : in  std_logic;
		c_enable	 : in  std_logic;
		c_reset 	 : in  std_logic;
		c_flush 	 : in  std_logic;
		
		-- Control Inputs
		i_regDst  	 : in  std_logic;
		i_branch  	 : in  std_logic;
		i_ALUOp   	 : in  std_logic_vector(2 downto 0);
		i_ALUSrc  	 : in  std_logic;
		i_regWrite	 : in  std_logic;
		
		-- Signal Inputs
		i_pc_plus_1    	 : in  std_logic_vector(7 downto 0);
		i_read_data1   	 : in  std_logic_vector(7 downto 0);
		i_read_data2   	 : in  std_logic_vector(7 downto 0);
		i_rs           	 : in  std_logic_vector(1 downto 0);
		i_rd           	 : in  std_logic_vector(1 downto 0);
		i_sign_extended	 : in  std_logic_vector(7 downto 0);
		
		-- Control Outputs
		o_regDst  	 : out std_logic := 'X';
		o_branch  	 : out std_logic := '0';
		o_ALUOp   	 : out std_logic_vector(2 downto 0) := "XXX";
		o_ALUSrc  	 : out std_logic := 'X';
		o_regWrite	 : out std_logic := '0';
		
		-- Signal Inputs
		o_pc_plus_1    	 : out std_logic_vector(7 downto 0) := (others => '0');
		o_read_data1   	 : out std_logic_vector(7 downto 0) := (others => 'X');
		o_read_data2   	 : out std_logic_vector(7 downto 0) := (others => 'X');
		o_rs           	 : out std_logic_vector(1 downto 0) := (others => 'X');
		o_rd           	 : out std_logic_vector(1 downto 0) := (others => 'X');
		o_sign_extended	 : out std_logic_vector(7 downto 0) := (others => 'X')
	);
end id_ex;

architecture structural of id_ex is
	
begin
	
	-- logic below
	process ( c_reset,
	          c_flush,
	          c_enable,
	          c_clk ) is
		
	begin
		
		if c_reset = '1' or c_flush = '1' then
			
			o_regDst    <= 'X';
			o_branch    <= '0';
			o_ALUOp     <= "XXX";
			o_ALUSrc    <= 'X';
			o_regWrite  <= '0';
			
			o_pc_plus_1      <= (others => '0');
			o_read_data1     <= (others => 'X');
			o_read_data2     <= (others => 'X');
			o_rs             <= (others => 'X');
			o_rd             <= (others => 'X');
			o_sign_extended  <= (others => 'X');
			
		elsif c_enable = '1' and rising_edge(c_clk) then
			
			o_regDst    <= i_regDst;
			o_branch    <= i_branch;
			o_ALUOp     <= i_ALUOp;
			o_ALUSrc    <= i_ALUSrc;
			o_regWrite  <= i_regWrite;
			
			o_pc_plus_1      <= i_pc_plus_1;
			o_read_data1     <= i_read_data1;
			o_read_data2     <= i_read_data2;
			o_rs             <= i_rs;
			o_rd             <= i_rd;
			o_sign_extended  <= i_sign_extended;
			
		end if;
		
	end process;
	
end structural;
