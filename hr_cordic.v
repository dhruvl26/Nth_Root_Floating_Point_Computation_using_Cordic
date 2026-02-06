`timescale 1ns / 1ps

module hr_cordic(
    input  wire clk,
    input  wire signed [8:0]  E_in,
    input  wire signed [29:0] z_in,
    output reg  signed [29:0] x_out,
    output reg  signed [29:0] y_out,
    output reg  signed [8:0]  E_out
);

    localparam integer STAGES = 24;

    reg signed [29:0] x [0:STAGES];
    reg signed [29:0] y [0:STAGES];
    reg signed [29:0] z [0:STAGES];
    
    reg signed [8:0]  E [0:STAGES];

    wire [4:0] K [0:STAGES-1];
    assign K[0]  = 1;
    assign K[1]  = 2;
    assign K[2]  = 3;
    assign K[3]  = 4;
    assign K[4]  = 4;   
    assign K[5]  = 5;
    assign K[6]  = 6;
    assign K[7]  = 7;
    assign K[8]  = 8;
    assign K[9]  = 9;
    assign K[10] = 10;
    assign K[11] = 11;
    assign K[12] = 12;
    assign K[13] = 13;
    assign K[14] = 13; 
    assign K[15] = 14;
    assign K[16] = 15;
    assign K[17] = 16;
    assign K[18] = 5'd17; 
    assign K[19] = 5'd18;
    assign K[20] = 5'd19; 
    assign K[21] = 5'd20; 
    assign K[22] = 5'd21; 
    assign K[23] = 5'd22; 
//    assign K[24] = 5'd23;
//    assign K[25] = 5'd24;
//    assign K[26] = 5'd25;

    wire signed [29:0] ATANH [0:24];
   
    assign ATANH[0]  = 30'h06570069;
    assign ATANH[1]  = 30'h02f2a71c;
    assign ATANH[2]  = 30'h01734592;
    assign ATANH[3]  = 30'h00b8e7ee;
    assign ATANH[4]  = 30'h005c5cd0;
    assign ATANH[5]  = 30'h002e2b85;
    assign ATANH[6]  = 30'h00171566;
    assign ATANH[7]  = 30'h000b8aa8;
    assign ATANH[8]  = 30'h0005c552;
    assign ATANH[9]  = 30'h0002e2a9;
    assign ATANH[10] = 30'h00017154;
    assign ATANH[11] = 30'h0000b8aa;
    assign ATANH[12] = 30'h00005c55;
    assign ATANH[13] = 30'h00002e2b; 
    assign ATANH[14] = 30'h00001715;
    assign ATANH[15] = 30'h00000b8b;
    assign ATANH[16] = 30'h000005c5;
    assign ATANH[17] = 30'h000002e3;
    assign ATANH[18] = 30'h00000171;
    assign ATANH[19] = 30'h000000b9;
    assign ATANH[20] = 30'h0000005c;
    assign ATANH[21] = 30'h0000002e;
//    assign ATANH[22] = 30'h00000017;
//    assign ATANH[23] = 30'h0000000c;
//    assign ATANH[24] = 30'h00000006;

    integer i;

    always @(posedge clk) begin
            x[0] <= 30'h09a8f439;
            y[0] <= 30'd0;
            z[0] <= z_in;
            E[0] <= E_in;
    end

    genvar g;
    generate
        for (g=0; g<STAGES; g=g+1) begin : HV_STAGE
            always @(posedge clk) begin
                
                if (z[g] <= 0) begin
                    x[g+1] <= x[g] - (y[g] >>> K[g]);
                    y[g+1] <= y[g] - (x[g] >>> K[g]);
                    z[g+1] <= z[g] + ATANH[K[g]-1];
                    E[g+1] <= E[g];
                end else begin
                    x[g+1] <= x[g] + (y[g] >>> K[g]);
                    y[g+1] <= y[g] + (x[g] >>> K[g]);
                    z[g+1] <= z[g] - ATANH[K[g]-1];
                    E[g+1] <= E[g];
                end
                end
                
            end
    endgenerate
    
    always @(posedge clk) begin
        x_out <= x[STAGES];
        y_out <= y[STAGES]; 
        E_out <= E[STAGES];
    end

endmodule
