library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity riscv_pipeline is 
	port (
		clk		: in std_logic;
		rst	   	: in std_logic;
		data  	: out std_logic_vector(WORD_SIZE-1 downto 0)
		);
end riscv_pipeline;
-------------------------------------------------------------------------
architecture riscv_a of riscv_pipeline is 
 	
 	signal PCSrc, RegWrite : std_logic;
 	signal WriteData, BranchPC : std_logic_vector(WORD_SIZE-1 downto 0);
 	signal WriteRegister : std_logic_vector(BREG_IDX-1 downto 0);

 	signal reg_IFID : std_logic_vector(63 downto 0);
 	signal reg_IDEX : std_logic_vector(149 downto 0);
 	signal reg_EXMEM : std_logic_vector(105 downto 0);
 	signal reg_MEMWB : std_logic_vector(103 downto 0);

	begin 
 
		fetch: fetch_stage
			port map (
				clk => clk, 
				PC_src => PCSrc, 
				branch_PC => BranchPC,
				reg_IF_ID => reg_IFID
			);

		decode: decode_stage 
			port map (
				clk => clk, 
				f_breg_wr => RegWrite,
				wb_rd => WriteData,
				rd => WriteRegister,
				reg_IF_ID => reg_IFID,
				reg_ID_EX => reg_IDEX
			);

		execute: execute_stage   
			port map ( 
				clk => clk, 
				reg_ID_EX => reg_IDEX, 
				pc_branch => BranchPC,
				reg_EX_MEM => reg_EXMEM
			);

		memory: memory_stage  
			port map ( 
				clk => clk, 
				reg_EX_MEM => reg_EXMEM,
				reg_MEM_WB => reg_MEMWB
			);

		writeback: wb_stage  
			port map ( 
				clk => clk, 
				reg_MEM_WB => reg_MEMWB,
				f_breg_wr => RegWrite,
				rd => WriteRegister,
				wb_rd => WriteData
			);

		data <= WriteData;
		
end riscv_a;