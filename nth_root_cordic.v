`timescale 1ns / 1ps

module nth_root_cordic (
        input clk,
        input signed [31:0] value,
        input [7:0] N,
        output signed [31:0] root_value
        );
        
        wire        S = value[31];
        wire [7:0]  E = value [30:23];
        wire [24:0] M = {2'b01, value[22:0]};

        wire signed [8:0]  E_minus;
        //assign E_minus = ({1'b0,E} - 9'd127);
        
        wire signed [29:0] z_out_hv;
        
        hv_cordic hv (.clk(clk), 
                      .x_in( {1'b0, (M + 25'h0800000),4'd0}), 
                      .y_in( {1'b0, (M - 25'h0800000),4'd0}), 
                      .z_out(z_out_hv));
                      
        
        wire signed [35:0] z_out_lv;
        
        lv_cordic lv (.clk(clk), 
                      .E_in(E),
                      .x_in({1'b0,N,27'b0}), 
                      .z_out(z_out_lv),
                      .E_minus(E_minus));

        wire signed [44:0] EF_DivN;
        assign EF_DivN = E_minus * z_out_lv; 
        
        wire signed [65:0] LogM_DivN;
        assign LogM_DivN = z_out_hv * z_out_lv;
        
        wire [27:0] EF;
        assign EF = {1'b0,EF_DivN[26:0]}; 
        
        wire signed [8:0] EI;
        assign EI = {EF_DivN[44],EF_DivN[34:27]};
        
        wire [27:0] LogM_N;
        assign LogM_N = {1'b0,LogM_DivN[52:26]};
        
        wire signed [28:0] add;
        assign add  = {1'b0,EF} + {1'b0,LogM_N};
        
        wire signed [29:0] z_in;
        assign z_in = {1'b0,add};
        
        wire signed [29:0] x_out_hr,y_out_hr;
        wire signed [8:0] E_out;
        
        hr_cordic hr (.clk(clk), 
                      .E_in(EI),
                      .z_in( z_in ), 
                      .x_out(x_out_hr), 
                      .y_out(y_out_hr),
                      .E_out(E_out));
                      
        wire signed [30:0] M_root;
        assign M_root = {x_out_hr[29],x_out_hr} + {y_out_hr[29],y_out_hr};
                
        reg [22:0] M_root_reg;
        reg signed [8:0]  EI_reg;
        
        always @(*) begin
            if(M_root[28]) begin
                M_root_reg = M_root[27:5];
                EI_reg     = E_out + 9'sd128;
            end else begin
                M_root_reg = M_root[26:4];
                EI_reg     = E_out + 9'sd127;
            end
        end
                 
        assign root_value = {S,EI_reg[7:0],M_root_reg[22:0]};
endmodule