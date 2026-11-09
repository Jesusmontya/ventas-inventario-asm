# Plan de pruebas manuales

Estas son entradas y resultados **esperados**. La columna de resultado obtenido debe llenarse tras ejecutar en Windows con MASM e Irvine32; no se ha ejecutado en ese entorno.

| Caso | Entrada | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| Lista inicial | Abrir archivo de muestra; opción 2 | Cuatro tés, códigos válidos y precios con dos decimales MXN | Pendiente |
| Alta válida | `ABC-123`, `Te verde`, `185.50`, `10` | Producto registrado; precio 185.50 MXN | Pendiente |
| Duplicado | Registrar de nuevo `ABC-123` | Rechaza el código y permite capturarlo de nuevo | Pendiente |
| Código inválido | `abc-123`, `ABC-12A`, `AB-1234` | Rechaza cada código | Pendiente |
| Nombre inválido | Vacío o más de 25 caracteres | Rechaza y vuelve a pedir | Pendiente |
| Precios válidos | `185.50`, `12.05`, `15`, `15.5` | 185.50, 12.05, 15.00, 15.50 MXN | Pendiente |
| Precios inválidos | `0`, `10000`, `1.234`, `1,000`, `$1`, `12.` | Rechaza y vuelve a pedir | Pendiente |
| Buscar | Opción 3, `TET-500` | Muestra datos del té de 500 ml | Pendiente |
| Buscar inexistente | Opción 3, `ABC-999` | Mensaje de producto no encontrado | Pendiente |
| Entrada válida | `TET-005`, 20 | Existencia de 10 a 30 | Pendiente |
| Entrada excesiva | `TET-500`, 51 desde existencia 50 | Rechaza y conserva 50 | Pendiente |
| Cantidad inválida | Venta o entrada: `0`, `-1`, `hola` | Rechaza y vuelve a pedir | Pendiente |
| Venta normal | `TET-500`, 2 desde 50 | 30.00 MXN, existencia 48 | Pendiente |
| Mayoreo | `TET-001`, 5 desde 30 | Descuento 2%, total 147.00 MXN, existencia 25 | Pendiente |
| Venta excesiva | `TET-005`, 11 desde 10 | Rechaza sin alterar el catálogo ni ingresos | Pendiente |
| Resumen inicial | Opción 6 con archivo de muestra intacto | 110 unidades y 3450.00 MXN; ingresos 0.00 MXN | Pendiente |
| Guardar y recuperar | Registrar, guardar, salir y reiniciar | Se recuperan código, nombre, precio y existencia | Pendiente |
| Archivo ausente | Renombrar inventario.bin, iniciar | Aviso y catálogo base | Pendiente |
| Archivo inválido | Truncar o modificar firma de una copia, cargar | Aviso, sin reemplazar catálogo en memoria | Pendiente |
| Salida con cambios | Modificar, seleccionar 9 | Ofrece guardar, descartar o cancelar | Pendiente |
| Capacidad | Completar 10 productos e intentar otro | Informa que se alcanzó el máximo | Pendiente |

Restaurar el archivo de muestra antes de cada caso independiente para obtener las existencias indicadas. Los resultados obtenidos y cualquier captura deben proceder de la ejecución real del equipo.
