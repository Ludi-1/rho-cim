library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_package.all;

entity cnn_1 is
    generic(
        crossbar_size: integer := 512;

        -- LAYER 1: CONV 5x5 kernel size, 5 output? channels
        l1_input_channels: integer := 1; -- grayscale
        l1_output_channels: integer := 5; -- 5 output channels
        l1_kernel_size: integer := 5; -- 5x5 conv
        l1_image_size: integer := 28; -- 28x28 MNIST
        l1_datatype_size: integer := 8; -- datatype size l1
        l1_obuf_datatype_size: integer := 25; -- 2d + log2(R)
        l1_func_datatype_size: integer := 1; -- BNN

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

        -- LAYER 4: FC layer, 10 neurons
        l4_inputs: integer := 720; -- Max-pooled image size
        l4_neurons: integer := 10; -- Amount of neurons in FC layer
        l4_datatype_size: integer := 1; -- datatype size of input
        l4_obuf_datatype_size: integer := 10; -- if d>1: 2d + log2(R), else: d+log2(R)
        l4_func_datatype_size: integer := 8 -- int8 output
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
end cnn_1;