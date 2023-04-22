;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     FEVEREIRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		X1              ;Primeiro termo da operação de multiplicação, recebe um inteiro de um byte na forma de hexadecimal
		X2              ;Segundo termo da operação de multiplicação, recebe um inteiro de um byte na forma de hexadecimal
		iterator        ;Variável auxiliar utilizada para verificar se o loop principal deve ser parado. Começa com o valor 7 e é decrementado até o valor 0.
		R1              ;Byte menos significativo da resposta
		R2              ;Byte mais significativo da resposta
		tempR1          ;Variável auxiliar responsável por armazenar o byte menos significativo do resultado da multiplicação parcial X1 * 2^counter, que posteriormente será adicionado a R1 na execução do loop.
		tempR2          ;Variável auxiliar responsável por armazenar o byte mais significativo do resultado da multiplicação parcial X1 * 2^counter, que posteriormente será adicionado a R1 na execução do loop.
		counter         ;Contador de iterações do loop externo. Usada para inferir qual bit de X2 está sendo testado, e portanto, por qual potência de 2 deve-se multiplicar o valor de X1 antes de adicioná-lo ao resultado caso o bit de X2 testado seja 1.
		shiftIter       ;Contador de iterações do loop intero, responsável por calcular o valor de X1 * 2^counter.
		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ROTINA PRINCIPAL                              *
;*                                                                         *
;* Em um primeiro momento, as variáveis são inicializadas. X1 e X2 recebem *
;* seus respectivos valores, iterator recebe a quantidade de repetições do *
;* loop externo do algoritmo e as demais variáveis são limpadas, recebendo *
;* o valor 0.                                                              *  
;*                                                                         *
;* Em seguida, o algoritmo verifica se o valor de iterator é 0. Caso       *
;* verdadeiro, sabemos que o loop principal já foi iterado pela quantidade *
;* de vezes desejadas, que neste caso são 8, e portanto não é mais         *
;* necessário continuar o iterando. Caso falso, sabemos que o loop ainda   *
;* não foi iterado um numero suficiente de vezes, então a execução do loop *
;* prossegue.                                                              *
;*                                                                         *
;* Após isso, verfica-se o bit menos significativo de X2, rotacionando o   *
;* valor do registrador para direita(armazenando o resultado nele mesmo) e *
;* então testando o bit de carry do STATUS. Caso o bit de carry assuma o   *
;* valor 0, a execução do programa pula para o "rodapé" da iteração, onde  *
;* o valor armazenado em counter é incrementado, iterator é decrementado e *
;* em seguida a execução do algoritmo volta ao inicio do loop. Caso o bit  *
;* de carry assuma o valor 1, deve-se adicionar um multiplo de X1 ao       *
;* resultado, sendo este valor definido pela quantidade de iterações do    *
;* loop já realizadas, indicadas pelo valor de counter. Em termos gerais,  *
;* este passo itera por todos os bits de X2, adicionando X1 * 2^counter ao *
;* resultado caso o bit correspondente de X2 seja 1. Vale salientar que    *
;* o loop interno do algoritmo é responsável por calcular o valor de       *
;* 2^counter.                                                              *
;*                                                                         *
;* Após testar os valores de todos os bits de X2, os valores em R1 e R2    *
;* correspondem ao byte menos significativo e ao byte mais significativo   *
;* do resultado respectivamente.                                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW 0x0E                                                              ;Define o valor do primeiro fator da multiplicação, que será armazenado em X1
	MOVWF X1                                                                ;X1 recebe o valor de work
	MOVLW 0x0A                                                              ;Define o valor do segundo fator da multiplicação, que será armazenado em X2
	MOVWF X2                                                                ;X2 recebe o valor de work
	MOVLW 0x07
	MOVWF iterator                                                          ;Iterator
	CLRF R1
	CLRF R2
	CLRF tempR1
	CLRF tempR2
	CLRF counter
