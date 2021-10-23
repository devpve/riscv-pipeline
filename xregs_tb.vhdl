------------------------------------------------------------
-- MUX Generic Testbench
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
------------------------------------------------------------
entity testbench is 
end testbench;
------------------------------------------------------------
architecture tb of testbench is 

	component xreg is 
		generic (
			SIZE : natural := WORD_SIZE;
			ADDR : natural := BREG_IDX
		);
		port (
			clk		: in  std_logic;
			wren  	: in  std_logic;
			rs1		: in  std_logic_vector(ADDR-1 downto 0);
			rs2		: in  std_logic_vector(ADDR-1 downto 0);
			rd		: in  std_logic_vector(ADDR-1 downto 0);
			data_in	: in  std_logic_vector(SIZE-1 downto 0);
			A 		: out std_logic_vector(SIZE-1 downto 0);
			B	 	: out std_logic_vector(SIZE-1 downto 0)
		);
	end component;

	signal clk_in, wren_in 	: std_logic := '0';
	signal rs1_in, rs2_in, rd_in 	: std_logic_vector(BREG_IDX-1 downto 0);
	signal data : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ro1_out, ro2_out : std_logic_vector(WORD_SIZE-1 downto 0);

	begin 
		DUT : xreg
			generic map (SIZE => WORD_SIZE, ADDR => BREG_IDX)
			port map(clk => clk_in,
					wren => wren_in, 
					rs1 => rs1_in, 
					rs2 => rs2_in,
					rd => rd_in,
					data_in => data,
					A => ro1_out,
					B => ro2_out);

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

		--rst_in <= '1';
		--wait for 100 ns;
		--assert(ro1_out = X"00000000") report "Fail Reset" severity error;

		--rst_in <= '0';
		wren_in <= '1';
		rd_in <= std_logic_vector(to_unsigned(1, 5));
		data <= X"FF00FF00";
		wait for 50 ns;
		-- come checar o valor de regs?

		wren_in <= '0';
		rs1_in <= std_logic_vector(to_unsigned(1, 5));
		wait for 50 ns;
		assert(ro1_out = X"FF00FF00") report "Fail Read 1" severity error;


		--rst_in <= '0';
		wren_in <= '1';
		rd_in <= std_logic_vector(to_unsigned(2, 5));
		data <= X"FFFFFFFF";
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