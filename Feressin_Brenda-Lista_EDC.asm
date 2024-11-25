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
	
#error:	.asciiz "Error: "
return:	.asciiz "\n"
catName:.asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria: "
idObj:	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName:.asciiz "\nIngrese el nombre de un objeto: "
success:.asciiz "La operacion se realizo con exito\n\n"	

wc: 	.asciiz "> "

error201:	.asciiz "Error 201: No hay categorias disponibles."
error202:	.asciiz "Error 202: Solo hay una categoria disponible."
error301: 	.asciiz "Error 301: No hay categorias disponibles para listar."
error401: 	.asciiz "Error 401: No hay categorias disponibles para borrar."
error501:	.asciiz "Error 501: No hay categorias disponibles para anexar objetos."
error601: 	.asciiz "Error 601: No hay categorias disponibles para acceder a sus objetos."
error602:	.asciiz "Error 602: No hay objetos creados para la categoria seleccionada."
error701: 	.asciiz "Error 701: No hay categorias ingresadas."

.text

	la $t0, schedv		#inicializacion
	la $t1, newcategory	#cargo c/ direcc del menu, y la guardo en el space schedv
	sw $t1, 0($t0)
	la $t1, nextcategory
	sw $t1, 4($t0)
	la $t1, prevcategory
	sw $t1, 8($t0)
	la $t1, listcategory
	sw $t1, 12($t0)
	la $t1, delcategory
	sw $t1, 16($t0)
	la $t1, newobject
	sw $t1, 20($t0)
	la $t1, listobjects
	sw $t1, 24($t0)
	la $t1, delobject
	sw $t1, 28($t0)
	
main: 	
#Imprimo menu
	
	li $v0, 4
	la $a0, menu
	syscall
	
#Tomo el input del usuario	
	
	li $v0, 5
	syscall
	move $t1, $v0	#Lo paso a t1 porque al v0 lo voy a estar pisando constantemente con syscall seguro
	
	
#VALIDAR QUE EL DATO ESTE ENTRE 1 Y 8 PARA QUE NO ME TIRE ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#Si el error fuera una selección inexistente del menú, el códido de error sería (101)
	
#Hago una comparacion entre el input del usuario y los nros del menu para saber a que funcion salto.

####CAMBIAR ESTA MANERA DE HACERLO!!!!! TENGO QUE USAR LA INICIALIZACION E IR ACCEDIENDO DESDE AHI!!!!!!!!

	##PROVISORIOOOO!!!!
	beqz $t1, end
	li $t2, 1
	bne $t1, $t2, no_newcategory	#Si no es, salta a "NO ES..." Si es, continua al siguiente renglon 
	jal newcategory			#y salta a la funcion
	
	no_newcategory:			
	li $t2, 2
	bne $t1, $t2, no_nextcategory
	jal nextcategory

	no_nextcategory:
	li $t2, 3
	bne $t1, $t2, no_prevcategory
	jal prevcategory
	
	no_prevcategory:
	li $t2, 4
	bne $t1, $t2, no_listcategory
	jal listcategory
	
	no_listcategory:
	li $t2, 5
	bne $t1, $t2, no_delcategory
	jal delcategory
	
	no_delcategory:
	li $t2, 6
	bne $t1, $t2, no_newobject
	jal newobject
	
	no_newobject:
	li $t2, 7
	bne $t1, $t2, no_listobjects
	jal listobjects
	
	no_listobjects:
	li $t2, 8
	bne $t1, $t2, no_delobject
	jal delobject
	
	no_delobject:

#imprimo espacio \n	
	li $v0, 4
	la $a0, return
	syscall

	j main		#loop para volver a ejecutar desde main.
	
	
	
	

