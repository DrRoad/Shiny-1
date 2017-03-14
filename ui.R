ui <- fluidPage(theme = "bootstrap.css",
                titlePanel(title = "Outlayers Detection and Imputation", windowTitle = "Outlayers Detection and Imputation"),
                sidebarLayout(
                  sidebarPanel(
                    navbarPage(
                      tabPanel(title = " "),
                      tabPanel(title = "Login via JDBC",
                               br(),
                               fluidRow(
                                 column(4, offset = 1, checkboxInput(inputId =  "JDBC", label = "Via JDBC", value = TRUE)),
                                 column(5, offset = 1, checkboxInput(inputId = "CSV", label = "Via CSV", value = FALSE))
                               ),
                               fluidRow(
                                 column(5, textInput(inputId = "user", label = "User", value = "root")),
                                 column(6, offset = 1, passwordInput(inputId = "password", label = "Password:"))
                               ),
                               fluidRow(
                                 column(5, textInput(inputId = "driver", label = "Driver:", value = "com.mysql.jdbc.Driver")),
                                 column(6, offset = 1, textInput(inputId = "classpath", label = "ClassPath:", 
                                                     value = "/Users/JorgeQuintana/IdeaProjects/Connect/mysql-connector-java-5.1.35-bin.jar"))
                               ),
                               fluidRow(
                                 column(5, textInput(inputId = "port", label = "Port:", value = "jdbc:mysql://localhost:3306/WTI"))
                               ),
                               fluidRow(
                                 column(4, actionButton(inputId = "connect", label = "Connect")),
                                 column(5, offset = 2, actionButton(inputId = "close", label = "Disconnect"))
                               ),
                               hr(),
                               textAreaInput(inputId = "query", label = "Query", value = "SELECT * FROM PRUEBA.DATOS_PRUEBA", width = "450px", height = "50px"),
                               hr(),
                               h4("Data Preview"),
                               DT::dataTableOutput("preview1")
                      ),
                    tabPanel(title = "Load a CSV file",
                             br(),
                             fluidRow(
                               column(4, offset = 1, checkboxInput("JDBC", "Via JDBC", FALSE)),
                               column(5, offset = 1, checkboxInput("CSV", "Via CSV", TRUE))
                             ),
                             fileInput(inputId = "file", label = "Choose CSV File", accept = c("text/csv", "text/comma-separated-values,text/plain",".csv")),
                             checkboxInput("header", "Header", TRUE),
                             fluidRow(
                               column(5, selectInput(inputId = "separator", label = "Separator", c(",", ";", "\t", "|"))),
                               column(6, selectInput(inputId = "decimal", label = "Decimal", c(",", ".")))
                             ),
                             hr(),
                             h4("Data Preview"),
                             DT::dataTableOutput("preview2")
                    ),
                    tabPanel(title = "Analyze!",
                             h4("Choose one variable to analyze outlayers"),
                             selectInput(inputId = "variables", label = "X Variable", c("Item A", "Item B", "Item C")),
                             sliderInput(inputId = "percentile1", label = "Min Percentile", min = 0, max = 0.1, value = 0.05),
                             sliderInput(inputId = "percentile2", label = "Max Percentile", min = 0.9, max = 1, value = 0.95),
                             sliderInput(inputId = "bw", label = "Band Width", min = 0.1, max = 2, value = 0.5),
                             hr(),
                             h4("Choose three variables to create Cross Table"),
                             selectInput(inputId = "heat1", label = "X Variable", c("Item A", "Item B", "Item C")),
                             selectInput(inputId = "heat2", label = "Y Variable", c("Item A", "Item B", "Item C"))
                    )
                  )
                ),
                mainPanel(
                  navbarPage(
                    tabPanel(title = " "),
                    tabPanel(title = "Outlayers",
                             plotlyOutput(outputId = "distPlot"),
                             plotlyOutput(outputId = "boxPlot")),
                    tabPanel(title = "Missings", DT::dataTableOutput(outputId = "miss")),
                    tabPanel(title = "Cross Tables", DT::dataTableOutput(outputId = "cross"))
                  )
                )
)
)