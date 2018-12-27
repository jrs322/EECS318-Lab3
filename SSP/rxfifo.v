module RXFIFO (PRDATA, RXINTR,
              RXDATA, CLEAR, CLK, SEL, WRITE, RECEIVED);
  input[7:0] RXDATA;
  input CLEAR, CLK, SEL, WRITE, RECEIVED;
  output RXINTR;
  output[7:0] PRDATA;
  reg[7:0] RX_mem[0:3];
  wire EMPTY;
  assign PRDATA = RX_mem[0];
  assign EMPTY = ~(|RX_mem[0]);
  integer rx_count;
  assign TXINTR = (rx_count == 4);
  initial begin
    rx_count = 0;
  end
  always @ (posedge CLK & SEL )
  begin
    if(CLEAR)
      begin
        RX_mem[0] <= 8'bx;
        RX_mem[1] <= 8'bx;
        RX_mem[2] <= 8'bx;
        RX_mem[3] <= 8'bx;
        rx_count = 0;
      end
    else
      if(RECEIVED & ~EMPTY)
        begin
          RX_mem[0] <= RX_mem[1];
          RX_mem[1] <= RX_mem[2];
          RX_mem[2] <= RX_mem[3];
          RX_mem[3] <= 8'bx;
          rx_count = rx_count - 1;
        end
      if(WRITE & ~(rx_count == 4))
        begin
          RX_mem[rx_count] <= RXDATA;
          rx_count = rx_count + 1;
        end
      else
        $display("incorrect inputs, doing nothing");
  end
  initial
    $monitor("rxfifo time = %d, %b %b %b %b %b",$time, RX_mem[3], RX_mem[2], RX_mem[1], RX_mem[0], RXINTR);
endmodule //RXFIF0
