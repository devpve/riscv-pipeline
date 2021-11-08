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
			reg_EX_MEM : out std_logic_vector(104 downto 0)
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
	signal reg_EX_MEM_out : std_logic_vector(104 downto 0);

	-- alias for reg_EX_MEM
	alias breg_wr_EX: std_logic is reg_EX_MEM_out(0);
	alias mem2reg_EX: std_logic is reg_EX_MEM_out(1);
	alias mem_wr_EX: std_logic is reg_EX_MEM_out(2);
	alias mem_rd_EX: std_logic is reg_EX_MEM_out(3);
	alias ALU_RESULT_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM_out(35 downto 4);
	alias RD2_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM_out(67 downto 36);
	alias RD_EX: std_logic_vector(BREG_IDX-1 downto 0) is reg_EX_MEM_out(72 downto 68);
	alias NEXTPC_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM_out(104 downto 73);

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
 
	stim_proc: process
	begin

		-- #1: Testando iRType
		-- add t0, zero, zero imm inexistente
		wait for 1.5 ps;
		assert(breg_wr_EX = '0') report "#1: BREG WRITE Fail" severity error;
		assert(mem2reg_EX = '0') report "#1: MEM2REG Fail" severity error;
		assert(ALU_RESULT_EX = ZERO32) report "#1: ALU RESULT Fail" severity error;
		assert(mem_wr_EX = '0') report "#1 MEM WRITE Fail" severity error;
		assert(mem_rd_EX = '0') report "#1 MEM READ Fail" severity error;
		--assert(RD2_EX = '')
		assert(RD_EX = std_logic_vector(to_unsigned(5, 5))) report "#1: Failed to read rd" severity error;

		---- #2: Testando I-type0
		---- lw t0, 16(zero)
		--instr <= X"01002283"; 
		--wait for 2 ps;
		--reg_IF_ID_in <= instr & ZERO32;
		--wait for 5 ps;
		--assert(pc_src_ID = '0') report "#2 PC Source fail" severity error;
		--assert(mem2reg_ID = '1') report "#2 Mem2Reg Fail" severity error;
		--assert (breg_wr_ID = '1') report "#2 RegWrite Fail" severity error;
		--assert(mem_rd_ID = '1') report "#2 MemRead Fail" severity error;
		--assert(alu_src_ID = '1') report "#2 ALUSrc Fail" severity error;
		--assert(alu_op_ID = "01") report "#2 ALUOp Fail" severity error;
		--assert (PC_ID = ZERO32) report "#2: PC Fail to Read" severity error;
		--assert(IMM_ID = ZERO32 & std_logic_vector(to_signed(16, 32))) report "#2:Immediate Fail" severity error;
		--assert(RD_ID = instr(11 downto 7)) report "#2:Failed to read rd" severity error;

		---- #3: Testando I-Type1 
		---- addi t1, zero, -100
		--instr <= X"F9C00313";
		--wait for 2 ps;
		--reg_IF_ID_in <= instr & ZERO32;
		--wait for 5 ps;
		--assert(pc_src_ID = '0') report "#3: PC Source fail" severity error;
		--assert(alu_op_ID = "00") report "#3: ALUOp Fail" severity error;
		--assert(alu_src_ID = '1') report "#3: ALUSrc Fail" severity error;
		--assert (PC_ID = ZERO32) report "#3: PC Fail to Read" severity error;
		--assert(IMM_ID = ZERO32 & std_logic_vector(to_signed(-100, 32))) report "#3: Immediate Fail" severity error;
		--assert(RD_ID = instr(11 downto 7)) report "#3: Failed to read rd" severity error;

		---- #4: Testando U-Type
		---- lui s0, 2
		--instr <= X"00002437";
		--wait for 2 ps; 
		--reg_IF_ID_in <= instr & ZERO32;
		--wait for 5 ps; 
		--assert(pc_src_ID = '0') report "#4: PC Source fail" severity error;
		--assert(alu_op_ID = "11") report "#4: ALUOp Fail" severity error;
		--assert(alu_src_ID = '1') report "#4: ALUSrc Fail" severity error;
		--assert (PC_ID = ZERO32) report "#4: PC Fail to Read" severity error;
		--assert(IMM_ID = ZERO32 & std_logic_vector(signed(instr(31 downto 12) & X"000"))) report "#4: Immediate Fail" severity error;
		--assert(RD_ID = instr(11 downto 7)) report "#4: Failed to read rd" severity error;

		---- #5: Testando S-Type
		---- sw t0, 60 (s0)
		--instr <= X"02542e23";
		--wait for 2 ps; 
		--reg_IF_ID_in <= instr & ZERO32;
		--wait for 5 ps; 
		--assert(pc_src_ID = '0') report "#5 PC Source fail" severity error;
		--assert(mem_wr_ID = '1') report "#5 Mem2Reg Fail" severity error;
		--assert(alu_src_ID = '1') report "#5 ALUSrc Fail" severity error;
		--assert(alu_op_ID = "01") report "#5 ALUOp Fail" severity error;
		--assert (PC_ID = ZERO32) report "#5: PC Fail to Read" severity error;
		--assert(IMM_ID = ZERO32 & std_logic_vector(to_signed(60, 32))) report "#4: Immediate Fail" severity error;
		--assert(RD1_ID = X"FFFFFFFF") report "#5: Failed to read r1" severity error;
		--assert(RD2_ID = X"FFFFFFFF") report "#5: Failed to read r2" severity error;

		---- #6: Testando SB-Type
		---- bne t0, t0, main
		--instr <= X"fe5290e3";
		--wait for 2 ps; 
		--reg_IF_ID_in <= instr & ZERO32;
		--wait for 5 ps; 
		--assert(pc_src_ID = '1') report "#6: PC Source fail" severity error;
		--assert(is_branch_ID = '1') report "#6: Is Branch fail" severity error;
		--assert(alu_src_ID = '1') report "#6 ALUSrc fail" severity error;
		--assert(alu_op_ID = "10") report "#6 ALUOp fail" severity error;
		--assert (PC_ID = ZERO32) report "#6: PC Fail to Read" severity error;
		--assert(IMM_ID = ZERO32 & std_logic_vector(to_signed(-32, 32))) report "#6: Immediate Fail" severity error;
		--assert(RD1_ID = X"FFFFFFFF") report "#6: Failed to read rd" severity error;

		---- #7 testando branch JALX
		--instr <= X"F000016F";
		--wait for 1 ps;
		--reg_IF_ID_in <= instr & ZERO32;
		--wait for 2 ps;
		--assert(pc_src_ID = '1') report "#7: PC Source fail" severity error;
		--assert(is_jalx_ID = '1') report "#7: Is Branch fail" severity error;
		--assert(alu_src_ID = '1') report "#7: ALUSrc fail" severity error;
		--assert(alu_op_ID = "10") report "#7: ALUOp fail" severity error;
		--assert (PC_ID = ZERO32) report "#7: PC Fail to Read" severity error;
		--assert(RD_ID = instr(11 downto 7)) report "#7: Regs(rd) Fail to Read" severity error;
		--assert(IMM_ID = ZERO32 & std_logic_vector(resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32))) report "#7: Immediate Fail to Read" severity error;
		
		---- testando branch JALR
		--instr <= X"F0000167";
		--wait for 1 ps;
		--reg_IF_ID_in <= instr & ZERO32;
		--wait for 2 ps;
		--assert(pc_src_ID = '1') report "#8: PC Source fail" severity error;
		--assert(is_jalr_ID = '1') report "#8: Is Branch fail" severity error;
		--assert(alu_src_ID = '0') report "#8: ALUSrc fail" severity error;
		--assert(alu_op_ID = "10") report "#8: ALUOp fail" severity error;
		--assert (PC_ID = ZERO32) report "#8: PC Fail to Read" severity error;
		--assert(RD1_ID = X"FFFFFFFF") report "#8: regs(1) Fail to Read" severity error;
	
	wait;
	end process;
end tb_execute; 
