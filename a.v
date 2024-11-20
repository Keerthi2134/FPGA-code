// Low-Pass Finite Impulse Response (FIR) Filter Implementation
module fir_filter #(
    parameter DATA_WIDTH = 16,     // Input data width
    parameter COEFF_WIDTH = 16,    // Filter coefficient width
    parameter FILTER_TAPS = 32     // Number of filter taps
)(
    input wire clk,                // Clock
    input wire reset,              // Reset signal
    input wire [DATA_WIDTH-1:0] data_in,  // Input data stream
    output wire [DATA_WIDTH-1:0] data_out // Filtered output
);

    // Internal signals
    reg [DATA_WIDTH-1:0] shift_reg [0:FILTER_TAPS-1];
    reg [DATA_WIDTH+COEFF_WIDTH-1:0] mult_result [0:FILTER_TAPS-1];
    reg [DATA_WIDTH+COEFF_WIDTH-1:0] accumulator;

    // Pre-defined filter coefficients (example: low-pass filter)
    // These coefficients are symmetric for a linear phase response
    wire signed [COEFF_WIDTH-1:0] coefficients [0:FILTER_TAPS-1] = {
        16'h0010, 16'h0020, 16'h0030, // Example coefficient values
        // ... more coefficients
        16'h0030, 16'h0020, 16'h0010
    };

    integer i;

    // Shift register and multiplication
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers
            for (i = 0; i < FILTER_TAPS; i = i + 1) begin
                shift_reg[i] <= 0;
                mult_result[i] <= 0;
            end
            accumulator <= 0;
        end else begin
            // Shift input data
            for (i = FILTER_TAPS-1; i > 0; i = i - 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
            shift_reg[0] <= data_in;

            // Multiply and accumulate
            accumulator <= 0;
            for (i = 0; i < FILTER_TAPS; i = i + 1) begin
                mult_result[i] <= shift_reg[i] * coefficients[i];
                accumulator <= accumulator + mult_result[i];
            end
        end
    end

    // Output assignment
    assign data_out = accumulator[DATA_WIDTH+COEFF_WIDTH-1:COEFF_WIDTH];

endmodule

// testbench
module fir_filter_tb;
    reg clk, reset;
    reg [15:0] data_in;
    wire [15:0] data_out;

    // Instantiate the FIR filter
    fir_filter uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        data_in = 0;

        // Release reset
        #10 reset = 0;

        // Generate test input (sine wave)
        repeat(100) begin
            #10 data_in = $sin(i) * 32767; // Scaled sine input
        end

        $finish;
    end

    // Optional: Waveform dumping for simulation
    initial begin
        $dumpfile("fir_filter_simulation.vcd");
        $dumpvars(0, fir_filter_tb);
    end
endmodule