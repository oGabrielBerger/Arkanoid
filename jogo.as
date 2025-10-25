;------------------------------------------------------------------------------
; ZONA I: Definição de constantes
;         Pseudo-instrução : EQU
;------------------------------------------------------------------------------

CR                          EQU     0Ah
IO_READ                     EQU     FFFFh
IO_WRITE                    EQU     FFFEh
IO_STATUS                   EQU     FFFDh
INITIAL_SP                  EQU     FDFFh
CURSOR                      EQU     FFFCh
CURSOR_INIT                 EQU     FFFFh
UNIDADE_CONTAGEM            EQU     FFF6h
TEMPORIZADOR                EQU     FFF7h
ROW_SHIFT                   EQU     8

FIM_TEXTO                   EQU     '@'
NUMLINES                    EQU     24
MAP_LINE_LENGTH             EQU     81d
ON                          EQU     1d
OFF                         EQU     0d

DIREITA_CIMA                EQU     0d
DIREITA_BAIXO               EQU     1d
ESQUERDA_CIMA               EQU     2d
ESQUERDA_BAIXO              EQU     3d

LINHA_INICIAL_BOLA          EQU     22d
COLUNA_INICIAL_BOLA         EQU     39d

;------------------------------------------------------------------------------
; ZONA II: Definição de linhas e variáveis 
;------------------------------------------------------------------------------

                            ORIG    8000h

; usado para ser printado
Line0                       STR     '================================================================================', FIM_TEXTO
Line1                       STR     '| pontuacao: 000                                                      vidas: 3 |', FIM_TEXTO
Line2                       STR     '================================================================================', FIM_TEXTO
Line3                       STR     '                                                                                ', FIM_TEXTO
Line4                       STR     '      www  www  www  www  www  www  www  www  www  www  www  www  www  www      ', FIM_TEXTO
Line5                       STR     '                                                                                ', FIM_TEXTO
Line6                       STR     '      www  www  www  www  www  www  www  www  www  www  www  www  www  www      ', FIM_TEXTO
Line7                       STR     '                                                                                ', FIM_TEXTO
Line8                       STR     '      www  www  www  www  www  www  www  www  www  www  www  www  www  www      ', FIM_TEXTO
Line9                       STR     '                                                                                ', FIM_TEXTO
Line10                      STR     '      www  www  www  www  www  www  www  www  www  www  www  www  www  www      ', FIM_TEXTO
Line11                      STR     '                                                                                ', FIM_TEXTO 
Line12                      STR     '      www  www  www  www  www  www  www  www  www  www  www  www  www  www      ', FIM_TEXTO 
Line13                      STR     '                                                                                ', FIM_TEXTO
Line14                      STR     '                                                                                ', FIM_TEXTO
Line15                      STR     '                                                                                ', FIM_TEXTO
Line16                      STR     '                                                                                ', FIM_TEXTO
Line17                      STR     '                                                                                ', FIM_TEXTO
Line18                      STR     '                                                                                ', FIM_TEXTO
Line19                      STR     '                                                                                ', FIM_TEXTO
Line20                      STR     '                                                                                ', FIM_TEXTO
Line21                      STR     '                                                                                ', FIM_TEXTO
Line22                      STR     '                                       O                                        ', FIM_TEXTO
Line23                      STR     '                                     _____                                      ', FIM_TEXTO

; usado na movimentacao da nave
Space                       STR     ' ', FIM_TEXTO
InNave                      STR     '_', FIM_TEXTO
ShipCol                     WORD    37


; usado ao reiniciar apos perda de vida
ShipStr    STR     '_____', FIM_TEXTO
BlankShip  STR     '     ', FIM_TEXTO

; usado para movmento da bola
Ball                        STR     'O', FIM_TEXTO
LinhaBola                   WORD    LINHA_INICIAL_BOLA
ColunaBola                  WORD    COLUNA_INICIAL_BOLA
DirecaoBola                 WORD    DIREITA_CIMA

