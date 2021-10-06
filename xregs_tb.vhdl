------------------------------------------------------------
-- MUX Generic Testbench
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity testbench is 
end testbench;
------------------------------------------------------------
architecture tb of testbench is 

	component xregs is 
		generic (W_SIZE : natural := 32);
		port (clk, wren, rst 	: in std_logic; 
			rs1, rs2, rd	: in std_logic_vector(4 downto 0);
			data	: in std_logic_vector(W_SIZE-1 downto 0);
			ro1, ro2	: out std_logic_vector(W_SIZE-1 downto 0));
	end component;

	constant w_size_gen : natural := 32;
	signal clk_in, wren_in, rst_in 	: std_logic := '0';
	signal rs1_in, rs2_in, rd_in 	: std_logic_vector(4 downto 0);
	signal data_in : std_logic_vector(w_size_gen-1 downto 0);
	signal ro1_out, ro2_out : std_logic_vector(w_size_gen-1 downto 0);

	begin 
		DUT : xregs 
			generic map (W_SIZE => w_size_gen)
			port map(clk => clk_in,
					wren => wren_in, 
					rst => rst_in, 
					rs1 => rs1_in, 
					rs2 => rs2_in,
					rd => rd_in,
					data => data_in,
					ro1 => ro1_out,
					ro2 => ro2_out);

	clk_process: process
	begin

	for i in 1 to 20 loop
	clk_in <= '0';
	wait for 25 ns;
	clk_in <= '1';
	wait for 25 ns;

	end loop;
	wait;
	end process;

	stim_proc: process
	begin

		rst_in <= '1';
		wait for 100 ns;
		assert(ro1_out = X"00000000") report "Fail Reset" severity error;

		rst_in <= '0';
		wren_in <= '1';
		rd_in <= std_logic_vector(to_unsigned(1, 5));
		data_in <= X"FF00FF00";
		wait for 50 ns;
		-- come checar o valor de regs?

		wren_in <= '0';
		rs1_in <= std_logic_vector(to_unsigned(1, 5));
		wait for 50 ns;
		assert(ro1_out = X"FF00FF00") report "Fail Read 1" severity error;


		rst_in <= '0';
		wren_in <= '1';
		rd_in <= std_logic_vector(to_unsigned(2, 5));
		data_in <= X"FFFFFFFF";
		wait for 50 ns;
		-- como checar o valor de regs?

		wren_in <= '0';
		rs2_in <= std_logic_vector(to_unsigned(2, 5));
		wait for 50 ns;
		assert(ro2_out = X"FFFFFFFF") report "Fail Read 2" severity error;


	wait;
	end process;
end tb;
------------------------------------------------------------