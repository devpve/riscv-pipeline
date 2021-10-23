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
		port (clk : in std_logic;
			  f_breg_wr: in std_logic;
			  is_jalx, is_jalr : in std_logic; 
			  xreg_reset : in std_logic;
			  wb_rd : in std_logic_vector(WORD_SIZE-1 downto 0);
			  reg_IF_ID : in std_logic_vector(95 downto 0);
			  pc_branch : out signed(WORD_SIZE-1 downto 0);
			  reg_ID_EX : out std_logic_vector(174 downto 0));
	end component;
	
	signal clk_in, f_breg_wr_in, is_jalx_in, is_jalr_in, xreg_reset_in : std_logic;
	signal wb_rd_in: std_logic_vector(WORD_SIZE-1 downto 0);
	signal pc_branch_out : signed(WORD_SIZE-1 downto 0);
	signal reg_IF_ID_in : std_logic_vector(95 downto 0);
	signal reg_ID_EX_out : std_logic_vector(174 downto 0); 

	signal instr : std_logic_vector(WORD_SIZE-1 downto 0);

	alias PC_ID_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(31 downto 0); 
	alias BREG_RA_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(63 downto 32);
	alias BREG_RB_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(95 downto 64);
	alias ft_instruction_ID_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(127 downto 96);
	alias rs1_A: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX_out(132 downto 128);
	alias rs2_A: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX_out(137 downto 133);
	alias rsd_A: std_logic_vector(BREG_IDX-1 downto 0) is reg_ID_EX_out(142 downto 138);
	alias imm_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_ID_EX_out(174 downto 143);

	begin 
		DUT : decode_stage
			port map(clk => clk_in,
					 f_breg_wr => f_breg_wr_in,
					 is_jalx => is_jalx_in,
					 is_jalr => is_jalr_in,
					 xreg_reset => xreg_reset_in,
					 wb_rd => wb_rd_in,
					 reg_IF_ID => reg_IF_ID_in,
					 pc_branch => pc_branch_out,
					 reg_ID_EX => reg_ID_EX_out);

	clk_process: process
	begin
	for i in 0 to 800 loop
	clk_in <= '0';
	wait for 2 ps;
	clk_in <= '1';
	wait for 2 ps;

	end loop;
	wait;
	end process;
 
	stim_proc: process
	begin

		xreg_reset_in <= '1';
		is_jalx_in <= '0';
		wait for 2 ps; 
		xreg_reset_in <= '0';
		wait for 2 ps;


		-- #1: Testando iRType
		-- add t0, zero, zero imm inexistente
		instr <= X"000002b3"; 
		wait for 2 ps; 
		reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		wait for 5 ps;
		assert (PC_ID_A = ZERO32) report "#1: PC Fail to Read" severity error;
		assert(ft_instruction_ID_A = instr) report "#1: Instruction Fail to Read" severity error;
		assert(imm_A = ZERO32) report "#1: Immediate Fail" severity error;
		assert(rsd_A = instr(11 downto 7)) report "#1: Failed to read rd" severity error;

		-- #2: Testando I-type0
		-- lw t0, 16(zero)
		instr <= X"01002283"; 
		wait for 2 ps;
		reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		wait for 5 ps;
		assert (PC_ID_A = ZERO32) report "#2: PC Fail to Read" severity error;
		assert(ft_instruction_ID_A = instr) report "#2: Instruction Fail to Read" severity error;
		assert(imm_A = std_logic_vector(to_signed(16, 32))) report "#2:Immediate Fail" severity error;
		assert(rsd_A = instr(11 downto 7)) report "#2:Failed to read rd" severity error;

		-- #3: Testando I-Type1 
		-- addi t1, zero, -100
		instr <= X"F9C00313";
		wait for 2 ps;
		reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		wait for 5 ps;
		assert (PC_ID_A = ZERO32) report "#3: PC Fail to Read" severity error;
		assert(ft_instruction_ID_A = instr) report "#3: Instruction Fail to Read" severity error;
		assert(imm_A = std_logic_vector(to_signed(-100, 32))) report "#3: Immediate Fail" severity error;
		assert(rsd_A = instr(11 downto 7)) report "#3: Failed to read rd" severity error;

		-- #4: Testando U-Type
		instr <= X"00002437";
		wait for 2 ps; 
		reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		wait for 5 ps; 
		assert (PC_ID_A = ZERO32) report "#4: PC Fail to Read" severity error;
		assert(ft_instruction_ID_A = instr) report "#4: Instruction Fail to Read" severity error;
		assert(imm_A = std_logic_vector(signed(instr(31 downto 12) & X"000"))) report "#4: Immediate Fail" severity error;
		assert(rsd_A = instr(11 downto 7)) report "#4: Failed to read rd" severity error;

		-- #5: Testando S-Type
		instr <= X"02542e23";
		wait for 2 ps; 
		reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		wait for 5 ps; 
		assert (PC_ID_A = ZERO32) report "#5: PC Fail to Read" severity error;
		assert(ft_instruction_ID_A = instr) report "#5: Instruction Fail to Read" severity error;
		assert(imm_A = std_logic_vector(to_signed(60, 32))) report "#4: Immediate Fail" severity error;
		assert(rs1_A = instr(19 downto 15)) report "#4: Failed to read r1" severity error;
		assert(rs2_A = instr(24 downto 20)) report "#4: Failed to read r1" severity error;

		-- #6: Testando SB-Type
		--instr <= "fe5290e3";
		--wait for 2 ps; 
		--reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		--wait for 5 ps; 
		--assert (PC_ID_A = ZERO32) report "#6: PC Fail to Read" severity error;
		--assert(ft_instruction_ID_A = instr) report "#6: Instruction Fail to Read" severity error;
		--assert(imm_A = std_logic_vector(to_signed(60, 32))) report "#6: Immediate Fail" severity error;
		--assert(rs1_A = instr(19 downto 15)) report "#6: Failed to read rd" severity error;

		-- testando branch JALX
		f_breg_wr_in <= '0';
		is_jalr_in <= '0';
		wb_rd_in <= ZERO32; 
		is_jalx_in <= '1';
		instr <= X"F000016F";
		wait for 1 ps;
		reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		wait for 2 ps;
		assert (PC_ID_A = ZERO32) report "PC Fail to Read" severity error;
		assert(ft_instruction_ID_A = instr) report "Instruction Fail to Read" severity error;
		assert(rsd_A = "00010") report "regs(rd) Fail to Read" severity error;
		-- assert(imm_A = std_logic_vector(resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32))) report "Immediate Fail to Read" severity error;
		is_jalx_in <= '0';

		-- testando branch JALR
		-- TODO: Carregar valor diferente nos registradores
		is_jalr_in <= '1';
		instr <= X"F0000167";
		wait for 1 ps;
		reg_IF_ID_in <= X"00000010" & instr & ZERO32;
		wait for 2 ps;
		assert (PC_ID_A = ZERO32) report "PC Fail to Read" severity error;
		assert(ft_instruction_ID_A = instr) report "Instruction Fail to Read" severity error;
		assert(BREG_RA_A = ZERO32) report "regs(A) Fail to Read" severity error;
		assert(pc_branch_out = (resize(signed(instr(31 downto 20)), 32))) report "Failed to Branch" severity error;
		-- assert pc branch
	wait;
	end process;
end tb_decode; 
