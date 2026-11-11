# Informe de diseño

## Objetivo y negocio
Administrar el inventario y las ventas de una tienda de té desde consola, mediante MASM x86 e Irvine32. Se soportan hasta diez productos.

## Organización de memoria
El catálogo es una imagen de 428 bytes: firma ASCII `INV1` (4 bytes), contador de productos (DWORD) y 10 registros de 42 bytes. Cada registro contiene código de 8 bytes incluyendo el cero final, nombre de 26 bytes incluyendo el cero final, precio en centavos DWORD y existencias DWORD. El producto i comienza en `records + i*42`; ESI se usa para recorridos y copias. Los precios se guardan en centavos enteros.

## Procedimientos y decisiones
`ReadLine` usa ReadString. `ParseUInt` convierte y valida enteros con detección de desbordamiento; `ParsePrice` convierte pesos y uno o dos decimales a centavos y valida límites. `ValidCode` exige tres mayúsculas, guion, tres dígitos y terminador; `FindCode` busca y detecta duplicados. `PrintUInt` divide entre 10 repetidamente y `PrintMoney` divide entre 100 para mostrar dos decimales y MXN. Las cabeceras del código describen parámetros y registros; las operaciones de alto nivel preservan registros con `pushad`/`popad` y las subrutinas terminan con `ret`.

Las altas se preparan en variables temporales y se incorporan solo después de validar todos los campos. Una entrada o venta rechazada no cambia las existencias. La venta revisa los ingresos antes de actualizarlos para evitar desbordamiento. La regla adicional es 2% de descuento a partir de 5 unidades: se calcula el 2% del subtotal en centavos, truncando las fracciones de centavo; se resta esa cifra y el resultado se acumula en ingresos.

## Archivo
`inventario.bin` guarda los 428 bytes de la imagen del catálogo. Al cargar se lee a un área temporal, se exige tamaño exacto, firma, contador, formato de códigos, nombres terminados, precios, existencias y unicidad. Solo después se reemplaza el catálogo en memoria. Las operaciones comprueban errores de lectura/escritura y el número de bytes. El aviso de cambios permite guardar, descartar o cancelar. Los ingresos son de la sesión y no se persisten.

## Investigación y fuentes
- Documentación suministrada con Irvine32 en el entorno del curso: contratos de ReadString, OpenInputFile, ReadFromFile, CreateOutputFile, WriteToFile y CloseFile.
- Intel, *Intel 64 and IA-32 Architectures Software Developer's Manual*, instrucciones DIV, MUL, CALL, RET, PUSHAD y POPAD: https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html

La investigación y explicación individual debe completarse por cada integrante según la rúbrica. La ejecución real debe verificarse en Windows con la instalación específica de MASM e Irvine32.
