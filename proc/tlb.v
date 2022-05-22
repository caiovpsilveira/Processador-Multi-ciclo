/*
LAOC2 Pratica 2
21/05/2022

Caio Vinicius Pereira Silveira
Paulo Lopes Nascimento

*/

/*
Módulo do TLB 
Input: Endereço virtual vADDR.
Output: Endereço físico fADDR.
*/
module tlb(vADDR, fADDR);

	input [5:0] vADDR;
	output reg [5:0] fADDR;

	/*
	Planejamento da distribuiçao dos bits do TLB.
		V + D + LRU + TAG + DADO
		1 + 1 + 1 + 6 + 6 = 14b
		V: [14]
		D: [13]
		LRU: [12]
		TAG: [11:6]
		DADO: [5:0]
	*/
	
	reg [14:0] tlb [63:0]; //64 entradas de 15 bits
	integer i, hitPos;
	reg hit, algumLRUehZero;
	
	//Deve ser colocado o PATH completo para que o MODELSIM funcione
	initial
	begin
		$readmemb("C:/Users/Estudo/Downloads/procMulticiclo/tlb.txt", tlb);
	end
	
	always @(vADDR)
	begin
		hitPos = 6'b000000;
		hit = 1'b0;
		fADDR = 6'b000000;
		algumLRUehZero = 1'b0;
	
		//Percorre todas as entradas, buscando uma entrada valida e com tag igual. 
		for(i = 0; i<64; i = i + 1)
		begin
				
			if(tlb[i][14] == 1'b1 && tlb[i][11:6] == vADDR[5:0]) //hit
			begin
				hitPos = i; //Salva a posicão acessada.
				hit = 1'b1;
				tlb[i][12] = 1'b1; // Atualiza LRU.
				fADDR = tlb[i][5:0];
			end
			else if(tlb[i][14] == 1'b1 && tlb[i][12] == 1'b0)
				algumLRUehZero = 1'b1;
			
		end
		//Se hit e nenhum LRU eh 0 -> resetar todos os LRUS, menos o último acessado.
		if(hit && !algumLRUehZero) 
		begin
			for(i = 0; i<64; i = i + 1)
			begin
				if(i != hitPos)
					tlb[i][12] = 1'b0; //Reseta todos os LRUs, menos o último acessado.
			end
		end
	end
	
endmodule