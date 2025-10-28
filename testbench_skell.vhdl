-------------------
--
-- testbench_skell_tb.vhdl
-- Paul Eickhoff
-- 
-------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity testbench_skell_tb is
	generic(
		frequency: natural := 5
	);
end entity;

architecture testbench of testbench_skell_tb is

		constant	PER: time := 20 ns;

		signal RSTB					: 	std_logic;
		signal CLK					:	std_logic;
		signal DESIRED				:	std_logic_vector(7 downto 0);
		signal ACTUAL				:	std_logic_vector(7 downto 0);
		signal FAN_SPEED			: 	std_logic_vector(1 downto 0);
		signal HEAT					: 	std_logic;
		signal COOL					:	std_logic;

		component HW8
		port(
			i_rstb:			in std_logic; 
			i_clk: 			in std_logic;
			i_desired: 		in std_logic_vector(7 downto 0);
			i_actual: 		in std_logic_vector(7 downto 0); 
		
			o_fan_speed: 	out std_logic_vector(1 downto 0);
			o_heat: 			out std_logic; 
			o_cool: 			out std_logic 
		);

		end component;

begin
	DUT: HW8
	port map (
			i_rstb	 	=> RSTB,
			i_clk			=> CLK,
			i_desired	=> DESIRED,
			i_actual		=> ACTUAL,
		
			o_fan_speed	=> FAN_SPEED,
			o_heat		=> HEAT,
			o_cool		=> COOL
	);
	
	-- CLOCK
	clock:process
	begin
		CLK <= '0';
		wait for PER/2;
		infinite: loop
			CLK <= not CLK;
			wait for PER/2;
		end loop;
	end process;
	
	-- Device Under Test
	test:process
	begin
		-- ResetB
		wait for 2*PER;
		RSTB <= '1';
		
		-- Stuff to test
		DESIRED <= std_logic_vector(to_signed(25,8));
		for i in 10 to 40 loop
			ACTUAL <= std_logic_vector(to_signed(i,8));
			wait for 4*PER;
		end loop;
	end process;
end architecture;
	
	
	