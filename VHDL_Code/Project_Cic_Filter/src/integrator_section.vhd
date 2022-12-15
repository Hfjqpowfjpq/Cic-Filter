library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity integrator_section is

	generic(
		Nstages : integer;
		Rfactor : integer;
		Nbit    : integer
		);
	port (
		clk     : in   std_logic;
		enabler : in   std_logic;
		input   : in   std_logic_vector(Nbit + (Nstages - 1) - 1 downto 0);    -- 19 bit
		res     : in   std_logic;
		output	: out  std_logic_vector(Nbit + (2 * Nstages - 2) - 1 downto 0) -- 22 bit
	);

end integrator_section;

architecture integrator_section_arch of integrator_section is

	component integrator_block is
		generic(
			Nbit : integer
		);
		port (
			clk    : in   std_logic;
			input  : in   std_logic_vector(Nbit - 1 downto 0); -- Always a bit less than the output -> if 19 bit in -> 20 bit out
			res    : in   std_logic;
			output : out  std_logic_vector(Nbit downto 0)      -- Always a bit more than the input -> if 19 bit in -> 20 bit out
		);
	end component integrator_block;

	signal integrator_block_out_0 : std_logic_vector(Nbit + 3 downto 0); -- 20 bit
	signal integrator_block_out_1 : std_logic_vector(Nbit + 4 downto 0); -- 21 bit
	signal integrator_block_out_2 : std_logic_vector(Nbit + 5 downto 0); -- 22 bit
	signal integrator_block_out_3 : std_logic_vector(Nbit + 6 downto 0); -- 23 bit

begin

	integrator_block_map_0: integrator_block
		generic map(
			Nbit => Nbit + 3
		)
		port map(
			clk => clk,
			input => input,
			res => res,
			output => integrator_block_out_0
		);

	integrator_block_map_1: integrator_block
		generic map(
			Nbit => Nbit + 4
		)
		port map(
			clk => clk,
			input => integrator_block_out_0,
			res => res,
			output => integrator_block_out_1
		);

	integrator_block_map_2: integrator_block
		generic map(
			Nbit => Nbit + 5
		)
		port map(
			clk => clk,
			input => integrator_block_out_1,
			res => res,
			output => integrator_block_out_2
		);

	integrator_block_map_3: integrator_block
		generic map(
			Nbit => Nbit + 6
		)
		port map(
			clk => clk,
			input => integrator_block_out_2,
			res => res,
			output => integrator_block_out_3
		);

	output <= integrator_block_out_3(Nbit + (6 - 1)  downto 0); -- Truncation of the MSB -> 22 bit

end integrator_section_arch;
