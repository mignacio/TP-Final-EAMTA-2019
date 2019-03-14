module top_tx #(parameter NB_COUNT = 3)( 

			input i_reset,
			input [3:0] i_enable,
			input clock,
			output [3:0] o_leds,
			output [12:0] fir_out
			);

reg [NB_COUNT-1:0] count;
wire valid;
wire data_prbs;
//wire [12:0] fir_out;

assign o_leds = i_enable;


always@(posedge clock) begin
		
		if (i_reset) 
			
			count <= {NB_COUNT{1'b0}};

		else 
			if (i_enable[0])
				count <= count + 1;
			else 
				count <= count;
end

assign valid = (count == {NB_COUNT{1'b1}})?1'b1:1'b0;

	PRBS
		u_prbs
		   (.o_data(data_prbs),
			.i_reset(i_reset),
			.i_valid(valid),
			.clock(clock),
			.i_enable(i_enable[1]));
		
	fir_filter
		u_fir( .clk(clock),
			   .i_rst(i_reset),
			   .i_valid(valid),
			   .i_enable(i_enable[2]),
			   .i_prbs(data_prbs),
			   .o_data(fir_out)
		);

endmodule