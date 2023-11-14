.data
    birthdays: .word 0:100    # matriz para armazenar os aniversários (100 registros)
    count: .word 0            # contador de aniversários adicionados
    menu: .asciiz "Menu:\n1. Adicionar aniversário\n2. Remover aniversário\n3. Visualizar aniversários\n4. Sair\nEscolha uma opção: "


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

