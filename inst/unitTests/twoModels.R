library(shiny)
library(shinyjs)
library(nglShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
jsCode <- "shinyjs.pageCol = function(params){$('body').css('background', params);}"
jsHide <- "shinyjs.hideDiv = function(divName){$('#nglShiny2').hide();}"

jsJustOne <- paste0("shinyjs.justOne = function(){ ",
                    "$('#nglShiny2').parent().hide(); ",
                    "$('#nglShiny1').parent().removeClass('col-sm-6').addClass('col-sm-12').resize(); ",
                    "$('#nglShiny1').parent().show(); ",
                    "}")

jsJustTwo <- paste0("shinyjs.justTwo = function(){ ",
                    "$('#nglShiny1').parent().hide(); ",
                    "$('#nglShiny2').parent().removeClass('col-sm-6').addClass('col-sm-12').resize(); ",
                    "$('#nglShiny2').parent().show(); ",
                    "}")

jsBoth <- paste0("shinyjs.both = function(){ ",
                    "$('#nglShiny1').parent().hide(); ",
                    "$('#nglShiny2').parent().hide(); ",
                    "$('#nglShiny1').parent().addClass('col-sm-6').resize(); ",
                    "$('#nglShiny2').parent().addClass('col-sm-6').resize(); ",
                    "$('#nglShiny1').parent().show(); ",
                    "$('#nglShiny2').parent().show(); ",
                    "}")

jsNone <- paste0("shinyjs.none = function(){ ",
                    "$('#nglShiny1').parent().hide(); ",
                    "$('#nglShiny2').parent().hide(); ",
                    "}")

# "$('#nglShiny2').parent().removeClass('col-sm-6'); ",

# $("#nglShiny1").parent().removeClass("col-sm-12").addClass("col-sm-6").resize()

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

  useShinyjs(),
  extendShinyjs(text=jsCode),
  extendShinyjs(text=jsHide),
  extendShinyjs(text=jsNone),
  extendShinyjs(text=jsJustOne),
  extendShinyjs(text=jsJustTwo),
  extendShinyjs(text=jsBoth),

  sidebarLayout(
     sidebarPanel(
        wellPanel(
          actionButton("fitButton_1", "Fit 1"),
          actionButton("fitButton_2", "Fit 2")
          ),
        radioButtons("vw", "Visible Windows:",
                     c("none", "one", "two", "both"),
                     selected="both"
                     ),
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

  observeEvent(input$vw, ignoreInit = TRUE, {
     newChoice <- input$vw
     printf("vw: %s", newChoice)
     if(newChoice == "one"){
        js$justOne()
        }
     if(newChoice == "two"){
        js$justTwo()
        }
     if(newChoice == "both"){
        js$both()
        }
     if(newChoice == "none"){
       js$none()
       }
     }) # vw

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
    ngl.0
    })

  output$nglShiny2 <- renderNglShiny({
    ngl.1
    #nglShiny(list(pdbID="4our"), options, 300, 300)
    })

} # server
#----------------------------------------------------------------------------------------------------
port <- 11112
browseURL(sprintf("http://localhost:%d", port))
runApp(shinyApp(ui=ui, server=server), port=port)


