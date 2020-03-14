library(shiny)
library(nglShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
# https://www.sciencedaily.com/releases/2018/10/181018105325.htm

# Whenever you see green color out in nature, you are likely to look
# at chlorophyll. This is the pigment used by all plants to do
# photosynthesis. There are two versions, chlorophyll a and
# chlorophyll b. These are structurally very similar to one another
# but have different colors, blue-green and yellowish green,
# respectively. Both pigments fulfill different jobs during
# photosynthesis and therefore are bound very selectively by the
# proteins of the photosynthesis apparatus in plants. How these plant
# proteins recognize the two chlorophylls, despite their small
# structural differences, and thus are able to bind them selectively,
# has been largely unknown so far.

# Researchers of Johannes Gutenberg University Mainz (JGU), together
# with two Japanese colleagues, have partially solved this riddle. The
# team of Professor Harald Paulsen at the JGU Faculty of Biology used
# the so-called Water-soluble Chlorophyll Protein of cauliflower and
# Virginia pepperweed as a model protein. This protein possesses only
# a single chlorophyll binding site per protein molecule and is able
# to bind both chlorophyll versions. Upon variation of the amino acids
# near the chlorophyll binding site, the preference of the protein for
# one chlorophyll or the other changed. In one case, exchanging a
# single amino acid altered the relative binding strengths by a factor
# of 40. "This does not explain everything about Chl a/b binding
# specificity in the photosynthetic apparatus," said Paulsen, "but our
# results yield useful hypotheses that now can be tested with
# photosynthesis proteins. In the longer run, this may help to improve
# light harvesting in new photovoltaic devices or in artificial
# photosynthesis."

# Water-Soluble Chlorophyll Protein (WSCP) Stably Binds Two or Four Chlorophylls.

#----------------------------------------------------------------------------------------------------
nglRepresentations = c('angle', 'axes', 'ball+stick', 'backbone', 'base', 'cartoon', 'contact',
                       'dihedral', 'distance', 'helixorient', 'licorice', 'hyperball', 'label',
                       'line', 'surface', 'point', 'ribbon', 'rocket', 'rope', 'spacefill', 'trace', 'unitcell',
                       'validation')
nglColorSchemes <- c('residueIndex', 'chainIndex', 'entityType', 'entityIndex')
defaultRepresentation <- "cartoon"
defaultColorScheme <- "residueIndex"
defaultPdbID <- "6GIW"
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

