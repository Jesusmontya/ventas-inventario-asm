; Sistema de inventario y ventas - MASM x86 / Irvine32
; Precio: centavos enteros; catalogo: registros de 42 bytes.
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
INCLUDE Irvine32.inc

MAXPROD EQU 10
RECSIZE EQU 42
PRICEOFF EQU 34
STOCKOFF EQU 38
IMAGESIZE EQU 428             ; firma(4) + cantidad(4) + 10 registros

.data
menu BYTE 13,10,'1 Registrar  2 Listar  3 Buscar  4 Entrada  5 Venta',13,10
     BYTE '6 Resumen    7 Guardar  8 Cargar  9 Salir',13,10,'Opcion: ',0
pCode BYTE 'Codigo (ABC-123): ',0
pName BYTE 'Nombre (1 a 25 caracteres): ',0
pPrice BYTE 'Precio en MXN (0.01 a 9999.99): ',0
pStock BYTE 'Existencia inicial (0 a 100): ',0
pQty BYTE 'Cantidad entera mayor que cero: ',0
bad BYTE 'Dato invalido. Intente de nuevo.',13,10,0
badCode BYTE 'Codigo invalido o ya registrado.',13,10,0
fullMsg BYTE 'Capacidad maxima alcanzada.',13,10,0
notFound BYTE 'Producto no encontrado.',13,10,0
stockErr BYTE 'Operacion rechazada: existencias insuficientes o limite excedido.',13,10,0
okMsg BYTE 'Operacion realizada.',13,10,0
moneyMsg BYTE ' MXN',0
spaceMsg BYTE ' | ',0
stockMsg BYTE ' | Existencia: ',0
saleMsg BYTE 'Total de venta: ',0
discountMsg BYTE 'Descuento de mayoreo: 2%.',13,10,0
unitMsg BYTE 'Unidades disponibles: ',0
valueMsg BYTE 'Valor del inventario: ',0
incomeMsg BYTE 'Ingresos de la sesion: ',0
fileName BYTE 'inventario.bin',0
fileOK BYTE 'Archivo guardado correctamente.',13,10,0
loadOK BYTE 'Catalogo cargado correctamente.',13,10,0
fileErr BYTE 'Archivo ausente, invalido o error de lectura/escritura.',13,10,0
unsavedMsg BYTE 'Hay cambios sin guardar. 1 Guardar, 2 Descartar, 3 Cancelar: ',0
overMsg BYTE 'Operacion rechazada: desbordamiento de ingresos.',13,10,0
emptyMsg BYTE 'No hay productos registrados.',13,10,0
inputBuffer BYTE 256 DUP(0)
numBuffer BYTE 16 DUP(0)
; Imagen de archivo completa. Campos de codigo y nombre incluyen cero final.
imageStart LABEL BYTE
magic BYTE 'INV1'
productCount DWORD 4
records LABEL BYTE
BYTE 'TET-500',0,'Te 500ml',18 DUP(0)
DWORD 1500,50
BYTE 'TET-001',0,'Te 1 litro',16 DUP(0)
DWORD 3000,30
BYTE 'TET-002',0,'Te 2 litros',15 DUP(0)
DWORD 4500,20
BYTE 'TET-005',0,'Te 5 litros',15 DUP(0)
DWORD 9000,10
BYTE (6*RECSIZE) DUP(0)
imageEnd LABEL BYTE
stage BYTE IMAGESIZE DUP(0)
extraByte BYTE 0
fileHandle DWORD 0
bytesRead DWORD 0
income DWORD 0
dirty DWORD 0
selected DWORD 0
quantity DWORD 0
subtotal DWORD 0
workCode BYTE 8 DUP(0)
workName BYTE 26 DUP(0)
workPrice DWORD 0
workStock DWORD 0

.code
; Lectura acotada. Entrada EDX = mensaje; salida inputBuffer, EAX = longitud.
; Modifica EAX, ECX, EDX; ReadString siempre termina con cero.
ReadLine PROC
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, SIZEOF inputBuffer
    call ReadString
    ret
ReadLine ENDP

; Convertir cadena decimal no vacia a entero sin signo.
; Salida EAX=valor, CF=0; CF=1 si invalido o desbordamiento.
; Conserva EBX, ECX, EDX, ESI.
ParseUInt PROC
    push ebx
    push ecx
    push edx
    push esi
    mov esi, OFFSET inputBuffer
    xor eax, eax
    cmp BYTE PTR [esi], 0
    je pu_error
