module gpio_out_v2 (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    output wire [31:0] gpio_out
);

    reg [31:0] gpio_data_reg;
    reg [31:0] gpio_dir_reg;
    reg [31:0] gpio_read_reg;

    wire [1:0] reg_sel = addr[3:2];

    localparam DATA_REG = 2'b00;
    localparam DIR_REG  = 2'b01;
    localparam READ_REG = 2'b10;

    always @(posedge clk) begin
        if (rst) begin
            gpio_data_reg <= 32'h00000000;
            gpio_dir_reg  <= 32'h00000000;
        end else if (valid && we) begin
            case (reg_sel)
                DATA_REG: gpio_data_reg <= wdata;
                DIR_REG:  gpio_dir_reg  <= wdata;
                default:  ;
            endcase
        end
    end

    assign gpio_out = gpio_data_reg & gpio_dir_reg;

    always @(*) begin
        gpio_read_reg = gpio_data_reg & gpio_dir_reg;
    end

    always @(*) begin
        case (reg_sel)
            DATA_REG: rdata = gpio_data_reg;
            DIR_REG:  rdata = gpio_dir_reg;
            READ_REG: rdata = gpio_read_reg;
            default:  rdata = 32'h00000000;
        endcase
    end

endmodule
