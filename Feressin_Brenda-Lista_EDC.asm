		###CODIGO DEL PDF, PARA IR AGREGANDO





















###LISTA ENLAZADA

	.data
p_cat:	.word 0

provis:	.word 1,2,3,4

nombres_cat:	.asciiz "mamiferos", "aves", "reptiles", "peces" #lista de strings separadas por un char nulo que ocupa un byte

nro_cat:	.word 4


	.text
main: 	la $s0, provis		#cargo en s0 la direccion de provisorio
	lw $s1, nro_cat		#cargo en s1 el nro de categ para el contador del loop
	la $s2, nombres_cat	#cargo en s2 la direcc de la lista de nombres para categ
	
loop: 	lw $a0, ($s0)		#cargo en a0 el contenido de la mem que esta siendo apuntada por s0, o sea elem de provis
	jal newnode		
	addi $s0, $s0, 4	#a la direcc de prov cargada en s0 le sumo 4, o sea me desplazo a la direcc del sig elem de prov
	jal recorrer_nombres	#Actualizo el puntero de nombres_cat, a la siguiente palabra en la lista de categorias
	addi $s1, $s1, -1	#resto 1 al nro de cat, porque ya se hizo una vuelta del loop
	bnez $s1, loop 
	jal end			#Si es cero, finalizo.
	
		


newnode:	move $t0, $a0		#preserva el elemento de provisorio
		li $v0, 9		
		li $a0, 16		#con syscall sbrk pido espacio para p.ant, p.obj, dato, p.sig
		syscall			#direcc nuevo nodo en v0
		
		sw $t0, 4($v0)		#guarda el elem prov en v0+4(2do lugar) 
		lw $t1, p_cat		#cargo el contenido del puntero de lista categoria
		beq $t1, $0, first 	#? si lista=vacia, se creara el 1er nodo
				#Si no es 1er N,chequear si es 2do. Para eso, debo acceder a 1er o 4to campo y ver si es NULL
		lw $t4, ($t1)		#en t1 cargue el cont de p_cat, o sea la direcc del v0 1erN.En t4 guardo el cont de ese v0
		beqz $t4, second	#si el v0 del 1er nodo =null, confirmo, por lo que salto a la funcion para crear el 2doN
		
		sw $t1, 12($v0)		#comienzo a insertar nuevo nodo por detras. 4to campo apunta a 1er campo 1erN
		sw $s2, 8($v0)		#3er campo, direcc de palabra de categoria, dato.
		sw $t4, ($v0)		#aca apunto con el 1er campo del nuevo nodo al nodo anterior
		sw $v0, 12($t4)		#aca hago que el 4to campo del nodo ant apunte a v0
		sw $v0, ($t1)		#aca el 1er campo del 1er nodo apunta a el nuevo nodo que estamos creando
		
		jr $ra			

		first: 		
		sw $0, ($v0) 		#primer campo inicializado a null 
		sw $0, 12($v0)		#4to campo inicializado en null
		sw $s2, 8($v0)		#VER SI ANDA BIEN!!! Guardo en el 3er campo la direcc para el 1er dato o palabra de nombres_cat
		sw $v0, p_cat 		#el puntero de la lista categoria va a guardar la direcc de v0, ya no sera null
		jr $ra	

		second:
		sw $t1, ($v0)		#1er campo 2do nodo apunta a 1er campo 1er nodo
		sw $t1, 12($v0)		#4to campo 2doN apunta a 1er campo 1erN (caso particular, sig=ant)
		sw $s2, 8($v0)		#3er campo: direcc 2da palabra de categ
		sw $v0, ($t1)		#aca cambio los punteros de 1er N (null) a apuntar a 2doN
		sw $v0, 12($t1)
		jr $ra


#Funcion para recorrer nombres_cat

recorrer_nombres:
	
	move $t2, $s2
	
	loop_nombres:
	lb $t3, 0($t2)
	beqz $t3, next_word
	addiu $t2, $t2, 1
	j loop_nombres
	
	next_word:
	addiu $t2, $t2, 1
	move  $s2, $t2
	jr $ra
	
	
end:
	li $v0, 10
	syscall

	
