library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity fetch_stage is 
	port (clk : in std_logic; 
		fetch_sel : in std_logic_vector(1 downto 0);
		PC		  : in std_logic_vector(WORD_SIZE-1 downto 0);
		branch_PC : in std_logic_vector(WORD_SIZE-1 downto 0); 
		reg_IF_ID : out std_logic_vector(95 downto 0));
end fetch_stage;
-------------------------------------------------------------------------
architecture fetch_a of fetch_stage is 

	-- ALIAS for reg_IF_ID: next_PC / Instruction / PC  
	alias next_PC_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(95 downto 64);
	alias ft_instruction_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(63 downto 32);
	alias PC_A: std_logic_vector(WORD_SIZE-1 downto 0) is reg_IF_ID(31 downto 0); 
	
	-- PC / Instruction 
	signal current_pc : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal ft_instruction : std_logic_vector(WORD_SIZE-1 downto 0);

	begin 

		-- MuxPC
		with fetch_sel select 
			current_pc <= PC when "00",
						  std_logic_vector(unsigned(PC) + 4) when "01",
						  branch_PC when "10",
				  		  ZERO32 when others;	

		-- InsMem
		InstrMEM: memInstr 
			generic map (WIDTH => WORD_SIZE,
						 WADDR => WORD_SIZE) 
			port map (ADDRESS  => current_pc,
					  clk	=> clk,
				      Q => ft_instruction);
		
		-- Reg_IF_ID Aliases
		next_PC_A <= std_logic_vector(unsigned(current_pc) + 4);
		ft_instruction_A <= ft_instruction;
		PC_A <= current_pc;
 
end fetch_a; 
