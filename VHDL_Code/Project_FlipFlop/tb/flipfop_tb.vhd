library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity flipflop_tb is
end flipflop_tb;

architecture arch of flipflop_tb is

	constant T_clk       : time      := 100 ns;
	constant Nbit_tb     : integer   := 4;
	signal index         : integer   := 0;
  	signal clk_tb        : std_logic := '0';
	signal enabler_tb    : std_logic := '1';
  	signal res_tb        : std_logic := '1';
	signal inputData_tb  : std_logic_vector(Nbit_tb-1 downto 0) := "0000";
	signal outputData_tb : std_logic_vector(Nbit_tb-1 downto 0);
	signal end_sim       : std_logic := '1';

	component flipflop is
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

	type lut_t is array(natural range <>) of integer;
	constant lut : lut_t(0 to 9) := (0, 1, 2 ,4 , 8, 4, 2, 1, 0, 1);

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_clk/2;
	res_tb <= '0' after T_clk;

	flipflop_map: flipflop
	generic map(
		Nbit => Nbit_tb
		)
		port map(
			clk => clk_tb,
			enabler => enabler_tb,
			inputData => inputData_tb,
			res => res_tb,
			outputData => outputData_tb
		);

	process(clk_tb, inputData_tb) begin
		if (rising_edge(clk_tb)) then
			if (res_tb = '1') then
				index <= 0;
				inputData_tb <= (others => '0');
			else
				if (index < 9) then 
					inputData_tb <= std_logic_vector(to_unsigned(lut(index),inputData_tb'length));
					index <= index + 1;
				else 
					end_sim <= '0';
				end if;
			end if;
		end if;
	end process;

end arch;