; usado para checagem de vida e fim de jogo
Vida                        WORD    3
VidasStr                    STR     ' ', FIM_TEXTO
GameOverMsg                 STR     '--- FIM DE JOGO ---', FIM_TEXTO
GameOverMsgByWinning        STR     '--- VOCE VENCEU! ---', FIM_TEXTO

; usado para checagem e calculo da pontuacao
Pontuacao                   WORD    0
PontuacaoStr                STR     '000', FIM_TEXTO

;------------------------------------------------------------------------------
; ZONA III: Tabela de interrupções
;------------------------------------------------------------------------------

                            ORIG    FE00h
INT0                        WORD    GoRight
INT1                        WORD    GoLeft

                            ORIG    FE0Fh
INT15                       WORD    Timer

;------------------------------------------------------------------------------
; ZONA IV: Interrupções e Funções
;------------------------------------------------------------------------------

                            ORIG    0000h
                            JMP     Main

;------------------------------------------------------------------------------
; Interrupção GoRight
;------------------------------------------------------------------------------

GoRight:                    PUSH    R1
                            PUSH    R2
                            PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            MOV     R1, M[ShipCol]
                            CMP     R1, 75
                            JMP.Z   GoRightEnd        

                            MOV     R6, 23            
                            MOV     R7, R1            
                            MOV     R5, Space
                            CALL    PrintF

                            INC     R1

                            MOV     R2, R1
                            ADD     R2, 4

                            MOV     R7, R2            
                            MOV     R5, InNave        
                            CALL    PrintF

                            MOV     M[ShipCol], R1

GoRightEnd:                 POP     R7
                            POP     R6
                            POP     R5
                            POP     R2
                            POP     R1
                            RTI

;------------------------------------------------------------------------------
; Interrupção GoLeft
;------------------------------------------------------------------------------

GoLeft:                     PUSH    R1
                            PUSH    R2
                            PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            MOV     R1, M[ShipCol]
                            CMP     R1, 0
                            JMP.Z   GoLeftEnd

                            MOV     R2, R1
                            ADD     R2, 4

                            MOV     R6, 23
                            MOV     R7, R2
                            MOV     R5, Space
                            CALL    PrintF

                            DEC     R1

                            MOV     R6, 23
                            MOV     R7, R1
                            MOV     R5, InNave
                            CALL    PrintF

                            MOV     M[ShipCol], R1

GoLeftEnd:                  POP     R7
                            POP     R6
                            POP     R5
                            POP     R2
                            POP     R1
                            RTI

;------------------------------------------------------------------------------
; Interrupção Timer
;------------------------------------------------------------------------------

Timer:                      CALL    MovimentaBolaInicio
                            CALL    ConfiguraTimer
                            RTI

;------------------------------------------------------------------------------
; Função ConfiguraTimer
;------------------------------------------------------------------------------

ConfiguraTimer:             PUSH    R1

                            MOV     R1, 3d
                            MOV     M[UNIDADE_CONTAGEM], R1
                            MOV     R1, ON
                            MOV     M[TEMPORIZADOR], R1

                            POP     R1
                            RET
                            
;------------------------------------------------------------------------------
; Função MovimentaBolaInicio
;------------------------------------------------------------------------------

MovimentaBolaInicio:        PUSH    R1
                            PUSH    R2
                            PUSH    R3
                            PUSH    R4
                            PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            MOV     R2, M[LinhaBola]
                            MOV     R3, M[ColunaBola]
                            MOV     R1, M[DirecaoBola]

                            CMP     R1, DIREITA_CIMA
                            JMP.Z   PrevDirCima
                            CMP     R1, DIREITA_BAIXO
                            JMP.Z   PrevDirBaixo
                            CMP     R1, ESQUERDA_CIMA
                            JMP.Z   PrevEsqCima
                            CMP     R1, ESQUERDA_BAIXO
                            JMP.Z   PrevEsqBaixo

PrevDirCima:                DEC     R2
                            INC     R3
                            JMP     ChecaColisao

PrevDirBaixo:               INC     R2
                            INC     R3
                            JMP     ChecaColisao

