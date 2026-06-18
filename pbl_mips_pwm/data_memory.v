`timescale 1ns / 1ps

module data_memory (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mem_write_en,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    input  wire [7:0]  switches,
    output wire        pwm_out,
    output reg  [31:0] read_data
);
    reg [31:0] ram [0:63];
    wire [31:0] ram_out;
    assign ram_out = ram[addr[7:2]];

    reg [7:0] pwm_duty;
    reg       pwm_en;

    pwm_controller u_pwm (
        .clk(clk),
        .rst_n(rst_n),
        .enable(pwm_en),
        .duty_cycle(pwm_duty),
        .pwm_out(pwm_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_duty <= 8'h00;
            pwm_en <= 1'b0;
        end else if (mem_write_en) begin
            case (addr)
                32'h00000090: ;
                32'h00000098: pwm_duty <= write_data[7:0];
                32'h0000009c: pwm_en <= write_data[0];
                default:      ram[addr[7:2]] <= write_data;
            endcase
        end
    end

    always @(*) begin
        case (addr)
            32'h00000090: read_data = {24'b0, switches};
            32'h00000098: read_data = 32'b0;
            32'h0000009c: read_data = 32'b0;
            default:      read_data = ram_out;
        endcase
    end
endmodule
