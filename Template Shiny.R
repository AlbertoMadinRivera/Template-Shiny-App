# Instala el paquete reshape2 si no está instalado
if (!require(reshape2)) {
  install.packages("reshape2")
}

# Instala el paquete Shiny si no está instalado
if (!require(shiny)) {
  install.packages("shiny")
}

# Instala el paquete writexl si no está instalado
if (!require(writexl)) {
  install.packages("writexl")
}

# Instala el paquete plotly si no está instalado
if (!require(plotly)) {
  install.packages("plotly")
}

# Instala el paquete shinythemes si no está instalado
if (!require(shinythemes)) {
  install.packages("shinythemes")
}

# Carga las librerías necesarias
library(shiny)
library(writexl)
library(ggplot2)
library(plotly)
library(shinythemes)
library(reshape2)

# Define la interfaz de usuario
ui <- navbarPage(
  "Visualización y Descarga de Datos",
  tabPanel("Visualización",
           sidebarLayout(
             sidebarPanel(
               selectInput("x_variable", "Selecciona la variable para el eje X:",
                           choices = NULL),
               selectInput("y_variable", "Selecciona la variable para el eje Y:",
                           choices = NULL),
               selectInput("color_variable", "Selecciona la variable para el color:",
                           choices = NULL),
               numericInput("num_clusters", "Número de clústeres:",
                            value = 3, min = 1, max = 10),
               actionButton("actualizar", "Actualizar"),
               checkboxInput("mostrar_tendencia", "Mostrar línea de tendencia", value = TRUE)
             ),
             mainPanel(
               plotlyOutput("scatterplot"),
               verbatimTextOutput("regression_summary"),  # Nuevo resumen de regresión
               tableOutput("table_visualization")  # Tabla de datos cargados
             )
           )
  ),
  tabPanel("Información",
           fileInput("file", "Seleccionar archivo CSV"),
           tableOutput("table_info")
  ),
  tabPanel("Histograma",
           sidebarLayout(
             sidebarPanel(
               selectInput("variable", "Selecciona una variable:",
                           choices = NULL),
               sliderInput("bins", "Número de bins:",
                           value = 30, min = 1, max = 100),
               actionButton("toggle_densidad", "Mostrar/Quitar Línea de Densidad"),
               checkboxInput("mostrar_densidad", "Mostrar línea de densidad", value = FALSE)
             ),
             mainPanel(
               plotlyOutput("histogram")
             )
           )
  ),
  tabPanel("Boxplot",
           sidebarLayout(
             sidebarPanel(
               selectInput("boxplot_variable", "Selecciona una variable:",
                           choices = NULL),
               selectInput("boxplot_group", "Selecciona una variable para agrupar:",
                           choices = NULL),
               actionButton("actualizar_boxplot", "Actualizar")
             ),
             mainPanel(
               plotlyOutput("boxplot")
             )
           )
  ),
  # "Tabla Dinámica"
  tabPanel("Tabla Dinámica",
           sidebarLayout(
             sidebarPanel(
               # Selecciona la variable para las filas de la tabla dinámica
               selectInput("rows_variable", "Selecciona la variable para las filas:",
                           choices = NULL),
               # Selecciona la variable para los valores de la tabla dinámica
               selectInput("values_variable", "Selecciona la variable para los valores:",
                           choices = NULL),
               # Selecciona la función de resumen (suma, máximo, mínimo, media, etc.)
               selectInput("summary_function", "Selecciona la función de resumen:",
                           choices = c("Suma" = "sum", "Máximo" = "max", "Mínimo" = "min", "Media" = "mean"))
             ),
             mainPanel(
               # Muestra la tabla dinámica
               dataTableOutput("pivot_table")
             )
           )
  ),
  theme = shinytheme("cerulean")  # Cambia el tema a cerulean
)

