library(shiny)
library(shinyjs)
library(dplyr)
library(DatabaseConnector)
library(gemini)
library(stringi)

shinyApp(
  ui <- (navbarPage(
    id='tabs',
    title = 'GEMINI',
    
    tabPanel('gemini'
             ,useShinyjs()
             ,tags$style("
               #rds_button {
               
               margin-top: 8rem;
               margin-bottom: 8rem;
               padding-top: 16rem;
               padding-right: 4rem;
               padding-bottom: 24rem;
               padding-left: 4rem;
               font-size: 200%;
               color : #FFFFFF;
                 background-color: #EC7063;
                 }

              #gemini_button {
              margin-top: 8rem;
              margin-bottom: 8rem;
              padding-top: 16rem;
              padding-right: 4rem;
              padding-bottom: 24rem;
              padding-left: 4rem;
              font-size: 200%;
              color : #FFFFFF;
                background-color: #5DADE2;
                
                }
              
              #back_button {
              padding-top: 1rem;
              padding-right: 2rem;
              padding-bottom: 1rem;
              padding-left: 2rem;
              color : #FFFFFF;
                background-color: #000000;
                }
              
              #back_button2 {
              padding-top: 1rem;
              padding-right: 2rem;
              padding-bottom: 1rem;
              padding-left: 2rem;
              color : #FFFFFF;
                background-color: #000000;
                }
              
              #settingDir {
              color : #000000;
                background-color: #FFFFFF;
                }
              
              #setwd_button {
              padding-top: 1rem;
              padding-right: 2rem;
              padding-bottom: 1rem;
              padding-left: 2rem;
              color : #000000;
                background-color: #FFFFFF;
                }
              
              #geminiAnalysis_button {
              margin-top: 2rem;
              padding-top: 1rem;
              padding-right: 1rem;
              padding-bottom: 1rem;
              padding-left: 1rem;
              color : #000000;
                background-color: #FFFFFF;
                }

             ")
             
             ,fluidRow(
               column(5,offset = 1
                      ,align='center'
                      ,actionButton('Create RDS File',inputId = 'rds_button',width = "100%")
               )
               ,column(5,align='center'
                       ,actionButton('GEMINI',inputId = 'gemini_button',width = "100%")
               )
               ,shinyjs::hidden(
                 div(id='rdsPage'
                     ,column(12,align='left'
                             ,actionButton('back_button','back')
                     )
                     ,fluidRow(
                       column(
                         id='databaseConnect_ui'
                         ,4
                         ,offset = 2
                         ,align='center'
                         ,uiOutput("sqltype")
                         ,textInput("server_ip","Server IP",placeholder = '127.0.0.1')
                         ,textInput("dw_db","DW database",'',placeholder = 'cdmName.schema')
                         ,textInput("usr","USER ID",'',placeholder = 'db id')
                         ,passwordInput("pw","PASSWORD",'',placeholder = 'db password')
                         ,actionButton('actionBtn','Create Rds')
                         ,downloadButton("dbConnection_btn", "Download")
                       )
                       ,column(
                         id='databaseConnect_log_ui'
                         ,4
                         ,align='center'
                         ,verbatimTextOutput(outputId = 'createRdsLog',placeholder = T)
                         
                       )
                     )
                     
                 )
               )
               ,shinyjs::hidden(
                 div(id='geminiPage',
                     column(12,align='left'
                            ,actionButton('back_button2','back')
                     )
                     
                     ,fluidRow(
                       column(4
                              ,offset = 1
                              ,tags$h3('Target File')))
                     
                     ,fluidRow(
                       column(12
                              ,align='left'
                              ,offset = 1
                              ,fileInput('defaultFile1'
                                         ,label = NULL
                                         ,multiple = F
                                         ,accept = c('.zip')
                              )
                       )
                     )
                     
                     ,fluidRow(
                       column(12
                              ,align='left'
                              ,offset = 1
                              ,fileInput('defaultFile2'
                                         ,label = NULL
                                         ,multiple = F
                                         ,accept = c('.zip')
                              )
                       )
                     )
                     
                     
                     ,fluidRow(
                       column(6
                              ,offset = 1
                              ,align='right'
                              ,actionButton('geminiSetAdd_button1','+')
                       )
                     )
                     ,fluidRow(
                       column(6
                              ,offset = 1
                              ,align='right'
                              ,actionButton('geminiAnalysis_button','Start')
                              
                       )
                     )
                     ,fluidRow(
                       column(6
                              ,offset = 1
                              ,align='right'
                              ,downloadButton("dbConnection_btn2", "Download")
                              
                       )
                     )

                     
                 )
               )
             )
    )
    
    
  )),
  
  server <- (function(input, output,session) {
    observe({
      query <<- parseQueryString(session$clientData$url_search)
      updateTextInput(session = session
                      ,inputId = 'server_ip'
                      ,value = query$server_ip
      )
      updateTextInput(session = session
                      ,inputId = 'dw_db'
                      ,value = query$dw_db
      )
    })

    ##Main Page UI###########################################################################################

    ## hide, show UI###########################################################################################
    observeEvent(input$rds_button,{
      shinyjs::hide('rds_button')
      shinyjs::hide('gemini_button')
    })
    observeEvent(input$gemini_button,{
      hide('rds_button')
      hide('gemini_button')
    })
    shinyjs::onclick("rds_button",
                     shinyjs::toggle(id = "rdsPage", anim = F))
    shinyjs::onclick("gemini_button",
                     shinyjs::toggle(id = "geminiPage", anim = F))
    observeEvent(input$back_button,{
      shinyjs::show('rds_button')
      shinyjs::show('gemini_button')
    })
    observeEvent(input$back_button2,{
      shinyjs::show('rds_button')
      shinyjs::show('gemini_button')
    })
    shinyjs::onclick("back_button",
                     shinyjs::toggle(id = "rdsPage", anim = F)
    )
    shinyjs::onclick("back_button2",
                     shinyjs::toggle(id = "geminiPage", anim = F)
    )


    ##Gemini Page UI###########################################################################################

    observeEvent(input$geminiSetAdd_button1, {
      insertUI(
        selector = "#geminiSetAdd_button1",
        where = "beforeBegin",
        ui = tags$div(
          fluidRow(class=paste0('filePathClass',input$geminiSetAdd_button1),
                   column(8,align='left'
                          ,fileInput(paste0("file",input$geminiSetAdd_button1)
                                     ,label = NULL
                                     ,multiple = F
                                     ,accept = c('.zip')
                          )
                   )
                   ,column(2
                           ,align='left'
                           ,actionButton(paste0('removeButton',input$geminiSetAdd_button1),'-')
                   )
          )
        )
      )

    })
    filePathValue <<- data.frame(stringsAsFactors = F)

    lapply(1:100, function(i) {
      observeEvent(input[[paste0('removeButton', i)]],{
        removeUI(selector = paste0("#geminiPage > div > .col-sm-6.col-sm-offset-1 > div > ",".row.filePathClass",i))
        if(i %in% filePathValue$num){
          filePathValue <<- filePathValue[-c(which(filePathValue$num == i)),]
        }
      })
    }
    )

    observeEvent(input$geminiAnalysis_button,{
      defalutFilePathValue <- c(input$defaultFile1$datapath,input$defaultFile2$datapath)
      name <<- c(input$defaultFile1$name,input$defaultFile2$name)
      analysisFilePath <<- c(defalutFilePathValue,filePathValue$path)
    })


    ##Gemini Logic


    ##Create RDS File UI
    output$createRdsLog <- renderText({
      'my Log!'
    })
    ##Create RDS File Logic



    #Choose DBMS
    output$sqltype <- renderUI({
      selectInput("sqltype", "Select DBMS",
                  choices = c(
                    "sql server" = "sql server"
                  )
      )
    })


    # connecting to the Database
    DBconnection <- reactive({
      connectionDetails <<- DatabaseConnector::createConnectionDetails(server = input$server_ip
                                                                       ,dbms = input$sqltype
                                                                       ,user = input$usr
                                                                       ,password = input$pw
                                                                       ,schema = input$dw_db)
      connection <<- DatabaseConnector::connect(connectionDetails = connectionDetails)
    })

    observeEvent(input$actionBtn,{
      DBcon <<- DBconnection()
      if(exists("connection")==TRUE){
        tmpdir <<- tempdir()
        setwd(tmpdir)
        withProgress(value = 0
                     ,message = 'creating Rds ...'
                     ,{
                       schema_name <<- stri_rand_strings(1, 10)
                       gemini::create_rds(connectionDetails,getwd(),schema_name)
                       incProgress(1,message = 'create Rds')
                     })
      }

    })

    observe({
      flag <- input$actionBtn[[1]]
      if(flag == 0){
        disable('dbConnection_btn')
      }
      else{
        enable('dbConnection_btn')
      }
    })

    observe({
      flag <- input$geminiAnalysis_button[[1]]
      if(flag == 0){
        disable('dbConnection_btn2')
      }
      else{
        enable('dbConnection_btn2')
      }
    })

    output$dbConnection_btn <- downloadHandler(
      filename = function() {
        paste(input$dw_db, "zip", sep=".")
      },
      content = function(fname) {
        setwd(file.path(tmpdir,'Gemini RDS',schema_name))
        fs <- './'
        zip(zipfile= fname, files=fs)
      },
      contentType = "application/zip"
    )

    output$dbConnection_btn2 <- downloadHandler(
      filename = function() {
        paste('Gemini', "html", sep=".")
      },
      content = function(fname) {
        setwd(tmpdir)
        file.copy('Gemini_md.html',fname)
      },
      contentType = "application/octet-stream"
    )

    observeEvent(input$geminiAnalysis_button,{
      tmpdir <<- tempdir()
      setwd(tmpdir)
      gemini::gemini(dbCount = length(analysisFilePath),name = name,analysisFilePath = analysisFilePath)

    })
    
  })
)
