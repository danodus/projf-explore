// Project F Library - 1280x720p60 TMDS Clock Generation (GW2A)
// Copyright Will Green, open source hardware released under the MIT License
// Learn more at https://projectf.io

`default_nettype none
`timescale 1ns / 1ps

// Generate 74.25 MHz (1280x720 60Hz) with 27 MHz input clock

module clock_720p (
    input  wire logic clk_27m,        // input clock (27 MHz)
    input  wire logic rst,            // reset
    output      logic clk_pix,        // pixel clock
    output      logic clk_pix_5x,     // 5x clock for 10:1 DDR SerDes
    output      logic clk_pix_locked  // pixel clock locked?
    );

    logic locked;  // unsynced lock signal

    wire clkoutp_o;
    wire clkoutd_o;
    wire clkoutd3_o;
    wire gw_gnd;

    assign gw_gnd = 1'b0;

    rPLL #(
        .FCLKIN("27"),
        .DYN_IDIV_SEL("false"),
        .IDIV_SEL(3),
        .DYN_FBDIV_SEL("false"),
        .FBDIV_SEL(54),
        .DYN_ODIV_SEL("false"),
        .ODIV_SEL(2),
        .PSDA_SEL("0000"),
        .DYN_DA_EN("true"),
        .DUTYDA_SEL("1000"),
        .CLKOUT_FT_DIR(1'b1),
        .CLKOUTP_FT_DIR(1'b1),
        .CLKOUT_DLY_STEP(0),
        .CLKOUTP_DLY_STEP(0),
        .CLKFB_SEL("internal"),
        .CLKOUT_BYPASS("false"),
        .CLKOUTP_BYPASS("false"),
        .CLKOUTD_BYPASS("false"),
        .DYN_SDIV_SEL(2),
        .CLKOUTD_SRC("CLKOUT"),
        .CLKOUTD3_SRC("CLKOUT"),
        .DEVICE("GW2AR-18")
    ) rpll_inst (
        .CLKOUT(clk_pix_5x), // 371.25 MHz
        .LOCK(locked),
        .CLKOUTP(clkoutp_o),
        .CLKOUTD(clkoutd_o),
        .CLKOUTD3(clkoutd3_o),
        .RESET(rst),
        .RESET_P(gw_gnd),
        .CLKIN(clk_27m),
        .CLKFB(gw_gnd),
        .FBDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .IDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .ODSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .PSDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .DUTYDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .FDLY({gw_gnd,gw_gnd,gw_gnd,gw_gnd})
    );

    CLKDIV #(
        .DIV_MODE("5")
    ) clkdiv_inst (
        .CLKOUT(clk_pix),
        .HCLKIN(clk_pix_5x),
        .RESETN(1'b1),
        .CALIB(1'b0)
    );

    // ensure clock lock is synced with pixel clock
    logic locked_sync_0;
    always_ff @(posedge clk_pix) begin
        locked_sync_0 <= locked;
        clk_pix_locked <= locked_sync_0;
    end
endmodule
