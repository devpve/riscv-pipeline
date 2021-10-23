library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;
-------------------------------------------------------------------------
entity genImm32 is 
	port (
		instr : in std_logic_vector(WORD_SIZE-1 downto 0);
		imm32 : out signed(WORD_SIZE-1 downto 0));
end genImm32;
-------------------------------------------------------------------------
architecture genImm32_a of genImm32 is 
	
begin 

with (instr(6 downto 0)) select 
	imm32 <= signed(ZERO32) when "0110011", -- R-TYPE
			resize(signed(instr(31 downto 20)), 32) when "0000011" | "0010011" | "1100111", -- ITYPE
			resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32) when "0100011",  -- S TYPE 
	        resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32) when "1100011", -- sb type
	        signed(instr(31 downto 12) & X"000") when "0110111", -- utype
	        resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32) when "1101111", --uj type
			signed(ZERO32) when others;
end genImm32_a;