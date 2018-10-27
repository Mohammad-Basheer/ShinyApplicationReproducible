#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

shinyUI(fluidPage(

  # navigation bar
  navbarPage("2D KDE",
       tabPanel("Quakes map",
             h1("Locations of Earthquakes in Fiji"),   
             
    sidebarLayout(
          
          sidebarPanel(
                
                sliderInput("nLevels", "Number of density levels:",  
                            min = 5, max = 20, step = 1, value = 15),
                checkboxInput("isWeighted", "Weighted by magnitude", FALSE),
                hr(),
                div("Size and direction of probe bandwidth:"),   
                sliderInput("rx", "Radius along x [log(rx)]:",  
                            min = -1, max = 1, step = 2 / 20,
                            value = 0.3),
                sliderInput("ry", "Radius along y [log(ry)]:",  
                            min = -1, max = 1, step = 2 / 20,
                            value = -0.1),
                sliderInput("teta", "Probe rotation angle [teta]:",  
                            min = -90, max = 90, step = 180 / 4 /6,
                            value = 15, post="°"),
                tags$div(align="center", 
                         plotOutput("ellipse", width = 150, height = 150),
                         h5(strong("H"), "matrix"),
                         pre(textOutput("hmatrix") )
                         
                )
          ),
          
          # Show a plot
          mainPanel(
                
                leaflet::leafletOutput("quakesMap", width = "100%", height = 800),
                
                p("2D smoothing of Kernel Density Estimation (KDE)."),
                p("You can manually  select size and direction of bandwidth probe. 
                  Check its effect on the quality of 2D smoothing. 
                  Try different values of probe parameters for different zones on the map. ")
                )
          )
                
       ),
    
      navbarMenu("Theory",
         tabPanel("Multivariate KDE",
            withMathJax(includeHTML("theory1.html"))
         ),
         tabPanel("2D Kernel Density Estimation",
            withMathJax(includeHTML("theory2.html"))
         )
      ),

      tabPanel("Documentation",
            includeHTML("doc.html")
      ),

      tabPanel("Summary",
            includeMarkdown("summary.md")
      )
  )
  
))
