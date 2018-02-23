# Imports
library("DBI")
library("RSQLite")
source("./functions.R")

# Setup
outputDb <- dbConnect(drv = RSQLite::SQLite(), dbname = "output.sqlite")

# Base data frames
sampledIssues <- dbGetQuery(outputDb, "SELECT * FROM issues WHERE in_sample = 1")

# Topic code data frames
articlesIND <- getArticlesForTopicCode(outputDb, "IND")

# Cleanup
dbDisconnect(outputDb)
