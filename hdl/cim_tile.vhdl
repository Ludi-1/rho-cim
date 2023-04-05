library ieee;
use ieee.std_logic_1164.all;

entity cim_tile is
    generic(
        max_datatype_size: integer;
        max_address_size: integer
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic

    );
end cim_tile;

architecture behavioural of cim_tile is
begin
end behavioural;