# Define la lógica del servidor
server <- function(input, output, session) {
  
  data <- reactive({
    req(input$file)
    df <- read.csv(input$file$datapath)
    return(df)
  })
  
  observe({
    updateSelectInput(session, "x_variable", choices = names(data()))
    updateSelectInput(session, "y_variable", choices = names(data()))
    updateSelectInput(session, "color_variable", choices = names(data()))
    updateSelectInput(session, "variable", choices = names(data()))
    updateSelectInput(session, "boxplot_variable", choices = names(data()))
    updateSelectInput(session, "boxplot_group", choices = names(data()))
    updateSelectInput(session, "rows_variable", choices = names(data()))
    updateSelectInput(session, "values_variable", choices = names(data()))
  })
  
  # Filtra el conjunto de datos según la especie seleccionada
  data_filtered <- reactive({
    subset(data(), Species == input$especie)
  })
  
  # Genera un scatterplot con ggplot2, el número de clústeres seleccionado y línea de tendencia de regresión
  output$scatterplot <- renderPlotly({
    set.seed(123)
    clusters <- kmeans(data()[, c(input$x_variable, input$y_variable)], input$num_clusters)
    
    p <- ggplot(data(), aes(x = !!sym(input$x_variable), y = !!sym(input$y_variable), color = !!sym(input$color_variable))) +
      geom_point() +
      labs(title = "Scatterplot",
           x = input$x_variable, y = input$y_variable) +
      theme_minimal()
    
    if (input$mostrar_tendencia) {
      p <- p + geom_smooth(method = "lm", se = FALSE, color = "#154360", linetype = 1, size = 0.6, alpha = 0.5)
    }
    
    ggplotly(p)
  })
  
  # Genera un histograma con ggplot2 y la variable seleccionada
  output$histogram <- renderPlotly({
    p <- ggplot(data(), aes(x = .data[[input$variable]])) +
      geom_histogram(bins = input$bins, fill = "#17A589", color = "black", alpha = 0.7) +
      theme_minimal()
    
    if (input$mostrar_densidad) {
      p <- p + geom_density(color = "#154360", fill = "#154360", alpha = 0.5)
    }
    
    ggplotly(p)
  })
  
  # Genera una tabla dinámica interactiva con los datos seleccionados
  output$pivot_table <- renderDataTable({
    df_pivot <- data()
    if (!is.null(df_pivot)) {
      # Crea la tabla dinámica con las opciones seleccionadas
      pivot_table <- dcast(df_pivot, 
                           get(input$rows_variable) ~ get(input$values_variable),
                           fun.aggregate = get(input$summary_function))
      
      # Muestra la tabla dinámica
      pivot_table
    }
  })
  
  # Nuevo resumen de regresión
  output$regression_summary <- renderPrint({
    if (input$mostrar_tendencia) {
      model <- lm(data = data(), formula = as.formula(paste(input$y_variable, "~", input$x_variable)))
      summary(model)
    }
  })
  
  # Genera un boxplot con ggplot2 y las variables seleccionadas
  output$boxplot <- renderPlotly({
    p <- ggplot(data(), aes(x = !!sym(input$boxplot_group), y = !!sym(input$boxplot_variable))) +
      geom_boxplot(fill = "#3498DB", color = "#154360", alpha = 0.7) +
      labs(title = "Boxplot",
           x = input$boxplot_group, y = input$boxplot_variable) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Actualiza la interfaz cuando se presiona el botón de actualizar
  observeEvent(input$actualizar, {
    updateSelectInput(session, "especie",
                      choices = unique(data()$Species))
  })
  
  # Botón para mostrar/ocultar línea de densidad
  observeEvent(input$toggle_densidad, {
    updateCheckboxInput(session, "mostrar_densidad", value = !input$mostrar_densidad)
  })
  
  # Tabla de datos cargados en la pestaña de visualización
  output$table_visualization <- renderTable({
    if (!is.null(input$file)) {
      df_visualization <- data()
      head(df_visualization)
    }
  })
  
  # Tabla de información del archivo cargado en la pestaña de información
  output$table_info <- renderTable({
    if (!is.null(input$file)) {
      df_info <- data()
      head(df_info)
    }
  })
  
}

# Crea la aplicación Shiny
shinyApp(ui, server)