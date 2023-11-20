library ieee;
use ieee.std_logic_1164.all;

entity Lab2_KB is
	port(	PS2_DAT, PS2_CLK, clk, rstn : in std_logic;
			HEX7, HEX6, HEX0 : out std_logic_vector(6 downto 0);
			LEDR : out std_logic_vector(9 downto 0));
end entity;

architecture rtl of Lab2_KB is
	signal	shiftreg, scancode : std_logic_vector(9 downto 0) := (others => '1');
	signal	PS2_CLK2, PS2_CLK2_old : std_logic;
	signal	PS2_bit,  PS2_bit_en, PS2_byte_en : std_logic;
	signal 	PS2_byte : std_logic_vector(7 downto 0);	
	signal 	E0, F0 : std_logic;
begin

	p1 : process(clk) begin
		if rising_edge(clk) then
			PS2_CLK2 	 <= PS2_CLK;
			PS2_bit 	 <= PS2_DAT;
			PS2_CLK2_old <= PS2_CLK2;
		end if;
	end process;
	PS2_bit_en  <= (not PS2_CLK2) and PS2_CLK2_old;
	PS2_byte_en <= not shiftreg(0);
	PS2_byte 	<= shiftreg(8 downto 1);
	
	p2 : process(clk, rstn) begin
		if rstn = '0' then
			shiftreg <= (others => '1');
		elsif rising_edge(clk) then
			if PS2_byte_en = '1' then
				if PS2_byte = "11100000" then
					E0 <= '1';
				elsif PS2_byte = "11110000" then
					F0 <= '1';
				else
					scancode <= F0 & E0 & PS2_byte;
					F0 <= '0';
					E0 <= '0';
				end if;
				shiftreg <= (others => '1');
			elsif PS2_bit_en = '1' then	
				shiftreg <= PS2_bit & shiftreg(9 downto 1);
			end if;
		end if;
	end process;
	
	LEDR <= scancode;
	
	HEX0 <= 	"1111001" when scancode(7 downto 0) = "00010110" else -- 1 
				"0100100" when scancode(7 downto 0) = "00011110" else -- 2
				"0110000" when scancode(7 downto 0) = "00100110" else -- 3
				"0011001" when scancode(7 downto 0) = "00100101" else -- 4
				"0010010" when scancode(7 downto 0) = "00101110" else -- 5
				"0000010" when scancode(7 downto 0) = "00110110" else -- 6
				"1111000" when scancode(7 downto 0) = "00111101" else -- 7
				"0000000" when scancode(7 downto 0) = "00111110" else -- 8
				"0010000" when scancode(7 downto 0) = "01000110" else -- 9
				"1000000" when scancode(7 downto 0) = "01000101" else -- 0
				"0000110";															-- Error
	
	HEX7 <= "1000000";
	HEX6 <= "0000010";
	
end architecture;
