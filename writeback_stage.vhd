library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity wb_stage is 
	port (clk 			: in std_logic;
		  reg_MEM_WB 	: in std_logic_vector(70 downto 0);
		  f_breg_wr 	: out std_logic;
		  rd 			: out std_logic_vector(BREG_IDX-1 downto 0);
		  wb_rd			: out std_logic_vector(WORD_SIZE-1 downto 0));
end wb_stage;
-------------------------------------------------------------------------
architecture wb_a of wb_stage is 

	-- alias for reg_MEM_WB
	alias breg_wr_MEM: std_logic is reg_MEM_WB(0);
	alias mem2reg_MEM: std_logic is reg_MEM_WB(1);
	alias MEMRESULT_MEM: std_logic_vector(WORD_SIZE-1 downto 0) is reg_MEM_WB(33 downto 2);
	alias ADDRESS_MEM: std_logic_vector(WORD_SIZE-1 downto 0) is reg_MEM_WB(65 downto 34);
	alias RD_MEM: std_logic_vector(BREG_IDX-1 downto 0) is reg_MEM_WB(70 downto 66);

	begin 

		with mem2reg_MEM select 
			wb_rd <= 
				ADDRESS_MEM when '0',
				MEMRESULT_MEM when '1',
				unaffected when others;

		f_breg_wr <= breg_wr_MEM;
		rd <= RD_MEM;

end wb_a;
