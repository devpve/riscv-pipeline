------------------------------------------------------------
-- MEM RV Generic Testbench
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
------------------------------------------------------------
entity testbench is 
end testbench;
------------------------------------------------------------
architecture tb of testbench is 

	component mem_rv is 
		port (clk, we 	: in std_logic; 
			  address	: in std_logic_vector;
			  datain 	: in std_logic_vector;
			  dataout 	: out std_logic_vector
			  );
	end component;

	signal clk_in 	: std_logic := '0';
	signal we_in 	: std_logic := '0';
	signal address_in : std_logic_vector(7 downto 0);
	signal datain_in, dataout_out : std_logic_vector(31 downto 0);

	begin 
		DUT : mem_rv 
			port map(clk => clk_in,
					we => we_in, 
					address => address_in,
					datain => datain_in,
					dataout => dataout_out);

	clk_process: process
	begin
	-- perguntar do clock
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
			address_in <= std_logic_vector(to_unsigned(i, 8));
			datain_in <= std_logic_vector(to_unsigned(i, 30)) & "00";
			wait for 10 ps;
		end loop;

		we_in <= '1';
		wait for 10 ps;

		for i in 0 to 255 loop
			address_in <= std_logic_vector(to_unsigned(i, 8));
			datain_in <= std_logic_vector(to_unsigned(i, 30)) & "00";
			wait for 10 ps;
		end loop;


	wait;
	end process;
end tb;
------------------------------------------------------------