;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     FEVEREIRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		X1              ;Primeiro termo da opera��o de multiplica��o, recebe um inteiro de um byte na forma de hexadecimal
		X2              ;Segundo termo da opera��o de multiplica��o, recebe um inteiro de um byte na forma de hexadecimal
		iterator        ;Vari�vel auxiliar utilizada para verificar se o loop principal deve ser parado. Come�a com o valor 7 e � decrementado at� o valor 0.
		R1              ;Byte menos significativo da resposta
		R2              ;Byte mais significativo da resposta
		tempR1          ;Vari�vel auxiliar respons�vel por armazenar o byte menos significativo do resultado da multiplica��o parcial X1 * 2^counter, que posteriormente ser� adicionado a R1 na execu��o do loop.
		tempR2          ;Vari�vel auxiliar respons�vel por armazenar o byte mais significativo do resultado da multiplica��o parcial X1 * 2^counter, que posteriormente ser� adicionado a R1 na execu��o do loop.
		counter         ;Contador de itera��es do loop externo. Usada para inferir qual bit de X2 est� sendo testado, e portanto, por qual pot�ncia de 2 deve-se multiplicar o valor de X1 antes de adicion�-lo ao resultado caso o bit de X2 testado seja 1.
		shiftIter       ;Contador de itera��es do loop intero, respons�vel por calcular o valor de X1 * 2^counter.
		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ROTINA PRINCIPAL                              *
;*                                                                         *
;* Em um primeiro momento, as vari�veis s�o inicializadas. X1 e X2 recebem *
;* seus respectivos valores, iterator recebe a quantidade de repeti��es do *
;* loop externo do algoritmo e as demais vari�veis s�o limpadas, recebendo *
;* o valor 0.                                                              *  
;*                                                                         *
;* Em seguida, o algoritmo verifica se o valor de iterator � 0. Caso       *
;* verdadeiro, sabemos que o loop principal j� foi iterado pela quantidade *
;* de vezes desejadas, que neste caso s�o 8, e portanto n�o � mais         *
;* necess�rio continuar o iterando. Caso falso, sabemos que o loop ainda   *
;* n�o foi iterado um numero suficiente de vezes, ent�o a execu��o do loop *
;* prossegue.                                                              *
;*                                                                         *
;* Ap�s isso, verfica-se o bit menos significativo de X2, rotacionando o   *
;* valor do registrador para direita(armazenando o resultado nele mesmo) e *
;* ent�o testando o bit de carry do STATUS. Caso o bit de carry assuma o   *
;* valor 0, a execu��o do programa pula para o "rodap�" da itera��o, onde  *
;* o valor armazenado em counter � incrementado, iterator � decrementado e *
;* em seguida a execu��o do algoritmo volta ao inicio do loop. Caso o bit  *
;* de carry assuma o valor 1, deve-se adicionar um multiplo de X1 ao       *
;* resultado, sendo este valor definido pela quantidade de itera��es do    *
;* loop j� realizadas, indicadas pelo valor de counter. Em termos gerais,  *
;* este passo itera por todos os bits de X2, adicionando X1 * 2^counter ao *
;* resultado caso o bit correspondente de X2 seja 1. Vale salientar que    *
;* o loop interno do algoritmo � respons�vel por calcular o valor de       *
;* 2^counter.                                                              *
;*                                                                         *
;* Ap�s testar os valores de todos os bits de X2, os valores em R1 e R2    *
;* correspondem ao byte menos significativo e ao byte mais significativo   *
;* do resultado respectivamente.                                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW 0x0E                                                              ;Define o valor do primeiro fator da multiplica��o, que ser� armazenado em X1
	MOVWF X1                                                                ;X1 recebe o valor de work
	MOVLW 0x0A                                                              ;Define o valor do segundo fator da multiplica��o, que ser� armazenado em X2
	MOVWF X2                                                                ;X2 recebe o valor de work
	MOVLW 0x07
	MOVWF iterator                                                          ;Iterator
	CLRF R1
	CLRF R2
	CLRF tempR1
	CLRF tempR2
	CLRF counter
