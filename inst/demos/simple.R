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
pdbIDs <- c("http://localhost:60050/pdb/1crn.pdb",
            "http://localhost:60050/pdb/1s5l.pdb")
defaultPdbID <- pdbIDs[2]
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
        actionButton("defaultViewButton", "Defaults"),
        actionButton("clearRepresentationsButton", "Clear Representations"),
        selectInput("pdbSelector", "", pdbIDs, selected=defaultPdbID),
        selectInput("representationSelector", "", nglRepresentations, selected=defaultRepresentation),
        selectInput("colorSchemeSelector", "", nglColorSchemes, selected=defaultColorScheme),
        hr(),
        width=3
        ),
     mainPanel(
        nglShinyOutput('nglShiny'),
        width=9
        )
     ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session) {

  observeEvent(input$fitButton, ignoreInit=TRUE, {
     session$sendCustomMessage(type="fit", message=list())
     })

  observeEvent(input$defaultViewButton, ignoreInit=TRUE,  {
     session$sendCustomMessage(type="removeAllRepresentations", message=list())
     session$sendCustomMessage(type="setRepresentation", message=list(defaultRepresentation))
     session$sendCustomMessage(type="setColorScheme", message=list(defaultColorScheme))
     session$sendCustomMessage(type="fit", message=list())
     })

  observeEvent(input$clearRepresentationsButton, ignoreInit=TRUE, {
      session$sendCustomMessage(type="removeAllRepresentations", message=list())
      #updateSelectInput(session, "representationSelector", label=NULL, choices=NULL,  selected=defaultRepresentation)
      #updateSelectInput(session, "colorSchemeSelector", label=NULL, choices=NULL,  selected=defaultColorScheme)
      })

  observeEvent(input$pdbSelector, ignoreInit=TRUE, {
     choice = input$pdbSelector
     printf("pdb: %s", choice)
     session$sendCustomMessage(type="setPDB", message=list(pdbID=choice))
     updateSelectInput(session, "pdbSelector", label=NULL, choices=NULL,  selected=choice)
     })

  observeEvent(input$representationSelector, ignoreInit=TRUE,  {
     choice = input$representationSelector;
     printf("rep: %s", choice)
     session$sendCustomMessage(type="setRepresentation", message=list(choice))
     updateSelectInput(session, "representationSelector", label=NULL, choices=NULL,  selected=choice)
     })

  observeEvent(input$colorSchemeSelector, ignoreInit=TRUE,  {
     choice = input$colorSchemeSelector;
     printf("colorScheme: %s", choice)
     session$sendCustomMessage(type="setColorScheme", message=list(choice))
     updateSelectInput(session, "colorSchemeSelector", label=NULL, choices=NULL,  selected=choice)
     })

  output$value <- renderPrint({ input$action})

  options <- list(pdbID="http://localhost:60050/pdb/1crn.pdb", htmlContainer="nglShiny")

  output$nglShiny <- renderNglShiny(
    nglShiny(options, 300, 300)
    )

} # server
#----------------------------------------------------------------------------------------------------
port <- sample(10000:15000, size=1)
browseURL(sprintf("http://localhost:%d", port))
runApp(shinyApp(ui=ui, server=server), port=port)


