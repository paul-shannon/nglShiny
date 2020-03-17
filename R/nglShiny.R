#----------------------------------------------------------------------------------------------------
nglShiny <- function(options, width = NULL, height = NULL, elementId = NULL)
{
  printf("--- ~/github/nglShiny/R/nglShiny ctor");

  stopifnot("pdbID" %in% names(options))

  htmlwidgets::createWidget(
    name = 'nglShiny',
    options,
    width = width,
    height = height,
    # sizingPolicy = htmlwidgets::sizingPolicy(padding=0, browser.fill=TRUE),
    package = 'nglShiny',
    elementId = elementId
    )

} # nglShiny constructor
#----------------------------------------------------------------------------------------------------
nglShinyOutput <- function(outputId, width = '100%', height = '600px')
{
  htmlwidgets::shinyWidgetOutput(outputId, 'nglShiny', width, height, package = 'nglShiny')
}
#----------------------------------------------------------------------------------------------------
renderNglShiny <- function(expr, env = parent.frame(), quoted = FALSE)
{
   if (!quoted){
      expr <- substitute(expr)
      } # force quoted

  htmlwidgets::shinyRenderWidget(expr, nglShinyOutput, env, quoted = TRUE)

} # renderNglShiny
#----------------------------------------------------------------------------------------------------
fit <- function(session)
{
   session$sendCustomMessage("fit", list())

} # fit
#----------------------------------------------------------------------------------------------------
setRepresentation <- function(session, rep)
{
   session$sendCustomMessage("setRepresentation", list(rep))

} # setRepresentation
#----------------------------------------------------------------------------------------------------
showSelection <- function(session, rep, selection, colorScheme="residueIndex")
{
    session$sendCustomMessage("showSelection",
                              list(representation=rep, selection=selection, colorScheme=colorScheme))

} # setRepresentation
#----------------------------------------------------------------------------------------------------
setColorScheme <- function(session, newColorScheme)
{
   session$sendCustomMessage("setRepresentation", list(newColorScheme))

} # setColorScheme
#----------------------------------------------------------------------------------------------------

