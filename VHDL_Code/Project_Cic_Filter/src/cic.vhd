library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cic is

	generic(
		Nstages : integer := 4; -- N = 4
		Rfactor : integer := 4; -- R = 4
		Nbit    : integer := 16 -- Input and Output bits
	);
	port (
		clk    : in   std_logic;
		valid  : in   std_logic;
		input  : in   std_logic_vector(Nbit - 1 downto 0); -- 16 bit
		res    : in   std_logic;
		output : out  std_logic_vector(Nbit - 1 downto 0)  -- 16 bit
	);

end cic;

architecture cic_arch of cic is

-- Components declaration
component comb_section is
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
end component comb_section;

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

component integrator_section is
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
end component integrator_section;

-- Signals declaration
signal out_comb_section       : std_logic_vector(Nbit + (Nstages - 1) - 1 downto 0);     -- 19 bit
signal out_zero_insertion     : std_logic_vector(Nbit + (Nstages - 1) - 1 downto 0);     -- 19 bit
signal out_integrator_section : std_logic_vector(Nbit + (2 * Nstages - 2) - 1 downto 0); -- 22 bit
signal enabler                : std_logic;
signal counter                : integer;

begin

	-- Components Map and Processes
	comb_section_map: comb_section
		generic map(
			Nstages => Nstages,
			Rfactor => Rfactor,
			Nbit    => Nbit
		)
		port map(
			clk     => clk, 
			enabler => enabler, 
			input   => input,
			res     => res,
			output  => out_comb_section
		);

	zero_insertion_map: zero_insertion
		generic map(
			Nstages => Nstages,
			Rfactor => Rfactor,
			Nbit    => Nbit
			)
		port map(
			enabler => enabler,
			input   => out_comb_section,
			output  => out_zero_insertion
		);

	integrator_section_map: integrator_section
		generic map(
			Nstages => Nstages,
			Rfactor => Rfactor,
			Nbit    => Nbit
			)
		port map(
			clk     => clk, 
			enabler => enabler, 
			input   => out_zero_insertion,
			res     => res,
			output  => out_integrator_section
		);

	cic_process: process(clk, valid, res, enabler, counter)
	begin

		if (valid = '1') then -- The filter remains in steady state if valid = 0
			if (rising_edge(clk)) then -- When we have the rising edge
				if (res = '1') then -- We have a complete reset of the filter
					enabler <= '0';
					counter <= 0;
				elsif (counter = 3) then
					enabler <= '1';
					counter <= 0;
				else
					enabler <= '0';
					counter <= counter + 1;
				end if;
			end if;
		end if;

	end process cic_process;

	output <= out_integrator_section(Nbit + (2 * Nstages - 2) - 1 downto 6); -- MSB 16 bit

end cic_arch;