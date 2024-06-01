"""
HDL template for top-level module
"""

TEMPLATE = """module top_%LAYER_NAME% #(
%PARAMETERS%
) (
%PORTS%
);

%SIGNALS%

%MODULES

endmodule"""