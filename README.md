# turnover-and-retention-grids [![Build Status](https://travis-ci.org/dfe-analytical-services/turnover-and-retention-grids.svg?branch=master)](https://travis-ci.org/dfe-analytical-services/turnover-and-retention-grids)
## Shiny App for to allow exploration of teacher retention data

### Background

Retention of Newly Qualified Teachers (NQTs) is published annually in Table 8 of the School Workforce Census (SWC), however there has been considerable interest in how these figures vary across different school level, demographic and geographic factors.

This app allows users to filter the data published in Table 8 (albeit with a shorter time period) by a variety of different factors.

Entrants and leavers by subject data was first published in May 2017, there was demand for an update of this data which has been included within this application.

### Output

The output of this project is an R shiny app that allows users to filter data on the retention of NQTs and entrants and leavers by subject based on a range of demographic, regional, training and school level factors.

### Methodology

For the retention of NQTs, NQTs are identified each year as being new in service in year x and having qualified in year x-1. They are then linked into the SWC for each following year to find out if they are still in service. Demographic details of the teacher are extracted from the SWC as well as data on the school they start working as an NQT in, including region. Also, details of the training route they went through are extracted from the Initial Teacher Training Performance Profiles. Data on the qualifications a teacher holds at the point they become an NQT are also extracted from the SWC.

For leavers by subject, teachers are identified as having left if they are teaching in year x but not year x+1. For the year they left, the subjects they were teaching during the week of the SWC are identified and a teacher is assigned to each subject they were teaching proportionally to the number of hours they taught in a subject (i.e. if a teacher teaches 10 hours Mathematics and 10 hours Physics they would be 0.5 a Mathematics teacher and 0.5 a Physics teacher. 

Entrants by subject follows a similar methodology, except that it is teachers working in year x who weren't working in year x-1.

Curriculum data is only available for approximately 75% of secondary school teachers so all figures are scaled up to account for this.

All figures are presented in headcount form and relate to qualified teachers only.

### Opening the Project

To open the R Project double click the turnover-and-retention-grids Rproj file.

This project uses Packrat for dependency management. When you first open the project Packrat will install all the required packages in the local folder using the same versions as used for development. This ensures that all of the functions used will work over time and is only done once.

### Project structure

Throughout the project code is modulated and all files are in relevant sub folders. This allows code to be reused and split into manageable scripts.

#### Root

The root project folder contains the user interface (UI) and the server (where the data is filtered and tables are created).

#### Data folder

The data folder is where the raw data sits.

Within this folder there are individual rds's and csv's for each of the input datasets. The rds's are used in the app and the csv's are created for publication purposes (other than "nqt_year_title_lookup.csv" which is also used in the app). 

#### R folder

This folder contains the R scripts which load data into the app and functions which are used to filter and manipulate the data.

The core structure of the app is as follows:

* Load all the data and functions in.
* Create selection boxes for filtering the data for tab 1.
* Create a reactive dataset for tab 1 based on the filters selcted in the boxes created above.
* Create the data for tab 1 (both in terms of raw numbers and percentages).
* Create the data tables for tab 1 using the data.
* Repeat this process for tabs 2 and 3.

#### Styles folder

This folder contains a css file that defines the style that the R shiny app is to use and a DfE logo. This moves it from default styling to be in line with DfE style.

The css file is applied and logo added to the UI as "tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")".

#### Queries

The queries subfolder is for reference.

The raw data sources are taken directly from the SWFC_Project and TAD_UserSpace databases and as such the sql code underpinning these is saved in the Queries folder. This project does not run queries off the database directly as this is static data and it would not be neccesary.

The queries are run once in the R script "Create_data_for_app" which is in the Misc folder.

### Data Sources

The following data sources have been used in this analysis:

* [School Workforce Census](https://www.gov.uk/government/collections/statistics-school-workforce)
* [Initial Teacher Training Performance Profiles](https://www.gov.uk/government/collections/statistics-teacher-training)
