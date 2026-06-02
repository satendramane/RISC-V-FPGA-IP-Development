module timer (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);

    reg [31:0] ctrl_reg;
    reg [31:0] load_reg;
    reg [31:0] value_reg;
    reg        timeout_flag;

    wire        en        = ctrl_reg[0];
    wire        mode      = ctrl_reg[1];
    wire        presc_en  = ctrl_reg[2];
    wire [7:0]  presc_div = ctrl_reg[15:8];

    reg [7:0] presc_cnt;

    wire [1:0] reg_sel = addr[3:2];

    localparam CTRL_REG   = 2'b00;
    localparam LOAD_REG   = 2'b01;
    localparam VALUE_REG  = 2'b10;
    localparam STATUS_REG = 2'b11;

    // CPU write takes priority
    wire cpu_clear_timeout = valid && we && 
                             (reg_sel == STATUS_REG) && wdata[0];

    always @(posedge clk) begin
        if (rst) begin
            ctrl_reg     <= 32'h0;
            load_reg     <= 32'h0;
            value_reg    <= 32'h0;
            timeout_flag <= 1'b0;
            presc_cnt    <= 8'h0;
        end else begin

            // CPU write logic
            if (valid && we) begin
                case (reg_sel)
                    CTRL_REG: ctrl_reg <= wdata;
                    LOAD_REG: load_reg <= wdata;
                    default: ;
                endcase
            end

            // Timeout flag — CPU clear has priority over timer set
            if (cpu_clear_timeout)
                timeout_flag <= 1'b0;
            else if (en && value_reg == 0)
                timeout_flag <= 1'b1;

            // Timer countdown logic
            if (en) begin
                if (value_reg == 0) begin
                    if (mode)
                        value_reg <= load_reg;
                end else begin
                    if (presc_en) begin
                        if (presc_cnt == presc_div) begin
                            presc_cnt <= 8'h0;
                            value_reg <= value_reg - 1;
                        end else
                            presc_cnt <= presc_cnt + 1;
                    end else
                        value_reg <= value_reg - 1;
                end
            end else begin
                value_reg <= load_reg;
                presc_cnt <= 8'h0;
            end

        end
    end

    // Read logic
    always @(*) begin
        case (reg_sel)
            CTRL_REG:   rdata = ctrl_reg;
            LOAD_REG:   rdata = load_reg;
            VALUE_REG:  rdata = value_reg;
            STATUS_REG: rdata = {31'b0, timeout_flag};
            default:    rdata = 32'h0;
        endcase
    end

endmodule
