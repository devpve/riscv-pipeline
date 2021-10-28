library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity alu_ctr is
	port (
		clk 		: in std_logic;
		alu_op		: in std_logic_vector(1 downto 0);
		funct3		: in std_logic_vector(2 downto 0);
		funct7		: in std_logic;
		alu_ctr	   : out std_logic_vector(3 downto 0)
	);
end alu_ctr;
-------------------------------------------------------------------------
architecture alu_ctr_a of alu_ctr is 
	
	signal alu_control : std_logic_vector(3 downto 0) := "0000";

	begin 
		process(clk)
		begin 
			if (clk'EVENT and clk='1') then
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
							when others => 
								alu_control <= "1111";
						end case;

				when "01" => --load/store
					alu_control <= ULA_ADD;
				when "10" => -- branch
					alu_control <= ULA_SUB;
				when others => 
					alu_control <= "1111";
			end case;
		end if;
	end process;

	alu_ctr <= alu_control;

end alu_ctr_a;