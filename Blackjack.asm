.data
boas_vindas: .string "Vamos jogar Blackjack! Escolha uma opcao (0 - Jogar, 1 - Sair):\n"
escolheu_nao_jogar: .string "Obrigado por nao jogar!\n"
escolheu_jogar: .string "Bem-vindo ao Blackjack!!\n"
inicio_rodada: .string "Nova rodada.\n"
mao_do_jogador: .string "Mao do jogador:\n"
mao_do_dealer: .string "Mao do dealer: \n"
concatenar_cartas: .string "e\n"
pontuacao: .string "Pontuacao:\n"
escolher_movimento: .string "O que deseja pedir? (1 - Hit, 2 - Stand)\n"
jogador_pede_hit: .string "Jogador pediu Hit!\n"
jogador_pede_stand: .string "Jogador pediu Stand\n"
dealer_para: .string "Dealer parou, pontuacao maior ou igual a 17\n"
jogador_recebe_carta_nova: .string "Jogador recebeu a carta:\n"
dealer_recebe_carta_nova: .string "Dealer recebeu a carta:\n"
aviso_mao_cheia_jogador: .string "Mao do jogador cheia!\n"
aviso_mao_cheia_dealer: .string "Mao do dealer cheia!\n"
aviso_estouro: .string "Estourou!!\n"
aviso_opcao_invalida: .string "Opcao invalida.\n"
vez_do_dealer: .string "Hora do dealer!\n"
revelacao_carta_oculta: .string "Dealer revela sua carta secreta...\n"
dealer_pediu_hit: .string "Dealer precisa comprar, pontuacao inferior a 17.\n"
apresentar_resultado_final: .string "Resultados finais:\n"
pontuacao_final_jogador: .string "Pontuacao final do jogador:\n"
pontuacao_final_dealer: .string "Pontuacao final do dealer:\n"
vitoria_jogador: .string "Jogador venceu!!!!!!\n"
vitoria_dealer: .string "Dealer venceu!!!!!!\n"
empate: .string "O jogo terminou empatado!\n"
mensagemfinal: .string "Deseja jogar novamente? (0 - Sim, 1 - Nao)\n" 
mais: .string "+"
igual: .string "="
nova_linha: .string "\n"

# Vetores que armazenam as cartas
mao_jogador: .space 40 # Limitamos em 10 cartas, 10 x 4 bytes/carta = 40 bytes
mao_dealer: .space 40

# Contadores 
num_cartas_jogador: .word 0
num_cartas_dealer: .word 0

# Somas
soma_jogador: .word 0
soma_dealer: .word 0

# Duas variaveis auxiliares
opcao_jogar: .word 0
movimento_jogador: .word 0

.text

.globl main

main:
    # Exibe mensagem de boas-vindas
    la a0, boas_vindas       # Endereço da string "Vamos jogar Blackjack! Escolha uma opcao (0 - Jogar, 1 - Sair):\n"
    li a7, 4                 # syscall: print_string
    ecall

    # Lê a opção do usuário: jogar ou sair
    li a7, 5                 # syscall: read_int
    ecall
    la t0, opcao_jogar   # Carrega o endereço de opcao_jogar em t0
    sw a0, 0(t0)         # Armazena o valor de a0 no endereço apontado por t0       # Salva a opção em memória (opcao_jogar)

    # Se opção == 1, sair
    lw t0, opcao_jogar       # t0 = opcao_jogar
    li t1, 1
    beq t0, t1, sair_jogo    # Se opcao == 1, vai para sair_jogo

    # Exibe mensagem "Bem-vindo ao Blackjack!!"
    la a0, escolheu_jogar
    li a7, 4
    ecall