LOOP                                                                            ;Loop externo, respons�vel por iterar por X2, garantindo que X1 seja somado a si mesmo X2 vezes.
	MOVF iterator,1                                                         ;Opera��o utilizada para verificar se o valor de iterator � 0, j� que o comando MOVF altera o valor do bit Z de STATUS.
	BTFSC STATUS,2
	GOTO MAIN                                                               ;Caso iterator seja 0, volta para o inicio da rotina principal, onde as vari�veis  s�o inicializadas.
	BCF STATUS,0                                                            ;Como diversas opera��es realizadas alteram o valor do bit de carry, antes de realizar as rota��es, � necess�rio limpar o valor deste bit para que o resultado n�o seja alterado por lixo de mem�ria.
	RRF X2,1                                                                ;Verifica o bit menos significativo atual de X2 verificando o valor do bit de carry ap�s rotacionar X2 para a direita, atualizando X2 com o resultado da rota��o do registrador. Desta forma, com o passar das itera��es, todos os digitos de X2 s�o verificados em ordem.
	BTFSS STATUS,0                                                          ;Caso o valor do bit de carry seja 1, X1 * 2^counter � adicionado ao resultado. Caso contr�rio, a execu��o passa para a proxima itera��o.
	GOTO INCC
	MOVF X1,0
	MOVWF tempR1                                                            ;Move o valor de X1 para tempR1
	CLRF tempR2                                                             ;Limpa tempR2
	MOVF counter,0
	MOVWF shiftIter                                                         ;shiftIter recebe o valor de counter.
SHIFT                                                                           ;loop interno que � iterado counter vezes com o auxilio de shiftCounter, que manipula os valores de tempR1 e tempR2 para que estes assumam os valores do byte menos significativo e do byte mais significativo de X1 * 2^counter respectivamente.
	MOVF shiftIter,1                                                        ;Decrementa shiftIter
	BTFSC STATUS,2                                                          ;Caso o valor em shiftIter seja 0, os valores em tempR1 e tempR2 j� s�o correspondentes ao byte menos significativo e ao byte mais significativo de X1 * 2^counter, e portanto deve-se atualizar os valores de R1 e R2.
	GOTO UPDATE
	BCF STATUS,0                                                            ;Como diversas opera��es realizadas alteram o valor do bit de carry, antes de realizar as rota��es, � necess�rio limpar o valor deste bit para que o resultado n�o seja alterado por lixo de mem�ria.
	RLF tempR2,1                                                            ;rotaciona tempR2 para a esquerda, de forma com que os valores que foram adicionados em itera��es anteriores ocupem bits mais significativos em tempR2, e portanto tempR2 represente o valor do byte mais significativo de X1 * 2^counter ao final do loop.
	BCF STATUS,0                                                            ;Como diversas opera��es realizadas alteram o valor do bit de carry, antes de realizar as rota��es, � necess�rio limpar o valor deste bit para que o resultado n�o seja alterado por lixo de mem�ria.
	RLF tempR1,1                                                            ;rotaciona tempR1 para a esquerda, de forma com que o valor deste registrador corresponda ao byte menos significativo de X1 * 2^counter ao final do loop.
	BTFSC STATUS,0                                                          ;Caso o bit mais significativo de R1 antes da rota��o seja 1, incrementa tempR2.
	INCF tempR2,1
	DECF shiftIter,1                                                        ;Decrementa shiftIter
	GOTO SHIFT                                                              ;Retorna para o inicio do loop interno.
UPDATE                                                                          ;Rotina de atualiza��o dos valores do resultado, somando o valor armazenado nos registradores com o valor calculado pela itera��o atual do loop externo caso o bit de X2 nela verificado seja 1.
	MOVF tempR1,0
	ADDWF R1,1                                                              ;Soma o valor de R1 com o valor de tempR1 e armazena o resultado em R1
	BTFSC STATUS,0                                                          ;Caso a soma anterior resulte em overflow, incrementa o valor de R2
	INCF R2,1
	MOVF tempR2,0
	ADDWF R2,1                                                              ;Soma o valor de R2 com o valor de tempR2 e armazena o resultado em R2
INCC                                                                            ;Rotina de finiliza��o da itera��o do loop externo.
	DECF iterator,1                                                         ;Decrementa o valor de iterator
	INCF counter,1                                                          ;Incrementa o valor de counter
	GOTO LOOP                                                               ;"Pula" para o incio do loop externo
	;CORPO DA ROTINA PRINCIPAL
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END