smalloc:		##funcion para obtener espacio de memoria, ya sea de la lista de liberados o del heap
	lw $t0, slist		#"puntero"-> en la 1er vuelta es null	
	beqz $t0, sbrk
	move $v0, $t0		#si !null, copio en v0 la direcc de slist cargada en t0 (le estoy dando la direcc de un bloq liberado)
	lw $t0, 12($t0)		#Sobreescribo t0 con el valor almacenado en la dir t0+12 (o sea 4to campo del bloqfree q va a usar). 
				#Este campo contiene la direcc del sig bloq free. x ende, slist ahora apunta al sig bloqfree, 
				#"sacando" al 1ero de la lista free para su uso.
	sw $t0, slist		#Guardo en slist el nuevo 1er bloq free, actualizando el puntero
	jr $ra		#vuelvo a la direcc en ra, con direcc en v0 de un bloq reutilizado
	
	sbrk: 		##esto se usa para pedir memoria en el heap, solo si no tengo bloqs disponibles en la lista de liberados
		li $a0, 16 	#node size fixed 4 word	##nodo de tama;o fijo en 16 bytes, o sea 4 word
		li $v0, 9
		syscall		#return node address in v0	##devuelve en v0 la direcc de espacio de memoria pedido en el heap
		jr $ra		#vuelve a la direcc guardada en ra, con direcc en v0 de mem heap

	
	
newcategory:
	addiu $sp, $sp, -4	#Stack pointer crece decrec. Al restarle 4, me muevo -4 bytes a la sig direcc, a la cual apuntara sp                         
	sw $ra, 4($sp)	#No retrocede el puntero! Guardo ra en la direcc inicial (-4+4). Evito sobreesc.xq sp apunta a la sig direcc
	la $a0, catName		#input category name	##cargo la direcc de catName (msg)
	jal getblock
	move $a2, $v0 	#a2= *char to category name	##a2 ahora va a ser puntero al nombre de la categoria
	la $a0, cclist	#a0=list	##cargo en a0 la direcc de cclist, que es puntero a lista de categ
	li $a1, 0 	#a1=null	
	jal addnode
	lw $t0, wclist		#cargo en t0 el contenido de wclist- puntero a la categ selecc
	bnez $t0, newcategory_end	#si wclist !null, salto
	sw $v0, wclist 	#update working list if was NULL	##actualizar wclist si es null, p/q apunte a v0 (nodo actual) y sigo
	
	newcategory_end: 
		li $v0, 0 	#return success	##cargo 0 en v0 (null)
		li $v0, 4
		la $a0, success		#imprimo mensaje de exito
		syscall
		lw $ra, 4($sp)		#recupero la direcc para volver al menu (renglon: no_newcategory)
		addiu $sp, $sp, 4
		jr $ra			#vuelvo con new nodo inicializado y apuntando bien, con puntero categ en curso y v0=null



getblock: 		##funcion para obtener un bloque
	addi $sp, $sp, -4
	sw $ra, 4($sp)		#estoy guardando la 2da direcc de retorno en sp, para volver a func new category
	li $v0, 4		
	syscall			#syscall para imprimir msg de catName
	jal smalloc
	move $a0, $v0		#la direcc del bloq que tengo en v0 la copio a a0
	li $a1, 16		#syscall p leer input_string. En a1 reservo sizeMax p el buffer en mem q la almacenara (incluyendo \0)
	li $v0, 8		
	syscall			#Devuelve la cadena almacenada en la direcc guardada en a0 (requiere tener una direcc en a0 este syscall)
	move $v0, $a0		#Copio en v0 la direcc guardada en a0
	lw $ra, 4($sp)		#Recupero la 2da direcc de retorno en ra, que me permitira volver a func new category
	addi $sp, $sp, 4
	jr $ra			#vuelvo a funcion new category (renglon move $a2, $v0), con string almacenado en direcc cargada en v0
		

