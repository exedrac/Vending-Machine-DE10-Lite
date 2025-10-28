-------------------
--
-- clock_divider.vhdl
--
-- 10/2/2024
-- Paul Eickhoff
--
-------------------
-- divide clock with 50MHz external
-- Inputs: rstb, clk_50MHz
-- Outputs: clk_1Hz
-------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity clock_divider is
	generic(
		frequency: natural := 1
	);
	port(
		i_clk_50MHz	:	in std_logic;
		i_rstb		:	in std_logic;
		
		o_clk			:	out std_logic
	);
end entity;

architecture behavioral of clock_divider is
		constant INPUT_FREQUENCY: natural := 50_000_000;
		constant OUTPUT_FREQUENCY: natural := frequency; -- Set Clock Frequency
		constant num_bits: natural := natural(ceil(log2(real(INPUT_FREQUENCY / OUTPUT_FREQUENCY))))+1; -- +1 to add the unsigned bit
		constant CLKS_PER_HALF_PERIOD: signed (num_bits downto 0) := to_signed(((INPUT_FREQUENCY/2)/OUTPUT_FREQUENCY), num_bits+1);
		
		signal cnt:	signed (num_bits downto 0);
		signal clk_sig: std_logic;
begin
	process (i_clk_50MHz, i_rstb)
		begin
		--reset
		if (i_rstb = '0') then
			cnt <= (CLKS_PER_HALF_PERIOD - 1);
			clk_sig <= '0';
		elsif (rising_edge(i_clk_50MHz) ) then
			cnt <= cnt - 1;
			
			-- check if half 
			if (cnt<0) then
				cnt<=((CLKS_PER_HALF_PERIOD-1)-1);
				clk_sig <= not clk_sig;
			end if;
		end if;
	end process;
	
	o_clk <= clk_sig;
end behavioral;
