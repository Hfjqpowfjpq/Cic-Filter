library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity zero_insertion_tb is
end zero_insertion_tb;

architecture arch of zero_insertion_tb is

	constant T_clk      : time      := 100 ns;
	constant Nbit_tb    : integer   := 4;
	constant Rfactor_tb : integer   := 4;
	constant Nstages_tb : integer   := 4;
	signal index        : integer   := 0;
  	signal clk_tb       : std_logic := '0';
  	signal enabler_tb   : std_logic := '0';
	signal res_tb       : std_logic := '1';
	signal input_tb     : std_logic_vector(Nbit_tb + (Nstages_tb - 1) - 1 downto 0) := "0000000";
	signal output_tb    : std_logic_vector(Nbit_tb + (Nstages_tb - 1) - 1 downto 0);
	signal end_sim      : std_logic := '1';

	component zero_insertion is
		generic(
			Nstages : integer;
			Rfactor : integer;
			Nbit    : integer
			);
		port (
			enabler : in  std_logic;
			input   : in  std_logic_vector(Nbit + (Nstages - 1) - 1 downto 0); -- 19 bit
			output  : out std_logic_vector(Nbit + (Nstages - 1) - 1 downto 0)  -- 19 bit
		);
	end component zero_insertion;

	type lut_t is array(natural range <>) of integer;
	constant lut : lut_t(0 to 9) := (1, 1, 1, 1, 1, 1, 1, 1, 1, 1);

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_clk/2;
	res_tb <= '0' after 2*T_clk;

	zero_insertion_map: zero_insertion
	generic map(
		Nstages => Nstages_tb,
		Rfactor => Rfactor_tb,
		Nbit => Nbit_tb
		)
		port map(
			enabler => enabler_tb,
			input => input_tb,
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

				if (index = 3 or index = 6) then 
					enabler_tb <= '0';
				else 
					enabler_tb <= '1';
				end if;
			end if;
		end process;

end arch;
