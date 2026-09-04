library(shiny)
library(httr)
library(icesSD)
# Sys.setenv(CURL_CA_BUNDLE = "/certificates/ca-bundle.crt")

ui <- fluidPage(
  "Hello, world!",
  textOutput("webservice_status"),
  textOutput("icessd_status")
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

  sd_res <- tryCatch(
    icesSD::getSD(year = 2025),
    error = function(e) e
  )

  output$icessd_status <- renderText({
    if (inherits(sd_res, "error") || inherits(sd_res, "condition")) {
      paste("icesSD::getSD is DOWN:", conditionMessage(sd_res))
    } else if (is.data.frame(sd_res) && nrow(sd_res) > 0) {
      paste("icesSD::getSD is UP:", nrow(sd_res), "rows returned")
    } else {
      "icesSD::getSD returned no data"
    }
  })
}

shinyApp(ui, server)
