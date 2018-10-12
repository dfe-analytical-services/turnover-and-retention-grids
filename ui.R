#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


library(shiny)
library(shinycssloaders)
library(dplyr)
library(ggplot2)
library(shinythemes)
library(shinyBS)
library(rmarkdown)

#ui
shinyUI(fluidPage(
  tags$head(
    tags$script(src = "google-analytics.js"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  #create a page with navigation bar at the top
  navbarPage(
    "Teachers Analysis Compendium 4",
    id = "navbar",
    #Front Page###---------------------------------------------------------------------------
    tabPanel(
      "Front Page",
      h1("Teachers Analysis Compendium 4 Entrants, Leavers and Retention Statistics (Pilot)"),
      br(),
      br("This is a tool which has been built to allow users to interact with the data published in
        chapters 6 and 7 of the fourth Teachers Analysis Compendium."),
      br(),
      p("This experimental tool contains three tabs which can be used to interact with data on:"), 
      p("(i) the retention of Newly Qualified Teachers,"),
      p("(ii) the number of leavers from teaching by subject and"), 
      p("(iii) the number of entrants into teaching by subject."), 
      p("The tables are initially set up to include all the data, users can then select filters from the drop down boxes on the left hand side 
         of each tab to change the table to fit the types of schools, subjects, regions or training providers they are interested in."),
      br(),
      br("Further analysis from this publication and the rest of the series can be found here:", 
      a(href="https://www.gov.uk/government/collections/teacher-workforce-statistics-and-analysis", "Teacher workforce statistics and analysis")),
      br(),
      br("For the definitive source of statistics on teachers from the School Workforce Census, visit:",
      a(href="https://www.gov.uk/government/collections/statistics-school-workforce", "Statistics: school workforce")),
      br(),
      br("If you have any comments or feedback, please email", 
      a(href = "mailto:TeachersAnalysisUnit.MAILBOX@education.gov.uk", "TeachersAnalysisUnit.MAILBOX@education.gov.uk")),
      br(),
      br(),
      br(),
      br(),
      br(),
      #dfE logo
      img(
        src = "DfE_logo.png",
        height = 97.5,
        width = 195
      )
      ),
    
    
    #tab 1####--------------------------------------------------------------------------- 
    
tabPanel("Retention", h1("Retention of Newly Qualified Teachers"), 
         br(),
         h3("This tab looks at teachers by the year they gained qualified teacher status, 
            who were in service the following year and the percentage recorded 
            in service in state funded funded schools in England in each year later."), 
         br(),
         h4("Notes:"),
         p("The data can be filtered to look at details of the school they became
            a newly qualified teacher (NQT) in and details of the training route they went through."),
         p("The data can also be filtered to look at the subjects an NQT is
            qualified to teach. This is not necessarily the same as the subject they did their
            Initial Teacher Training in, it will also include any post A Level
            qualification in the relevant subject."),
         p("Total figures from all components on one field may not sum to overall totals as some NQTs may not have data recorded for all the possible selections within the School Workforce Census (SWC)."),
         p("Figures may not equal previously published figures due to rounding."),
         br(),
  sidebarLayout(
       sidebarPanel(
          #dropdown for phase
          selectizeInput(
            't1_phase_dropdown',
            label = "Phase:",
            choices = NULL,
            multiple = TRUE
          ),
          selectizeInput(
            't1_region_dropdown',
            label = "Region:",
            choices = NULL,
            multiple = TRUE
          ),
          selectizeInput(
            't1_type_dropdown',
            label = "School Type:",
            choices = NULL,
            multiple = TRUE
          ),
          selectizeInput(
            't1_perm_dropdown',
            label = "Percentage of Permanent Staff in the School:",
            choices = NULL,
            multiple = TRUE
          ), 
          selectizeInput(
            't1_FT_dropdown',
            label = "Full-time or Part-time status:",
            choices = NULL,
            multiple = TRUE
          ), 
         selectizeInput(
           't1_subject_dropdown',
           label = "Subjects Specialised in:",
           choices = NULL,
           multiple = TRUE
         ), 
          selectizeInput(
            't1_provider_dropdown',
            label = "Teacher Training Provider Type:",
            choices = NULL,
            multiple = TRUE
          ), 
          selectizeInput(
            't1_PG_dropdown',
            label = "Teacher Training Course Type:",
            choices = NULL,
            multiple = TRUE
          ),
         actionButton("Remove_All", "Clear"), width = 3
       ),
        #Contents of main panel
          mainPanel(
          tabsetPanel(
          tabPanel("Percentages", DT::dataTableOutput("t1_data_table_percentages"), style="color:black",
                   paste("The percentage of NQTs who were recorded in service in each year.", 
                         "Source: School Workforce Census and Initial Teacher Training Performance Profiles.")),
          tabPanel("Numbers", DT::dataTableOutput("t1_data_table_numbers"), style="color:black", 
                   paste("The number of NQTs who were recorded in service in each year.", 
                         "Source: School Workforce Census and Initial Teacher Training Performance Profiles.")),
          type = "tabs"),
          textOutput("t1_warning"), style="color:red",
          width = 7),
         
       position = "left", fluid = FALSE)
    ),
#-------------------------------------------------------------------------------
tabPanel("Leavers", h1("Teachers Leaving by Subject"),
         br(),
         h3("This tab provides recent trends in the number of teachers leaving the profession
            in English state-funded secondary schools between 2011 and 2017 by subject."),
         br(),
         h4("Notes:"),
         p("This analysis does not look into the subjects that a teacher is qualified to teach; 
            it only looks only at the subjects that a teacher is teaching in their last year. 
            For example, a teacher may be qualified to teach Geography but may have spent 
            the week the School Workforce Census was taken teaching Mathematics. Therefore, in this analysis 
            they would be identified as a Mathematics teacher."), 
         p("Also, where a teacher teachers more than one subject, they are split 
            proportionally between those subjects. So, if a teacher teaches ten hours
            of Geography and ten hours of Mathematics, they would count as half a 
            Geography teacher and half a Mathematics teacher."), 
         p("The years here identify the year where a teacher was no longer in service,
            i.e leavers in 2017 were teaching in a state funded secondary school in November 2016 but were not teaching 
            in a state funded primary or secondary school in November 2017."),
         p("The data can be filtered to look at different subjects of leavers,
            different exit routes, and demographic details of leavers."),
         p("The sum of the figures on demographics may not sum to total numbers seen in the Teacher Supply Model,
           this is due to different scalings used to create subject level figures."),
         p("Approximately 75% of secondary schools return data on curriculum hours taught by their teachers in any given year,
           these figures are estimates based on those figures and therefore are not exact figures."),
         br(),
         sidebarLayout(
           sidebarPanel(
             #dropdown for subject
             selectizeInput(
               't2_subject_dropdown',
               label = "Subject:",
               choices = NULL,
               multiple = TRUE
             ),
             #dropdown for leaver type
             selectizeInput(
               't2_leavertype_dropdown',
               label = "Leaver Type:",
               choices = NULL,
               multiple = TRUE
             ),
             #dropdown for gender
             selectizeInput(
               't2_gender_dropdown',
               label = "Gender:",
               choices = NULL,
               multiple = TRUE
             ),
             #dropdown for age
             selectizeInput(
               't2_age_dropdown',
               label = "Age Group:",
               choices = NULL,
               multiple = TRUE
             ), 
             actionButton("Remove_All_leavers", "Clear"),
             width = 3
           ),
           #Contents of main panel
           mainPanel(
             tabsetPanel(
               tabPanel("Percentages - Subjects", DT::dataTableOutput("t2_data_table_percentages_subjects"), style="color:black",
                        paste("Source: School Workforce Census.")),
               tabPanel("Numbers - Subjects", DT::dataTableOutput("t2_data_table_numbers_subjects"), style="color:black",
                        paste("Source: School Workforce Census.")),
               tabPanel("Percentages - Demographics", DT::dataTableOutput("t2_data_table_percentages_demographics"), style="color:black",
                        paste("Source: School Workforce Census.")),
               tabPanel("Numbers - Demographics", DT::dataTableOutput("t2_data_table_numbers_demographics"), style="color:black",
                        paste("Source: School Workforce Census.")),
                type = "tabs"), width = 7),
           
           position = "left", fluid = FALSE)
),

tabPanel("Entrants", h1("Teachers Entering by Subject"),
         br(),
         h3("This tab provides recent trends in the number of teachers entering the profession
            in English state-funded secondary schools between 2011 and 2017 by subject."),
         br(),
         h4("Notes:"),
         p("This analysis does not look into the subjects that a teacher is qualified to teach; 
            it only looks only at the subjects that a teacher is teaching in their entry year. 
            For example, a teacher may be qualified to teach Geography but may have spent 
            the week the School Workforce Census was taken teaching Mathematics. Therefore, in this analysis 
            they would be identified as a Mathematics teacher."), 
         p("Also, where a teacher teachers more than one subject, they are split 
            proportionally between those subjects. So, if a teacher teaches ten hours
            of Geography and ten hours of Mathematics, they would count as half a 
            Geography teacher and half a Mathematics teacher."),
         p("The years here identify the year where a teacher was identified as 
            new in service, i.e entrants in 2017 were not in a state funded primary
            or secondary school in November 2016 but were teaching in a state funded secondary school in November 2017,"),
         p("The data can be filtered to look at different subjects of entrants,
            different entry routes into teaching and demographic details."),
         p("The sum of the figures on demographics may not sum to total numbers seen in the Teacher Supply Model,
           this is due to different scalings used to create subject level figures."),
         p("Approximately 75% of secondary schools return data on curriculum hours taught by their teachers in any given year,
           these figures are estimates based on those figures and therefore are not exact figures."),
         br(),
         sidebarLayout(
           sidebarPanel(
             #dropdown for subject
             selectizeInput(
               't3_subject_dropdown',
               label = "Subject:",
               choices = NULL,
               multiple = TRUE
             ),
             #dropdown for entrant type
             selectizeInput(
               't3_entranttype_dropdown',
               label = "Entrant Type:",
               choices = NULL,
               multiple = TRUE
             ),
             #dropdown for gender
             selectizeInput(
               't3_gender_dropdown',
               label = "Gender:",
               choices = NULL,
               multiple = TRUE
             ),
             #dropdown for age
             selectizeInput(
               't3_age_dropdown',
               label = "Age Group:",
               choices = NULL,
               multiple = TRUE
             ), 
             actionButton("Remove_All_entrants", "Clear"),
             width = 3
           ),
           #Contents of main panel
           mainPanel(
             tabsetPanel(
               tabPanel("Percentages - Subjects", DT::dataTableOutput("t3_data_table_percentages_subjects"), style="color:black",
                        paste("Source: School Workforce Census.")),
               tabPanel("Numbers - Subjects", DT::dataTableOutput("t3_data_table_numbers_subjects"), style="color:black",
                        paste("Source: School Workforce Census.")),
               tabPanel("Percentages - Demographics", DT::dataTableOutput("t3_data_table_percentages_demographics"), style="color:black",
                        paste("Source: School Workforce Census.")),
               tabPanel("Numbers - Demographics", DT::dataTableOutput("t3_data_table_numbers_demographics"), style="color:black",
                        paste("Source: School Workforce Census.")),
                type = "tabs"), width = 7),
           
           position = "left", fluid = FALSE)
) 
)
)
)

#-------------------------------------------------------------------------------------------