addnode:
	addi $sp, $sp, -8	#preservo ra en la pila, para poder volver a func new category
	sw $ra, 8($sp)
	sw $a0, 4($sp)		#tambien preservo la direcc cclist (puntero a lista circ)
	jal smalloc		#salto a smalloc para pedir memoria en el heap o un bloque liberado, para crear el nodo categoria
	sw $a1, 4($v0)	#set node content	##vuelvo de smalloc con direcc bloq en v0. En el 2do campo, guardo a1=null
	sw $a2, 8($v0)		#En el 3er campo, puntero al nombre de la categoria
	lw $a0, 4($sp)		#devuelvo en a0 la direcc cargada en el sp (cclist)
	lw $t0, ($a0)	#first node address	##carga en t0 el cont de a0 (cclist). En t0 estoy cargando la direcc del 1er nodo
	beqz $t0, addnode_empty_list	##si cclist=null, salto. Si !null,o sea apunta a un nodo, sigo
	
	addnode_to_end:		#funcion para agregar nodo por detras
		lw $t1, ($t0)	#last node address ##carga en t1 el 1er campo del 1er nodo, o sea la direcc del nodo ant al 1ero (ult nodo)
				#Necesito ir hasta el ult nodo xq la funcion agrega nodos al final (t1 es el ult nodo antes de agregar)
		#update prev and next pointers of new node ##actualizo p_sig y p_ant del nodo cargado
		sw $t1, 0($v0)	#en el 1er campo del nodo nuevo (p_ant), cargo la direcc del que era nodo ant y ahora va a ser anteult.
		sw $t0, 12($v0)	#en el 4to campo del nodo nuevo (p_sig), cargo la direcc a la que apunta cclist (1er nodo)
		#update prev and first node to new node ##actualizo 1er nodo y nodo ant al nodo actual
		sw $v0, 12($t1)	#En el ahora anteult, cargo en su 4to campo (p_sig) la direcc del nuevo nodo ultimo
		sw $v0, 0($t0)	#En el 1er campo del 1er nodo (p_ant), cargo la direcc del nuevo nodo ultimo
		j addnode_exit
	
	addnode_empty_list:	#funcion para agregar nodo a lista vacia
		sw $v0, ($a0)	#guardo en la direccion de cclist, almacenada en a0, la direcc del bloque a usar (v0)
		sw $v0, 0($v0)	#guardo en el 1er campo del bloque la direcc del propio bloque
		sw $v0, 12($v0)	#lo mismo para el ultimo campo del bloque, apunta a si mismo. Sigue a func addnode_exit
		
	addnode_exit:
		lw $ra, 8($sp)		#recupero de sp la direcc para retornar a func new category (renglon lw $t0, wclist)
		addi $sp, $sp, 8
		jr $ra			#vuelvo con un bloque en v0 inicializado(p_ant, p_obj, p_dato, p_sig) 
					#Si el el 1er nodo = ademas, con cclist apuntandolo
					#si no lo es = ademas, con el nodo previo y anterior actualizado apuntando este bloque v0
	
	


nextcategory:
	addiu $sp, $sp, -4	                    
	sw $ra, 4($sp)		#guardo la direccion para retornar al menu
	la $a0, wclist		#cargo la direcc de wclist(direcc del puntero que apunta a la categ en curso)
	lw $t0, ($a0)		#cargo el contenido de wclist(direcc de la categ en curso)
	beqz $t0, error_201
	lw $t1, 12($t0)		#cargo el contenido del 4to campo de la cat en curso (direcc de sig nodo)
	beq $t0, $t1, error_202
	sw $t1, wclist		#Actualizo wclist: guardo el contenido de t1 (direcc del sig nodo) Ahora apunta al sig.
	lw $t2, 8($t1)		#cargo el cont del 3er campo del ahora actual nodo (p_dato:nombre cat)
	la $a0, selCat		#"se ha selecc la cat: "
	li $v0, 4		
	syscall			#syscall para imprimir msg de selCat
	la $a0, ($t2)		#"input_categ"
	li $v0, 4		
	syscall	
	li $v0, 4
	la $a0, return		#imprimo \n
	syscall
	li $v0, 4
	la $a0, success		#imprimo mensaje de exito
	syscall

end_next_prev_category: 
	lw $ra, 4($sp)		#recupero la direcc para volver al menu (renglon: no_nextcategory o no_prevcategory)
	addiu $sp, $sp, 4
	jr $ra	
	
error_201:
	#Imprimir mensaje: Error 201: No hay categorias disponibles.
	li $v0, 4
	la $a0, error201
	syscall
	j end_next_prev_category
		
error_202: 
	#Imprimir mensaje: Error 202: Solo hay una categoria disponible.
	li $v0, 4
	la $a0, error202
	syscall
	j end_next_prev_category
		

