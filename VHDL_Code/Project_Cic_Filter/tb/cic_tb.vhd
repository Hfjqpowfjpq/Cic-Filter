library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity cic_tb is
end cic_tb;

architecture arch of cic_tb is

	constant T_clk      : time      := 25 ns;
	constant Nstages_tb : integer   := 4;
	constant Rfactor_tb : integer   := 4;
  	constant N_tb       : integer   := 16;
  	signal clk_tb       : std_logic := '0';
	signal valid_tb     : std_logic := '1';
	signal input_tb     : std_logic_vector(N_tb - 1 downto 0) := "0000000000000000"; --Input
	signal res_tb       : std_logic := '1';
	signal output_tb    : std_logic_vector(N_tb - 1 downto 0); -- Output
	signal end_sim      : std_logic := '1';  -- Signal to use to stop the simulation when there is nothing else to test

	component cic is
		generic(
			Nstages : integer;
			Rfactor : integer;
			Nbit    : integer
		);
		port (
			clk    : in   std_logic;
			valid  : in   std_logic;
			input  : in   std_logic_vector(Nbit - 1 downto 0);
			res    : in   std_logic;
			output : out  std_logic_vector(Nbit - 1 downto 0)
		);
	end component cic;

	type lut_t is array(natural range <>) of integer;
	constant lut : lut_t(0 to 49) := (
		0, 7927, 15383, 21925, 27165, 30790, 32587, 32448, 30381, 26509, 21062, 14364, 6812, -1143, -9031, -16383,
		-22761, -27787, -31163, -32687, -32269, -29934, -25820, -20173, -13327, -5689, 2285, 10125, 17363, 23570,
		28377, 31497, 32747, 32050, 29450, 25100, 19259, 12274, 4560, -3425, -11206, -18323, -24350, -28931, -31793,
		-32767, -31793, -28931, -24350, -18323 -- 4pi divide by 49 samples (16 bit in)
	);

	signal index   : integer := 0;
	signal counter : integer := 0;

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_clk/2; -- Clock signal
	res_tb <= '0' after 1 * T_clk;
	-- valid_tb <= '0' after 32 * T_clk; -- I block the circuit

	cic_map: cic
		generic map(
			Nstages => Nstages_tb,
			Rfactor => Rfactor_tb,
			Nbit => N_tb
		)
		port map(
			clk => clk_tb,
			valid => valid_tb, 
			input => input_tb,
			res => res_tb,
			output => output_tb
		);

	process(clk_tb, input_tb) begin
		
		if (rising_edge(clk_tb)) then 
			if (valid_tb = '1') then -- The filter remains in steady state if valid = 0
				if (res_tb = '1') then
					index <= 0;
					counter <= 0;
					input_tb <= (others => '0');
				else
					if(counter = 4) then
						input_tb <= std_logic_vector(to_signed(lut(index),input_tb'length));
						if(index < 49) then
							index <= index + 1;
						else
							end_sim <= '0';
						end if;
						counter <= 0;
					else
						counter <= counter + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

end arch;
