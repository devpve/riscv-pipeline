library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity testbench_execute is 
end testbench_execute;
-------------------------------------------------------------------------
architecture tb_execute of testbench_execute is 

	component execute_stage is 
		port (
			clk 		: in std_logic;
			reg_ID_EX : in std_logic_vector(149 downto 0);
			pc_branch : out std_logic_vector(WORD_SIZE-1 downto 0);
			reg_EX_MEM : out std_logic_vector(105 downto 0)
			);
	end component;

	-- fetch stage
	signal clk_in 	: std_logic := '0';
	signal PC_src_in : std_logic := '0';
	signal branch_PC_in : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal reg_IF_ID_inout : std_logic_vector(63 downto 0);

	-- decode stage
	signal f_breg_wr_in : std_logic := '0';
	signal wb_rd_in: std_logic_vector(WORD_SIZE-1 downto 0);
	signal reg_ID_EX_inout : std_logic_vector(149 downto 0); 
	signal rd_in : std_logic_vector(BREG_IDX-1 downto 0);

	-- other stages
	alias alu_src_ID: std_logic is reg_ID_EX_inout(10);
	alias alu_op_ID: std_logic_vector(1 downto 0) is reg_ID_EX_inout(12 downto 11);
	
	-- other signals
	alias PC_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_inout(44 downto 13); 
	alias RD1_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_inout(76 downto 45);
	alias RD2_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_inout(108 downto 77);
	alias IMM_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_inout(140 downto 109);
	alias FUNCT3_ID: std_logic_vector(3 downto 0) is reg_ID_EX_inout(144 downto 141);
	alias RD_ID: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX_inout(149 downto 145);

	-- excute stage
	signal pc_branch_out: std_logic_vector(WORD_SIZE-1 downto 0);
	signal reg_EX_MEM_out: std_logic_vector(105 downto 0);

	-- alias for reg_EX_MEM
	alias breg_wr_EX: std_logic is reg_EX_MEM_out(0);
	alias mem2reg_EX: std_logic is reg_EX_MEM_out(1);
	alias mem_wr_EX: std_logic is reg_EX_MEM_out(2);
	alias mem_rd_EX: std_logic is reg_EX_MEM_out(3);
	alias ALU_RESULT_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM_out(35 downto 4);
	alias RD2_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM_out(67 downto 36);
	alias RD_EX: std_logic_vector(BREG_IDX-1 downto 0) is reg_EX_MEM_out(72 downto 68);
	alias NEXTPC_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM_out(104 downto 73);
	alias is_jalx_EX: std_logic is reg_EX_MEM_out(105);

	begin 
		fetch : fetch_stage
			port map(
				clk => clk_in,
				PC_src => PC_src_in,
				branch_PC => branch_PC_in, 
				reg_IF_ID => reg_IF_ID_inout
			);

		decode : decode_stage
			port map(
				clk => clk_in,
				f_breg_wr => f_breg_wr_in,
				rd => rd_in,
				wb_rd => wb_rd_in,
				reg_IF_ID => reg_IF_ID_inout,
				reg_ID_EX => reg_ID_EX_inout
			);

		execute : execute_stage
			port map (
				clk => clk_in,
				reg_ID_EX => reg_ID_EX_inout,
				pc_branch => pc_branch_out,
				reg_EX_MEM => reg_EX_MEM_out
			);

	clk_process: process
	begin
	for i in 0 to 800 loop
	clk_in <= '0';
	wait for 1 ps;
	clk_in <= '1';
	wait for 1 ps;

	end loop;
	wait;
	end process;
 
end tb_execute; 
