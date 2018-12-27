module TXFIFO (TXDATA, TXINTR,
              CLEAR, CLK, PWDATA, SEL, WRITE, SENT); //Receive FIFO
  output[7:0] TXDATA;
  output TXINTR;
  input CLEAR, CLK, SEL, WRITE, SENT;
  input[7:0] PWDATA;
  reg[7:0] TX_mem[3:0];
  wire EMPTY;
  assign TXDATA = TX_mem[0];
  assign EMPTY = ~(|TX_mem[0]);
  integer tx_count;
  assign TXINTR = (tx_count == 4);
  initial
    tx_count = 0;
  always @ (posedge CLK & SEL)
    begin
      if(CLEAR)
        begin
          TX_mem[0] <= 8'b0;
          TX_mem[1] <= 8'b0;
          TX_mem[2] <= 8'b0;
          TX_mem[3] <= 8'b0;
          tx_count = 0;
        end
      else
        if(SENT & ~EMPTY) //reading from TXFIFO
          begin
            TX_mem[0] <= TX_mem[1];
            TX_mem[1] <= TX_mem[2];
            TX_mem[2] <= TX_mem[3];
            TX_mem[3] <= 8'bx;
            tx_count = tx_count - 1;
          end
        if(WRITE & ~(tx_count == 4))//WRITING TO TXFIFO
          begin
            TX_mem[tx_count] <= PWDATA;
            tx_count = tx_count + 1;
          end
        else
          $display("incorrect inputs, doing nothing");
    end

initial
  $monitor("%d %b %b %b %b %b",$time, TX_mem[3], TX_mem[2], TX_mem[1], TX_mem[0], TXINTR);
endmodule //TxFIFO
