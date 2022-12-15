library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comb_section is

	generic(
		Nstages : integer;
		Rfactor : integer;
		Nbit    : integer
		);
	port (
		clk     : in   std_logic;
		enabler : in   std_logic;
		input   : in   std_logic_vector(Nbit - 1 downto 0);                -- 16 bit
		res     : in   std_logic;
		output  : out  std_logic_vector(Nbit + (Nstages - 1) - 1 downto 0) -- 19 bit
	);
	
end comb_section;

architecture comb_section_arch of comb_section is

	-- Components declaration
	component comb_block is
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
	end component comb_block;

	--Singals declaration
	-- Since we have N = 4 we will be having 4 outsignals, one from each comb_block
	signal comb_block_out_0 : std_logic_vector(Nbit downto 0);     -- 17 bit
	signal comb_block_out_1 : std_logic_vector(Nbit + 1 downto 0); -- 18 bit
	signal comb_block_out_2 : std_logic_vector(Nbit + 2 downto 0); -- 19 bit
	signal comb_block_out_3 : std_logic_vector(Nbit + 3 downto 0); -- 20 bit <-- This must be truncated at the exit of the Comb section

begin

	-- Components Map
	comb_block_0_map: comb_block
		generic map(
			Nbit => Nbit
		)
		port map(
			clk     => clk ,
			enabler => enabler,
			input   => input,
			res     => res,
			output  => comb_block_out_0
		);

	comb_block_1_map: comb_block
		generic map(
			Nbit => Nbit + 1
			)
		port map(
			clk     => clk,
			enabler => enabler,
			input   => comb_block_out_0,
			res     => res,
			output  => comb_block_out_1
		);

	comb_block_2_map: comb_block
		generic map(
			Nbit => Nbit + 2
			)
		port map(
			clk     => clk,
			enabler => enabler,
			input   => comb_block_out_1,
			res     => res,
			output  => comb_block_out_2
		);

	comb_block_3_map: comb_block
		generic map(
			Nbit => Nbit + 3
		)
		port map(
			clk     => clk,
			enabler => enabler,
			input   => comb_block_out_2,
			res     => res,
			output  => comb_block_out_3
		);

	output <= comb_block_out_3(Nbit + (3 - 1) downto 0); -- Truncation of the MSB -> 19 bit

end comb_section_arch;