PrevEsqCima:                DEC     R2
                            DEC     R3
                            JMP     ChecaColisao

PrevEsqBaixo:               INC     R2
                            DEC     R3
                            JMP     ChecaColisao

                            ; Checa topo da tela
ChecaColisao:               CMP     R2, 2
                            JMP.Z   ColideVert

                            ; Checa borda esquerda
                            CMP     R3, 0
                            JMP.Z   ColideHor

                            ; Checa borda direita
                            CMP     R3, 79
                            JMP.Z   ColideHor

                            ; Checagem com os blocos
                            CALL    ChecaColisaoBlocos  ; verificar quantidade de linhas completas e depois somar a coluna do bloco que eu estou / verificar M[R7 + Line0] == ' ' / 'w'
                            CMP     R7, 1d
                            JMP.Z   MovimentoBolaFim

                            ; Checa colisão com a nave 
                            CMP     R2, 22
                            JMP.N   ChecaColisaoFim ; ainda bem acima → nada a fazer
                            CMP     R2, 23
                            JMP.Z   ChecaNave ; está na linha da nave → testa colisão
                            CMP     R2, 24
                            JMP.P   FazReinicio ; exatamente na linha da nave → testa colisão
                            ; se R2 > 23 → passou do chão
                            JMP     ChecaColisaoFim

ChecaNave:                  MOV     R4, M[ShipCol]
                            MOV     R1, R4
                            ADD     R1, 4
                            CMP     R3, R4 ; coluna da bola < início nave?
                            JMP.N   FazReinicio ; não colidiu
                            CMP     R3, R1 ; coluna da bola > fim da nave?
                            JMP.P   FazReinicio ; não colidiu

                            ; Verifica se esta encostando na parede lateral
                            CMP R3, 0
                            JMP.Z   ChecaColisaoFim   ; evita dupla inversao
                            CMP R3, 79
                            JMP.Z   ChecaColisaoFim   ; evita dupla inversao
                            
                            CALL    InverteVertical
                            JMP     ChecaColisaoFim
                            

ChecaColisaoFim:            JMP     FazMovimento

FazReinicio:                CALL    ReiniciaBola
                            JMP     MovimentoBolaFim

ColideVert:                 CALL    InverteVertical
                            JMP     FazMovimento

ColideHor:                  CALL    InverteHorizontal

                            ; após inverter horizontalmente, verifica se está na linha da nave (descendo)
                            MOV     R1, M[DirecaoBola]
                            CMP     R1, DIREITA_BAIXO
                            JMP.Z   TestaNaveDepoisParede
                            CMP     R1, ESQUERDA_BAIXO
                            JMP.Z   TestaNaveDepoisParede
                            JMP     FazMovimento

TestaNaveDepoisParede:      MOV     R4, M[ShipCol]
                            MOV     R1, R4
                            ADD     R1, 4
                            CMP     R2, 23
                            JMP.NZ  FazMovimento ; não está na linha da nave

                            CMP     R3, R4
                            JMP.N   FazMovimento
                            CMP     R3, R1
                            JMP.P   FazMovimento

                            CALL    InverteVertical ; rebate na nave após parede
                            JMP     FazMovimento

FazMovimento:               MOV     R1, M[DirecaoBola]

                            CMP     R1, DIREITA_CIMA
                            JMP.Z   MovimentoBolaDireitaCima
                            CMP     R1, DIREITA_BAIXO
                            JMP.Z   MovimentoBolaDireitaBaixo
                            CMP     R1, ESQUERDA_CIMA
                            JMP.Z   MovimentoBolaEsquerdaCima
                            CMP     R1, ESQUERDA_BAIXO
                            JMP.Z   MovimentoBolaEsquerdaBaixo

MovimentoBolaDireitaCima:   MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Space
                            CALL PrintF

                            DEC M[LinhaBola]
                            INC M[ColunaBola]

                            MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Ball
                            CALL PrintF

                            JMP MovimentoBolaFim

MovimentoBolaDireitaBaixo:  MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Space
                            CALL PrintF

                            INC M[LinhaBola]
                            INC M[ColunaBola]

                            MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Ball
                            CALL PrintF

                            JMP MovimentoBolaFim

