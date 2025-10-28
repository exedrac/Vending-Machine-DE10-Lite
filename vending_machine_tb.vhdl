-------------------
-- vending_machine_tb.vhdl
-- Paul Eickhoff
-- 10/30/2024
-- 
-- V2.0
-------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity vending_machine_tb is
	generic(
		frequency: natural := 1
	);
end entity;

architecture testbench of vending_machine_tb is

		constant	PER: time := 20 ns;

		signal RSTB					: 	std_logic;
		signal CLK					:	std_logic;
		signal CANCEL				:	std_logic;
		signal MONEY				:	std_logic_vector(2 downto 0);
		signal ITEM					: 	std_logic_vector(4 downto 0);
		signal LED					: 	std_logic_vector(4 downto 0);
		signal HEX0					:	std_logic_vector(7 downto 0);
		signal HEX1					:	std_logic_vector(7 downto 0);
		signal HEX2					:	std_logic_vector(7 downto 0);
		signal HEX3					:	std_logic_vector(7 downto 0);
		signal HEX4					:	std_logic_vector(7 downto 0);
		signal HEX5					:	std_logic_vector(7 downto 0);

		component vending_machine
		port(
			i_rstb		: in std_logic;
			i_clk			: in std_logic;
			i_money		: in std_logic_vector(2 downto 0); 	-- SW(2-0)
			i_cancel		: in std_logic; 							-- SW(3)
			i_item		: in std_logic_vector(4 downto 0);	-- SW(8-4)
			o_money 		: out unsigned(7 downto 0);
		
			-- HEX values require a mixed code structure (behavioral and architectural)
			-- Allows for states to be used with decoder
			o_HEX0 		: out std_logic_vector (7 downto 0);
			o_HEX1 		: out std_logic_vector (7 downto 0);
			o_HEX2 		: out std_logic_vector (7 downto 0);
			o_HEX3 		: out std_logic_vector (7 downto 0);
			o_HEX4 		: out std_logic_vector (7 downto 0);
			o_HEX5 		: out std_logic_vector (7 downto 0);
			-- LED Lights
			o_LED			: out std_logic_vector(4 downto 0)	-- LED(4-0)
		);
		end component;

begin
	DUT: vending_machine
	port map (
			i_rstb	 	=> RSTB,
			i_clk			=> CLK,
			i_cancel		=> CANCEL,
			i_money		=> MONEY,
			i_item 		=> ITEM,
			
			o_HEX0 		=> HEX0,
			o_HEX1		=> HEX1,
			o_HEX2		=> HEX2,
			o_HEX3		=> HEX3,
			o_HEX4		=> HEX4,
			o_HEX5		=> HEX5,
			o_LED			=> LED	
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
		-- Needs an extra +1 if going from IDLE to MONEYIN
		-- ResetB
		wait for 2*PER;
		RSTB <= '1';
		
		-- 5 Dimes, Chip 1
		wait for 3*PER;
		RSTB <= '0';
		wait for 1*PER;
		RSTB <= '1';
		MONEY <= "000";
		ITEM <= "00000";
		wait for 2*PER;
		
		MONEY <= "010";
		wait for 5*PER;
		ITEM <= "00001";
		
		-- 4 Dimes, 5 Nickels, Candy 2
		wait for 3*PER;
		RSTB <= '0';
		wait for 1*PER;
		RSTB <= '1';
		MONEY <= "000";
		ITEM <= "00000";
		wait for 2*PER;
		
		MONEY <= "010";
		wait for (4+1)*PER;
		MONEY <= "011";
		wait for (5-1)*PER;
		ITEM <= "01000";
		
		-- 2 Quarters, Candy 1, 1 Dime, Candy 1
		wait for 3*PER;
		RSTB <= '0';
		wait for 1*PER;
		RSTB <= '1';
		MONEY <= "000";
		ITEM <= "00000";
		wait for 3*PER;
		
		MONEY <= "100";
		wait for (2+1)*PER;
		MONEY <= "000";
		ITEM <= "00100";
		wait for 2*PER;
		MONEY <= "010";
		wait for (1+1)*PER;
		ITEM <= "00100";
		
		-- 1 Nickle, 1 Dime, 1 Quarter, Chip 2, 1 Nickel, Chip 2, Cancel
		wait for 3*PER;
		RSTB <= '0';
		wait for 1*PER;
		RSTB <= '1';
		MONEY <= "000";
		ITEM <= "00000";
		wait for 3*PER;
		
		MONEY <= "001";
		wait for (1+1)*PER;
		MONEY <= "010";
		wait for 1*PER;
		MONEY <= "100";
		
		wait for 1*PER;
		MONEY <= "000";
		ITEM <= "00010";
		wait for (1+1)*PER;
		MONEY <= "001";
		ITEM <= "00000";
		wait for 1*PER;
		MONEY <= "000";
		ITEM <= "00010";
		wait for 2*PER;
		ITEM <= "00000";
		CANCEL <= '1';
			
	end process;
end architecture;
	
	
	