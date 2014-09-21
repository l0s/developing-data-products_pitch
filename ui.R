library( shiny )
library( ggvis )

shinyUI( fluidPage(

  # TODO documentation
  titlePanel( 'Keyword Bidding Data '),

  sidebarLayout(
    sidebarPanel(
      sliderInput( 'clusters',
                   'Number of clusters:',
                   min = 1,
                   max = 16,
                   value = 4 )
    ),

    mainPanel(
      #plotOutput( 'plot' )
      ggvisOutput( 'plot' )
    )
  )
) )