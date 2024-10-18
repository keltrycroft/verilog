module calibration_sum(
  input wire clk,
  input wire rst_n,
  input wire input_valid,
  input wire [7:0] char_in,
  output reg [31:0] result
);

  typedef enum logic [1:0] {
    READING = 2'b00,
    LINE_END = 2'b01
  } state_t;
  state_t state, next_state;

  reg [3:0] first_digit, last_digit, first_digit_next, last_digit_next;
  reg [31:0] result_next;
  reg digit_found, digit_found_next;
  reg [31:0] line_count, line_count_next;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= READING;
      result <= 0;
      first_digit <= 4'b1111; // Invalid digit
      last_digit <= 4'b1111;  // Invalid digit
      digit_found <= 0;
      line_count <= 0;
      //$display("Reset occurred. State: READING, Result: 0");
    end else begin
      state <= next_state;
      result <= result_next;
      first_digit <= first_digit_next;
      last_digit <= last_digit_next;
      digit_found <= digit_found_next;
      line_count <= line_count_next;
    end
  end

  always_comb begin
    // Default values for next states/outputs
    next_state = state;
    result_next = result;
    first_digit_next = first_digit;
    last_digit_next = last_digit;
    digit_found_next = digit_found;
    line_count_next = line_count;

    case (state)
      READING: begin
        if (input_valid) begin
          if (char_in >= 48 && char_in <= 57) begin
            // Found a digit (0-9)
            if (!digit_found) begin
              // First digit found: treat as both first and last initially
              first_digit_next = char_in - 48;
              last_digit_next = char_in - 48;
              digit_found_next = 1;
              //$display("Line %0d: First digit found: %d", line_count, first_digit_next);
            end else begin
              // Update the first digit with the newly found digit
              first_digit_next = char_in - 48;
              //$display("Line %0d: Updated first digit: %d", line_count, first_digit_next);
            end
          end else if (char_in == 10) begin  // Newline character (ASCII 10)
            next_state = LINE_END;  // Go to the LINE_END state
          end
        end
      end

      LINE_END: begin
        if (digit_found) begin
          // Compute result if digits were found in this line
          result_next = result + (first_digit * 10 + last_digit);
          //$display("Line %0d: Number: %d%d, New Result: %d", 
                   //line_count, first_digit, last_digit, result_next);
        end else begin
          //$display("Line %0d: No digits found", line_count);
        end

        // Reset for the next line
        next_state = READING;
        first_digit_next = 4'b1111;  // Reset to invalid
        last_digit_next = 4'b1111;   // Reset to invalid
        digit_found_next = 0;        // Reset digit found flag
        line_count_next = line_count + 1;  // Increment line count
      end
    endcase
  end

endmodule
