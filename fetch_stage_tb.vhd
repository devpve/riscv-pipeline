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
		port (clk  : in std_logic;
			fetch_sel : in std_logic_vector(1 downto 0);
			PC 		  : in std_logic_vector(WORD_SIZE-1 downto 0);
			branch_PC : in std_logic_vector(WORD_SIZE-1 downto 0);
			reg_IF_ID : out std_logic_vector(95 downto 0));
	end component;

	signal clk_in 	: std_logic := '0';
	signal fetch_sel_in : std_logic_vector(1 downto 0) := "00";
	signal PC_in : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal branch_PC_in : std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;
	signal reg_IF_ID_out : std_logic_vector(95 downto 0);

	begin 
		DUT : fetch_stage
			port map(clk => clk_in,
					fetch_sel => fetch_sel_in,
					PC => PC_in, 
					branch_PC => branch_PC_in, 
					reg_IF_ID => reg_IF_ID_out);

	clk_process: process
	begin
	for i in 0 to 800 loop
	clk_in <= '0';
	wait for 2 ps;
	clk_in <= '1';
	wait for 2 ps;

	end loop;
	wait;
	end process;
 
	stim_proc: process
	begin
		
		-- TEST PC
		-- Instruction is the same value as the address 
		fetch_sel_in <= "00";
		for i in 0 to 15 loop
			PC_in <= std_logic_vector(to_unsigned(i, 32));
			wait for 5 ps;
			assert(reg_IF_ID_out = std_logic_vector(unsigned(PC_in) + 4) & PC_in & PC_in) report "PC Fail to Read" severity error;
		end loop;
		
		-- TEST NEXT_PC_VALUE
		fetch_sel_in <= "01"; 
		PC_in <= std_logic_vector(to_unsigned(5, 32));
		wait for 5 ps;
		assert(reg_IF_ID_out = std_logic_vector(unsigned(PC_in) + 8) & std_logic_vector(unsigned(PC_in) + 4) & std_logic_vector(unsigned(PC_in) + 4)) report "Next PC Fail" severity error;

		wait for 20 ps;

		fetch_sel_in <= "10";
		branch_PC_in <= std_logic_vector(to_unsigned(8, 32));
		wait for 5 ps;
		assert(reg_IF_ID_out = std_logic_vector(unsigned(branch_PC_in) + 4) & branch_PC_in & branch_PC_in) report "Branch PC Fail" severity error;
		
		wait for 20 ps;
	wait;
	end process;
end tb_fetch; 
