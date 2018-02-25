# Imports
library("DBI")
library("RSQLite")
library("ggplot2")
source("./functions.R")

# Setup
outputDb <- dbConnect(drv = RSQLite::SQLite(), dbname = "output.sqlite")
topicCodeStore <- read.csv("codes.csv", header = TRUE)

# Base data objects
sampledIssues <- dbGetQuery(outputDb, "SELECT * FROM issues WHERE in_sample = 1")
topicCodes <- topicCodeStore$code
issueUuids <- sampledIssues$uuid

# Analytical data objects
articlesByTopicCodes <- getArticlesForMultipleTopicCodes(outputDb, topicCodes)
issueCountsByTopicCodes <- countMultipleTopicCodesForIssues(outputDb, topicCodes, issueUuids)

# Plots
issueCountsByTopicCodesBarPlots <- generateBarplotCountsForMultipleTopicCodes(issueCountsByTopicCodes, topicCodes)
lapply(topicCodes, function(topicCode) ggsave(
    filename=sub("TOPIC_CODE", topicCode, "charts/TOPIC_CODE.png"),
    plot=issueCountsByTopicCodesBarPlots[[topicCode]]
  ))

# Cleanup
dbDisconnect(outputDb)
