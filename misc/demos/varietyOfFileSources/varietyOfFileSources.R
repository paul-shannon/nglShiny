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
defaultPdbID <- "1ztu"
pdbIDs <- c(defaultPdbID,
            "1crn",  # crambin refined against 0.945-A x-ray diffraction data.
            "2UWS",  # photosynthetic reaction center from Rb. sphaeroides, pH 6.5, charge-separated state
            "1IZL")  # Crystal structure of oxygen-evolving photosystem II from Thermosynechococcus vulcanus at 3.7-A resolution
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  tags$head(
    tags$style("#nglShiny{height:90vh !important;}"),
    tags$link(rel="icon", href="data:;base64,iVBORw0KGgo=")
    ),

  sidebarLayout(
     sidebarPanel(
        actionButton("fitButton", "Fit"),
        actionButton("defaultViewButton", "Defaults"),
        actionButton("clearRepresentationsButton", "Clear Representations"),
        actionButton("toggleChromaphoreVisibilityButton", "Chromaphore"),
        actionButton("togglePASdomainVisibilityButton", "PAS"),
        actionButton("toggleGAFdomainVisibilityButton", "GAF"),
        actionButton("showChromaphoreAttachmentSiteButton", "Chromaphore Attachment"),
        actionButton("showCBDButton", "CBD"),
        selectInput("pdbSelector", "", pdbIDs, selected=defaultPdbID),
        selectInput("representationSelector", "", nglRepresentations, selected=defaultRepresentation),
        selectInput("colorSchemeSelector", "", nglColorSchemes, selected=defaultColorScheme),
        hr(),
        radioButtons("domainChooser", "Domain",
                     c("helix 1" = "helix001",
                       "helix 2" = "helix002",
                       "sheet 1" = "sheet001",
                       "sheet 2" = "sheet002")
                     ),
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

  observeEvent(input$fitButton, ignoreInit=TRUE, {
     fit(session)
     #session$sendCustomMessage(type="fit", message=list())
     })

  observeEvent(input$domainChooser, ignoreInit=TRUE, {
     chosenDomain = input$domainChooser
     printf("domains choice: %s", chosenDomain)
     residueRange <- switch(chosenDomain,
                            "helix001" = 7:19,
                            "helix002" = 23:30,
                            "sheet001" = 1:4,
                            "sheet002" = 32:35
                            )

     residue.string <- paste(residueRange, collapse=", ")
     printf("%s: %s", chosenDomain, residue.string)
     session$sendCustomMessage(type="select", message=list(residue.string))
       # 327 atoms, 46 residues
       # HELIX    1  H1 ILE A    7  PRO A   19  13/10 CONFORMATION RES 17,19       13
       # HELIX    2  H2 GLU A   23  THR A   30  1DISTORTED 3/10 AT RES 30           8
       # SHEET    1  S1 2 THR A   1  CYS A   4  0
       # SHEET    2  S1 2 CYS A  32  ILE A  35 -1
     })

  observeEvent(input$defaultViewButton, ignoreInit=TRUE, {
     session$sendCustomMessage(type="removeAllRepresentations", message=list())
     session$sendCustomMessage(type="setRepresentation", message=list(defaultRepresentation))
     session$sendCustomMessage(type="setColorScheme", message=list(defaultColorScheme))
     session$sendCustomMessage(type="fit", message=list())
     })


   #observeEvent(input$showChromaphoreButton, {
   #  repString <- "ball+stick"
   #  selectionString <- "not helix and not sheet and not turn and not water"
   #  printf("calling showSelection on nglShiny object")
   #  showSelection(session, repString, selectionString, name="chromaphore")
   #  #session$sendCustomMessage(type="showSelection", message=list(representation=repString,
   #  #                                                               selection=selectionString))
   #  })

   observeEvent(input$showChromaphoreAttachmentSiteButton, ignoreInit=TRUE, {
     repString <- "ball+stick"
     selectionString <- "24"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString,
                                                                  name="chromaphoreAttachment"))
     })

   observeEvent(input$toggleChromaphoreVisibilityButton, ignoreInit=TRUE, {
     newState <- !components$chromaphore$visible
     components$chromaphore$visible <<- newState
     setVisibility(session, "chromaphore", newState)
     })

   observeEvent(input$togglePASdomainVisibilityButton, ignoreInit=TRUE, {
     newState <- !components$pas$visible
     components$pas$visible <<- newState
     setVisibility(session, "pas", newState)
     })

   observeEvent(input$toggleGAFdomainVisibilityButton, ignoreInit=TRUE, {
     newState <- !components$gaf$visible
     components$gaf$visible <<- newState
     setVisibility(session, "gaf", newState)
     })

   observeEvent(input$showCBDButton, ignoreInit=TRUE, {
     repString <- "cartoon"
     selectionString <- "1-321"
     colorScheme = "residueIndex"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString,
                                                                  colorScheme=colorScheme,
                                                                  name="CBD"))
     })


   observeEvent(input$showCBD.PAS.Button, ignoreInit=TRUE, {
     repString <- "cartoon"
     selectionString <- "38-128"
     colorScheme = "residueIndex"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString,
                                                                  colorScheme=colorScheme,
                                                                  name="PAS"))
     })

  observeEvent(input$showCBD.GAF.Button, ignoreInit=TRUE, {
     repString <- "cartoon"
     selectionString <- "129-321"
     colorScheme = "residueIndex"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString,
                                                                  colorScheme=colorScheme,
                                                                  name="GAF"))
     })

  observeEvent(input$clearRepresentationsButton, ignoreInit=TRUE, {
      session$sendCustomMessage(type="removeAllRepresentations", message=list())
      #updateSelectInput(session, "representationSelector", label=NULL, choices=NULL,  selected=defaultRepresentation)
      #updateSelectInput(session, "colorSchemeSelector", label=NULL, choices=NULL,  selected=defaultColorScheme)
      })

  observeEvent(input$pdbSelector, ignoreInit=TRUE, {
     choice = input$pdbSelector
     printf("pdb: %s", choice)
     session$sendCustomMessage(type="setPDB", message=list(choice))
     updateSelectInput(session, "pdbSelector", label=NULL, choices=NULL,  selected=choice)
     })

  observeEvent(input$representationSelector, ignoreInit=TRUE, {
     choice = input$representationSelector;
     printf("rep: %s", choice)
     session$sendCustomMessage(type="setRepresentation", message=list(choice))
     updateSelectInput(session, "representationSelector", label=NULL, choices=NULL,  selected=choice)
     })

  observeEvent(input$colorSchemeSelector, ignoreInit=TRUE, {
     choice = input$colorSchemeSelector;
     printf("colorScheme: %s", choice)
     session$sendCustomMessage(type="setColorScheme", message=list(choice))
     updateSelectInput(session, "colorSchemeSelector", label=NULL, choices=NULL,  selected=choice)
     })

  output$value <- renderPrint({input$action})

  options <- list(pdbID=defaultPdbID) #, namedComponents=components)

  output$nglShiny <- renderNglShiny(
    nglShiny(options, 300, 300)
    )

} # server
#----------------------------------------------------------------------------------------------------
runApp(shinyApp(ui=ui, server=server), port=9002)


