library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity decode_stage is 
	port (clk : in std_logic;
		  f_breg_wr: in std_logic;
		  xreg_reset : in std_logic;
		  is_jalx, is_jalr : in std_logic; 
		  wb_rd : in std_logic_vector(WORD_SIZE-1 downto 0);
		  reg_IF_ID : in std_logic_vector(95 downto 0);
		  pc_branch : out signed(WORD_SIZE-1 downto 0);
		  reg_ID_EX : out std_logic_vector(174 downto 0));
end decode_stage;
-------------------------------------------------------------------------
architecture decode_a of decode_stage is 

	-- ALIAS for reg_IF_ID: next_PC / Instruction / PC  
	alias next_PC_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(95 downto 64);
	alias ft_instruction_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(63 downto 32);
	alias PC_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(31 downto 0); 
	-- ALIAS for opcode of instruction
	alias ocpode_A: std_logic_vector(6 downto 0) is ft_instruction_A(6 downto 0);

	alias PC_ID_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(31 downto 0); 
	alias BREG_RA_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(63 downto 32);
	alias BREG_RB_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(95 downto 64);
	alias ft_instruction_ID_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(127 downto 96);
	alias rs1_A: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX(132 downto 128);
	alias rs2_A: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX(137 downto 133);
	alias rsd_A: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX(142 downto 138);
	alias imm_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX(174 downto 143);

	signal id_imm_ws : signed(WORD_SIZE-1 downto 0);
	signal id_imm : signed(WORD_SIZE-1 downto 0);
	signal jump_addr : std_logic_vector(WORD_SIZE-1 downto 0);
	signal xregs_A, xregs_B : std_logic_vector(WORD_SIZE-1 downto 0);

	begin 

		regBank: xreg 
			generic map (SIZE => WORD_SIZE,
						 ADDR => BREG_IDX)
			port map(rst => xreg_reset,
					clk => clk,
					wren => f_breg_wr,
					rs1 => ft_instruction_A(19 downto 15),
					rs2	=> ft_instruction_A(24 downto 20),
					rd => ft_instruction_A(11 downto 7),
					data_in	=> wb_rd,
					A => xregs_A,
					B => xregs_B
			);

		-- JALR
		with is_jalr select 
			jump_addr <= PC_A when '0', 
						 xregs_A when '1',
						 ZERO32 when others;

		-- Gerador de imediato
		ImmediateGen: genImm32
			port map(instr => ft_instruction_A,
					imm32 => id_imm_ws);

		pc_branch <= signed(jump_addr) + signed(id_imm_ws);
		
		-- JAL
		with is_jalx select
			id_imm <= id_imm_ws when '0',
					  signed(next_PC_A) when '1',
					  signed(ZERO32) when others;

		-- Registrador final: reg_ID_EX
		PC_ID_A <= PC_A; 
		BREG_RA_A <= xregs_A;
		BREG_RB_A <= xregs_B;
		ft_instruction_ID_A <= ft_instruction_A;
		rs1_A <= ft_instruction_A(19 downto 15);
		rs2_A <= ft_instruction_A(24 downto 20);
		rsd_A <= ft_instruction_A(11 downto 7);
		imm_A <= std_logic_vector(id_imm);

end decode_a; 
