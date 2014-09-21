library( shiny )
library( ggvis )

shinyUI( fluidPage(

  titlePanel( 'Keyword Bidding Data Clustering'),

  sidebarLayout(
    sidebarPanel(
      sliderInput( 'clusters',
                   'Number of clusters:',
                   min = 1,
                   max = 16,
                   value = 4 )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel( 'Plot', ggvisOutput( 'plot' ) ),
        tabPanel( 'Documentation',
          p( 'This application explores the ',
             a( 'Open Advertising Dataset',
                href='https://code.google.com/p/open-advertising-dataset/',
                target='_blank' ),
             ' . It performs cluster analysis of search engine advertising ',
             'keyword bidding data. Each point on the plot represents a group ',
             'of keywords on which an advertiser may bid. The horizontal axis ',
             'shows the estimated daily cost of advertising for those search ',
             'terms on a log scale. The vertical axis shows the number of ',
             'monthly searches for those search terms on a log scale.' ),
          p( 'The bid terms are clustered using the K-Means clustering ',
             'algorithm. The clustering is performed on the values prior to ',
             'normalising them on a log scale. The points are coloured ',
             'according to the cluster to which they belong. Use the slider',
             'on the side panel to control the number of clusters.' ),
          p( 'Although normalising the axes on log scales makes it easier to ',
             'view the data, it obscures the actual values. Hover over or ',
             'click on individual points to see the actual cost and search ',
             'counts as well as the keywords associated with those values.' )
        )
      )
    )
  )
) )