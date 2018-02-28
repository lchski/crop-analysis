library(scales)

getArticlesForTopicCode <- function(outputDb, topicCode) {
  query <- sub("TOPIC_CODE", topicCode, "SELECT * FROM articles WHERE (topic_codes LIKE '%TOPIC_CODE%')");
  articlesForTopicCode <- dbGetQuery(outputDb, query);
  
  articlesForTopicCode;
}

getArticlesForMultipleTopicCodes <- function(outputDb, topicCodes) {
  # Create list with a data frame for each topic code
  articlesForCodes <- lapply(topicCodes, function(topicCode) getArticlesForTopicCode(outputDb, topicCode))
  
  # Name the list items with the topic codes
  names(articlesForCodes) <- topicCodes

  articlesForCodes
}

getCountsForTopicCode <- function(outputDb, topicCode) {
  query <- sub("TOPIC_CODE", topicCode, "SELECT issue_uuid, COUNT(*) as 'count' FROM articles WHERE (topic_codes LIKE '%TOPIC_CODE%') GROUP BY issue_uuid");
  countsForTopicCode <- dbGetQuery(outputDb, query);

  countsForTopicCode;
}

createGenericIssueCountFrame <- function(issues) {
  # Create data frame with two columns: issue UUID, and count (default to 0)
  genericIssueCountFrame <- data.frame(issues, c(rep(0, length(issues))))

  # Label the columns
  names(genericIssueCountFrame) <- c("issue_uuid", "count")

  genericIssueCountFrame
}

countTopicCodeForIssues <- function(outputDb, topicCode, issues) {
  # Get the raw data frame with merged counts
  mergedDf <- merge(createGenericIssueCountFrame(issues), getCountsForTopicCode(outputDb, topicCode), by=c("issue_uuid"), all=TRUE)

  # Drop the unused count field
  cleanedDf <- data.frame(mergedDf$issue_uuid, mergedDf$count.y)

  # Relabel the columns
  names(cleanedDf) <- c("issue_uuid", "count")

  # Replace NA values with 0
  cleanedDf <- replace(cleanedDf, is.na(cleanedDf), 0)

  cleanedDf
}

countMultipleTopicCodesForIssues <- function(outputDb, topicCodes, issues) {
  # Create list with a data frame for each topic code
  issueCountsForTopicCodes <- lapply(topicCodes, function(topicCode) countTopicCodeForIssues(outputDb, topicCode, issues))

  # Name the list items with the topic codes
  names(issueCountsForTopicCodes) <- topicCodes

  issueCountsForTopicCodes
}



## PLOTTING FUNCTIONS
barplotCountsForTopicCode <- function(issueCountsByTopicCode, topicCode, ylimUpper = NA, topicCodeStore) {
  countsForTopicCode <- issueCountsByTopicCode[[topicCode]];
  
  ggplot(countsForTopicCode, aes(x = countsForTopicCode$issue_uuid, y = countsForTopicCode$count)) +
    geom_bar(stat="identity") +
    ylim(0, ylimUpper) +
    xlab("Issue") +
    ylab("Count") +
    ggtitle(sub("TOPIC_CODE", topicCodeStore[which(topicCodeStore$code == topicCode), ][["description"]], "Articles coded 'TOPIC_CODE'")) +
    theme(
      axis.text.x=element_text(angle=90, hjust=1, vjust=0.5),
      plot.title = element_text(hjust = 0.5)
    );
}

generateBarplotCountsForMultipleTopicCodes <- function(issueCountsByTopicCode, topicCodes, topicCodeStore) {
  maxValue <- Reduce(function(maxValue, issueCountsForCode) if(max(issueCountsForCode[["count"]]) > maxValue) max(issueCountsForCode[["count"]]) else maxValue, issueCountsByTopicCode, 0)

  issueCountsByTopicCodesBarPlots <- lapply(topicCodes, function(topicCode) barplotCountsForTopicCode(issueCountsByTopicCode, topicCode, maxValue, topicCodeStore))
  names(issueCountsByTopicCodesBarPlots) <- topicCodes
  
  issueCountsByTopicCodesBarPlots
}

generateChartForGenderCounts <- function(genderCounts) {
  totalArticles <- sum(genderCounts$count)
  # Convert gender column to factor to ensure order
  genderCounts$gender <- factor(genderCounts$gender, levels = genderCounts$gender)
  
  ggplot(genderCounts, aes(x = genderCounts$gender, y = genderCounts$count/sum(genderCounts$count))) +
    geom_bar(stat="identity") +
    xlab("Inferred author gender") +
    ylab("Percentage of articles published") +
    scale_y_continuous(labels=scales::percent) +
    ggtitle("Percentage of articles published by inferred author gender") +
    theme(
      plot.title = element_text(hjust = 0.5)
    );
}

generateChartForInstitutionCounts <- function(institutionCounts) {
    # Convert institution column to factor to ensure order
  institutionCounts$institution <- factor(institutionCounts$institution, levels = institutionCounts$institution)
  
  ggplot(institutionCounts, aes(x = institutionCounts$institution, y = institutionCounts$count)) +
    geom_bar(stat="identity") +
    xlab("Author institution") +
    ylab("Number of articles published") +
    ggtitle("Number of articles published by author institution") +
    theme(
      axis.text.x=element_text(angle=90, hjust=1, vjust=0.5),
      plot.title = element_text(hjust = 0.5)
    );
}
