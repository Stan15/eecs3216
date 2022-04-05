 `timescale 1ns / 1ps

// image generator of a road and a sky 640x480 @ 60 fps

////////////////////////////////////////////////////////////////////////
module Top(
	
	 //////////// 50MHz CLOCK //////////
   input 	MAX10_CLK1_50,
	input 	ADC_CLK_10,
   input 	MAX10_CLK2_50,
	
	////////////// VGA /////////////////
	output VGA_HS,      		// horizontal sync
	output VGA_VS,	     		// vertical sync
	output [3:0] VGA_R,
	output [3:0] VGA_G,	
	output [3:0] VGA_B,
	
   //////////// 7SEG //////////
   output		     [7:0]		HEX0,
   output		     [7:0]		HEX1,
   output		     [7:0]		HEX2,
   output		     [7:0]		HEX3,
   output		     [7:0]		HEX4,
   output		     [7:0]		HEX5,
	
   //////////// Push Buttons //////////
   input 		     [1:0]		KEY,

   //////////// LED //////////
   output		     [9:0]		LEDR,

   //////////// SW //////////
   input 		     [9:0]		SW,

   //////////// Accelerometer ports //////////
   output		          		GSENSOR_CS_N,
   input 		     [2:1]		GSENSOR_INT,
   output		          		GSENSOR_SCLK,
   inout 		          		GSENSOR_SDI,
   inout 		          		GSENSOR_SDO
);
	parameter COLR_BITS = 12;
	//===========VGA Controller Logic==========================
	localparam H_RES=640;			// horizontal screen resolution
	localparam V_RES=480;			// vertical screen resolution
	localparam SCREEN_CORDW = 16; // # of bits used to store screen coordinates
	
	// slow down 50MHz clock to 25MHz and use 25MHz clock (clk_pix) to drive display
	logic clk_pix;
	reg reset = 0;  // for PLL
	ip (.areset(reset), .inclk0(MAX10_CLK1_50), .c0(clk_pix), .locked());

	// go through the display pixel-by-pixel
	logic [SCREEN_CORDW-1:0] screen_x, screen_y;
	logic hsync, vsync, de, frame, screen_line;
	display_480p #(
		.H_RES(H_RES),
		.V_RES(V_RES)
	) (
		.clk_pix,
		.rst(0), 
		.hsync,
		.vsync, 
		.de, 					// (data-enabled) signal asserted when we are in a region of screen which will be visible (i.e. we are not in blanking region)
		.frame, 				// signal asserted when we begin a new frame
		.line(screen_line),				// signal asserted when we begin a new line in a frame
		.screen_x,	 		// (x-coord) indicates what point of the frame we are currently rendering
		.screen_y			// (y-coord)
	);
	//===========End of VGA Controller Logic===========

	//======Accelerometer Logic===============
	
	//===== Declarations
   localparam SPI_CLK_FREQ  = 200;  // SPI Clock (Hz)
   localparam UPDATE_FREQ   = 1;    // Sampling frequency (Hz)

   // clks and reset
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;

   // output data
   wire data_update;
   wire [15:0] data_x, data_y;

	//===== Phase-locked Loop (PLL) instantiation. Code was copied from a module
	//      produced by Quartus' IP Catalog tool.
	pll pll_inst (
		.inclk0 ( MAX10_CLK1_50 ),
		.c0 ( clk ),                 // 25 MHz, phase   0 degrees
		.c1 ( spi_clk ),             //  2 MHz, phase   0 degrees
		.c2 ( spi_clk_out )          //  2 MHz, phase 270 degrees
		);

	//===== Instantiation of the spi_control module which provides the logic to 
	//      interface to the accelerometer.
	spi_control #(     // parameters
			.SPI_CLK_FREQ   (SPI_CLK_FREQ),
			.UPDATE_FREQ    (UPDATE_FREQ))
		spi_ctrl (      // port connections
			.reset_n    (reset_n),
			.clk        (clk),
			.spi_clk    (spi_clk),
			.spi_clk_out(spi_clk_out),
			.data_update(data_update),
			.data_x     (data_x),
			.data_y     (data_y),
			.SPI_SDI    (GSENSOR_SDI),
			.SPI_SDO    (GSENSOR_SDO),
			.SPI_CSN    (GSENSOR_CS_N),
			.SPI_CLK    (GSENSOR_SCLK),
			.interrupt  (GSENSOR_INT)
		);
		
		
	//===== Main block
	//      To make the module do something visible, the 16-bit data_x is 
	//      displayed on four of the HEX displays in hexadecimal format.

	wire slowclk;
	reg [15:0] data_X, data_Y;
	AccelClockDivider acd( spi_clk , slowclk);
		
	// Slows down accelerometer clock
	always@( posedge slowclk) 
	begin
		data_X = data_x; 
		data_Y = data_y;
	end
	
	//======End of Accelerometer Logic===============
	
	//==========Spaceship Logic===================
	localparam SPACESHIP_FILE = "spaceship.mem";
	localparam SPACESHIP_WIDTH = 17;
	localparam SPACESHIP_HEIGHT = 18;
	
	//-----spaceship position controller (replace code here with code for accelerometer controlling spaceship_x and spaceship_y value. for better modularity, the controller can be implemented in its own module)----
	logic [SCREEN_CORDW-1:0] spaceship_x = 16'd300;
	logic [SCREEN_CORDW-1:0] spaceship_y = 16'd240;
	reg [SCREEN_CORDW-1:0] spaceship_x_default = 16'd300; //for resetting the spaceship_x
	reg [SCREEN_CORDW-1:0] spaceship_y_default = 16'd240; //for resetting the spaceship_y
	
	//-----asteroid position controller-----
	logic [SCREEN_CORDW-1:0] asteroid_x = 16'd70;
	logic [SCREEN_CORDW-1:0] asteroid_y = 16'd270;
	reg [SCREEN_CORDW-1:0] asteroid_x_default = 16'd70; //for resetting the asteroid_x
	reg [SCREEN_CORDW-1:0] asteroid_y_default = 16'd270; //for resetting the asteroid_y
	
	// Pressing KEY0 freezes the accelerometer's output
	assign reset_n = KEY[0];
	
	always_ff @(posedge clk_pix) begin
		
		// SPACESHIP MOVEMENT
		if(~reset_n || collision)
		begin
			spaceship_x <= spaceship_x_default;
			spaceship_y <= spaceship_y_default;
		end
		else
		begin
			//spaceship_x direction
			if(data_X [10:7] >= 1 && data_X [10:7] <= 3 && frame && spaceship_x < H_RES-40) //Shifting spaceship_x to the right
			begin
				spaceship_x <= spaceship_x - 2;
			end
			else if(data_X [10:7] >=12 && data_X [10:7] <= 14 && frame && spaceship_x > 0) //Shifting spaceship_x to the left
			begin
				spaceship_x <= spaceship_x + 2;
			end

			//spaceship_y direction
			if(data_Y [10:7] >= 1 && data_Y [10:7] <= 3  && frame && spaceship_y > 0) //Shifting spaceship_y to the up
			begin
				spaceship_y <= spaceship_y + 2 ;
			end
			else if(data_Y [10:7] >= 12 && data_Y [10:7] <= 14 && frame && spaceship_y < V_RES-39) //Shifting spaceship_y to the down
			begin
				spaceship_y <= spaceship_y - 2;
			end
		end
		
		//ASTEROID MOVEMENT
		if(~reset_n || collision)
		begin
			asteroid_x <= spaceship_x_default;
			asteroid_y <= spaceship_y_default;
		end
		else
		begin
			//asteroid_x direction
			if( frame && SW[9] ) // update on every refresh of the screen if obstacles are enabled on sw9
				if( asteroid_y >= V_RES ) 	asteroid_y = 0;
				else if( asteroid_x >= H_RES ) 	asteroid_x = 0;
				else	begin							asteroid_y <= asteroid_y + 3; asteroid_x <= asteroid_x + 1; end
		end
		
	end

//	TripleDigitDisplay(data_Y[7:0], HEX3, HEX4, HEX5); // display x and y coordinates of the spaceship
//	TripleDigitDisplay(data_X[7:0], HEX0, HEX1, HEX2);
	
	//----------------------------------------
	
	// spaceship pixel data generator
	logic [COLR_BITS-1:0] spaceship_pixel;
	logic spaceship_drawing;			// flag indicating if spaceship pixel should be drawn the current screen position.
	sprite #(
		.FILE(SPACESHIP_FILE),
		.WIDTH(SPACESHIP_WIDTH),
		.HEIGHT(SPACESHIP_HEIGHT),
		.SCALE(2), 							// it is scaled by 4x its original size
		.SCREEN_CORDW(SCREEN_CORDW),
		.COLR_BITS(COLR_BITS)
	) spaceship(
		.clk_pix, .rst(0), .en(1),
		.screen_line,
		.screen_x, .screen_y,
		.sprite_x(spaceship_x), .sprite_y(spaceship_y),
		.pixel(spaceship_pixel),
		.drawing(spaceship_drawing)
	);
	//======End of Spaceship Logic===============
	
	//==========Obstacle Logic===================
	localparam OBSTACLE_FILE = "obstacle.mem";
	localparam OBSTACLE_WIDTH = 4;
	localparam OBSTACLE_HEIGHT = 4;
	
	// i'm creating just one obstacle for testing purposes. we should figure out how to create
	// multiple obstacles and make sure that they are spaced out. might require using generate blocks in some way.
	logic [SCREEN_CORDW-1:0] obstacle_1_x, obstacle_1_y;
	logic [9:0] [3:0]obstacle_1_drawing;			// flag indicating if spaceship pixel should be drawn the current screen position.
	logic [9:0] obstacle_1_pixel;
	
	genvar i;
	generate
		for( i=0; i<10; i=i+1)begin: asteroid				
			sprite #(
				.FILE(OBSTACLE_FILE),
				.WIDTH(OBSTACLE_WIDTH),
				.HEIGHT(OBSTACLE_HEIGHT),
				.SCALE(10), 							// it is scaled by 4x its original size
				.SCREEN_CORDW(SCREEN_CORDW)
			) obstacle1(
				.clk_pix, .rst(0), .en(SW[9]),
				.screen_line,
				.screen_x, .screen_y,
				.sprite_x(asteroid_x+(50*i)), .sprite_y(asteroid_y+(30*i)),
				.pixel(obstacle_1_pixel[i]),
				.drawing(obstacle_1_drawing[i])
			);		
		end
	endgenerate
	
	
	//======End of Obstacle Logic=======================
	
	//============Collision Detection==============
	logic collision; // signal to use to check if there's a collision
	wire collision_in_frame;
	integer j;
	always @(posedge clk_pix) begin
		if (frame) begin
			// only update the collision bit at the end of each frame (after we've gone through all pixels checking for a collision)
			collision <= collision_in_frame;
			collision_in_frame <= 0;
		end else begin
			// as we move across the screen, check if there's a collision at the pixel we are currently at							
			for(j = 0; j < 10; j = j+1) begin
				collision_in_frame <= collision_in_frame || spaceship_drawing && obstacle_1_drawing[j];			
			end			
		end
	end
	
	
	assign LEDR[0] = collision;
	//===========End of Collision Detection==========
	
	//============Timer & scores ==========
		
	reg[31:0] count = 32'd0;                // initializing a register count for 32 bits
	parameter D = 32'd50000000;
	reg[7:0] cntdwnclk = 8'd60;    // initializing countdown clock from	60s to 0s
	reg[7:0] prev_cntdwnclk = 8'd60;    // store prev coundown value before collision
	parameter D1 = 8'd0;
	reg[7:0] score =	8'd0; //stores current score
	logic collision_detect; //indicates if there was ever a collision throughout the time of the game

	always_ff @(posedge MAX10_CLK1_50) begin     
					 
		count <= count + 32'd1;
		if(~reset_n) 
		begin
			cntdwnclk <= 8'd60;				//reset countdown clock
			prev_cntdwnclk <= 8'd60;
			score <=	8'd0;
			collision_detect <= 0;	
		end
		else //no reset
		begin
			if(collision)
			begin
				collision_detect <= 1;	
				
				//Set the score
				if(prev_cntdwnclk >= 8'd50)       //within 10s	playtime results to  points based on time e.g 1s = 2 point
					score <=  (60 - prev_cntdwnclk)*2;
				else if(prev_cntdwnclk >= 8'd40)  //within 20s	10s playtime results to 50 points
					 score <= 8'd50;
				else if(prev_cntdwnclk >= 8'd30) //within 30s	playtime results to 100 points
					 score <= 8'd100;
				else if(prev_cntdwnclk > 8'd0) //[40s - 60s) playtime results to 150 points
					  score <= 8'd150;
				else
					  score <= 8'd200; //60s	playtime means no collision within playtime hence	results to 100 points
					  
				cntdwnclk <= 8'd60;	//reset countdown clock 
					  
			
				//code to delete all obstacles here
				//here
			
			end
			else //no collision
			begin
				if(count > D)
				begin
					count <= 32'd0;
					cntdwnclk <= cntdwnclk - 8'd1; 
					prev_cntdwnclk <= cntdwnclk;
					
					if(cntdwnclk <= D1)						
					begin
						cntdwnclk <=  8'd0;	//hold countdown clock at 0s until reset
						if(collision_detect == 0)
						begin
							score <= 8'd200;
						end
					end
				end //end of count
			end//end of no collision
		end//end of no reset
	end

	TripleDigitDisplay(cntdwnclk, HEX3, HEX4, HEX5);
	TripleDigitDisplay(score, HEX0, HEX1, HEX2);
	
	//===========End of Scores==========
	
	//===========Color Value Logic========================
	wire [3:0] bg_pix = 15;
	logic [3:0] screen_pix;

	reg [3:0]total_pixel;
	integer k;
	
	assign screen_pix = spaceship_drawing? spaceship_pixel : total_pixel;  // hierarchy of sprites to display.
	
	// map pixel color code to actual red-green-blue values
	logic [11:0] color_value;
	color_mapper (.clk(clk_pix), .color_code(screen_pix), .color_value);
	logic [3:0] red, green, blue;
	always_comb begin
		{red, green, blue} = color_value;
		
		total_pixel = bg_pix;
		for(k = 0; k < 10; k=k+1) begin
			total_pixel = obstacle_1_drawing[k] ? obstacle_1_pixel[k] : total_pixel;
		end	
	end
	//==========End of Color Value Logic===================
	
	

	//==========Output VGA Signals====================
	always_ff @(posedge clk_pix) begin
		VGA_HS <= hsync;
		VGA_VS <= vsync;
		if (de) begin	// only when we are in visible part of screen should we render color. otherwise, black.
			VGA_R <= red;
			VGA_G <= green;
			VGA_B <= blue;
		end else begin
			VGA_R <= 0;
			VGA_G <= 0;
			VGA_B <= 0;
		end
	end
	//==========End of "Output VGA Signals"===============
	
endmodule

module TripleDigitDisplay (input[7:0] number, output[6:0] dispUnit, dispTens, dispHundreds);

	SevenSegDecoder (number%10, dispUnit);
	SevenSegDecoder ((number%100)/10, dispTens);
	SevenSegDecoder (number/100, dispHundreds);
endmodule

module SevenSegDecoder(input[3:0] m, output[6:0] n);

	//a is the most significant bit, d is the least significant bit
	wire a,b,c,d;
	assign a = m[3];
	assign b = m[2];
	assign c = m[1];
	assign d = m[0];

	assign n[0] = (~a&~b&~c&d)|(~a&b&~c&~d)|(a&~b&c&d)|(a&b&~c&d);
	assign n[1] = (~a&b&~c&d)|(~a&b&c&~d)|(a&~b&c&d)|(a&b&~c&~d)|(a&b&c&~d)|(a&b&c&d);
	assign n[2] = (~a&~b&c&~d)|(a&b&~c&~d)|(a&b&c&~d)|(a&b&c&d);
	assign n[3] = (~a&~b&~c&d)|(~a&b&~c&~d)|(~a&b&c&d)|(a&~b&c&~d)|(a&b&c&d);
	assign n[4] = (~a&~b&~c&d)|(~a&~b&c&d)|(~a&b&~c&~d)|(~a&b&~c&d)|(~a&b&c&d)|(a&~b&~c&d);
	assign n[5] = (~a&~b&~c&d)|(~a&~b&c&~d)|(~a&~b&c&d)|(~a&b&c&d)|(a&b&~c&d);
	assign n[6] = (~a&~b&~c)|(~a&b&c&d)|(a&b&~c&~d);
	
endmodule

module AccelClockDivider(cin, cout);			
	input cin;
	output cout;
	reg[31:0] count = 32'd0; // initializing a register count for 32 bits
	parameter D = 32'd25000000;

	always @( posedge cin)                   
	begin
		 count <= count + 32'd100;                
		 if (count > D) begin                       
			  count <= 32'd0;
		end
	end
	assign cout = (count == 0) ? 1'b1 : 1'b0; // if count is < 25 mil, output 0, else 1

endmodule
