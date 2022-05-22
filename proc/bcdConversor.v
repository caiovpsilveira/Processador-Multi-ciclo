/*
LAOC2 Pratica 1 parte 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento
*/
/*
	Módulo de conversao de binário para bcd, reutilizado da Prática 1.
*/
module bcdConversor(in, bcd);
    
	 input [7:0] in;
	 output reg [11:0] bcd;
	 
    integer i;   
     
     always @(in)
        begin
            bcd = 0; 
            for (i = 0; i < 8; i = i+1) 
            begin
         
                if(bcd[3:0] >= 4'b0101) bcd = bcd + 2'b11;
                if(bcd[7:4] >= 4'b0101) bcd = bcd + 2'b11;
                if(bcd[11:8] >= 4'b0101) bcd = bcd + 2'b11;  
                
                bcd = {bcd[10:0],in[7-i]}; 
            end
        end     
            
endmodule
/* 
	Teste para o BCD.
*/
module testBCD();

	reg [7:0] in;
	wire [7:0] out;

	bcdConversor dut(in, out);

	initial
	begin
		in = 0;
	end
	
	initial
	begin
		$monitor("%0d = %b %b",$time, out[7:4], out[3:0]);
	end
	
	initial
	begin
		forever
		begin
			#1;
			in = in + 1;
			if(in == 100)
				$stop;
		end
	end
	
	
endmodule