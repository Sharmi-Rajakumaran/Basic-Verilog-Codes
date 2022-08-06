module seq_det_101_tb();

reg clock_tb, rst_tb, data_tb;
wire fsm_out_tb;


parameter CYCLE = 10;

// Instantiation
seq_det_101 DUT(.clock_in(clock_tb), .rst_in(rst_tb), .data_in(data_tb), .fsm_out(fsm_out_tb));

// Clock

always 

begin
 #(CYCLE / 2);
 clock_tb = 1'b0;
 #(CYCLE / 2);
 clock_tb = ~clock_tb;
end

// Reset Task

task reset;
begin
@(negedge clock_tb);
 rst_tb = 1'b1;
 @(negedge clock_tb);
 rst_tb = 1'b0;
end
endtask


// Stimulus for FSM

task stimulus(input l);
begin
    @(negedge clock_tb);
    data_tb = l;

end
endtask

// initialize task

    task initialize;
    begin
        @(negedge clock_tb)
        data_tb  = 1'b0;
    end
    endtask


    initial 
        begin
                reset;
                initialize;

                stimulus(1);
                stimulus(0);
                stimulus(1);
                stimulus(1);
                stimulus(0);
                stimulus(1);
                stimulus(0);
                stimulus(1);
                stimulus(1);
                stimulus(1);
                stimulus(0);
                stimulus(1);
                stimulus(0);
                $finish;
                

        end
    
// To access a value from the rtl just use the instance name followed by the variable name - eg

always@(DUT.state or data_tb)
begin
    if((DUT.state == DUT.S2) &&(fsm_out_tb))
        $monitor($time, " \t The sequence has been detected at state %b", DUT.state);
end

// process to display the result

initial

    $monitor($time, "\t Reset = %b, clock = %b, state = %b, data_in = %b, output = %b", rst_tb,clock_tb, DUT.state, data_tb, fsm_out_tb);

endmodule