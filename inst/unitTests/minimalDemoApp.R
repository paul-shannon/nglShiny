library(shiny)
library(nglShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  sidebarLayout(
     sidebarPanel(
        actionButton("randomRoiButton", "Random roi"),
        hr(),
        width=2
        ),
     mainPanel(
        nglShinyOutput('nglShiny'),
        width=10
        )
     ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session) {

   observeEvent(input$randomRoiButton, {
      input$randomRoiButton
      tss <- 88883200
      shoulder <- as.integer(runif(1, 0, 1000))
      roi.string <- sprintf("chr5:%d-%d", tss - shoulder, tss + shoulder)
      session$sendCustomMessage(type="showGenomicRegion", message=(list(roi=roi.string)))
      })

  output$value <- renderPrint({ input$action })
  output$nglShiny <- renderNglShiny(
    nglShiny("hello shinyApp")
    )

} # server
#----------------------------------------------------------------------------------------------------
# shinyApp(ui = ui, server = server)
