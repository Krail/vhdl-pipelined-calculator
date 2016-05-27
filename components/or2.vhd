library ieee;
use ieee.std_logic_1164.all;

-- Single-bit, 2-input OR gate
entity or2 is
	port(
		i_A	 : in  std_logic;
		i_B	 : in  std_logic;
		o_Z	 : out std_logic
	);
end or2;

architecture structural of or2 is
begin
	
	-- logic below
	process (i_A, i_B) is
	begin
		if i_A = '1' or i_B = '1' then
			o_Z <= '1';
		else
			o_Z <= '0';
		end if;
	end process;
	
end structural;