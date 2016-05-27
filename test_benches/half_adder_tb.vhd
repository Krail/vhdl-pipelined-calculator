library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity half_adder_tb is
end half_adder_tb;

architecture behav of half_adder_tb is
	--  Declaration of the component that will be instantiated.
	component half_adder
		port(
			i_A    	 : in  std_logic;
			i_B    	 : in  std_logic;
			o_Z    	 : out std_logic;
			o_carry	 : out std_logic
		);
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	signal s_A        	 : std_logic;
	signal s_B        	 : std_logic;
	signal s_Z        	 : std_logic;
	signal s_carry_out	 : std_logic;
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	half_adder_0: half_adder
		port map (
			i_A    	 => s_A,
			i_B    	 => s_B,
			o_Z    	 => s_Z,
			o_carry	 => s_carry_out
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
		
		
		-- test 0+0
		s_A <= '0';
		s_B <= '0';
		wait for clock_period;
		if '0' /= s_carry_out or '0' /= s_Z then
			assert false report "bad output value (0+0)" severity error;
		end if;
		
		-- test 0+1
		s_A <= '0';
		s_B <= '1';
		wait for clock_period;
		if '0' /= s_carry_out or '1' /= s_Z then
			assert false report "bad output value (0+1)" severity error;
		end if;
		
		-- test 1+0
		s_A <= '1';
		s_B <= '0';
		wait for clock_period;
		if '0' /= s_carry_out or '1' /= s_Z then
			assert false report "bad output value (1+0)" severity error;
		end if;
		
		-- test 1+1
		s_A <= '1';
		s_B <= '1';
		wait for clock_period;
		if '1' /= s_carry_out or '0' /= s_Z then
			assert false report "bad output value (1+1)" severity error;
		end if;
		
		
		-- test undefined
		s_A <= 'X';
		s_B <= 'X';
		wait for clock_period;
		if '0' /= s_carry_out or '0' /= s_Z then
			assert false report "bad output value (X+X)" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
