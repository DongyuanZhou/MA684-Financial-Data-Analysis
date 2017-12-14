library(shiny)
library(plyr)
library(ggplot2)
library(VGAM)
library(hett)
library(MASS)
library(lme4)
library(devtools)
library(tidyverse)
Loan1517 <- read.table("Loan1517.csv", header = TRUE, sep = ",")
Loan1517$year <- ifelse(Loan1517$term == "36",3,5)
Loan1517$region <- tolower(Loan1517$region)
Loan1517$dti <- Loan1517$dti/100
model2_1<- polr(grade ~ log(loan_amnt) + year + log(monthly_inc) + home_ownership, data = Loan1517)

ui <- fluidPage(
  titlePanel("Simulation: How LC assigned loan grade"),
  sidebarLayout(
    sidebarPanel(
      numericInput("LoanamountInput", "Loan Amount:", 5000, min = 0, max = 1000000),
      
      numericInput("TermInput", "Loan Term",3, min = 1, max = 20),
    
      numericInput("MonthlyincomeInput", "Monthly income:", 5000, min = 0, max = 1000000),
      
      selectInput("HomeownershipInput", "Home Ownership",
                  choices = c("MORTGAGE","RENT","OWN"),
                  selected = "MORTGAGE")),
      
      mainPanel( plotOutput("coolplot1",width="500px",height="300px"))
    
  )
)

server <- function(input, output) {
  output$coolplot1 <- renderPlot({
    
    predx<-data.frame(loan_amnt=input$LoanamountInput, year=input$TermInput, 
                      monthly_inc=input$MonthlyincomeInput, home_ownership=input$HomeownershipInput)
    
    predy<-as.data.frame(as.matrix(predict(model2_1,newdata=predx,type="prob")))
    colnames(predy) <- c("prob")
    predy$grade <- c("A","B","C","D","E","F","G")
    
    ggplot(predy)+
      aes(grade)+
      geom_bar(aes(y = prob,fill = grade),stat = "identity",alpha=0.5)+
      scale_y_continuous(labels = scales::percent)+
      ylab("Probability")+
      labs(title="Grade")+
      scale_fill_discrete(name = "Grade")
  })
}
shinyApp(ui = ui, server = server)
