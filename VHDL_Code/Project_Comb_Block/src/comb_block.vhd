library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comb_block is

	generic(
		Nbit : integer
		);
	port (
		clk     : in   std_logic;
		enabler : in   std_logic;
		input   : in   std_logic_vector(Nbit - 1 downto 0); -- Always a bit less than the output -> if 16 bit in -> 17 bit out
		res     : in   std_logic;
		output  : out  std_logic_vector(Nbit downto 0)    -- Always a bit more than the input -> if 16 bit in -> 17 bit out
	);

end comb_block;


architecture comb_block_arch of comb_block is

	-- Components declaration
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

	-- Signals declaration
	signal data_flow : std_logic_vector(Nbit - 1 downto 0);

begin

	-- Components Map
	flipflop_map: flipflop
		generic map(
			Nbit => Nbit
		)
		port map(
			clk => clk,
			enabler => enabler,
			inputData => input,
			res => res,
			outputData => data_flow
		);

	-- We need to resize the data at the since we are doing a N - N (since M = 1 it is the previous sample) to get a N + 1 bit signal
	output <= std_logic_vector(resize(signed(input),Nbit + 1) - resize(signed(data_flow),Nbit + 1));

end comb_block_arch;
