library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_package.all;

entity cnn_1 is
    generic(
        crossbar_size: integer := 512;
        addr_rd_size: integer := integer(ceil(log2(real(crossbar_size))));

        -- LAYER 1: CONV 5x5 kernel size, 5 output? channels
        l1_input_channels: integer := 1; -- grayscale
        l1_output_channels: integer := 5; -- 5 output channels
        l1_kernel_size: integer := 5; -- 5x5 conv
        l1_image_size: integer := 28; -- 28x28 MNIST
        l1_datatype_size: integer := 8; -- datatype size l1
        l1_obuf_datatype_size: integer := 25; -- 2d + log2(R)
        l1_func_datatype_size: integer := 1; -- BNN
        l1_obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(l1_datatype_size))); -- Amount of entries output buffer
        l1_addr_out_buf_size: integer := integer(ceil(log2(real(l1_obuf_addr_max)))); -- Addr size output buffer
        l1_row_split_tiles: integer := integer(ceil(real(l1_kernel_size**2*l1_input_channels)/real(crossbar_size)));
        l1_col_split_tiles: integer := integer(ceil(real(l1_output_channels)*real(l1_datatype_size)/real(crossbar_size)));
        l1_n_tiles: integer := integer(real(l1_row_split_tiles*l1_col_split_tiles));

        -- LAYER 2: POOL 2x2 kernel size
        l2_channels: integer := 5;
        l2_kernel_size: integer := 2; -- 2x2 kernel size of pooling
        l2_image_size: integer := 27; -- maxpooled img size: img_size-kernel_size+1= 28-2+1= 27
        l2_datatype_size: integer := 1; -- datatype size input

        -- LAYER 3: (P2)FC layer, 720 neurons
        l3_input_channels: integer := 5; -- Amount of input channels: Should be equal to the output channels of prev. layer
        l3_image_size: integer := 27; -- Max-pooled image size
        l3_neurons: integer := 720; -- Amount of neurons in FC layer
        l3_datatype_size: integer := 1; -- datatype size of input
        l3_obuf_datatype_size: integer := 10; -- for d=1: d+log2(R)
        l3_func_datatype_size: integer := 1;
        l3_obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(l3_datatype_size))); -- Amount of entries output buffer
        l3_addr_out_buf_size: integer := integer(ceil(log2(real(l3_obuf_addr_max)))); -- Addr size output buffer
        l3_row_split_tiles: integer := integer(ceil(real(l3_image_size**2 * l3_input_channels)/real(crossbar_size)));
        l3_col_split_tiles: integer := integer(ceil(real(l3_neurons)*real(l3_datatype_size)/real(crossbar_size)));
        l3_n_tiles: integer := integer(real(l3_row_split_tiles*l3_col_split_tiles));

        -- LAYER 4: FC layer, 70 neurons
        l4_inputs: integer := 720;
        l4_neurons: integer := 70; -- Amount of neurons in FC layer
        l4_datatype_size: integer := 1; -- datatype size of input
        l4_obuf_datatype_size: integer := 10; -- if d>1: 2d + log2(R), else: d+log2(R)
        l4_func_datatype_size: integer := 1;
        l4_obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(l4_datatype_size))); -- Amount of entries output buffer
        l4_addr_out_buf_size: integer := integer(ceil(log2(real(l4_obuf_addr_max)))); -- Addr size output buffer
        l4_row_split_tiles: integer := integer(ceil(real(l4_inputs)/real(crossbar_size)));
        l4_col_split_tiles: integer := integer(ceil(real(l4_neurons)*real(l4_datatype_size)/real(crossbar_size)));
        l4_n_tiles: integer := integer(real(l4_row_split_tiles*l4_col_split_tiles));
 
        -- LAYER 5: FC layer, 10 neurons
        l5_inputs: integer := 70;
        l5_neurons: integer := 10; -- Amount of neurons in FC layer
        l5_datatype_size: integer := 1; -- datatype size of input
        l5_obuf_datatype_size: integer := 10; -- if d>1: 2d + log2(R), else: d+log2(R)
        l5_func_datatype_size: integer := 8; -- int8 output
        l5_obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(l5_datatype_size))); -- Amount of entries output buffer
        l5_addr_out_buf_size: integer := integer(ceil(log2(real(l5_obuf_addr_max)))); -- Addr size output buffer
        l5_row_split_tiles: integer := integer(ceil(real(l5_inputs)/real(crossbar_size)));
        l5_col_split_tiles: integer := integer(ceil(real(l5_neurons)*real(l5_datatype_size)/real(crossbar_size)));
        l5_n_tiles: integer := integer(real(l5_row_split_tiles*l5_col_split_tiles))
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic_vector(l1_input_channels - 1 downto 0);
        o_ibuf_full: out std_logic_vector(l1_input_channels - 1 downto 0);
        i_ibuf_data: in std_logic_vector(l1_datatype_size * l1_input_channels - 1 downto 0); -- Input data for input buffers
        i_start: in std_logic; -- Start consuming input buffer
        o_busy: out std_logic; -- busy
        o_data: out std_logic_vector(l5_func_datatype_size - 1 downto 0); -- Output data
        o_start: out std_logic;
        o_we: out std_logic;
        i_next_layer_busy: in std_logic;
        i_next_ibuf_full: in std_logic;

        o_l1_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0);
        o_l1_tile_rd_data: out std_logic_vector(l1_datatype_size - 1 downto 0);
        i_l1_tiles_done: in std_logic_vector(l1_n_tiles - 1 downto 0);
        i_l1_tile_data: in std_logic_vector(l1_obuf_datatype_size * l1_n_tiles - 1 downto 0);
        o_l1_tile_addr: out std_logic_vector(l1_addr_out_buf_size - 1 downto 0);
        o_l1_rd_write_enable: out std_logic_vector(l1_n_tiles - 1 downto 0);
        o_l1_tile_start: out std_logic_vector(l1_n_tiles - 1 downto 0);

        o_l3_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0);
        o_l3_tile_rd_data: out std_logic_vector(l3_datatype_size - 1 downto 0);
        i_l3_tiles_done: in std_logic_vector(l3_n_tiles - 1 downto 0);
        i_l3_tile_data: in std_logic_vector(l3_obuf_datatype_size * l3_n_tiles - 1 downto 0);
        o_l3_tile_addr: out std_logic_vector(l3_addr_out_buf_size - 1 downto 0);
        o_l3_rd_write_enable: out std_logic_vector(l3_n_tiles - 1 downto 0);
        o_l3_tile_start: out std_logic_vector(l3_n_tiles - 1 downto 0);

        o_l4_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0);
        o_l4_tile_rd_data: out std_logic_vector(l4_datatype_size - 1 downto 0);
        i_l4_tiles_done: in std_logic_vector(l4_n_tiles - 1 downto 0);
        i_l4_tile_data: in std_logic_vector(l4_obuf_datatype_size * l4_n_tiles - 1 downto 0);
        o_l4_tile_addr: out std_logic_vector(l4_addr_out_buf_size - 1 downto 0);
        o_l4_rd_write_enable: out std_logic_vector(l4_n_tiles - 1 downto 0);
        o_l4_tile_start: out std_logic_vector(l4_n_tiles - 1 downto 0);

        o_l5_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0);
        o_l5_tile_rd_data: out std_logic_vector(l5_datatype_size - 1 downto 0);
        i_l5_tiles_done: in std_logic_vector(l5_n_tiles - 1 downto 0);
        i_l5_tile_data: in std_logic_vector(l5_obuf_datatype_size * l5_n_tiles - 1 downto 0);
        o_l5_tile_addr: out std_logic_vector(l5_addr_out_buf_size - 1 downto 0);
        o_l5_rd_write_enable: out std_logic_vector(l5_n_tiles - 1 downto 0);
        o_l5_tile_start: out std_logic_vector(l5_n_tiles - 1 downto 0)        
    );
