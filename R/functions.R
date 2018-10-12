
# Supporting Functions ----------------------------------------------------

# The following functions a vector/column col and a vector var and creates a 
# condition that if the var is not na it filters col based on elements in 
# var
# Params:
# col = the vector/col to filter
# var = the vector of filtering variables
fn_in_not_na <- function(col, var){
  if (is.na(var)) 1==1 else col %in% var
}

# The following functions a vector vec and if the vector is empty returns
# NA. If not NA it returns the vector.
# Params:
# vec = any vector
fn_emp_vec_na <- function(vec){
  if (is_empty(vec)){
    NA
  } else {
    vec
  }
}

# The following is a list of data table options that we will be using accross
# all data tables in the app.
data_table_options <- list(dom = 'Bfrtip',
                           buttons = c('copy', 'csv'),
                           pageLength = 5,
                           paging=FALSE,
                           searching=FALSE,
                           info = FALSE,
                           rowReorder = FALSE,
                           rowReorder.enable = FALSE,
                           language.select.rows=FALSE,
                           language.loadingRecords=FALSE,
                           language.info=FALSE,
                           fixedHeader.footer=FALSE,
                           columns.width = "10px",
                           columnDefs = list(list(className = 'dt-right', targets = "_all")))

# Retention ---------------------------------------------------------------

# This function takes the full retention dataset and conditionally filters
# based on a number of input parameters. If the input parameters are NA it does
# not filter based on that parameter.
# Note: Subjects are treated differently as you can teach multiple subjects.
# Params:
# inp_phase: inp_ttct = vectors for values to filter on in each col
fn_retention <- function(inp_phase = NA, inp_region = NA, inp_schooltype = NA,
                         inp_percperm = NA, inp_ftpt = NA, inp_subjspec = NA,
                         inp_ttpt = NA, inp_ttct = NA
){
  retention_data %>%
    # Filter all columns based on input
    filter(
      fn_in_not_na(Phase, inp_phase),
      fn_in_not_na(RegionOfSchool, inp_region),
      fn_in_not_na(LA_or_Academy, inp_schooltype),
      fn_in_not_na(PercentagePermanent, inp_percperm),
      fn_in_not_na(FT_PT, inp_ftpt),
      fn_in_not_na(Provider_Type, inp_ttpt),
      fn_in_not_na(PG_or_UG, inp_ttct)
    ) %>%
    # Filter subject differently due to multiple cols to check
    filter_at(
      vars(11:28),
      any_vars(. %in% inp_subjspec)
    ) %>%
    group_by(NQT_Year, YearsFrom) %>%
    summarise(n = sum(InService * Headcount, na.rm = TRUE)) %>%
    ungroup()
}

# This function takes the output of fn_retention and prepares it for display
# in the app. This is done by pivotting and formatting.
# Params:
# data = The output of fn_retention.
fn_retention_numbers <- function(data){
  # Start with input data
  data %>%
    # Join nqt year title lookup on to data to display even for null years
    right_join(nqt_year_title_lookup, by = c("YearsFrom")) %>%
    # Drop Years from Column so not inclued in spread
    select(-YearsFrom) %>%
    # Spread
    spread(Title, n, fill = NA, drop = FALSE) %>%
    # Join on empty NQT years to display as null for blank years
    right_join(data_frame(NQT_Year = c(2010:2016)), by = c("NQT_Year")) %>%
    # Re order columns
    select(c("NQT_Year", nqt_year_title_lookup$Title)) %>% 
    # Rename
    rename("Year Qualified" = NQT_Year)
  }


# Entrants and Leavers ----------------------------------------------------

# This function takes the raw entrants or leavers data and filters based on
# defined vectors of values.
# params:
# data = raw entrants or leavers data
# inp_subject:inp_type = vectors for values to filter on in each col
# col_type = The column to filter on based on dataset
fn_entrants_leavers <- function(data, inp_subject = NA, inp_gender = NA, inp_age = NA, col_type = c("QualifiedLeaverType", "QualifiedEntrantType")) {
  data %>%
    filter (
    # Filter all columns based on input
    fn_in_not_na(Subject, inp_subject),
    fn_in_not_na(Gender, inp_gender),
    fn_in_not_na(AgeGroup, inp_age)
)
}

# The following function takes the filtered entrants/leavers data from 
# fn_entrants_leavers, aggregates it based on specified columns and returns
# a pivotted dataset with either percentage or numbers of for each group by 
# census year
# params:
# data = the output from fn_entrants_leavers
# col_type = The column to filter on based on dataset
# agg_cols = a vector of columns to group on
# measure = number (n) or percentage (perc)
fn_entrants_leavers_aggregate <- function(
  data, col_type = c("QualifiedLeaverType", "QualifiedEntrantType"), inp_type,
  agg_cols, measure = c("n", "perc")){
  
  # Create a variable for filter based on type of data
  cond_not_filter <- ifelse(col_type == "QualifiedLeaverType", 'Not a qualified Leaver', 'Not a qualified Entrant')
  
  # create decimal places var
  digits <- ifelse(measure == "n", 0, 1)
  
  data %>%
    # Group by combination of agg_cols and census year
    group_by_at(vars(one_of(c(agg_cols, "CensusYear")))) %>% 
    summarise(
      # Create a conditional n based on being a qualified leaver or entrant
      n = sum(ifelse(get(col_type) != cond_not_filter & fn_in_not_na(get(col_type), inp_type), StockSize, 0), na.rm = T),
      # Calculate total stock
      total_stock = sum(StockSize, na.rm = T),
      # Calculate percentage out of total stock
      perc = 100* n/total_stock
      ) %>%
    ungroup() %>%
    select_at(vars(one_of(c(agg_cols, "CensusYear", measure)))) %>%
    spread_("CensusYear", measure) %>%
    mutate_at((length(agg_cols)+1):ncol(.),funs(ifelse(is.na(.),., formatC(., width = 5, digits = digits, format = "f", big.mark=","))))
}

