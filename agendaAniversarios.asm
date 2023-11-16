.data
    list: .space 2000 # Inicializa um vetor com 100 espaços (cada espaço possui 4 + 4 + 12 bytes do ano, mês e nome respectivamente), salvo com a regra row major
    name: .space 12 # Inicializa a variável para os nomes com 10 bytes ***poderá ser alterado
    count: .word 0 # contador de aniversários adicionados
    menu: .asciiz "Menu:\n1. Adicionar aniversário\n2. Remover aniversário\n3. Visualizar aniversários\n4. Sair\nEscolha uma opção: "
    add_prompt: .asciiz "Insira o dia, mês e nome (com limite de 11 caracteres):\n"
    newline: .asciiz "\n"
   month_prompt: .asciiz "Digite o número do mês desejado: "
   found_birthday: .asciiz "Aniversário encontrado:\n"
   month_invalid: .asciiz "Mês inválido. Operação cancelada.\n"
   birthday_off: .asciiz "Mês inválido. Operação cancelada.\n"
   month: .asciiz "Mês: "
   day: .asciiz "Dia: "
   nome: .asciiz "Aniversariante: "
   
   
   
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
    # código para adicionar um aniversário à agenda
    li $v0, 4
    la $a0, add_prompt # printa a mensagem pedindo pelo input
    syscall
    
    # Calcular o offset (id do array) para salvar os valores
    lw $t0, count
    mul $t1, $t0, 20 # Offset em $t1

    # Lê o dia
    li $v0, 5 # Seta a syscall para read int
    syscall
    sw $v0, list($t1) # Salva no array
    addi $t1, $t1, 4 # Seta o offset para o proximo campo (4 bytes a frente)
    # Lê o mês
    li $v0, 5 # Seta a syscall para read int
    syscall
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
    sw $t0, count      # ^
    
    j main
	
#-----------------------------------------------------------------------------------------------------
remove_birthday:
    # código para remover um aniversário da agenda
    
    
    
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

no_birthdays:
    li $v0, 4
    la $a0, birthday_off
    syscall
    j main
#----------------------------------------------------------------------------------------------

exit_program:
    li $v0, 10
    syscall
