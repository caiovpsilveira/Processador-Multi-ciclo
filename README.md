# Processador-Multi-ciclo
Processador multi-ciclo baseado no exercício 10 do Altera Lab. Adicionado suporte para as instruções de or, slt, sll e srl. Adicionado um Translation Lookaside Buffer (TLB) simples para a memória de instrução, desconsiderando a possibilidade de falha (miss).

O conjunto de instruções e a tabela de estados pode ser visualziado em [https://docs.google.com/spreadsheets/d/15OyB4uIeD0876lJ7M8QA8vN2qYoWBCkFkYUHrpxfzPw/edit#gid=0](https://docs.google.com/spreadsheets/d/15OyB4uIeD0876lJ7M8QA8vN2qYoWBCkFkYUHrpxfzPw/edit?usp=sharing)

O módulo principal “procMulticiclo” contém a memória de dados, a memória de instruções, o TLB, o processador e um multiplexador que seleciona qual dado será recebido no input do processador.
