
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library( shiny )
library( dplyr )

if( !file.exists( 'data' ) )
{
  dir.create( 'data' )
}
if( !file.exists( 'data/US-market' ) )
{
  # TODO download the other 2 files
  if( !file.exists( 'data/bids-dataset-1.zip' ) )
  {
    download.file( 'https://open-advertising-dataset.googlecode.com/files/bids-dataset-1.zip',
                   destfile='data/bids-dataset-1.zip', method='curl' )
  }
  unzip( 'data/bids-dataset-1.zip', exdir='data' )
}

df <- read.csv( 'data/US-market/keyword_stats_20120531_0148831.csv', na.strings='-' )
df$Estimated.Daily.Cost.... <-
  as.numeric( gsub( ',', '', df$Estimated.Daily.Cost.... ) )
df <-
  filter( df, !is.na( Global.Monthly.Searches ),
          !is.na( Local.Monthly.Searches ) )

shinyServer( function( input, output ) {
  data <- df[ , c( 'Estimated.Daily.Cost....', 'Local.Monthly.Searches' ) ]
  clusters <- reactive( {
    kmeans( data, input$clusters )
  } )
  output$plot <- renderPlot( {
    plot( x=data$Estimated.Daily.Cost...., y=log( data$Local.Monthly.Searches ),
          col=clusters()$cluster, pch = 20, cex = 3 )
    points( clusters()$centers, pch = 4, cex = 4, lwd = 4 )
  } )

} )