MovimentoBolaEsquerdaCima:  MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Space
                            CALL PrintF

                            DEC M[LinhaBola]
                            DEC M[ColunaBola]

                            MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Ball
                            CALL PrintF

                            JMP MovimentoBolaFim

MovimentoBolaEsquerdaBaixo: MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Space
                            CALL PrintF

                            INC M[LinhaBola]
                            DEC M[ColunaBola]

                            MOV R6, M[LinhaBola]
                            MOV R7, M[ColunaBola]
                            MOV R5, Ball
                            CALL PrintF

MovimentoBolaFim:           POP     R7
                            POP     R6
                            POP     R5
                            POP     R4
                            POP     R3
                            POP     R2
                            POP     R1
                            RET

;------------------------------------------------------------------------------
; Funções de Inversão de Direção
;------------------------------------------------------------------------------

; inverte a direcao vertical tendo em vista a anterior 

InverteVertical:            PUSH    R1

                            MOV     R1, M[DirecaoBola]
                            
                            CMP     R1, DIREITA_CIMA
                            JMP.Z   VertDC
                            CMP     R1, DIREITA_BAIXO
                            JMP.Z   VertDB
                            CMP     R1, ESQUERDA_CIMA
                            JMP.Z   VertEC
                            CMP     R1, ESQUERDA_BAIXO
                            JMP.Z   VertEB

VertDC:                     MOV     R1, DIREITA_BAIXO
                            MOV     M[DirecaoBola], R1
                            JMP     VertFim

VertDB:                     MOV     R1, DIREITA_CIMA
                            MOV     M[DirecaoBola], R1
                            JMP     VertFim

VertEC:                     MOV     R1, ESQUERDA_BAIXO
                            MOV     M[DirecaoBola], R1
                            JMP     VertFim

VertEB:                     MOV     R1, ESQUERDA_CIMA
                            MOV     M[DirecaoBola], R1

VertFim:                    POP     R1
                            RET

; inverte a direcao horizontal tendo em vista a anterior 

InverteHorizontal:          PUSH    R1

                            MOV     R1, M[DirecaoBola]
                            
                            CMP     R1, DIREITA_CIMA
                            JMP.Z   HorDC
                            CMP     R1, DIREITA_BAIXO
                            JMP.Z   HorDB
                            CMP     R1, ESQUERDA_CIMA
                            JMP.Z   HorEC
                            CMP     R1, ESQUERDA_BAIXO
                            JMP.Z   HorEB

HorDC:                      MOV     R1, ESQUERDA_CIMA
                            MOV     M[DirecaoBola], R1
                            JMP     HorFim

HorDB:                      MOV     R1, ESQUERDA_BAIXO
                            MOV     M[DirecaoBola], R1
                            JMP     HorFim

HorEC:                      MOV     R1, DIREITA_CIMA
                            MOV     M[DirecaoBola], R1
                            JMP     HorFim

HorEB:                      MOV     R1, DIREITA_BAIXO
                            MOV     M[DirecaoBola], R1

HorFim:                     POP     R1
                            RET

;------------------------------------------------------------------------------
; Função Reinicio da Bola
;------------------------------------------------------------------------------

ReiniciaBola:               PUSH    R1
                            PUSH    R2
                            PUSH    R3
                            PUSH    R4
                            PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            ; Diminui vida
                            MOV     R1, M[Vida]
                            DEC     R1
                            MOV     M[Vida], R1

                            ; Atualiza string VidasStr
                            ADD     R1, '0' ; "transforma" (soma o valor em ascii) o valor da vida em uma string
                            MOV     M[VidasStr], R1

                            ; Imprime numero de vidas no menu
                            MOV     R6, 1              
                            MOV     R7, 77             
                            MOV     R5, VidasStr
                            CALL    PrintF

                            ; Checa fim de jogo
                            MOV     R1, M[Vida]
                            CMP     R1, 0
                            JMP.NZ  ContinuaReinicio

                            ; FIM DE JOGO
                            MOV     R6, 14  ; Linha central da tela
                            MOV     R7, 30  ; Coluna centralizada
                            MOV     R5, GameOverMsg
                            CALL    PrintF
                            JMP     Halt ; loop infinito / fim do codigo

                            ; Apaga a bola da posição atual
