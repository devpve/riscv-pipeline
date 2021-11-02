library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity testbench_fetch is 
end testbench_fetch;
-------------------------------------------------------------------------
architecture tb_fetch of testbench_fetch is 

	component fetch_stage is 
		port (clk 	 	: in std_logic; 
			  PC_src 	: in std_logic;
			  branch_PC : in std_logic_vector(WORD_SIZE-1 downto 0); 
			  reg_IF_ID : out std_logic_vector(63 downto 0));
	end component;

	signal clk_in 	: std_logic := '0';
	signal PC_src_in : std_logic := '0';
	signal branch_PC_in : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal reg_IF_ID_out : std_logic_vector(63 downto 0);

	begin 
		DUT : fetch_stage
			port map(clk => clk_in,
					PC_src => PC_src_in,
					branch_PC => branch_PC_in, 
					reg_IF_ID => reg_IF_ID_out);

	clk_process: process
	begin
	for i in 0 to 800 loop
	clk_in <= '0';
	wait for 1 ns;
	clk_in <= '1';
	wait for 1 ns;

	end loop;
	wait;
	end process;
 
	stim_proc: process
	begin
		 
		-- TEST PC
		-- Instruction is the same value as the address 
		wait for 0.5 ns;
		assert(reg_IF_ID_out = X"000002b3" & X"00000000") report "Fetch: PC Zero fail" severity error;
		wait for 2 ns;
		assert(reg_IF_ID_out = X"01002283" & X"00000004") report "Fetch: PC 4 fail" severity error;
		wait for 2 ns;
		assert(reg_IF_ID_out = X"F9C00313" & X"00000008") report "Fetch: PC 8 fail" severity error;
		wait for 2 ns;
		
		PC_src_in <= '1';
		branch_PC_in <= std_logic_vector(to_unsigned(16, 32));
		wait for 2 ns;
		assert(reg_IF_ID_out = X"00000001" & branch_PC_in) report "Fetch: Branch PC Fail" severity error;
		
		wait for 20 ns;
	wait;
	end process;
end tb_fetch; 
