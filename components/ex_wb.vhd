library ieee;
use ieee.std_logic_1164.all;

-- Execute to Writeback Intermediate Registers
entity ex_wb is
	port (
		-- Control Signals
		c_clk   	 : in  std_logic;
		c_enable	 : in  std_logic;
		c_reset 	 : in  std_logic;
		c_flush 	 : in  std_logic;
		
		-- Control Inputs
		i_branch  	 : in  std_logic;
		i_regWrite	 : in  std_logic;
		
		-- Signal Inputs
		i_pc_plus_1_plus_branch	 : in  std_logic_vector(7 downto 0);
		i_zero                 	 : in  std_logic;
		i_write_data           	 : in  std_logic_vector (7 downto 0);
		i_write_reg            	 : in  std_logic_vector (1 downto 0);
		
		-- Control Outputs
		o_branch  	 : out std_logic := '0';
		o_regWrite	 : out std_logic := '0';
		
		-- Signal Outputs
		o_pc_plus_1_plus_branch	 : out std_logic_vector(7 downto 0) := (others => '0');
		o_zero                 	 : out std_logic := '0';
		o_write_data           	 : out std_logic_vector (7 downto 0) := (others => 'X');
		o_write_reg            	 : out std_logic_vector (1 downto 0) := (others => 'X')
	);
end ex_wb;

architecture structural of ex_wb is
	
begin
	
	-- logic below
	process ( c_reset,
	          c_flush,
	          c_enable,
	          c_clk ) is
		
	begin
		
		if c_reset = '1' or c_flush = '1' then
			
			o_branch    <= '0';
			o_regWrite  <= '0';
			
			o_pc_plus_1_plus_branch  <= (others => '0');
			o_zero                   <= '0';
			o_write_data             <= (others => 'X');
			o_write_reg              <= (others => 'X');
			
		elsif c_enable = '1' and rising_edge(c_clk) then
			
			o_branch    <= i_branch;
			o_regWrite  <= i_regWrite;
			
			o_pc_plus_1_plus_branch  <= i_pc_plus_1_plus_branch;
			o_zero                   <= i_zero;
			o_write_data             <= i_write_data;
			o_write_reg              <= i_write_reg;
			
		end if;
		
	end process;
	
end structural;
