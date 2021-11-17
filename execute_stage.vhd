 library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity execute_stage is 
	port (clk 		: in std_logic;
		  reg_ID_EX : in std_logic_vector(149 downto 0);
		  pc_branch : out std_logic_vector(WORD_SIZE-1 downto 0);
		  reg_EX_MEM : out std_logic_vector(105 downto 0));
end execute_stage;
-------------------------------------------------------------------------
architecture execute_a of execute_stage is 
	
	-- alias for reg_ID_EX
	-- control signals
	alias breg_wr_ID: std_logic is reg_ID_EX(0);
	alias mem2reg_ID: std_logic is reg_ID_EX(1);
	alias pc_src_ID: std_logic is reg_ID_EX(2);
	alias is_branch_ID: std_logic is reg_ID_EX(3);
	alias is_lui_ID: std_logic is reg_ID_EX(4);
	alias is_auipc_ID: std_logic is reg_ID_EX(5);
	alias is_jalx_ID: std_logic is reg_ID_EX(6);
	alias is_jalr_ID: std_logic is reg_ID_EX(7);
	alias mem_wr_ID: std_logic is reg_ID_EX(8);
	alias mem_rd_ID: std_logic is reg_ID_EX(9);
	alias alu_src_ID: std_logic is reg_ID_EX(10);
	alias alu_op_ID: std_logic_vector(1 downto 0) is reg_ID_EX(12 downto 11);
	
	-- other signals
	alias PC_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(44 downto 13); 
	alias RD1_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(76 downto 45);
	alias RD2_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(108 downto 77);
	alias IMM_ID: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(140 downto 109);
	alias FUNCT3_ID: std_logic_vector(3 downto 0) is reg_ID_EX(144 downto 141);
	alias FUNCT7_ID: std_logic is FUNCT3_ID(3);
	alias RD_ID: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX(149 downto 145);

	-- alias for reg_EX_MEM
	alias breg_wr_EX: std_logic is reg_EX_MEM(0);
	alias mem2reg_EX: std_logic is reg_EX_MEM(1);
	alias mem_wr_EX: std_logic is reg_EX_MEM(2);
	alias mem_rd_EX: std_logic is reg_EX_MEM(3);
	alias ALU_RESULT_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(35 downto 4);
	alias RD2_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(67 downto 36);
	alias RD_EX: std_logic_vector(BREG_IDX-1 downto 0) is reg_EX_MEM(72 downto 68);
	alias NEXTPC_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(104 downto 73);
	alias is_jalx_EX: std_logic is reg_EX_MEM(105);

	signal zero_out : std_logic;
	signal alu_opcode : std_logic_vector(3 downto 0);
	signal is_branch_or_jump : std_logic_vector(3 downto 0);
	signal alu_r1, alu_r2, alu_result: std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal next_pc, imm_pc, jump_addr: std_logic_vector(WORD_SIZE-1 downto 0);	

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

		-- AUI PC MUX
		with is_auipc_ID select 
			alu_r1 <= 
				RD1_ID when '0',
				PC_ID when '1',
				unaffected when others;

		-- ALU Source MUX
		with alu_src_ID select 
			alu_r2 <= 
				RD2_ID when '0', 
				IMM_ID when '1',
				unaffected when others;

		-- ALU
		alu_ex: alu 
			port map (
				opcode => alu_opcode,
				A => alu_r1,
				B => alu_r2,
				aluout => alu_result,
				zero => zero_out
			);

		next_pc <= std_logic_vector(unsigned(PC_ID) + 1);
		imm_pc <= std_logic_vector(unsigned(PC_ID) + unsigned(IMM_ID(WORD_SIZE-1 downto 0)));

		-- BRANCH 
		is_branch_or_jump <= is_jalr_ID & is_jalx_ID & alu_result(0) & is_branch_ID;

		with is_branch_or_jump select 
			jump_addr <= imm_pc when "0100" | "0110" | "0011",	-- if jalx or take branch
						 std_logic_vector(unsigned(PC_ID) + unsigned(RD1_ID)) when "1000" | "1010", -- when jalr
			             next_pc when others;	-- when others just next pc


		pc_branch <= jump_addr; 

		process (clk)
		begin 
			if (clk'EVENT and clk='1') then
				-- Final register
				breg_wr_EX <= breg_wr_ID;
				mem2reg_EX <= mem2reg_ID;
				mem_wr_EX <= mem_wr_ID;
				mem_rd_EX <= mem_rd_ID;
				ALU_RESULT_EX <= alu_result;
				RD2_EX <= RD2_ID;
				RD_EX <= RD_ID;
				NEXTPC_EX <= next_pc;
				is_jalx_EX <= is_jalx_ID;
			end if;
		end process;

end execute_a;
