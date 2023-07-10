library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_pkg.all;

entity cnn_ibuf is
    generic(
        kernel_size: integer := 5; -- 5x5 kernel
        datatype_size: integer := 8;
        channels: integer := 1;
        kernels: integer := 5;
        image_size: integer := 28 -- mnist 28x28 image
    );
    port (
        i_clk : in std_logic;
        i_write_enable : in std_logic;
        
        i_data : in data_array(channels - 1 downto 0)(datatype_size - 1 downto 0);
        o_data : out data_array(channels - 1 downto 0)(datatype_size*kernel_size**2 - 1 downto 0)
    );
end cnn_ibuf;

architecture behavioral of cnn_ibuf is
    type fifo_mem is array(kernel_size + image_size - 1 downto 0) of std_logic_vector(datatype_size - 1 downto 0);
    type ibuf_mem is array (channels - 1 downto 0) of fifo_mem;

    signal s_ibuf_mem: ibuf_mem;
begin

    data_proc: process(all)
    begin

        -- Shift the FIFO buffer
        if rising_edge(i_clk) then
            if (i_write_enable = '1') then
                g_ibuf_channels: for channel_num in 0 to channels - 1 loop
                    g_ibuf_shift: for fifo_index in (kernel_size - 1) * image_size + kernel_size - 1 downto 1 loop
                        s_ibuf_mem(channel_num)(fifo_index) <= s_ibuf_mem(channel_num)(fifo_index - 1);
                    end loop g_ibuf_shift;   
                end loop g_ibuf_channels;
            end if;
        end if;

        -- Route data from Input buffer to RD buffers
        g_ibuf_channel_route: for channel_num in 0 to channels - 1 loop -- For every channel
            g_ibuf_kernel_route: for kernel_num in 0 to kernel_size - 2 loop
                g_ibuf_kernel_idx: for kernel_idx in 0 to kernel_size - 1 loop
                -- o_data(channel_num)(kernel_size*kernel_num - 1 downto kernel_num) <= s_ibuf_mem(channel_num)(kernel_num downto 0);
                end loop g_ibuf_kernel_idx;
            end loop g_ibuf_kernel_route;

            g_ibuf_rest_kernel: for kernel_num in 0 to kernel_size - 1 loop
                o_data(channel_num)(datatype_size*kernel_size**2 - 1 downto datatype_size*kernel_size**2 - 1) <= s_ibuf_mem(channel_num)(kernel_num);
            end loop g_ibuf_rest_kernel;
        end loop g_ibuf_channel_route;

    end process data_proc;

end behavioral;