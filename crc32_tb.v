`timescale 1ns/1ps

module crc32_tb();

    // Parameters to match CRC-32 (IEEE)
    localparam CRC_W = 32;
    localparam DATA_W = 8;

    reg clk;
    reg rstn;
    reg valid;
    reg last;
    reg [DATA_W-1:0] data;
    wire ready;
    wire done;
    wire [CRC_W-1:0] crc_out;

    // Instantiate CRC accelerator (reflected mode for CRC-32)
    crc32 #(
        .CRC_WIDTH(CRC_W),
        .DATA_WIDTH(DATA_W),
        .POLY(32'h04C11DB7),
        .POLY_REF(32'hEDB88320),
        .INIT(32'hFFFFFFFF),
        .XOROUT(32'hFFFFFFFF),
        .REFLECT(1)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .valid(valid),
        .last(last),
        .data(data),
        .ready(ready),
        .done(done),
        .crc_out(crc_out)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz-ish for simulation timing
    end

    // Stimulus
    integer i;
    reg [7:0] message [0:8]; // "123456789"
    initial begin
        // ASCII "123456789"
        message[0] = 8'h31;
        message[1] = 8'h32;
        message[2] = 8'h33;
        message[3] = 8'h34;
        message[4] = 8'h35;
        message[5] = 8'h36;
        message[6] = 8'h37;
        message[7] = 8'h38;
        message[8] = 8'h39;

        // reset
        rstn = 0;
        valid = 0;
        last = 0;
        data = 0;
        #20;
        rstn = 1;
        #20;

        // feed bytes, one per cycle (DATA_WIDTH=8)
        for (i = 0; i < 9; i = i + 1) begin
            @(posedge clk);
            valid <= 1;
            data <= message[i];
            last <= (i == 8) ? 1'b1 : 1'b0;
            @(posedge clk);
            // deassert valid for one cycle (simple interface)
            valid <= 0;
            last <= 0;
            data <= 0;
        end

        // wait for done
        wait(done == 1);
        #1;
        $display("CRC-32 computed: 0x%08h", crc_out);
        // expected 0xCBF43926
        if (crc_out === 32'hCBF43926) begin
            $display("PASS: CRC matches expected 0xCBF43926");
        end else begin
            $display("FAIL: CRC mismatch. Expected 0xCBF43926");
        end

        #50;
        $finish;
    end

endmodule

