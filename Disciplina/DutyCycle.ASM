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
		COUNTER1
		COUNTER2

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

DELAY1                                                                          ;Subrotina de delay de semiciclo ALTO. É quase idêntida a subrotina de delay de semiciclo BAIXO, sendo a única diferença a variável que utilizam para contar a quantidade de delays a serem feitos.
    _SET
	MOVLW .169
	MOVWF TMR0                                                              ;Para sincronizar o timer de modo com que o delay tomado seja o mais próximo do desejado, TMR0 recebe um offset.
    LOOP
	BTFSS INTCON, 2                                                         ;Verifica se ocorreu overflow em TMR0
	GOTO LOOP                                                               ;Volta a verificar enquanto não ocorrer overflow
	BCF INTCON, 2                                                           ;Limpa o bit de flag para o overflow do timer
	DECFSZ COUNTER1                                                         ;decrementa o contador de delays. Caso o resultado seja zero, a função retorna, pois o tempo desejado para o semiciclo ALTO já passou.
	GOTO _SET                                                               ;Enquanto o contador não for zerado, volta a executar o delay.
	
	RETURN
DELAY2                                                                          ;Subrotina de delay de semiciclo BAIXO. É quase idêntida a subrotina de delay de semiciclo ALTO, sendo a única diferença a variável que utilizam para contar a quantidade de delays a serem feitos.
    _SET2
	MOVLW .169
	MOVWF TMR0                                                              ;Para sincronizar o timer de modo com que o delay tomado seja o mais próximo do desejado, TMR0 recebe um offset.
    LOOP2
	BTFSS INTCON, 2                                                         ;Verifica se ocorreu overflow em TMR0
	GOTO LOOP2                                                              ;Volta a verificar enquanto não ocorrer overflow
	BCF INTCON, 2                                                           ;Limpa o bit de flag para o overflow do timer
	DECFSZ COUNTER2                                                         ;decrementa o contador de delays. Caso o resultado seja zero, a função retorna, pois o tempo desejado para o semiciclo BAIXO já passou.
	GOTO _SET2                                                              ;Enquanto o contador não for zerado, volta a executar o delay.
	
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;*              Duty Cycle Controlado por entradas                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00001011' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00001000'                                                     ;Para uma maior precisão, OPTION_REG é configurado de tal forma que TMR0 seja incrementado a cada ciclo de instrução
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* O presente programa controla o duty cycle de uma onda quadrada  *
;* em GPIO 5, de frequência 500 Hz, com base nos valores lidos em  *
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
;* Desta forma, a lógica do programa consiste em definir os valores*
;* dos contadores para que os semiciclos se aproximem ao máximo do *
;* duty cicle desejado, verificando o estado dos pinos GPIO 0 e    *
;* GPIO 1; Em seguida, mudar o valor da saída para o estado da vez *
;* e então chamar a rotina de delay de 5% do periodo quantas vezes *
;* forem necessárias para obedecer o duty cylce selecionado.       *
;* Após finalizar um periodo da onda (2ms), o estado das chaves é  *
;* verificado novamente, atualizando os valores nos contadores para*
;* a nova configuração, que pode ser a mesma que a anterior.       *
;*                                                                 *
;* Vale salientar que não foi possível atingir uma precisão de 100%*
;* acerca dos valores das especificações, sendo a real frequência  *
;* da onda de saída ~503.78 Hz, e os duty cycles das configurações:*
;* 00: Duty Cycle = ~5.3%                                          *
;* 01: Duty Cycle = ~20.1%                                         *
;* 10: Duty Cycle = ~59.6%                                         *
;* 11: Duty Cycle = 100%                                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	NOP									;NOPS para melhor sincronização. Os ciclos de execução(periodo da onda de saída
	NOP
	MOVLW .1                                                                ;Work recebe o valor padrão 1. Dependendo dos testes de GPIO 0 e GPIO 1 este valor pode mudar ou continuar o mesmo.
	BTFSC GPIO, 0                                                           
	GOTO _HIGH                                                              ;Caso GPIO 0 seja 1, o programa vai para a sequencia de instruções entiquetada de _HIGH, onde o valor de Work é atualizado de acordo.
	BTFSC GPIO, 1                                                           ;Caso GPIO 0 seja 0, este teste é realizado(caso contrário, ele seria pulado).
	MOVLW .12                                                               ;Se GPIO 1 for 1, Work recebe o valor 12, pois a configuração de entradas é 10, ou seja, o duty cycle desejado é 60%
	GOTO APPLY
_HIGH
	MOVLW .20                                                               ;Caso GPIO 0 seja 1, Work recebe o valor 20.
	BTFSS GPIO, 1                                                           ;Caso GPIO 1 seja 1, Work continua com o valor 20.
	MOVLW .4                                                                ;Caso GPIO 1 seja 0, temos a configuração 01, que indica um duty cycle de 20%, portanto work recebe 4
APPLY
	MOVWF COUNTER1                                                          ;O contador de semiciclo ALTO recebe o valor de work. Este valor indica quantas vezes a função de delay será chamada no semiciclo ALTO da onda de saída. Como o delay é de 5% do periodo da onda, este valor varia entre 1, 4, 12 e 20 a depender da confiuração das entradas.
	SUBLW .20
	MOVWF COUNTER2                                                          ;O contador de semiciclo BAIXO recebe 20 - Contador1, de forma com que a quantidade total de vezes na qual a subrotina de delay de 5% é chamada seja 20, configurando um periodo completo da onda de saída.
	BSF GPIO, 5                                                             ;Seta o valor da saída para ALTO
	CALL DELAY1                                                             ;Chama a função de delay de semicilo ALTO, que espera até a quantidade desejada de tempo tenha se passado no semiciclo ALTO antes de continuar com a execução da rotina principal.
	
	MOVF COUNTER2, 1                                                        ;Verifica se o contador de semiciclo BAIXO está zerado. Caso ele esteja, isso significa que o dutycycle é 100% e portanto não se deve considerar um semiciclo baixo.
	BTFSC STATUS, 2
	GOTO MAIN
	BCF GPIO, 5                                                             ;Limpa o valor da saída para BAIXO
	CALL DELAY2                                                             ;Chama a função de delay de semicilo BAIXO, que espera até a quantidade desejada de tempo tenha se passado no semiciclo BAIXO antes de continuar com a execução da rotina principal.
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
