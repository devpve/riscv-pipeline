 library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity execute_stage is 
	port (clk 		: in std_logic;
		  reg_ID_EX : in std_logic_vector(179 downto 0);
		  pc_branch : out std_logic_vector(WORD_SIZE-1 downto 0);
		  reg_EX_MEM : out std_logic_vector(72 downto 0));
end execute_stage;
-------------------------------------------------------------------------
architecture execute_a of execute_stage is 
	
	-- alias for reg_ID_EX
	-- control signals
	alias breg_wr_ID: std_logic is reg_ID_EX(0);
	alias mem2reg_ID: std_logic is reg_ID_EX(1);
	alias pc_src_ID: std_logic is reg_ID_EX(2);
	alias is_branch_ID: std_logic is reg_ID_EX(3);
	alias is_jalx_ID: std_logic is reg_ID_EX(4);
	alias is_jalr_ID: std_logic is reg_ID_EX(5);
	alias mem_wr_ID: std_logic is reg_ID_EX(6);
	alias mem_rd_ID: std_logic is reg_ID_EX(7);
	alias alu_src_ID: std_logic is reg_ID_EX(8);
	alias alu_op_ID: std_logic_vector(1 downto 0) is reg_ID_EX(10 downto 9);
	
	-- other signals
	alias PC_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(42 downto 11); 
	alias RD1_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(74 downto 43);
	alias RD2_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(106 downto 75);
	alias IMM_ID: std_logic_vector(63 downto 0) is reg_ID_EX(170 downto 107);
	alias FUNCT3_ID: std_logic_vector(3 downto 0) is reg_ID_EX(174 downto 171);
	alias FUNCT7_ID: std_logic is FUNCT3_ID(3);
	alias RD_ID: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX(179 downto 175);

	-- alias for reg_EX_MEM
	alias breg_wr_EX: std_logic is reg_EX_MEM(0);
	alias mem2reg_EX: std_logic is reg_EX_MEM(1);
	alias mem_wr_EX: std_logic is reg_EX_MEM(2);
	alias mem_rd_EX: std_logic is reg_EX_MEM(3);
	alias ALU_RESULT_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(35 downto 4);
	alias RD2_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(67 downto 36);
	alias RD_EX: std_logic_vector(BREG_IDX-1 downto 0) is reg_EX_MEM(72 downto 68);

	signal zero_out : std_logic;
	signal alu_opcode : std_logic_vector(3 downto 0);
	signal is_jump : std_logic_vector(1 downto 0);
	signal is_branch_res : std_logic_vector(1 downto 0);
	signal alu_src : std_logic_vector(WORD_SIZE-1 downto 0);

	signal jump_addr: std_logic_vector(WORD_SIZE-1 downto 0);
	signal alu_result: std_logic_vector(WORD_SIZE-1 downto 0);

	begin 

		-- ALU Control
		alu_control: alu_ctr
			port map (
				clk => clk,
				alu_op => alu_op_ID,
				funct3 => FUNCT3_ID(2 downto 0),
				funct7 => FUNCT7_ID,
				alu_ctr => alu_opcode
			);

		-- ALU Source MUX
		with alu_src_ID select 
			alu_src <= 
				RD2_ID when '0', 
				IMM_ID(31 downto 0)	when '1',
				unaffected when others;

		-- ALU
		alu_ex: alu 
			port map (
				opcode => alu_opcode,
				A => RD1_ID,
				B => alu_src,
				aluout => alu_result,
				zero => zero_out
			);

 		is_jump <= is_jalr_ID & is_jalx_ID;

		-- JALX 
		with is_jump select
			jump_addr <= std_logic_vector(unsigned(PC_ID) + unsigned(IMM_ID(WORD_SIZE-1 downto 0))) when "01",
						 std_logic_vector(unsigned(PC_ID) + unsigned(RD1_ID)) when "10",
						 ZERO32 when others;


		-- BRANCH 
		is_branch_res <= zero_out & is_branch_ID;

		with is_branch_res select 
			jump_addr <= std_logic_vector(unsigned(PC_ID) + 4) when "01",
				         std_logic_vector(unsigned(PC_ID) + unsigned(IMM_ID(WORD_SIZE-1 downto 0))) when "10",
			             ZERO32 when others;


		pc_branch <= jump_addr; 

		-- Final register
		breg_wr_EX <= breg_wr_ID;
		mem2reg_EX <= mem2reg_ID;
		mem_wr_EX <= mem_wr_ID;
		mem_rd_EX <= mem_rd_ID;
		ALU_RESULT_EX <= alu_result;
		RD2_EX <= RD2_ID;
		RD_EX <= RD_ID;

end execute_a;
