library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all; 
-------------------------------------------------------------------------
entity memory_stage is 
	port (clk 			: in std_logic;
		  reg_EX_MEM 	: in std_logic_vector(105 downto 0);
		  reg_MEM_WB 	: out std_logic_vector(103 downto 0));
end memory_stage;
-------------------------------------------------------------------------
architecture memory_a of memory_stage is 

	-- alias for reg_EX_MEM
	alias breg_wr_EX: std_logic is reg_EX_MEM(0);
	alias mem2reg_EX: std_logic is reg_EX_MEM(1);
	alias mem_wr_EX: std_logic is reg_EX_MEM(2);
	alias mem_rd_EX: std_logic is reg_EX_MEM(3);
	alias ALU_RESULT_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(35 downto 4);
	alias RD2_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(67 downto 36);
	alias RD_EX: std_logic_vector(BREG_IDX-1 downto 0) is reg_EX_MEM(72 downto 68);
	alias NEXTPC_EX: std_logic_vector(WORD_SIZE-1 downto 0) is reg_EX_MEM(104 downto 73);
	alias is_jalx_EX: std_logic is reg_EX_MEM(105);
	
	-- alias for reg_MEM_WB
	alias breg_wr_MEM: std_logic is reg_MEM_WB(0);
	alias mem2reg_MEM: std_logic is reg_MEM_WB(1);
	alias MEMRESULT_MEM: std_logic_vector(WORD_SIZE-1 downto 0) is reg_MEM_WB(33 downto 2);
	alias ADDRESS_MEM: std_logic_vector(WORD_SIZE-1 downto 0) is reg_MEM_WB(65 downto 34);
	alias RD_MEM: std_logic_vector(BREG_IDX-1 downto 0) is reg_MEM_WB(70 downto 66);
	alias NEXTPC_MEM: std_logic_vector(WORD_SIZE-1 downto 0) is reg_MEM_WB(102 downto 71);
	alias is_jalx_MEM: std_logic is reg_MEM_WB(103);

	signal mem_result: std_logic_vector(WORD_SIZE-1 downto 0) := ZERO32;

	begin 

		DataMem: memData
		generic map (WIDTH => WORD_SIZE,
					 WADDR => WORD_SIZE) 
		port map (address  => ALU_RESULT_EX,
				  clk	=> clk,
				  data => RD2_EX,
				  wren => mem_wr_EX,
				  rden => mem_rd_EX,
			      Q => mem_result);

		process (clk)
		begin 

			if (clk'EVENT and clk='1') then
				-- final register
				breg_wr_MEM <= breg_wr_EX;
				mem2reg_MEM <= mem2reg_EX;
				MEMRESULT_MEM <= mem_result;
				ADDRESS_MEM <= ALU_RESULT_EX;
				RD_MEM <= RD_EX;
				NEXTPC_MEM <= NEXTPC_EX;
				is_jalx_MEM <= is_jalx_EX;
			end if;
		end process;



end memory_a;
