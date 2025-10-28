-----------------
-- vending_machine.vhdl
-- Paul Eickhoff
-- 10/30/2024
-- 
-- Vending Machine Logic System
-- V2.0
------------------------
-- Can you use a value that has been updated in the same process? Test experimentally
-- Can you pass set input / output values to something that is not logic_vector?
-- For example, can i set my output to be an unsigned value?
-- How would you implement multiple types of money being inputted at once? (in the money logic)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity vending_machine is

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
end entity;

architecture behavioral of vending_machine is

	-- Item Signals
	constant cost_chips		: natural := 50;
	constant cost_candy		: natural := 60;
	-- Assign each item to a "type" for comparison
	constant chips				: unsigned (1 downto 0) := to_unsigned(1,2);
	constant candy				: unsigned (1 downto 0) := to_unsigned(2,2);
	-- Item Type: Determines candy / chips. Item Cost: Determines Price
	signal 	item_type		: unsigned (1 downto 0); -- 4 bits, 2 item types
	signal 	item_cost 		: unsigned (7 downto 0);

	-- State Signals
	type statetype is (IDLE, CANCEL, MONEY_IN, SELECT_ITEM, VEND);
	signal state				: statetype;
	signal state_next			: statetype;
	signal money				: unsigned (7 downto 0);
	signal money_next			: unsigned (7 downto 0);

	-- Total Money and Coin Values
	signal coin_value			: unsigned(4 downto 0);
	constant nickle			: unsigned(4 downto 0) := to_unsigned(5,5); 
	constant dime				: unsigned(4 downto 0) := to_unsigned(10,5);
	constant quarter			: unsigned(4 downto 0) := to_unsigned(25,5);	
	
	-- All SSEG money is in binary
	constant dash:	std_logic_vector(7 downto 0) := "10111111";
	signal sseg_money_0		: std_logic_vector(7 downto 0);
	signal sseg_money_1		: std_logic_vector(7 downto 0);
	
	signal money_0 			: std_logic_vector(5 downto 0);
	signal money_1				: std_logic_vector(5 downto 0);
	
	--
	-- Components
	--
	component sseg_decoder
		port(
			i_sseg_in: 		in std_logic_vector(5 downto 0);
			o_sseg_out:		out std_logic_vector(7 downto 0)
		);
	end component;

