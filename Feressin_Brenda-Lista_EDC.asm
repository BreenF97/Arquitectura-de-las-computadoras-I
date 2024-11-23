		###CODIGO DEL PDF, PARA IR AGREGANDO
	
	.data
slist:	.word 0		#puntero - lo utilizan las funciones smalloc y sfree
cclist:	.word 0		#puntero a la lista de categorias - circular category list
wclist:	.word 0		#puntero a la categoria seleccionada en curso - working category list
schedv:	.space 32	#vector de direcc scheduler vector- 32 bytes para las 8 opciones del menu
menu:	.ascii "Colecciones de objetos categorizados\n"
	.ascii "====================================\n"
	.ascii "1-Nueva categoria\n"
	.ascii "2-Siguiente categoria\n"
	.ascii "3-Categoria anterior\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objeto de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
	
error:	.asciiz "Error: "
return:	.asciiz "\n"
catName:.asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria: "
idObj:	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName:.asciiz "\nIngrese el nombre de un objeto: "
success:.asciiz "La operacion se realizo con exito\n\n"	

.text

main:	la $t0, schedv		#inicializacion
	la $t1, newcategory	#cargo c/ direcc del menu, y la guardo en el space schedv
	sw $t1, 0($t0)
#	la $t1, nextcategory
#	sw $t1, 4($t0)
#	la $t1, prevcategory
#	sw $t1, 8($t0)
#	la $t1, listcategory
#	sw $t1, 12($t0)
#	la $t1, delcategory
#	sw $t1, 16($t0)
#	la $t1, newobject
#	sw $t1, 20($t0)
#	la $t1, listobjects
#	sw $t1, 24($t0)
#	la $t1, delobject
#	sw $t1, 28($t0)
	
	
#Imprimo menu
	
	li $v0, 4
	la $a0, menu
	syscall
	
#Tomo el input del usuario	
	
	li $v0, 5
	syscall
	move $t1, $v0	#Lo paso a t1 porque al v0 lo voy a estar pisando constantemente con syscall seguro
	
#Hago una comparacion entre el input del usuario y los nros del menu para saber a que funcion salto.

	beqz $t1, end
	li $t2, 1
	beq $t1, $t2, newcategory
#	li $t2, 2
#	beq $t1, $t2, nextcategory
#	li $t2, 3
#	beq $t1, $t2, prevcategory
#	li $t2, 4
#	beq $t1, $t2, listcategory
#	li $t2, 5
#	beq $t1, $t2, delcategory
#	li $t2, 6
#	beq $t1, $t2, newobject
#	li $t2, 7
#	beq $t1, $t2, listobjects
#	li $t2, 8
#	beq $t1, $t2, delobject
	
	
	
	
	

	
#sfree: 		#en $a0 debe estar la direccion de memoria del nodo a eliminar	
#	lw $t0, slist
#	sw $t0, 12($a0)
#	sw $a0, slist 	#a0 node adrdress in unused list
#	jr $ra
	
	
newcategory:
	addiu $sp, $sp, -4	#Stack pointer crece decrec. Al restarle 4, me muevo -4 bytes a la sig direcc, a la cual apuntara sp                         
	sw $ra, 4($sp)	#No retrocede el puntero! Guardo ra en la direcc inicial (-4+4). Evito sobreesc.xq sp apunta a la sig direcc
	la $a0, catName		#input category name	##cargo la direcc de catName (msg)
	jal getblock
#	move $a2, $v0 	#a2= *char to category name
#	la $a0, cclist	#a0=list
#	li $a1, 0 	#a1=null
#	jal addnode
#	lw $t0, wclist
#	bnez $t0, newcategory_end
#	sw $v0, wclist 	#update working list if was NULL

getblock: 		##funcion para obtener un bloque
	addi $sp, $sp, -4
	sw $ra, 4($sp)		#estoy guardando la 2da direcc de retorno en sp, para volver a func new category
	li $v0, 4		
	syscall			#syscall para imprimir msg de catName
	jal smalloc
	move $a0, $v0
#	li $a1, 16
#	li $v0, 8
#	syscall
#	move $v0, $a0
#	lw $ra, 4($sp)
#	addi $sp, $sp, 4
#	jr $ra
	
	
smalloc:		##funcion para obtener espacio de memoria, ya sea de la lista de liberados o del heap
	lw $t0, slist		#"puntero"-> en la 1er vuelta es null	
	beqz $t0, sbrk
	move $v0, $t0		#si !null, copio en v0 la direcc de slist cargada en t0 (le estoy dando la direcc de un nodo liberado)
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
	
	sbrk: 		##esto se usa para pedir memoria en el heap, solo si no tengo nodos disponibles en la lista de liberados
		li $a0, 16 	#node size fixed 4 word	##nodo de tama;o fijo en 16 bytes, o sea 4 word
		li $v0, 9
		syscall		#return node address in v0	##devuelve en v0 la direcc de espacio de memoria pedido en el heap
		jr $ra		#vuelve a la direcc guardada en ra (move $a0, $v0 de funcion getblock)
		
		
		
	
#newcategory_end: 
#	li $v0, 0 	#return success
#	lw $ra, 4($sp)
#	addiu $sp, $sp, 4
#	jr $ra

	
	


end:		##Funcion para cerrar el programa
	li $v0, 10	
	syscall
	





















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

	
