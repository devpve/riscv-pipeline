 ------------------------------------------------------------
-- MEM RV
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.riscv_pkg.all; 
------------------------------------------------------------
entity memData is 
	generic (
		WIDTH : natural := WORD_SIZE;
		WADDR : natural := WORD_SIZE
	); 
	port
	(
		address		: in std_logic_vector (WADDR-1 downto 0);
		clk	 		: in std_logic;
		data		: in std_logic_vector (WORD_SIZE-1 downto 0);
		wren		: in std_logic;
		rden 		: in std_logic;
		Q			: out std_logic_vector (WORD_SIZE-1 downto 0)
	);
end memData;
------------------------------------------------------------
architecture memData_a of memData is 

	type mem_type is array (0 to IMEM_SIZE - 1) of std_logic_vector(WIDTH - 1 downto 0);

	impure function init_ram_hex return mem_type is
  		
  		file text_file : text open read_mode is "memory_file.txt";
  		variable text_line : line;
  		variable mem_content : mem_type;
	
		begin
  			for i in 0 to IMEM_SIZE - 1 loop
    			readline(text_file, text_line);
    			hread(text_line, mem_content(i));
  			end loop;
 
  			return mem_content;
	end function;

	signal mem : mem_type := init_ram_hex;

begin
	Write: process(clk, wren, rden)
	begin
		-- write in memory
		if (wren = '1') then 
			mem(to_integer(unsigned(address))) <= data;
		end if; 

		-- read memory 
		if (rden = '1') then 
			Q <= mem(to_integer(unsigned(address)));
		end if;

	end process;

end memData_a;
------------------------------------------------------------