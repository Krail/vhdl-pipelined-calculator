library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity mux2_tb is
end mux2_tb;

architecture behav of mux2_tb is
	--  Declaration of the component that will be instantiated.
	component mux2
		generic (LENGTH : integer);
		port(
			i_A   : in  std_logic_vector (LENGTH-1 downto 0);
			i_B   : in  std_logic_vector (LENGTH-1 downto 0);
			i_SEL : in  std_logic := 'X';
			o_Z   : out std_logic_vector (LENGTH-1 downto 0) := (others => 'X')
		);
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	signal s_A1 : std_logic_vector(0 downto 0) := (others => 'X');
	signal s_B1 : std_logic_vector(0 downto 0) := (others => 'X');
	signal s_SEL1 : std_logic := 'X';
	signal s_Z1 : std_logic_vector(0 downto 0) := (others => 'X');

	signal s_A2 : std_logic_vector(1 downto 0) := (others => 'X');
	signal s_B2 : std_logic_vector(1 downto 0) := (others => 'X');
	signal s_SEL2 : std_logic := 'X';
	signal s_Z2 : std_logic_vector(1 downto 0) := (others => 'X');
	
	signal s_A8 : std_logic_vector(7 downto 0) := (others => 'X');
	signal s_B8 : std_logic_vector(7 downto 0) := (others => 'X');
	signal s_SEL8 : std_logic := 'X';
	signal s_Z8 : std_logic_vector(7 downto 0) := (others => 'X');
	
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	mux2_1bit: mux2
		generic map (LENGTH => 1)
		port map (
			i_A => s_A1,
			i_B => s_B1,
			i_SEL => s_SEL1,
			o_Z => s_Z1
		);
	mux2_2bit: mux2
		generic map (LENGTH => 2)
		port map (
			i_A => s_A2,
			i_B => s_B2,
			i_SEL => s_SEL2,
			o_Z => s_Z2
		);
	mux2_8bit: mux2
		generic map (LENGTH => 8)
		port map (
			i_A => s_A8,
			i_B => s_B8,
			i_SEL => s_SEL8,
			o_Z => s_Z8
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
		
		
		---- mux2_1bit
		-- setup
		s_A1 <= (others => '0');
		s_B1 <= (others => '1');
		
		-- test A1
		s_SEL1 <= '0';
		wait for clock_period;
		if ("0" /= s_Z1) then
			assert false report "bad output value 1" severity error;
		end if;
		
		-- test B1
		s_SEL1 <= '1';
		wait for clock_period;
		if ("1" /= s_Z1) then
			assert false report "bad output value 2" severity error;
		end if;
		
		-- test B1 again
		s_B1 <= "0";
		wait for clock_period;
		if ("0" /= s_Z1) then
			assert false report "bad output value 3" severity error;
		end if;
		
		-- test A1 again
		s_A1 <= "1";
		s_SEL1 <= '0';
		wait for clock_period;
		if ("1" /= s_Z1) then
			assert false report "bad output value 4" severity error;
		end if;
		
		
		---- mux2_2bit
		-- setup
		s_A2 <= (others => '0');
		s_B2 <= (others => '1');
		
		-- test A2
		s_SEL2 <= '0';
		wait for clock_period;
		if ("00" /= s_Z2) then
			assert false report "bad output value 5" severity error;
		end if;
		
		-- test B2
		s_SEL2 <= '1';
		wait for clock_period;
		if ("11" /= s_Z2) then
			assert false report "bad output value 6" severity error;
		end if;
		
		-- test B2 again
		s_B2 <= "01";
		wait for clock_period;
		if ("01" /= s_Z2) then
			assert false report "bad output value 7" severity error;
		end if;
		
		-- test A2 again
		s_A2 <= "10";
		s_SEL2 <= '0';
		wait for clock_period;
		if ("10" /= s_Z2) then
			assert false report "bad output value 8" severity error;
		end if;
		
		
		---- mux2_8bit
		-- setup
		s_A8 <= (others => '0');
		s_B8 <= (others => '1');
		
		-- test A8
		s_SEL8 <= '0';
		wait for clock_period;
		if ("00000000" /= s_Z8) then
			assert false report "bad output value 9" severity error;
		end if;
		
		-- test B8
		s_SEL8 <= '1';
		wait for clock_period;
		if ("11111111" /= s_Z8) then
			assert false report "bad output value 10" severity error;
		end if;
		
		-- test B8 again
		s_B8 <= "00001111";
		wait for clock_period;
		if ("00001111" /= s_Z8) then
			assert false report "bad output value 11" severity error;
		end if;
		
		-- test A8 again
		s_A8 <= "11110000";
		s_SEL8 <= '0';
		wait for clock_period;
		if ("11110000" /= s_Z8) then
			assert false report "bad output value 12" severity error;
		end if;
		
		-- test undefined
		s_A8 <= "XXXXXXXX";
		s_SEL8 <= '0';
		wait for clock_period;
		if ("XXXXXXXX" /= s_Z8) then
			assert false report "bad output value 13" severity error;
		end if;
		
		-- test undefined again
		s_A8 <= "11110000";
		s_SEL8 <= 'X';
		wait for clock_period;
		if ("XXXXXXXX" /= s_Z8) then
			assert false report "bad output value 12" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
