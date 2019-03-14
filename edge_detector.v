module edge_detector(

	input clk,
	input i_rst,
	input i_sw,
	output reg o_enable
		
);	
    reg prev;

	always @(posedge clk) begin
		if (i_rst) begin
			
			o_enable <= 0;
			prev <= i_sw;
			
		end
		else 
		if( prev == 1'b0 && i_sw == 1'b1) begin		
			o_enable <= 1'b1;
			prev <= i_sw;
		end
		else begin
			o_enable <= 1'b0;
			prev <= i_sw;
		end
	end
	
endmodule