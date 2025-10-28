------------
-- vending_machine_de10.vhdl
-- Paul Eickhoff
-- 10/30/2024
-- 
-- Vending Machine DE10 Implementation
-- V2.0
------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity vending_machine_de10 is
	generic(
		frequency: natural := 1
	);
	port(
		CLOCK_50:	in		std_logic;
		SW:			in		std_logic_vector(8 downto 0); 
		HEX0:			out	std_logic_vector(7 downto 0);
		HEX1:			out	std_logic_vector(7 downto 0);
		HEX2:			out	std_logic_vector(7 downto 0);
		HEX3: 		out	std_logic_vector(7 downto 0);
		HEX4:			out	std_logic_vector(7 downto 0); 
		HEX5:			out	std_logic_vector(7 downto 0); 
		LEDR:			out 	std_logic_vector(4 downto 0) 
	);
end entity;

architecture behavioral of vending_machine_de10 is

	signal CLKSIG: 				std_logic;
	signal RST:						std_logic;

	component clock_divider
		generic ( 
			frequency: natural := 1
			);
		port(
			i_clk_50MHz	:	IN	STD_LOGIC;
			i_rstb		:	IN STD_LOGIC;
			o_clk			:	OUT STD_LOGIC
			);
	end component;

	-- Elevator Logic
	component vending_machine
	port(
		i_rstb		: in std_logic;
		i_clk			: in std_logic;
		i_money		: in std_logic_vector(2 downto 0); 	-- SW(2-0)
		i_cancel		: in std_logic; 							-- SW(3)
		i_item		: in std_logic_vector(4 downto 0);	-- SW(8-4)
		
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
	RST <= '1';
	
	CK0: clock_divider
		generic map(
			frequency =>  1
		)
		port map(
			i_clk_50MHz	=>	CLOCK_50,
			i_rstb		=>	RST,
			o_clk			=>	CLKSIG
		);
		
	VENDING: vending_machine
	port map(
		i_rstb		=> RST,
		i_clk			=> CLKSIG,
		i_money		=> SW(2 downto 0), -- SW(2-0)
		i_cancel		=> SW(3),				-- SW(3)
		i_item		=> SW(8 downto 4),	-- SW(8-4)

		o_HEX0 		=> HEX0,
		o_HEX1 		=> HEX1,
		o_HEX2 		=> HEX2,
		o_HEX3 		=> HEX3,
		o_HEX4 		=> HEX4,
		o_HEX5 		=> HEX5,
		-- LED Lights
		o_LED			=> LEDR(4 downto 0)	-- LED(4-0)
	);		
end architecture;

