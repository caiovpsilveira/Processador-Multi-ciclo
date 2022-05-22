/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/
/*
	Módulo que realiza incremento nos estágios.
	Inputs: Clear e clk.
	Outputs: out.
*/
module upcount(clear, clk, out);
	// Definiçoes de entrada e saída.
	input clear, clk;
	output reg [2:0] out;
	
	// Bloco initial inicializando a saída como 0.
	initial
	begin
		out <= 3'b000;
	end
	
	// Bloco always que age na subida do clock, verifica se Clear está ativo, se sim zera a saída, senão soma 1.
	always @(posedge clk)
	begin
		if(clear)
			out <= 3'b000;
		else
			out <= out + 1'b1;
	end
endmodule

/*
	Teste da módulo UpCount.
*/
module testeUpcount();
	
	// Definiçoes de entrada e saída.
	reg clear, clk;
	wire [2:0] out;
	// Chama o módulo.
	upcount dut(clear, clk, out);
	// Bloco initial inicializando o clk com 0 e realiza a alternância do clock, se out for 7, para a execuçao.
	initial
	begin
		clk = 1'b0;
		forever
		begin
			#1;
			clk = !clk;
			if(out == 3'b111)
				$stop;
		end
	end
	// Bloco initial com monitoramento em display.
	initial
	begin
		$monitor("Time: %0d, out: %b", $time, out);
	end
	// Bloco initial com chamadas de clear.
	initial
	begin
		clear = 1'b1; #2;
		clear = 1'b0; #2;
		clear = 1'b1; #2;
		clear = 1'b0;
	end
endmodule