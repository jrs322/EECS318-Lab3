module ssp_test1;
	reg clock, clear_b, pwrite, psel, sspclkin, sspfssin, ssprxd;
	reg [7:0] data_in;

	wire sspoe_b, ssptxd, sspfssout, sspclkout, ssptxintr, ssprxintr;
	wire [7:0] data_out;

	initial
	begin
			clock = 1'b0;
			clear_b = 1'b0;
			psel = 1'b0;
			sspclkin = 1'b0;
    			sspfssin = 1'b0;
    			ssprxd = 1'b0;
		@(posedge clock);
		#1;
		@(posedge clock);
    			data_in = 8'b11111111; //8'hFF, dummy data. should not enter into SSP.
		#1;
			clear_b = 1'b1;
		#50 	psel = 1'b1;
			pwrite = 1'b1;
			data_in = 8'b00110101; //8'h35
		#40 	data_in = 8'b10101110; //8'hAE
		#30 	psel = 1'b0;
		#200   	data_in = 8'b00100110; //8'h26
		#10 	psel = 1'b1;
		#40 	data_in = 8'b00111001; //8'h39
    		#40 	data_in = 8'b10011101; //8'h9D
    		#40 	data_in = 8'b01110100; //8'h74
    		#40 	data_in = 8'b10001111; //8'h8F
    		#40 	data_in = 8'b10110001; //8'bB1
		#40 	data_in = 8'b01010101; //8'b55

	end

	always
		#20 clock = ~clock;

// serial output from SSP is looped back to the serial input.

	ssp ssp1 (.CLK(clock), .CLEAR(clear_b), .SEL(psel), .WRITE(pwrite), .SSPCLK_IN(sspclkin), .S_IN(sspfssin), .bit_in(ssprxd), .PWDATA(data_in), .PRDATA(data_out), .SSPCLK_OUT(sspclkout), .S_OUT(sspfssout), .bit_out(ssptxd), .OE_B(sspoe_b), .TXINTR(ssptxintr), .RXINTR(ssprxintr));

endmodule

module ssp_test2;
	reg clock, clear_b, pwrite, psel, s_in, ssp_clk;
	reg [7:0] data_in;
	wire [7:0] data_out;
	wire sspoe_b, tx_to_rx, clk_wire, ssptxintr, ssprxintr, oe_b, s_out;

	initial
	begin
			clock = 1'b0;
			clear_b = 1'b0;
			psel = 1'b1;
		@(posedge clock);
		#1;
		@(posedge clock);
    			data_in = 8'b11111111; //8'hFF, dummy data. should not enter into SSP.
		#1;
			clear_b = 1'b1;
		#15 	pwrite = 1'b1; s_in = 1'b1;
			data_in = 8'b10010100; //8'h94
		#40 	data_in = 8'b00001111; //8'h0F
		#40 	data_in = 8'b01010001; //8'h51
		#40 	data_in = 8'b00100100; //8'h24
		#40 	data_in = 8'b01100111; //8'h67
		#40 	data_in = 8'b11110011; //8'hF3
    		#40 	data_in = 8'b10110110; //8'hB6
    		#40 	data_in = 8'b10000100; //8'b84
		#30 	psel = 1'b0;
		#870 	psel = 1'b1;
			pwrite = 1'b0;
    		#80 	pwrite = 1'b1;
    		#40 	psel = 1'b0;
    		#3600 	pwrite = 1'b0;
    			psel = 1'b1;
	end

	always
		#20	clock = ~clock;
	always @ (posedge clock) begin
		ssp_clk = ~ssp_clk;
		$display("%b %b %b ", tx_to_rx, data_in, data_out);
		end
// serial output from SSP is looped back to the serial input.

	ssp ssp2 (.CLK(clock), .CLEAR(clear_b), .SEL(psel), .WRITE(pwrite), .SSPCLK_IN(ssp_clk), .S_IN(s_in), .bit_in(tx_to_rx), .PWDATA(data_in), .PRDATA(data_out), .SSPCLK_OUT(clk_wire), .S_OUT(s_out), .bit_out(tx_to_rx), .OE_B(oe_b), .TXINTR(ssptxintr), .RXINTR(ssprxintr));

endmodule
