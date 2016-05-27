library ieee;
use ieee.std_logic_1164.all;

-- ALU
entity alu is 
    port(
        c_enable	 : in  std_logic;
        c_ALUOp 	 : in  std_logic_vector (2 downto 0);
        i_A     	 : in  std_logic_vector (7 downto 0);
        i_B     	 : in  std_logic_vector (7 downto 0);
        o_result	 : out std_logic_vector (7 downto 0) := (others => 'X');
        o_print 	 : out std_logic_vector (7 downto 0) := (others => 'X');
        o_oflow 	 : out std_logic := '0';
        o_uflow 	 : out std_logic := '0';
        o_zero  	 : out std_logic := '0'
    );
    
end alu;

architecture structural of alu is
	
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
	component comparator2
		generic (LENGTH : integer);
		port(
			i_A	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_A	 : out std_logic_vector (LENGTH-1 downto 0);
			o_Z	 : out std_logic_vector (1 downto 0)
		);
	end component;
	
	-- state types
	type STATE_TYPE is (load, add, sub, print, beq, noop);
	
	-- add/subtract signals
	signal s_op : std_logic := '0';
	signal s_addsub_result : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_flow : std_logic := 'X';
	signal s_comp : std_logic_vector (1 downto 0) := "XX";
	
begin
	
	addsub: add2
		generic map (LENGTH => 8)
		port map (
			c_op  	 => s_op,
			i_A   	 => i_A,
			i_B   	 => i_B,
			o_Z   	 => s_addsub_result,
			o_flow	 => s_flow
		);
	beq_comparator: comparator2
		generic map (LENGTH => 8)
		port map (
			i_A	 => i_A,
			i_B	 => i_B,
			o_A	 => open,
			o_Z	 => s_comp
		);
	
	-- logic below
	process (c_enable,
	         c_ALUOp,
	         i_A,
	         i_B,
	         s_addsub_result,
	         s_comp,
	         s_flow) is
		variable state : STATE_TYPE;
	begin
		
		if c_enable = '1' then
			
			state_machine_case: case c_ALUOp(2 downto 1) is
				when "00"	=> state := load;
				when "01"	=> state := add;
				when "10"	=> state := sub;
				when "11"	=>
					special_state_case: case c_ALUOp(0) is
						when '0'	=> state := beq;
						when '1'	=> state := print;
						when others	=> state := noop;
					end case special_state_case;
				when others	=> state := noop;
			end case state_machine_case;
			
			logic_case: case state is
				when load =>
					s_op <= '0';
					-- ignore i_A
					o_result <= i_B;
					-- control signals
					o_zero <='0';
					o_oflow <= '0';
					o_uflow <= '0';
				when add =>
					s_op <= '0';
					o_result <= s_addsub_result;
					-- control signals
					o_zero <= '0';
					if s_flow = '1' then
						if i_A(7) = '0' and i_B(7) = '0' then
							o_oflow <= '1';
							o_uflow <= '0';
						elsif i_A(7) = '1' and i_B(7) = '1' then
							o_oflow <= '0';
							o_uflow <= '1';
						else 
							o_oflow <= '0';
							o_uflow <= '0';
						end if;
					else
						o_oflow <= '0';
						o_uflow <= '0';
					end if;
				when sub =>
					s_op <= '1';
					o_result <= s_addsub_result;
					-- control signals
					o_zero <= '0';
					if s_flow = '1' then
						if i_A(7) = '0' and i_B(7) = '1' then
							o_oflow <= '1';
							o_uflow <= '0';
						elsif i_A(7) = '1' and i_B(7) = '0' then
							o_oflow <= '0';
							o_uflow <= '1';
						else 
							o_oflow <= '0';
							o_uflow <= '0';
						end if;
					else
						o_oflow <= '0';
						o_uflow <= '0';
					end if;
				when beq =>   -- beq (or skip)
					s_op <= '1';
					o_result <= "XXXXXXXX";
					if s_comp = "00" then
						o_zero <= '1';
					else
						o_zero <= '0';
					end if;
					-- control signals
					o_oflow <= '0';
					o_uflow <= '0';
				when print =>   -- print
					s_op <= '0';
					o_result <= "XXXXXXXX";
					o_print <= i_A;
					-- ignore i_B
					-- control signals
					o_zero <= '0';
					o_oflow <= '0';
					o_uflow <= '0';
				when noop =>   -- noop (do nothing)
					s_op <= '0';
					o_result <= "XXXXXXXX";
					-- control signals
					o_zero <= '0';
					o_oflow <= '0';
					o_uflow <= '0';
			end case logic_case;
			
		end if;
	end process;
	
end structural;