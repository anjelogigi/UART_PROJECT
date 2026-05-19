`timescale 1ns / 1ns
`include "inc.h"

module uart #(
    parameter freq  = `XTAL_CLK,
    parameter baudr = `BAUD,
    parameter width = `WORD_LEN
)(
    input  wire sys_clk,
    input  wire sys_rst,
    input  wire xmit_h,
    input  wire [width-1:0] xmit_data_h,
    input  wire uart_rec_data_h,

    output wire uart_clk,
    output wire uart_xmit_data_h,
    output wire xmit_done_h,
    output wire [width-1:0] rec_data_h,
    output wire rec_ready,
    output wire rec_busy,
    output wire xmit_active
);

    baud #(
        .freq(freq),
        .baudr(baudr)
    ) b1(
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .uart_clk(uart_clk)
    );

    u_xmit #(
        .width(width)
    ) b2 (
        .uart_clk(uart_clk),
        .sys_rst(sys_rst),
        .xmit_h(xmit_h),
        .xmit_data_h(xmit_data_h),
        .xmit_done_h(xmit_done_h),
        .xmit_active(xmit_active),
        .uart_xmit_data_h(uart_xmit_data_h)
    );

    u_rec #(
        .width(width)
    ) b3 (
        .sys_rst(sys_rst),
        .uart_clk(uart_clk),
        .uart_rec_data_h(uart_rec_data_h),
        .rec_busy(rec_busy),
        .rec_ready(rec_ready),
        .rec_data_h(rec_data_h)
    );

endmodule
