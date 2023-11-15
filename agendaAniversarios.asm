.data
meses: .word 12
nomes: .asciiz "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
datas: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

.text
la $s0, nomes
la $s1, datas
li $t0, 0 # índice do vetor
sll $t1, $t0, 2 # calcular o endereço do elemento do vetor
add $t2, $s0, $t1 # adicionar o endereço do vetor ao endereço do elemento do vetor
lw $t3, 0($t2) # carregar o valor do elemento do vetor
sw $t3, 0($t2) # armazenar o valor do elemento do vetor

.text
main:
    li $v0, 4
    la $a0, menu
    syscall

    li $v0, 5
    syscall
    move $t0, $v0              # opção do menu

    beq $t0, 1, add_birthday    # se a opção for 1, adicionar aniversário
    beq $t0, 2, remove_birthday # se a opção for 2, remover aniversário
    beq $t0, 3, view_birthdays  # se a opção for 3, visualizar aniversários
    beq $t0, 4, exit_program    # se a opção for 4, sair do programa

add_birthday:
    # código para adicionar um aniversário à agenda


remove_birthday:
    # código para remover um aniversário da agenda

view_birthdays:
    # código para visualizar os aniversários na agenda

exit_program:
    li $v0, 10
    syscall

