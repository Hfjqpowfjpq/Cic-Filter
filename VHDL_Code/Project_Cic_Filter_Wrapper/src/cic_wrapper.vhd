library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cic_wrapper is
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
end cic_wrapper;

architecture cic_wrapper_arch of cic_wrapper is

    component cic is
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
    end component;

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
    end component;

    signal out_flipflop_0 : std_logic_vector(Nbit - 1 downto 0);
    signal out_flipflop_1 : std_logic_vector(Nbit - 1 downto 0);
    signal out_cic      : std_logic_vector(Nbit - 1 downto 0);

begin

    flipflop_0_map : flipflop
        generic map(
            Nbit => Nbit
        )
        port map(
            clk => clk,
            enabler => '1',
            inputData => input,
            res => res,
            outputData => out_flipflop_0
        );

    cic_map : cic
        generic map(
            Nstages => Nstages,
            Rfactor => Rfactor,
            Nbit => Nbit
        )
        port map(
            clk => clk,
            valid => valid,
            input => out_flipflop_0,
            res => res,
            output => out_cic
        );

    flipflop_1_map : flipflop
        generic map(
            Nbit => Nbit
        )
        port map(
            clk => clk,
            enabler => '1',
            inputData => out_cic,
            res => res,
            outputData => out_flipflop_1
        );

    output <= out_flipflop_1;

end cic_wrapper_arch;