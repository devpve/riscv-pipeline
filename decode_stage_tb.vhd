library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity testbench_decode is 
end testbench_decode;
-------------------------------------------------------------------------
architecture tb_decode of testbench_decode is 

	component decode_stage is 
		port (
			clk 		: in std_logic;
			f_breg_wr : in std_logic;
			rd 		: in std_logic_vector(BREG_IDX-1 downto 0);
			wb_rd 	: in std_logic_vector(WORD_SIZE-1 downto 0);
			reg_IF_ID : in std_logic_vector(63 downto 0);
			reg_ID_EX : out std_logic_vector(149 downto 0)
		);
	end component;

	-- fetch stage
	signal clk_in 	: std_logic := '0';
	signal PC_src_in : std_logic := '0';
	signal branch_PC_in : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal reg_IF_ID_inout : std_logic_vector(63 downto 0);

    -- alias for reg_IF_ID: Instruction / PC  
	alias PC_IF: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID_inout(31 downto 0);
	alias instruction_IF: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID_inout(63 downto 32);

	-- decode stage
	signal f_breg_wr_in : std_logic := '0';
	signal wb_rd_in: std_logic_vector(WORD_SIZE-1 downto 0);
	signal reg_ID_EX_out : std_logic_vector(149 downto 0); 
	signal rd_in : std_logic_vector(BREG_IDX-1 downto 0);
	-- alias for reg_ID_EX
	-- control signals
	alias breg_wr_ID: std_logic is reg_ID_EX_out(0);
	alias mem2reg_ID: std_logic is reg_ID_EX_out(1);
	alias pc_src_ID: std_logic is reg_ID_EX_out(2);
	alias is_branch_ID: std_logic is reg_ID_EX_out(3);
	alias is_lui_ID: std_logic is reg_ID_EX_out(4);
	alias is_auipc_ID: std_logic is reg_ID_EX_out(5);
	alias is_jalx_ID: std_logic is reg_ID_EX_out(6);
	alias is_jalr_ID: std_logic is reg_ID_EX_out(7);
	alias mem_wr_ID: std_logic is reg_ID_EX_out(8);
	alias mem_rd_ID: std_logic is reg_ID_EX_out(9);
	alias alu_src_ID: std_logic is reg_ID_EX_out(10);
	alias alu_op_ID: std_logic_vector(1 downto 0) is reg_ID_EX_out(12 downto 11);
	
	-- other signals
	alias PC_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(44 downto 13); 
	alias RD1_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(76 downto 45);
	alias RD2_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(108 downto 77);
	alias IMM_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(140 downto 109);
	alias FUNCT3_ID: std_logic_vector(3 downto 0) is reg_ID_EX_out(144 downto 141);
	alias RD_ID: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX_out(149 downto 145);

	begin 
		fetch : fetch_stage
			port map(clk => clk_in,
					PC_src => PC_src_in,
					branch_PC => branch_PC_in, 
					reg_IF_ID => reg_IF_ID_inout);

		decode : decode_stage
			port map(
				clk => clk_in,
				f_breg_wr => f_breg_wr_in,
				rd => rd_in,
				wb_rd => wb_rd_in,
				reg_IF_ID => reg_IF_ID_inout,
				reg_ID_EX => reg_ID_EX_out
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
 
end tb_decode; 
