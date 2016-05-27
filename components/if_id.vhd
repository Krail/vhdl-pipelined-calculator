library ieee;
use ieee.std_logic_1164.all;

-- Instruction Fetch to Instruction Decode Intermediate Registers
entity if_id is
	port (
		-- Control Signals
		c_clk   	 : in  std_logic;
		c_enable	 : in  std_logic;
		c_reset 	 : in  std_logic;
		c_flush 	 : in  std_logic;
		
		-- Signal Inputs
		i_pc_plus_1  	 : in  std_logic_vector(7 downto 0);
		i_instruction	 : in  std_logic_vector(7 downto 0);
		
		-- Singal Outputs
		o_pc_plus_1  	 : out std_logic_vector(7 downto 0) := (others => '0');
		o_instruction	 : out std_logic_vector(7 downto 0) := (others => 'X')
	);
end if_id;

architecture structural of if_id is
	
begin
	
	-- logic below
	process ( c_reset,
	          c_flush,
	          c_enable,
	          c_clk ) is
		
	begin
		
		if c_reset = '1' or c_flush = '1' then
			
			o_pc_plus_1    <= (others => '0');
			o_instruction  <= (others => 'X');
			
		elsif c_enable = '1' and rising_edge(c_clk) then
			
			o_pc_plus_1    <= i_pc_plus_1;
			o_instruction  <= i_instruction;
			
		end if;
		
	end process;
	
end structural;
