library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity alu_tb is
end alu_tb;

architecture behav of alu_tb is
	--  Declaration of the component that will be instantiated.
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
	
	signal s_enable	 : std_logic := 'X';
	signal s_ALUOp 	 : std_logic_vector (2 downto 0) := (others => 'X');
	signal s_A     	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_B     	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_result	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_print 	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_oflow 	 : std_logic := 'X';
	signal s_uflow 	 : std_logic := 'X';
	signal s_zero  	 : std_logic := 'X';
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	alu_0: alu
		port map (
			c_enable	 => s_enable,
			c_ALUOp 	 => s_ALUOp,
			i_A     	 => s_A,
			i_B     	 => s_B,
			o_result	 => s_result,
			o_print 	 => s_print,
			o_oflow 	 => s_oflow,
			o_uflow 	 => s_uflow,
			o_zero  	 => s_zero
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
		
		
		-- test load
		s_ALUOp <= "00X";
		s_A <= "XXXXXXXX";
		s_B <= x"10";
		wait for clock_period/2;
		if "00010000" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (load 0x10)" severity error;
		end if;
		
		
		-- test add
		s_ALUOp <= "01X";
		s_A <= x"00";
		s_B <= x"01";
		wait for clock_period/2;
		if "00000001" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (add 0x00+0x01)" severity error;
		end if;
		
		-- test add
		s_ALUOp <= "01X";
		s_A <= "11111111";
		s_B <= "11111111";
		wait for clock_period/2;
		if "11111110" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (add 0xFF+0xFF)" severity error;
		end if;
		
		-- test add (overflow)
		s_ALUOp <= "01X";
		s_A <= "01111111";
		s_B <= "01111111";
		wait for clock_period/2;
		if "11111110" /= s_result
				or "XXXXXXXX" /= s_print
				or '1' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (add 0x7F+0x7F)" severity error;
		end if;
		
		-- test add (underflow)
		s_ALUOp <= "01X";
		s_A <= "10000000";
		s_B <= "10000000";
		wait for clock_period/2;
		if "00000000" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '1' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (add 0x80+0x80)" severity error;
		end if;
		
		
		-- test sub
		s_ALUOp <= "10X";
		s_A <= x"00";
		s_B <= x"01";
		wait for clock_period/2;
		if "11111111" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (sub 0x00-0x01)" severity error;
		end if;
		
		-- test sub
		s_ALUOp <= "10X";
		s_A <= x"FF";
		s_B <= x"FF";
		wait for clock_period/2;
		if "00000000" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (sub 0xFF-0xFF)" severity error;
		end if;
		
		-- test sub (overflow)
		s_ALUOp <= "10X";
		s_A <= "01111111";
		s_B <= "11111111";
		wait for clock_period/2;
		if "10000000" /= s_result
				or "XXXXXXXX" /= s_print
				or '1' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (sub 0x7F-0xFF)" severity error;
		end if;
		
		-- test sub (underflow)
		s_ALUOp <= "10X";
		s_A <= "10000000";
		s_B <= "01111111";
		wait for clock_period/2;
		if "00000001" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '1' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (sub 0x80-0x7F)" severity error;
		end if;
		
		
		-- test beq/skip (taken)
		s_ALUOp <= "110";
		s_A <= x"10";
		s_B <= x"10";
		wait for clock_period/2;
		if "XXXXXXXX" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '1' /= s_zero then
			assert false report "bad output value (beq/skip taken)" severity error;
		end if;
		
		-- test beq/skip (not taken)
		s_ALUOp <= "110";
		s_A <= x"10";
		s_B <= x"11";
		wait for clock_period/2;
		if "XXXXXXXX" /= s_result
				or "XXXXXXXX" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (beq/skip not taken)" severity error;
		end if;
		
		
		-- test print
		s_ALUOp <= "111";
		s_A <= x"10";
		s_B <= "XXXXXXXX";
		wait for clock_period/2;
		if "XXXXXXXX" /= s_result
				or "00010000" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (print 0x10)" severity error;
		end if;
		
		-- test load again
		s_ALUOp <= "00X";
		s_A <= "XXXXXXXX"; -- prints i_A to s_print before switching to load
		--s_A <= "10101100";
		s_B <= x"22";
		wait for clock_period/2;
		if "00100010" /= s_result
				or "00010000" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (load 0x22)" severity error;
		end if;
		if "00010000" /= s_print then
			assert false report "bad output value (load 0x22, print /= 00010000)" severity error;
		end if;
		
		-- test print again
		s_ALUOp <= "111";
		s_A <= x"22";
		s_B <= "XXXXXXXX";
		wait for clock_period/2;
		if "XXXXXXXX" /= s_result
				or "00100010" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (print 0x22)" severity error;
		end if;
		
		-- test load again x2
		s_ALUOp <= "00X";
		s_A <= "XXXXXXXX"; -- prints i_A to s_print before switching to load
		--s_A <= "10101100";
		s_B <= x"33";
		wait for clock_period/2;
		if "00110011" /= s_result
				or "00100010" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (load 0x22)" severity error;
		end if;
		if "00100010" /= s_print then
			assert false report "bad output value (load 0x22, print /= 00010000)" severity error;
		end if;
		
		
		-- test undefined
		s_ALUOp <= "XXX";
		s_A <= "XXXXXXXX";
		s_B <= "XXXXXXXX";
		wait for clock_period/2;
		if "XXXXXXXX" /= s_result
				or "00100010" /= s_print
				or '0' /= s_oflow
				or '0' /= s_uflow
				or '0' /= s_zero then
			assert false report "bad output value (undefined)" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
