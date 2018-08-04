#----------------------------------------------------------------------------------------------------
nglShiny <- function(message, width = NULL, height = NULL, elementId = NULL)
{
  printf("--- ~/github/nglShiny/R/nglShiny ctor");
  x <- list(
    message = message
    )

  # create widget
  htmlwidgets::createWidget(
    name = 'nglShiny',
    x,
    width = width,
    height = height,
    package = 'nglShiny',
    elementId = elementId
    )

} # nglShiny constructor
#----------------------------------------------------------------------------------------------------
nglShinyOutput <- function(outputId, width = '100%', height = '400px')
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

}
#----------------------------------------------------------------------------------------------------

