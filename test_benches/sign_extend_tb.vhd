library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity sign_extend_tb is
end sign_extend_tb;

architecture behav of sign_extend_tb is
	--  Declaration of the component that will be instantiated.
	component sign_extend
		generic (IN_WORD_LENGTH  : integer;
		         OUT_WORD_LENGTH : integer);
		port(
			i_A   : in  std_logic_vector (IN_WORD_LENGTH-1 downto 0);
			o_Z   : out std_logic_vector (OUT_WORD_LENGTH-1 downto 0) := (others => 'X')
		);
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	signal s_A : std_logic_vector(3 downto 0) := (others => 'X');
	signal s_Z : std_logic_vector(7 downto 0) := (others => 'X');
	-- Clock period definitions
	constant clock_period : time := 10 ns;
begin
	sign_extend_4bits_to_8bits: sign_extend
		generic map (IN_WORD_LENGTH  => 4,
		             OUT_WORD_LENGTH => 8)
		port map (
			i_A => s_A,
			o_Z => s_Z
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
		s_A <= (others => '0');
		
		-- test positive
		wait for clock_period;
		if ("00000000" /= s_Z) then
			assert false report "bad output value 1" severity error;
		end if;
		
		-- test negative
		s_A <= (others => '1');
		wait for clock_period;
		if ("11111111" /= s_Z) then
			assert false report "bad output value 2" severity error;
		end if;
		
		-- test positive again
		s_A <= "0101";
		wait for clock_period;
		if ("00000101" /= s_Z) then
			assert false report "bad output value 3" severity error;
		end if;
		
		-- test undefined
		s_A <= "XXXX";
		wait for clock_period;
		if ("XXXXXXXX" /= s_Z) then
			assert false report "bad output value 4" severity error;
		end if;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
