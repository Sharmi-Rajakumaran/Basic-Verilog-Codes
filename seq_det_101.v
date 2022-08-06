module seq_det_101(input clock_in, rst_in, data_in, output reg fsm_out);


// defining states

parameter IDLE = 2'b00,
          S1 = 2'b01,
          S2 = 2'b10;

// present state and next state - 3 states each state requires 2 bits

reg [1:0] state, next_state;

// Present State Logic or State Transition Logic

always @(posedge clock_in or posedge rst_in)
begin
    if(rst_in)
        state <= IDLE;
        else 
            state <= next_state;
end

// Next state decoder Logic:

always@(state or data_in)
begin   
    case(state)
        IDLE: begin 
                if(data_in==1)
                    next_state = S1;
                     else 
                        next_state = IDLE;
              end
        S1 : begin  
                if(data_in==0)
                    next_state = S2;
                    else    
                        next_state = S1;
            end

        S2 : begin  
                if(data_in==1)
                    next_state = S1;
                    else
                    next_state = IDLE;
        end

        default : next_state = IDLE;

    endcase
end

// Output Logic

always@(posedge clock_in or posedge rst_in)
    
    begin
    if(rst_in)
     begin
        fsm_out <= 1'b0;
     end

    if((state == S2)&& (data_in ==1))
        fsm_out = 1'b1;
        else 
            fsm_out = 1'b0;
    end


endmodule