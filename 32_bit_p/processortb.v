//IR[31:28] Opcode 0000
//IR[27:24] CC 0000
//IR[27] source type O=reg(mem),1=imm 0
//IR[26] destination type O=reg, 1=imm 0
//IR[23:12] Source address 000000000000
//IR[23:12] shift/rotate count 000000000000
//IR[11:0] destination address 000000000000
// 0000 0000 000000000000 000000000000
module test_processor();
  reg CLK, hold;
  processor_main cpu(CLK);

  initial begin                //  |op |cc |src        |dest
    CLK = 1'b1; hold = 1'b0;

    #1000 $finish;
  end

  always
   #5 CLK = ~CLK;
endmodule