ContinuaReinicio:           MOV     R6, M[LinhaBola]
                            MOV     R7, M[ColunaBola]
                            MOV     R5, Space
                            CALL    PrintF

                            ; apaga 5 colunas da nave na posicao atual
                            MOV     R1, M[ShipCol]
                            MOV     R6, 23
                            MOV     R7, R1
                            MOV     R5, BlankShip
                            CALL    PrintF

                            ; reposiciona valores iniciais (já no seu código)
                            MOV     R2, LINHA_INICIAL_BOLA
                            MOV     R3, COLUNA_INICIAL_BOLA
                            MOV     R4, 37 ; posição inicial da nave

                            MOV     M[LinhaBola], R2
                            MOV     M[ColunaBola], R3
                            MOV     R1, DIREITA_CIMA ; direcao inicial
                            MOV     M[DirecaoBola], R1 

                            MOV     M[ShipCol], R4

                            ; redesenha a bola na posição inicial
                            MOV     R6, R2
                            MOV     R7, R3
                            MOV     R5, Ball
                            CALL    PrintF

                            ; redesenha a nave inteira na posição inicial (5 colunas)
                            MOV     R6, 23
                            MOV     R7, R4
                            MOV     R5, ShipStr
                            CALL    PrintF

                            POP     R7
                            POP     R6
                            POP     R5
                            POP     R4
                            POP     R3
                            POP     R2
                            POP     R1
                            RET

;------------------------------------------------------------------------------
; Função Colisão com 'w'
;------------------------------------------------------------------------------

ChecaColisaoBlocos:         PUSH    R1
                            PUSH    R2
                            PUSH    R3
                            PUSH    R4
                            PUSH    R5
                            PUSH    R6

                            ; calcula endereco do caractere na memoria
                            ; endereco = Line0 + linha*81 + coluna
                            MOV     R4, R2 ; soma a linha
                            SHL     R4, 6  ; soma a linha*2^6 = linha*64

                            MOV     R1, R2 ; soma em outro registrador a linha
                            SHL     R1, 4  ; soma em outro registrador a linha*2^4 = linha*16

                            ADD     R4, R1 ; soma os dois registradores, ficando linha*80
                            ADD     R4, R2  ; por fim, soma mais uma vez a linha, para enfim: linha*81

                            ADD     R4, R3 ; soma a coluna

                            MOV     R1, Line0
                            ADD     R4, R1 ; soma Line0

                            ; le o caractere do mapa
                            MOV     R5, M[R4]
                            CMP     R5, 'w'
                            JMP.NZ  NaoColidiu

                            ; apaga o bloco
                            MOV     R5, ' '
                            MOV     M[R4], R5

                            ; atualiza na tela
                            MOV     R6, R2
                            MOV     R7, R3
                            MOV     R5, Space
                            CALL    PrintF

                            ; rebate verticalmente
                            CALL    InverteVertical

                            CALL    AtualizaPontuacao

                            ; indica colisao
                            MOV     R7, 1
                            JMP     FimChecaColisaoBlocos

NaoColidiu:                 MOV     R7, 0

FimChecaColisaoBlocos:      POP     R6
                            POP     R5
                            POP     R4
                            POP     R3
                            POP     R2
                            POP     R1
                            RET


;------------------------------------------------------------------------------
; Função AtualizaPontuacao
;------------------------------------------------------------------------------

