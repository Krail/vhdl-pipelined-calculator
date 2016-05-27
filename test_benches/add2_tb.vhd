library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity add2_tb is
end add2_tb;

architecture behav of add2_tb is
	--  Declaration of the component that will be instantiated.
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
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	signal s_op  	 : std_logic;
	-- 2-bit adder/subtractor
	signal s_A   	 : std_logic_vector (1 downto 0);
	signal s_B   	 : std_logic_vector (1 downto 0);
	signal s_Z   	 : std_logic_vector (1 downto 0) := (others => 'X');
	signal s_flow	 : std_logic;
	-- 8-bit adder/subtractor
	signal s_op8   	 : std_logic;
	signal s_A8    	 : std_logic_vector (7 downto 0);
	signal s_B8    	 : std_logic_vector (7 downto 0);
	signal s_Z8    	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_flow8	 : std_logic;
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	add2_2bit: add2
		generic map (LENGTH => 2)
		port map (
			c_op  	 => s_op,
			i_A   	 => s_A,
			i_B   	 => s_B,
			o_Z   	 => s_Z,
			o_flow	 => s_flow
		);
	add2_8bit: add2
		generic map (LENGTH => 8)
		port map (
			c_op  	 => s_op8,
			i_A   	 => s_A8,
			i_B   	 => s_B8,
			o_Z   	 => s_Z8,
			o_flow	 => s_flow8
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
		
		
		-- test 00+00
		s_op <= '0';
		s_A <= "00";
		s_B <= "00";
		wait for clock_period;
		if ("00" /= s_Z or '0' /= s_flow) then
			assert false report "bad output value (00+00)" severity error;
		end if;
		
		-- test 00+01
		s_op <= '0';
		s_A <= "00";
		s_B <= "01";
		wait for clock_period;
		if ("01" /= s_Z or '0' /= s_flow) then
			assert false report "bad output value (00+01)" severity error;
		end if;
		
		-- test 01+10
		s_op <= '0';
		s_A <= "01";
		s_B <= "10";
		wait for clock_period;
		if ("11" /= s_Z or '0' /= s_flow) then
			assert false report "bad output value (01+10)" severity error;
		end if;
		
		-- test 01+01 (overflow)
		s_op <= '0';
		s_A <= "01";
		s_B <= "01";
		wait for clock_period;
		if ("10" /= s_Z or '1' /= s_flow) then
			assert false report "bad output value (01+01)" severity error;
		end if;
		
		-- test 10+10 (overflow)
		s_op <= '0';
		s_A <= "10";
		s_B <= "10";
		wait for clock_period;
		if ("00" /= s_Z or '1' /= s_flow) then
			assert false report "bad output value (10+10)" severity error;
		end if;
		
		
		-- test 00-00
		s_op <= '1';
		s_A <= "00";
		s_B <= "00";
		wait for clock_period;
		if ("00" /= s_Z or '0' /= s_flow) then
			assert false report "bad output value (00-00)" severity error;
		end if;
		
		-- test 00-01
		s_op <= '1';
		s_A <= "00";
		s_B <= "01";
		wait for clock_period;
		if ("11" /= s_Z or '0' /= s_flow) then
			assert false report "bad output value (00-01)" severity error;
		end if;
		
		-- test 01-00
		s_op <= '1';
		s_A <= "01";
		s_B <= "00";
		wait for clock_period;
		if ("01" /= s_Z or '0' /= s_flow) then
			assert false report "bad output value (01-00)" severity error;
		end if;
		
		-- test 10-01 (underflow)
		s_op <= '1';
		s_A <= "10";
		s_B <= "01";
		wait for clock_period;
		if ("01" /= s_Z or '1' /= s_flow) then
			assert false report "bad output value (10-01)" severity error;
		end if;
		
		
		-- test XX?XX (undefined)
		s_op <= 'X';
		s_A <= "XX";
		s_B <= "XX";
		wait for clock_period;
		if ("00" /= s_Z or '0' /= s_flow) then
			assert false report "bad output value (XX?XX)" severity error;
		end if;
		
		
		-- test 10000000+10000000 (underflow)
		s_op8 <= '0';
		s_A8 <= "10000000";
		s_B8 <= "10000000";
		wait for clock_period;
		if ("00000000" /= s_Z8 or '1' /= s_flow8) then
			assert false report "bad output value (0x80+0x80)" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
