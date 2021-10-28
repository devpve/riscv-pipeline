library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity decode_stage is 
	port (clk 		: in std_logic;
		  f_breg_wr : in std_logic;
		  rd 		: in std_logic_vector(BREG_IDX-1 downto 0);
		  wb_rd 	: in std_logic_vector(WORD_SIZE-1 downto 0);
		  reg_IF_ID : in std_logic_vector(63 downto 0);
		  reg_ID_EX : out std_logic_vector(179 downto 0));
end decode_stage;
-------------------------------------------------------------------------
architecture decode_a of decode_stage is 

	-- alias for reg_IF_ID: Instruction / PC  
	alias PC_IF: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(31 downto 0);
	alias instruction_IF: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(63 downto 32);

	-- alias for opcode of instruction
	alias ocpode_ID: std_logic_vector(6 downto 0) is instruction_IF(6 downto 0);

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
	alias RD_ID: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX(179 downto 175);

	signal immediate : signed(WORD_SIZE-1 downto 0);
	signal rd1, rd2  : std_logic_vector(WORD_SIZE-1 downto 0);

	begin 

		ctrl: control  
			port map (
				clk => clk, 
				instruction => instruction_IF,
				alu_op => alu_op_ID,
				pc_src => pc_src_ID,
				is_branch => is_branch_ID,
				is_jalr => is_jalr_ID,
				is_jalx => is_jalx_ID,
				mem_wr => mem_wr_ID, 
				mem_rd => mem_rd_ID, 
				mem2reg => mem2reg_ID,
				alu_src => alu_src_ID,
				breg_wr => breg_wr_ID
			);

		-- Banco de registradores
		regBank: xreg 
			generic map (
				SIZE => WORD_SIZE,
				ADDR => BREG_IDX
			)
			port map (
				clk => clk,
				wren => f_breg_wr,
				rs1 => instruction_IF(19 downto 15),
				rs2	=> instruction_IF(24 downto 20),
				rd => rd,
				data_in	=> wb_rd,
				A => rd1,
				B => rd2
			);

		-- Gerador de imediato
		ImmediateGen: genImm32
			port map(instr => instruction_IF,
					imm32 => immediate);

		-- Final register: reg_ID_EX
		PC_ID <= PC_IF; 
		RD1_ID <= rd1;
		RD2_ID <= rd2;
		IMM_ID <= ZERO32 & std_logic_vector(immediate); -- extend signal i dont know why
		FUNCT3_ID <= instruction_IF(30) & instruction_IF(14 downto 12);
		RD_ID <= instruction_IF(11 downto 7);

end decode_a; 
