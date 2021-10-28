------------------------------------------------------------
-- DATA MEM RV Generic Testbench
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.riscv_pkg.all; 
------------------------------------------------------------
entity testbench_memData is 
end testbench_memData;
------------------------------------------------------------
architecture tb_memData of testbench_memData is 

	component memData is 
		generic (
			WIDTH : natural := WORD_SIZE;
			WADDR : natural := WORD_SIZE
		); 
		port
		(
			address		: in std_logic_vector (WADDR-1 downto 0);
			clk	 		: in std_logic;
			data		: in std_logic_vector (WORD_SIZE-1 downto 0);
			wren		: in std_logic;
			rden 		: in std_logic;
			Q			: out std_logic_vector (WORD_SIZE-1 downto 0)
		);
	end component;

	signal clk_in 	: std_logic := '0';
	signal wren_in, rden_in : std_logic := '0';
	signal data_in, address_in : std_logic_vector(WORD_SIZE-1 downto 0);
	signal Q_out : std_logic_vector(WORD_SIZE-1 downto 0);

	begin 
		DUT : memData
			generic map  (WIDTH => WORD_SIZE, WADDR => WORD_SIZE)
			port map(clk => clk_in,
					address => address_in,
					data => data_in, 
					wren => wren_in,
					rden => rden_in,
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
		
		rden_in <= '1';

		for i in 0 to 5 loop
			address_in <= std_logic_vector(to_unsigned(i, 32));
			wait for 10 ps;
		end loop;

		data_in <= X"FFFFFFFF";
		address_in <= ZERO32;
		wait for 1 ps;
		wren_in <= '1';

		wait for 10 ps;

		address_in <= ZERO32;
		rden_in <= '1';
		wren_in <= '0';
		wait for 10 ps; 

		assert(Q_out = X"FFFFFFFF") report "error" severity error;

		address_in <= X"00000001";
		wait for 10 ps; 

		assert(Q_out = X"00000001") report "error" severity error;

	wait;
	end process;
end tb_memData;
------------------------------------------------------------