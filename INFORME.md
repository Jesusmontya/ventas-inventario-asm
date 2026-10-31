# Informe breve

## Objetivo

Desarrollar en ensamblador x86 un sistema de consola para administrar ventas e inventario de una tienda. El sistema mantiene hasta diez productos, controla existencias y conserva el inventario entre ejecuciones.

## Diseño

Los códigos, nombres, precios y stocks se almacenan en arreglos paralelos. Los precios se representan en centavos (`DWORD`) y el formato de salida divide entre 100 para mostrar pesos mexicanos. Cada producto admite hasta 100 unidades.

Las rutinas principales son `RegistrarProducto`, `BuscarProductoUI`, `RealizarVenta`, `RecibirMercancia`, `MostrarResumen`, `CargarInventarioInicio` y `GuardarInventarioArchivo`.

## Reglas implementadas

- Máximo de 10 productos.
- Validación del separador `-` en el código y detección de códigos duplicados.
- Rechazo de índices inválidos, ventas mayores al stock y entradas que rebasen 100 unidades.
- Descuento de 2% en ventas de cinco o más unidades.
- Persistencia de stocks en `inventario.bin`.

## Limitaciones y mejora futura

La validación actual comprueba el guion del código; como mejora se puede validar estrictamente cada carácter del patrón `ABC-123`. También puede ampliarse el archivo persistente para almacenar altas de productos, además de las existencias.
