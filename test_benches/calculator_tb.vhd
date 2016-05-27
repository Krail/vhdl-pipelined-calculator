library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--  A testbench has no ports.
entity calculator_tb is
end calculator_tb;

architecture behav of calculator_tb is
	--  Declaration of the component that will be instantiated.
	component calculator
		port(
			clk               	 : in  std_logic;
			i_reset           	 : in  std_logic;
			i_enable          	 : in  std_logic;
			i_num_instructions	 : in  std_logic_vector (7 downto 0);
			i_instruction	  	 : in  std_logic_vector (7 downto 0);
			o_PC              	 : out std_logic_vector (7 downto 0);
			o_print           	 : out std_logic_vector (7 downto 0)
		);
	end component;
	
	type instructions_memory_type is array (30 downto 0) of STD_LOGIC_VECTOR (7 downto 0) ;
	signal instruction_memory : instructions_memory_type := (
			0  => "00001000",  -- load "11111000" into reg "00"
			1  => "00001000",  -- load "11111000" into reg "00"
			2  => "00001000",  -- load "11111000" into reg "00"
			3  => "11000001",  -- print reg "00"                      (11111000)
			4  => "00010100",  -- load "00000100" into reg "01"
			5  => "11010001",  -- print reg "01"                      (00000100)
			6  => "00100010",  -- load "00000010" into reg "10"
			7  => "11100001",  -- print reg "10"                      (00000010)
			8  => "00110001",  -- load "00000001" into reg "11"
			9  => "11110001",  -- print reg "11"                      (00000001)
			10 => "11000001",  -- print reg "00"                      (11111000)
			11 => "11010001",  -- print reg "01"                      (00000100)
			12 => "11100001",  -- print reg "10"                      (00000010)
			13 => "11110001",  -- print reg "11"                      (00000001)
			14 => "11000001",  -- print reg "00"                      (11111000)
			15 => "01101011",  -- add 10, 10 into reg "11" (00000100)
			16 => "11110001",  -- print reg "11"                      (00000100)
			17 => "11000010",  -- skip 2 instructions      (skip 2)
			18 => "11000001",  -- print reg "00"           (skipped)  (11111000)
			19 => "11010001",  -- print reg "01"           (skipped)  (00000100)
			20 => "11100001",  -- print reg "10"                      (00000010)
			21 => "11000000",  -- skip 1 instruction       (skip 1)
			22 => "11000001",  -- print reg "00"           (skipped)  (11111000)
			23 => "11010001",  -- print reg "01"                      (00000100)
			24 => "11000001",  -- print reg "00"                      (11111000)
			25 => "10011000",  -- sub 01, 10 into reg "00" (00000010)
			26 => "11000001",  -- print reg "00"                      (00000010)
			others => "11010001"  -- print reg "01"                   (00000100)
	);
	
	-- signal-port declarations
	signal clock             	 : std_logic := '0';
	signal end_of_sim        	 : std_logic := '0';
	
	signal s_reset           	 : std_logic := '0';
	signal s_enable          	 : std_logic := '0';
	
	-- Different number of instructions you can specify
--	signal s_num_instructions	 : std_logic_vector (7 downto 0) := "00001000";  -- 8
--	signal s_num_instructions	 : std_logic_vector (7 downto 0) := "00001111";  -- 15
--	signal s_num_instructions	 : std_logic_vector (7 downto 0) := "00011000";  -- 24
--	signal s_num_instructions	 : std_logic_vector (7 downto 0) := "00011001";  -- 25
--	signal s_num_instructions	 : std_logic_vector (7 downto 0) := "00011011";  -- 27
	signal s_num_instructions	 : std_logic_vector (7 downto 0) := "00011110";  -- 30
--	signal s_num_instructions	 : std_logic_vector (7 downto 0) := "00011111";  -- 31
	
	signal s_instruction     	 : std_logic_vector (7 downto 0) := x"00";
	signal s_pc              	 : std_logic_vector (7 downto 0) := x"00";
	signal s_print           	 : std_logic_vector (7 downto 0) := "XXXXXXXX";
	
	-- Clock period definitions
	constant clock_period : time := 10 ns;
	
	
	-- Jose showed us this
	function to_bstring(sl : std_logic) return string is
	  variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
	begin
	  sl_str_v := std_logic'image(sl);
	  return "" & sl_str_v(2);  -- "" & character to get string
	end function;
	function to_bstring(slv : std_logic_vector) return string is
	  alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
	  variable sl_str_v : string(1 to 1);  -- String of std_logic
	  variable res_v    : string(1 to slv'length);
	begin
	  for idx in slv_norm'range loop
	    sl_str_v := to_bstring(slv_norm(idx));
	    res_v(idx) := sl_str_v(1);
	  end loop;
	  return res_v;
	end function;
	
	-- Ours
	function is_valid(i_vector : std_logic_vector) return boolean is
	begin
		for i in i_vector'range loop
			if i_vector(i) /= '0' and i_vector(i) /= '1' then
				return false;
			end if;
		end loop;
		return true;
	end function;
	
	
begin
	calculator_0: calculator
		port map (
			clk               	 => clock,
			i_reset           	 => s_reset,
			i_enable          	 => s_enable,
			i_num_instructions	 => s_num_instructions,
			i_instruction     	 => s_instruction,
			o_PC              	 => s_pc,
			o_print           	 => s_print
		);
	
	-- Clock process definitions
	clock_process: process
	begin
		if not end_of_sim = '1' then
			clock <= '0';
			wait for clock_period/2;
			clock <= '1';
			wait for clock_period/2;
		else
			wait;
		end if;
	end process clock_process;
	
	
	-- print_process: process (s_print) is
	print_process: process (s_print, clock) is
	begin
		if s_enable = '1' and rising_edge(clock) and is_valid(s_print) then
			report "                 PRINTER: "&to_bstring(s_print) severity note;
		end if;
	end process print_process;
	
	fetch_instruction: process (s_enable, s_pc) is
	begin
		if s_enable = '1' then
			s_instruction <= instruction_memory(to_integer(unsigned(s_pc)));
		end if;
	end process fetch_instruction;
	
	
	-- Stimulus process
	stim_proc: process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
		wait for clock_period*10; -- another 100 ns
		
		report "setting up" severity note;
		
		-- setup
		s_reset <= '1';
		wait for clock_period;
		s_reset <= '0';
		wait for clock_period;
		-- s_reset <= '1';
		s_enable <= '1';
		
		report "beginning execution" severity note;
		
		report "PC    INSTRUCTION" severity note;
		
		-- wait for s_num_instructions cycles
		for i in 0 to to_integer(unsigned(s_num_instructions)) loop
			wait for clock_period;
		end loop;
		
		wait for clock_period;
		s_enable <= '0';
		
		report "finished execution" severity note;
		
		-- one more good measure
		wait for clock_period;
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		
		wait;
	end process stim_proc;
	
end behav;
