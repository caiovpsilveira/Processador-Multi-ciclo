/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/
/*
	Módulo que converte hexadecimal/4 bits binários para um bloco de 7 segmentos a ser utilizado no FPGA.
*/
module HEXto7Segment(in, out);
	
	input [3:0] in;
	output reg [6:0] out;
	
	always @*
	begin
		out = 7'b0000000;
		
		case(in)
			4'h0:begin // Display 0
				out[6] = 1'b1;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b0;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b0;
			end
			4'h1:begin // Display 1
				out[6] = 1'b1;
				out[5] = 1'b1;
				out[4] = 1'b1;
				out[3] = 1'b1;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b1;
			end
			4'h2:begin // Display 2
				out[6] = 1'b0;
				out[5] = 1'b1;
				out[4] = 1'b0;
				out[3] = 1'b0;
				out[2] = 1'b1;
				out[1] = 1'b0;
				out[0] = 1'b0;
			end
			4'h3:begin // Display 3
				out[6] = 1'b0;
				out[5] = 1'b1;
				out[4] = 1'b1;
				out[3] = 1'b0;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b0;
			end
			4'h4:begin // Display 4
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b1;
				out[3] = 1'b1;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b1;
			end
			4'h5:begin // Display 5
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b1;
				out[3] = 1'b0;
				out[2] = 1'b0;
				out[1] = 1'b1;
				out[0] = 1'b0;
			end
			4'h6:begin // Display 6
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b0;
				out[2] = 1'b0;
				out[1] = 1'b1;
				out[0] = 1'b0;
			end
			4'h7:begin // Display 7
				out[6] = 1'b1;
				out[5] = 1'b1;
				out[4] = 1'b1;
				out[3] = 1'b1;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b0;
			end
			4'h8:begin // Display 8
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b0;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b0;
			end
			4'h9:begin // Display 9
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b1;
				out[3] = 1'b1;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b0;
			end
			4'hA:begin // Display A
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b1;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b0;
			end
			4'hB:begin // Display B
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b1;
				out[2] = 1'b0;
				out[1] = 1'b1;
				out[0] = 1'b1;
			end
			4'hC:begin // Display C
				out[6] = 1'b1;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b0;
				out[2] = 1'b1;
				out[1] = 1'b1;
				out[0] = 1'b0;
			end
			4'hD:begin // Display D
				out[6] = 1'b0;
				out[5] = 1'b1;
				out[4] = 1'b0;
				out[3] = 1'b0;
				out[2] = 1'b0;
				out[1] = 1'b0;
				out[0] = 1'b1;
			end
			4'hE:begin // Display E
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b0;
				out[2] = 1'b1;
				out[1] = 1'b1;
				out[0] = 1'b0;
			end
			4'hF:begin // Display F
				out[6] = 1'b0;
				out[5] = 1'b0;
				out[4] = 1'b0;
				out[3] = 1'b1;
				out[2] = 1'b1;
				out[1] = 1'b1;
				out[0] = 1'b0;
			end
		endcase
	end
endmodule