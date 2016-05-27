library ieee;
use ieee.std_logic_1164.all;

-- if     i_SEL = 0  then o_Z <= i_A
-- elsif  i_SEL = 1  then o_Z <= i_B
-- else                   o_Z <= (others => 'X')
entity mux2 is
	generic (LENGTH : integer);
	port(
		i_A   : in  std_logic_vector (LENGTH-1 downto 0);
		i_B   : in  std_logic_vector (LENGTH-1 downto 0);
		i_SEL : in  std_logic;
		o_Z   : out std_logic_vector (LENGTH-1 downto 0)
	);
end mux2;

architecture behavioral of mux2 is
begin
	mux_proc: process (i_A, i_B, i_SEL) is
	begin
		mux_case: case i_SEL is
			when '0' =>
				o_Z <= i_A;
			when '1' =>
				o_Z <= i_B;
			when others =>
				o_Z <= (others => 'X');
		end case mux_case;
	end process mux_proc;
end behavioral;
