`define MAX_LEN 128
`define ST_INIT 0
`define ST_CLEAR 1
`define ST_DISPLAY 2
`define ST_IDLE 3

`define INITIAL_WAIT 750000
`define PULSE_TIME 12
`define WAIT1 205000
`define WAIT2 5000
`define WAIT3 2000
`define WAIT4 2000
`define NUM_LCD_INIT_STEPS 9

`define CMD_STATE_IDLE 0
`define CMD_STATE_WORKING 1
`define CMD_READY 1
`define CMD_BUSY 0


//`define INIT_WAITS {`INITIAL_WAIT, `PULSE_TIME, `WAIT1, \
  //          `PULSE_TIME, `WAIT2, `PULSE_TIME, `WAIT3, `PULSE_TIME, `WAIT3}

	 
`define INIT_WAITS \
            lcd_init_waits [0] = `INITIAL_WAIT ;\
				lcd_init_waits [1] = `INITIAL_WAIT + `PULSE_TIME ;\
				lcd_init_waits [2] = `INITIAL_WAIT + `PULSE_TIME + `WAIT1 ;\
				lcd_init_waits [3] = `INITIAL_WAIT + `PULSE_TIME + `WAIT1 + `PULSE_TIME ;\
				lcd_init_waits [4] = `INITIAL_WAIT + `PULSE_TIME + `WAIT1 + `PULSE_TIME + `WAIT2;\
				lcd_init_waits [5] = `INITIAL_WAIT + `PULSE_TIME + `WAIT1 + `PULSE_TIME + `WAIT2 + `PULSE_TIME ;\
				lcd_init_waits [6] = `INITIAL_WAIT + `PULSE_TIME + `WAIT1 + `PULSE_TIME + `WAIT2 + `PULSE_TIME + `WAIT3 ;\
				lcd_init_waits [7] = `INITIAL_WAIT + `PULSE_TIME + `WAIT1 + `PULSE_TIME + `WAIT2 + `PULSE_TIME + `WAIT3 + `PULSE_TIME ;\
				lcd_init_waits [8] = `INITIAL_WAIT + `PULSE_TIME + `WAIT1 + `PULSE_TIME + `WAIT2 + `PULSE_TIME + `WAIT3 + `PULSE_TIME + `WAIT4 ;

				
`define NUM_CMD_PHASES 5				
`define NIBBLE_PULSE_WIDTH 15
`define INTER_NIBBLE_WIDTH 50
`define INTER_CMD_WIDTH 4000

`define COMMAND_TIMING { 0, `NIBBLE_PULSE_WIDTH, `INTER_NIBBLE_WIDTH, `NIBBLE_PULSE_WIDTH, `INTER_CMD_WIDTH}
`define INIT_CMDS \
    cmd_waits[0] = 1; \
	cmd_waits[1] = 1 + `NIBBLE_PULSE_WIDTH;\
	cmd_waits[2] = 1 + `NIBBLE_PULSE_WIDTH + `INTER_NIBBLE_WIDTH;\
	cmd_waits[3] = 1 + `NIBBLE_PULSE_WIDTH + `INTER_NIBBLE_WIDTH + `NIBBLE_PULSE_WIDTH;\
	cmd_waits[4] = 1 + `NIBBLE_PULSE_WIDTH + `INTER_NIBBLE_WIDTH + `NIBBLE_PULSE_WIDTH + `INTER_CMD_WIDTH;

`define CMD 1'b0
`define DATA 1'b1	
`define CLEAR_CMD 8'b1
`define FUNCTION_SET 8'h28
`define DISPLAY_ON 8'h0c
`define ENTRY_MODE_SET 8'b110

`define SET_DD_ADDR 8'h80