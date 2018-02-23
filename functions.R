getArticlesForTopicCode <- function(outputDb, topicCode) {
  query <- sub("TOPIC_CODE", topicCode, "SELECT * FROM articles WHERE (topic_codes LIKE '%TOPIC_CODE%')");
  articlesForTopicCode <- dbGetQuery(outputDb, query);
  
  articlesForTopicCode;
}