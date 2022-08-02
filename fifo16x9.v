module fifo16x9(input clock, resetn, write_enb, read_enb, soft_reset, lfd_state, 
                input [7:0] data_in, 
                output empty, full, 
                output reg [7:0]data_out);


// Fifo contains memory of 16 x 8. So declare a memory register

reg [8:0]mem[0:15];         // 16 x 9 memory

reg [6:0] fifo_counter;     // used to count the payload
                            // max payload is 64 bytes but parity & header bytes must also be written so use 7 bits
                        
reg [4:0]rd_pt, wr_pt;

integer i;

// FIFO Pointer Logic for each clock pulse

always@(posedge clock)

    begin
            if(!resetn)
                begin
                        rd_pt <= 5'b0;
                        wr_pt <=5'b00;
                end
                else if (soft_reset)
                    begin
                        rd_pt <=5'b0;
                        wr_pt <=5'b0;
                    end
                else
                    begin   
                        if(!full && write_enb)
                            wr_pt <=wr_pt +1;
                            else
                             wr_pt <= wr_pt;
                        if(!empty && read_enb)
                            rd_pt <= rd_pt +1;
                            else 
                            rd_pt <= rd_pt;
                    end


    end 

// FIFO Counter Logic

always @(posedge clock)
begin
    if(resetn)    
        fifo_counter <= 5'b0;
        else if(soft_reset)
            fifo_counter <=5'b0;
                else if (read_enb & ~empty)
                    begin
                        if(mem[rd_pt[3:0]][8] <=1'b1)
                            fifo_counter <= mem[rd_pt[3:0]][7:2] + 1'b1; 
                        else if (fifo_counter!=0)
                            fifo_counter <= fifo_counter - 1'b1;
                    end
end

// Read Operation

always @(posedge clock)
    begin
        if(!resetn)
            data_out <=8'b0;
            else if(soft_reset)
            data_out <=8'bz;
            else if (fifo_counter == 0)
                data_out <=8'bz;
                else if(read_enb&& ~empty)
                    data_out <= mem[rd_pt[3:0]];
    end
// Write OPeration

always@(posedge clock)
    begin
    if(!resetn)
        begin
            for (i=0; i<16; i = i+1)
            mem[i] = 0;

        end
        else if(soft_reset)
            begin   
                for(i=0;i<16; i = i+1)
                mem[i] = 0;
            end
            else if(write_enb && !full)
            begin
                {mem[wr_pt[3:0]][8], mem[wr_pt[3:0]][7:0]}  <= {lfd_state, data_in};
            end
    end

// empty and full logic

assign full = (wr_pt=={~rd_pt[4],rd_pt[3:0]})?1'b1:1'b0;

assign empty = (wr_pt == rd_pt) ? 1'b1: 1'b0;

endmodule

