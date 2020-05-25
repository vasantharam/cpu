`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:50:50 04/05/2020 
// Design Name: 
// Module Name:    hello 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defs.vh"
/*
 FSM states
    init (on reset)
    clear display ( fall through after init, or button press)
    display text (up_button_release, or display change indication)
*/

/*
   left button :- current_pointer--, display_change indication
    right_button :- current_pointer++, display_change_indication
    up_button:- clear_display
*/

module hello(clk, LED_F12, LCD_E, LCD_RS, LCD_RW, DB, SF_CE0,
                  BTN_NORTH, BTN_SOUTH, BTN_WEST, BTN_EAST
    );

input clk, BTN_NORTH, BTN_SOUTH, BTN_WEST, BTN_EAST;
output reg LED_F12, LCD_RS, LCD_E, LCD_RW, SF_CE0;
output reg [3:0] DB;

reg [0:(`MAX_LEN*8)-1] first_line = "Hello World. This is a verilog module displaying on the LCD.                                                                   ";
reg [0:(`MAX_LEN*8)-1] second_line = "Second line of text. This is a string stored as a bit array.                                                                   ";

reg [31:0] lcd_init_waits[`NUM_LCD_INIT_STEPS-1:0]; // = `INIT_WAITS;
reg [31:0] cmd_waits [ `NUM_CMD_PHASES-1:0 ]; //= `COMMAND_TIMING;

reg [1:0] disp_state = `ST_INIT;
reg [1:0] disp_state_nxt = `ST_INIT;
reg [31:0] init_counter;
reg [31:0] cmd_counter;
reg [13:0] btn_counter;
reg [31:0] wait_after_clear;
reg [7:0] current_command;
reg [8:0] display_init_commands [0:3] ;
reg [8:0] send_data_commands [17*2-1:0] ;

reg [3:0] current_init_step;
reg [2:0] current_cmd_step;

reg clear_display;
reg display_change;
reg btn_north_detected, btn_east_detected, btn_west_detected;
reg btn_east, btn_west, btn_north;

reg [5:0] cur_ptr;

integer loop;
reg cmd_ready;
reg cmd_or_data; reg [7:0] cmd; reg cmd_valid;


reg [1:0] cmd_state;
reg [1:0] cmd_state_nxt;

reg write;
reg [7:0] addr;
wire [7:0] din;
wire [7:0] dout;

ram i_ram(clk, write, addr, din, dout);

initial
begin
    disp_state <= `ST_INIT;
    disp_state_nxt <= `ST_INIT;
    clear_display <= 0;
    display_change <= 0;
    cur_ptr <= 0;
    init_counter <= 0;
    cmd_counter <=0;
    LCD_E <= 0;
    DB <= 3'h3;
    current_init_step <=0;
    current_cmd_step <=0;
    current_command <= 0;
    `INIT_WAITS
    `INIT_CMDS
    loop <=0;
    LED_F12 <= 0;
    wait_after_clear <= 0;
    cmd_state <= `CMD_STATE_IDLE;
    cmd_state_nxt <= `CMD_STATE_IDLE;
    cmd_ready <= `CMD_READY;
    cmd_valid <= 0;
    btn_east <= 0;
    btn_west <= 0;
    btn_north <= 0;
    btn_east_detected <= 0;
    btn_west_detected <= 0;   
    btn_north_detected <= 0;    
    write <=0; 
    addr <=0;
            
            display_init_commands[0] <= {`CMD, `FUNCTION_SET};
            display_init_commands[1] <= {`CMD, `ENTRY_MODE_SET}; 
            display_init_commands[2] <= {`CMD, `DISPLAY_ON}; 
            display_init_commands[3] <= {`CMD, `CLEAR_CMD};
end



always @(posedge clk)
begin
    if (btn_north != BTN_NORTH)
    begin
        btn_north_detected <= 1;
        btn_north <= BTN_NORTH;
    end
    else btn_north_detected <= 0;
    if (btn_east != BTN_EAST)
    begin
        btn_east_detected <= 1;
        btn_east <= BTN_EAST;
    end
    else btn_east_detected <= 0;
    if (btn_west != BTN_WEST)
    begin
        btn_west_detected <= 1;
        btn_west <= BTN_WEST;
    end
    else btn_west_detected <= 0;
        
    if (disp_state == `ST_IDLE)
    begin
        if (btn_east_detected == 1 && btn_east == 1)
        begin
            display_change <= 1;
            cur_ptr = cur_ptr + 6'b1;
        end
        if (btn_west_detected == 1 && btn_west == 1)
        begin
            display_change <= 1;
            if (cur_ptr != 0) cur_ptr = cur_ptr - 6'b1;
        end
        if (btn_north_detected == 1 && btn_north == 1)
        begin
            clear_display <= 1;
        end
    end
    if (display_change == 1)
    begin
        LED_F12 <= ~LED_F12;
        display_change <= 0;
    end
    if (clear_display == 1)
        clear_display <= 0;
end

task write_command_nibble;
    input [3:0] cmd;
    begin
        LCD_RW <= 0;
        DB = cmd;
        LCD_E <=1;    

     end
endtask

task write_pause;
    LCD_E <= 0;
endtask

task write_cmd_or_data(input [31:0] index, input cmd_or_data_, input [7:0] cmd_);
    begin
    if ((cmd_ready != `CMD_BUSY) && (cmd_valid == 0))
    begin
        if (cmd_ready == `CMD_READY)
        begin
            cmd_or_data <= cmd_or_data_;
            cmd <= cmd_;
            cmd_valid <= 1;
        end
    end
    if ((cmd_ready == `CMD_BUSY) && (cmd_valid == 1)) 
    begin
        cmd_valid <= 0;
        current_command <= current_command + 1;
    end
    end
endtask



always @(posedge clk)
begin
    case (cmd_state)
        `CMD_STATE_IDLE:
        begin
            if (cmd_valid == 1)
            begin
                cmd_state_nxt <= `CMD_STATE_WORKING;
                cmd_ready <= `CMD_BUSY;
            end
            cmd_counter <= 0;
            current_cmd_step <= 0;
        end
        `CMD_STATE_WORKING:        
        begin
            LCD_RS <= cmd_or_data;
            if (cmd_counter == cmd_waits [ current_cmd_step] )
            begin
                case (current_cmd_step)
                    0: write_command_nibble( cmd [7:4] );
                    1: LCD_E <= 0;
                    2: write_command_nibble( cmd [3:0] );
                    3: LCD_E <= 0;
                    4: 
                        begin
                            /* Indicate we are done */
                            cmd_state_nxt <= `CMD_STATE_IDLE;
                            cmd_ready <= `CMD_READY;
                            
                        end
                endcase
                current_cmd_step <= (current_cmd_step + 3'h1);
            end 

         
            cmd_counter <= cmd_counter + 1;
        end
        
    endcase
    cmd_state <= cmd_state_nxt;

end
 /* Send a command FSM */

/* Display handler */
always @(posedge clk)
begin
    case (disp_state)
        `ST_INIT:
        begin
            
            SF_CE0 <= 1;
            if (init_counter == lcd_init_waits[current_init_step]) 
            begin
//                LCD_E <= ~LCD_E;
                if (current_init_step != `NUM_LCD_INIT_STEPS-1)
                    current_init_step <= (current_init_step + 4'h1);                
            end
            if (current_init_step == `NUM_LCD_INIT_STEPS-1) 
            begin
                disp_state_nxt <= `ST_CLEAR;
                current_init_step <= 0;
                init_counter <= 0;
            end
            else 
            begin
                init_counter <= init_counter + 1;    
            end
                
            end 
        `ST_CLEAR:
        begin
            if (current_command < 4) 
                write_cmd_or_data( current_command, display_init_commands[current_command][8], display_init_commands[current_command][7:0]  );

            if ((current_command==4) && (cmd_ready != `CMD_BUSY) && wait_after_clear <= 82000 ) wait_after_clear <= wait_after_clear + 1;
            if (wait_after_clear > 82000) begin
                wait_after_clear <=0;
                current_command <= 0;
                disp_state_nxt <= `ST_DISPLAY;
            end
            
        end
        `ST_DISPLAY:
        begin
        /*
            set address to line 1.
            write first line [cur_ptr to cur_ptr + 15]
            set address to line 2.
            write second line [ cur ptr to cur ptr + 15 ]
            */
            send_data_commands[0] <= {`CMD, `SET_DD_ADDR};
            for (loop = 1; loop < 17; loop = loop + 1)
            begin
                send_data_commands[loop] <= {`DATA, first_line[(loop+cur_ptr)*8+:8] };
            end
            send_data_commands[17] <= {`CMD, `SET_DD_ADDR | 8'h40};
            for (loop = 18; loop < 34; loop = loop + 1)
            begin
                send_data_commands[loop] <= {`DATA, second_line[(loop-17+cur_ptr)*8+:8] };
            end
            addr <= current_command;
            if (current_command < 34) 
            if (send_data_commands[current_command][8] == `CMD)
                write_cmd_or_data(current_command, send_data_commands[current_command][8], send_data_commands[current_command][7:0]);
            else
                write_cmd_or_data(current_command, send_data_commands[current_command][8], dout); //send_data_commands[current_command][7:0]);
            
            if ( (current_command==34) && (cmd_ready != `CMD_BUSY) && (cmd_valid == 0) ) 
            begin
                current_command <= 0;
                disp_state_nxt <= `ST_IDLE; 
            end

                
        end
        `ST_IDLE:
        begin
            if (clear_display) disp_state_nxt <= `ST_CLEAR;
            if (display_change) disp_state_nxt <= `ST_DISPLAY;
        end
        default:
        begin
        end
          
    endcase
    disp_state <= disp_state_nxt;

end


endmodule

