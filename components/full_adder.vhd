library ieee;
use ieee.std_logic_1164.all;

entity full_adder is 
	port(
		i_A    	 : in  std_logic;
		i_B    	 : in  std_logic;
		i_carry	 : in  std_logic;
		o_Z    	 : out std_logic;
		o_carry	 : out std_logic
	);
end full_adder;

architecture structural of full_adder is
	
	component half_adder
		port(
			i_A    	 : in  std_logic;
			i_B    	 : in  std_logic;
			o_Z    	 : out std_logic;
			o_carry	 : out std_logic
		);
	end component;
	component or2
		port(
			i_A    	 : in  std_logic;
			i_B    	 : in  std_logic;
			o_Z    	 : out std_logic
		);
	end component;
	
	signal s_Z : std_logic := 'X';
	signal s_carry_out_0 : std_logic := 'X';
	signal s_carry_out_1 : std_logic := 'X';
	
begin
	
	half_adder_0: half_adder
		port map (
			i_A    	 => i_A,
			i_B    	 => i_B,
			o_Z    	 => s_Z,
			o_carry	 => s_carry_out_0
		);
	half_adder_1: half_adder
		port map (
			i_A    	 => s_Z,
			i_B    	 => i_carry,
			o_Z    	 => o_Z,
			o_carry	 => s_carry_out_1
		);
	or2_0: or2
		port map (
			i_A    	 => s_carry_out_1,
			i_B    	 => s_carry_out_0,
			o_Z    	 => o_carry
		);
	
end structural;