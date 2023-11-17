.data
    list: .space 2000 # Inicializa um vetor com 100 espaços (cada espaço possui 4 + 4 + 12 bytes do ano, mês e nome respectivamente), salvo com a regra row major
    name: .space 12 # Inicializa a variável para os nomes com 10 bytes ***poderá ser alterado
    count: .word 0 # contador de aniversários adicionados
    menu: .asciiz "Menu:\n1. Adicionar aniversário\n2. Remover aniversário\n3. Visualizar aniversários\n4. Sair\nEscolha uma opção: "
    add_prompt: .asciiz "Insira o dia, mês e nome (com limite de 11 caracteres):\n"
    newline: .asciiz "\n"
    month_prompt: .asciiz "Digite o número do mês desejado: "
    day_prompt: .asciiz "Digite o número do dia desejado: "
    name_prompt: .asciiz "Digite o nome desejado, deixe em branco para remover todos no dia e mês selecionados: "
    found_birthday: .asciiz "Aniversário encontrado:\n"
    month_invalid: .asciiz "Mês inválido. Operação cancelada.\n"
    day_invalid: .asciiz "Dia inválido. Operação cancelada.\n"
    birthday_off: .asciiz "Mês inválido. Operação cancelada.\n"
    month: .asciiz "Mês: "
    day: .asciiz "Dia: "
    nome: .asciiz "Aniversariante: "
    full_prompt: .asciiz "Lista cheia!\n"
   
.text
main:
    li $v0, 4 # printa o menu
    la $a0, menu
    syscall

    li $v0, 5 # lê a opção
    syscall
    move $t0, $v0              # opção do menu

    beq $t0, 1, add_birthday    # se a opção for 1, adicionar aniversário
    beq $t0, 2, remove_birthday # se a opção for 2, remover aniversário
    beq $t0, 3, view_birthdays_by_month  # se a opção for 3, visualizar aniversários
    beq $t0, 4, exit_program    # se a opção for 4, sair do programa


#----------------------------------------------------------------------------------------------
add_birthday:
    # Calcular o offset (id do array) para salvar os valores
    lw $t0, count           # t0 = count
    mul $t1, $t0, 20        # Offset em $t1
    beq $t1, 2000, fullList # Se offset = limite, mostre mensagem de erro
    
    # código para adicionar um aniversário à agenda
    li $v0, 4
    la $a0, add_prompt # printa a mensagem pedindo pelo input
    syscall

    # Lê o dia
    li $v0, 5 # Seta a syscall para read int
    syscall
    blt $v0, 1, invalid_day # Checa a validade do dia
    bgt $v0, 31, invalid_day
    move $t2, $v0 # Salva o dia em t2
    
    # Lê o mês
    li $v0, 5 # Seta a syscall para read int
    syscall
    blt $v0, 1, invalid_month # Checa a validade do mes
    bgt $v0, 12, invalid_month
    
    sw $t2, list($t1) # Salva no array
    addi $t1, $t1, 4 # Seta o offset para o proximo campo (4 bytes a frente)
    sw $v0, list($t1) # Salva no array
    addi $t1, $t1, 4 # Seta o offset para o proximo campo (4 bytes a frente)
    
    
    # Lê o nome
    li $v0, 8
    la $a0, name # salvará o input em name (necessário pois não é possível armazenar 10 bytes em um ponteiro
    li $a1, 12 # tamanho máximo do input de 11, (ultimo caractere precisa ser \0 por isso teremos apenas 9 caracteres pro nome) ***pode ser alterado
    syscall
    
    move $t2, $zero # Offset para a variável name em t2
    lw $t3, name($t2) # carrega o nome em $t3
    sw $t3, list($t1) # Salva no array
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    lw $t3, name($t2) # carrega o nome em $t3
    sw $t3, list($t1) # Salva no array
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    lw $t3, name($t2) # carrega o nome em $t3
    sw $t3, list($t1) # Salva no array
    
    
    addi $t0, $t0, 1 # count++
    sw $t0, count    # ^
    
    j main
	
fullList:
    li $v0, 4
    la $a0, full_prompt # printa a mensagem de erro lista cheia
    syscall
    j main