# Loop principal do jogo
jogo_loop:
    # Reset das variáveis para nova rodada
    li t0, 0
    la t1, num_cartas_jogador   # Carrega o endereço de 'num_cartas_jogador' em t1
    sw t0, 0(t1)                # Salva o valor de t0 no endereço apontado por t1
    la t1, num_cartas_dealer    # Carrega o endereço de 'num_cartas_dealer' em t1
    sw t0, 0(t1)                # Salva o valor de t0 no endereço apontado por t1
    la t1, soma_jogador         # Carrega o endereço de 'soma_jogador' em t1
    sw t0, 0(t1)                # Salva o valor de t0 no endereço apontado por t1
    la t1, soma_dealer          # Carrega o endereço de 'soma_dealer' em t1
    sw t0, 0(t1)                # Salva o valor de t0 no endereço apontado por t1

    # Exibe "Nova rodada."
    la a0, inicio_rodada
    li a7, 4
    ecall

    #### Distribuição inicial de cartas ####

    ## Jogador recebe 2 cartas
    jal gerarCarta                  # a0 = carta gerada
    la a1, mao_jogador              # a1 = endereço da mão do jogador
    la a2, num_cartas_jogador       # a2 = endereço do contador de cartas do jogador
    jal adicionarCartaNaMao

    jal gerarCarta
    la a1, mao_jogador
    la a2, num_cartas_jogador
    jal adicionarCartaNaMao

    ## Dealer recebe 2 cartas
    jal gerarCarta
    la a1, mao_dealer
    la a2, num_cartas_dealer
    jal adicionarCartaNaMao

    jal gerarCarta
    la a1, mao_dealer
    la a2, num_cartas_dealer
    jal adicionarCartaNaMao

    #### Mostrar mão inicial ####

    # Exibe "Mao do jogador:"
    la a0, mao_do_jogador
    li a7, 4
    ecall

    # Exibe cartas do jogador
    la a0, mao_jogador
    lw a1, num_cartas_jogador
    jal mostrarMao

    # Exibe a string "Mao do dealer: "
    la a0, mao_do_dealer  # Endereço da STRING "Mao do dealer: \n"
    li a7, 4              # syscall: print_string
    ecall

    # Carrega a primeira carta do ARRAY mao_dealer e a exibe
    la t0, mao_dealer     # Carrega o endereço do ARRAY de inteiros 'mao_dealer'
    lw a0, 0(t0)          # Carrega a primeira carta (índice 0) do array 'mao_dealer' para a0
    li a7, 1              # syscall: print_int
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    #### Turno do jogador ####

    jal turnoJogador         # Executa o turno do jogador

    # Verifica se o jogador estourou
    lw t0, soma_jogador      # t0 = soma do jogador
    li t1, 21
    bgt t0, t1, fim_rodada   # Se soma > 21, vai direto para fim_rodada (dealer não joga)

    #### Turno do dealer ####

    jal turnoDealer          # Executa o turno do dealer

fim_rodada:
    #### Exibe resultados finais ####

    la a0, apresentar_resultado_final
    li a7, 4
    ecall

    # Exibe "Pontuacao final do jogador:"
    la a0, pontuacao_final_jogador
    li a7, 4
    ecall

    lw a0, soma_jogador
    li a7, 1
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    # Exibe "Pontuacao final do dealer:"
    la a0, pontuacao_final_dealer
    li a7, 4
    ecall

    lw a0, soma_dealer
    li a7, 1
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    #### Determinação do vencedor ####

    lw t0, soma_jogador      # t0 = soma do jogador
    lw t1, soma_dealer       # t1 = soma do dealer
    li t2, 21

    # Verifica se jogador estourou
    bgt t0, t2, dealer_vence

    # Verifica se dealer estourou
    bgt t1, t2, jogador_vence

    # Compara pontuações
    bgt t0, t1, jogador_vence
    blt t0, t1, dealer_vence

    # Empate
    la a0, empate
    li a7, 4
    ecall
    j perguntar_rejogar

jogador_vence:
    la a0, vitoria_jogador
    li a7, 4
    ecall
    j perguntar_rejogar

dealer_vence:
    la a0, vitoria_dealer
    li a7, 4
    ecall

perguntar_rejogar:
    # Pergunta se quer jogar novamente
    la a0, mensagemfinal
    li a7, 4
    ecall

    li a7, 5
    ecall
    la t0, opcao_jogar          # Carrega o endereço de 'opcao_jogar' em t0
    sw a0, 0(t0)                # Salva o valor de a0 no endereço apontado por t0

    lw t0, opcao_jogar
    li t1, 1
    beq t0, t1, sair_jogo
    j jogo_loop

sair_jogo:
    la a0, escolheu_nao_jogar
    li a7, 4
    ecall

    li a7, 10               # syscall: exit
    ecall

# Função: gerarCarta
# Gera um número aleatório entre 1 e 13 e retorna em a0

gerarCarta:
    li a7, 42       # Syscall 42: Random Int Range
    li a0, 0        # ID do gerador aleatório padrão
    li a1, 13       # Limite superior exclusivo: [0,12]
    ecall           # Executa o random

    addi a0, a0, 1  # Ajusta intervalo para [1,13]
    jr ra           # Retorna

