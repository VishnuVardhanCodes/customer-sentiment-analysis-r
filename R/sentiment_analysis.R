# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Lexicon-Based Sentiment Analysis (R/sentiment_analysis.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidytext)
  library(syuzhet)
  library(stringr)
})

#' Perform lexicon-based sentiment analysis on customer text
#'
#' @param df Data frame containing the dataset
#' @param text_col Character, name of original text column
#' @param clean_col Character, name of preprocessed text column (defaults to "cleaned_text")
#' @return Data frame with added columns `Sentiment_Score` and `Sentiment`
analyze_lexicon_sentiment <- function(df, text_col, clean_col = "cleaned_text") {
  if (!clean_col %in% colnames(df)) {
    clean_vec <- clean_text(df[[text_col]])
  } else {
    clean_vec <- df[[clean_col]]
  }
  
  # Calculate sentiment score using Syuzhet (Bing lexicon method)
  scores <- syuzhet::get_sentiment(clean_vec, method = "bing")
  
  # Categorize scores into Positive, Neutral, Negative
  labels <- case_when(
    scores > 0  ~ "Positive",
    scores < 0  ~ "Negative",
    TRUE        ~ "Neutral"
  )
  
  res_df <- df
  res_df$Sentiment_Score <- scores
  res_df$Sentiment       <- labels
  
  return(res_df)
}

#' Calculate summary KPIs from sentiment results
#'
#' @param sentiment_df Data frame containing column `Sentiment`
#' @return List of KPI values (Total, Pos_Count, Neu_Count, Neg_Count, Pos_Pct, Neu_Pct, Neg_Pct)
calculate_sentiment_kpis <- function(sentiment_df) {
  if (!"Sentiment" %in% colnames(sentiment_df)) {
    return(NULL)
  }
  
  total <- nrow(sentiment_df)
  if (total == 0) {
    return(list(
      Total = 0, Pos_Count = 0, Neu_Count = 0, Neg_Count = 0,
      Pos_Pct = 0, Neu_Pct = 0, Neg_Pct = 0, Dominant = "None"
    ))
  }
  
  pos_count <- sum(sentiment_df$Sentiment == "Positive", na.rm = TRUE)
  neu_count <- sum(sentiment_df$Sentiment == "Neutral", na.rm = TRUE)
  neg_count <- sum(sentiment_df$Sentiment == "Negative", na.rm = TRUE)
  
  pos_pct <- round((pos_count / total) * 100, 1)
  neu_pct <- round((neu_count / total) * 100, 1)
  neg_pct <- round((neg_count / total) * 100, 1)
  
  # Determine dominant sentiment
  if (pos_count >= neu_count && pos_count >= neg_count) {
    dominant <- "Positive"
  } else if (neg_count >= pos_count && neg_count >= neu_count) {
    dominant <- "Negative"
  } else {
    dominant <- "Neutral"
  }
  
  return(list(
    Total      = total,
    Pos_Count  = pos_count,
    Neu_Count  = neu_count,
    Neg_Count  = neg_count,
    Pos_Pct    = pos_pct,
    Neu_Pct    = neu_pct,
    Neg_Pct    = neg_pct,
    Dominant   = dominant
  ))
}

#' Extract top sentiment-driving words (Positive vs Negative)
#'
#' @param clean_text_vec Character vector of preprocessed text
#' @param top_n Integer, number of words to return per sentiment
#' @return List with `Positive_Words` and `Negative_Words` data frames
get_sentiment_word_counts <- function(clean_text_vec, top_n = 20) {
  if (length(clean_text_vec) == 0) {
    return(list(
      Positive_Words = data.frame(Word = character(0), Count = integer(0)),
      Negative_Words = data.frame(Word = character(0), Count = integer(0))
    ))
  }
  
  df_temp <- data.frame(doc_id = seq_along(clean_text_vec), text = clean_text_vec, stringsAsFactors = FALSE)
  
  tokens <- df_temp %>%
    tidytext::unnest_tokens(word, text) %>%
    filter(!is.na(word), nchar(word) > 1)
  
  bing_lex <- tidytext::get_sentiments("bing")
  
  sentiment_words <- tokens %>%
    inner_join(bing_lex, by = "word") %>%
    count(word, sentiment, sort = TRUE)
  
  pos_words <- sentiment_words %>%
    filter(sentiment == "positive") %>%
    rename(Word = word, Count = n) %>%
    select(Word, Count) %>%
    head(top_n)
  
  neg_words <- sentiment_words %>%
    filter(sentiment == "negative") %>%
    rename(Word = word, Count = n) %>%
    select(Word, Count) %>%
    head(top_n)
  
  return(list(
    Positive_Words = pos_words,
    Negative_Words = neg_words
  ))
}
