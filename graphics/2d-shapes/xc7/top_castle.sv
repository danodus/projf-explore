// Project F: 2D Shapes - Top Castle (Arty Pmod VGA)
// (C)2021 Will Green, open source hardware released under the MIT License
// Learn more at https://projectf.io

`default_nettype none
`timescale 1ns / 1ps

module top_castle (
    input  wire logic clk_100m,     // 100 MHz clock
    input  wire logic btn_rst,      // reset button (active low)
    output      logic vga_hsync,    // horizontal sync
    output      logic vga_vsync,    // vertical sync
    output      logic [3:0] vga_r,  // 4-bit VGA red
    output      logic [3:0] vga_g,  // 4-bit VGA green
    output      logic [3:0] vga_b   // 4-bit VGA blue
    );

    // generate pixel clock
    logic clk_pix;
    logic clk_locked;
    clock_gen_480p clock_pix_inst (
       .clk(clk_100m),
       .rst(!btn_rst),  // reset button is active low
       .clk_pix,
       .clk_locked
    );

    // display timings
    localparam CORDW = 16;
    logic signed [CORDW-1:0] sx, sy;
    logic hsync, vsync;
    logic de, frame, line;
    display_timings_480p #(.CORDW(CORDW)) display_timings_inst (
        .clk_pix,
        .rst(!clk_locked),  // wait for pixel clock lock
        .sx,
        .sy,
        .hsync,
        .vsync,
        .de,
        .frame,
        .line
    );

    logic frame_sys;  // start of new frame in system clock domain
    xd xd_frame (.clk_i(clk_pix), .clk_o(clk_100m),
                 .rst_i(1'b0), .rst_o(1'b0), .i(frame), .o(frame_sys));

    // framebuffer (FB)
    localparam FB_WIDTH   = 320;
    localparam FB_HEIGHT  = 180;
    localparam FB_CIDXW   = 4;
    localparam FB_CHANW   = 4;
    localparam FB_SCALE   = 2;
    localparam FB_IMAGE   = "";
    localparam FB_PALETTE = "16_colr_4bit_palette.mem";

    logic fb_we;
    logic signed [CORDW-1:0] fbx, fby;  // framebuffer coordinates
    logic [FB_CIDXW-1:0] fb_cidx;
    logic [FB_CHANW-1:0] fb_red, fb_green, fb_blue;  // colours for display

    framebuffer #(
        .WIDTH(FB_WIDTH),
        .HEIGHT(FB_HEIGHT),
        .CIDXW(FB_CIDXW),
        .CHANW(FB_CHANW),
        .SCALE(FB_SCALE),
        .F_IMAGE(FB_IMAGE),
        .F_PALETTE(FB_PALETTE)
    ) fb_inst (
        .clk_sys(clk_100m),
        .clk_pix,
        .rst_sys(1'b0),
        .rst_pix(1'b0),
        .de(sy >= 60 && sy < 420 && sx >= 0),  // 16:9 letterbox
        .frame,
        .line,
        .we(fb_we),
        .x(fbx),
        .y(fby),
        .cidx(fb_cidx),
        /* verilator lint_off PINCONNECTEMPTY */
        .clip(),
        /* verilator lint_on PINCONNECTEMPTY */
        .red(fb_red),
        .green(fb_green),
        .blue(fb_blue)
    );

    // draw shapes in framebuffer
    localparam SHAPE_CNT=19;  // number of shapes to draw
    logic [4:0] shape_id;     // shape identifier
    logic signed [CORDW-1:0] vx0, vy0, vx1, vy1, vx2, vy2;  // shape coords
    logic signed [CORDW-1:0] fbx_tri, fby_tri;    // tri framebuffer coordinates
    logic signed [CORDW-1:0] fbx_rect, fby_rect;  // rect framebuffer coordinates
    logic drawing, draw_done;  // combined drawing signals
    logic draw_start_tri, drawing_tri, draw_done_tri;  // drawing tri
    logic draw_start_rect, drawing_rect, draw_done_rect;  // drawing rect

    // draw state machine
    enum {IDLE, INIT, DRAW, DONE} state;
    always_ff @(posedge clk_100m) begin
        case (state)
            INIT: begin  // register coordinates and colour
                state <= DRAW;
                case (shape_id)
                    5'd0: begin  // main building
                        draw_start_rect <= 1;
                        vx0 <=  60; vy0 <=  70;
                        vx1 <= 190; vy1 <= 120;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd1: begin  // drawbridge
                        draw_start_rect <= 1;
                        vx0 <= 110; vy0 <=  90;
                        vx1 <= 140; vy1 <= 120;
                        fb_cidx <= 4'h4;  // brown
                    end
                    5'd2: begin  // arch left
                        draw_start_tri <= 1;
                        vx0 <= 110; vy0 <=  90;
                        vx1 <= 120; vy1 <=  90;
                        vx2 <= 110; vy2 <= 100;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd3: begin  // arch right
                        draw_start_tri <= 1;
                        vx0 <= 130; vy0 <=  90;
                        vx1 <= 140; vy1 <=  90;
                        vx2 <= 140; vy2 <= 100;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd4: begin  // left tower
                        draw_start_rect <= 1;
                        vx0 <=  40; vy0 <=  45;
                        vx1 <=  60; vy1 <= 120;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd5: begin  // middle tower
                        draw_start_rect <= 1;
                        vx0 <= 110; vy0 <=  40;
                        vx1 <= 140; vy1 <=  70;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd6: begin  // right tower
                        draw_start_rect <= 1;
                        vx0 <= 190; vy0 <=  45;
                        vx1 <= 210; vy1 <= 120;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd7: begin  // left roof
                        draw_start_tri <= 1;
                        vx0 <=  50; vy0 <=  25;
                        vx1 <=  65; vy1 <=  45;
                        vx2 <=  35; vy2 <=  45;
                        fb_cidx <= 4'h2;  // dark-purple
                    end
                    5'd8: begin  // middle roof
                        draw_start_tri <= 1;
                        vx0 <= 125; vy0 <=  10;
                        vx1 <= 145; vy1 <=  40;
                        vx2 <= 105; vy2 <=  40;
                        fb_cidx <= 4'h2;  // dark-purple
                    end
                    5'd9: begin  // right roof
                        draw_start_tri <= 1;
                        vx0 <= 200; vy0 <=  25;
                        vx1 <= 215; vy1 <=  45;
                        vx2 <= 185; vy2 <=  45;
                        fb_cidx <= 4'h2;  // dark-purple
                    end
                    5'd10: begin  // left window
                        draw_start_rect <= 1;
                        vx0 <=  46; vy0 <=  50;
                        vx1 <=  54; vy1 <=  65;
                        fb_cidx <= 4'h1;  // dark blue
                    end
                    5'd11: begin  // middle window
                        draw_start_rect <= 1;
                        vx0 <= 120; vy0 <=  45;
                        vx1 <= 130; vy1 <=  65;
                        fb_cidx <= 4'h1;  // dark blue
                    end
                    5'd12: begin  // right window
                        draw_start_rect <= 1;
                        vx0 <= 196; vy0 <=  50;
                        vx1 <= 204; vy1 <=  65;
                        fb_cidx <= 4'h1;  // dark blue
                    end
                    5'd13: begin  // battlement 1
                        draw_start_rect <= 1;
                        vx0 <=  63; vy0 <=  62;
                        vx1 <=  72; vy1 <=  70;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd14: begin  // battlement 2
                        draw_start_rect <= 1;
                        vx0 <=   80; vy0 <=  62;
                        vx1 <=   89; vy1 <=  70;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd15: begin  // battlement 3
                        draw_start_rect <= 1;
                        vx0 <=  97; vy0 <=  62;
                        vx1 <= 106; vy1 <=  70;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd16: begin  // battlement 4
                        draw_start_rect <= 1;
                        vx0 <= 144; vy0 <=  62;
                        vx1 <= 153; vy1 <=  70;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd17: begin  // battlement 5
                        draw_start_rect <= 1;
                        vx0 <= 161; vy0 <=  62;
                        vx1 <= 170; vy1 <=  70;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    5'd18: begin  // battlement 6
                        draw_start_rect <= 1;
                        vx0 <= 178; vy0 <=  62;
                        vx1 <= 187; vy1 <=  70;
                        fb_cidx <= 4'h5;  // dark grey
                    end
                    default: begin  // should never occur
                        draw_start_tri <= 1;
                        vx0 <=   10; vy0 <=   10;
                        vx1 <=   10; vy1 <=   30;
                        vx2 <=   20; vy2 <=   20;
                        fb_cidx <= 4'h7;  // white
                    end
                endcase
            end
            DRAW: begin
                draw_start_rect <= 0;
                draw_start_tri <= 0;
                if (draw_done) begin
                    if (shape_id == SHAPE_CNT-1) begin
                        state <= DONE;
                    end else begin
                        shape_id <= shape_id + 1;
                        state <= INIT;
                    end
                end
            end
            DONE: state <= DONE;
            default: if (frame_sys) state <= INIT;  // IDLE
        endcase
    end

    draw_triangle_fill #(.CORDW(CORDW)) draw_triangle_inst (
        .clk(clk_100m),
        .rst(1'b0),
        .start(draw_start_tri),
        .oe(1'b1),
        .x0(vx0),
        .y0(vy0),
        .x1(vx1),
        .y1(vy1),
        .x2(vx2),
        .y2(vy2),
        .x(fbx_tri),
        .y(fby_tri),
        .drawing(drawing_tri),
        /* verilator lint_off PINCONNECTEMPTY */
        .complete(),
        /* verilator lint_on PINCONNECTEMPTY */
        .done(draw_done_tri)
    );

    draw_rectangle_fill #(.CORDW(CORDW)) draw_rectangle_inst (
        .clk(clk_100m),
        .rst(1'b0),
        .start(draw_start_rect),
        .oe(1'b1),
        .x0(vx0),
        .y0(vy0),
        .x1(vx1),
        .y1(vy1),
        .x(fbx_rect),
        .y(fby_rect),
        .drawing(drawing_rect),
        /* verilator lint_off PINCONNECTEMPTY */
        .complete(),
        /* verilator lint_on PINCONNECTEMPTY */
        .done(draw_done_rect)
    );

    // write to framebuffer when drawing
    always_ff @(posedge clk_100m) begin
        drawing <= drawing_tri || drawing_rect;
        fb_we <= drawing;
        draw_done <= draw_done_tri || draw_done_rect;
        fbx <= drawing_tri ? fbx_tri : fbx_rect;
        fby <= drawing_tri ? fby_tri : fby_rect;
    end

    // reading from FB takes one cycle: delay display signals to match
    logic hsync_p1, vsync_p1;
    always_ff @(posedge clk_pix) begin
        hsync_p1 <= hsync;
        vsync_p1 <= vsync;
    end

    // background colour (sy doesn't account for letterbox)
    logic [11:0] bg_colr;
    logic show_bg;
    always_ff @(posedge clk_pix) begin
        if (line) begin
            if      (sy ==   0) bg_colr <= 12'h000;
            else if (sy ==  60) bg_colr <= 12'h239;
            else if (sy == 130) bg_colr <= 12'h24A;
            else if (sy == 175) bg_colr <= 12'h25B;
            else if (sy == 210) bg_colr <= 12'h26C;
            else if (sy == 240) bg_colr <= 12'h27D;
            else if (sy == 265) bg_colr <= 12'h29E;
            else if (sy == 285) bg_colr <= 12'h2BF;
            else if (sy == 300) bg_colr <= 12'h260;
            else if (sy == 420) bg_colr <= 12'h000;
        end
        show_bg <= (de && {fb_red,fb_green,fb_blue} == 0);
    end

    // VGA output
    always_ff @(posedge clk_pix) begin
        vga_hsync <= hsync_p1;
        vga_vsync <= vsync_p1;
        vga_r <= show_bg ? bg_colr[11:8] : fb_red;
        vga_g <= show_bg ? bg_colr[7:4]  : fb_green;
        vga_b <= show_bg ? bg_colr[3:0]  : fb_blue;
    end
endmodule