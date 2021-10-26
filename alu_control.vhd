library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity alu_ctr is
	port (
		alu_op		: in std_logic_vector(1 downto 0);
		funct3		: in std_logic_vector(2 downto 0);
		funct7		: in std_logic;
		alu_ctr	   : out std_logic_vector(3 downto 0)
	);
end alu_ctr;
-------------------------------------------------------------------------
architecture alu_ctr_a of alu_ctr is 
	
	signal alu_control : std_logic_vector(3 downto 0);

	begin 
		process 
		begin 
			case alu_op is 
				when "00" => -- rtype/look for funct3
					case funct3 is 
						when iADDSUB3 =>
							if (funct7 = '0') then
								alu_control <= ULA_ADD;

							elsif (funct7 = '1') then 
								alu_control <= ULA_SUB;
							end if;

						when iSLL3 =>
							alu_control <= ULA_SLL;

						when iSLTI3 =>
							alu_control <= ULA_SLT;

						when iSLTIU3 =>
							alu_control <= ULA_SLTU;

						when iXOR3 =>
							alu_control <= ULA_XOR;

						when iSR3 =>
							if (funct7 = '0') then
								alu_control <= ULA_SRL;

							elsif (funct7 = '1') then 
								alu_control <= ULA_SRA;
							end if;

						when iOR3 => 
							alu_control <= ULA_OR;

						when iAND3 =>
							alu_control <= ULA_AND;
					end case;
				when "01" => --load/store
					case funct3 is 
						alu_control <= ULA_ADD;
						
					end case;
				when "10" => -- branch
					case funct3 is 
						alu_control <= ULA_SUB;
		
					end case;
				when "11" => -- default
					alu_control <= "0000";
			end case;
		end process;

	alu_ctr <= alu_control;

end alu_ctr_a;