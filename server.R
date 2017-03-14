server <- function(input, output, session) 
{
  library("shiny")
  library("dplyr")
  library("plotly")
  library("RJDBC")
  library("knitr")
  library("DT")
  options(shiny.maxRequestSize = 3000*1024^2)
  # Driver <- JDBC("com.mysql.jdbc.Driver", classPath = "/Users/JorgeQuintana/IdeaProjects/Connect/mysql-connector-java-5.1.35-bin.jar", "")
  
  Connect <- eventReactive(
    input$connect,
    {
      Driver <- JDBC(input$driver, classPath = input$classpath, "")
      dbConnect(Driver, input$port, input$user, input$password)
    }
  )
  
  GetCSV_Data <- reactive(
    {
      inFile <- input$file
      if (is.null(inFile))
        return(NULL)
      read.delim(file = inFile$datapath, sep = input$separator, dec = input$decimal, header = input$header)
    }
  )
  
  GetJDBC_Data <- reactive(
    {
      if (is.null(input$query))
        return(NULL)
      dbGetQuery(Connect(), input$query)
    }
  )
  
  Get_Data <- reactive(
    {
      if (input$JDBC == TRUE)
      {
        GetJDBC_Data()
      }
      else
      {
        GetCSV_Data()
      }
    }
  )
  
  output$preview1 <- DT::renderDataTable(DT::datatable({head(GetJDBC_Data()[, 1:4], 5)}))
  output$preview2 <- DT::renderDataTable(DT::datatable({head(GetCSV_Data()[, 1:4], 6)}))
  
  Cross <- reactive(
    {
      v1 <- input$heat1
      v2 <- input$heat2
      table(Get_Data()[[v1]], Get_Data()[[v2]])
    }
  )
  
  Classifying_Variables <- reactive(
    {
      names(
        Get_Data()[, 
             which(
               as.logical(
                 sapply(names(Get_Data()),
                        function(x)
                        {
                          is.numeric(Get_Data()[[x]])
                        }
                 )
               )
             )
          ]
      )
    }
  )
  
  Categorical_Variables <- reactive(
    {
      setdiff(names(Get_Data()), Classifying_Variables())
    }
  )
  
  Missings <- reactive(
    {
      data.frame(NA_Prct =
                   sapply(names(Get_Data()),
                          function(x)
                          {
                            round(mean(is.na(Get_Data()[[x]])) * 100, 2)
                          }
                   )
      )
    } 
  )
  
  observe(
    {
      x <- Classifying_Variables()
      y <- Categorical_Variables()
      updateSelectInput(session = session, inputId = "variables", label = "X Variable", choices = x, selected = x[[3]])
      updateSelectInput(session = session, inputId = "heat1", label = "X Variable", choices = y, selected = y[[2]])
      updateSelectInput(session = session, inputId = "heat2", label = "Y Variable", choices = y, selected = y[[3]])
    }
  )
  
  Min <- reactive(
    {
      quantile(x = Get_Data()[[input$variables]], probs = input$percentile1, na.rm = TRUE)
    }
  )
  
  Max <- reactive(
    {
      quantile(x = Get_Data()[[input$variables]], probs = input$percentile2, na.rm = TRUE)
    }
  )
  
  x <- reactive(
    {
      as.numeric(
        ifelse(Get_Data()[[input$variables]] < Min(), Min(), 
               ifelse(Get_Data()[[input$variables]] > Max(), Max(), 
                      Get_Data()[[input$variables]]
               )
        )
      )
    } 
  )
  
  output$distPlot <- renderPlotly(
    {
      if (is.null(Get_Data()))
        return(NULL)
      fit <- density(x(), bw = input$bw, na.rm = TRUE)
      plot_ly(x = x()) %>%
        add_histogram(name = "Histogram", alpha = 0.7, histnorm = "probability") %>% 
        add_lines(x = fit$x, y = fit$y, fill = "tozeroy", yaxis = "y2", name = "Density") %>% 
        layout(yaxis2 = list(overlaying = "y", side = "right"))
    }
  )
  
  output$boxPlot <- renderPlotly(
    {
      if (is.null(Get_Data()))
        return(NULL)
      plot_ly(data.frame(x()), x = ~x(), type = "box", name = "BoxPlot") %>%
        layout(title = paste("BoxPlot of ", input$xcol2, sep = ""), xaxis = list(title = input$xcol2, zeroline = FALSE))
    }
  )
  
  output$miss <- DT::renderDataTable(DT::datatable({Missings()}))
  output$cross <- DT::renderDataTable(DT::datatable({Cross()}))
}