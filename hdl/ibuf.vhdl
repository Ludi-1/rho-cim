library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity ibuf is
    generic(
        ibuf_size: integer := 784;
        addr_size: integer := integer(ceil(log2(real(ibuf_size))));
        max_datatype_size: integer := 32
    );
    port (
        i_clk : in std_logic;
        i_write_enable : in std_logic;
        i_write_addr : in std_logic_vector(addr_size - 1 downto 0);
        i_read_addr: in std_logic_vector(addr_size - 1 downto 0);
        i_data : in std_logic_vector(max_datatype_size - 1 downto 0);
        o_data : out std_logic_vector(max_datatype_size - 1 downto 0)
    );
end ibuf;

architecture behavioral of ibuf is
    type ibuf_mem is array(0 to ibuf_size - 1) of std_logic_vector(max_datatype_size - 1 downto 0);
    signal s_registers: ibuf_mem;
begin
    write_proc: process(all)
    begin
        if rising_edge(i_clk) then
            if (i_write_enable = '1') then
                s_registers(to_integer(unsigned(i_write_addr))) <= i_data;
            -- else
            --     o_data <= s_registers(to_integer(unsigned(i_read_addr)));
            end if;
        end if;
    end process write_proc;

    read_proc: process (all)
    begin
        o_data <= s_registers(to_integer(unsigned(i_read_addr)));
    end process read_proc;
end behavioral;