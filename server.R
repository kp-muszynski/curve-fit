
server <- shinyServer(function(input, output,session) {
    
    triangle<-reactive({
     get(input$data)
    })
    
    output$weights_0<-renderUI(sliderInput("weights",label="Please insert weights (periods to take) for the calculation of age-to-age factors:",value = nrow(triangle())-1 ,min=1, max=nrow(triangle())-1,step=1))
    
    # for triangle output
    output$table1<-DT::renderDataTable({datatable(cbind(Lp=c(1:nrow(triangle())),triangle()),options=list("pageLength"=20,scrollX=TRUE),rownames= TRUE) %>% formatStyle(0,target='row',"white-space"="nowrap") %>% formatRound(columns=c(2:ncol(triangle())+1),mark=" ",digits=0) })
    
    # link ratios
    vec<-reactive({
      ata_weight(triangle(),input$weights)
    })
    
    # displaying link ratios in a bit nicer form
    vec_print<-reactive({
      sapply(1:length(vec()),function(i){paste(i-1," - ",i," -----> ",round(vec()[i],5),sep="")})
    })
    
    output$linkr_0<-renderUI(checkboxGroupInput("linkr","Calculated age-to-age factors:",vec_print(),selected=vec_print()))
    
    # table with results
    table2_0<-reactive({link_plot(isolate(vec())[match(input$linkr,isolate(vec_print()))],isolate(vec()),input$periods)[[2]]})
    output$table2<-DT::renderDataTable(table2_0(),rownames=F)
    
    # plot
    plot1_0<-reactive({link_plot(isolate(vec())[match(input$linkr,isolate(vec_print()))],isolate(vec()),input$periods)[[1]]})
    output$plot1<-renderPlotly({plot1_0()})  
    
  observeEvent(input$switchoff,{
    stopApp() })
  
})


