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
		COUNTER1
		COUNTER2

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

DELAY1                                                                          ;Subrotina de delay de semiciclo ALTO. � quase id�ntida a subrotina de delay de semiciclo BAIXO, sendo a �nica diferen�a a vari�vel que utilizam para contar a quantidade de delays a serem feitos.
    _SET
	MOVLW .169
	MOVWF TMR0                                                              ;Para sincronizar o timer de modo com que o delay tomado seja o mais pr�ximo do desejado, TMR0 recebe um offset.
    LOOP
	BTFSS INTCON, 2                                                         ;Verifica se ocorreu overflow em TMR0
	GOTO LOOP                                                               ;Volta a verificar enquanto n�o ocorrer overflow
	BCF INTCON, 2                                                           ;Limpa o bit de flag para o overflow do timer
	DECFSZ COUNTER1                                                         ;decrementa o contador de delays. Caso o resultado seja zero, a fun��o retorna, pois o tempo desejado para o semiciclo ALTO j� passou.
	GOTO _SET                                                               ;Enquanto o contador n�o for zerado, volta a executar o delay.
	
	RETURN
DELAY2                                                                          ;Subrotina de delay de semiciclo BAIXO. � quase id�ntida a subrotina de delay de semiciclo ALTO, sendo a �nica diferen�a a vari�vel que utilizam para contar a quantidade de delays a serem feitos.
    _SET2
	MOVLW .169
	MOVWF TMR0                                                              ;Para sincronizar o timer de modo com que o delay tomado seja o mais pr�ximo do desejado, TMR0 recebe um offset.
    LOOP2
	BTFSS INTCON, 2                                                         ;Verifica se ocorreu overflow em TMR0
	GOTO LOOP2                                                              ;Volta a verificar enquanto n�o ocorrer overflow
	BCF INTCON, 2                                                           ;Limpa o bit de flag para o overflow do timer
	DECFSZ COUNTER2                                                         ;decrementa o contador de delays. Caso o resultado seja zero, a fun��o retorna, pois o tempo desejado para o semiciclo BAIXO j� passou.
	GOTO _SET2                                                              ;Enquanto o contador n�o for zerado, volta a executar o delay.
	
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;*              Duty Cycle Controlado por entradas                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00001011' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00001000'                                                     ;Para uma maior precis�o, OPTION_REG � configurado de tal forma que TMR0 seja incrementado a cada ciclo de instru��o
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* O presente programa controla o duty cycle de uma onda quadrada  *
;* em GPIO 5, de frequ�ncia 500 Hz, com base nos valores lidos em  *
;* GPIO 0 e GPIO 1, seguindo a seguinte tabela:                    *
;*                                                                 *
;*	    | GPIO 1 | GPIO 0 | Duty Cycle |                       *
;*	    |   0    |   0    |     5%     |                       *
;*	    |   0    |   1    |     20%    |                       *
;*	    |   1    |   0    |     60%    |                       *
;*	    |   1    |   1    |    100%    |                       *
;*                                                                 *
;* Para implementar tal funcionalidade, foi implementada uma       *
;* subrotina de delay de ~100 us, ou seja, ~5% do periodo da onda  *
;* alvo, em conjunto com dois contadores, um para definir quantos  *
;* delays a onda deve passar no semiciclo de estado ALTO, e outro  *
;* para definir quantos delays a onda deve passar no semiciclo de  *
;* estado BAIXO, seguindo a tabela acima.                          *
;*                                                                 *	
;* Desta forma, a l�gica do programa consiste em definir os valores*
;* dos contadores para que os semiciclos se aproximem ao m�ximo do *
;* duty cicle desejado, verificando o estado dos pinos GPIO 0 e    *
;* GPIO 1; Em seguida, mudar o valor da sa�da para o estado da vez *
;* e ent�o chamar a rotina de delay de 5% do periodo quantas vezes *
;* forem necess�rias para obedecer o duty cylce selecionado.       *
;* Ap�s finalizar um periodo da onda (2ms), o estado das chaves �  *
;* verificado novamente, atualizando os valores nos contadores para*
;* a nova configura��o, que pode ser a mesma que a anterior.       *
;*                                                                 *
;* Vale salientar que n�o foi poss�vel atingir uma precis�o de 100%*
;* acerca dos valores das especifica��es, sendo a real frequ�ncia  *
;* da onda de sa�da ~503.78 Hz, e os duty cycles das configura��es:*
;* 00: Duty Cycle = ~5.3%                                          *
;* 01: Duty Cycle = ~20.1%                                         *
;* 10: Duty Cycle = ~59.6%                                         *
;* 11: Duty Cycle = 100%                                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	NOP									;NOPS para melhor sincroniza��o. Os ciclos de execu��o(periodo da onda de sa�da
	NOP
	MOVLW .1                                                                ;Work recebe o valor padr�o 1. Dependendo dos testes de GPIO 0 e GPIO 1 este valor pode mudar ou continuar o mesmo.
	BTFSC GPIO, 0                                                           
	GOTO _HIGH                                                              ;Caso GPIO 0 seja 1, o programa vai para a sequencia de instru��es entiquetada de _HIGH, onde o valor de Work � atualizado de acordo.
	BTFSC GPIO, 1                                                           ;Caso GPIO 0 seja 0, este teste � realizado(caso contr�rio, ele seria pulado).
	MOVLW .12                                                               ;Se GPIO 1 for 1, Work recebe o valor 12, pois a configura��o de entradas � 10, ou seja, o duty cycle desejado � 60%
	GOTO APPLY
_HIGH
	MOVLW .20                                                               ;Caso GPIO 0 seja 1, Work recebe o valor 20.
	BTFSS GPIO, 1                                                           ;Caso GPIO 1 seja 1, Work continua com o valor 20.
	MOVLW .4                                                                ;Caso GPIO 1 seja 0, temos a configura��o 01, que indica um duty cycle de 20%, portanto work recebe 4
APPLY
	MOVWF COUNTER1                                                          ;O contador de semiciclo ALTO recebe o valor de work. Este valor indica quantas vezes a fun��o de delay ser� chamada no semiciclo ALTO da onda de sa�da. Como o delay � de 5% do periodo da onda, este valor varia entre 1, 4, 12 e 20 a depender da confiura��o das entradas.
	SUBLW .20
	MOVWF COUNTER2                                                          ;O contador de semiciclo BAIXO recebe 20 - Contador1, de forma com que a quantidade total de vezes na qual a subrotina de delay de 5% � chamada seja 20, configurando um periodo completo da onda de sa�da.
	BSF GPIO, 5                                                             ;Seta o valor da sa�da para ALTO
	CALL DELAY1                                                             ;Chama a fun��o de delay de semicilo ALTO, que espera at� a quantidade desejada de tempo tenha se passado no semiciclo ALTO antes de continuar com a execu��o da rotina principal.
	
	MOVF COUNTER2, 1                                                        ;Verifica se o contador de semiciclo BAIXO est� zerado. Caso ele esteja, isso significa que o dutycycle � 100% e portanto n�o se deve considerar um semiciclo baixo.
	BTFSC STATUS, 2
	GOTO MAIN
	BCF GPIO, 5                                                             ;Limpa o valor da sa�da para BAIXO
	CALL DELAY2                                                             ;Chama a fun��o de delay de semicilo BAIXO, que espera at� a quantidade desejada de tempo tenha se passado no semiciclo BAIXO antes de continuar com a execu��o da rotina principal.
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
