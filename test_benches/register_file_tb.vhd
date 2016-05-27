library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use IEEE.STD_LOGIC_ARITH.ALL; 

--  A testbench has no ports.
entity register_file_tb is
end register_file_tb;

architecture behav of register_file_tb is
	--  Declaration of the component that will be instantiated.
	component register_file
		generic (REG_VALUE	 : integer);
		port(
			c_enable    	 : in  std_logic := '0';
			c_reset     	 : in  std_logic := '0';
			c_regWrite  	 : in  std_logic := '0';
			c_clk       	 : in  std_logic := '0';
			i_read_reg1 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_read_reg2 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_write_reg 	 : in  std_logic_vector (1 downto 0) := (others => 'X');
			i_write_data	 : in  std_logic_vector (REG_VALUE-1 downto 0) := (others => 'X');
			o_read_data1	 : out std_logic_vector (REG_VALUE-1 downto 0) := (others => 'X');
			o_read_data2	 : out std_logic_vector (REG_VALUE-1 downto 0) := (others => 'X')
		);
	end component;
	
	-- signal-port declarations
	signal clock: std_logic := '0';
	signal end_of_sim: std_logic := '0';
	
	-- control signals
	signal s_enable    	 : std_logic := '0';
	signal s_reset     	 : std_logic := '0';
	signal s_regWrite  	 : std_logic := '0';
	signal s_clk       	 : std_logic := '0';
	-- inputs
	signal s_read_reg1 	 : std_logic_vector(1 downto 0) := (others => 'X');
	signal s_read_reg2 	 : std_logic_vector(1 downto 0) := (others => 'X');
	signal s_write_reg 	 : std_logic_vector(1 downto 0) := (others => 'X');
	signal s_write_data	 : std_logic_vector(7 downto 0) := (others => 'X');
	-- outputs
	signal s_read_data1	 : std_logic_vector(7 downto 0) := (others => 'X');
	signal s_read_data2	 : std_logic_vector(7 downto 0) := (others => 'X');
	-- Clock period definitions
	constant clock_period : time := 10 ns;
	
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
	
