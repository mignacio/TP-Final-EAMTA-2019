(* ram_style = "block" *)
module bram#(parameter NB_ADDR = 15,
			 parameter NB_DATA = 14,
			 parameter INIT_FILE = "RAM_INIT.txt")
			(
			output reg [NB_DATA-1 : 0] o_data,
			input [NB_DATA-1 : 0] i_data,
			input [NB_DATA-1 : 0] i_write_addr,
			input [NB_ADDR-1 : 0] i_read_addr,
			input				  i_write_enable,
			input				  i_read_enable,
			input				  clock
			);
	reg [NB_DATA-1:0] ram [2**NB_ADDR-1:0];

	always@(posedge clock)begin:writecycle
		if(i_write_enable)begin
			ram[i_write_addr] <= i_data;
		end
		else begin
		end
	end
	
	always@(posedge clock)begin:readcycle
		if(i_read_enable)begin
			o_data <= ram[i_read_addr];
		end
		else begin
		end
	end
	
	generate
		initial
			$readmemh(INIT_FILE, ram, 0, (2**NB_ADDR)-1);
	endgenerate

endmodule