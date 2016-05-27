library ieee;
use ieee.std_logic_1164.all;

-- LENGTH must be greater than 2 !!! (haven't tested this yet)
-- c_op = 0 for add
-- c_op = 1 for sub
entity add2 is
	generic (LENGTH : integer);
	port(
		c_op  	 : in  std_logic;
		i_A   	 : in  std_logic_vector (LENGTH-1 downto 0);
		i_B   	 : in  std_logic_vector (LENGTH-1 downto 0);
		o_Z   	 : out std_logic_vector (LENGTH-1 downto 0) := (others => 'X');
		o_flow	 : out std_logic
	);
end add2;

architecture structural of add2 is
	
	component xor2
		port(
			i_A	 : in  std_logic;
			i_B	 : in  std_logic;
			o_Z	 : out std_logic
		);
	end component;
	component full_adder
		port(
			i_A    	 : in  std_logic;
			i_B    	 : in  std_logic;
			i_carry	 : in  std_logic;
			o_Z    	 : out std_logic;
			o_carry	 : out std_logic
		);
	end component;
	
	signal s_B_full_adder : std_logic_vector (LENGTH-1 downto 0) := (others => 'X');
	signal s_carry_out : std_logic_vector (LENGTH-1 downto 0) := (others => 'X');
	
begin
	
	-- Determines if over/underflow occurred
	xor2_carry: xor2
		port map (
			i_A => s_carry_out(LENGTH-1),
			i_B => s_carry_out(LENGTH-2),
			o_Z => o_flow
		);
	
	generate_components:
		for i in 0 to LENGTH-1 generate
			-- Performs Twos Complement if subtracting (c_op = 1)
			xor2_i: xor2
				port map (
					i_A => c_op,
					i_B => i_B(i),
					o_Z => s_B_full_adder(i)
				);
			first_full_adder: if i = 0 generate  -- first full adder is special
				full_adder_0: full_adder
					port map (
						i_A    	 => i_A(i),
						i_B    	 => s_B_full_adder(i),
						i_carry	 =>	c_op,             	 -- !!
						o_Z    	 => o_Z(i),
						o_carry	 => s_carry_out(i)
					);
			end generate first_full_adder;
			i_full_adder: if i > 0 generate      -- other full adders are identical
				full_adder_i: full_adder
					port map (
						i_A    	 => i_A(i),
						i_B    	 => s_B_full_adder(i),
						i_carry	 =>	s_carry_out(i-1), 	 -- !!
						o_Z    	 => o_Z(i),
						o_carry	 => s_carry_out(i)
					);
			end generate i_full_adder;
		end generate generate_components;
	
end structural;