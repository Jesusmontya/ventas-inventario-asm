# Ventas e inventario en ensamblador

Sistema de consola en MASM x86 de 32 bits con Irvine32. Capacidad: 10 productos; código AAA-999; nombre de 1 a 25 caracteres; precio de 0.01 a 9999.99 MXN y existencia de 0 a 100.

## Compilar en Visual Studio

1. Crear un proyecto vacío de C++ para Windows y elegir plataforma **x86**.
2. Agregar `AddTwo.asm` y habilitar MASM en Dependencias de compilación > Personalizaciones de compilación.
3. Configurar los directorios de inclusión y bibliotecas de la instalación local de Irvine32, así como el enlace de `Irvine32.lib`, según la configuración del curso.
4. Compilar y ejecutar en x86. El proyecto necesita Windows, MASM e Irvine32; no están incluidos aquí.
5. El directorio de trabajo de Visual Studio determina dónde se lee y guarda `inventario.bin`. Para usar el archivo de prueba, copiar `inventario-ejemplo.bin` a ese directorio con el nombre `inventario.bin` antes de ejecutar.

Si falta o es inválido el archivo, el programa informa del error y conserva el catálogo inicial integrado. El archivo de la versión anterior, que solo tenía 40 bytes de existencias, no es compatible; renómbralo o retíralo antes de usar esta versión.

## Uso

El menú registra, lista, busca por código, recibe mercancía, vende, muestra resumen, guarda y carga. El precio se escribe como `15`, `15.5` o `15.50` en MXN. Las operaciones de venta y entrada piden cantidad entre 1 y 100; además validan la existencia real y el límite. Las ventas desde cinco unidades aplican 2% de descuento, truncando fracciones de centavo. La opción de carga y la salida preguntan qué hacer si hay cambios sin guardar. Los ingresos pertenecen solo a la sesión y no se guardan.

Guardar reemplaza `inventario.bin` en el directorio de trabajo. Si una escritura falla, el programa informa del error y mantiene el indicador de cambios pendientes; se recomienda conservar una copia de respaldo del archivo anterior.

## Archivos

- `AddTwo.asm`: código fuente.
- `inventario-ejemplo.bin`: archivo de ejemplo con cuatro productos, formato INV1.
- `INFORME.md`: diseño, funcionamiento y decisiones.
- `PRUEBAS.md`: casos para ejecutar en Windows; no se presentan como resultados obtenidos.
