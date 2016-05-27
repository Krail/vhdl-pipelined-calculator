library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity comparator2_tb is
end comparator2_tb;

architecture behav of comparator2_tb is
	--  Declaration of the component that will be instantiated.
	component comparator2
		generic (LENGTH : integer);
		port(
			i_A	 : in  std_logic_vector (LENGTH-1 downto 0);
			i_B	 : in  std_logic_vector (LENGTH-1 downto 0);
			o_A	 : out std_logic_vector (LENGTH-1 downto 0);
			o_Z	 : out std_logic_vector (1 downto 0)
		);
	end component;
	
	-- signal-port declarations
	signal clock	 : std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	signal s_A  	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_B  	 : std_logic_vector (7 downto 0) := (others => 'X');
	signal s_Z  	 : std_logic_vector (1 downto 0) := "XX";
	
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	comparator2_8bits: comparator2
		generic map (LENGTH => 8)
		port map (
			i_A	 => s_A,
			i_B	 => s_B,
			o_A	 => open,
			o_Z	 => s_Z
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
		
		
		-- test equal
		s_A <= x"7F";
		s_B <= x"7F";
		wait for clock_period;
		if ("00" /= s_Z) then
			assert false report "bad output value (0x7F=0x7F)" severity error;
		end if;
		
		-- test less than
		s_A <= x"11";
		s_B <= x"7F";
		wait for clock_period;
		if ("10" /= s_Z) then
			assert false report "bad output value (0x11<0x7F)" severity error;
		end if;
		
		-- test greater than
		s_A <= x"7F";
		s_B <= x"11";
		wait for clock_period;
		if ("01" /= s_Z) then
			assert false report "bad output value (0x7F<0x11)" severity error;
		end if;
		
		-- test greater than
		s_A <= x"80";
		s_B <= x"01";
		wait for clock_period;
		if ("01" /= s_Z) then
			assert false report "bad output value (0x80<0x01)" severity error;
		end if;
		
		
		-- test 0xXX?0xXX (undefined1)
		s_A <= "XXXXXXXX";
		s_B <= "XXXXXXXX";
		wait for clock_period;
		if ("XX" /= s_Z) then
			assert false report "bad output value (0xXX?0xXX)" severity error;
		end if;
		
		
		-- test 0xUU?0xUU (undefined2)
		s_A <= "UUUUUUUU";
		s_B <= "UUUUUUUU";
		wait for clock_period;
		if ("XX" /= s_Z) then
			assert false report "bad output value (0xUU?0xUU)" severity error;
		end if;
		
		-- test 0x11?0xUU (undefined3)
		s_A <= "00010001";
		s_B <= "UUUUUUUU";
		wait for clock_period;
		if ("XX" /= s_Z) then
			assert false report "bad output value (0x11?0xUU)" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