pu_next:
    movzx ecx, BYTE PTR [esi]
    test ecx, ecx
    jz pu_ok
    cmp ecx, '0'
    jb pu_error
    cmp ecx, '9'
    ja pu_error
    sub ecx, '0'
    mov ebx, 10
    mul ebx
    test edx, edx
    jnz pu_error
    add eax, ecx
    jc pu_error
    inc esi
    jmp pu_next
pu_ok:
    clc
    jmp pu_end
pu_error:
    stc
pu_end:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
ParseUInt ENDP

; Convierte precio escrito en pesos a centavos: 1 o 2 decimales opcionales.
; Salida EAX=centavos, CF indica error. Conserva EBX, ECX, EDX, ESI, EDI.
ParsePrice PROC
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov esi, OFFSET inputBuffer
    xor eax, eax
    xor edi, edi                ; cantidad de digitos enteros
pp_integer:
    movzx ecx, BYTE PTR [esi]
    cmp ecx, '0'
    jb pp_int_end
    cmp ecx, '9'
    ja pp_int_end
    inc edi
    cmp edi, 4
    ja pp_error
    sub ecx, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp pp_integer
pp_int_end:
    test edi, edi
    jz pp_error
    imul eax, 100
    cmp BYTE PTR [esi], 0
    je pp_range
    cmp BYTE PTR [esi], '.'
    jne pp_error
    inc esi
    movzx ecx, BYTE PTR [esi]
    cmp ecx, '0'
    jb pp_error
    cmp ecx, '9'
    ja pp_error
    sub ecx, '0'
    imul ecx, 10
    add eax, ecx
    inc esi
    cmp BYTE PTR [esi], 0
    je pp_range
    movzx ecx, BYTE PTR [esi]
    cmp ecx, '0'
    jb pp_error
    cmp ecx, '9'
    ja pp_error
    sub ecx, '0'
    add eax, ecx
    inc esi
    cmp BYTE PTR [esi], 0
    jne pp_error
pp_range:
    cmp eax, 1
    jb pp_error
    cmp eax, 999999
    ja pp_error
    clc
    jmp pp_end
pp_error:
    stc
pp_end:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
ParsePrice ENDP

; ESI apunta a codigo de 8 bytes. CF=0 si cumple AAA-999 y termina en cero.
; Conserva EAX, ECX, ESI.
ValidCode PROC
    push eax
    push ecx
    push esi
    mov ecx, 3
vc_letters:
    mov al, [esi]
    cmp al, 'A'
    jb vc_bad
    cmp al, 'Z'
    ja vc_bad
    inc esi
    loop vc_letters
    cmp BYTE PTR [esi], '-'
    jne vc_bad
    inc esi
    mov ecx, 3
vc_digits:
    mov al, [esi]
    cmp al, '0'
    jb vc_bad
    cmp al, '9'
    ja vc_bad
    inc esi
    loop vc_digits
    cmp BYTE PTR [esi], 0
    jne vc_bad
    clc
    jmp vc_end
vc_bad:
    stc
vc_end:
    pop esi
    pop ecx
    pop eax
    ret
ValidCode ENDP

; Entrada EAX indice. Salida EDI apunta al registro. Modifica EDI.
RecordAt PROC
    imul edi, eax, RECSIZE
    add edi, OFFSET records
    ret
RecordAt ENDP

; Buscar inputBuffer por codigo. EAX=indice o FFFFFFFFh. Conserva EBX,ECX,EDX,ESI,EDI.
FindCode PROC
    push ebx
    push ecx
    push edx
    push esi
    push edi
    xor ebx, ebx
fc_loop:
    cmp ebx, productCount
    jae fc_none
    mov eax, ebx
    call RecordAt
    mov esi, OFFSET inputBuffer
    mov ecx, 8
    cld
    repe cmpsb
    je fc_found
    inc ebx
    jmp fc_loop
fc_found:
    mov eax, ebx
    jmp fc_end
fc_none:
    mov eax, 0FFFFFFFFh
fc_end:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
FindCode ENDP

; Imprime EAX sin signo mediante conversion propia. Conserva registros.
PrintUInt PROC
    pushad
    mov edi, OFFSET numBuffer+15
    mov BYTE PTR [edi], 0
    mov ebx, 10
pu_convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz pu_convert
    mov edx, edi
    call WriteString
    popad
    ret
PrintUInt ENDP

; Imprime EAX centavos con exactamente dos decimales y MXN. Conserva registros.
PrintMoney PROC
    pushad
    xor edx, edx
    mov ebx, 100
    div ebx
    push edx
    call PrintUInt
    mov al, '.'
    call WriteChar
    pop eax
    cmp eax, 10
    jae pm_two
    push eax
    mov al, '0'
    call WriteChar
    pop eax
