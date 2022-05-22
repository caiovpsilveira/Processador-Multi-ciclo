/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/

/* 
	Módulo de teste na placa FPGA.
*/

module testeFPGA(CLOCK_50, LEDR, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
//module testeFPGA(SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
	
	/*
	SW[0]: RESET
	SW[1]: RUN
	SW[2]: Clock
	*/
	
	input CLOCK_50;
	input [17:0] SW;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	output [17:0] LEDR;
	
	reg [24:0] redutor; 
	wire reset, run, clockProc;
	
	assign reset = SW[0];
	assign run = SW[1];
	//assign clockProc = SW[2]; //descomentar se utilizar SW como clock, ao inves do clock interno de 50 MHz

	assign clockProc = redutor[24]; //reduz a frequencia de CLOCK em 2^25 (24+ [0])
	
	wire [127:0] oREGS;
	wire [15:0] R0, R1, R2, R3, R4, R5, R7; //R6, R7;
	
	assign R0 = oREGS[15:0];
	assign R1 = oREGS[31:16];
	assign R2 = oREGS[47:32];
	assign R3 = oREGS[63:48];
	assign R4 = oREGS[79:64];
	assign R5 = oREGS[95:80];
	//assign R6 = oREGS[111:96]; // Não será utilizado.
	assign R7 = oREGS[127:112];
	
	wire [15:0] oDIN;
	assign LEDR[15:0] = oDIN;
	assign LEDR[16] = 1'b0;
	assign LEDR[17] = clockProc;
	
	wire [11:0] bcdR7;
	
	//module procMulticiclo(Clock, Resetn, Run, oREGS, oDIN);
	procMulticiclo proc(clockProc, reset, run, oREGS, oDIN);
	
	//module bcdConversor(in, bcd);
	bcdConversor convBCDR7(R7[7:0], bcdR7);
	
	//module HEXto7Segment(in, out);
	//HEX0 : R0 = HEX 0 ... R5 = HEX5 (indice cresce da direita para esquerda), decidimos por utilizar o inverso, abaixo.
	//HEXto7Segment hex0(R0[3:0], HEX0);
	//HEXto7Segment hex1(R1[3:0], HEX1);
	//HEXto7Segment hex2(R2[3:0], HEX2);
	//HEXto7Segment hex3(R3[3:0], HEX3);
	//HEXto7Segment hex4(R4[3:0], HEX4);
	//HEXto7Segment hex5(R5[3:0], HEX5);
	
	//HEX0 : R5 = HEX 0 ... R0 = HEX5 (indice cresce da esquerda para direita)
	HEXto7Segment hex0(R0[3:0], HEX5);
	HEXto7Segment hex1(R1[3:0], HEX4);
	HEXto7Segment hex2(R2[3:0], HEX3);
	HEXto7Segment hex3(R3[3:0], HEX2);
	HEXto7Segment hex4(R4[3:0], HEX1);
	HEXto7Segment hex5(R5[3:0], HEX0);
	
	//PC em decimal: duas casas, HEX7(dezena), HEX6(unidade)
	HEXto7Segment hex6(bcdR7[3:0], HEX6);
	HEXto7Segment hex7(bcdR7[7:4], HEX7);
	
	initial
		redutor = 0;
	
	always @(posedge CLOCK_50)
	begin
		redutor <= redutor + 1'b1;
	end
	
endmodule