module processor_main(clk); //should not do anything if halt cmd is high
  input clk;
  //status registers
  reg Rcarry, Rparity, Reven, Rneg, Rzero;
  reg BRANCHED;
  //memory registers
  reg[31:0] reg_file[15:0];
  reg[31:0] store_mem[15:0];
  //instruction_reg
  //test set
  reg[31:0] is0 =  32'b00000000000000000000000000000000;
  reg[31:0] is1 =  32'b00101000000000001010000000000000; //store a = -15 into mem 0
  reg[31:0] is2 =  32'b00101000000001001001000000000001; //store b =  -3 into mem 1
  reg[31:0] is3 =  32'b00010000000000000000000000000000; //loading mem  into reg 0
  reg[31:0] is4 =  32'b00010000000000000000000000000001; //loading mem 1 into reg 1
  reg[31:0] is5 =  32'b00110100000000000000000000001010; //branch if reg 1 negative to is10
  reg[31:0] is6 =  32'b00110101000000000000000000001101; //branch if reg 1 = 0 to is13
  reg[31:0] is7 =  32'b01010000000000000000000000000000; //add reg 0 to reg 0
  reg[31:0] is8 =  32'b01011000111111111111000000000001; //add -1 to reg 1
  reg[31:0] is9 =  32'b00110000000000000000000000000110; //branch always to is6
  reg[31:0] is10 = 32'b10010000000000000001000000000001; //complement reg 1 to reg 1
  reg[31:0] is11 = 32'b01011000000000000010000000000001; //add 2 to reg 1
  reg[31:0] is12 = 32'b00110000000000000000000000000110; //branch always to is6
  reg[31:0] is13 = 32'b00100000000000000000000000000010; //store reg 0 to mem 2
  reg[31:0] is14 = 32'b00000000000000000000000000000000; //nope
  reg[31:0] is15 = 32'b00000000000000000000000000000000; //nope
  //temp register
  reg[31:0] temp;
  reg[31:0] instruction;
  //program counter
  reg[3:0] program_counter;
  //splitting the instruction into OP, shift_amt, etc.
  reg[11:0] imm_src;
  reg[3:0] op, cc;
  reg[3:0] dest_addr, src_addr;
  reg[4:0] shift_amt;
  reg src_type, dest_type;
  reg shift_direction;


  integer i;

  initial
    begin
      program_counter = 4'b0;
      BRANCHED <= 1'b0;
    end

  always @ (program_counter) begin
  case (program_counter)
   4'b0000: instruction = is0;
   4'b0001: instruction = is1;
   4'b0010: instruction = is2;
   4'b0011: instruction = is3;
   4'b0100: instruction = is4;
   4'b0101: instruction = is5;
   4'b0110: instruction = is6;
   4'b0111: instruction = is7;
   4'b1000: instruction = is8;
   4'b1001: instruction = is9;
   4'b1010: instruction = is10;
   4'b1011: instruction = is11;
   4'b1100: instruction = is12;
   4'b1101: instruction = is13;
   4'b1110: instruction = is14;
   4'b1111: instruction = is15;
   default: $display("illegal command instruction");
  endcase
  end

  always @ (posedge clk)
   begin
   //here is the Program counter selection case
    op <= instruction[31:28];
    cc <= instruction[27:24];

    src_type <= instruction[27];
    dest_type <= instruction[26];

    imm_src <= instruction[23:12];
    src_addr <= instruction[15:12];
    dest_addr <= instruction[3:0];

    shift_amt <= instruction[16:12];
    shift_direction <= instruction[23];
    BRANCHED <= 1'b0;
    $display("operation = %b \n", op);
    #10 case(op)
      4'b0000: //NOP
        begin
          $display("Here in nope");
          program_counter = program_counter + 1;
        end
      4'b0001: //LOAD
        begin
          case(src_type)
            1'b1:
              begin
                temp = imm_src;
                reg_file[dest_addr] <= temp;
                //set PSR
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("Here in load with imm_src");
              end
            1'b0:
              begin
                temp = store_mem[src_addr];
                reg_file[dest_addr] <= temp;
                //set rest of PSR
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("Here in load with mem_dest");
              end
            default: $display("This is an error message in LOAD");
          endcase
          program_counter = program_counter + 1;
        end
      4'b0010: //STORE clears PSR
        begin //loads to a reg file
          case(src_type) //1 means imm source 0 means store_mem
            1'b1:
              begin
                store_mem[dest_addr] <= imm_src;
                {Rcarry, Rparity, Reven, Rneg, Rzero} <= 5'd0;
                $display("Here in store with imm_src");
              end
            1'b0:
              begin
                store_mem[dest_addr] <= store_mem[src_addr];
                {Rcarry, Rparity, Reven, Rneg, Rzero} <= 5'd0;
                $display("Here in store with mem_dest");
              end
            default: $display("This is an error message in STORE");
          endcase
          program_counter = program_counter + 1;
        end
      4'b0011: //BRANCH
        begin
          case(cc)
            4'b0000:
              begin
                program_counter = dest_addr; BRANCHED <= 1'b1;
                $display("Here in branch with always");
              end
            4'b0001:
              begin
                if(Rparity)
                  begin
                  program_counter = dest_addr; BRANCHED <= 1'b1;
                  $display("Here in branch with parity");
                  end
                else
                  begin
                  $display("Did not match condition parity");
                  program_counter = program_counter + 1;
                  end
              end
            4'b0010:
              begin
              if(Reven)
                begin
                program_counter = dest_addr; BRANCHED <= 1'b1;
                $display("Here in branch with even");
                end
              else
                begin
                $display("Did not match condition even");
                program_counter = program_counter + 1;
                end
              end
            4'b0011:
              begin
              if(Rcarry)
                begin
                program_counter = dest_addr; BRANCHED <= 1'b1;
                $display("Here in branch with carry");
                end
              else
                begin
                $display("Did not match condition carry");
                program_counter = program_counter + 1;
                end
              end
            4'b0100:
              begin
              if(Rneg)
                begin
                program_counter = dest_addr; BRANCHED <= 1'b1;
                $display("Branching to instr = %b", dest_addr);
                end
              else
                begin
                $display("Did not match condition negative");
                program_counter = program_counter + 1;
                end
              end
            4'b0101:
              begin
                if(Rzero)
                  begin
                  program_counter = dest_addr; BRANCHED <= 1'b1;
                  $display("Here in branch with zero");
                  end
                else
                  begin
                  $display("Did not match condition zero");
                  program_counter = program_counter + 1;
                  end
              end
            4'b0110:
              begin
              if(~Rcarry)
                begin
                program_counter = dest_addr; BRANCHED <= 1'b1;
                $display("Here in branch with no carry");
                end
              else
                begin
                $display("Did not match condition no carry");
                program_counter = program_counter + 1;
                end
              end
            4'b0111:
              begin
                if(~Rneg)
                  begin
                  program_counter = dest_addr; BRANCHED <= 1'b1;
                  $display("Here in branch with positive");
                  end
                else
                  begin
                  $display("Did not match condition positive");
                  program_counter = program_counter + 1;
                  end
              end
            default: $display("This is an error message for BRANCH");
          endcase
        end
      4'b0100: //XOR
        begin
          case(src_type)
            1'b1:
              begin
                temp = reg_file[dest_addr] ^ imm_src;
                reg_file[dest_addr] = temp;
                // check psr
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("Here in xor with imm_src");
              end
            1'b0:
              begin
                temp = reg_file[dest_addr] ^ reg_file[src_addr];
                reg_file[dest_addr] = temp;
                // check psr
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("Here in xor with reg_file");
              end
            default: $display("This is an error message in XOR");
          endcase
          program_counter = program_counter + 1;
        end
        4'b0101: //ADD
        begin
          case(src_type)
            1'b1:
              begin
                {Rcarry, temp} = reg_file[dest_addr] + imm_src;
                #20 reg_file[dest_addr] = temp;
                //set rest of psr
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("Here in add with imm_src");
              end
            1'b0:
              begin
                {Rcarry, temp} = reg_file[dest_addr] + reg_file[src_addr];
                #20 reg_file[dest_addr] = temp;
                //set rest of psr
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("Here in add with reg_file");
              end
            default: $display("This is an error message in ADD");
          endcase
          program_counter = program_counter + 1;
        end
      4'b0110: //ROTATE
        begin
          if(~shift_direction) //left
            begin
            temp = reg_file[dest_addr];
              for(i = 0; i < shift_amt; i = i + 1)
                begin
                  temp = {temp[30:0], temp[31]};
                end
              reg_file[dest_addr] == temp;
              Rcarry <= 1'b0;
              Rparity <= (^temp);
              Rneg <= temp[11];
              Rzero <= (temp == 32'b0);
              Reven <= ~(temp[0]);
              $display("rot left");
            end
          if(shift_direction) //right
            begin
            temp = reg_file[dest_addr];
            for(i = 0; i < shift_amt; i = i + 1)
              begin
                temp <= {temp[0], temp[31:1]};
              end
             reg_file[dest_addr] <= temp;
             Rcarry <= 1'b0;
             Rparity <= (^temp);
             Rneg <= temp[11];
             Rzero <= (temp == 32'b0);
             Reven <= ~(temp[0]);
             $display("rot right");
            end
          else
            $display("This is an error message in ROT");
          program_counter = program_counter + 1;
        end
      4'b0111: //SHIFT
        begin
          if(~shift_direction) //left
            begin
              temp <= reg_file[dest_addr];
              temp = temp << shift_amt;
              #20 reg_file[dest_addr] = temp;
              Rcarry <= 1'b0;
              Rparity <= (^temp);
              Rneg <= temp[11];
              Rzero <= (temp[11:0] == 12'b0);
              Reven <= ~(temp[0]);
              $display("shift left");
            end
          if(shift_direction)
            begin
              temp <= reg_file[dest_addr];
              temp = temp >> shift_amt;
              #20 reg_file[dest_addr] = temp;
              //set PSR
              Rcarry <= 1'b0;
              Rparity <= (^temp);
              Rneg <= temp[11];
              Rzero <= (temp == 32'b0);
              Reven <= ~(temp[0]);
              $display("shift right");
            end
          else
            $display("This is an error message in shift or the shift_amt was zero");
          program_counter = program_counter + 1;
        end

      4'b1000: //HALT
        begin
            program_counter <= program_counter;
            $display("This has halted");
        end
      4'b1001: //COMP
        begin
          if(src_type)
              begin
                temp <= ~(imm_src);
                reg_file[dest_addr] <= temp;
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("complementing imm_src");
              end
          if(~src_type)
              begin
                temp <= ~(reg_file[src_addr]);
                reg_file[dest_addr] <= temp;
                Rcarry <= 1'b0;
                Rparity <= (^temp);
                Rneg <= temp[11];
                Rzero <= (temp == 32'b0);
                Reven <= ~(temp[0]);
                $display("complementing reg_file");
              end
          else
            $display("An error has occured at complement");
          program_counter = program_counter + 1;
        end
    endcase
    $monitor("time = %d, pc = %b, opcode = %b, src_addr = %b, src_type = %b, dest_addr = %b, dest_type = %b \n
              dest_mem val = %b, dest reg_file val = %b, \n
              imm_src = %b, src_reg_val = %b src_mem_val = %b\n
              Rcarry = %b, Rneg = %b, Rzero = %b, Rparity = %b, Reven = %b", $time, program_counter, op, src_addr, src_type, dest_addr, dest_type,
              store_mem[dest_addr], reg_file[dest_addr],
              imm_src, reg_file[src_addr], store_mem[src_addr],
              Rcarry, Rneg, Rzero, Rparity, Reven);
  end


endmodule
