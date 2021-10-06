------------------------------------------------------------
-- XREGs
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity xregs is 
	generic (W_SIZE : natural := 32);
	port (clk, wren, rst 	: in std_logic; 
		rs1, rs2, rd	: in std_logic_vector(4 downto 0);
		data	: in std_logic_vector(W_SIZE-1 downto 0);
		ro1, ro2	: out std_logic_vector(W_SIZE-1 downto 0));
end xregs;
------------------------------------------------------------
architecture xregs_riscv of xregs is 
	type vector_array is array (W_SIZE-1 downto 0) of
		std_logic_vector (W_SIZE-1 downto 0);

	signal regs : vector_array;
	-- rst é async ou sync?
begin
	process(clk, wren)
	begin 

		-- reset all regs to zero
		if (rst = '1') then 
			for k in 0 to W_SIZE-1 loop
				regs(k) <= (OTHERS => '0');
			end loop;
		end if; 

		-- write enable
		if (clk'EVENT and clk='1') then
			
			ro1 <= regs(to_integer(unsigned(rs1)));
			ro2 <= regs(to_integer(unsigned(rs2)));

			if (wren='1') then
				if (to_integer(unsigned(rd)) /= 0) then
					regs(to_integer(unsigned(rd))) <= data;
				end if;
			end if;
		end if;
	end process;
end xregs_riscv;
------------------------------------------------------------