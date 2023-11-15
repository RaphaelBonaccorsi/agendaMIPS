.data
    list: .space 2000 # Inicializa um vetor com 100 espaços (cada espaço possui 4 + 4 + 12 bytes do ano, mês e nome respectivamente), salvo com a regra row major
    name: .space 12 # Inicializa a variável para os nomes com 10 bytes ***poderá ser alterado
    count: .word 0 # contador de aniversários adicionados
    menu: .asciiz "Menu:\n1. Adicionar aniversário\n2. Remover aniversário\n3. Visualizar aniversários\n4. Sair\nEscolha uma opção: "
    add_prompt: .asciiz "Insira o dia, mês e nome (com limite de 11 caracteres):\n"
    newline: .asciiz "\n"


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
    beq $t0, 3, view_birthdays  # se a opção for 3, visualizar aniversários
    beq $t0, 4, exit_program    # se a opção for 4, sair do programa

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
    lw $t3, name # carrega o nome em $t3
    sw $t3, list($t1) # Salva no array
    
    addi $t0, $t0, 1 # count++
    sw $t0, count      # ^
    
    j main
	

remove_birthday:
    # código para remover um aniversário da agenda

view_birthdays:
    # código para visualizar os aniversários na agenda
    lw $t0, count
    li $t1, 0 # seta o i = 0
    while:
    	beq $t1, $t0, main
    	# calcular o offset
    	mul $t2, $t1, 20 # Calcula o offset em $t2 (índice * tamanho de cada espaço)
    	# Printa o dia
    	li $v0, 1
    	lw $a0, list($t2)
    	syscall
    	# printa nova linha
    	li $v0, 4
    	la $a0, newline
    	syscall
    	addi $t2, $t2, 4 # Seta o offset para o proximo campo (4 bytes a frente)
    	# Printa o mês
    	li $v0, 1
    	lw $a0, list($t2)
    	syscall
    	# printa nova linha
    	li $v0, 4
    	la $a0, newline
    	syscall
    	addi $t2, $t2, 4 # Seta o offset para o proximo campo (4 bytes a frente)
    	# Printa o nome
    	
    	li $v0, 4
    	la $a0, name # Seta o endereço da string em $a0
    	lw $a1, list($t2) # Load the first word of the name
        lw $a2, list + 4($t2)    # Load the second word of the name
        lw $a3, list + 8($t2)   # Load the third word of the name
    	syscall
    	# printa nova linha
    	li $v0, 4
    	la $a0, newline
    	syscall
    	addi $t1, $t1, 1
    	
    	j while
    
    j main

    
exit_program:
    li $v0, 10
    syscall