#-----------------------------------------------------------------------------------------------------
remove_birthday:
    # código para remover um aniversário da agenda
    li $v0, 4
    la $a0, day_prompt # printa a mensagem pedindo pelo input
    syscall
    # Lê o dia
    li $v0, 5 # Seta a syscall para read int
    syscall
    blt $v0, 1, invalid_day # Checa a validade do dia
    bgt $v0, 31, invalid_day
    move $t0, $v0 # Salva o dia em t0
    
    li $v0, 4
    la $a0, month_prompt # printa a mensagem pedindo pelo input
    syscall
    
    # Lê o mês
    li $v0, 5 # Seta a syscall para read int
    syscall
    blt $v0, 1, invalid_month # Checa a validade do mes
    bgt $v0, 12, invalid_month
    move $t1, $v0
    # t0 = dia, t1 = mes
    move $t2, $zero # Seta o offset em t2
    move $t3, $zero # Seta i
    
    
    removeWhile:
         lw $t4, count # Carrega tamanho do vetor list
         beq $t4, $t3, main # Se i = count sair do loop
         lw $t6, list($t2) # Carrega o dia em t6
         beq $t6, $t0, sameDayCondition # Se o dia for igual segue para sameDayCondition
         
         addi $t2, $t2, 20 # Seta o offset para o próximo dia
         addi $t3, $t3, 1 # i++
         j removeWhile # Se o dia não for igual retorna para começo no proximo espaço
         
    sameDayCondition:
         addi $t2, $t2, 4 # Seta o offset para o mês
         lw $t5, list($t2) # Carrega o mês em t5
         move $t6, $t3   # t6 = t3 / j = i
         beq $t5, $t1, removeEntry # Se o mês for igual, segue para removeEntry
         addi $t2, $t2, 16 # Seta o offset para o próximo dia
         addi $t3, $t3, 1 # i++
         j removeWhile
         
    removeEntry:
         # Loop para trazer todos os registros pra trás
         beq $t6, $t4, removeCount # Se j = count, volte para removeCount (fim do vetor)
         addi $t6, $t6, 1 # j++
         mul $t8, $t6, 20 # Pega o offset para o próximo dia
         ### Pega os proximos valores e coloca 20 bytes (um índice) antes
         lw $t7, list($t8)
         subi $t8, $t8, 20
         sw $t7, list($t8)
         addi $t8, $t8, 24
         ###
         lw $t7, list($t8)
         subi $t8, $t8, 20
         sw $t7, list($t8)
         addi $t8, $t8, 24
         ###
         lw $t7, list($t8)
         subi $t8, $t8, 20
         sw $t7, list($t8)
         addi $t8, $t8, 24
         ###
         lw $t7, list($t8)
         subi $t8, $t8, 20
         sw $t7, list($t8)
         addi $t8, $t8, 24
         ###
         lw $t7, list($t8)
         subi $t8, $t8, 20
         sw $t7, list($t8)
         addi $t8, $t8, 24
         
         j removeEntry
         
    removeCount:
         subi $t4, $t4, 1
         sw $t4, count
         j removeWhile
    
    
#-------------------------------------------------------------------------------------------------
view_birthdays_by_month:
    lw $t0, count # carrega o contador
    beq $t0, $zero, no_birthdays # se count for zero, não há aniversários para visualizar

    li $v0, 4
    la $a0, month_prompt
    syscall

    li $v0, 5
    syscall
    move $t1, $v0 # mês escolhido pelo usuário

    # Verifica se o mês escolhido é válido
    blt $t1, 1, invalid_month
    bgt $t1, 12, invalid_month

    li $t2, 0 # inicializa o índice do vetor
    
view_month_loop:
    # Calcule o offset para a próxima entrada no vetor
    mul $t3, $t2, 20 # 20 bytes por entrada
    la $t4, list # endereço inicial do vetor
    add $t4, $t4, $t3 # aponta para a entrada atual no vetor

    # Carrega o mês da entrada
    lw $t5, 4($t4)

    # Verifica se o mês da entrada é igual ao mês escolhido pelo usuário
    beq $t5, $t1, print_entry

    addi $t2, $t2, 1 # incrementa o índice
    blt $t2, $t0, view_month_loop # se não atingiu o final, continue o loop

    j no_birthdays_for_month

print_entry:
    # Imprima ou faça algo com a entrada encontrada
    li $v0, 4
    la $a0, found_birthday
    syscall
    
    # Imprima prompt
    li $v0, 4
    la $a0, day
    syscall
    # Imprima o dia
    li $v0, 1
    lw $a0, 0($t4)
    syscall
    # Imprima uma quebra de linha
    li $v0, 4
    la $a0, newline
    syscall
    
    
    # Imprima prompt
    li $v0, 4
    la $a0, month
    syscall
    # Imprima o mês
    li $v0, 1
    lw $a0, 4($t4)
    syscall
    # Imprima uma quebra de linha
    li $v0, 4
    la $a0, newline
    syscall
    
    # Imprima prompt
    li $v0, 4
    la $a0, nome
    syscall
    # Imprima o nome
    li $v0, 4
    la $a0, 8($t4)
    syscall
    # Imprima uma quebra de linha
    li $v0, 4
    la $a0, newline
    syscall

    addi $t2, $t2, 1 # incrementa o índice
    blt $t2, $t0, view_month_loop # se não atingiu o final, continue o loop

no_birthdays_for_month:
    j main

invalid_month:
    li $v0, 4
    la $a0, month_invalid
    syscall
    j main

invalid_day:
    li $v0, 4
    la $a0, day_invalid
    syscall
    j main

no_birthdays:
    li $v0, 4
    la $a0, birthday_off
    syscall
    j main
#----------------------------------------------------------------------------------------------

exit_program:
    li $v0, 10
    syscall
