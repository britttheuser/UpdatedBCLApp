library(shiny)
library(tidyverse)
library(shinythemes)
library(stringr)
bcl <- read_csv("bcl-data.csv")
options(shiny.autoreload = TRUE)



#only outputs html, so R code does not work in here
ui <- fluidPage(
  titlePanel("Updated BCL App"),
  img(src='logo.jpeg', align = "right"),
  strong("This is an app that helps you explore the alcohol content of beverages at BC Liquor stores
  between two price points"),
  br(),
  "You can select a theme in the floating theme selector window. This window can be dragged elsewhere.",
  br(),
  br(),
  sidebarLayout(
    sidebarPanel("You can input here: ",
                 sliderInput("my_slider", "Select a price range", min = 0, max = 200, step = 10, value = c(10, 130), ticks = TRUE),
    radioButtons("my_radio", "Select beverage type",
                 choices = unique(bcl$Type)),
    numericInput("my_num_input", "Select a sweetness level", value = 0, step = 1, min = 0, max = 10),
    selectInput("my_select", "Sort result by price", choices = c("Not Sorted", "Ascending", "Descending")),
    shinythemes::themeSelector(),
    ),

    mainPanel("Your result will be displayed here: ",
              br(),
              tabsetPanel(
                tabPanel("Plot",
                       plotOutput("my_plot")), #put the plot here, leave a spot for my plot,
                tabPanel("Table",
                       textOutput("my_text"),
                       br(),
                       tableOutput("my_table")),
                tabPanel("Brand Lookup",
                         textInput("user_text", label = h3("You can look up a specific brand: "), value = "Enter text..."),
                         hr(),
                         tableOutput("user_table"))
              )
  )
  )



)


server <- function(input, output) {

  filtered <- reactive({ #get rid of repeated code but cannot put raw code in server fx, use reactive
    bcl %>%
      filter(Price < input$my_slider[2],
             Price > input$my_slider[1],
             Type == input$my_radio,
             Sweetness == input$my_num_input)
  })

  filtered_rows <- reactive (filtered()%>%summarise(n = n()))

  filtered_ascending <- reactive(filtered() %>% arrange(Price))

  filtered_descending <- reactive(filtered() %>% arrange(desc(Price)))

  #input$my_slider #a vector of length 2 of the min and max the user selected
  output$my_plot<-renderPlot(
    filtered() %>%
      ggplot(aes(Alcohol_Content)) +
      geom_histogram()
  ) #specify output list to include the same name as the spot holder

  output$my_text<- renderText ({
    paste("We found ", filtered_rows()[[1]], "results for you")
  })

  output$my_table<-renderTable(
    if (input$my_select == "Ascending") {
      filtered_ascending()
    }
    else if (input$my_select == "Descending") {
      filtered_descending()
    }
    else {
      filtered()
    }

  )

  #https://www.statology.org/filter-rows-that-contain-string-dplyr/ reference
  #also see https://sebastiansauer.github.io/dplyr_filter/ although have not figured out how to combine regex with input$user_text
  output$user_table<-renderTable(
    bcl %>%
      #filter(Name == input$user_text))
      filter(grepl(input$user_text, Name)))


}

#output is like a list, the element can be anything

# Run the application
shinyApp(ui = ui, server = server)
