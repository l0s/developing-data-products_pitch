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
df$l_est_daily_cost <- log( df$est_daily_cost + 1 )
df$l_local_monthly_searches <- log( df$local_monthly_searches + 1 )

shinyServer( function( input, output ) {
  data <- df[ , c( 'est_daily_cost', 'local_monthly_searches' ) ]
  clusters <- reactive( {
    kmeans( data, input$clusters )
  } )
  create_tooltip <- function( record )
  {
    if( is.null( record ) ) return( NULL )
    candidates <-
      filter( df,
              abs( df$l_est_daily_cost - record$l_est_daily_cost ) < 0.000001,
              abs( df$l_local_monthly_searches - record$l_local_monthly_searches ) < 0.000001 )
    if( dim( candidates )[ 1 ] <= 0 ) return( NULL )
    row <- candidates[ 1, ]
    paste0( '<strong>', row$keyword, '</strong><br />',
            'Monthly searches: ',
            format( row$local_monthly_searches, big.mark=',',
                    scientific=FALSE ), '<br />',
            'Estimated Daily Cost: ',
            format( row$est_daily_cost, big.mark=',', scientific=FALSE ),
            ' GBP' )
  }
  vis <- reactive( {
    df %>%
      ggvis( x=~l_est_daily_cost, y=~l_local_monthly_searches ) %>%
      add_axis( 'x', title='Estimated daily cost (log scale of GBP)' ) %>%
      add_axis( 'y', title='Local monthly searches (log scale)' ) %>%
      layer_points( fill=~factor( clusters()$cluster ), size.hover := 200 ) %>%
      add_legend( title='Clusters', scales='fill' ) %>%
      add_tooltip( create_tooltip, c( 'hover', 'click' ) )
  } )
  vis %>% bind_shiny( 'plot' )

} )