AtualizaPontuacao:          PUSH    R1
                            PUSH    R2
                            PUSH    R3
                            PUSH    R4
                            PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            ; Incrementa pontuação
                            MOV     R1, M[Pontuacao]
                            INC     R1
                            MOV     M[Pontuacao], R1

                            ; Centena = R1 / 100
                            MOV     R2, 100
                            DIV     R1, R2      ; R1 = quociente (centena), R2 = resto
                            MOV     R3, R1      ; R3 = dígito da centena

                            ; Dezena = R2 / 10
                            MOV     R1, R2      ; R1 = resto anterior
                            MOV     R2, 10
                            DIV     R1, R2      ; R1 = quociente (dezena), R2 = resto
                            MOV     R4, R1      ; R4 = dígito da dezena

                            ; Unidade = R2 (resto final)
                            MOV     R5, R2      ; R5 = unidade

                            ADD     R3, '0'
                            ADD     R4, '0'
                            ADD     R5, '0'

                            ; Escreve na string
                            MOV     R1, PontuacaoStr
                            MOV     M[R1], R3
                            INC     R1

                            MOV     M[R1], R4
                            INC     R1

                            MOV     M[R1], R5
                            INC     R1

                            MOV R2, FIM_TEXTO
                            MOV M[R1], R2

                            ; Reimprime pontuação na tela
                            MOV     R6, 1       ; linha 1
                            MOV     R7, 13      ; coluna onde começa '000' após "pontuacao: "
                            MOV     R5, PontuacaoStr
                            CALL    PrintF

                            MOV     R1, 210d
                            CMP     M[Pontuacao], R1  ; max = 210
                            JMP.Z Vitoria

                            POP     R7
                            POP     R6
                            POP     R5
                            POP     R4
                            POP     R3
                            POP     R2
                            POP     R1
                            RET
;------------------------------------------------------------------------------
; Função Vitoria
;------------------------------------------------------------------------------

Vitoria:                    PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            MOV     R7, 30
                            MOV     R6, 14
                            MOV     R5, GameOverMsgByWinning
                            CALL    PrintF
                            JMP     Halt

                            POP     R7
                            POP     R6
                            POP     R5

;------------------------------------------------------------------------------
; Função PrintF
;------------------------------------------------------------------------------

PrintF:                     PUSH    R1
                            PUSH    R2
                            PUSH    R3
                            PUSH    R4
                            PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            MOV     R4, 0   ; contador das colunas

PrintFCycle:                MOV     R1, R6  ; linhas recebidas de R6
                            MOV     R2, R7  ; colunas recebidas de R7
                            ADD     R2, R4
                            SHL     R1, ROW_SHIFT
                            OR      R1, R2
                            MOV     M[CURSOR], R1

                            MOV     R3, M[R5] ; conteudo recebido de R5
                            CMP     R3, FIM_TEXTO
                            JMP.Z   PrintFFim

                            MOV     M[IO_WRITE], R3
                            INC     R5
                            INC     R4
                            JMP     PrintFCycle

PrintFFim:                  POP     R7
                            POP     R6
                            POP     R5
                            POP     R4
                            POP     R3
                            POP     R2
                            POP     R1
                            RET

;------------------------------------------------------------------------------
; Função PrintAllLines
;------------------------------------------------------------------------------

PrintAllLines:              PUSH    R1
                            PUSH    R2
                            PUSH    R5
                            PUSH    R6
                            PUSH    R7

                            MOV     R1, 0
                            MOV     R2, Line0
                            MOV     R6, 0
                            MOV     R7, 0

LoopPrintLines:             CMP     R1, NUMLINES
                            JMP.Z   EndPrintAllLines

                            MOV     R5, R2
                            CALL    PrintF

                            ADD     R2, MAP_LINE_LENGTH
                            INC     R6
                            INC     R1
                            JMP     LoopPrintLines

EndPrintAllLines:           POP     R7
                            POP     R6
                            POP     R5
                            POP     R2
                            POP     R1
                            RET

;------------------------------------------------------------------------------
; Função Main
;------------------------------------------------------------------------------

Main:                       ENI
                            MOV     R1, INITIAL_SP
                            MOV     SP, R1
                            MOV     R1, CURSOR_INIT
                            MOV     M[CURSOR], R1
                            
                            CALL    PrintAllLines
                            CALL    ConfiguraTimer

Cycle:                      BR      Cycle
Halt:                       BR      Halt
