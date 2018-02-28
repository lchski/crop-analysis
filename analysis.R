# Imports
library("DBI")
library("RSQLite")
library("ggplot2")
library("scales")
source("./functions.R")

# Setup
outputDb <- dbConnect(drv = RSQLite::SQLite(), dbname = "output.sqlite")
topicCodeStore <- read.csv("codes.csv", header = TRUE)

# Base data objects
sampledIssues <- dbGetQuery(outputDb, "SELECT * FROM issues WHERE in_sample = 1")
topicCodes <- as.character(topicCodeStore$code)
issueUuids <- sampledIssues$uuid

# Analytical data objects
articlesByTopicCodes <- getArticlesForMultipleTopicCodes(outputDb, topicCodes)
issueCountsByTopicCodes <- countMultipleTopicCodesForIssues(outputDb, topicCodes, issueUuids)
genderCounts <- dbGetQuery(outputDb, 'SELECT author_presumed_gender as "gender", COUNT(*) as "count" FROM articles GROUP BY gender ORDER BY "count" DESC')
institutionCounts <- dbGetQuery(outputDb, 'SELECT author_institution as "institution", COUNT(*) as "count" FROM articles WHERE (length(author_institution) != 0) AND (author_institution != "NA") GROUP BY author_institution ORDER BY "count" DESC');

# Plots
issueCountsByTopicCodesBarPlots <- generateBarplotCountsForMultipleTopicCodes(issueCountsByTopicCodes, topicCodes, topicCodeStore)
lapply(topicCodes, function(topicCode) ggsave(
    filename=sub("TOPIC_CODE", topicCode, "charts/TOPIC_CODE.png"),
    plot=issueCountsByTopicCodesBarPlots[[topicCode]]
  ))
genderCountChart <- generateChartForGenderCounts(genderCounts)
ggsave(filename = "charts/percent_inferred_author_gender.png", plot=genderCountChart)
institutionCountChart <- generateChartForInstitutionCounts(institutionCounts[which(institutionCounts$count > 4), ])
ggsave(filename = "charts/count_author_institution.png", plot=institutionCountChart)

# Cleanup
dbDisconnect(outputDb)
