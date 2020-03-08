library(shiny)
library(nglShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
nglRepresentations = c('angle', 'axes', 'ball+stick', 'backbone', 'base', 'cartoon', 'contact',
                       'dihedral', 'distance', 'helixorient', 'licorice', 'hyperball', 'label',
                       'line', 'surface', 'point', 'ribbon', 'rocket', 'rope', 'spacefill', 'trace', 'unitcell',
                       'validation')
nglColorSchemes <- c('residueIndex', 'chainIndex', 'entityType', 'entityIndex')
#----------------------------------------------------------------------------------------------------
# 1RQK, 3I4D: Photosynthetic reaction center from rhodobacter sphaeroides 2.4.1
# crambin, 1crn: https://bmcbiophys.biomedcentral.com/articles/10.1186/s13628-014-0008-0
ui = shinyUI(fluidPage(

  tags$head(
    tags$style("#nglShiny{height:98vh !important;}"),
    tags$link(rel="icon", href="data:;base64,iVBORw0KGgo=")
    ),

  sidebarLayout(
     sidebarPanel(
        actionButton("fitButton", "Fit"),
        actionButton("clearRepresentationsButton", "Clear Representations"),
        selectInput("representationSelector", "", nglRepresentations),
        selectInput("colorSchemeSelector", "", nglColorSchemes),
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

  observeEvent(input$fitButton, {
     session$sendCustomMessage(type="fit", message=list())
     })

  observeEvent(input$clearRepresentationsButton, {
      session$sendCustomMessage(type="removeAllRepresentations", message=list())
      })

  observeEvent(input$representationSelector, {
     choice = input$representationSelector;
     printf("rep: %s", choice)
     session$sendCustomMessage(type="setRepresentation", message=list(choice))
     })

  observeEvent(input$colorSchemeSelector, {
     choice = input$colorSchemeSelector;
     printf("colorScheme: %s", choice)
     session$sendCustomMessage(type="setColorScheme", message=list(choice))
     })

  output$value <- renderPrint({ input$action})

  #options <- list(pdbID="1pcr")
  #options <- list(pdbID="3kvk")
  options <- list(pdbID="1crn")
  #options <- list(pdbID="1rqk")

  output$nglShiny <- renderNglShiny(
    nglShiny(options, 300, 300)
    )

} # server
#----------------------------------------------------------------------------------------------------
app <- shinyApp(ui = ui, server = server)

