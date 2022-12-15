library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity integrator_block_tb is


end integrator_block_tb;

architecture arch of integrator_block_tb is

	constant T_clk   : time      := 100 ns;
	constant Nbit_tb : integer   := 4;
	signal index     : integer   := 0;
  	signal clk_tb    : std_logic := '0';
  	signal res_tb    : std_logic := '1';
	signal input_tb  : std_logic_vector(Nbit_tb - 1 downto 0) := "0000";
	signal output_tb : std_logic_vector(Nbit_tb downto 0);
	signal end_sim   : std_logic := '1';

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

	type lut_t is array(natural range <>) of integer;
	constant lut : lut_t(0 to 9) := (-1, 2, -1, 2, -1, 2, -1, 2, -1, 2);

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_clk/2;
	res_tb <= '0' after T_clk;

	integrator_block_map: integrator_block
	generic map(
		Nbit => Nbit_tb
	)
	port map(
		clk => clk_tb,
		input => input_tb,
		res => res_tb,
		output => output_tb
	);

	process(clk_tb, input_tb) begin
		if (rising_edge(clk_tb)) then
			if (res_tb = '1') then
				index <= 0;
				input_tb <= (others => '0');
			else
				if (index < 9) then 
					input_tb <= std_logic_vector(to_signed(lut(index),input_tb'length));
					index <= index + 1;
				else 
					end_sim <= '0';
				end if;
			end if;
		end if;
	end process;

end arch;
