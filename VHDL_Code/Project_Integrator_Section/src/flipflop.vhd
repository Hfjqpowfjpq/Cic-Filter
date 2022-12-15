library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity flipflop is

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

end flipflop;

architecture flipflop_arch of flipflop is

begin

	registerProcess: process(clk, inputData, res) begin
		if (rising_edge(clk)) then
			if (res = '1') then
				outputData <= (others => '0');
			else
				if (enabler = '1') then
					outputData <= inputData;
				end if;
			end if;
		end if;
	end process registerProcess;

end flipflop_arch;
