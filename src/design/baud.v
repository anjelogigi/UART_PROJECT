`timescale 1ns / 1ns
`include "inc.h"

module baud #(parameter freq  = `XTAL_CLK, parameter baudrate = `BAUD)(
    input  wire sys_clk,
    input  wire sys_rst,     
    output reg  uart_clk );

    localparam integer END_COUNT = freq / (baudrate * 16 * 2);

    reg [$clog2(END_COUNT)-1:0] count;

    always @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            uart_clk <= 1'b0;
            count    <= 0;
        end
        else begin
            if (count == END_COUNT - 1) begin
                uart_clk <= ~uart_clk;
                count <= 0;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule
