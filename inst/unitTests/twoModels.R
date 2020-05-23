library(shiny)
library(nglShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
nglRepresentations = c('angle', 'axes', 'ball+stick', 'backbone', 'base', 'cartoon', 'contact',
                       'dihedral', 'distance', 'helixorient', 'licorice', 'hyperball', 'label',
                       'line', 'surface', 'point', 'ribbon', 'rocket', 'rope', 'spacefill', 'trace', 'unitcell',
                       'validation')
nglColorSchemes <- c('residueIndex', 'chainIndex', 'entityType', 'entityIndex')
defaultRepresentation <- "cartoon"
defaultColorScheme <- "residueIndex"
pdbIDs <- c("1crn",  # crambin refined against 0.945-A x-ray diffraction data.
            "2UWS",  # photosynthetic reaction center from Rb. sphaeroides, pH 6.5, charge-separated state
            "1IZL")  # Crystal structure of oxygen-evolving photosystem II from Thermosynechococcus vulcanus at 3.7-A resolution
defaultPdbID <- "1crn"
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
        actionButton("fitButton_1", "Fit 1"),
        actionButton("fitButton_2", "Fit 2"),
        width=2
        ),
     mainPanel(
        fluidRow(
          column(6,nglShinyOutput('nglShiny1')),
          column(6,nglShinyOutput('nglShiny2'))
          ),
        width=10
        )
     ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session) {

  observeEvent(input$fitButton_1, {
     fit(session, htmlContainer="nglShiny1")
     })

  observeEvent(input$fitButton_2, {
     fit(session, htmlContainer="nglShiny2")
     })

  observeEvent(input$defaultViewButton, {
     session$sendCustomMessage(type="removeAllRepresentations", message=list())
     session$sendCustomMessage(type="setRepresentation", message=list(defaultRepresentation))
     session$sendCustomMessage(type="setColorScheme", message=list(defaultColorScheme))
     session$sendCustomMessage(type="fit", message=list())
     })

  observeEvent(input$clearRepresentationsButton, {
      session$sendCustomMessage(type="removeAllRepresentations", message=list())
      #updateSelectInput(session, "representationSelector", label=NULL, choices=NULL,  selected=defaultRepresentation)
      #updateSelectInput(session, "colorSchemeSelector", label=NULL, choices=NULL,  selected=defaultColorScheme)
      })

  observeEvent(input$pdbSelector, {
     choice = input$pdbSelector
     printf("pdb: %s", choice)
     # session$sendCustomMessage(type="setPDB", message=list(choice))
     updateSelectInput(session, "pdbSelector", label=NULL, choices=NULL,  selected=choice)
     })

  observeEvent(input$representationSelector, {
     choice = input$representationSelector;
     printf("rep: %s", choice)
     session$sendCustomMessage(type="setRepresentation", message=list(choice))
     updateSelectInput(session, "representationSelector", label=NULL, choices=NULL,  selected=choice)
     })

  observeEvent(input$colorSchemeSelector, {
     choice = input$colorSchemeSelector;
     printf("colorScheme: %s", choice)
     session$sendCustomMessage(type="setColorScheme", message=list(choice))
     updateSelectInput(session, "colorSchemeSelector", label=NULL, choices=NULL,  selected=choice)
     })

  output$value <- renderPrint({ input$action})

  #options <- list(pdbID="1pcr")
  #options <- list(pdbID="3kvk")
  #options <- list(pdbID="1rqk")

  output$nglShiny1 <- renderNglShiny({
    #options <- list(pdbID="1crn", htmlContainer="nglShiny1")
    ngl0 = nglShiny(options=list(pdbID="1crn", htmlContainer="nglShiny1"), 300, 300, elementId="nglShiny1")
    print("--- just created ngl0")
    print(ngl0)
    })

  output$nglShiny2 <- renderNglShiny({
    ngl1 = nglShiny(options=list(pdbID="4our", htmlContainer="nglShiny2"), 300, 300, elementId="nglShiny2")
    print("--- just created ngl1")
    print(ngl1)
    #nglShiny(list(pdbID="4our"), options, 300, 300)
    })

} # server
#----------------------------------------------------------------------------------------------------
port <- 11112
browseURL(sprintf("http://localhost:%d", port))
runApp(shinyApp(ui=ui, server=server), port=port)


