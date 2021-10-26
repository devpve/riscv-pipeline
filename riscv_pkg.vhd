library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
   
package riscv_pkg is
	
	constant IMEM_SIZE	: integer := 1024;
	constant IMEM_ADDR	: integer := 8;
	constant WORD_SIZE 	: natural := 32;
	constant BREG_IDX 	: natural := 5;
	constant ZERO32 		: std_logic_vector(WORD_SIZE-1 downto 0) := (others=>'0');
	constant INC_PC		: std_logic_vector(WORD_SIZE-1 downto 0) := (2=>'1', others=>'0');
	
	-- Type Declaration (optional)
	--type word_array is array (natural range<>) of std_logic_vector(WORD_SIZE-1 downto 0);
	
	-- Opcodes do RV32I
	constant iRType		: std_logic_vector(6 downto 0) := "0110011";
	constant iILType		: std_logic_vector(6 downto 0) := "0000011";
	constant iSType		: std_logic_vector(6 downto 0) := "0100011";
	constant iBType		: std_logic_vector(6 downto 0) := "1100011"; -- branch
	-- descobre qual branch no funct3
	-- função shift diferente
	constant iIType		: std_logic_vector(6 downto 0) := "0010011";
	constant iLUI			: std_logic_vector(6 downto 0) := "0110111";
	constant iAUIPC		: std_logic_vector(6 downto 0) := "0010111";
	constant iJALR			: std_logic_vector(6 downto 0) := "1100111";
	constant iJAL			: std_logic_vector(6 downto 0) := "1101111";
	constant eCALL			: std_logic_vector(6 downto 0) := "1110011";

	
	-- Campo funct3
	constant iADDSUB3		: std_logic_vector(2 downto 0) := "000";
	constant iXOR3			: std_logic_vector(2 downto 0) := "100";
	constant iADD3			: std_logic_vector(2 downto 0) := "000";
	constant iOR3			: std_logic_vector(2 downto 0) := "110";
	constant iSLTI3			: std_logic_vector(2 downto 0) := "010";
	constant iAND3			: std_logic_vector(2 downto 0) := "111";
	constant iSLTIU3		: std_logic_vector(2 downto 0) := "011"; -- 001? bug
	constant iSR3			: std_logic_vector(2 downto 0) := "101";
	constant iBEQ3			: std_logic_vector(2 downto 0) := "000";
	constant iBNE3			: std_logic_vector(2 downto 0) := "001";
	constant iBLT3			: std_logic_vector(2 downto 0) := "100";
	constant iBGE3			: std_logic_vector(2 downto 0) := "101";	
	constant iBLTU3			: std_logic_vector(2 downto 0) := "110";
	constant iBGEU3			: std_logic_vector(2 downto 0) := "111";
	constant iLB3			: std_logic_vector(2 downto 0) := "000";
	constant iLH3			: std_logic_vector(2 downto 0) := "001";
	constant iSLL3			: std_logic_vector(2 downto 0) := "001";
	constant iSRI3			: std_logic_vector(2 downto 0) := "101";
	constant iLW3			: std_logic_vector(2 downto 0) := "000";
	constant iLBU3			: std_logic_vector(2 downto 0) := "100";
	constant iLHU3			: std_logic_vector(2 downto 0) := "101";
	constant iSB3			: std_logic_vector(2 downto 0) := "000";
	constant iSH3			: std_logic_vector(2 downto 0) := "001";
	constant iSW3			: std_logic_vector(2 downto 0) := "010";
	
	-- Campo funct7 / bit30	
	constant iSUB7			: std_logic := '1';
	constant iSRA7			: std_logic := '1';
	constant iSRAI7			: std_logic := '1';

	
	-- Controle ULA
	constant ULA_ADD		: std_logic_vector(3 downto 0) := "0000";
	constant ULA_SUB		: std_logic_vector(3 downto 0) := "0001";
	constant ULA_AND		: std_logic_vector(3 downto 0) := "0010";
	constant ULA_OR			: std_logic_vector(3 downto 0) := "0011";
	constant ULA_XOR		: std_logic_vector(3 downto 0) := "0100";
	constant ULA_SLL		: std_logic_vector(3 downto 0) := "0101";
	constant ULA_SRL		: std_logic_vector(3 downto 0) := "0110";
	constant ULA_SRA		: std_logic_vector(3 downto 0) := "0111";
	constant ULA_SLT		: std_logic_vector(3 downto 0) := "1000";
	constant ULA_SLTU		: std_logic_vector(3 downto 0) := "1001";
	constant ULA_SGE		: std_logic_vector(3 downto 0) := "1010";
	constant ULA_SGEU		: std_logic_vector(3 downto 0) := "1011";
	constant ULA_SEQ		: std_logic_vector(3 downto 0) := "1100";
	constant ULA_SNE		: std_logic_vector(3 downto 0) := "1101";
	
	-- Aliases
	component rv_pipe is
		port (
			clk		: in std_logic;
			clk_rom	: in std_logic;
			rst	   : in std_logic;
			data  	: out std_logic_vector(WORD_SIZE-1 downto 0)
		);
	end component;

	component fetch_stage is 
		port (
			clk 	 	: in std_logic; 
			PC_src 		: in std_logic;
		    PC   		: in std_logic_vector(WORD_SIZE-1 downto 0);
			branch_PC 	: in std_logic_vector(WORD_SIZE-1 downto 0); 
			reg_IF_ID 	: out std_logic_vector(63 downto 0)
		);
	end component;

	component decode_stage is 
		port (clk 		: in std_logic;
		  PC 		: in std_logic_vector(WORD_SIZE-1 downto 0);
		  f_breg_wr : in std_logic;
		  wb_rd 	: in std_logic_vector(WORD_SIZE-1 downto 0);
		  reg_IF_ID : in std_logic_vector(63 downto 0);
		  reg_ID_EX : out std_logic_vector(179 downto 0)
		);
	end component;
	
	component reg is
	generic (
		SIZE : natural := 32
	);
	port 
	(
		clk		: in std_logic;
		wren		: in std_logic;
		rst		: in std_logic;
		d_in	   : in std_logic_vector(WORD_SIZE-1 downto 0);
		d_out	: out std_logic_vector(WORD_SIZE-1 downto 0)
	);
	end component; 
	
	component mux_2 is
	generic (
		SIZE : natural := 32
	);
	port (	
		in0, in1	: in std_logic_vector(SIZE-1 downto 0);
		sel		: in std_logic;
		m_out		: out std_logic_vector(SIZE-1 downto 0)
	);
	end component;

	component adder is
	generic (
		DATA_WIDTH : natural := WORD_SIZE
	);
	port (
		a	 : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		b	 : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		res : out std_logic_vector ((DATA_WIDTH-1) downto 0)
	);
	end component;
	
	component memInstr is
	generic (
		WIDTH : natural := WORD_SIZE;
		WADDR : natural := 8);
	port (ADDRESS  : in STD_LOGIC_VECTOR (WADDR-1 downto 0);
			clk		: in std_logic;
			Q 			: out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end component;

	component ula is
	port (
		aluctl: 	in  std_logic_vector(3 downto 0);
		A, B:		in  std_logic_vector(WORD_SIZE-1 downto 0);
		aluout:	out std_logic_vector(WORD_SIZE-1 downto 0);
		zero:		out std_logic
		);
	end component;
	
	component xreg is
	generic (
		SIZE : natural := WORD_SIZE;
		ADDR : natural := BREG_IDX
	);
	port 
	(	
		clk		: in  std_logic;
		wren  	: in  std_logic;
		rs1		: in  std_logic_vector(ADDR-1 downto 0);
		rs2		: in  std_logic_vector(ADDR-1 downto 0);
		rd			: in  std_logic_vector(ADDR-1 downto 0);
		data_in	: in  std_logic_vector(SIZE-1 downto 0);
		A 			: out std_logic_vector(SIZE-1 downto 0);
		B	 		: out std_logic_vector(SIZE-1 downto 0)
	);

	end component;
	
	
	component alu_ctr is
	port (
		alu_op		: in std_logic_vector(1 downto 0);
		funct3		: in std_logic_vector(2 downto 0);
		funct7		: in std_logic;
		alu_ctr	   : out std_logic_vector(3 downto 0)
	);
	end component;
	


	component control is
	port (
		clk  		: in std_logic;
		instruction	: in std_logic_vector(WORD_SIZE-1 downto 0);
		alu_op 		: out std_logic_vector(1 downto 0);
		pc_src,
		is_branch,
		is_jalr,  
		is_jalx,
		mem_wr,
		mem_rd,
		mem2reg,
		alu_src,
		breg_wr 	: out std_logic
		);
	end component;

	component genImm32 is
		port (
			instr	: in std_logic_vector(WORD_SIZE - 1 downto 0);
			imm32 : out signed(WORD_SIZE-1 downto 0)
			);
	end component;

	component data_mem is
		port
		(
			address	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC;
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;

	component clk_div is
		port
		(
			clk	  : in std_logic;
			clk64   : out std_logic
		);

	end component;
	
--	procedure mux2x1 (signal x0, x1	: in std_logic_vector(WORD_SIZE-1 downto 0); 
--							signal sel	: in std_logic;
--							signal z 	: out std_logic_vector(WORD_SIZE-1 downto 0) );
	
	
end riscv_pkg;


package body riscv_pkg is

	-- Type Declaration (optional)

	-- Subtype Declaration (optional)

	-- Constant Declaration (optional)

	-- Function Declaration (optional)

	-- Function Body (optional)

	-- Procedures
	procedure mux2x1 (signal x0, x1	: in std_logic_vector(WORD_SIZE-1 downto 0); 
							signal sel		: in std_logic;
							signal z 		: out std_logic_vector(WORD_SIZE-1 downto 0) ) is
	begin	
		if (sel = '1') then	
			z <= x1;
		else	
			z <= x0;
		end if;
	end procedure;

end riscv_pkg;
