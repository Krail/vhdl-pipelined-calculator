library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity full_adder_tb is
end full_adder_tb;

architecture behav of full_adder_tb is
	--  Declaration of the component that will be instantiated.
	component full_adder
		port(
			i_A    	 : in  std_logic;
			i_B    	 : in  std_logic;
			i_carry	 : in  std_logic;
			o_Z    	 : out std_logic;
			o_carry	 : out std_logic
		);
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	signal s_A        	 : std_logic;
	signal s_B        	 : std_logic;
	signal s_carry_in 	 : std_logic;
	signal s_Z        	 : std_logic;
	signal s_carry_out	 : std_logic;
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	full_adder_0: full_adder
		port map (
			i_A    	 => s_A,
			i_B    	 => s_B,
			i_carry	 =>	s_carry_in,
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
		
		
		-- test 0+0c0
		s_A <= '0';
		s_B <= '0';
		s_carry_in <= '0';
		wait for clock_period;
		if ('0' /= s_carry_out or '0' /= s_Z) then
			assert false report "bad output value (0+0c0)" severity error;
		end if;
		
		-- test 0+0c1
		s_A <= '0';
		s_B <= '0';
		s_carry_in <= '1';
		wait for clock_period;
		if ('0' /= s_carry_out or '1' /= s_Z) then
			assert false report "bad output value (0+0c1)" severity error;
		end if;
		
		-- test 0+1c0
		s_A <= '0';
		s_B <= '1';
		s_carry_in <= '0';
		wait for clock_period;
		if ('0' /= s_carry_out or '1' /= s_Z) then
			assert false report "bad output value (0+1c0)" severity error;
		end if;
		
		-- test 0+1c1
		s_A <= '0';
		s_B <= '1';
		s_carry_in <= '1';
		wait for clock_period;
		if ('1' /= s_carry_out or '0' /= s_Z) then
			assert false report "bad output value (0+1c1)" severity error;
		end if;
		
		
		-- test 1+0c0
		s_A <= '1';
		s_B <= '0';
		s_carry_in <= '0';
		wait for clock_period;
		if ('0' /= s_carry_out or '1' /= s_Z) then
			assert false report "bad output value (1+0c0)" severity error;
		end if;
		
		-- test 1+0c1
		s_A <= '1';
		s_B <= '0';
		s_carry_in <= '1';
		wait for clock_period;
		if ('1' /= s_carry_out or '0' /= s_Z) then
			assert false report "bad output value (1+0c1)" severity error;
		end if;
		
		-- test 1+1c0
		s_A <= '1';
		s_B <= '1';
		s_carry_in <= '0';
		wait for clock_period;
		if ('1' /= s_carry_out or '0' /= s_Z) then
			assert false report "bad output value (1+1c0)" severity error;
		end if;
		
		-- test 1+1c1
		s_A <= '1';
		s_B <= '1';
		s_carry_in <= '1';
		wait for clock_period;
		if ('1' /= s_carry_out or '1' /= s_Z) then
			assert false report "bad output value (1+1c1)" severity error;
		end if;
		
		
		-- test X+XcX (undefined)
		s_A <= 'X';
		s_B <= 'X';
		s_carry_in <= 'X';
		wait for clock_period;
		if ('0' /= s_carry_out or '0' /= s_Z) then
			assert false report "bad output value (X+XcX)" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
