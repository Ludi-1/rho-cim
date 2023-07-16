library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_pkg.all;

entity cnn_layer is
    generic(
        channels: integer := 2; -- Input channels
        kernel_size: integer := 3; -- 5x5 kernel
        datatype_size: integer := 8;
        image_size: integer := 28 -- mnist 28x28 image
    );
    port (
        i_clk : in std_logic;
        i_write_enable : in std_logic;

        i_layer_data : in std_logic_vector(datatype_size * channels - 1 downto 0);
        -- o_data : out data_array(kernel_size**2 - 1 downto 0)(datatype_size - 1 downto 0)
        o_tile_data: out std_logic_vector(datatype_size * kernel_size**2 * channels - 1 downto 0)
        o_next_layer_data: out std_logic_vector(datatype_size * kernel_size**2 - 1 downto 0)
    );
end cnn_layer;

architecture behavioral of layer is
    type fifo_mem is array((kernel_size - 1) * image_size + kernel_size - 1 downto 0) of std_logic_vector(datatype_size - 1 downto 0);
 
    signal s_data: data_array(kernel_size**2 - 1 downto 0)(datatype_size - 1 downto 0);
    signal s_ibuf_mem: fifo_mem;
begin

    data_proc: process(all)
    begin

        -- Shift the FIFO buffer
        if rising_edge(i_clk) then
            if (i_write_enable = '1') then
                s_ibuf_mem(0) <= i_data;
                g_ibuf_shift: for fifo_index in (kernel_size - 1) * image_size + kernel_size - 1 downto 1 loop
                        s_ibuf_mem(fifo_index) <= s_ibuf_mem(fifo_index - 1);
                end loop g_ibuf_shift;   
            end if;
        end if;

        -- Route data from Input buffer to RD buffers
        g_ibuf_kernel_route: for kernel_num in 0 to kernel_size - 2 loop
            g_ibuf_kernel_idx: for kernel_idx in 0 to kernel_size - 1 loop
                s_data(kernel_num*kernel_size + kernel_idx) <= s_ibuf_mem(kernel_num*image_size + kernel_idx);
            end loop g_ibuf_kernel_idx;
        end loop g_ibuf_kernel_route;

        g_ibuf_rest_kernel: for kernel_num in 0 to kernel_size - 1 loop
            s_data(kernel_size**2 - 1 - kernel_num) <= s_ibuf_mem((kernel_size - 1) * image_size + kernel_size - 1 - kernel_num);
        end loop g_ibuf_rest_kernel;

        g_output_data: for kernel_num in 0 to kernel_size**2 - 1 loop
            o_data((kernel_num + 1) * datatype_size - 1 downto kernel_num * datatype_size) <= s_data(kernel_num);
        end loop g_output_data;

    end process data_proc;

end behavioral;