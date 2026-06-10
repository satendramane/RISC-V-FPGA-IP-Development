module timer_ip (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid,
    input  wire        we,
    input  wire [1:0]  offset,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);

    reg [31:0] ctrl_reg;
    reg [31:0] load_reg;
    reg [31:0] value_reg;
    reg        timeout_flag;
    reg [7:0]  presc_counter;

    wire en       = ctrl_reg[0];
    wire mode     = ctrl_reg[1];
    wire presc_en = ctrl_reg[2];
    wire [7:0] presc_div = ctrl_reg[15:8];
    wire presc_tick = (!presc_en) || (presc_counter == 8'd0);

    always @(posedge clk) begin
        if (rst) begin
            ctrl_reg      <= 32'd0;
            load_reg      <= 32'd0;
            value_reg     <= 32'd0;
            timeout_flag  <= 1'b0;
            presc_counter <= 8'd0;
        end else begin
            // CPU writes
            if (valid && we) begin
                case (offset)
                    2'b00: begin
                        ctrl_reg <= wdata;
                        if (wdata[0]) value_reg <= load_reg;  // Load VALUE when EN is set
                    end
                    2'b01: load_reg <= wdata;
                    2'b10: ;  // VALUE is read-only
                    2'b11: if (wdata[0]) timeout_flag <= 1'b0;  // Write-1-to-clear TIMEOUT
                endcase
            end

            // Prescaler logic
            if (!en || !presc_en)
                presc_counter <= 8'd0;
            else begin
                if (presc_counter == 8'd0)
                    presc_counter <= presc_div;
                else
                    presc_counter <= presc_counter - 8'd1;
            end

            // Timer countdown logic
            if (en && presc_tick && !(valid && we && offset == 2'b00)) begin
                if (value_reg == 32'd0) begin
                    // At zero: set timeout and reload if periodic
                    timeout_flag <= 1'b1;
                    if (mode) 
                        value_reg <= load_reg;
                end else if (value_reg == 32'd1) begin
                    // One cycle before zero: set timeout flag
                    timeout_flag <= 1'b1;
                    value_reg <= value_reg - 32'd1;
                end else begin
                    // Normal countdown
                    value_reg <= value_reg - 32'd1;
                end
            end
        end
    end

    // Read logic
    always @(*) begin
        case (offset)
            2'b00: rdata = ctrl_reg;
            2'b01: rdata = load_reg;
            2'b10: rdata = value_reg;
            2'b11: rdata = {31'b0, timeout_flag};
            default: rdata = 32'd0;
        endcase
    end

endmodule
