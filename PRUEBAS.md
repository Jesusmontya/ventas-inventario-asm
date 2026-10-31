# Tabla de pruebas

Las pruebas se plantearon con el inventario inicial incluido. Los resultados obtenidos indican el comportamiento que muestra la ejecución manual del flujo descrito.

| Caso | Entrada | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| Consulta válida | Opción 2, índice `0` | Muestra `Te 500ml` | Se muestra el nombre del producto 0 |
| Venta normal | Opción 3, índice `0`, cantidad `2` | Total `$30.00`; stock pasa de 50 a 48 | Total mostrado `30.0`; stock actualizado a 48 |
| Venta con mayoreo | Opción 3, índice `1`, cantidad `5` | 5 × $30.00 − 2% = `$147.00` | Muestra aviso de descuento y total `147.0` |
| Venta sin stock suficiente | Opción 3, índice `3`, cantidad `11` | Mensaje de existencias insuficientes | Se rechaza la operación |
| Entrada permitida | Opción 4, índice `3`, cantidad `20` | Stock pasa de 10 a 30 | Operación exitosa |
| Entrada que excede límite | Opción 4, índice `0`, cantidad `51` | Mensaje de máximo 100 unidades | Se rechaza la operación |
| Código duplicado | Opción 1, código `TET-500` | Mensaje de código existente | Se rechaza el registro |
| Guardado | Opción 6 | Crea/actualiza `inventario.bin` | Muestra confirmación de guardado |
