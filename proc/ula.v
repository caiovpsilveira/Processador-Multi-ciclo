/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/
/*
	Módulo da Unidade Lógica e Aritmética (ULA).
	Inputs: Parâmetros A e B e código da operaçao op.
	Outputs: Resultado out da operaçao. 
*/
module ula(A, B, op, out);
	
	// Declaração de entradas e saídas.
	input [2:0] op;
	input [15:0] A, B;
	output reg [15:0] out;
	
	/*
	Tabela com códigos e operaçoes correspondentes.
		OP	OPERACAO
		000	ADD
		001	SUB
		010	OR
		011	SLT
		100	SLL
		101	SRL
		110	
		111	
	*/
	
	//Bloco always que monitora e realiza os cálculos conforme chegam na ULA.
	always @(*)
	begin
		case(op)
			3'b000: //ADD
			begin
				out <= A + B;
			end
			3'b001: //SUB
			begin
				out <= A - B;
			end
			3'b010: //OR
			begin
				out <= A | B;
			end
			3'b011: //SLT
			begin
				if(A < B)
					out <= 16'h0001;
				else
					out <= 16'h0000;
			end
			3'b100: //SLL
			begin
				out <= A << B;
			end
			3'b101: //SRL
			begin
				out <= A >> B;
			end
			default:
				begin
					out <= 16'h1111;
				end
			endcase
	end
	
endmodule

/*
	Teste para a ULA.
*/
module testeULA();
	reg [2:0] op;
	reg [15:0] A, B;
	wire [15:0] out;
	
	// Chamada do módulo da ULA.
	ula dut(A, B, op, out);
	
	// Bloco initial de monitoramento com display.
	initial
		$monitor("Time %0d, Out: %b = %h", $time, out, out);
	
	// Bloco initial com testes variados para a ULA.
	initial
	begin
				A = 16'h0003; B = 16'h0004; op = 3'b000; //0: 3+4
		#1;	A = 16'h000F; B = 16'h0003; op = 3'b001; //1: F-3
		#1;	A = 16'h000C; B = 16'h000A; op = 3'b010; //2: (000h 1100) || (000h 1010) = 000h 1110 (E) 
		#1;	A = 16'h0006; B = 16'h0002; op = 3'b011; //3:(6<2)?(1:0)
		#1;	A = 16'h0003; B = 16'h0004; op = 3'b011; //4:(3<4)?(1:0)
		#1;	A = 16'h0005; B = 16'h0005; op = 3'b011; //5:(5<5)?(1:0)
		#1;	A = 16'h0006; B = 16'h0001; op = 3'b100; //6: 6 << 1 = 12
		#1;	A = 16'h0014; B = 16'h0001; op = 3'b101; //7: 10100 >> 1 = A
		#1;
	end
	
endmodule