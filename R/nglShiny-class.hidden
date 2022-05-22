#' @import shiny
#' @importFrom htmlwidgets createWidget shinyWidgetOutput shinyRenderWidget
#' @import shinyjs
#' @importFrom methods new
#' @title nglShiny
#------------------------------------------------------------------------------------------------------------------------
#' @name nglShiny-class
#' @rdname nglShiny-class
#' @aliases nglShiny
#'
## @import methods

.nglShiny <- setClass ("nglShiny",
                       representation = representation(
                           pdbID="character",
                           htmlContainer="character",
                           widget="htmlwidget",
                           width="numeric",
                           height="numeric",
                           componentOptions="list",
                           state="environment",
                           quiet="logical"
                           )
                         )

#------------------------------------------------------------------------------------------------------------------------
printf <- function(...) print(noquote(sprintf(...)))
#------------------------------------------------------------------------------------------------------------------------
setGeneric('getPdbID', signature='obj', function(obj) standardGeneric('getPdbID'))
setGeneric('fit', signature='obj', function(obj) standardGeneric('fit'))
#------------------------------------------------------------------------------------------------------------------------
#' nglShiny
#'
#'
#' @export
#'
#' @param options
#' @param width integer  initial width of the widget.
#' @param height integer initial height of the widget.
#' @param elementId string the DOM id into which the widget is rendered, default NULL is best.
#'
#' @return a reference to an htmlwidget.
#'
nglShiny <- function(pdbID, componentOptions, htmlContainer, width = NULL, height = NULL, quiet=TRUE)
{
  printf("--- ~/github/nglShiny/R/nglShiny s$ ctor");

  widget <- htmlwidgets::createWidget(
    name = 'nglShiny',
    options,
    width = width,
    height = height,
    package = 'nglShiny',
    elementId = htmlContainer
    )

  state <- new.env(parent=emptenv())

  obj <- .nglShiny(pdbID=pdbID,
                   componentOptions=componentOptions,
                   htmlContainer=htmlContainer,
                   widget=widget,
                   width=width,
                   height=height,
                   componentOptions=componentOptions,
                   state=state,
                   quiet=quiet)

   obj

} # nglShiny constructor
#----------------------------------------------------------------------------------------------------
#' Standard shiny ui rendering construct
#'
#' @param outputId the name of the DOM element to create.
#' @param width integer  optional initial width of the widget.
#' @param height integer optional initial height of the widget.
#'
#' @return a reference to an htmlwidget
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   mainPanel(nglShinyOutput('nglShiny'), width=10)
#' }
#'
#' @aliases nglShinyOutput
#' @rdname nglShinyOutput
#'
#' @export

nglShinyOutput <- function(outputId, width = '100%', height = '600px')
{
  htmlwidgets::shinyWidgetOutput(outputId, 'nglShiny', width, height, package = 'nglShiny')
}
#----------------------------------------------------------------------------------------------------
#' More shiny plumbing -  an nglShiny wrapper for htmlwidget standard rendering operation
#'
#' @param expr an expression that generates an HTML widget.
#' @param env environment in which to evaluate expr.
#' @param quoted logical specifies whether expr is quoted ("useuful if you want to save an expression in a variable").
#'
#' @return not sure
#'
#' @aliases renderNglShiny
#' @rdname renderNglShiny
#'
#' @export
#'
renderNglShiny <- function(expr, env = parent.frame(), quoted = FALSE)
{
   if (!quoted){
      expr <- substitute(expr)
      } # force quoted

  htmlwidgets::shinyRenderWidget(expr, nglShinyOutput, env, quoted = TRUE)

} # renderNglShiny
#----------------------------------------------------------------------------------------------------
#' Set zoom and center so that the current model nicely fills the display.
#'
#' @param session a Shiny server session object.
#' @param htmlContainer a character string used to identify the nglShiny instance, the id of html element
#'
#' @examples
#' \dontrun{
#'   fit(session)
#'}
#'
#' @aliases fit
#' @rdname fit
#'
#'
#' @export
#'
fit <- function(session, htmlContainer)
{
   session$sendCustomMessage("fit", message=list(htmlContainer=htmlContainer))

} # fit
#----------------------------------------------------------------------------------------------------
setRepresentation <- function(session, rep)
{
   session$sendCustomMessage("setRepresentation", list(rep))

} # setRepresentation
#----------------------------------------------------------------------------------------------------
#' Using the specified representation and colorScheme, display the portion of selection
#'
#' @param session a Shiny server session object.
#' @param representation todo
#' @param selection todo
#' @param colorScheme todo
#' @param name character string, used for subsequent show/hide
#'
#' @examples
#' \dontrun{
#'   showSelection(session, "cartoon", "helix", "residueIndex")
#'}
#'
#' @aliases showSelection
#' @rdname showSelection
#'
#' @export
#'
showSelection <- function(session, representation, selection, name, colorScheme="residueIndex")
{
    session$sendCustomMessage("showSelection",
                              list(representation=representation,
                                   selection=selection,
                                   colorScheme=colorScheme,
                                   name=name))

} # showSelection
#----------------------------------------------------------------------------------------------------
#' hide or show the named selection
#'
#' @param session a Shiny server session object.
#' @param representationName a previously assigned character string
#'
#' @examples
#' \dontrun{
#'   setVisibility(session, "chromaphore", FALSE)
#'}
#'
#' @aliases setVisibility
#' @rdname setVisibility
#'
#' @export
#'
setVisibility <- function(session, representationName, newVisibilityState)
{
    session$sendCustomMessage("setVisibility",
                              list(representationName=representationName,
                                   newState=newVisibilityState))

} # setVisibility
#----------------------------------------------------------------------------------------------------
setColorScheme <- function(session, newColorScheme)
{
   session$sendCustomMessage("setRepresentation", list(newColorScheme))

} # setColorScheme
#----------------------------------------------------------------------------------------------------

