library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is 
end testbench;

architecture tb of testbench is 

	component genImm32 is 
		port (instr : in std_logic_vector(31 downto 0);
			imm32 : out signed(31 downto 0));
	end component;

	signal instr_in : std_logic_vector(31 downto 0); 
	signal imm32_out : signed(31 downto 0);

	begin
		DUT: genImm32
			port map (instr => instr_in, 
					imm32 => imm32_out);
	stim_proc: process
	begin
	
		instr_in <= X"000002b3";
		wait for 10 ns;

		instr_in <= X"01002283";
		wait for 10 ns;

		instr_in <= X"f9c00313";
		wait for 10 ns;

		instr_in <= X"fff2c293";
		wait for 10 ns;

		instr_in <= X"16200313";
		wait for 10 ns;

		instr_in <= X"01800067";
		wait for 10 ns;

		instr_in <= X"00002437";
		wait for 10 ns;

		instr_in <= X"02542e23";
		wait for 10 ns;

		instr_in <= X"fe5290e3";
		wait for 10 ns;

		instr_in <= X"00c000ef";
		wait for 10 ns;

	wait;
	end process;

end;