end cnn_1;

architecture behavioral of cnn_1 is

component cnn_layer is
    generic(
        input_channels: integer := 5;
        output_channels: integer := 65; -- num of output channels

        kernel_size: integer := 3; -- 5x5 kernel
        image_size: integer := 28; -- mnist 28x28 image
        datatype_size: integer := 8; -- datatype size input
        crossbar_size: integer := 512; -- RxR Crossbar size
        obuf_datatype_size: integer := 25; -- 2d + log2(R) = 2*8+9
        func_datatype_size: integer := 1;
        row_split_tiles: integer := integer(ceil(real(kernel_size**2*input_channels)/real(crossbar_size)));
        col_split_tiles: integer := integer(ceil(real(output_channels)*real(datatype_size)/real(crossbar_size)));
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles));
        obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(datatype_size))); -- Amount of entries output buffer
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))); -- Addr size output buffer
        addr_rd_size: integer := integer(ceil(log2(real(crossbar_size)))) -- Bit length of rd buf addr
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic_vector(input_channels - 1 downto 0);
        o_ibuf_full: out std_logic_vector(input_channels - 1 downto 0);
        i_ibuf_data: in std_logic_vector(datatype_size * input_channels - 1 downto 0); -- Input data for input buffers

        o_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0); -- Addr for RD buffer
        o_tile_rd_data: out std_logic_vector(datatype_size - 1 downto 0); -- Data to RD buffer
        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done/Ready signal from tiles
        i_tile_data: in std_logic_vector(obuf_datatype_size * n_tiles - 1 downto 0); -- Data from output buffer tiles
        o_tile_addr: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Address to output buffer
        o_rd_write_enable: out std_logic_vector(n_tiles - 1 downto 0);
        o_tile_start: out std_logic_vector(n_tiles - 1 downto 0);

        i_next_ibuf_full: in std_logic_vector(output_channels - 1 downto 0); -- Next layer FIFO ibuf full
        i_start: in std_logic; -- Start consuming input buffer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_layer_busy: out std_logic; -- This Layer busy
        o_write_enable : out std_logic_vector(output_channels - 1 downto 0); -- Write data to next layer
        o_data: out std_logic_vector(func_datatype_size - 1 downto 0); -- Data to the next layer
        o_start: out std_logic
    );