prevcategory:
	addiu $sp, $sp, -4	                    
	sw $ra, 4($sp)		#guardo la direccion para retornar al menu
	la $a0, wclist		#cargo la direcc de wclist(direcc del puntero que apunta a la categ en curso)
	lw $t0, ($a0)		#cargo el contenido de wclist(direcc de la categ en curso)
	beqz $t0, error_201
	lw $t1, ($t0)		#cargo el contenido del 1er campo de la cat en curso (direcc de ant nodo)
	beq $t0, $t1, error_202
	sw $t1, wclist		#Actualizo wclist: guardo el contenido de t1 (direcc del ant nodo) Ahora apunta al ant.
	lw $t2, 8($t1)		#cargo el cont del 3er campo del ahora actual nodo (p_dato:nombre cat)
	la $a0, selCat		#"se ha selecc la cat: "
	li $v0, 4		
	syscall			#syscall para imprimir msg de selCat
	la $a0, ($t2)		#"input_categ"
	li $v0, 4		
	syscall
	li $v0, 4
	la $a0, return		#imprimo \n
	syscall
	li $v0, 4
	la $a0, success		#imprimo mensaje de exito
	syscall
	j end_next_prev_category
	
	


listcategory:
	
	addiu $sp, $sp, -4	                    
	sw $ra, 4($sp)		#guardo la direccion para retornar al menu
	li $v0,4
	la $a0, return
	syscall			#imprimo un salto de linea
	lw $t1, wclist		#cargo la direcc del nodo de la categ en curso
	lw $s0, cclist		#cargo el contenido de cclist(direcc al primer nodo de la lista de categ)
	beqz $s0, error_301	#si es null, entonces no hay categorias, error301
	move $t0, $s0		#hago una copia. s0 sera la referencia contra la cual chequear y t0 la variable q cambia en c/ iterac
	###VER!!! LO TENGO QUE PONER EN OTRO LUGAR, VER LA MANERA!!!!
	li $v0, 4
	la $a0, success		#imprimo mensaje de exito
	syscall
	li $v0, 4
	la $a0, return		#imprimo \n
	syscall
	
	loop_list_cat:	#si es la categ selecc, imprimir ">"
		bne $t0, $t1, no_seleccionada	#sin no es wc, sigo con el loop. Si lo es, antes de seguir le imprimo x delante un ">"
		li $v0, 4
		la $a0, wc
		syscall
		
		no_seleccionada:
			li $v0, 4
			lw $a0, 8($t0)
			syscall			# imprimir el primer nodo
			li $v0, 4
			la $a0, return
			syscall
			lw $t0, 12($t0)		#avanzo t0 al siguiente nodo
			beq $t0, $s0, end_listcategory	# chequeo si termina el loop viendo si t0 es == s0
			j loop_list_cat			# repetir hasta salir en el renglon de arriba
				
	end_listcategory:
		li $v0,4
		la $a0, return
		syscall
		lw $ra, 4($sp)		#recupero la direcc para volver al menu (renglon: no_listcategory)
		addiu $sp, $sp, 4
		jr $ra	
	
error_301:
	#Imprimir mensaje: Error 301: No hay categorias disponibles para listar.
	li $v0, 4
	la $a0, error301
	syscall
	j end_listcategory





delcategory:
	
	#Si lista de obj de cat selecc = 0 ->borrar solo la cat y seleccionar como cat automáticamente la sig si existe.
	#Si no existe cat sig, deberá nulificar los punteros necesarios
	#Si !0, 1ero borrar todos los obj, devolviendo la memoria, y luego borrar la cat como se indico antes

	addiu $sp, $sp, -4	                    
	sw $ra, 4($sp)		#guardo la direccion para retornar al menu
	lw $a0, wclist		#cargo el contenido de wclist(direcc al nodo seleccionado de la lista de categ)
	beqz $a0, error_401	#si es null, entonces no hay categorias, error401
	la $a1, wclist
	la $s0, cclist 		#direcc de cclist
	lw $a2, ($s0)		#contenido de cclist
	#si cclist=wclist, actualizo cclist tambien

