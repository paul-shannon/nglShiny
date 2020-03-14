library(shiny)
library(nglShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
# display just the chromaphore (and water)
#   use ui button: clear representations
#   stage.getComponentsByName('1ztu').addRepresentation('ball+stick', {sele: 'not helix and not sheet and not turn and not water'})
# https://www.sciencedaily.com/releases/2018/10/181018105325.htm

# A light-sensing knot revealed by the structure of the chromophore-binding domain of phytochrome.
#   Wagner, J.R., Brunzelle, J.S., Forest, K.T., Vierstra, R.D.
#  (2005) Nature 438: 325-331


# Phytochromes are red/far-red light photoreceptors that direct photosensory responses across the bacterial, fungal and
# plant kingdoms. These include photosynthetic potential and pigmentation in bacteria as well as chloroplast development
# and photomorphogenesis in plants. Phytochromes consist of an amino-terminal region that covalently binds a single
# bilin chromophore, followed by a carboxy-terminal dimerization domain that often transmits the light signal through a
# histidine kinase relay. Here we describe the three-dimensional structure of the chromophore-binding domain of
# Deinococcus radiodurans phytochrome assembled with its chromophore biliverdin in the Pr ground state. Our model,
# refined to 2.5 A ̊ resolution, reaffirms Cys 24 as the chromophore attachment site, locates key amino acids that form a
# solvent-shielded bilin-binding pocket, and reveals an unusually formed deep trefoil knot that stabilizes this
# region. The structure provides the first three-dimensional glimpse into the photochromic behaviour of these
# photoreceptors and helps to explain the evolution of higher plant phytochromes from prokaryotic precursors.

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
        actionButton("showChromaphoreButton", "Chromaphore Only"),
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

  observeEvent(input$fitButton, {
     session$sendCustomMessage(type="fit", message=list())
     })

  observeEvent(input$domainChooser, {
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

  observeEvent(input$defaultViewButton, {
     session$sendCustomMessage(type="removeAllRepresentations", message=list())
     session$sendCustomMessage(type="setRepresentation", message=list(defaultRepresentation))
     session$sendCustomMessage(type="setColorScheme", message=list(defaultColorScheme))
     session$sendCustomMessage(type="fit", message=list())
     })


   observeEvent(input$showChromaphoreButton, {
     repString <- "ball+stick"
     selectionString <- "not helix and not sheet and not turn and not water"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                    selection=selectionString))
     })


  observeEvent(input$clearRepresentationsButton, {
      session$sendCustomMessage(type="removeAllRepresentations", message=list())
      #updateSelectInput(session, "representationSelector", label=NULL, choices=NULL,  selected=defaultRepresentation)
      #updateSelectInput(session, "colorSchemeSelector", label=NULL, choices=NULL,  selected=defaultColorScheme)
      })

  observeEvent(input$pdbSelector, {
     choice = input$pdbSelector
     printf("pdb: %s", choice)
     session$sendCustomMessage(type="setPDB", message=list(choice))
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
  options <- list(pdbID=defaultPdbID);
  #options <- list(pdbID="1rqk")

  output$nglShiny <- renderNglShiny(
    nglShiny(options, 300, 300)
    )

} # server
#----------------------------------------------------------------------------------------------------
app <- shinyApp(ui=ui, server=server)

