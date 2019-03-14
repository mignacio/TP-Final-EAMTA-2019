

module PRBS #(parameter NB = 9, 
		      parameter SEED = 9'h1AA,
		      parameter HIGH = 9,
		      parameter LOW = 5)(
	
	output o_data,
	input i_reset, i_valid, clock, i_enable);

reg [NB-1:0] shift_reg;

always @(posedge clock) begin
	if (i_reset) begin
		
		shift_reg <= SEED;
		
	end
	else if (i_enable && i_valid) begin

		shift_reg <= {shift_reg[NB-2-:NB-1],shift_reg[LOW-1]^shift_reg[HIGH-9]}; //Me paro en la posicion NB-2 (7) y tomo NB-1(8) elementos
	end
	else 
		shift_reg <= shift_reg;
end

assign o_data = shift_reg[NB-1];

endmodule