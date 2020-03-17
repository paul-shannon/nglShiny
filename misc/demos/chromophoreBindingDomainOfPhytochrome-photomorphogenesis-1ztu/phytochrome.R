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

# Genome of the Extremely Radiation-Resistant Bacterium Deinococcus radiodurans Viewed from the Perspective of Comparative Genomics
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC99018/

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

# DrCBD: The first 321 residues of D. radiodurans bacteriophytochrome photo-receptor (DrBphP)
# constitute the chromophore-binding domain (DrCBD) and provide a stable, soluble and spectrally
# active fragment of phytochrome that is amenable to structural studies (Supplementary Fig. 1)
# 5. Although DrCBD readily assembles with biliverdin to generate a protein with a normal Pr
# spectrum4, its Pfr spectrum is substantially bleached, in accord with the need of a downstream PHY
# domain to stabilize the Pfr conformer4,6,7.
#
#
#

# As predicted by PFAM8 and sequence alignments 1,4,6, two well-known domain folds were easily
# identified in the DrCBD structure (Fig. 1). The PAS (Per/Arndt/Sim) domain encompasses residues 38
# to 128 with a five-stranded antiparallel b-sheet (b2, b1, b5, b4 and b3) flanked on one side by
# three a helices (a1–a3). Its concave front surface is possibly a protein–protein signalling
# interface, on the basis of comparisons with other PAS domains bound to protein
# partners. Following the PAS domain is a GAF (cGMP phosphodiesterase/adenyl cyclase/FhlA)
# domain, confirmed biochemically to form most of the bilin-binding pocket1,4,6. This domain
# contains a six-stranded anti-parallel b sheet (b9, b10, b11, b6, b7 and b8) sandwiched between a
# three-helix bundle (a4, a5, a8) and a6 and a7. As in most members of the phytochrome superfamily,
# the PAS domain of DrCBD is preceded by an  ~35-residue random-coil. Within the bacterial and fungal
# phytochrome clades, this extension contains the cysteine that covalently binds the A ring of the
# bilin chromophore4,11.

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
        actionButton("showChromaphoreButton", "Chromaphore"),
        actionButton("showChromaphoreAttachmentSiteButton", "Chromaphore Attachment"),
        actionButton("showCBDButton", "CBD"),
        actionButton("showCBD.PAS.Button", "CBD PAS Domain"),
        actionButton("showCBD.GAF.Button", "CBD GAF Domain"),
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

   observeEvent(input$showChromaphoreAttachmentSiteButton, {
     repString <- "ball+stick"
     selectionString <- "24"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString))
     })


   observeEvent(input$showChromaphoreButton, {
     repString <- "ball+stick"
     selectionString <- "not helix and not sheet and not turn and not water"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                    selection=selectionString))
     })

   observeEvent(input$showCBDButton, {
     repString <- "cartoon"
     selectionString <- "1-321"
     colorScheme = "residueIndex"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString,
                                                                  colorScheme=colorScheme))
     })


   observeEvent(input$showCBD.PAS.Button, {
     repString <- "cartoon"
     selectionString <- "38-128"
     colorScheme = "residueIndex"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString,
                                                                  colorScheme=colorScheme))
     })

  observeEvent(input$showCBD.GAF.Button, {
     repString <- "cartoon"
     selectionString <- "129-321"
     colorScheme = "residueIndex"
     session$sendCustomMessage(type="showSelection", message=list(representation=repString,
                                                                  selection=selectionString,
                                                                  colorScheme=colorScheme))
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

