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

		signal reg_IF_ID_out std_logic_vector(95 downto 0));
		signal fetch_sel_in(1 downto 0) <= is_branch or is_jalx;

		fetch:  fetch_stage
			port map(clk => clk, 
					 fetch_sel => fetch_sel_in, 
					 PC => PC_in, 
					 branch_PC => branch_PC_in,
					 reg_IF_ID => reg_IF_ID_out
					 );

		--control: control  
		--	port map (
		--		);


		decode: decode_stage 
			port map (clk => clk, 
					  f_breg_wr => f_breg_wr,
					  is_jalx => is_jalx,
					  is_jalr => is_jalr,
					  wb_rd => wb_rd_in,
					  reg_IF_ID => reg_IF_ID_out
					  pc_branch => branch_PC_in
					  reg_ID_EX => reg_ID_EX_out
					  ); 

		--execute: execute_stage port map();
		--memory: memory_stage port map();
		--write_back: write_back_stage port map();

end riscv_a;