/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/
/*
	Módulo de coordenação dos módulos, realizando todas as chamadas.
	Input: Clock, Resetn e Run.
	Outputs: Array de registradores e DIN completo.
	*/
module procMulticiclo(Clock, Resetn, Run, oREGS, oDIN);

	// Declaração dos argumentos
	input Clock, Resetn, Run;
	output [127:0] oREGS; //{R7, R6, R5, R4, R3, R2, R1, R0};
	output [15:0] oDIN;
	// DIN que será entrada do processador.
	reg [15:0] DIN;
	// Saídas:
	// ADDRout e DOUTout são saídas do processador.
	wire [15:0] ADDRout, DOUTout;
	// ROMout e RAMout são as saídas da ROM e RAM respectivamente, se existirem.
	wire [15:0] ROMout, RAMout;
	// tlbOUT é a saida do TLB.
	wire [5:0] tlbOut;
	// Bit de escrita na memória (Write Enable).
	wire memW;
	// Bit de sinal para o MUX que coordena qual será a entrada DIN, será a saida da ROM ou RAM.
	wire muxRomRam;
	// Clock da memória.
	wire memClock;
	// Atribuiçao do clock da memória sendo o clock do processador negado, agilizando o processo.
	assign memClock = ~Clock; //Sincronismo de leitura e escrita.
	// Atribuiçao do DIN completo como DIN atual (que varia conforme origem).
	assign oDIN = DIN;
	
	
	//module romplm (address,clock,q);
	romplm ROM(tlbOut, memClock, ROMout);
	
	//module ramplm (address,clock,data,wren,q);
	ramplm RAM(ADDRout[5:0], memClock, DOUTout, memW, RAMout);
	
	//module tlb(vADDR, fADDR);
	tlb tlb(ADDRout[5:0], tlbOut);
	
	//module proc (DIN, Resetn, Clock, Run, ADDRout, DOUTout, memW, muxRomRam, oREGS);
	proc p(DIN, Resetn, Clock, Run, ADDRout, DOUTout, memW, muxRomRam, oREGS);
	
	// Bloco always que define o DIN baseado no sinal que sai do processador,
	//	ou a saida da RAM ou saída da ROM.
	always @(muxRomRam or RAMout or ROMout)
	begin
		if(muxRomRam)
			DIN = RAMout; //selecao do dado da RAM
		else
			DIN = ROMout;
	end
	
endmodule

/*
	Teste para o procMulticiclo.
*/
module testeProcMulticiclo();
	reg Clock;
	reg Resetn;
	reg Run;
	
	wire [127:0] oREGS;
	wire [15:0] oDIN;
	
	//module procMulticiclo(Clock, Resetn, Run, oREGS, oDIN);
	procMulticiclo d(Clock, Resetn, Run, oREGS, oDIN);
	
	// Bloco initial inicializando as entradas.
	initial
	begin	
		Clock = 1'b0;
		Resetn = 1'b0;
		Run = 1'b1;
	end
	
	//Bloco forever para progressao do clock.
	initial
	begin
		forever
		begin
			#1;
			Clock = !Clock;
		end
	end
	
	// Bloco always que executa na borda de subida e realiza os displays para simulaçao no ModelSim.
	always @(posedge Clock)
	begin
	
		if(d.p.R7 == 39) //Parada do teste principal no PC 39.
			$stop;
	
		$display("ROMout: b%b = h%h", d.ROMout, d.ROMout);
		$display("RAMout: b%b = h%h", d.RAMout, d.RAMout);
	
		if(d.muxRomRam)
		begin
			$display("LEITURA\nDIN recebendo da RAM\nDIN = b%b = h%h", d.p.DIN, d.p.DIN);
		end
		else
		begin
			$display("DIN recebendo da ROM\nDIN = b%b = h%h", d.p.DIN, d.p.DIN);
			$display("IR = b%b = h%h\nInstrucao apontada por IR:", d.p.IR, d.p.IR);
			case(d.p.IR[9:6])
				4'h0:  $display("LD");
				4'h1: $display("ST");
				4'h2: $display("MVNZ");
				4'h3: $display("MV");
				4'h4: $display("MVI");
				4'h5: $display("ADD");
				4'h6: $display("SUB");
				4'h7: $display("OR");
				4'h8: $display("SLT");
				4'h9: $display("SLL");
				4'hA: $display("SRL");
				default:
					$display("OPCODE INVALIDO");
			endcase
			case(d.p.IR[5:3])
				3'b000: $display("0");
				3'b001: $display("1");
				3'b010: $display("2");
				3'b011: $display("3");
				3'b100: $display("4");
				3'b101: $display("5");
				3'b110: $display("6");
				3'b111: $display("7");
			endcase
			case(d.p.IR[2:0])
				3'b000: $display("0");
				3'b001: $display("1");
				3'b010: $display("2");
				3'b011: $display("3");
				3'b100: $display("4");
				3'b101: $display("5");
				3'b110: $display("6");
				3'b111: $display("7");
			endcase
		end
			
		$display("______________________");
		$display("PC: %b = d%d = h%h", d.p.R7, d.p.R7, d.p.R7);
		$display("IR: %b", d.p.IR[9:0]);
		$display("Tstep: %d", d.p.Tstep_Q);
		
		$display("______________________");
		$display("Bus: %h", d.p.Bus);
		$display("Rout: %b\nGout: %b\nDINout: %b", d.p.Rout, d.p.Gout, d.p.DINout);
		$display("______________________");
		$display("Rin WE: %b", d.p.Rin);	
		
		$display("______________________");
		$display("REGISTRADORES");
		$display("R0: d%d = h%h", d.p.R0, d.p.R0);
		$display("R1: d%d = h%h", d.p.R1, d.p.R1);
		$display("R2: d%d = h%h", d.p.R2, d.p.R2);
		$display("R3: d%d = h%h", d.p.R3, d.p.R3);
		$display("R4: d%d = h%h", d.p.R4, d.p.R4);
		$display("R5: d%d = h%h", d.p.R5, d.p.R5);
		$display("RA: d%d = h%h", d.p.RA, d.p.RA);
		$display("RG: d%d = h%h", d.p.RG, d.p.RG);
		
		$display("______________________");
		if(d.memW)
			$display("ESCRITA");
		$display("SAIDAS:\n ADDRout: d%d = h%h\nDOUTout: d%d = h%h\n memW = %b", d.p.ADDRout, d.p.ADDRout, d.p.DOUTout, d.p.DOUTout, d.p.memW);	
		
		$display("______________________");
		$display("ULA: UlaOp: %b, ULAout: %h", d.p.ULAop, d.p.ULAout);
		
		$display("--------------------------------------------------------------");
	end
endmodule