# a0: node address to delete	##direccion del nodo a eliminar, guardado en wclist
# a1: list address where node is deleted	##direcc de la lista donde se elimino el nodo -> wclist
	delnode:
		addi $sp, $sp, -8
		sw $ra, 8($sp)		#guardo la direcc para desp volver al menu
	
		sw $a0, 4($sp)		#guardo el argumento tmb (direcc del nodo a eliminar)
		lw $a0, 8($a0)		#get block address ##obtener la dirección del bloque (de nombre-dato)
		jal sfree		#free block
		lw $a0, 4($sp)		#restore argument a0	#restauro la direcc del nodo a eliminar
		lw $t0, 12($a0)		#get address to next node of a0 node ##Obtener la direcc del nodo sig al q se iba a eliminar
	
		beq $a0, $t0, delnode_point_self	#es un unico nodo que apunta a si mismo
		lw $t1, 0($a0) 		#get address to prev node #cargo en t1 el cont del 1er campo (direcc del nodo ant)
		sw $t1, 0($t0)		#guardo en el 1er campo del nodo sig(p_ant) la direcc del nodo ant.
		sw $t0, 12($t1)		#guardo en el uilt campo del nodo ant (p_sig) la direcc del nodo sig
		lw $t1, 0($a1)	#??????????????get address to first node again #obtener la direcc del 1er nodo nuevamente. ???????
	
		bne $a0, $t1, delnode_exit	#si el nodo a eliminar ! del sig nodo, paso a exit
	
		bne $a0, $a2, no_actualizar_cclist
		sw $t0, ($s0)	#Actualizo cclist si el nodo a borrar es el primer nodo de la lista categ
	
		no_actualizar_cclist:
			sw $t0, ($a1)		#list point to next node #lista apunta al siguiente nodo
			j delnode_exit
	
		delnode_point_self:
		
			sw $0, ($s0)	#Actualizo cclist
			sw $zero, ($a1)	#only one node ##si es el unico nodo, la lista cat queda vacia, por lo tanto wclist =null\
		
		
		delnode_exit:
			
			addiu $sp, $sp, -8
			sw $a0, 4($sp)
			sw $v0, 8($sp)
			
			li $v0, 4
			la $a0, success		#imprimo mensaje de exito
			syscall
			
			lw $a0, 4($sp)
			lw $v0, 8($sp)
			addiu $sp, $sp, 8
			
			jal sfree
			lw $ra, 8($sp)
			addi $sp, $sp, 8	#recupero la direcc para volver 
			jr $ra


	error_401:
		#Imprimir mensaje: Error 401: No hay categorias disponibles para borrar.
	
		li $v0, 4
		la $a0, return		#imprimo espacio \n	
		syscall
		li $v0, 4
		la $a0, error401
		syscall
		j end_delcategory


	end_delcategory:
		li $v0, 4
		la $a0, return		#imprimo espacio \n 
		syscall
		lw $ra, 4($sp)		#recupero la direcc para volver al menu (renglon: no_delcategory:)
		addiu $sp, $sp, 4
		jr $ra
		
		
sfree: 		#en $a0 debe estar la direccion de memoria del nodo a eliminar	
	lw $t0, slist		#cargo el contenido de slist(direcc de mem de 1er objeto de lista de eliminados)
	sw $t0, 12($a0)		#En el ultimo campo del nodo a eliminar, guardo la direcc de mem de 1er obj lista elim. 
	sw $a0, slist 	#a0 node adrdress in unused list #direcc de nodo a0 en lista de no utilizados. Slist apunta a nodo a borrar
	jr $ra		#vuelvo al menu
	
	
	

#####VOLVER A CHEQUEAR LOS RETURN ADDRESS!!!! A DONDE VOY EN CADA SALTO??????




