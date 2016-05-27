library ieee;
use ieee.std_logic_1164.all;

-- OUT_WORD_LENGTH must be greater than IN_WORD_LENGTH !!!
entity sign_extend is
	generic (IN_WORD_LENGTH  : integer;
	         OUT_WORD_LENGTH : integer);
	port(
		i_A   : in  std_logic_vector (IN_WORD_LENGTH-1 downto 0);
		o_Z   : out std_logic_vector (OUT_WORD_LENGTH-1 downto 0)
	);
end sign_extend;

architecture behavioral of sign_extend is
begin
	sign_extend_proc: process (i_A) is
		variable v_sign_extension : std_logic_vector (OUT_WORD_LENGTH-IN_WORD_LENGTH-1 downto 0);
	begin
		v_sign_extension := (others => i_A(IN_WORD_LENGTH-1));
		o_Z <= v_sign_extension & i_A;
	end process sign_extend_proc;
end behavioral;
