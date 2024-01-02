module iverilog_dump();
initial begin
    $dumpfile("ctrl.fst");
    $dumpvars(0, ctrl);
end
endmodule
