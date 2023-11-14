.data
    birthdays: .word 0:100    # matriz para armazenar os anivers�rios (100 registros)
    count: .word 0            # contador de anivers�rios adicionados
    menu: .asciiz "Menu:\n1. Adicionar anivers�rio\n2. Remover anivers�rio\n3. Visualizar anivers�rios\n4. Sair\nEscolha uma op��o: "


.text
main:
    li $v0, 4
    la $a0, menu
    syscall

    li $v0, 5
    syscall
    move $t0, $v0              # op��o do menu

    beq $t0, 1, add_birthday    # se a op��o for 1, adicionar anivers�rio
    beq $t0, 2, remove_birthday # se a op��o for 2, remover anivers�rio
    beq $t0, 3, view_birthdays  # se a op��o for 3, visualizar anivers�rios
    beq $t0, 4, exit_program    # se a op��o for 4, sair do programa

add_birthday:
    # c�digo para adicionar um anivers�rio � agenda


remove_birthday:
    # c�digo para remover um anivers�rio da agenda

view_birthdays:
    # c�digo para visualizar os anivers�rios na agenda

exit_program:
    li $v0, 10
    syscall

