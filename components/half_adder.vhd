library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
	port(
		i_A    	 : in  std_logic;
		i_B    	 : in  std_logic;
		o_Z    	 : out std_logic;
		o_carry	 : out std_logic
	);
end half_adder;

architecture structural of half_adder is
	
	component and2
		port(
			i_A   : in  std_logic;
			i_B   : in  std_logic;
			o_Z   : out std_logic
		);
	end component;
	component xor2
		port(
			i_A   : in  std_logic;
			i_B   : in  std_logic;
			o_Z   : out std_logic
		);
	end component;
	
begin
	
	and2_0: and2
		port map (
			i_A => i_A,
			i_B => i_B,
			o_Z => o_carry
		);
	xor2_0: xor2
		port map (
			i_A => i_A,
			i_B => i_B,
			o_Z => o_Z
		);
	
end structural;