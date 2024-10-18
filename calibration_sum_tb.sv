module calibration_sum_tb;

  // Parameters for clock period
  parameter CLOCK_PERIOD = 10;

  // Clock and reset
  reg clk;
  reg rst_n;

  // Inputs to the DUT (Device Under Test)
  reg input_valid;
  reg [7:0] char_in;

  // Output from the DUT
  wire [31:0] result;

  // Instantiate the DUT
  calibration_sum dut (
    .clk(clk),
    .rst_n(rst_n),
    .input_valid(input_valid),
    .char_in(char_in),
    .result(result)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
  end

  // Testbench variables for file I/O
  integer file;
  reg [8*200-1:0] line;
  integer i, char_count;

  // Task to feed one character into the DUT
  task feed_char;
    input [7:0] c;
    begin
      char_in = c;
      input_valid = 1;   // Set input_valid high
      @(posedge clk);     // Wait for a clock cycle
      input_valid = 0;    // Set input_valid low
      @(posedge clk);     // Wait for the next clock cycle to ensure DUT processes input
    end
  endtask

  // Testbench main logic
  initial begin
    // Initialize signals
    rst_n = 0; // Assert reset
    input_valid = 0;
    char_in = 0;

    // Apply reset
    @(posedge clk);
    rst_n = 1; // Deassert reset
    @(posedge clk); // Allow time for DUT to reset

    // Open the input file
    file = $fopen("input.txt", "r");
    if (file == 0) begin
      $display("Error: Could not open input.txt");
      $finish;
    end

    // Read file line by line
    while (!$feof(file)) begin
      char_count = $fgets(line, file);
      
      // Feed each character into the DUT
      if (char_count > 0) begin
        for (i = 0; i < char_count; i = i + 1) begin
          feed_char(line[8*i +: 8]);  // Feed each character to DUT
        end
        
        // Feed a newline (ASCII 10) to signal end of line
        feed_char(8'h0A);  // ASCII for newline '\n'
      end
    end

    // Close the file
    $fclose(file);

    // Wait for some cycles and check result
    @(posedge clk);
    @(posedge clk);
    $display("Final result: %d", result);

    // End simulation
    $finish;
  end

endmodule
