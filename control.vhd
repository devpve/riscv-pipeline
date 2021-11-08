library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity control is 
	port (
		clk  		: in std_logic;
		instruction	: in std_logic_vector(WORD_SIZE-1 downto 0);
		alu_op 		: out std_logic_vector(1 downto 0);
		pc_src,
		is_branch,
		is_jalr,  
		is_jalx,
		is_lui,
		is_auipc,
		mem_wr,
		mem_rd,
		mem2reg,
		alu_src,
		breg_wr 	: out std_logic
		);
end control;
-------------------------------------------------------------------------
architecture control_a of control is 
	
	alias opcode: std_logic_vector(6 downto 0) is instruction(6 downto 0);
	alias funct3: std_logic_vector(2 downto 0) is instruction(14 downto 12);

	begin 
		process(clk)  
		begin 
			if (clk'EVENT and clk='1') then

				case opcode is  
					-- R TYPE Arithmetic
					when iRType =>
						pc_src <= '0';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '0';
						is_lui <= '0';
						is_auipc <= '0';
						mem2reg <= '0';
						breg_wr <= '1';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '0';
						alu_op <= "00";

					-- I TYPE Arithmetic
					when iIType =>
						pc_src <= '0';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '0';
						is_lui <= '0';
						is_auipc <= '0';
						mem2reg <= '0';
						breg_wr <= '1';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '1';
						alu_op <= "00";

					-- Load Type
					when iILType =>
						pc_src <= '0';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '0';
						is_lui <= '0';
						is_auipc <= '0';
						mem2reg <= '1';
						breg_wr <= '1';
						mem_wr <= '0'; 
						mem_rd <= '1';
						alu_src <= '1';
						alu_op <= "01";

					-- Store Type
					when iSType => 
						pc_src <= '0';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '0';
						is_lui <= '0';
						is_auipc <= '0';
						mem2reg <= '0';
						breg_wr <= '0';
						mem_wr <= '1'; 
						mem_rd <= '0';
						alu_src <= '1';
						alu_op <= "01";

					-- Branch Type
					when iBType => 
						pc_src <= '1';
						is_branch <= '1';
						is_jalr <= '0';
						is_jalx <= '0';
						is_lui <= '0';
						is_auipc <= '0';
						mem2reg <= '0';
						breg_wr <= '0';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '1';
						alu_op <= "10";

					-- Jump Type Jalx
					when iJAL => 
						pc_src <= '1';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '1';
						is_lui <= '0';
						is_auipc <= '0';
						mem2reg <= '0';
						breg_wr <= '0';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '1';
						alu_op <= "01";

					-- Jump Type Jalr
					when iJALR =>
						pc_src <= '1';
						is_branch <= '0';
						is_jalr <= '1';
						is_jalx <= '0';
						is_lui <= '0';
						is_auipc <= '0';
						mem2reg <= '0';
						breg_wr <= '0';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '0';
						alu_op <= "01";

					-- LUI
					when iLUI => 
						pc_src <= '0';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '0';
						is_lui <= '1';
						is_auipc <= '0';
						mem2reg <= '0';
						breg_wr <= '1';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '1';
						alu_op <= "01";

					-- AUI
					when iAUIPC => 
						pc_src <= '0';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '0';
						is_lui <= '0';
						is_auipc <= '1';
						mem2reg <= '0';
						breg_wr <= '1';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '1';
						alu_op <= "01";

					when others =>
						pc_src <= '0';
						is_branch <= '0';
						is_jalr <= '0';
						is_jalx <= '0';
						mem2reg <= '0';
						breg_wr <= '0';
						mem_wr <= '0'; 
						mem_rd <= '0';
						alu_src <= '0';
						alu_op <= "11";

				end case;

			end if;
		end process;
end control_a; 
