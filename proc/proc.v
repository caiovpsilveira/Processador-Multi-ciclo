/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento

*/
/*
	Módulo do processador.
	Inputs: DIN: Entrada de 16 bits, Resetn: bit de reset, clk: clock e Run: bit para inicial execuçao.
	Outputs: ADDRout: endereço para acesso de memória/busca de instruçao, 
		DOUTout: Dado de saida, memW: Bit de write enable para memória, 
		muxRomRam: Sinal do mux e oRegs: Registradores utilizados.
*/
module proc (DIN, Resetn, clk, Run, ADDRout, DOUTout, memW, muxRomRam, oREGS);
	//Declaraçoes de entradas e saídas.
	input [15:0] DIN;
	input Resetn, clk, Run;

	output reg memW;
	output reg muxRomRam;
	output [15:0] ADDRout, DOUTout;
	output [127:0] oREGS;
	
	/*Flags:
		Running = Estado de execuçao.
		pcReset = Bit para reset do PC(registrador R7).
		Done = Estado de completude da execução.
	*/
	reg running;
	reg pcReset;
	reg Done;
	
	reg [15:0] Bus;
	
	//Register write-enable
	reg Ain, Gin, IRin;
	reg ADDRin, DOUTin;
	reg [7:0] Rin;
	
	//Selecao de r7
	reg muxR7BusAdder;
	
	//Selecao do MUX do barramento
	reg [7:0] Rout;
	reg Gout, DINout;
	
	//ULA
	reg [2:0] ULAop;
	wire [15:0] ULAout; //ULAout eh reg
	
	//INSTRUCAO
	wire [9:0] IR; //wire porque IR ja eh registrador
	wire [3:0] I;
	
	//REG auxiliar para multiplexar a entrada de R7(PC) entre bus, adder e reset (0)
	reg [15:0] inR7;
	
	wire [2:0] Tstep_Q;
	wire [7:0] Xreg, Yreg;
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7, RA, RG;
	
	// Atribuição dos registradores para o array oRegs de saida.
	assign oREGS = {R7, R6, R5, R4, R3, R2, R1, R0};
	
	// Clear condicionado ao Done e ao estado Running.
	wire Clear = Done | ~running;
	
	//INSTANCIACAO DOS MODULOS
	
	//module upcount(Clear, clk, Q);
	upcount Tstep(Clear, clk, Tstep_Q);
	
	//module regn(in, WE, clk, out);
	regn reg_IR(DIN[9:0], IRin, clk, IR); //registrador de instrucao
	defparam reg_IR.n = 10;
	
	//Registradores
	regn reg_0(Bus, Rin[0], clk, R0);
	regn reg_1(Bus, Rin[1], clk, R1);
	regn reg_2(Bus, Rin[2], clk, R2);
	regn reg_3(Bus, Rin[3], clk, R3);
	regn reg_4(Bus, Rin[4], clk, R4);
	regn reg_5(Bus, Rin[5], clk, R5);
	regn reg_6(Bus, Rin[6], clk, R6);
	regn reg_7(inR7, Rin[7], clk, R7); //PC
	
	regn reg_A(Bus, Ain, clk, RA);
	regn reg_G(ULAout, Gin, clk, RG);
	regn reg_ADDR(Bus, ADDRin, clk, ADDRout);
	regn reg_DOUT(Bus, DOUTin, clk, DOUTout);
	
	//module ula(A, B, op, out);
	ula ULA(RA, Bus, ULAop, ULAout);
	
	//Extraçao do opcode de 4 bits.
	assign I = IR[9:6]; 
	dec3to8 decX(IR[5:3], 1'b1, Xreg); //qual registrador sera habilitado para x
	dec3to8 decY(IR[2:0], 1'b1, Yreg); //qual registrador sera habiliado para y
	
	// Bloco de inicializaçao dos registradores.
	initial
	begin
		//ULA
		ULAop = 3'b000;
		//Selecao MUX barramento
		DINout = 1'b0;
		Gout = 1'b0;
		Rout = 8'h00;
		//Regs WE
		IRin = 1'b0;
		Rin = 8'h00;
		Ain = 1'b0;
		Gin = 1'b0;
		ADDRin = 1'b0;
		DOUTin = 1'b0;
		//memDado WE
		memW = 1'b0;
		//Selecao MUX R7(PC)
		muxR7BusAdder = 1'b0;
		//Done
		Done = 1'b0;
		//Selecao MUX DIN (externo)
		muxRomRam = 1'b0;
		
		//Flags
		running = 1'b0;
		pcReset = 1'b0;
		Done = 1'b0;
	end
	
	//Logica RESET e RUN
	always @(posedge Resetn or posedge Run)
	begin
		if(Resetn)
		begin
			running = 1'b0;
			pcReset = 1'b1;
		end
		//else if(Run) //poderia ser somente else, ja que no posedge se nao for reset deve ser o run
		else
		begin
			running = 1'b1;
			pcReset = 1'b0;
		end
	end
	
	// Bloco always dependente da mudança de estágios, entrada de registradores, estado running e saida da ula.
	always @(Tstep_Q or I or Xreg or Yreg or running or RG)
	begin
		//Tornar todos os estados 0, para garantir que nao ocorrera nenhuma leitura ou escrita indesejada
		//ULA
		ULAop = 3'b000;
		//Selecao MUX barramento
		DINout = 1'b0;
		Gout = 1'b0;
		Rout = 8'h00;
		//Regs WE
		IRin = 1'b0;
		Rin = 8'h00;
		Ain = 1'b0;
		Gin = 1'b0;
		ADDRin = 1'b0;
		DOUTin = 1'b0;
		//memDado WE
		memW = 1'b0;
		//Selecao MUX R7(PC)
		muxR7BusAdder = 1'b0;
		//Done
		Done = 1'b0;
		//Selecao MUX DIN (externo)
		muxRomRam = 1'b0;
		
		//contador de estagios
		case (Tstep_Q)	
		3'b000: //T0
		begin
			//Fetch
			Rout = 8'b10000000;
			ADDRin = 1'b1;
			//incrementar PC
			Rin = 8'b10000000; //habilita escrita de R7
			muxR7BusAdder = 1'b1;
		end
		
		3'b001: //T1
		begin
			IRin = 1'b1;
		end
		
		3'b010: //T2
		begin
			case (I)
			4'b0000, //LD
			4'b0001: //ST
			begin
				ADDRin = 1'b1;
				Rout = Yreg;
			end
			4'b0010: //MVNZ
			begin
				if(RG != 16'h0000)
				begin
					Rout = Yreg;
					Rin = Xreg;
				end
				Done = 1'b1;
			end
			4'b0011: //MV
			begin
				Rout = Yreg;
				Rin = Xreg;
				Done = 1'b1;
			end
			4'b0100: //MVI
			begin
				//Fetch
				Rout = 8'b10000000;
				ADDRin = 1'b1;
				//incrementar PC
				Rin = 8'b10000000; //habilita escrita de R7
				muxR7BusAdder = 1'b1;	
			end
			4'b0101, //ADD
			4'b0110, //SUB
			4'b0111, //OR
			4'b1000, //SLT
			4'b1001, //SLL
			4'b1010: //SRL
			begin
				Rout = Xreg;
				Ain = 1'b1;
			end
			default:
			begin
				//Do nothing.
			end
			endcase
		end
		
		3'b011: //T3
		begin
			case (I)
			4'b0000: //LD
			begin
				Rin = Xreg;
				DINout = 1'b1;
				muxRomRam = 1'b1;
				Done = 1'b1;
			end
			4'b0001: //ST
			begin
				Rout = Xreg;
				DOUTin = 1'b1;
			end
			//4'b0010: //MVNZ
			//4'b0011: //MV
			4'b0100: //MVI
			begin
				DINout = 1'b1;
				Rin = Xreg;
				Done = 1'b1;
			end
			4'b0101: //ADD
			begin
				Rout = Yreg;
				Gin = 1'b1;
				ULAop = 3'b000;
			end
			4'b0110: //SUB
			begin
				Rout = Yreg;
				Gin = 1'b1;
				ULAop = 3'b001;
			end
			4'b0111: //OR
			begin
				Rout = Yreg;
				Gin = 1'b1;
				ULAop = 3'b010;
			end
			4'b1000: //SLT
			begin
				Rout = Yreg;
				Gin = 1'b1;
				ULAop = 3'b011;
			end
			4'b1001: //SLL
			begin
				Rout = Yreg;
				Gin = 1'b1;
				ULAop = 3'b100;
			end
			4'b1010: //SRL
			begin
				Rout = Yreg;
				Gin = 1'b1;
				ULAop = 3'b101;
			end
			default:
			begin
				//Do nothing.
			end
			endcase
		end
		
		
		3'b100: //T4
		begin
			case (I)
			//4'b0000: //LD
			4'b0001: //ST
			begin
				memW = 1'b1;
				Done = 1'b1;
			end
			//4'b0010, //MVNZ
			//4'b0011, //MV
			//4'b0100: //MVI
			4'b0101, //ADD
			4'b0110, //SUB
			4'b0111, //OR
			4'b1000, //SLT
			4'b1001, //SLL
			4'b1010: //SRL
			begin
				Gout = 1'b1;
				Rin = Xreg;
				Done = 1'b1;
			end
			default:
			begin
				//Do nothing.
			end
			endcase
		end
		
		default //Outros T_step que nunca deveriam ocorrer. Flag done para resetar o counter
			Done = 1'b1;
		endcase
			
	end
	
	//Multiplexadores
	//MUX barramento
	always@(DINout or DIN or Gout or RG or Rout or R0 or R1 or R2 or R3 or R4 or R5 or R6 or R7)
	begin
		if(DINout)
			Bus = DIN;
		else if(Gout)
			Bus = RG;
		else
		begin
			case(Rout)
				8'b00000001:
					Bus = R0;
				8'b00000010:
					Bus = R1;
				8'b00000100:
					Bus = R2;
				8'b00001000:
					Bus = R3;
				8'b00010000:
					Bus = R4;
				8'b00100000:
					Bus = R5;
				8'b01000000:
					Bus = R6;
				8'b10000000:
					Bus = R7;
				default:
					Bus = 16'h0000;
			endcase
		end
	end
	
	//MUX entrada de R7 (PC)
	always @ (muxR7BusAdder or R7 or Bus or pcReset)
	begin
		if(pcReset)
			inR7 <= 16'h0000;
		else if(muxR7BusAdder)
			inR7 <= R7 + 16'h0001;
		else
			inR7 <= Bus;
	end
	
endmodule


/*
	Testbench
*/
module testeProc();
	
	reg [15:0] DIN;
	reg Resetn, Run, clk;
	wire Done, memW, muxRomRam;
	wire [15:0] ADDRout, DOUTout, Bus;
	wire [127:0] oREGS;
	
	//module proc (DIN, Resetn, clk, Run, ADDRout, DOUTout, memW, muxRomRam, oREGS);
	proc p(DIN, Resetn, clk, Run, ADDRout, DOUTout, memW, muxRomRam, oREGS);

	initial
	begin
		Resetn = 1'b0;
		Run = 1'b1;
		clk = 1'b0;
		forever
		begin
			#1;
			clk = !clk;
		end
	end
	
	initial
	begin
		//6b: nada, 4b: opcode, 3b: 1op, 3b: 2op
		//colocar espera # de 2*o tempo de ciclo da instrucao
		//para load, colocar o dado recebido em T3
		#1; //sincronizar com a borda de subida do clock
		DIN = 16'b0000000100000000; #4; //MVI R0, #2
		DIN = 16'b0000000000000010; #4; //imediato 2
		DIN = 16'b0000000100001000; #4; //MVI R1, #3
		DIN = 16'b0000000000000011; #4; //imediato 3
		DIN = 16'b0000000101001000; #10; //ADD R1, R0
		DIN = 16'b0000000100010000; #4; //MVI R2, #6
		DIN = 16'b0000000000000110; #4; //imediato 6
		DIN = 16'b0000000110010001; #10; //SUB R2, R1
		DIN = 16'b0000000011011010; #6; //MV R3, R2 
		DIN = 16'b0000000101000011; #10; //ADD R0,R3 
		DIN = 16'b0000000111001000; #10; //OR R1,R0  
		DIN = 16'b0000000110001000; #10; //SUB R1,R0 
		DIN = 16'b0000000101001011; #10; //ADD R1, R3
		DIN = 16'b0000001001001011; #10; //SLL R1, R3
		DIN = 16'b0000001010001011; #10; //SRL R1, R3
		DIN = 16'b0000000100000000; #4; //MVI R0, #0
		DIN = 16'b0000000000000000; #4; //imediato 0
		DIN = 16'b0000001000000001; #10; //SLT R0, R1
		DIN = 16'b0000001000001001; #10; //SLT R1, R1
		DIN = 16'b0000000100011000; #4; //MVI R3, #3
		DIN = 16'b0000000000000011; #4; //imediato 3
		DIN = 16'b0000000100001000; #4; //MVI R1, #5
		DIN = 16'b0000000000000101; #4; //imediato 5
		DIN = 16'b0000000101000011; #10; //ADD R0, R3
		DIN = 16'b0000000100000000; #4; //MVI R0, #0
		DIN = 16'b0000000000000000; #4; //imediato 0
		DIN = 16'b0000000000010011; #4; //LD R2, R3
			DIN = 16'b0000000000000100; #4; //SOMENTE ESSE TESTBENCH: simular que a memoria retornou 4
		DIN = 16'b0000000101010011; #10; //ADD R2, R3
		DIN = 16'b0000000001010000; #10; //SD R2, R0 
		DIN = 16'b0000000000000000; #4; //LD R0, R0
			DIN = 16'b0000000000000111; #4; //SOMENTE ESSE TESTBENCH: simular que a memoria retornou 7
		DIN = 16'b0000000110000011; #10; //SUB R0, R3
		DIN = 16'b0000000100000000; #4; //MVI R0, #0
		DIN = 16'b0000000000000000; #4; //imediato 0
		DIN = 16'b0000000101000000; #10; //ADD R0, R0
		DIN = 16'b0000000010000010; #6; //MVNZ R0,R2
		DIN = 16'b0000000110001011; #10; //SUB R1,R3 
		DIN = 16'b0000000010000010; #6; //MVNZ R0,R2
		DIN = 16'b0000000101000001; #10; //ADD R0, R1
	end
	
	/* Teste Load
		#1; //sincronizar com a borda de subida do clock
		DIN = 16'0000000100011000; #6; //MVI R3, #3
		DIN = 16'0000000000000011; #2; //imediato 3
		DIN = 16'0000000000010011; #6; //LD R2, R3
			DIN = 16'0000000000000100; #2; //SOMENTE ESSE TESTBENCH: simular que a memoria retornou 4
	*/
	
	/* Teste Jump: somente colocar no .mif, nao tem como testar pelo testbench do processador.
		0000000100010000 //MVI R2, #1
		0000000000000001 //imediato 1
		0000000100100000 //MVI R4, #10
		0000000000001010 //imediato 10
		0000000011101111 //MV R5, R7
		0000000110100010 //SUB R4, R2
		0000000010111101 //MVNZ R7,R5
	*/
	
	/*
	Teste Store: somente testar com mif, nao faz sentido testar pelo testbench do processador.
		0000000100100000 //MVI R4, #10
		0000000000001010 //imediato 10
		0000000100001000 //MVI R1, #3
		0000000000000011 //imediato 3
		0000000001100001 //SD R4, R1 
		0000000100000000 //MVI R0, #3
		0000000000000011 //imediato 3
		0000000000000000 //LD R0, R0
	*/

	
	always @(posedge clk)
	begin
	
		if(p.R7 == 39) //criterio de parada somente para o teste principal
			$stop;
	
		if(muxRomRam)
		begin
			$display("LEITURA\nDIN recebendo da RAM\nDIN = b%b = h%h", p.DIN, p.DIN);
			$display("IR = b%b = h%h\nInstrucao apontada por IR:", p.IR, p.IR);
		end
		else
		begin
			$display("DIN recebendo da ROM\nDIN = b%b = h%h", p.DIN, p.DIN);
			$display("IR = b%b = h%h\nInstrucao apontada por IR:", p.IR, p.IR);
			case(p.IR[9:6])
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
		case(p.IR[5:3])
			3'b000: $display("0");
			3'b001: $display("1");
			3'b010: $display("2");
			3'b011: $display("3");
			3'b100: $display("4");
			3'b101: $display("5");
			3'b110: $display("6");
			3'b111: $display("7");
		endcase
		case(p.IR[2:0])
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
		$display("ADDRin = b%b = h%h\n, ADDRout = b%b = h%h", p.ADDRin, p.ADDRin, p.ADDRout, p.ADDRout);
		
		$display("______________________");
		$display("PC: %b = d%d = h%h", p.R7, p.R7, p.R7);
		$display("IR: %b", p.IR[9:0]);
		$display("Tstep: %d", p.Tstep_Q);
		
		$display("______________________");
		$display("Bus: %h", p.Bus);
		$display("Rout: %b\nGout: %b\nDINout: %b", p.Rout, p.Gout, p.DINout);
		$display("______________________");
		$display("Rin WE: %b", p.Rin);	
		
		$display("______________________");
		$display("REGISTRADORES");
		$display("R0: d%d = h%h", p.R0, p.R0);
		$display("R1: d%d = h%h", p.R1, p.R1);
		$display("R2: d%d = h%h", p.R2, p.R2);
		$display("R3: d%d = h%h", p.R3, p.R3);
		$display("RA: d%d = h%h", p.RA, p.RA);
		$display("RG: d%d = h%h", p.RG, p.RG);
		
		$display("______________________");
		if(memW)
			$display("ESCRITA");
		$display("SAIDAS:\n ADDRout: d%d = h%h\nDOUTout: d%d = h%h\n memW = %b", p.ADDRout, p.ADDRout, p.DOUTout, p.DOUTout, p.memW);	
		
		$display("______________________");
		$display("ULA: UlaOp: %b, ULAout: %h", p.ULAop, p.ULAout);
		
		$display("--------------------------------------------------------------");
		
	end
	
endmodule