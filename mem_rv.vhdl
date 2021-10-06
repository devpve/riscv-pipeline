------------------------------------------------------------
-- MEM RV
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
------------------------------------------------------------
entity mem_rv is 
	port (clk, we 	: in std_logic; 
		  address	: in std_logic_vector;
		  datain 	: in std_logic_vector;
		  dataout 	: out std_logic_vector
		  );
end mem_rv;
------------------------------------------------------------
architecture RTL of mem_rv is 

	constant ram_depth : natural := 256;
	constant ram_width : natural := 32;
	
	-- type mem_type is array(0 to (2**address'length)-1) of std_logic_vector(datain'range);

	type ram_type is array (0 to ram_depth - 1) of std_logic_vector(ram_width - 1 downto 0);

	impure function init_ram_hex return ram_type is
  		file text_file : text open read_mode is "memory_file.txt";
  		variable text_line : line;
  		variable ram_content : ram_type;
	begin
  		for i in 0 to ram_depth - 1 loop
    		readline(text_file, text_line);
    		hread(text_line, ram_content(i));
  		end loop;
 
  		return ram_content;
	end function;

	signal mem : ram_type := init_ram_hex;
	signal read_address : std_logic_vector(address'range);

begin
	Write: process(clk)
	begin 
		if (we = '1') then
			mem(to_integer(unsigned(address))) <= datain;
		end if;
		read_address <= address;
	end process;

	dataout <= mem(to_integer(unsigned(read_address)));

end RTL;
------------------------------------------------------------