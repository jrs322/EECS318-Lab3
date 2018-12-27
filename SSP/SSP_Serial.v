module serial_port(RXDATA, bit_out, SSPCLK_OUT, OE_B, S_OUT, RECEIVED_DATA, SENT_DATA,
                  TXDATA, bit_in, SSPCLK_IN, S_IN, CLEAR);
    input bit_in, SSPCLK_IN, S_IN, CLEAR;
    input[7:0] TXDATA;
    output bit_out, SSPCLK_OUT, OE_B, S_OUT, RECEIVED_DATA, SENT_DATA;
    output[7:0] RXDATA;
    assign SSPCLK_OUT = SSPCLK_IN;
    reg[7:0] transmit_value, RXDATA;
    reg S_OUT, sending, receiving, bit_out, RECEIVED_DATA, SENT_DATA;
    reg[2:0] out_count, in_count;
    initial
    begin
      {RXDATA, transmit_value} <= 16'bx;
      out_count <= 3'b0;
      in_count <= 3'b0;
    end
    always @ (posedge SSPCLK_IN) //do transmit logic here
    begin
      if (CLEAR)
      begin
        transmit_value <= 8'bx;
        bit_out <= 1'bx;
        out_count <= 3'b0;
      end
      else if(TXDATA != transmit_value & !sending)
      begin
        sending <= 1'b1;
        S_OUT <= 1'b1;
      end
      else if(sending)
      begin
        S_OUT <= 1'b0;
        bit_out = transmit_value[out_count];
        out_count = out_count + 1;
        S_OUT <= 1'b0;
        if(out_count > 7)
        begin
          out_count = 0;
          S_OUT <= 1'b1;
          sending <= 1'b0;
          SENT_DATA <= 1'b1;
          #20 S_OUT <= 1'b0;
        end
      end
    end

    always @ (negedge SSPCLK_IN) //receive logic
    begin
      if(CLEAR)
      begin
        RXDATA <= 8'bx;
        in_count <= 3'b0;
      end
      else
      begin
        if(S_IN)
          begin
            RXDATA[in_count] = bit_in;
            in_count = in_count + 1;
            if(in_count > 7)
              begin
                in_count = 0;
                RECEIVED_DATA = 1'b1;
              end
          end
        else
          $display("Not receiving");
      end
    end
    initial begin
      $monitor("%b %b %b %b %b %b", bit_in, bit_out, RXDATA, transmit_value, TXDATA, RXDATA);
    end
endmodule
