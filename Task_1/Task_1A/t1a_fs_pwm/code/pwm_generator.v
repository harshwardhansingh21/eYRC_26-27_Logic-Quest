// Logic Quest Bot : Task 1A : PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the clk_5MHz Clock Frequency to 500Hz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : clk_5MHz, pulse_width
//Output : clk_500Hz, pwm_signal

module pwm_generator(
    input clk_5MHz,
    input reset_n,
    input [4:0] pulse_width,
    output reg clk_500Hz, pwm_signal
);

    localparam int TICK_COUNT        = 500;
    localparam int COUNTS_PER_PERIOD = 20;
 
    reg [8:0] tick_cnt;
    reg     tick;
 
    always_ff @(posedge clk_5MHz or negedge reset_n) begin
        if (!reset_n) begin
            tick_cnt <= '0;
            tick     <= 1'b0;
        end else if (tick_cnt == TICK_COUNT - 1) begin
            tick_cnt <= '0;
            tick     <= 1'b1;
        end else begin
            tick_cnt <= tick_cnt + 1'b1;
            tick     <= 1'b0;
        end
    end
 
    logic [4:0] pwm_cnt;
 
    always_ff @(posedge clk_5MHz or negedge reset_n) begin
        if (!reset_n) begin
            pwm_cnt <= '0;
        end else if (tick) begin
            if (pwm_cnt == COUNTS_PER_PERIOD - 1)
                pwm_cnt <= '0;
            else
                pwm_cnt <= pwm_cnt + 1'b1;
        end
    end
 
    always_ff @(posedge clk_5MHz or negedge reset_n) begin
        if (!reset_n) begin
            clk_500Hz  <= 1'b0;
            pwm_signal <= 1'b0;
        end else begin
            clk_500Hz  <= (pwm_cnt < (COUNTS_PER_PERIOD / 2));
            pwm_signal <= (pwm_cnt < pulse_width);
        end
    end

endmodule