# Função: calcularValorCarta
# Entrada: a0 = número da carta (1 a 13)
# Saída: a0 = valor real para somar na mão

calcularValorCarta:
    li t0, 1
    beq a0, t0, carta_e_as # Se for Ás
    li t0, 11
    bge a0, t0, carta_figura # Se for J, Q ou K
    j valor_normal

carta_e_as:
    li a0, 11
    jr ra

carta_figura:
    li a0, 10
    jr ra

valor_normal:
    jr ra

# Função: adicionarCartaNaMao
# Entrada: 
#   a0 = número da carta
#   a1 = endereço da mão (vetor)
#   a2 = endereço do contador de cartas

adicionarCartaNaMao:
    lw t0, 0(a2)            # Carrega o número atual de cartas
    slli t1, t0, 2          # Multiplica por 4 (palavra de 4 bytes)
    add t2, a1, t1          # Calcula o endereço de armazenamento

    sw a0, 0(t2)            # Armazena a carta

    addi t0, t0, 1          # Incrementa contador
    sw t0, 0(a2)
    jr ra

# Função: somarMao
# Entrada: 
#   a0 = endereço do vetor da mão
#   a1 = quantidade de cartas
#   a2 = endereço para armazenar soma

somarMao:
    # Salvar ra e registradores 's' na pilha
    addi sp, sp, -8 # Exemplo: 2 registradores (ra, s0)
    sw ra, 0(sp)
    sw s0, 4(sp)    # s0 para numAses

    li t0, 0                # índice (para o loop de soma)
    li t1, 0                # soma acumulada
    li s0, 0                # s0 = numAses (inicializa com 0)

soma_loop:
    bge t0, a1, soma_fim   # Fim do loop se índice >= quantidade de cartas

    slli t2, t0, 2         # índice * 4 (para offset da palavra)
    add t3, a0, t2         # endereço da carta atual (a0 = base do vetor)
    lw t4, 0(t3)           # carrega a carta para t4 (valor original 1-13)

    # Checa se a carta original é um Ás (valor 1)
    li t5, 1                 # t5 = 1
    bne t4, t5, nao_e_um_as  # Se carta original != 1, não é um Ás

    e_um_as:
        addi s0, s0, 1           # numAses++
        # O valor do Ás será 11 pelo calcularValorCarta
        j continua_processamento_carta

nao_e_um_as:
    # Não é Ás, continua sem incrementar numAses

continua_processamento_carta:
    mv a0, t4                # Passa a carta original para calcularValorCarta
    jal calcularValorCarta   # a0 = valor processado (10 para J/Q/K, 11 para Ás, etc.)
    add t1, t1, a0           # soma += valor da carta processado

    addi t0, t0, 1           # Incrementa o índice
    j soma_loop

soma_fim:
    # Lógica para ajustar Ases se a soma estourou 21
ajuste_ases_loop:
    li t2, 21                # t2 = 21 (valor máximo sem estourar)
    bgt t1, t2, verifica_num_ases # Se soma > 21, verifica se tem Ases para ajustar
    j fim_ajuste_ases        # Se soma <= 21, sai do ajuste

verifica_num_ases:
    bgt s0, zero, continua_ajuste_ases # Se numAses > 0, ajusta
    j fim_ajuste_ases        # Se numAses <= 0, sai do ajuste

continua_ajuste_ases:
    addi t1, t1, -10         # soma -= 10 (converte Ás de 11 para 1)
    addi s0, s0, -1          # numAses--
    j ajuste_ases_loop       # Volta para verificar novamente

fim_ajuste_ases:
    sw t1, 0(a2)             # Salva a soma final ajustada no endereço a2

    # Restaura ra e registradores 's' da pilha
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    jr ra

# Função: mostrarMao
# Entrada: 
#   a0 = endereço vetor mão
#   a1 = quantidade de cartas

mostrarMao:
    li t0, 0

mostrar_loop:
    bge t0, a1, mostrar_fim

    slli t2, t0, 2
    add t3, a0, t2
    lw t4, 0(t3)

    mv a0, t4
    li a7, 1       # print int
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    addi t0, t0, 1
    j mostrar_loop

mostrar_fim:
    jr ra

# Função: turnoJogador
# Responsável por gerenciar o turno do jogador: decidir entre Hit ou Stand.

