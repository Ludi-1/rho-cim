library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_package.all;

entity pooling_layer is
    generic(
        channels: integer := 5;

        kernel_size: integer := 3; -- 5x5 kernel size of pooling
        image_size: integer := 28; -- 28x28 image
        datatype_size: integer := 8 -- datatype size input
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
end pooling_layer;

architecture behavioral of pooling_layer is

component cnn_ibuf is
    generic(
        kernel_size: integer := 3; -- 5x5 kernel
        datatype_size: integer := 8;
        image_size: integer := 28 -- mnist 28x28 image
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic;
        o_ibuf_full: out std_logic;
        i_data: in std_logic_vector(datatype_size - 1 downto 0);
        o_data: out std_logic_vector(datatype_size * kernel_size**2 - 1 downto 0)
    );
end component;

    signal s_layer_busy: std_logic;
    signal s_write_enable: std_logic_vector(channels - 1 downto 0);
    signal s_ibuf_data: data_array(channels - 1 downto 0)(datatype_size*kernel_size**2 - 1 downto 0);

begin

    o_layer_busy <= i_next_layer_busy or s_layer_busy;
    o_write_enable <= s_write_enable;

    process(all) is
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_layer_busy <= '0';
            else
                if i_start = '1' then
                    s_layer_busy <= '1';
                    if s_write_enable = (channels - 1 downto 0 => '1') then
                        s_write_enable <= (others => '0');
                        o_start <= '1';
                    else
                        s_write_enable <= (others => '1');
                        o_start <= '0';
                    end if;
                else
                    o_start <= '0';
                    s_layer_busy <= '0';
                end if;
            end if;
        end if;
    end process;

    g_ibuf: for input_channel in 0 to channels - 1 generate
        ibuf: cnn_ibuf
            generic map(
                kernel_size => kernel_size,
                datatype_size => datatype_size,
                image_size => image_size
            )
            port map(
                i_clk => i_clk,
                i_rst => i_rst,
                o_ibuf_full => o_ibuf_full(input_channel),
                i_write_enable => i_write_enable(input_channel),
                i_data => i_ibuf_data(datatype_size*(input_channel + 1) - 1 downto datatype_size*input_channel),
                o_data => s_ibuf_data(input_channel)
            );
    end generate;

    pooling_proc: process(all) is
        variable v_max_value: data_array(channels - 1 downto 0)(datatype_size - 1 downto 0);
    begin
        for input_channel in 0 to channels - 1 loop

            -- Perform max pooling on ibuf of this layer
            v_max_value(input_channel) := (others => '0');
            for kernel_idx in 0 to kernel_size**2 - 1 loop
                if signed(s_ibuf_data(input_channel)((kernel_idx+1)*datatype_size - 1 downto kernel_idx*datatype_size)) > signed(v_max_value(input_channel)) then
                    v_max_value(input_channel) :=
                        s_ibuf_data(input_channel)((kernel_idx+1)*datatype_size - 1 downto kernel_idx*datatype_size);
                end if;
            end loop;

            -- Route max pooling value to ibuf of next layer
            o_data((input_channel + 1)*datatype_size - 1 downto input_channel*datatype_size)
                <= v_max_value(input_channel);
        end loop;
    end process;

end behavioral;