library(shiny)
ui <- fluidPage()
server <- function(input, output) {}
shinyApp(ui = ui, server = server)

#It is very important that the name of the file is app.R, otherwise it would not be recognized as a Shiny app.
#You should not have any R code after the shinyApp(ui = ui, server = server) line.
#       That line needs to be the last line in your file.
#It is good practice to place this app in its own folder, and not in a folder that already has other R scripts or files,
#       unless those other files are used by your app.
