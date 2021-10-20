------------------------------------------------------------
-- ULA
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity ulaRV is 
	generic (WSIZE : natural := 32);
	port (opcode	: in std_logic_vector(3 downto 0);
		A, B 	: in std_logic_vector(WSIZE-1 downto 0);
		Z 	: out std_logic_vector(WSIZE-1 downto 0);
		zero	: out std_logic);
end ulaRV;
------------------------------------------------------------
architecture ula of ulaRV is 

function bool2stdv(bval : in boolean) return std_logic_vector is
	begin
    	if (bval = TRUE) 
        	then return X"00000001";
            else return X"00000000";
        end if;
    end function;
	
begin 

	with opcode(3 downto 0) select
	Z <= std_logic_vector(signed(A) + signed(B)) when "0000",
	     std_logic_vector(signed(A) - signed(B)) when "0001",
	     A and B when "0010",
	     A or B when "0011",
	     A xor B when "0100",
	     std_logic_vector(unsigned(A) sll to_integer(unsigned(B))) when "0101",
	     std_logic_vector(unsigned(A) srl to_integer(unsigned(B))) when "0110",
	     std_logic_vector(signed(A) sra to_integer(signed(B))) when "0111",
	     bool2stdv(signed(A) < signed(B)) when "1000",
	     bool2stdv(unsigned(A) < unsigned(B)) when "1001",
	     bool2stdv(signed(A) >= signed(B)) when "1010",
	     bool2stdv(unsigned(A) >= unsigned(B)) when "1011",
	     bool2stdv(A = B) when "1100",
	     bool2stdv(A /= B) when "1101",
	     unaffected when others;

end ula;
------------------------------------------------------------