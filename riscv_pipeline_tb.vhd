library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity testbench_riscvpipe is 
end testbench_riscvpipe;
-------------------------------------------------------------------------
architecture tb_rvpipe of testbench_riscvpipe is 

	component riscv_pipeline is 
		port (
			clk		: in std_logic;
			rst	   	: in std_logic;
			data  	: out std_logic_vector(WORD_SIZE-1 downto 0)
			);
	end component;

	-- fetch stage
	signal clk_in, rst_in	: std_logic;
	signal data_out 		: std_logic_vector(WORD_SIZE-1 downto 0);


	begin 
		riscv : riscv_pipeline
			port map (
				clk => clk_in,
				rst => rst_in,
				data => data_out
				);

	clk_process: process
	begin
	for i in 0 to 800 loop
	clk_in <= '0';
	wait for 1 ps;
	clk_in <= '1';
	wait for 1 ps;

	end loop;
	wait;
	end process;
 
	--stim_proc: process
	--begin

	
	
	--wait;
	--end process;
end tb_rvpipe; 
