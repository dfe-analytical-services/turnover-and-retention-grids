# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#load in packages
library(shiny)
library(gridExtra)
library(grid)
library(tidyr)
library(knitr)
library(DT)
library(purrr)
library(stringr)

#load datasets and functions
source("R/load_datasets.R")
source("R/functions.R")

# Define server logic
shinyServer(function(input, output, session) {
  
  ######TAB 1#####
  
  #####Set up drop down boxes for each variable#####
  
  #update phase dropdown when value is selected  
  updateSelectizeInput(
    session = session, 
    inputId = 't1_phase_dropdown',
    choices = c("Primary", "Secondary","Special"),
    selected = "")
  
  #update region dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_region_dropdown',
    choices = c("East of England", "East Midlands", "Inner London", "North East",
                "North West", "Outer London", "South East", "South West",
                "West Midlands", "Yorkshire and the Humber"),
    selected = "")
  
  #update school type dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_type_dropdown',
    choices = c("LA Maintained", "Not LA Maintained"),
    selected = "")
  
  #update percentage of permanent teachers in school dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_perm_dropdown',
    choices = c("Under 90% permanent staff", "At least 90% permanent staff"),
    selected = "")
  
  #update FT_PT dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_FT_dropdown',
    choices = c("Full-time", "Part-time"),
    selected = "")
  
  #update subject dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_subject_dropdown',
    choices =  c( "Art & Design", "Biology", "Business Studies", "Chemistry", 
                  "Classics", "Computing", "Design & Technology", "Drama", 
                  "English", "Food", "Geography", "History", "Mathematics", 
                  "Modern Foreign Languages", "Music", "Physical Education",
                  "Physics","Religious Education"),
    selected = "")
  
  #update Provider type dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_provider_dropdown',
    choices = c("HEI", "EBITT", "SCITT"),
    selected = "")
  
  #update PG_UG dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't1_PG_dropdown',
    choices = c("Postgraduate Trainee", "Undergraduate Trainee"),
    selected = "")
  
  
  #####Create button to remove all filters###### 
  
  #update phase dropdown when value is selected  
  observeEvent(input$Remove_All, {
    updateSelectizeInput(
      session = session, 
      inputId = 't1_phase_dropdown',
      choices = c("Primary", "Secondary","Special"),
      selected = "")
    
    #update region dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't1_region_dropdown',
      choices = c("East of England", "East Midlands", "Inner London", "North East",
                  "North West", "Outer London", "South East", "South West",
                  "West Midlands", "Yorkshire and the Humber"),
      selected = "")
    
    #update school type dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't1_type_dropdown',
      choices = c("LA Maintained", "Not LA Maintained"),
      selected = "")
    
    #update percentage of permanent teachers in school dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't1_perm_dropdown',
      choices = c("Under 90% permanent staff", "At least 90% permanent staff"),
      selected = "")
    
    #update FT_PT dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't1_FT_dropdown',
      choices = c("Full-time", "Part-time"),
      selected = "")
    
    #update subject dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't1_subject_dropdown',
      choices =  c( "Art & Design", "Biology", "Business Studies", "Chemistry", 
                    "Classics", "Computing", "Design & Technology", "Drama", 
                    "English", "Food", "Geography", "History", "Mathematics", 
                    "Modern Foreign Languages", "Music", "Physical Education",
                    "Physics","Religious Education"),
      selected = "")
    
    #update Provider type dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't1_provider_dropdown',
      choices = c("HEI", "EBITT", "SCITT"),
      selected = "")
    
    #update PG_UG dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't1_PG_dropdown',
      choices = c("Postgraduate Trainee", "Undergraduate Trainee"),
      selected = "")
    
  })
  
  ######Filter data and create data frames######
  
  # Filter data based on selections in the drop down boxes
  t1_selected_data <- reactive({
    fn_retention(fn_emp_vec_na(input$t1_phase_dropdown),
                 fn_emp_vec_na(input$t1_region_dropdown),
                 fn_emp_vec_na(input$t1_type_dropdown),
                 fn_emp_vec_na(input$t1_perm_dropdown),
                 fn_emp_vec_na(input$t1_FT_dropdown),
                 fn_emp_vec_na(input$t1_subject_dropdown),
                 fn_emp_vec_na(input$t1_provider_dropdown),
                 fn_emp_vec_na(input$t1_PG_dropdown)
    )
  }
  )
  
  
  #Create data frame of the numbers of NQTs remaining in each year.
  t1_data_table_numbers <-  reactive({
    # Start with data
    t1_selected_data() %>%
      fn_retention_numbers() %>%
      mutate_at(2:9,funs(ifelse(is.na(.),., formatC(., width = 5, digits = 0, format = "f", big.mark=","))))
  })
  
  # Create data frame of the percentage of NQTs remaining in each year.
  t1_data_table_perc <-  reactive({
    # Start with data
    t1_selected_data() %>%
      # Self join filtered on year 0
      left_join(x = ., y = filter(., YearsFrom == 0), by = c("NQT_Year")) %>%
      # Calculate percentage compared to year 0
      mutate(n = ifelse(YearsFrom.x == 0, n.x, 100 * n.x/n.y)) %>%
      # Select cols
      select(NQT_Year, YearsFrom = YearsFrom.x, n) %>%
      fn_retention_numbers() %>%
      mutate_at(2, funs(ifelse(is.na(.),., formatC(., width = 5, digits = 0, format = "f", big.mark=",")))) %>%
      mutate_at(3:9,funs(ifelse(is.na(.),., formatC(., width = 5, digits = 1, format = "f", big.mark=","))))
  })
  
  ######Create output tables######
  
  # Create table with the number of NQTs still in service in each year.
  output$t1_data_table_numbers <-  DT::renderDataTable({
    # Produce warning if filters return no NQTs
    validate(
      need(is.na(t1_data_table_numbers()$'Number of NQTs') == FALSE, 'The filters you have selected applied to no newly qualified teachers between 2010 and 2016, please select more data.')
    )
    datatable(t1_data_table_numbers(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames = FALSE,
              width = 5)
  })
  
  # Create table with the percentage of NQTs still in service in each year.
  output$t1_data_table_percentages <-  DT::renderDataTable({
    # Produce warning if filters return no NQTs
    validate(
      need(is.na(t1_data_table_perc()$'Number of NQTs') == FALSE, 'The filters you have selected applied to no newly qualified teachers between 2010 and 2016, please select more data.')
    )
    datatable(t1_data_table_perc(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames=FALSE,
              width = 5)
  })
  
  # text saying the number of NQTs selected in the grid is very low.
  output$t1_warning <- renderText({
    if (mean(t1_selected_data()$'n', na.rm=TRUE) < 100) 
    {paste("The number of newly qualified teachers selected is VERY low here, be careful drawing conclusions 
           based on figures displayed in this grid.") } else {paste("")}
    })
  
  
  
  #####TAB 2#####---------------------------------------------------------------------------------------------------------------------------------------------- 
  
  #####Set up drop down boxes for each variable#####
  
  #update subject dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't2_subject_dropdown',
    choices = c( "Art & Design", "Biology", "Business Studies", "Chemistry", 
                 "Classics", "Computing", "Design & Technology", "Drama", 
                 "English", "Food", "Geography", "History", "Mathematics", 
                 "Modern Foreign Languages", "Music", "Physical Education",
                 "Physics","Religious Education"),
    selected = "")
  
  #update leaver type dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't2_leavertype_dropdown',
    choices = c("Wastage", "Retired"),
    selected = "")
  
  #update gender dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't2_gender_dropdown',
    choices = c("Female", "Male"),
    selected = "")
  
  #update age dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't2_age_dropdown',
    choices = c("Less than 35", "35-54", "55 and over"),
    selected = "")
  
  #####Create button to remove all filters###### 
  
  #update subject dropdown when value is selected
  observeEvent(input$Remove_All_leavers, {
    updateSelectizeInput(
      session = session, 
      inputId = 't2_subject_dropdown',
      choices = c( "Art & Design", "Biology", "Business Studies", "Chemistry", 
                   "Classics", "Computing", "Design & Technology", "Drama", 
                   "English", "Food", "Geography", "History", "Mathematics", 
                   "Modern Foreign Languages", "Music", "Physical Education",
                   "Physics","Religious Education"),
      selected = "")
    
    #update leaver type dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't2_leavertype_dropdown',
      choices = c("Wastage", "Retired"),
      selected = "")
    
    #update gender dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't2_gender_dropdown',
      choices = c("Female", "Male"),
      selected = "")
    
    #update age dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't2_age_dropdown',
      choices = c("Less than 35", "35-54", "55 and over"),
      selected = "")
  })
  
  ######Filter data and create data frames######
  
  # Filter data based on selections in the drop down boxes
  t2_selected_data <- reactive({
    fn_entrants_leavers(data_leavers,
                        fn_emp_vec_na(input$t2_subject_dropdown),
                        fn_emp_vec_na(input$t2_gender_dropdown),
                        fn_emp_vec_na(input$t2_age_dropdown),
                        "QualifiedLeaverType")
  }
  )
  
  # Create data frame for leaver numbers by subject
  t2_data_table_numbers_subjects <- reactive({
    t2_selected_data() %>% 
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedLeaverType",
        inp_type = fn_emp_vec_na(input$t2_leavertype_dropdown),
        agg_cols = c("Subject"),
        measure = "n")
  })
  
  # Create data frame for leaver numbers by demographics
  t2_data_table_numbers_demographics <- reactive({
    t2_selected_data() %>% 
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedLeaverType",
        inp_type = fn_emp_vec_na(input$t2_leavertype_dropdown),
        agg_cols = c("Gender", "AgeGroup"),
        measure = "n")%>%
      arrange(factor(AgeGroup, levels = c("Less than 35", "35-54", "55 and over")), Gender)
  })
  
  # Create data frame for leaver percentages by subject.
  t2_data_table_percentages_subjects <- reactive({
    t2_selected_data() %>% 
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedLeaverType",
        inp_type = fn_emp_vec_na(input$t2_leavertype_dropdown),
        agg_cols = c("Subject"),
        measure = "perc")
  })
  
  # Create data frame for leaver percentages by demographics
  t2_data_table_percentages_demographics <- reactive({
    t2_selected_data() %>% 
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedLeaverType",
        inp_type = fn_emp_vec_na(input$t2_leavertype_dropdown),
        agg_cols = c("Gender", "AgeGroup"),
        measure = "perc") %>%
      arrange(factor(AgeGroup, levels = c("Less than 35", "35-54", "55 and over")), Gender)
  })
  
  ######Create output tables######
  
  # Create final table for number of leavers by subject.
  output$t2_data_table_numbers_subjects <-  DT::renderDataTable({
    datatable(t2_data_table_numbers_subjects(),
              extensions = 'Buttons',
              options= data_table_options,
              rownames = FALSE,
              width = 5)
  })
  
  # Create final table for percentage of leavers by subject.
  output$t2_data_table_percentages_subjects <-  DT::renderDataTable({
    datatable(t2_data_table_percentages_subjects(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames=FALSE,
              width = 5)
  })
  
  # Create fbnal table for number of leavers by demographics
  output$t2_data_table_numbers_demographics <-  DT::renderDataTable({
    datatable(t2_data_table_numbers_demographics(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames = FALSE,
              width = 5)
  })
  
  # Create final table for percentage of leavers by demographics
  output$t2_data_table_percentages_demographics <-  DT::renderDataTable({
    datatable(t2_data_table_percentages_demographics(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames=FALSE,
              width = 5)
  })
  
  #####TAB 3#####---------------------------------------------------------------------------------------------------------------------------------------------- 
  
  #####Set up drop down boxes for each variable#####
  
  #update subject dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't3_subject_dropdown',
    choices = c( "Art & Design", "Biology", "Business Studies", "Chemistry", 
                 "Classics", "Computing", "Design & Technology", "Drama", 
                 "English", "Food", "Geography", "History", "Mathematics", 
                 "Modern Foreign Languages", "Music", "Physical Education",
                 "Physics","Religious Education"),
    selected = "")
  
  #update entrant type dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't3_entranttype_dropdown',
    choices = c("NQT", "Returner", "New to the state funded sector"),
    selected = "")
  
  #update gender dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't3_gender_dropdown',
    choices = c("Female", "Male"),
    selected = "")
  
  #update age dropdown when value is selected
  updateSelectizeInput(
    session = session, 
    inputId = 't3_age_dropdown',
    choices = c("Less than 35", "35-54", "55 and over"),
    selected = "")
  
  #####Create button to remove all filters###### 
  
  #update subject dropdown when value is selected
  observeEvent(input$Remove_All_entrants, {
    updateSelectizeInput(
      session = session, 
      inputId = 't3_subject_dropdown',
      choices = c( "Art & Design", "Biology", "Business Studies", "Chemistry", 
                   "Classics", "Computing", "Design & Technology", "Drama", 
                   "English", "Food", "Geography", "History", "Mathematics", 
                   "Modern Foreign Languages", "Music", "Physical Education",
                   "Physics","Religious Education"),
      selected = "")
    
    #update entrant type dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't3_entranttype_dropdown',
      choices = c("NQT", "Returner", "New to the state funded sector"),
      selected = "")
    
    #update gender dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't3_gender_dropdown',
      choices = c("Female", "Male"),
      selected = "")
    
    #update age dropdown when value is selected
    updateSelectizeInput(
      session = session, 
      inputId = 't3_age_dropdown',
      choices = c("Less than 35", "35-54", "55 and over"),
      selected = "")
  })
  
  ######Filter data and create data frames######
  
  # Filter data based on selections in the drop down boxes
  t3_selected_data <- reactive({
    fn_entrants_leavers(data_entrants,
                        fn_emp_vec_na(input$t3_subject_dropdown),
                        fn_emp_vec_na(input$t3_gender_dropdown),
                        fn_emp_vec_na(input$t3_age_dropdown),
                        "QualifiedEntrantType")
  }
  )
  
  # Create data frame for entrant numbers by subject.
  t3_data_table_numbers_subjects <- reactive({
    t3_selected_data() %>%
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedEntrantType",
        inp_type = fn_emp_vec_na(input$t3_entranttype_dropdown),
        agg_cols = c("Subject"),
        measure = "n")
  })
  
  # Create data frame for entrant numbers by demographics
  t3_data_table_numbers_demographics <- reactive({
    t3_selected_data() %>%
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedEntrantType",
        inp_type = fn_emp_vec_na(input$t3_entranttype_dropdown),
        agg_cols = c("Gender", "AgeGroup"),
        measure = "n")%>%
      arrange(factor(AgeGroup, levels = c("Less than 35", "35-54", "55 and over")), Gender)
  })
  
  # Create data frame for entrant percentages by subject.
  t3_data_table_percentages_subjects <- reactive({
    t3_selected_data() %>%
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedEntrantType",
        inp_type = fn_emp_vec_na(input$t3_entranttype_dropdown),
        agg_cols = c("Subject"),
        measure = "perc")
  })
  
  # Create data frame for entrant percentages by demographics
  t3_data_table_percentages_demographics <- reactive({
    t3_selected_data() %>%
      fn_entrants_leavers_aggregate(
        col_type = "QualifiedEntrantType",
        inp_type = fn_emp_vec_na(input$t3_entranttype_dropdown),
        agg_cols = c("Gender", "AgeGroup"),
        measure = "perc")%>%
      arrange(factor(AgeGroup, levels = c("Less than 35", "35-54", "55 and over")), Gender)
  })
  
  
  ######Create output tables######
  
  # Create final table for number of entrants by subject.
  output$t3_data_table_numbers_subjects <-  DT::renderDataTable({
    datatable(t3_data_table_numbers_subjects(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames = FALSE,
              width = 5)
  })
  
  # Create final table for percentage of entrants by subject.
  output$t3_data_table_percentages_subjects <-  DT::renderDataTable({
    datatable(t3_data_table_percentages_subjects(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames=FALSE,
              width = 5)
  })
  
  # Create final table for number of entrants by demographics.
  output$t3_data_table_numbers_demographics <-  DT::renderDataTable({
    datatable(t3_data_table_numbers_demographics(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames = FALSE,
              width = 5)
  })
  
  # Create final table for percentage of entrants by demographics.
  output$t3_data_table_percentages_demographics <-  DT::renderDataTable({
    datatable(t3_data_table_percentages_demographics(),
              extensions = 'Buttons',
              options=data_table_options,
              rownames=FALSE,
              width = 5)
  })
  
  # stop app running when closed in browser
  session$onSessionEnded(function() { stopApp() })
  
  })  
