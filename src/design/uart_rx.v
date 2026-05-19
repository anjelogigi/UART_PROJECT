`timescale 1ns / 1ns
`include "inc.h"

module u_rec #(
    parameter width = `WORD_LEN )(
    input  wire sys_rst,          
    input  wire uart_clk,
    input  wire uart_rec_data_h,
    output reg rec_busy,
    output reg rec_ready,
    output reg [width-1:0] rec_data_h );
    localparam idle  = 2'd0;
    localparam start = 2'd1;
    localparam data  = 2'd2;
    localparam stop  = 2'd3;
    reg [1:0] c_state, n_state;
    reg [3:0] count;
    reg [$clog2(width):0] index;

    reg rx1, rx2;

    always @(posedge uart_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            rx1 <= 1'b1;
            rx2 <= 1'b1;
        end
        else begin
            rx1 <= uart_rec_data_h;
            rx2 <= rx1;
        end
    end

    always @(posedge uart_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            c_state <= idle;
            count <= 0;
            index <= 0;
            rec_data_h <= 0;
            rec_ready <= 1'b0;
            rec_busy <= 1'b0;
        end
        else begin
            c_state <= n_state;

            if (c_state != n_state) begin
                count <= 0;
            end
            else begin
                count <= count + 1'b1;
            end

            if (c_state == idle) begin
                index <= 0;
            end
            else if (c_state == data && count == 15) begin
                index <= index + 1'b1;
            end

            if (c_state == data && count == 15) begin
                rec_data_h <= {rx2, rec_data_h[width-1:1]};
            end

            if (c_state == stop && count == 15) begin
                if (rx2 != 1'b1)
                    rec_data_h <= 0;
            end

            rec_ready <= (c_state == stop && count == 15 && rx2 == 1'b1);
            rec_busy <= (n_state != idle);
        end
    end

    always @(*) begin
        n_state = c_state;

        case (c_state)

            idle: begin
                if (rx2 == 1'b0)
                    n_state = start;
                else
                    n_state = idle;
            end

            start: begin
                if (count == 7) begin
                    if (rx2 == 1'b0)
                        n_state = data;
                    else
                        n_state = idle;
                end
                else begin
                    n_state = start;
                end
            end

            data: begin
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
                if (count == 15)
                    n_state = idle;
                else
                    n_state = stop;
            end

            default: begin
                n_state = idle;
            end

        endcase
    end

endmodule
