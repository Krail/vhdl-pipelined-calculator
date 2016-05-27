library ieee;
use ieee.std_logic_1164.all;

-- Single-bit, 2-input XOR gate
entity xor2 is
	port(
		i_A	 : in  std_logic;
		i_B	 : in  std_logic;
		o_Z	 : out std_logic
	);
end xor2;

architecture structural of xor2 is
begin
	
	-- logic below
	process (i_A, i_B) is
	begin
		if (i_A = '0' and i_B = '1') or (i_A = '1' and i_B = '0') then
			o_Z <= '1';
		else
			o_Z <= '0';
		end if;
	end process;
	
end structural;