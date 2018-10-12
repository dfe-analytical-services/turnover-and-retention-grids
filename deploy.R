# Create conditional app name based on branch

app_name <- if (Sys.getenv("TRAVIS_BRANCH") == "master"){
  "turnover-and-retention-grids"
} else if (Sys.getenv("TRAVIS_BRANCH") == "develop"){
  "dev-turnover-and-retention-grids"
}

# Set account info
rsconnect::setAccountInfo(
  name="department-for-education",
  token=Sys.getenv("SHINYAPPS_TOKEN"),
  secret=Sys.getenv("SHINYAPPS_SECRET")
  )

# Print name to console
print(app_name)

# Deploy
rsconnect::deployApp(appName = app_name)
