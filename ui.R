
ui <- shinyUI( fluidPage(titlePanel(title="Link ratios",windowTitle = "Link ratios"),
                         sidebarPanel(
                           radioButtons(inputId="data", label="Please choose triangle:", 
                                        choices=x,selected="RAA_triangle"),
                           uiOutput("weights_0"),
                           numericInput("periods",label="Please insert number of future periods for the extrapolation and tail calculation:",value = 10, min=1),
                           actionButton("switchoff","Quit",icon("stop"),style="color: #fff; background-color: #FF0000"),
                         width=5 ),
                         sidebarPanel(
                           uiOutput("linkr_0"),
                           width=5
                         ),
                         mainPanel(
                           tabsetPanel(
                             tabPanel(title="Triangle",
                           div(DT::dataTableOutput('table1'),style = "font-size:80%")),
                           tabPanel(title="Plot",
                                    plotlyOutput("plot1",width="100%",height=500)
                                    ),
                           tabPanel(title="Results",
                                    DT::dataTableOutput('table2'),
                                    )
                           ),width=10
                            )
                             )
)