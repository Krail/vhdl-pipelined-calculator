library ieee;
use ieee.std_logic_1164.all;

-- Register File
--   Only update o_read_data1 and o_read_data2 when i_read_reg1 or i_read_reg2 changes OR rising edge of c_clk,
--     NOT when i_write_data changes
entity register_file is 
	generic (REG_VALUE	 : integer);
	port(
		-- Control Signals
		c_enable    	 : in  std_logic := '0';
		c_reset     	 : in  std_logic := '1';
		c_regWrite  	 : in  std_logic := '0';
		c_clk       	 : in  std_logic := '0';
		
		-- Inputs
		i_read_reg1 	 : in  std_logic_vector (1 downto 0);
		i_read_reg2 	 : in  std_logic_vector (1 downto 0);
		i_write_reg 	 : in  std_logic_vector (1 downto 0);
		i_write_data	 : in  std_logic_vector (REG_VALUE-1 downto 0);
		
		-- Outputs
		o_read_data1	 : out std_logic_vector (REG_VALUE-1 downto 0) := (others => 'X');
		o_read_data2	 : out std_logic_vector (REG_VALUE-1 downto 0) := (others => 'X')
	);
end register_file;

architecture structural of register_file is

	-- Stored Registers
	signal s_reg0	 : std_logic_vector (REG_VALUE-1 downto 0) := (others => '0');	 -- index "00"
	signal s_reg1	 : std_logic_vector (REG_VALUE-1 downto 0) := (others => '0');	 -- index "01"
	signal s_reg2	 : std_logic_vector (REG_VALUE-1 downto 0) := (others => '0');	 -- index "10"
	signal s_reg3	 : std_logic_vector (REG_VALUE-1 downto 0) := (others => '0');	 -- index "11"
	
-- delete below
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
-- delete above
	
begin
	
	-- logic below
	process (c_enable,
	         c_reset,
	         c_clk,
	         c_regWrite,
	         i_read_reg1,
	         i_read_reg2,
	         i_write_reg,
	         i_write_data) is
	begin
		if rising_edge(c_reset) then
			s_reg0 <= (others => '0'); -- gets set here and remains at this value (whatever it is)
			s_reg1 <= (others => '0');
			s_reg2 <= (others => '0');
			s_reg3 <= (others => '0');
		elsif c_enable = '1' then
			
			-- read on rising edge of pseudo-clock
			if rising_edge(c_clk) then
				
				-- Read first register
				read_reg1: case i_read_reg1 is
					when "00"  	 =>	 o_read_data1 <= s_reg0;
					when "01"  	 =>	 o_read_data1 <= s_reg1;
					when "10"  	 =>	 o_read_data1 <= s_reg2;
					when "11"  	 =>	 o_read_data1 <= s_reg3;
					when others	 =>	 o_read_data1 <= (others => 'X');
				end case read_reg1;
				
				-- Read second register
				read_reg2: case i_read_reg2 is
					when "00"  	 =>	 o_read_data2 <= s_reg0;
					when "01"  	 =>	 o_read_data2 <= s_reg1;
					when "10"  	 =>	 o_read_data2 <= s_reg2;
					when "11"  	 =>	 o_read_data2 <= s_reg3;
					when others	 =>	 o_read_data2 <= (others => 'X');
				end case read_reg2;
				
			end if;
			
			-- write whenever
			if c_regWrite = '1' and (i_write_reg'event or i_write_data'event) then
			-- if falling_edge(c_clk) and c_regWrite = '1' then
				write_reg: case i_write_reg is
					when "00"  	 =>	 s_reg0 <= i_write_data;
					when "01"  	 =>	 s_reg1 <= i_write_data;
					when "10"  	 =>	 s_reg2 <= i_write_data;
					when "11"  	 =>	 s_reg3 <= i_write_data;
					when others	 =>	 null;
				end case write_reg;
			end if;
		end if;
	end process;
	
end structural;