begin
	reg_file: register_file
		generic map (REG_VALUE => 8)
		port map (
			c_enable    	 => s_enable,
			c_reset     	 => s_reset,
			c_regWrite  	 => s_regWrite,
			c_clk       	 => clock,
			i_read_reg1 	 => s_read_reg1,
			i_read_reg2 	 => s_read_reg2,
			i_write_reg 	 => s_write_reg,
			i_write_data	 => s_write_data,
			o_read_data1	 => s_read_data1,
			o_read_data2	 => s_read_data2
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
		wait for clock_period/2;
		--report "clk="&to_bstring(clock) severity note; -- clk is 0
		
		-- setup
		s_reset <= '1';
		s_enable <= '0';
		s_regWrite <= '0';
		s_read_reg1 <= "XX";
		s_read_reg2 <= "XX";
		s_write_reg <= "XX";
		s_write_data <= "XXXXXXXX";
		wait for clock_period;
		
		-- read 00 and 01
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '0';
		s_read_reg1 <= "00";
		s_read_reg2 <= "01";
		s_write_reg <= "XX";
		s_write_data <= "XXXXXXXX";
		wait for clock_period;
		if "00000000" /= s_read_data1 or "00000000" /= s_read_data2 then
			assert false report "bad output value 1 (print 00 and 01)" severity error;
		end if;
		
		-- read 01 and 11
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '0';
		s_read_reg1 <= "10";
		s_read_reg2 <= "11";
		s_write_reg <= "XX";
		s_write_data <= "XXXXXXXX";
		wait for clock_period;
		if "00000000" /= s_read_data1 or "00000000" /= s_read_data2 then
			assert false report "bad output value 1 (print 10 and 11)" severity error;
		end if;
		
		-- s_regWrite <= '1';
		-- wait for clock_period;
		
		-- write 00000001 to 00
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '1';
		s_read_reg1 <= "XX";
		s_read_reg2 <= "XX";
		s_write_reg <= "00";
		s_write_data <= "00000001";
		wait for clock_period;
		if "XXXXXXXX" /= s_read_data1 or "XXXXXXXX" /= s_read_data2 then
			assert false report "bad output value 2 (load 00000001 to 00)" severity error;
		end if;
		report "wrote 00000001 to 00";
		report "write to 00 (expecting 00): s_write_reg: "&to_bstring(s_write_reg) severity note;
		
		-- write 00000010 to 01
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '1';
		s_read_reg1 <= "XX";
		s_read_reg2 <= "XX";
		s_write_reg <= "01";
		s_write_data <= "00000010";
		wait for clock_period;
		if "XXXXXXXX" /= s_read_data1 or "XXXXXXXX" /= s_read_data2 then
			assert false report "bad output value 2 (load 00000010 to 01)" severity error;
		end if;
		
		-- write 00000100 to 10
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '1';
		s_read_reg1 <= "XX";
		s_read_reg2 <= "XX";
		s_write_reg <= "10";
		s_write_data <= "00000100";
		wait for clock_period;
		if "XXXXXXXX" /= s_read_data1 or "XXXXXXXX" /= s_read_data2 then
			assert false report "bad output value 2 (load 00000100 to 10)" severity error;
		end if;
		
		-- write 11111000 to 11
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '1';
		s_read_reg1 <= "XX";
		s_read_reg2 <= "XX";
		s_write_reg <= "11";
		s_write_data <= "11111000";
		wait for clock_period;
		if "XXXXXXXX" /= s_read_data1 or "XXXXXXXX" /= s_read_data2 then
			assert false report "bad output value 2 (load 11111000 to 11)" severity error;
		end if;
		
		-- read 00 and 01
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '0';
		s_read_reg1 <= "00";
		s_read_reg2 <= "01";
		-- s_read_reg1 <= "01";
		-- s_read_reg2 <= "00";
		s_write_reg <= "XX";
		s_write_data <= "XXXXXXXX";
		wait for clock_period;
		if "00000001" /= s_read_data1 or "00000010" /= s_read_data2 then
			assert false report "bad output value 3 (print 00 and 01)" severity error;
		end if;
		report "read 00 and 01" severity note;
		report "print 00 (expecting 00): s_read_reg1: "&to_bstring(s_read_reg1) severity note;
		report "print 01 (expecting 01): s_read_reg2: "&to_bstring(s_read_reg2) severity note;
		report "print 00 (expecting 00000001): s_read_data1: "&to_bstring(s_read_data1) severity note;
		report "print 01 (expecting 00000010): s_read_data2: "&to_bstring(s_read_data2) severity note;
		
		-- read 01 and 11
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '0';
		s_read_reg1 <= "10";
		s_read_reg2 <= "11";
		s_write_reg <= "XX";
		s_write_data <= "XXXXXXXX";
		wait for clock_period;
		if "00000100" /= s_read_data1 or "11111000" /= s_read_data2 then
			assert false report "bad output value 3 (print 10 and 11)" severity error;
		end if;
		report "read 10 and 11" severity note;
		report "print 10 (expecting 10): s_read_reg1: "&to_bstring(s_read_reg1) severity note;
		report "print 11 (expecting 11): s_read_reg2: "&to_bstring(s_read_reg2) severity note;
		report "print 10 (expecting 00000100): s_read_data1: "&to_bstring(s_read_data1) severity note;
		report "print 11 (expecting 11111000): s_read_data2: "&to_bstring(s_read_data2) severity note;
		
		
		-- read 00 and 00 and write to 00
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '1';
		s_read_reg1 <= "00";
		s_read_reg2 <= "00";
		s_write_reg <= "00";
		s_write_data <= "01010101";
		wait for clock_period;
		if "00000001" /= s_read_data1 or "00000001" /= s_read_data2 then
			assert false report "bad output value 4 (print 00 and 00 and write 01010101 to 00)" severity error;
		end if;
		report "read 00 and 00 and write 01010101" severity note;
		report "print 00 (expecting 00): s_read_reg1: "&to_bstring(s_read_reg1) severity note;
		report "print 00 (expecting 00): s_read_reg2: "&to_bstring(s_read_reg2) severity note;
		report "print 00 (expecting 00000001): s_read_data1: "&to_bstring(s_read_data1) severity note;
		report "print 00 (expecting 00000001): s_read_data2: "&to_bstring(s_read_data2) severity note;
		
		-- read 00 and 00 and write to 00
		s_reset <= '0';
		s_enable <= '1';
		s_regWrite <= '1';
		s_read_reg1 <= "00";
		s_read_reg2 <= "00";
		s_write_reg <= "00";
		s_write_data <= "10101010";
		wait for clock_period;
		if "01010101" /= s_read_data1 or "01010101" /= s_read_data2 then
			assert false report "bad output value 4 (print 00 and 00 and write 10101010 to 00)" severity error;
		end if;
		report "read 00 and 00 and write 10101010" severity note;
		report "print 00 (expecting 00): s_read_reg1: "&to_bstring(s_read_reg1) severity note;
		report "print 00 (expecting 00): s_read_reg2: "&to_bstring(s_read_reg2) severity note;
		report "print 00 (expecting 01010101): s_read_data1: "&to_bstring(s_read_data1) severity note;
		report "print 00 (expecting 01010101): s_read_data2: "&to_bstring(s_read_data2) severity note;
		
		
		-- done
		end_of_sim <= '1';
		report "end of test" severity note;
		wait;
	end process stim_proc;
	
end behav;
