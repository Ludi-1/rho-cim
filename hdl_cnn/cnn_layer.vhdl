library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_pkg.all;

entity cnn_layer is
    generic(
        input_channels: integer := 5;
        output_channels: integer := 10; -- num of output channels

        kernel_size: integer := 3; -- 5x5 kernel
        image_size: integer := 28; -- mnist 28x28 image
        datatype_size: integer := 8; -- datatype size input
        crossbar_size: integer := 512; -- RxR Crossbar size
        obuf_datatype_size: integer := 25; -- 2d + log2(R) = 2*8+9
        func_datatype_size: integer := 1;
        row_split_tiles: integer := integer(ceil(real(input_channels)/real(crossbar_size)));
        col_split_tiles: integer := integer(ceil(real(output_channels)*real(datatype_size)/real(crossbar_size)));
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles));
        obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(datatype_size))); -- Amount of entries output buffer
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))) -- Addr size output buffer
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic_vector(input_channels - 1 downto 0);
        i_data: in std_logic_vector(datatype_size * input_channels - 1 downto 0);
        o_tile_rd_data: in std_logic_vector(datatype_size * kernel_size**2 * input_channels);

        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from tiles
        i_next_layer_busy: in std_logic; -- Next layer busy signal

        o_func_busy: out std_logic; -- Functional unit busy
        o_write_enable : out std_logic_vector(output_channels - 1 downto 0); -- Write data to next layer
        
        i_data : in std_logic_vector(obuf_datatype_size * n_tiles - 1 downto 0); -- Data from output buffer tiles
        o_tile_addr: out std_logic_vector(addr_out_buf_size - 1 downto 0);

        o_data: out std_logic_vector(func_datatype_size - 1 downto 0) -- Data to the next layer
    );
end cnn_layer;

architecture behavioral of cnn_func is

component cnn_ibuf is
    generic(
        kernel_size: integer := 3; -- 5x5 kernel
        datatype_size: integer := 8;
        image_size: integer := 28 -- mnist 28x28 image
    );
    port (
        i_clk : in std_logic;
        i_write_enable : in std_logic;
        
        i_data : in std_logic_vector(datatype_size - 1 downto 0);
        -- o_data : out data_array(kernel_size**2 - 1 downto 0)(datatype_size - 1 downto 0)
        o_data: out std_logic_vector(datatype_size * kernel_size**2 - 1 downto 0)
    );
end component;

begin

    g_ibuf: for input_channel in 0 to input_channels - 1 generate
        ibuf: cnn_ibuf
            generic map(
                kernel_size => kernel_size,
                datatype_size => datatype_size,
                image_size => image_size
            )
            port map(
                i_clk => i_clk,
                i_write_enable => i_write_enable(input_channel),
                i_data => i_data(datatype_size*(input_channel + 1) - 1 downto datatype_size*input_channel),
                o_data => o_tile_rd_data(datatype_size * kernel_size**2 * (input_channel + 1) - 1 downto datatype_size * kernel_size**2 * input_channel)
            );
    end generate;

end behavioral;