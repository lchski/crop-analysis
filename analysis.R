# Imports
library("DBI")
library("RSQLite")
source("./functions.R")

# Setup
outputDb <- dbConnect(drv = RSQLite::SQLite(), dbname = "output.sqlite")
topicCodeStore <- read.csv("codes.csv", header = TRUE)

# Base data objects
topicCodes <- topicCodeStore$code
sampledIssues <- dbGetQuery(outputDb, "SELECT * FROM issues WHERE in_sample = 1")

# Topic code data frames
articlesIND <- getArticlesForTopicCode(outputDb, "IND")

# Cleanup
dbDisconnect(outputDb)
