/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/

/*
	Módulo de montagem de registradores.
	Inputs: in: bloco binário com registrador de tamanho variável. WE = bit writeEnable e clk = clock.
	Outputs: Saída out com registrador "montado".
*/
module regn(in, WE, clk, out);
	// Declaraçao de parâmetros, entradas e saídas.
	parameter n = 16;
	input [n-1:0] in;
	input WE, clk;
	output reg [n-1:0] out;
	
	// Bloco initial inicializando saída em 0.
	initial
	begin
		out <= 0;
	end
	
	// Bloco always com clock em borda de subida verificando se o WE está ativo, 
	// se sim a saída recebe a entrada.
	always @(posedge clk)
		if(WE)
			out <= in;
endmodule

/*
	Teste do módulo regn.
*/
module testeRegn();

	reg [15:0] in;
	reg WE, clk;
	wire [15:0] out;
	
	// Chamada do módulo.
	regn dut(in, WE, clk, out);
	
	// Bloco initial inicializando o clock em 0 e alternando-o.
	initial
	begin
		clk = 1'b0;
		forever
		begin
			#1;
			clk = !clk;
		end
	end
	
	// Bloco initial para monitoramento em display.
	initial
		$monitor("Time: %0d, out: %b = %h", $time, out, out);
	
	// Bloco initial testando alguns valores.	
	initial
	begin
				WE = 1'b0; in = 16'h0011; //0
		#1;	WE = 1'b0; in = 16'h0001; //1
		#1;	WE = 1'b1; in = 16'h1010; //2
		#1;
	end
	
endmodule