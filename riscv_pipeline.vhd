library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity riscv_pipeline is 
	port (clk		: in std_logic;
		clk_rom	: in std_logic;
		rst	   : in std_logic;
		data  	: out std_logic_vector(WORD_SIZE-1 downto 0));
end riscv_pipeline;
-------------------------------------------------------------------------
architecture riscv_a of riscv_pipeline is 
 
	begin 

		--fetch:  fetch_stage port map ();
		--decode: decode_stage port map ();
		--execute: execute_stage port map();
		--memory: memory_stage port map();
		--write_back: write_back_stage port map();

end riscv_a;