LOOP                                                                            ;Loop externo, responsável por iterar por X2, garantindo que X1 seja somado a si mesmo X2 vezes.
	MOVF iterator,1                                                         ;Operação utilizada para verificar se o valor de iterator é 0, já que o comando MOVF altera o valor do bit Z de STATUS.
	BTFSC STATUS,2
	GOTO MAIN                                                               ;Caso iterator seja 0, volta para o inicio da rotina principal, onde as variáveis  são inicializadas.
	BCF STATUS,0                                                            ;Como diversas operações realizadas alteram o valor do bit de carry, antes de realizar as rotações, é necessário limpar o valor deste bit para que o resultado não seja alterado por lixo de memória.
	RRF X2,1                                                                ;Verifica o bit menos significativo atual de X2 verificando o valor do bit de carry após rotacionar X2 para a direita, atualizando X2 com o resultado da rotação do registrador. Desta forma, com o passar das iterações, todos os digitos de X2 são verificados em ordem.
	BTFSS STATUS,0                                                          ;Caso o valor do bit de carry seja 1, X1 * 2^counter é adicionado ao resultado. Caso contrário, a execução passa para a proxima iteração.
	GOTO INCC
	MOVF X1,0
	MOVWF tempR1                                                            ;Move o valor de X1 para tempR1
	CLRF tempR2                                                             ;Limpa tempR2
	MOVF counter,0
	MOVWF shiftIter                                                         ;shiftIter recebe o valor de counter.
SHIFT                                                                           ;loop interno que é iterado counter vezes com o auxilio de shiftCounter, que manipula os valores de tempR1 e tempR2 para que estes assumam os valores do byte menos significativo e do byte mais significativo de X1 * 2^counter respectivamente.
	MOVF shiftIter,1                                                        ;Decrementa shiftIter
	BTFSC STATUS,2                                                          ;Caso o valor em shiftIter seja 0, os valores em tempR1 e tempR2 já são correspondentes ao byte menos significativo e ao byte mais significativo de X1 * 2^counter, e portanto deve-se atualizar os valores de R1 e R2.
	GOTO UPDATE
	BCF STATUS,0                                                            ;Como diversas operações realizadas alteram o valor do bit de carry, antes de realizar as rotações, é necessário limpar o valor deste bit para que o resultado não seja alterado por lixo de memória.
	RLF tempR2,1                                                            ;rotaciona tempR2 para a esquerda, de forma com que os valores que foram adicionados em iterações anteriores ocupem bits mais significativos em tempR2, e portanto tempR2 represente o valor do byte mais significativo de X1 * 2^counter ao final do loop.
	BCF STATUS,0                                                            ;Como diversas operações realizadas alteram o valor do bit de carry, antes de realizar as rotações, é necessário limpar o valor deste bit para que o resultado não seja alterado por lixo de memória.
	RLF tempR1,1                                                            ;rotaciona tempR1 para a esquerda, de forma com que o valor deste registrador corresponda ao byte menos significativo de X1 * 2^counter ao final do loop.
	BTFSC STATUS,0                                                          ;Caso o bit mais significativo de R1 antes da rotação seja 1, incrementa tempR2.
	INCF tempR2,1
	DECF shiftIter,1                                                        ;Decrementa shiftIter
	GOTO SHIFT                                                              ;Retorna para o inicio do loop interno.
UPDATE                                                                          ;Rotina de atualização dos valores do resultado, somando o valor armazenado nos registradores com o valor calculado pela iteração atual do loop externo caso o bit de X2 nela verificado seja 1.
	MOVF tempR1,0
	ADDWF R1,1                                                              ;Soma o valor de R1 com o valor de tempR1 e armazena o resultado em R1
	BTFSC STATUS,0                                                          ;Caso a soma anterior resulte em overflow, incrementa o valor de R2
	INCF R2,1
	MOVF tempR2,0
	ADDWF R2,1                                                              ;Soma o valor de R2 com o valor de tempR2 e armazena o resultado em R2
INCC                                                                            ;Rotina de finilização da iteração do loop externo.
	DECF iterator,1                                                         ;Decrementa o valor de iterator
	INCF counter,1                                                          ;Incrementa o valor de counter
	GOTO LOOP                                                               ;"Pula" para o incio do loop externo
	;CORPO DA ROTINA PRINCIPAL
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END
