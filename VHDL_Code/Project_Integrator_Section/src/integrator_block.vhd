library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity integrator_block is

	generic(
		Nbit : integer
	);
	port (
		clk    : in   std_logic;
		input  : in   std_logic_vector(Nbit - 1 downto 0); -- Always a bit less than the output -> if 19 bit in -> 20 bit out
		res    : in   std_logic;
		output : out  std_logic_vector(Nbit downto 0)      -- Always a bit more than the input -> if 19 bit in -> 20 bit out
	);

end integrator_block;


architecture integrator_block_arch of integrator_block is

	component flipflop
		generic(
			Nbit : integer
		);
		port (
			clk         : in  std_logic;
			enabler     : in  std_logic;
			inputData   : in  std_logic_vector(Nbit - 1 downto 0);
			res         : in  std_logic;
			outputData  : out std_logic_vector(Nbit - 1 downto 0)
		);
	end component flipflop;

	signal data_flow : std_logic_vector(Nbit downto 0);
	signal save_data : std_logic_vector(Nbit downto 0);

begin

	-- Components Map
	flipflop_map: flipflop
		generic map(
			Nbit => Nbit + 1
		)
		port map(
			clk => clk,
			enabler => '1', -- Always active since working freq = clock
			inputData => data_flow,
			res => res,
			outputData => save_data
		);
	
	-- We need to resize the data at the since we are doing a N + J (since M = 1 it is the previous sample) to get a N + 1 bit signal
	data_flow <= std_logic_vector(resize(signed(input), Nbit + 1) + resize(signed(save_data), Nbit + 1));
	output <= data_flow;

end integrator_block_arch;