pm_two:
    call PrintUInt
    mov edx, OFFSET moneyMsg
    call WriteString
    popad
    ret
PrintMoney ENDP

; EAX=indice. Imprime codigo, nombre, precio y existencia. Conserva registros.
PrintRecord PROC
    pushad
    call RecordAt
    mov edx, edi
    call WriteString
    mov edx, OFFSET spaceMsg
    call WriteString
    lea edx, [edi+8]
    call WriteString
    mov edx, OFFSET spaceMsg
    call WriteString
    mov eax, [edi+PRICEOFF]
    call PrintMoney
    mov edx, OFFSET stockMsg
    call WriteString
    mov eax, [edi+STOCKOFF]
    call PrintUInt
    call Crlf
    popad
    ret
PrintRecord ENDP

; Pide codigo valido y existente. CF=0 y selected=indice; CF=1 no encontrado.
ChooseProduct PROC
    pushad
choose_retry:
    mov edx, OFFSET pCode
    call ReadLine
    mov esi, OFFSET inputBuffer
    call ValidCode
    jc choose_bad
    call FindCode
    cmp eax, 0FFFFFFFFh
    je choose_missing
    mov selected, eax
    popad
    clc
    ret
choose_bad:
    mov edx, OFFSET bad
    call WriteString
    jmp choose_retry
choose_missing:
    mov edx, OFFSET notFound
    call WriteString
    popad
    stc
    ret
ChooseProduct ENDP

; Pide cantidad entre 1 y 100. La operacion aplica su propio limite adicional.
ReadQuantity PROC
    pushad
rq_retry:
    mov edx, OFFSET pQty
    call ReadLine
    call ParseUInt
    jc rq_bad
    cmp eax, 1
    jb rq_bad
    cmp eax, 100
    ja rq_bad
    mov quantity, eax
    popad
    ret
rq_bad:
    mov edx, OFFSET bad
    call WriteString
    jmp rq_retry
ReadQuantity ENDP

; Alta transaccional: guarda datos temporales y modifica catalogo al terminar.
RegisterProduct PROC
    pushad
    cmp productCount, MAXPROD
    jae reg_full
reg_code:
    mov edx, OFFSET pCode
    call ReadLine
    mov esi, OFFSET inputBuffer
    call ValidCode
    jc reg_code_bad
    call FindCode
    cmp eax, 0FFFFFFFFh
    jne reg_code_bad
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET workCode
    mov ecx, 8
    cld
    rep movsb
    jmp reg_name
reg_code_bad:
    mov edx, OFFSET badCode
    call WriteString
    jmp reg_code
reg_name:
    mov edx, OFFSET pName
    call ReadLine
    cmp eax, 1
    jb reg_name_bad
    cmp eax, 25
    ja reg_name_bad
    ; Limpia el destino y copia incluyendo el terminador.
    mov ecx, 26
    mov edi, OFFSET workName
    xor eax, eax
    cld
    rep stosb
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET workName
reg_copy_name:
    lodsb
    stosb
    test al, al
    jnz reg_copy_name
    jmp reg_price
reg_name_bad:
    mov edx, OFFSET bad
    call WriteString
    jmp reg_name
reg_price:
    mov edx, OFFSET pPrice
    call ReadLine
    call ParsePrice
    jc reg_price_bad
    mov workPrice, eax
    jmp reg_stock
reg_price_bad:
    mov edx, OFFSET bad
    call WriteString
    jmp reg_price
reg_stock:
    mov edx, OFFSET pStock
    call ReadLine
    call ParseUInt
    jc reg_stock_bad
    cmp eax, 100
    ja reg_stock_bad
    mov workStock, eax
    jmp reg_commit
reg_stock_bad:
    mov edx, OFFSET bad
    call WriteString
    jmp reg_stock
reg_commit:
    mov eax, productCount
    call RecordAt
    mov esi, OFFSET workCode
    mov ecx, 8
    cld
    rep movsb
    mov esi, OFFSET workName
    mov ecx, 26
    rep movsb
    mov eax, workPrice
    stosd
    mov eax, workStock
    stosd
    inc productCount
    mov dirty, 1
    mov edx, OFFSET okMsg
    call WriteString
    jmp reg_end
reg_full:
    mov edx, OFFSET fullMsg
    call WriteString
reg_end:
    popad
    ret
RegisterProduct ENDP

ListProducts PROC
    pushad
    cmp productCount, 0
    jne list_start
    mov edx, OFFSET emptyMsg
    call WriteString
    jmp list_end
