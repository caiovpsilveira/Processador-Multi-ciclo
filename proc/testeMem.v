/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/
/*
	Módulo de teste da memória ROM.
*/
module testeMem();
	// Declaraçao da entrada Clock e flag para saber se é o começo ou não.
	reg Clock, flaggie;
	// Wire e reg com saida e entrada respectivamente do módulo da ROM.
	wire [15:0] ROMout;
	reg [15:0] ADDRout;
	
	// Bloco initial inicializando o clock, a flag e a entrada ADDRout em 0.
	initial 
	begin		
		Clock = 1'b1;
		flaggie = 'b0;
		ADDRout = 4'b0000;
	end
	
	// Bloco initial para iteraçao do clock.
	initial
	begin
		forever
		begin
			#1;
			Clock = !Clock;
		end
	end
	
	// Chamada do módulo.
	romplm ROM(ADDRout[4:0], Clock, ROMout);

	// Bloco always na borda de subida.
	always @(posedge Clock)
	begin
		// Se o ADDRout for 0 e a flag for 0, printa primeiro e aumenta a flag depois.
		if(ADDRout == 4'b0000 && flaggie == 1'b0) begin
			$display("Entrada:");
			$display("ADDRout = %b", ADDRout);
			$display("Saida:");
			$display("ROMout = %b\n\n", ROMout);
			flaggie = 1'b1;
		end else begin
		// Se o ADDRout não for 0  a flag for diferente de 0, incrementa o ADDR primeiro e printa depois.	
			ADDRout = ADDRout + 1'b1;
			$display("Entrada:");
			$display("ADDRout = %b", ADDRout);
			$display("Saida:");
			$display("ROMout = %b\n\n", ROMout);
		end

	end

endmodule