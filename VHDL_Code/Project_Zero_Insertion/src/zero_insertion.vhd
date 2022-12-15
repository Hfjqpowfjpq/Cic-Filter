library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity zero_insertion is

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

end zero_insertion;

architecture zero_insertion_arch of zero_insertion is

begin

	output <= input when enabler = '1' else (others => '0');

end zero_insertion_arch;
