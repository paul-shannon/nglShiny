#----------------------------------------------------------------------------------------------------
nglShiny <- function(message, width = NULL, height = NULL, elementId = NULL)
{
  printf("--- ~/github/nglShiny/R/nglShiny ctor");


  x <- list(
    message = message
    )

  # create widget
  printf("creating widget with sizingPolicy");

  htmlwidgets::createWidget(
    name = 'nglShiny',
    x,
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

}
#----------------------------------------------------------------------------------------------------

