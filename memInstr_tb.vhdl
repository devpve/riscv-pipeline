------------------------------------------------------------
-- MEM RV Generic Testbench
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.riscv_pkg.all; 
------------------------------------------------------------
entity testbench_mem is 
end testbench_mem;
------------------------------------------------------------
architecture tb_mem of testbench_mem is 

	component memInstr is 
		generic (WIDTH : natural := WORD_SIZE;
				WADDR : natural := WORD_SIZE);
		port (ADDRESS  : in STD_LOGIC_VECTOR (WORD_SIZE-1 downto 0);
				clk		: in std_logic;
				Q 		: out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end component;

	signal clk_in 	: std_logic := '0';
	signal address_in : std_logic_vector(WORD_SIZE-1 downto 0);
	signal Q_out : std_logic_vector(WORD_SIZE-1 downto 0);

	begin 
		DUT : memInstr
			generic map  (WIDTH => WORD_SIZE, WADDR => WORD_SIZE)
			port map(clk => clk_in,
					ADDRESS => address_in,
					Q => Q_out);

	clk_process: process
	begin
	for i in 0 to 800 loop
	clk_in <= '0';
	wait for 5 ps;
	clk_in <= '1';
	wait for 5 ps;

	end loop;
	wait;
	end process;

	stim_proc: process
	begin

		for i in 0 to 255 loop
			address_in <= std_logic_vector(to_unsigned(i, 32));
			wait for 10 ps;
		end loop;

	wait;
	end process;
end tb_mem;
------------------------------------------------------------