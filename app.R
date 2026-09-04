library(shiny)
library(httr)
# Sys.setenv(CURL_CA_BUNDLE = "/certificates/ca-bundle.crt")

ui <- fluidPage(
  "Hello, world!",
  textOutput("webservice_status")
)

server <- function(input, output, session) {
  res <- tryCatch(
    httr::GET("https://sid.ices.dk/services/odata3/StockListDWs3?$filter=ActiveYear%20eq%202015"),
    error = function(e) e
  )

  output$webservice_status <- renderText({
    if (inherits(res, "error") || inherits(res, "condition")) {
      paste("Webservice is DOWN:", conditionMessage(res))
    } else if (httr::status_code(res) == 200) {
      "Webservice is UP"
    } else {
      paste("Webservice returned status code:", httr::status_code(res))
    }
  })
}

shinyApp(ui, server)
