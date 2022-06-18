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
ngl.0 <- nglShiny(options=list(pdbID="1crn", htmlContainer="nglShiny1"), 300, 300, elementId="nglShiny1")
ngl.1 <- nglShiny(options=list(pdbID="4our", htmlContainer="nglShiny2"), 300, 300, elementId="nglShiny2")
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
        radioButtons("vw", "Visible Windows:",
                     c("none", "one", "two", "both"),
                     selected="none"
                     ),
        width=2,
        ),
     mainPanel(
        fluidRow(
            column(6,
              conditionalPanel(id="cp1", "(input.vw == 'one' || input.vw == 'both')", imageOutput("imageOne"))
              ),
            column(6,
              conditionalPanel(id="cp2", "(input.vw == 'two' || input.vw == 'both')",  imageOutput("imageTwo"))
              )
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

   output$imageOne <- renderImage({
    list(src = "~/github/nglShiny/inst/unitTests/images/4our-ligands.png",
         contentType = 'image/png',
         width = 300,
         height = 300,
         alt = "This is alternate text")
     }, deleteFile = FALSE)

   output$imageTwo <- renderImage({
    list(src = "~/github/nglShiny/inst/unitTests/images/GSM749704_ChIPseq-CTCF-chr19-bestFIMOmatch.png",
         contentType = 'image/png',
         width = 300,
         height = 300,
         alt = "This is alternate text")
     }, deleteFile = FALSE)


} # server
#----------------------------------------------------------------------------------------------------
port <- 11112
browseURL(sprintf("http://localhost:%d", port))
runApp(shinyApp(ui=ui, server=server), port=port)