list_start:
    xor esi, esi
list_loop:
    cmp esi, productCount
    jae list_end
    mov eax, esi
    call PrintRecord
    inc esi
    jmp list_loop
list_end:
    popad
    ret
ListProducts ENDP

SearchProduct PROC
    pushad
    call ChooseProduct
    jc search_end
    mov eax, selected
    call PrintRecord
search_end:
    popad
    ret
SearchProduct ENDP

ReceiveStock PROC
    pushad
    call ChooseProduct
    jc recv_end
    call ReadQuantity
    mov eax, selected
    call RecordAt
    mov eax, [edi+STOCKOFF]
    add eax, quantity
    cmp eax, 100
    ja recv_bad
    mov [edi+STOCKOFF], eax
    mov dirty, 1
    mov edx, OFFSET okMsg
    call WriteString
    jmp recv_end
recv_bad:
    mov edx, OFFSET stockErr
    call WriteString
recv_end:
    popad
    ret
ReceiveStock ENDP

; Venta aplica 2% desde 5 unidades. Descuento trunca fracciones de centavo.
SellProduct PROC
    pushad
    call ChooseProduct
    jc sell_end
    call ReadQuantity
    mov eax, selected
    call RecordAt
    mov ebx, quantity
    cmp ebx, [edi+STOCKOFF]
    ja sell_stock_error
    mov eax, [edi+PRICEOFF]
    mul ebx
    test edx, edx
    jnz sell_overflow
    mov subtotal, eax
    cmp ebx, 5
    jb sell_total
    mov ecx, 2
    mul ecx
    mov ecx, 100
    div ecx
    sub subtotal, eax
sell_total:
    mov eax, income
    add eax, subtotal
    jc sell_overflow
    mov income, eax
    mov eax, quantity
    sub [edi+STOCKOFF], eax
    mov dirty, 1
    cmp quantity, 5
    jb sell_show
    mov edx, OFFSET discountMsg
    call WriteString
sell_show:
    mov edx, OFFSET saleMsg
    call WriteString
    mov eax, subtotal
    call PrintMoney
    call Crlf
    jmp sell_end
sell_stock_error:
    mov edx, OFFSET stockErr
    call WriteString
    jmp sell_end
sell_overflow:
    mov edx, OFFSET overMsg
    call WriteString
sell_end:
    popad
    ret
SellProduct ENDP

ShowSummary PROC
    pushad
    xor esi, esi
    xor ebx, ebx
    xor ebp, ebp
summary_loop:
    cmp esi, productCount
    jae summary_show
    mov eax, esi
    call RecordAt
    add ebx, [edi+STOCKOFF]
    mov eax, [edi+PRICEOFF]
    mul DWORD PTR [edi+STOCKOFF]
    add ebp, eax
    inc esi
    jmp summary_loop
summary_show:
    mov edx, OFFSET unitMsg
    call WriteString
    mov eax, ebx
    call PrintUInt
    call Crlf
    mov edx, OFFSET valueMsg
    call WriteString
    mov eax, ebp
    call PrintMoney
    call Crlf
    mov edx, OFFSET incomeMsg
    call WriteString
    mov eax, income
    call PrintMoney
    call Crlf
    popad
    ret
ShowSummary ENDP

; Validar stage antes de tocar catalogo: firma, cantidad, campos y duplicados.
; CF=0 valido; CF=1 invalido. Conserva todos los registros.
ValidateImage PROC
    pushad
    cmp DWORD PTR [stage], 31564E49h ; bytes INV1 en little endian
    jne vi_bad
    mov eax, DWORD PTR [stage+4]
    cmp eax, MAXPROD
    ja vi_bad
    xor ebx, ebx
vi_each:
    cmp ebx, DWORD PTR [stage+4]
    jae vi_ok
    imul edi, ebx, RECSIZE
    add edi, OFFSET stage+8
    mov esi, edi
    call ValidCode
    jc vi_bad
    ; Nombre: 1 a 25 caracteres, terminado dentro de sus 26 bytes.
    cmp BYTE PTR [edi+8], 0
    je vi_bad
    lea esi, [edi+8]
    mov ecx, 26
vi_name:
    cmp BYTE PTR [esi], 0
    je vi_price
    inc esi
    loop vi_name
    jmp vi_bad
vi_price:
    mov eax, [edi+PRICEOFF]
    cmp eax, 1
    jb vi_bad
    cmp eax, 999999
    ja vi_bad
    cmp DWORD PTR [edi+STOCKOFF], 100
    ja vi_bad
    xor ebp, ebp
