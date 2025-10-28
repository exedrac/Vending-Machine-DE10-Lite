library ieee;
use ieee.std_logic_1164.all;
entity sseg_decoder is
	port(
		i_sseg_in: 		in std_logic_vector(5 downto 0);
		o_sseg_out:		out std_logic_vector(7 downto 0)
	);
end entity sseg_decoder;

architecture behavioral of sseg_decoder is
begin
	with i_sseg_in select
	
	o_sseg_out <= 
		
		8X"c0" when 6X"00",
		8X"f9" when 6X"01",
		8X"a4" when 6X"02",
		8X"b0" when 6X"03",
		8X"99" when 6X"04",
 
		"10010010" when 6x"05", 
		"10000010" when 6x"06",
		"11011000" when 6x"07",
		"10000000" when 6x"08",
		"10010000" when 6x"09",
		"10001000" when 6x"0A",
		"10000011" when 6x"0B",
		"10100111" when 6x"0C",
		"10100001" when 6x"0D",
		"10000110" when 6x"0E",
		"10001110" when 6x"0F",
		"11000010" when 6x"10",
		"10001011" when 6x"11", -- H
		"11111011" when 6x"12", 
		"11100001" when 6x"13",
		"10001010" when 6x"14",
		"11000111" when 6x"15", --L
		"11001000" when 6x"16", 
		"10101011" when 6x"17", 
		"10100011" when 6x"18",
		"10001100" when 6x"19", --P
		"10011000" when 6x"1A", 
		"10101111" when 6x"1B",
		"10010011" when 6x"1C", --S
		"10000111" when 6x"1D",
		"11100011" when 6x"1E",
		"11000001" when 6x"1F",
		"10000001" when 6x"20",
		"10001001" when 6x"21", --x
		"10010001" when 6x"22",
		"11100100" when 6x"23",
		"10111111" when 6x"24",
		"11110111" when 6x"25",
		8X"7f" when 6X"26",
		8X"ff" when others;
end architecture behavioral; 