end component;

component pooling_layer is
    generic(
        channels: integer := 5;
        kernel_size: integer := 2; -- 5x5 kernel size of pooling
        image_size: integer := 27; -- 28x28 image
        datatype_size: integer := 1 -- datatype size input
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;
        i_write_enable: in std_logic_vector(channels - 1 downto 0);
        o_ibuf_full: out std_logic_vector(channels - 1 downto 0);
        i_ibuf_data: in std_logic_vector(datatype_size * channels - 1 downto 0); -- Input data for input buffers
        i_next_ibuf_full: in std_logic_vector(channels - 1 downto 0); -- Next layer FIFO ibuf full
        i_start: in std_logic; -- Start consuming input buffer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_layer_busy: out std_logic; -- This Layer busy
        o_write_enable: out std_logic_vector(channels - 1 downto 0); -- Write data to next layer
        o_data: out std_logic_vector(datatype_size * channels - 1 downto 0); -- Data to the next layer
        o_start: out std_logic
    );
end component;

component p2fc_layer is
    generic(
        input_channels: integer := 5; -- Amount of input channels: Should be equal to the output channels of prev. layer
        image_size: integer := 28; -- Max-pooled output image size
        neurons: integer := 65; -- Amount of neurons in FC layer
        datatype_size: integer := 8; -- datatype size of input
        crossbar_size: integer := 512; -- RxR Crossbar size
        obuf_datatype_size: integer := 25; -- if d>1: 2d + log2(R), else: d+log2(R)
        func_datatype_size: integer := 1;
        row_split_tiles: integer := integer(ceil(real(image_size**2 * input_channels)/real(crossbar_size)));
        col_split_tiles: integer := integer(ceil(real(neurons)*real(datatype_size)/real(crossbar_size)));
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles));
        obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(datatype_size))); -- Amount of entries output buffer
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))); -- Addr size output buffer
        addr_rd_size: integer := integer(ceil(log2(real(crossbar_size)))) -- Bit length of rd buf addr
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic_vector(input_channels - 1 downto 0);
        o_ibuf_full: out std_logic_vector(input_channels - 1 downto 0);
        i_ibuf_data: in std_logic_vector(datatype_size * input_channels - 1 downto 0); -- Input data for input buffers

        o_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0); -- Addr for RD buffer
        o_tile_rd_data: out std_logic_vector(datatype_size - 1 downto 0); -- Data to RD buffer
        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done/Ready signal from tiles
        i_tile_data: in std_logic_vector(obuf_datatype_size * n_tiles - 1 downto 0); -- Data from output buffer tiles
        o_tile_addr: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Address to output buffer
        o_rd_write_enable: out std_logic_vector(n_tiles - 1 downto 0);
        o_tile_start: out std_logic_vector(n_tiles - 1 downto 0);

        i_next_ibuf_full: in std_logic; -- Next layer FIFO ibuf full
        i_start: in std_logic; -- Start consuming input buffer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_layer_busy: out std_logic; -- This Layer busy
        o_write_enable : out std_logic; -- Write data to next layer
        o_data: out std_logic_vector(func_datatype_size - 1 downto 0); -- Data to the next layer
        o_start: out std_logic
    );