vi_duplicate:
    cmp ebp, ebx
    jae vi_next
    imul esi, ebp, RECSIZE
    add esi, OFFSET stage+8
    push edi
    push ecx
    mov ecx, 8
    cld
    repe cmpsb
    pop ecx
    pop edi
    je vi_bad
    inc ebp
    jmp vi_duplicate
vi_next:
    inc ebx
    jmp vi_each
vi_ok:
    popad
    clc
    ret
vi_bad:
    popad
    stc
    ret
ValidateImage ENDP

; Guardar archivo. CF=0 si se escribieron exactamente todos los bytes.
; Conserva los registros. Solo limpia dirty tras confirmar escritura.
SaveFile PROC
    pushad
    mov edx, OFFSET fileName
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je sf_error
    mov fileHandle, eax
    mov edx, OFFSET imageStart
    mov ecx, IMAGESIZE
    call WriteToFile
    jc sf_close_error
    cmp eax, IMAGESIZE
    jne sf_close_error
    mov eax, fileHandle
    call CloseFile
    mov dirty, 0
    mov edx, OFFSET fileOK
    call WriteString
    popad
    clc
    ret
sf_close_error:
    mov eax, fileHandle
    call CloseFile
sf_error:
    mov edx, OFFSET fileErr
    call WriteString
    popad
    stc
    ret
SaveFile ENDP

; Leer archivo en stage, exigir tamano exacto y validar antes de reemplazar.
; Si falla deja el catalogo en memoria sin cambios. CF indica resultado.
LoadFile PROC
    pushad
    mov edx, OFFSET fileName
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je lf_error
    mov fileHandle, eax
    mov edx, OFFSET stage
    mov ecx, IMAGESIZE
    call ReadFromFile
    jc lf_close_error
    cmp eax, IMAGESIZE
    jne lf_close_error
    mov eax, fileHandle
    mov edx, OFFSET extraByte
    mov ecx, 1
    call ReadFromFile
    jc lf_close_error
    cmp eax, 0
    jne lf_close_error
    mov eax, fileHandle
    call CloseFile
    call ValidateImage
    jc lf_error
    mov esi, OFFSET stage
    mov edi, OFFSET imageStart
    mov ecx, IMAGESIZE
    cld
    rep movsb
    mov dirty, 0
    mov edx, OFFSET loadOK
    call WriteString
    popad
    clc
    ret
lf_close_error:
    mov eax, fileHandle
    call CloseFile
lf_error:
    mov edx, OFFSET fileErr
    call WriteString
    popad
    stc
    ret
LoadFile ENDP

; Confirma que es seguro perder cambios: 1 guarda, 2 descarta, 3 cancela.
; CF=0 continuar; CF=1 cancelar. No modifica dirty al elegir descartar.
ConfirmUnsaved PROC
    pushad
    cmp dirty, 0
    je cu_yes
cu_prompt:
    mov edx, OFFSET unsavedMsg
    call ReadLine
    call ParseUInt
    jc cu_prompt
    cmp eax, 1
    je cu_save
    cmp eax, 2
    je cu_yes
    cmp eax, 3
    je cu_no
    jmp cu_prompt
cu_save:
    call SaveFile
    jc cu_no
cu_yes:
    popad
    clc
    ret
cu_no:
    popad
    stc
    ret
ConfirmUnsaved ENDP

main PROC
    cld
    call LoadFile             ; si no existe, se conserva catalogo inicial
main_menu:
    mov edx, OFFSET menu
    call ReadLine
    call ParseUInt
    jc main_bad
    cmp eax, 1
    je main_register
    cmp eax, 2
    je main_list
    cmp eax, 3
    je main_search
    cmp eax, 4
    je main_receive
    cmp eax, 5
    je main_sell
    cmp eax, 6
    je main_summary
    cmp eax, 7
    je main_save
    cmp eax, 8
    je main_load
    cmp eax, 9
    je main_exit
main_bad:
    mov edx, OFFSET bad
    call WriteString
    jmp main_menu
main_register:
    call RegisterProduct
    jmp main_menu
main_list:
    call ListProducts
    jmp main_menu
main_search:
    call SearchProduct
    jmp main_menu
main_receive:
    call ReceiveStock
    jmp main_menu
main_sell:
    call SellProduct
    jmp main_menu
main_summary:
    call ShowSummary
    jmp main_menu
main_save:
    call SaveFile
    jmp main_menu
main_load:
    call ConfirmUnsaved
    jc main_menu
    call LoadFile
    jmp main_menu
main_exit:
    call ConfirmUnsaved
    jc main_menu
    INVOKE ExitProcess, 0
main ENDP
END main
