module synchronizer(input clock, resetn, detect_add,
                    input full0, full1, full2,
                    input [1:0]data_in,
                    input empty0, empty1, empty2,
                    input write_enb_reg,
                    input read_enb0, read_enb1, read_enb2,
                    output reg [2:0]write_enb,
                    output reg fifo_full,
                    output vld_out0, vld_out1,vld_out2,
                    output reg soft_reset0, soft_reset1, soft_reset2);


// register for implementing Soft reset counter and for updating the address only when detect address equals 1

reg [1:0]fifo_addr;

reg [4:0] count_fifo_0_sft_rst, count_fifo_1_sft_rst, count_fifo_2_sft_rst;

// Since we are reseting the counter after waiting for 30 clock pulses 5 bit is used.

// Logic for FIFO Full

// assign fifo_full = full0 || full1 || full2;

always@(posedge clock)

begin

case (data_in)
    2'b00: fifo_full <= full0;
    2'b01: fifo_full <= full1;
    2'b10: fifo_full <= full2;

    default: fifo_full <= 1'b0;
endcase

end

// passing address when the detect address is high
always@(posedge clock)
begin
 if(!resetn)
  fifo_addr <= 2'b00;
    else if(detect_add)
        fifo_addr <=data_in;
end


// Logic for Valid Out

assign vld_out0 = ~empty0;
assign vld_out1 = ~empty1;
assign vld_out2 = ~empty2;

// Logic for Write enable - 3 bit
always @(*) // Write enable doesnot depend on clock

begin
if(write_enb_reg == 1'b0)
    write_enb = 3'b000;

    else 
        begin

            case(fifo_addr)

            2'b00: write_enb = 3'b001;
            2'b01: write_enb = 3'b010;
            2'b10: write_enb = 3'b100;

            default: write_enb = 3'b111;

            endcase
        end
end


// Logic for soft reset

// Soft Reset for FIFO _ 0
always@(posedge clock)
    begin
        if(~resetn)                         // if active low reset
            begin
                count_fifo_0_sft_rst <= 5'b00001;
                soft_reset0 <=0;
            end

            else if (~vld_out0)             // if valid out is 0
                begin
                    count_fifo_0_sft_rst <= 5'b00001;
                    soft_reset0 <=0;
                end
                else if(read_enb0)          // if read enable is 1
                    begin
                        count_fifo_0_sft_rst <= 5'b00001;
                        soft_reset0 <=0;
                    end
                        else if(count_fifo_0_sft_rst == 5'd30)
                            begin
                                soft_reset0 <=1;
                                count_fifo_0_sft_rst <=5'b00001;
                            end
                            else 
                                begin   
                                    count_fifo_0_sft_rst <= count_fifo_0_sft_rst + 1'b1;
                                    soft_reset0 <=0;
                                end
    end

// Soft Reset for FIFO _ 1
always@(posedge clock)
    begin
        if(~resetn)                         // if active low reset
            begin
                count_fifo_1_sft_rst <= 5'b00001;
                soft_reset1 <=0;
            end

            else if (~vld_out1)             // if valid out is 0
                begin
                    count_fifo_1_sft_rst <= 5'b00001;
                    soft_reset1 <=0;
                end
                else if(read_enb1)          // if read enable is 1
                    begin
                        count_fifo_1_sft_rst <= 5'b00001;
                        soft_reset1 <=0;
                    end
                        else if(count_fifo_1_sft_rst == 5'd30)
                            begin
                                soft_reset1 <=1;
                                count_fifo_1_sft_rst <=5'b00001;
                            end
                            else 
                                begin   
                                    count_fifo_1_sft_rst <= count_fifo_1_sft_rst + 1'b1;
                                    soft_reset1<=0;
                                end
    end

// Soft Reset for FIFO _ 2
always@(posedge clock)
    begin
        if(~resetn)                         // if active low reset
            begin
                count_fifo_2_sft_rst <= 5'b00001;
                soft_reset2 <=0;
            end

            else if (~vld_out2)             // if valid out is 0
                begin
                    count_fifo_2_sft_rst <= 5'b00001;
                    soft_reset2 <=0;
                end
                else if(read_enb2)          // if read enable is 1
                    begin
                        count_fifo_2_sft_rst <= 5'b00001;
                        soft_reset2 <=0;
                    end
                        else if(count_fifo_2_sft_rst == 5'd30)
                            begin
                                soft_reset2 <=1;
                                count_fifo_2_sft_rst <=5'b00001;
                            end
                            else 
                                begin   
                                    count_fifo_2_sft_rst <= count_fifo_2_sft_rst + 1'b1;
                                    soft_reset2<=0;
                                end
    end




endmodule