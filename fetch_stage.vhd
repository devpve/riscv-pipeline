-------------------------------------------------------------------------
-- Fetch Stage Calcula o proximo PC e pega a proxima instruçao 
-- que sera executada utilizando a memoria de instrucoes.
-- Sinais de entrada: clk, PC_src, branch_PC
-- Sinais de saída: reg_IF_ID
-- 		Composto por PC e Instrucao
-------------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity fetch_stage is 
	port (clk 	 	: in std_logic; 
		  PC_src 	: in std_logic;
		  branch_PC : in std_logic_vector(WORD_SIZE-1 downto 0); 
		  reg_IF_ID : out std_logic_vector(63 downto 0));
end fetch_stage;
-------------------------------------------------------------------------
architecture fetch_a of fetch_stage is 

	-- alias for reg_IF_ID: Instruction / PC  
	alias PC_IF: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(31 downto 0);
	alias instruction_IF: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(63 downto 32);
	
	-- PC / Instruction 
	signal current_pc : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal instruction : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;

	begin 

		-- InstrMem
		InstrMEM: memInstr 
		generic map (WIDTH => WORD_SIZE,
					 WADDR => WORD_SIZE) 
		port map (ADDRESS  => current_pc,
				  clk	=> clk,
			      Q => instruction);

		process (clk)
		begin 

			if (clk'EVENT and clk='1') then

				-- MuxPC
				with PC_src select 
					current_pc <= std_logic_vector(unsigned(current_pc) + 1) when '0',
								  branch_PC when '1',
						  		  ZERO32 when others;
						  		  
				-- Output: Reg_IF_ID (PC + Instruction)
				PC_IF <= current_pc;
				instruction_IF <= instruction;	
			end if;

		end process;
		
end fetch_a; 
