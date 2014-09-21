library( shiny )
library( dplyr )

if( !file.exists( 'data' ) )
{
  dir.create( 'data' )
}
if( !file.exists( 'data/US-market' ) )
{
  # TODO download the other two files
  if( !file.exists( 'data/bids-dataset-1.zip' ) )
  {
    download.file( 'https://open-advertising-dataset.googlecode.com/files/bids-dataset-1.zip',
                   destfile='data/bids-dataset-1.zip', method='curl' )
    # TODO validate SHA sum
  }
  # TODO unzip the other two files
  unzip( 'data/bids-dataset-1.zip', exdir='data' )
}

# TODO read the other files
df <- read.csv( 'data/US-market/keyword_stats_20120531_0148831.csv', na.strings='-' )
# TODO use nicer column names
colnames( df ) <-
  c( 'keyword', 'global_monthly_searches', 'est_avg_cpc', 'est_ad_pos',
     'est_daily_clicks', 'est_daily_cost', 'local_monthly_searches' )
df$est_daily_cost <-
  as.numeric( gsub( ',', '', df$est_daily_cost ) )
# TODO parse and add date
df <-
  filter( df, !is.na( global_monthly_searches ),
          !is.na( local_monthly_searches ) )

shinyServer( function( input, output ) {
  data <- df[ , c( 'est_daily_cost', 'local_monthly_searches' ) ]
  clusters <- reactive( {
    kmeans( data, input$clusters )
  } )
  create_tooltip <- function( record )
  {
    if( is.null( record ) ) return( NULL )
    record$x
  }
  vis <- reactive( {
    # TODO sensible labels
    df %>%
      ggvis( x=~log( 1 + est_daily_cost ), y=~log( 1 + local_monthly_searches ) ) %>%
      layer_points( fill=~factor( clusters()$cluster ), size.hover := 200 ) %>%
      add_tooltip( create_tooltip, c( 'hover', 'click' ) )
  } )
  vis %>% bind_shiny( 'plot' )

} )