end component;

component fc_layer is
    generic(
        inputs: integer := 720; -- Max-pooled image size
        neurons: integer := 1000; -- Amount of neurons in FC layer
        datatype_size: integer := 1; -- datatype size of input
        crossbar_size: integer := 512; -- RxR Crossbar size
        obuf_datatype_size: integer := 10; -- if d>1: 2d + log2(R), else: d+log2(R)
        func_datatype_size: integer := 1;
        row_split_tiles: integer := integer(ceil(real(inputs)/real(crossbar_size)));
        col_split_tiles: integer := integer(ceil(real(neurons)*real(datatype_size)/real(crossbar_size)));
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles));
        obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(datatype_size))); -- Amount of entries output buffer
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))); -- Addr size output buffer
        addr_rd_size: integer := integer(ceil(log2(real(crossbar_size)))) -- Bit length of rd buf addr
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic;
        o_ibuf_full: out std_logic;
        i_ibuf_data: in std_logic_vector(datatype_size - 1 downto 0); -- Input data for input buffers

        o_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0); -- Addr for RD buffer
        o_tile_rd_data: out std_logic_vector(datatype_size - 1 downto 0); -- Data to RD buffer
        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done/Ready signal from tiles
        i_tile_data: in std_logic_vector(obuf_datatype_size * n_tiles - 1 downto 0); -- Data from output buffer tiles
        o_tile_addr: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Address to output buffer
        o_rd_write_enable: out std_logic_vector(n_tiles - 1 downto 0);
        o_tile_start: out std_logic_vector(n_tiles - 1 downto 0);

        i_next_ibuf_full: in std_logic; -- Next layer FIFO ibuf full
        i_start: in std_logic; -- Start consuming input buffer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_layer_busy: out std_logic; -- This Layer busy
        o_write_enable : out std_logic; -- Write data to next layer
        o_data: out std_logic_vector(func_datatype_size - 1 downto 0); -- Data to the next layer
        o_start: out std_logic
    );
end component;

    signal s_l2_ibuf_full, s_l2_we: std_logic_vector(l2_channels - 1 downto 0);
    signal s_l2_busy, s_l2_start: std_logic;
    signal s_l2_data: std_logic_vector(l2_datatype_size * l2_channels - 1 downto 0);
    signal s_l2_bc_data: std_logic_vector(l2_datatype_size - 1 downto 0);

    signal s_l3_ibuf_full, s_l3_we: std_logic_vector(l3_input_channels - 1 downto 0);
    signal s_l3_busy, s_l3_start: std_logic;
    signal s_l3_data: std_logic_vector(l3_datatype_size * l3_input_channels - 1 downto 0);

    signal s_l4_ibuf_full, s_l4_we: std_logic;
    signal s_l4_busy, s_l4_start: std_logic;
    signal s_l4_data: std_logic_vector(l4_func_datatype_size - 1 downto 0);

    signal s_l5_ibuf_full, s_l5_we: std_logic;
    signal s_l5_busy, s_l5_start: std_logic;