newobject:	#anexar un objeto a la categoria seleccionada en curso
	addiu $sp, $sp, -4	                    
	sw $ra, 4($sp)		#guardo la direccion para retornar al menu
	lw $s0, wclist		#cargo el contenido de wclist(direcc al nodo seleccionado de la lista de categ)
	beqz $s0, error_501	#wclist=null
	la $a0, objName		#cargo la direcc de objName (msg) "\nIngrese el nombre de un objeto: "
	jal getblock		#de este voy a volver con el input nombre obj en la direcc de v0
	move $a2, $v0 	#a2= *char to category name	##a2 ahora va a ser puntero al nombre de la categoria
	addi $a0, $s0, 4	#cargo en a0 la direcc de s0+4, que es el 2do campo de la categ, que estara apuntando a lista obj
	li $a1, 0 	#a1=null	
	jal addnode
	li $v0, 0 	#return success	##cargo 0 en v0 (null)
	li $v0, 4
	la $a0, success		#imprimo mensaje de exito
	syscall
	
	end_newobject: 
		lw $ra, 4($sp)		#recupero la direcc para volver al menu (renglon: no_newobject:)
		addiu $sp, $sp, 4
		jr $ra			#vuelvo con new nodo inicializado y apuntando bien, con puntero categ en curso y v0=null	
	
	
	error_501:
		#Imprimir mensaje: Error 501: No hay categorias disponibles para anexar objetos.
	
		li $v0, 4
		la $a0, return		#imprimo espacio \n	
		syscall
		li $v0, 4
		la $a0, error501
		syscall
		j end_newobject
		





listobjects: 	#listar objetos de la categoria en curso
	addiu $sp, $sp, -4	                    
	sw $ra, 4($sp)		#guardo la direccion para retornar al menu
	lw $s0, wclist		#cargo el contenido de wclist(direcc al nodo seleccionado de la lista de categ)
	beqz $s0, error_601	#wclist=null
	lw $s1, 4($s0)		#cargo el cont del 2do campo de la cat. (ahi esta la direcc al 1er elem obj
	beqz $s1, error_602
	
	move $t0, $s1		#hago una copia. s1 es la referencia contra la cual chequear y t0 la variable q cambia en c/ iterac
	###VER!!! LO TENGO QUE PONER EN OTRO LUGAR, VER LA MANERA!!!!
	li $v0, 4
	la $a0, success		#imprimo mensaje de exito
	syscall
	li $v0, 4
	la $a0, return		#imprimo \n
	syscall
	
	loop_list_obj:	
		li $v0, 4
		lw $a0, 8($t0)
		syscall			# imprimir el primer nodo
		li $v0, 4
		la $a0, return		#imprimir \n
		syscall
		lw $t0, 12($t0)		#avanzo t0 al siguiente nodo
		beq $t0, $s1, end_listobject	# chequeo si termina el loop viendo si t0 es == s1
		j loop_list_obj		# repetir hasta salir en el renglon de arriba
	

	error_601:
	#Imprimir mensaje: Error 601: No hay categorias disponibles para acceder a sus objetos.
	
		li $v0, 4
		la $a0, return		#imprimo espacio \n	
		syscall
		li $v0, 4
		la $a0, error601
		syscall
		j end_listobject	
	
	
	error_602:
	#Imprimir mensaje: Error 602: No hay objetos creados para la categoria seleccionada.
	
		li $v0, 4
		la $a0, return		#imprimo espacio \n	
		syscall
		li $v0, 4
		la $a0, error602
		syscall
		j end_listobject	
	

	end_listobject:
		li $v0,4
		la $a0, return
		syscall
		lw $ra, 4($sp)		#recupero la direcc para volver al menu 
		addiu $sp, $sp, 4
		jr $ra	





delobject:	
#Borrar un objeto de la categoría seleccionada en curso usando el ID. 
#Si el ID provisto no es encontrado se informará con un mensaje notFound
#Si no existen categorías el error (701).

	addiu $sp, $sp, -4	                    
	sw $ra, 4($sp)		#guardo la direccion para retornar al menu


	error_701:
	#Imprimir mensaje: Error 701: No hay categorias ingresadas.
	
		li $v0, 4
		la $a0, return		#imprimo espacio \n	
		syscall
		li $v0, 4
		la $a0, error701
		syscall
		j end_delobject	
	

	end_delobject:
		li $v0,4
		la $a0, return
		syscall
		lw $ra, 4($sp)		#recupero la direcc para volver al menu 
		addiu $sp, $sp, 4
		jr $ra	






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

	
