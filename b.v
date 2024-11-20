// Simple Sine Wave Generator and Filter
module sine_generator(
    input wire clk,
    input wire reset,
    output reg [15:0] sine_out
);
    // Angle accumulator
    reg [15:0] angle;
    
    // Sine wave generation using simple method
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            angle <= 0;
            sine_out <= 0;
        end else begin
            // Increment angle to create wave
            angle <= angle + 1;
            
            // Simple sine approximation
            case(angle[15:14])
                2'b00: sine_out = angle[13:0];
                2'b01: sine_out = 16'hFFFF - angle[13:0];
                2'b10: sine_out = -angle[13:0];
                2'b11: sine_out = angle[13:0] - 16'hFFFF;
            endcase
        end
    end
endmodule

// Simple Low-Pass Filter
module low_pass_filter(
    input wire clk,
    input wire reset,
    input wire [15:0] data_in,
    output reg [15:0] filtered_out
);
    // Filter coefficient (simple moving average)
    reg [15:0] prev_values [3:0];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            filtered_out <= 0;
            for (i = 0; i < 4; i = i + 1)
                prev_values[i] <= 0;
        end else begin
            // Shift previous values
            for (i = 3; i > 0; i = i - 1)
                prev_values[i] <= prev_values[i-1];
            
            // Store new input
            prev_values[0] <= data_in;
            
            // Calculate moving average
            filtered_out <= (prev_values[0] + prev_values[1] + 
                             prev_values[2] + prev_values[3]) >> 2;
        end
    end
endmodule

// Testbench
module testbench;
    reg clk, reset;
    wire [15:0] sine_wave;
    wire [15:0] filtered_signal;

    // Instantiate modules
    sine_generator generator(
        .clk(clk),
        .reset(reset),
        .sine_out(sine_wave)
    );

    low_pass_filter filter(
        .clk(clk),
        .reset(reset),
        .data_in(sine_wave),
        .filtered_out(filtered_signal)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Simulation control
    initial begin
        // Initialize
        clk = 0;
        reset = 1;

        // Release reset
        #10 reset = 0;

        // Run simulation for some time
        #1000 $finish;
    end

    // Output results
    initial begin
        $monitor("Time=%0t Sine Wave=%d Filtered Signal=%d", 
                  $time, sine_wave, filtered_signal);
    end
endmodule