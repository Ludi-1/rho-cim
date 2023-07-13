-- FC(784) - FC(1500) - FC(1000) - FC(500) - FC(10)
-- 784 inputs into 1500 neurons
-- ceil(784/512) * ceil(1500/512) = 2*3 = 6 tiles

library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use std.env.stop;
use work.cnn_pkg.all;
use ieee.numeric_std.all;

entity cnn_ibuf_tb is
end cnn_ibuf_tb;

architecture behavioural of cnn_ibuf_tb is

    constant clk_period: time := 2 ns;
    constant kernel_size: integer := 3; -- 5x5 kernel
    constant datatype_size: integer := 8;
    constant image_size: integer := 28; -- mnist 28x28 image

    component cnn_ibuf
        generic(
            kernel_size: integer := 3; -- 5x5 kernel
            datatype_size: integer := 8;
            image_size: integer := 28 -- mnist 28x28 image
        );
        port (
            i_clk : in std_logic;
            i_write_enable : in std_logic;
            
            i_data : in std_logic_vector(datatype_size - 1 downto 0);
            o_data : out data_array(kernel_size**2 - 1 downto 0)(datatype_size - 1 downto 0)
        );
    end component;

    signal i_clk: std_logic := '1';
    signal i_write_enable: std_logic;
    signal i_data: std_logic_vector(datatype_size - 1 downto 0);
    signal o_ibuf_data: data_array(kernel_size**2 - 1 downto 0)(datatype_size - 1 downto 0);

begin

    dut: cnn_ibuf port map (
        i_clk => i_clk,
        i_write_enable => i_write_enable,
        i_data => i_data,
        o_data => o_ibuf_data
    );

    i_clk <= NOT i_clk after clk_period/2;

    i_write_enable <= '1' after clk_period;
    i_data <= x"AB";

    stop_process: process
    begin
        wait for 1000 ns;
        report "Calling 'finish'";
        stop;
        wait;
    end process;

end behavioural;