# Aplicación Shiny: Visualización y Descarga de Datos

Esta es una aplicación Shiny diseñada para visualizar datos a través de gráficos interactivos y realizar análisis exploratorios. Puedes cargar tus propios conjuntos de datos en formato CSV y explorar diferentes visualizaciones.

## Requisitos

Asegúrate de tener instalados los siguientes paquetes de R antes de ejecutar la aplicación:

- `reshape2`
- `shiny`
- `writexl`
- `plotly`
- `shinythemes`

Puedes instalar estos paquetes ejecutando el siguiente código en tu consola de R:

```R
install.packages(c("reshape2", "shiny", "writexl", "plotly", "shinythemes"))
```

## Instrucciones de Uso

1. **Visualización**:

Selecciona las variables para los ejes X, Y y el color.
Ajusta el número de clústeres y activa la opción de mostrar la línea de tendencia.
Presiona el botón "Actualizar" para aplicar los cambios.

2. **Información**:

Carga un archivo CSV utilizando el botón de selección de archivo.
Visualiza la información básica del archivo en la pestaña "Información".

3. **Histograma**:

Selecciona una variable y ajusta el número de bins.
Activa la opción para mostrar la línea de densidad si es necesario.

4. **Boxplot**:

Selecciona las variables para el boxplot y elige una variable para agrupar.
Presiona el botón "Actualizar" para aplicar los cambios.

5. **Tabla Dinámica**:

Selecciona la variable para las filas y los valores de la tabla dinámica.
Elige la función de resumen (suma, máximo, mínimo, media, etc.).
La tabla dinámica se actualizará automáticamente.

## Ejecución
Para ejecutar la aplicación, carga el código en tu entorno de R y ejecuta shinyApp(ui, server).

## Contribuciones
¡Las contribuciones son bienvenidas! Si encuentras algún problema o tienes ideas para mejorar la aplicación, no dudes en abrir un problema o enviar una solicitud de extracción.
