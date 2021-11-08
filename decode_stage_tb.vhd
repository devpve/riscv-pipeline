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
 
	stim_proc: process
	begin

		-- #1: Testando iRType
		-- add t0, zero, zero imm inexistente
		wait for 1.5 ps;
		assert(pc_src_ID = '0') report "#1: PC Source fail" severity error;
		assert(alu_op_ID = "00") report "#1: ALUOp Fail" severity error;
		assert(alu_src_ID = '0') report "#1: ALUSrc Fail" severity error;
		assert (PC_ID = X"00000004") report "#1: PC Fail to Read" severity error;
		assert(IMM_ID = ZERO32) report "#1: Immediate Fail" severity error;
		assert(RD_ID = std_logic_vector(to_unsigned(5, 5))) report "#1: Failed to read rd" severity error;


		-- #2: Testando I-type0
		-- lw t0, 16(zero)
		wait for 1.5 ps;
		assert(pc_src_ID = '0') report "#2 PC Source fail" severity error;
		assert(mem2reg_ID = '1') report "#2 Mem2Reg Fail" severity error;
		assert (breg_wr_ID = '1') report "#2 RegWrite Fail" severity error;
		assert(mem_rd_ID = '1') report "#2 MemRead Fail" severity error;
		assert(alu_src_ID = '1') report "#2 ALUSrc Fail" severity error;
		assert(alu_op_ID = "01") report "#2 ALUOp Fail" severity error;
		assert (PC_ID = X"00000008") report "#2: PC Fail to Read" severity error;
		assert(IMM_ID = std_logic_vector(to_signed(16, 32))) report "#2:Immediate Fail" severity error;
		assert(RD_ID = std_logic_vector(to_unsigned(5, 5))) report "#2:Failed to read rd" severity error;

		-- #3: Testando I-Type1 
		-- addi t1, zero, -100
		wait for 1.5 ps;
		assert(pc_src_ID = '0') report "#3: PC Source fail" severity error;
		assert(alu_op_ID = "00") report "#3: ALUOp Fail" severity error;
		assert(alu_src_ID = '1') report "#3: ALUSrc Fail" severity error;
		assert (PC_ID = X"0000000C") report "#3: PC Fail to Read" severity error;
		assert(IMM_ID = std_logic_vector(to_signed(-100, 32))) report "#3: Immediate Fail" severity error;
		assert(RD_ID = std_logic_vector(to_unsigned(6, 5))) report "#3: Failed to read rd" severity error;

		-- #4: Testando U-Type
		-- lui s0, 2
		wait for 1.5 ps;
		assert(pc_src_ID = '0') report "#4: PC Source fail" severity error;
		assert(alu_op_ID = "11") report "#4: ALUOp Fail" severity error;
		assert(alu_src_ID = '1') report "#4: ALUSrc Fail" severity error;
		assert (PC_ID = X"00000010") report "#4: PC Fail to Read" severity error;
		assert(IMM_ID = X"00002000") report "#4: Immediate Fail" severity error;
		assert(RD_ID = std_logic_vector(to_unsigned(8, 5))) report "#4: Failed to read rd" severity error;

		-- #5: Testando S-Type
		-- sw t0, 60 (s0)
		wait for 1.5 ps;
		assert(pc_src_ID = '0') report "#5 PC Source fail" severity error;
		assert(mem_wr_ID = '1') report "#5 Mem2Reg Fail" severity error;
		assert(alu_src_ID = '1') report "#5 ALUSrc Fail" severity error;
		assert(alu_op_ID = "01") report "#5 ALUOp Fail" severity error;
		assert (PC_ID = X"00000014") report "#5: PC Fail to Read" severity error;
		assert(IMM_ID = std_logic_vector(to_signed(60, 32))) report "#4: Immediate Fail" severity error;
		assert(RD1_ID = X"FFFFFFFF") report "#5: Failed to read r1" severity error;
		assert(RD2_ID = X"FFFFFFFF") report "#5: Failed to read r2" severity error;

		-- #6: Testando SB-Type
		-- bne t0, t0, main
		wait for 1.5 ps;
		assert(pc_src_ID = '1') report "#6: PC Source fail" severity error;
		assert(is_branch_ID = '1') report "#6: Is Branch fail" severity error;
		assert(alu_src_ID = '1') report "#6 ALUSrc fail" severity error;
		assert(alu_op_ID = "10") report "#6 ALUOp fail" severity error;
		assert (PC_ID = X"00000018") report "#6: PC Fail to Read" severity error;
		assert(IMM_ID = std_logic_vector(to_signed(-32, 32))) report "#6: Immediate Fail" severity error;
		assert(RD1_ID = X"FFFFFFFF") report "#6: Failed to read rd" severity error;

		-- #7 testando branch JALX
		wait for 1.5 ps;
		assert(pc_src_ID = '1') report "#7: PC Source fail" severity error;
		assert(is_jalx_ID = '1') report "#7: Is Branch fail" severity error;
		assert(alu_src_ID = '1') report "#7: ALUSrc fail" severity error;
		assert(alu_op_ID = "10") report "#7: ALUOp fail" severity error;
		assert (PC_ID = X"0000001C") report "#7: PC Fail to Read" severity error;
		assert(RD_ID = std_logic_vector(to_unsigned(2, 5))) report "#7: Regs(rd) Fail to Read" severity error;
		assert(IMM_ID = X"FFF00700") report "#7: Immediate Fail to Read" severity error;
		
		-- testando branch JALR
		wait for 1.5 ps;
		assert(pc_src_ID = '1') report "#8: PC Source fail" severity error;
		assert(is_jalr_ID = '1') report "#8: Is Branch fail" severity error;
		assert(alu_src_ID = '0') report "#8: ALUSrc fail" severity error;
		assert(alu_op_ID = "10") report "#8: ALUOp fail" severity error;
		assert (PC_ID = X"00000020") report "#8: PC Fail to Read" severity error;
		assert(RD1_ID = X"FFFFFFFF") report "#8: regs(1) Fail to Read" severity error;
	
	wait;
	end process;
end tb_decode; 