begin

    process(all)
    begin
        for i in 0 to l2_channels - 1 loop
            s_l2_data(l2_datatype_size * (i+1) - 1 downto l2_datatype_size * i) <= s_l2_bc_data;
        end loop;
    end process;

    -- 5x5,5
    l1_layer: cnn_layer
        generic map(
        input_channels => l1_input_channels,
        output_channels => l1_output_channels,
        kernel_size => l1_kernel_size,
        image_size => l1_image_size,
        datatype_size => l1_datatype_size,
        crossbar_size => crossbar_size,
        obuf_datatype_size => l1_obuf_datatype_size,
        func_datatype_size => l1_func_datatype_size
        )
        port map(
            i_clk => i_clk,
            i_rst => i_rst,

            i_write_enable => i_write_enable,
            o_ibuf_full => o_ibuf_full,
            i_ibuf_data => i_ibuf_data,

            o_tile_rd_addr => o_l1_tile_rd_addr,
            o_tile_rd_data => o_l1_tile_rd_data,
            i_tiles_done => i_l1_tiles_done,
            i_tile_data => i_l1_tile_data,
            o_tile_addr => o_l1_tile_addr,
            o_rd_write_enable => o_l1_rd_write_enable,
            o_tile_start => o_l1_tile_start,

            i_next_ibuf_full => s_l2_ibuf_full,
            i_start => i_start,
            i_next_layer_busy => s_l2_busy,
            o_layer_busy => o_busy,
            o_write_enable => s_l2_we,
            o_data => s_l2_bc_data,
            o_start => s_l2_start            
        );

    -- 2x2 pool
    l2: pooling_layer
        generic map(
        channels => l2_channels,
        kernel_size => l2_kernel_size,
        image_size => l2_image_size,
        datatype_size => l2_datatype_size
        )
        port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_write_enable => s_l2_we,
        o_ibuf_full => s_l2_ibuf_full,
        i_ibuf_data => s_l2_data,
        i_next_ibuf_full => s_l3_ibuf_full,
        i_start => s_l2_start,
        i_next_layer_busy => s_l3_busy,
        o_layer_busy => s_l2_busy,
        o_write_enable => s_l3_we,
        o_data => s_l3_data,
        o_start => s_l3_start            
        );

    -- p2fc 720
    l3: p2fc_layer
        generic map(
        input_channels => l3_input_channels,
        image_size => l3_image_size,
        neurons => l3_neurons,
        datatype_size => l3_datatype_size,
        crossbar_size => crossbar_size ,
        obuf_datatype_size => l3_obuf_datatype_size,
        func_datatype_size => l3_func_datatype_size
        )
        port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_write_enable => s_l3_we,
        o_ibuf_full => s_l3_ibuf_full,
        i_ibuf_data => s_l3_data,

        o_tile_rd_addr => o_l3_tile_rd_addr,
        o_tile_rd_data => o_l3_tile_rd_data,
        i_tiles_done => i_l3_tiles_done,
        i_tile_data => i_l3_tile_data,
        o_tile_addr => o_l3_tile_addr,
        o_rd_write_enable => o_l3_rd_write_enable,
        o_tile_start => o_l3_tile_start,

        i_next_ibuf_full => s_l4_ibuf_full,
        i_start => s_l3_start,
        i_next_layer_busy => s_l4_busy,
        o_layer_busy => s_l3_busy,
        o_write_enable => s_l4_we,
        o_data => s_l4_data,
        o_start => s_l4_start
        );

    -- fc 70
    l4: fc_layer
        generic map(
        inputs => l4_inputs,
        neurons => l4_neurons,
        datatype_size => l4_datatype_size,
        crossbar_size => crossbar_size,
        obuf_datatype_size => l4_obuf_datatype_size,
        func_datatype_size => l4_func_datatype_size
        )
        port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_write_enable => s_l4_we,
        o_ibuf_full => s_l4_ibuf_full,
        i_ibuf_data => s_l4_data,

        o_tile_rd_addr => o_l4_tile_rd_addr,
        o_tile_rd_data => o_l4_tile_rd_data,
        i_tiles_done => i_l4_tiles_done,
        i_tile_data => i_l4_tile_data,
        o_tile_addr => o_l4_tile_addr,
        o_rd_write_enable => o_l4_rd_write_enable,
        o_tile_start => o_l4_tile_start,

        i_next_ibuf_full => s_l5_ibuf_full,
        i_start => s_l4_start,
        i_next_layer_busy => s_l5_busy,
        o_layer_busy => s_l4_busy,
        o_write_enable => s_l5_we,
        o_data => s_l4_data,
        o_start => s_l5_start
        );

    -- fc 10
    l5: fc_layer
        generic map(
        inputs => l5_inputs,
        neurons => l5_neurons,
        datatype_size => l5_datatype_size,
        crossbar_size => crossbar_size,
        obuf_datatype_size => l5_obuf_datatype_size,
        func_datatype_size => l5_func_datatype_size
        )
        port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_write_enable => s_l5_we,
        o_ibuf_full => s_l5_ibuf_full,
        i_ibuf_data => s_l4_data,

        o_tile_rd_addr => o_l5_tile_rd_addr,
        o_tile_rd_data => o_l5_tile_rd_data,
        i_tiles_done => i_l5_tiles_done,
        i_tile_data => i_l5_tile_data,
        o_tile_addr => o_l5_tile_addr,
        o_rd_write_enable => o_l5_rd_write_enable,
        o_tile_start => o_l5_tile_start,

        i_next_ibuf_full => i_next_ibuf_full,
        i_start => s_l5_start,
        i_next_layer_busy => i_next_layer_busy,
        o_layer_busy => s_l5_busy,
        o_write_enable => o_we,
        o_data => o_data,
        o_start => o_start
        );

end behavioral;