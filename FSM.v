module FSM (
	input clk,
	input i_rst,
	input i_write_full,       /* FSM reads this signal when  WRITE_COUNTER overflows */
	input edge_detector,
	output reg full_mem_indicator,
	output reg o_write_ena /* This signal goes to BRAM and WRITE_COUNTER */	
);

	//localparam READ_STATE = 2'd0;
	localparam WRITE_STATE = 2'd1;
	localparam IDLE_STATE = 2'd2;

	reg [1:0] state;
	reg [1:0] next_state;

	always @(posedge clk) begin
		if (i_rst) begin		
			state <= IDLE_STATE;
		end
		else begin
			state <= next_state;		
		end
	end

	always @(*) begin
		
		case(state)

			WRITE_STATE: begin			
				o_write_ena <= 1'b1;

				if (i_write_full) begin		
					next_state <= IDLE_STATE;
					full_mem_indicator <= 1'd1;	
				end 
				else begin
					next_state <= WRITE_STATE;
					full_mem_indicator <= 1'd0;	
				end
				//o_read_ena <= 1'b0;
				//next_state <= READ_STATE;
			end

			/*READ_STATE: begin			
				o_read_ena <= 1'b1;
				o_write_ena <= 1'b0;
				next_state <= WRITE_STATE;
			end*/

			IDLE_STATE: begin			
				//o_read_ena <= 1'b0;
				o_write_ena <= 1'b0;

				if(edge_detector) begin
					next_state <= WRITE_STATE;
				end
				else begin	
					next_state <= IDLE_STATE;
				end				
			end

			default: begin
					next_state <= next_state;
			end
		endcase
	end		
endmodule