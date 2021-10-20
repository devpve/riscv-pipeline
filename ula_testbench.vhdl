
------------------------------------------------------------
-- ULA TESTBENCH
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity ula_tb is 
end ula_tb; 
------------------------------------------------------------
architecture tb_arch of ula_tb is 
	component ulaRV IS
		generic (WSIZE: natural := 32);
		port ( opcode	: in std_logic_vector(3 downto 0);
				A, B 	: in std_logic_vector(WSIZE-1 downto 0);
				Z 		: out std_logic_vector(WSIZE-1 downto 0);
				zero	: out std_logic);
  	end component;
	
	constant word : natural := 32;
	signal opcode_in : std_logic_vector(3 downto 0) := (others => '0');
	signal A_in, B_in : std_logic_vector(word-1 downto 0) := (others => '0');
	signal Z_out : std_logic_vector(word-1 downto 0);
	signal zero_out : std_logic;

begin 

	DUT: ulaRV  
          generic map (WSIZE => word)
          port map(opcode => opcode_in,
          			A => A_in,
          			B => B_in,
          			Z => Z_out,
          			zero => zero_out);

    stim_proc: process
    begin

    -- 50 ns ADD
    opcode_in <= "0000";
    A_in <= std_logic_vector(to_unsigned(2, word));
    B_in <= std_logic_vector(to_unsigned(3, word));
    wait for 50 ns;

    -- 100 ns SUB
    opcode_in <= "0001";
    A_in <= std_logic_vector(to_unsigned(3, word));
    B_in <= std_logic_vector(to_unsigned(2, word));
    wait for 50 ns;
	
    -- 150 ns AND
    opcode_in <= "0010";
    A_in <= X"FFFF0000";
    B_in <= X"FF00FF00";
    wait for 25 ns;

    --A_in <= (OTHERS => '0');
    --B_in <= (OTHERS => '1');
    --wait for 25 ns;

    -- 200 ns OR
    opcode_in <= "0011";
    --A_in <= (OTHERS => '0');
    --B_in <= (OTHERS => '1');
    wait for 50 ns;

    -- 200 ns XOR
    opcode_in <= "0100";
    --A_in <= (OTHERS => '0');
    --B_in <= (OTHERS => '1');
    wait for 25 ns;

    --A_in <= (OTHERS => '1');
    --B_in <= (OTHERS => '1');
    wait for 25 ns;

     -- 250 ns sll
    opcode_in <= "0101";
    A_in <= (OTHERS => '1');
    B_in <= std_logic_vector(to_unsigned(2, word));
    wait for 50 ns;

    -- 300 ns srl
    opcode_in <= "0110";
    A_in <= (OTHERS => '1');
    B_in <= std_logic_vector(to_unsigned(2, word));
    wait for 50 ns;

    -- 350 ns sra
    opcode_in <= "0111";
    A_in <= std_logic_vector(to_signed(-10, word));
    B_in <= std_logic_vector(to_unsigned(1, word));
    wait for 25 ns;
     
    opcode_in <= "0111";
    A_in <= std_logic_vector(to_unsigned(8, word));
    B_in <= std_logic_vector(to_signed(1, word));
    wait for 25 ns;

    -- 400 ns signed <
    opcode_in <= "1000";
    A_in <= std_logic_vector(to_signed(8, word));
    B_in <= std_logic_vector(to_signed(10, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_signed(10, word));
    B_in <= std_logic_vector(to_signed(8, word));
    wait for 25 ns;
    
    A_in <= std_logic_vector(to_signed(-8, word));
    B_in <= std_logic_vector(to_signed(-1, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_signed(8, word));
    B_in <= std_logic_vector(to_signed(8, word));
    wait for 25 ns;
    
    -- 500 ns < unsigned
    opcode_in <= "1001";
    A_in <= std_logic_vector(to_unsigned(8, word));
    B_in <= std_logic_vector(to_unsigned(10, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_unsigned(10, word));
    B_in <= std_logic_vector(to_unsigned(8, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_unsigned(8, word));
    B_in <= std_logic_vector(to_unsigned(8, word));
    wait for 25 ns;
    
    -- 550 ns >= signed
    opcode_in <= "1010";
    A_in <= std_logic_vector(to_signed(10, word));
    B_in <= std_logic_vector(to_signed(8, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_signed(8, word));
    B_in <= std_logic_vector(to_signed(10, word));
    wait for 25 ns;
    
    A_in <= std_logic_vector(to_signed(8, word));
    B_in <= std_logic_vector(to_signed(8, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_signed(-8, word));
    B_in <= std_logic_vector(to_signed(-1, word));
    wait for 25 ns;
    
    -- >= unsigned
    opcode_in <= "1011";    
    A_in <= std_logic_vector(to_unsigned(8, word));
    B_in <= std_logic_vector(to_unsigned(10, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_unsigned(10, word));
    B_in <= std_logic_vector(to_unsigned(8, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_unsigned(8, word));
    B_in <= std_logic_vector(to_unsigned(8, word));
    wait for 25 ns;

    -- >= unsigned
    opcode_in <= "1011";    
    A_in <= std_logic_vector(to_unsigned(8, word));
    B_in <= std_logic_vector(to_unsigned(10, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_unsigned(10, word));
    B_in <= std_logic_vector(to_unsigned(8, word));
    wait for 25 ns;

    A_in <= std_logic_vector(to_unsigned(8, word));
    B_in <= std_logic_vector(to_unsigned(8, word));
    wait for 25 ns;

    -- =
    opcode_in <= "1100";    
    A_in <= X"FFFF0000";
    B_in <= X"FF00FF00";
    wait for 25 ns;

    A_in <= X"FF00FF00";
    B_in <= X"FF00FF00";
    wait for 25 ns;

    -- /= 
    opcode_in <= "1101";
    A_in <= X"FFFF0000";
    B_in <= X"FF00FF00";
    wait for 25 ns;

    A_in <= X"FF00FF00";
    B_in <= X"FF00FF00";
    wait for 25 ns;

	wait;
    end process;
end tb_arch;