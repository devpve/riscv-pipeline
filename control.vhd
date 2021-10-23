library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity control is 
	port (opcode : in std_logic_vector(6 downto 0);
	op_ula :	out std_logic_vector(1 downto 0);
	reg_dst,
	branch,
	is_bne,
	jump,
	mem2reg,
	mem_wr,
	alu_src,
	breg_wr:	out std_logic);
end control;
-------------------------------------------------------------------------
architecture control_a of control is 

	
		
		

end control_a; 
