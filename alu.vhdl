------------------------------------------------------------
-- ALU
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
------------------------------------------------------------
entity alu is 
	port (opcode	: in std_logic_vector(3 downto 0);
		A, B 	: in std_logic_vector(WORD_SIZE-1 downto 0);
		aluout 	: out std_logic_vector(WORD_SIZE-1 downto 0);
		zero	: out std_logic);
end alu;
------------------------------------------------------------
architecture alu_a of alu is 

	function bool2stdv(bval : in boolean) return std_logic_vector is
		begin
	    	if (bval = TRUE) 
	        	then return X"00000001";
	            else return X"00000000";
	        end if;
	    end function;
		
	begin 

	with opcode(3 downto 0) select
	aluout <= std_logic_vector(signed(A) + signed(B)) when ULA_ADD,
	     std_logic_vector(signed(A) - signed(B)) when ULA_SUB,
	     A and B when ULA_AND,
	     A or B when ULA_OR,
	     A xor B when ULA_XOR,
	     std_logic_vector(unsigned(A) sll to_integer(unsigned(B))) when ULA_SLL,
	     std_logic_vector(unsigned(A) srl to_integer(unsigned(B))) when ULA_SRL,
	     std_logic_vector(signed(A) sra to_integer(signed(B))) when ULA_SRA,
	     bool2stdv(signed(A) < signed(B)) when ULA_SLT,
	     bool2stdv(unsigned(A) < unsigned(B)) when ULA_SLTU,
	     bool2stdv(signed(A) >= signed(B)) when ULA_SGE,
	     bool2stdv(unsigned(A) >= unsigned(B)) when ULA_SGEU,
	     bool2stdv(A = B) when ULA_SEQ,
	     bool2stdv(A /= B) when ULA_SNE,
	     unaffected when others;

	zero <= '0';
	
end alu_a;
------------------------------------------------------------