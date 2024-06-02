"""
HDL template for top-level module
"""

TEMPLATE = """module top_%TOP_NAME% #(
%PARAMETERS%
) (
%PORTS%
);

%SIGNALS%

%MODULES%

endmodule"""