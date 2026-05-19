`timescale 1ns / 1ns
`include "inc.h"

module u_xmit #(parameter width = `WORD_LEN)(
    input wire uart_clk,
    input wire sys_rst,       
    input wire xmit_h,
    input wire [width-1:0]  xmit_data_h,
    output reg xmit_done_h,
    output reg xmit_active,
    output reg uart_xmit_data_h );

    localparam idle  = 2'd0,start = 2'd1,data  = 2'd2,stop  = 2'd3;

    reg [1:0] c_state, n_state;
    reg [3:0] count;
    reg [$clog2(width):0] index;
    reg [width-1:0] temp_data;
    reg out;

    always @(posedge uart_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            c_state <= idle;
            count <= 0;
            index <= 0;
            temp_data <= 0;
            uart_xmit_data_h <= 1'b1;
            xmit_done_h <= 1'b0;
            xmit_active <= 1'b0;
        end
        else begin
            c_state <= n_state;
            uart_xmit_data_h <= out;

            if (xmit_h && c_state == idle) begin
                temp_data <= xmit_data_h;
            end

            if (c_state == idle) begin
                count <= 0;
            end
            else if (n_state != c_state) begin
                count <= 0;
            end
            else begin
                count <= count + 1'b1;
            end

            if (c_state == idle) begin
                index <= 0;
            end
            else if (c_state == data && count == 15 && n_state == data) begin
                index <= index + 1'b1;
            end

            xmit_done_h <= (c_state == stop && count == 15);
            xmit_active <= (n_state != idle);
        end
    end

    always @(*) begin
        n_state = c_state;
        out = 1'b1;

        case (c_state)

            idle: begin
                out = 1'b1;
                if (xmit_h)
                    n_state = start;
                else
                    n_state = idle;
            end

            start: begin
                out = 1'b0;
                if (count == 15)
                    n_state = data;
                else
                    n_state = start;
            end

            data: begin
                out = temp_data[index];

                if (count == 15) begin
                    if (index == width - 1)
                        n_state = stop;
                    else
                        n_state = data;
                end
                else begin
                    n_state = data;
                end
            end

            stop: begin
                out = 1'b1;
                if (count == 15)
                    n_state = idle;
                else
                    n_state = stop;
            end

            default: begin
                out = 1'b1;
                n_state = idle;
            end
        endcase
    end
endmodule
