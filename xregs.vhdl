------------------------------------------------------------
-- XREGs
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
------------------------------------------------------------
entity xreg is 
	generic (
		SIZE : natural := WORD_SIZE;
		ADDR : natural := BREG_IDX
	);
	port 
	(	
		clk		: in  std_logic;
		wren  	: in  std_logic;
		rs1		: in  std_logic_vector(ADDR-1 downto 0);
		rs2		: in  std_logic_vector(ADDR-1 downto 0);
		rd		: in  std_logic_vector(ADDR-1 downto 0);
		data_in	: in  std_logic_vector(SIZE-1 downto 0);
		A 		: out std_logic_vector(SIZE-1 downto 0);
		B	 	: out std_logic_vector(SIZE-1 downto 0)
	);
end xreg;
------------------------------------------------------------
architecture xreg_a of xreg is 
	type vector_array is array (WORD_SIZE-1 downto 0) of
		std_logic_vector (WORD_SIZE-1 downto 0);

	signal regs : vector_array := (OTHERS => (OTHERS => '0'));
	-- rst é async ou sync?
begin
	process(clk, wren)
	begin 

		-- write enable
		if (clk'EVENT and clk='1') then
			
			A <= regs(to_integer(unsigned(rs1)));
			B <= regs(to_integer(unsigned(rs2)));

			if (wren='1') then
				if (to_integer(unsigned(rd)) /= 0) then
					regs(to_integer(unsigned(rd))) <= data_in;
				end if;
			end if;
		end if;
	end process;
end xreg_a;
------------------------------------------------------------