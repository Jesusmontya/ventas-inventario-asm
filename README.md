# Sistema de ventas e inventario en ensamblador

Proyecto de la Unidad 2 para gestionar un catálogo de productos, sus existencias y ventas desde consola.

## Integrantes

- Jesus Pavel Montoya Cerpa
- Jesus Dadynirt Gamez Guerrero
- Noel Sebastian Rodriguez Sainz

## Contenido

- `AddTwo.asm`: código fuente MASM x86.
- `inventario-inicial.txt`: catálogo y existencias de referencia.
- `INFORME.md`: informe breve de diseño y funcionamiento.
- `PRUEBAS.md`: tabla de entradas, resultados esperados y resultados obtenidos.

## Requisitos

- Windows.
- Visual Studio con las herramientas de C++ de escritorio y MASM (`ml.exe`).
- La biblioteca **Irvine32**, configurada siguiendo la instalación indicada por el curso.

## Compilación y ejecución en Visual Studio

1. Cree un proyecto vacío de C++ para Windows de 32 bits (`x86`).
2. Agregue `AddTwo.asm` al proyecto y marque el archivo como elemento de compilación MASM.
3. Configure las rutas de inclusión y bibliotecas de Irvine32, incluyendo `Irvine32.inc` y `Irvine32.lib`.
4. Compile en configuración `Debug` o `Release`, plataforma `x86`.
5. Ejecute el programa desde Visual Studio o el archivo `.exe` generado.

El programa crea o actualiza `inventario.bin` al usar la opción 6. Ese archivo guarda los stocks como datos binarios y se vuelve a cargar al iniciar la aplicación.

## Funciones incluidas

1. Alta de productos (máximo 10), validando código y duplicados.
2. Consulta por índice y listado del inventario.
3. Venta con validación de existencia y descuento de 2% desde 5 unidades.
4. Recepción de mercancía sin exceder 100 unidades por producto.
5. Resumen de unidades, valor de inventario e ingresos de la sesión.
6. Persistencia de existencias en archivo.

## Uso rápido

Al iniciar aparece el menú. Para una venta, seleccione `3`, indique el índice de producto mostrado en pantalla y la cantidad. Para guardar existencias, seleccione `6`. El importe se maneja internamente en centavos para evitar errores de redondeo.