begin
	-- Money Signal Conversion 
	-- money0 -> remainder(money,10) -> vector(remainder(money,10)
	
	-- Uses o_money instead of money, because money doesn't include the price display logic
	money_0 <= ("00" & std_logic_vector(o_money(3 downto 0)));
	money_1 <= ("00" & std_logic_vector(o_money(7 downto 4)));
	
	money0: sseg_decoder
		port map(
			i_sseg_in	=> money_0,
			
			o_sseg_out	=> sseg_money_0
		);
	money1: sseg_decoder
		port map(
			i_sseg_in	=> money_1,
			
			o_sseg_out	=> sseg_money_1
		);
	--
	-- NSL
	-- 
	process(all)
	begin
		-- Set state_next and money_next
		case state is 
			when IDLE =>
				if (i_money /= "000") then
					state_next <= MONEY_IN;
				else
					state_next <= IDLE;
				end if;
				
				money_next <= "00000000";
			when CANCEL =>
				state_next <= IDLE;
				
				money_next <= "00000000";
			when MONEY_IN =>
				if (i_item /= "00000") Then
					state_next <= SELECT_ITEM;
				elsif (i_cancel = '1') then
					state_next <= CANCEL;
				else
					state_next <= MONEY_IN;
				end if;
				
				money_next <= money + coin_value;
			when SELECT_ITEM =>
				-- if item is chips
				if (i_item(0) = '1' or i_item(1) = '1') then 
					if (money < item_cost) then
						state_next <= MONEY_IN;
					else
						state_next <= VEND;
					end if;
				-- if item is not chips (aka. candy)
				else
					if (money < item_cost) then
						state_next <= MONEY_IN;
					else
						state_next <= VEND;
					end if;
				end if;
				
				money_next <= money;
				
			when VEND =>
				state_next <= IDLE;
				
				money_next <= "00000000";
			when others =>
				state_next <= IDLE;
				
				money_next <= "00000000";
		end case;
	end process;
	
	--
	-- Register
	-- 
	process(i_clk, i_rstb) -- Register
	begin
		-- reset
		if (i_rstb = '0') then
			state <= IDLE;
			money <= (others => '0');
		elsif (rising_edge(i_clk)) then
			state <= state_next;
			money <= money_next;
		end if;
	end process;

	--
	-- Output Logic 1
	-- Determine Money and LEDs
	-- 
	process(all)
	begin
		case state is 
			when IDLE =>
			
				o_money <= "00000000";
				
				o_LED <= "00000";
			when CANCEL =>
			
				o_money <= "00000000";
				
				o_LED <= "11111";
				
			when MONEY_IN =>
				
				o_money <= money;
			
				o_LED <= "00000";
			when SELECT_ITEM =>
				
				if (money < item_cost) then
					if (item_type = chips) then
--						o_money <= to_unsigned(cost_chips,8);
						o_money <= item_cost;
					elsif (item_type = candy) then
--						o_money <= to_unsigned(cost_candy,8);
						o_money <= item_cost;
					else
						o_money <= item_cost;
					end if;
				else
					o_money <= item_cost;
				end if;
				-- Otherwise, keep displaying money and wait for VEND state
				o_LED <= "00000";
			when VEND =>
				
				o_money <= "00000000";
				
				if (i_item(0) = '1') then
					o_LED <= "00001";
				elsif (i_item(1) = '1') then
					o_LED <= "00010";
				elsif (i_item(2) = '1') then
					o_LED <= "00100";
				elsif (i_item(3) = '1') then
					o_LED <= "01000";
				elsif (i_item(4) = '1') then
					o_LED <= "10000";
				else
					o_LED <= "00000";
				end if;
			when others =>
				o_money <= "00000000";
				o_LED <= "01010"; --ERROR LEDS
		end case;
	end process;
	
	-- 
	-- Output Logic 2
	-- Determine HEX Outputs
	--
	process(all)
	begin
		case state is 
			when IDLE =>
			-- OFF
				o_HEX5 <= 8x"ff";
				o_HEX4 <= 8x"ff";
				o_HEX3 <= 8x"ff";
				o_HEX2 <= 8x"ff";
				o_HEX1 <= 8x"ff";
				o_HEX0 <= 8x"ff";

			when CANCEL =>
			-- Display CANCEL
				o_HEX5 <= "10100111";
				o_HEX4 <= "10001000";
				o_HEX3 <= "10101011";
				o_HEX2 <= "10100111";
				o_HEX1 <= "10000110";
				o_HEX0 <= "11000111";
				
			when MONEY_IN =>
			-- Display Money Inputted
				o_HEX5 <= 8x"ff";
				o_HEX4 <= 8x"ff";
				o_HEX3 <= sseg_money_1;
				o_HEX2 <= sseg_money_0;
				o_HEX1 <= 8x"ff";
				o_HEX0 <= 8x"ff";

			when SELECT_ITEM =>
			-- Display --XX--
				o_HEX5 <= dash;
				o_HEX4 <= dash;
				o_HEX3 <= sseg_money_1;
				o_HEX2 <= sseg_money_0;
				o_HEX1 <= dash;
				o_HEX0 <= dash;
				
			when VEND =>
			-- Display VEND
				o_HEX5 <= "11000001";
				o_HEX4 <= "10000110";
				o_HEX3 <= "10101011";
				o_HEX2 <= "10100001";
				o_HEX1 <= 8x"ff";
				o_HEX0 <= 8x"ff";
			
			when others =>
			-- Display ERROR
				o_HEX5 <= "10000110";
				o_HEX4 <= "10101111";
				o_HEX3 <= "10101111";
				o_HEX2 <= "10100011";
				o_HEX1 <= "10101111";
				o_HEX0 <= 8x"ff";

		end case;
	end process;	
	
	--
	-- Money Logic + Item Logic
	--
	process(all)
	begin 
	-- Item (set hard values to prevent double loading)
		if (i_item = "00001" or i_item = "00010") then
			item_type <= chips;
			item_cost <= to_unsigned(cost_chips,8);
		elsif (i_item = "00100" or i_item = "01000" or i_item = "10000") then
			item_type <= candy;
			item_cost <= to_unsigned(cost_candy,8);
		else
			item_type <= (others => '0');
			item_cost <= to_unsigned(255,8);
		end if;
	
	-- Money
		if (i_money(0) = '1') then
			coin_value <= nickle;
		elsif (i_money(1) = '1') then
			coin_value <= dime;
		elsif (i_money(2) = '1') then
			coin_value <= quarter;
		else
			coin_value <= (others => '0');
		end if;
	end process;
	
end architecture;
