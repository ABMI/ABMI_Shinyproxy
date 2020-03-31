library(shiny)

shinyApp(
server = function(input, output) {  
    output$downloadData <- downloadHandler(
      filename = function() {
        paste("output", "zip", sep=".")
      },
      content = function(fname) {
        fs <- c()
        tmpdir <- tempdir()
        setwd(tempdir())
        for (i in c(1,2,3,4,5)) {
          path <- file.path(tmpdir,paste0("sample_", i, ".csv"))
          fs <- c(fs, path)
          write(i*2, path)
        }
        zip(zipfile=fname, files=fs)
      },
      contentType = "application/zip"
    )
  }
  ,ui = fluidPage(
    titlePanel(""),
    sidebarLayout(
      sidebarPanel(
        downloadButton("downloadData", label = "Download")
      ),
      mainPanel(h6("Sample download", align = "center"))
    )
  )
)