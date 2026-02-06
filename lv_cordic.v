`timescale 1ns / 1ps

module lv_cordic(
    input  wire clk,
    input  wire [7:0]  E_in,
    input  wire signed [35:0]  x_in,
    output reg signed  [35:0]  z_out,
    output reg signed  [8:0]   E_minus
    );

    localparam integer STAGES = 24;

    reg signed [35:0] x [0:STAGES];
    reg signed [35:0] y [0:STAGES];
    reg signed [35:0] z [0:STAGES];   
    
    reg [7:0]  E [0:STAGES];
    
    integer i;
    always @(posedge clk) begin
            x[0] <= x_in;
            y[0] <= 36'h008000000;
            z[0] <= 36'd0; 
            E[0] <= E_in;
    end

    genvar j;
    generate
        for (j = 0; j < STAGES; j = j + 1) begin : LV_STAGE
            always @(posedge clk) begin
               
                if (y[j] <= 0) begin
                    x[j+1] <= x[j];
                    y[j+1] <= y[j] + (x[j] >>> j);
                    z[j+1] <= z[j] - (36'h008000000 >> j);
                    E[j+1] <= E[j];
                end else begin
                    x[j+1] <= x[j];
                    y[j+1] <= y[j] - (x[j] >>> j);
                    z[j+1] <= z[j] + (36'h008000000 >> j);
                    E[j+1] <= E[j];
                end

            end
        end
    endgenerate
    
    always @(posedge clk) begin
            z_out <= z[STAGES];
            E_minus <= ({1'b0,E[STAGES]} - 9'd127);
    end

endmodule
