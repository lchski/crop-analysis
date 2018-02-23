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
