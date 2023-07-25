library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_package.all;

entity fc_fifo is
    generic(
        datatype_size: integer := 8;
        fifo_size: integer := 28 -- mnist 28x28 image
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic;
        o_ibuf_full: out std_logic;
        i_data: in std_logic_vector(datatype_size - 1 downto 0);
        o_data: out std_logic_vector(datatype_size * fifo_size - 1 downto 0)
    );
end fc_fifo;

architecture behavioral of fc_fifo is
    type fifo_mem is array(fifo_size - 1 downto 0) of std_logic_vector(datatype_size - 1 downto 0);
 
    signal s_fifo_mem: fifo_mem;
    signal s_count: natural range fifo_size - 1 downto 0;
begin

    data_proc: process(all)
    begin

        -- Shift the FIFO buffer
        if rising_edge(i_clk) then
            if (i_write_enable = '1') then
                s_fifo_mem(0) <= i_data;
                g_ibuf_shift: for fifo_index in fifo_size - 1 downto 1 loop
                        s_fifo_mem(fifo_index) <= s_fifo_mem(fifo_index - 1);
                end loop g_ibuf_shift;
            end if;
        end if;

        -- FIFO generate 'full' signal
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_count <= 0;
                o_ibuf_full <= '0';
            else
                if i_write_enable = '1' then
                    if s_count = fifo_size - 1 then
                        s_count <= s_count;
                        o_ibuf_full <= '1';
                    else
                        s_count <= s_count + 1;
                        o_ibuf_full <= '0';
                    end if;
                end if;
            end if;
        end if;

        -- Unroll 2D vector into 1D vector
        g_output_data: for fifo_idx in 0 to fifo_size - 1 loop
            o_data((fifo_idx + 1) * datatype_size - 1 downto fifo_idx * datatype_size) <= s_fifo_mem(fifo_idx);
        end loop g_output_data;

    end process data_proc;

end behavioral;