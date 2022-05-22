/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/
/*
	Módulo que extende um valor de 3 bits para um de 8 bits.
	Inputs: in: valor de 3 bits, WE: write enable.
	Outputs: out: saída de 8 bits.
*/
module dec3to8(in, WE, out);
	// Declaraçao de entradas e saídas.
	input [2:0] in;
	input WE;
	output reg [7:0] out;
	
	//Bloco initial inicializando a saida em 0.
	initial
	begin
		out = 8'h00;
	end
	
	// Bloco always, executado a cada entrada distinta em que o WE é ativo.
	always @(in or WE)
	begin
		if(WE)
			case(in)
				// Orientaçao da esquerda para a direita, utilizamos o oposto, porém ambos são viáveis.
				//3'b000: out = 8'b10000000;
				//3'b001: out = 8'b01000000;
				//3'b010: out = 8'b00100000;
				//3'b011: out = 8'b00010000;
				//3'b100: out = 8'b00001000;
				//3'b101: out = 8'b00000100;
				//3'b110: out = 8'b00000010;
				//3'b111: out = 8'b00000001;
				3'b000: out = 8'b00000001;
				3'b001: out = 8'b00000010;
				3'b010: out = 8'b00000100;
				3'b011: out = 8'b00001000;
				3'b100: out = 8'b00010000;
				3'b101: out = 8'b00100000;
				3'b110: out = 8'b01000000;
				3'b111: out = 8'b10000000;
			endcase
		else
			out = 8'b00000000;
		end
endmodule

/*
	Módulo de teste do módulo dec3to8.
*/
module testeDec3To8();
	// Declaraçao de entradas e saídas.
	reg [2:0] in;
	reg WE;
	wire [7:0] out;
	
	// Integer i para percorrer os bits.
	integer i;
	
	// Chamada do módulo.
	dec3to8 dut(in, WE, out);
	
	// Bloco initial para monitoramento em display.
	initial
		$monitor("Time: %0d, out: %b", $time, out);
	
	// Bloco initial com valores distintos de entrada e WE, iterando e extendendo o valor.
	initial
	begin
		in = 3'b111; WE = 1'b0; #1; //0
		in = 3'b101; WE = 1'b0; #1; //1
		in = 3'b000; WE = 1'b1; #1; //2
		for(i = 1; i<8; i = i+1) //3-8
		begin
			in = in + 1;
			#1;
		end
	end

endmodule