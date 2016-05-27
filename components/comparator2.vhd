library ieee;
use ieee.std_logic_1164.all;

-- 2-input Comparator
--   o_Z = "00" if i_A = i_A    (zero)
--         "10" elsif i_A < i_B (negative)
--         "01" elsif i_A > i_B (positive)
--         "XX" else            (undefined)
entity comparator2 is
	generic (LENGTH : integer);
	port(
		i_A	 : in  std_logic_vector (LENGTH-1 downto 0);
		i_B	 : in  std_logic_vector (LENGTH-1 downto 0);
		o_A	 : out std_logic_vector (LENGTH-1 downto 0);
		o_Z	 : out std_logic_vector (1 downto 0)
	);
end comparator2;

architecture structural of comparator2 is

	function is_valid(i_A, i_B : std_logic_vector) return boolean is
	begin
		-- i_A'range = i_B'range
		for i in i_A'range loop
			if (i_A(i) /= '0' and i_A(i) /= '1')
					or (i_B(i) /= '0' and i_B(i) /= '1') then
				return false;
			end if;
		end loop;
		return true;
	end function;

begin
	
	-- logic below
	process (i_A, i_B) is
	begin
		if is_valid(i_A, i_B) then
			if i_A = i_B then
				o_Z <= "00";
			elsif i_A < i_B then
				o_Z <= "10";
			elsif i_A > i_B then
				o_Z <= "01";
			else
				o_Z <= "XX";
			end if;
		else
			o_Z <= "XX";
		end if;
		o_A <= i_A;
	end process;
	
end structural;