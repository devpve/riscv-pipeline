library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity control is 
	port (clk : in std_logic;
		instruction : in std_logic_vector(WORD_SIZE-1 downto 0);
		op_ula :	out std_logic_vector(1 downto 0);
		is_branch,
		is_jalx, 
		is_jalr,  
		mem2reg,
		mem_wr,
		alu_src,
		breg_wr:	out std_logic);
end control;
-------------------------------------------------------------------------
architecture control_a of control is 
	
	alias opcode: std_logic_vector(6 downto 0) is instruction(6 downto 0);

	process(clk)  
	begin 
		if (clk'EVENT and clk='1') then

			case opcode is  
				when iRType =>
					is_branch <= '0';
					is_jalx <= '0';
					is_jalr <= '0';

				when iILType =>

				when iSType => 

				when iBType => 

				when iIType =>

				when iLUI => 

				when iAUIPC => 

				when iJALR =>
					is_jalr <= '1';

				when iJAL => 
					is_jalx <= '1';

				when eCALL =>

			end case;

		end if;

end control_a; 