turnoJogador:
    # Loop do turno do jogador
turno_jogador_loop:
    # Recalcula soma da mão do jogador
    la a0, mao_jogador
    lw a1, num_cartas_jogador
    la a2, soma_jogador
    jal somarMao

    # Mostra a pontuação atual
    la a0, pontuacao
    li a7, 4
    ecall

    lw a0, soma_jogador
    li a7, 1
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    # Pergunta o movimento
    la a0, escolher_movimento
    li a7, 4
    ecall

    li a7, 5  # Lê inteiro
    ecall
    la t0, movimento_jogador  # Carrega o endereço de 'movimento_jogador' em t0
    sw a0, 0(t0)              # Salva o valor de a0 no endereço apontado por t0

    # Se for Hit (1)
    lw t0, movimento_jogador
    li t1, 1
    beq t0, t1, jogador_hit

    # Se for Stand (2)
    li t1, 2
    beq t0, t1, jogador_stand

    # Caso inválido
    la a0, aviso_opcao_invalida
    li a7, 4
    ecall
    j turno_jogador_loop

jogador_hit:
    la a0, jogador_pede_hit
    li a7, 4
    ecall

    # Gera nova carta
    jal gerarCarta

    # Adiciona à mão do jogador
    la a1, mao_jogador
    la a2, num_cartas_jogador
    jal adicionarCartaNaMao

    la a0, jogador_recebe_carta_nova
    li a7, 4
    ecall

    # Mostra a carta recebida
    lw a1, num_cartas_jogador
    addi a1, a1, -1  # Índice da última carta
    slli t0, a1, 2
    la t1, mao_jogador
    add t1, t1, t0
    lw a0, 0(t1)

    li a7, 1
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    # Recalcula soma
    la a0, mao_jogador
    lw a1, num_cartas_jogador
    la a2, soma_jogador
    jal somarMao

    # Verifica se estourou
    lw t0, soma_jogador
    li t1, 21
    bgt t0, t1, jogador_estourou

    # Continua no loop
    j turno_jogador_loop

jogador_stand:
    la a0, jogador_pede_stand
    li a7, 4
    ecall
    jr ra

jogador_estourou:
    la a0, aviso_estouro
    li a7, 4
    ecall
    jr ra

# Função: turnoDealer
# Gerencia o turno automático do dealer.

turnoDealer:
    la a0, vez_do_dealer
    li a7, 4
    ecall

    la a0, revelacao_carta_oculta
    li a7, 4
    ecall

    # Mostra mão completa do dealer
    la a0, mao_do_dealer
    li a7, 4
    ecall

    la a0, mao_dealer
    lw a1, num_cartas_dealer
    jal mostrarMao

turno_dealer_loop:
    # Recalcula soma da mão do dealer
    la a0, mao_dealer
    lw a1, num_cartas_dealer
    la a2, soma_dealer
    jal somarMao

    # Mostra a pontuação
    la a0, pontuacao
    li a7, 4
    ecall

    lw a0, soma_dealer
    li a7, 1
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    # Verifica se precisa pedir carta (<17)
    lw t0, soma_dealer
    li t1, 17
    blt t0, t1, dealer_pede_hit

    # Se não, dealer para
    la a0, dealer_para
    li a7, 4
    ecall
    jr ra

dealer_pede_hit:
    la a0, dealer_pediu_hit
    li a7, 4
    ecall

    # Gera nova carta
    jal gerarCarta

    # Adiciona à mão do dealer
    la a1, mao_dealer
    la a2, num_cartas_dealer
    jal adicionarCartaNaMao

    la a0, dealer_recebe_carta_nova
    li a7, 4
    ecall

    # Mostra a carta recebida
    lw a1, num_cartas_dealer
    addi a1, a1, -1
    slli t0, a1, 2
    la t1, mao_dealer
    add t1, t1, t0
    lw a0, 0(t1)

    li a7, 1
    ecall

    la a0, nova_linha
    li a7, 4
    ecall

    # Verifica se estourou
    la a0, mao_dealer
    lw a1, num_cartas_dealer
    la a2, soma_dealer
    jal somarMao

    lw t0, soma_dealer
    li t1, 21
    bgt t0, t1, dealer_estourou

    # Continua o loop
    j turno_dealer_loop

dealer_estourou:
    la a0, aviso_estouro
    li a7, 4
    ecall
    jr ra







