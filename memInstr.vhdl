------------------------------------------------------------
-- MEM RV
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.riscv_pkg.all; 
------------------------------------------------------------
entity memInstr is 
	generic (WIDTH : natural := WORD_SIZE;
			WADDR : natural := WORD_SIZE); 
	port (ADDRESS  : in STD_LOGIC_VECTOR (WADDR-1 downto 0);
			clk		: in std_logic;
			Q 		: out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end memInstr;
------------------------------------------------------------
architecture RTL of memInstr is 

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
	signal read_address : std_logic_vector(ADDRESS'range);

begin
	Write: process(clk)
	begin 
		read_address <= address;
	end process;

	Q <= mem(to_integer(unsigned(read_address)));

end RTL;
------------------------------------------------------------