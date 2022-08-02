module fifo16x9_tb();

reg clock_tb, resetn_tb, write_enb_tb, read_enb_tb, soft_reset_tb, lfd_state_tb;
reg [7:0] data_in_tb;
reg empty_tb, full_tb;
wire [7:0]data_out_tb ;

integer k;
// Clock Generate Logic
parameter T = 5;

always 

    begin
        #(T/2);
        clock_tb = 1'b0;
        #(T/2);
        clk = ~clk;
    end

// Initialize Task

task Initialize();
begin
    clock_tb = 1'b0;
    resetn_tb = 1'b0;
    write_enb_tb = 1'b0;
    read_enb_tb = 1'b0;
    soft_reset_tb = 1'b0;
end
endtask

// reset task

task reset;
begin
@(negedge clock_tb)
 resetn_tb = 1'b0;
 @(negedge clock_tb)
 resetn_tb = 1'b1;
end
endtask

// Soft reset

task soft_dut();
begin
    soft_reset_tb = 1'b1;
    #(T);

    soft_reset_tb = 1'b0;
end
endtask

// Write Task
task write;
reg [7:0]payload_data, parity, header;
reg [5:0]payload_len;
reg [1:0]data;

    begin
        @(negedge clock_tb)
        payload_len = 6'd14;
        addr = 2'b01;
        header = {payload_len, addr};
        data_in_tb = header;
        lfd_state_tb = 1'b1;
        write_enb_tb = 1'b1;
        
        for (k=0: k<payload_len: k = k +1)
            begin
              @(negedge clock_tb)
              lfd_state_tb = 1'b0;
              payload_data = {%random %256};
              data_in_tb = payload_data; 
            end
            @(negedge clock_tb)
            parity = {$random}%256;
            data_in_tb = parity;
    end
    endtask

    // read task

        task read(input i, input j);

        begin

            @(negedge clock_tb)
            write_enb_tb = i;
            read_enb_tb =j;
        end
        endtask
    initial 
    begin
    initialize;
    #10;
    reset;
    write;
    for(k=0;k<16;k=k+1)
    read(0,1);
    #20;
    read(0,0);
    #4000 $finish;    
    end
    endmodule
