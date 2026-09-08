# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Text Mining (R/text_mining.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidytext)
  library(tm)
  library(tidyr)
  library(Matrix)
})

#' Calculate Word Frequencies from clean text vector
#'
#' @param clean_text_vec Character vector of preprocessed text
#' @param top_n Integer, maximum number of top frequent words to return
#' @return Data frame with columns `Word` and `Frequency`
get_word_frequencies <- function(clean_text_vec, top_n = 50) {
  if (length(clean_text_vec) == 0 || all(nchar(clean_text_vec) == 0)) {
    return(data.frame(Word = character(0), Frequency = integer(0)))
  }
  
  df_temp <- data.frame(doc_id = seq_along(clean_text_vec), text = clean_text_vec, stringsAsFactors = FALSE)
  
  tokens <- df_temp %>%
    tidytext::unnest_tokens(word, text) %>%
    filter(!is.na(word), nchar(word) > 1)
  
  freq_df <- tokens %>%
    count(word, sort = TRUE) %>%
    rename(Word = word, Frequency = n)
  
  if (!is.null(top_n) && top_n > 0 && top_n <= nrow(freq_df)) {
    freq_df <- head(freq_df, top_n)
  }
  
  return(freq_df)
}

#' Calculate TF-IDF (Term Frequency - Inverse Document Frequency) for the dataset
#'
#' @param clean_text_vec Character vector of preprocessed text
#' @return Data frame with columns `Term`, `TF`, `IDF`, `TF_IDF_Score`
compute_tfidf <- function(clean_text_vec) {
  if (length(clean_text_vec) == 0 || all(nchar(clean_text_vec) == 0)) {
    return(data.frame(Term = character(0), TF = numeric(0), IDF = numeric(0), TF_IDF_Score = numeric(0)))
  }
  
  df_temp <- data.frame(doc_id = factor(seq_along(clean_text_vec)), text = clean_text_vec, stringsAsFactors = FALSE)
  
  words_df <- df_temp %>%
    tidytext::unnest_tokens(word, text) %>%
    filter(!is.na(word), nchar(word) > 1) %>%
    count(doc_id, word, name = "n")
  
  if (nrow(words_df) == 0) {
    return(data.frame(Term = character(0), TF = numeric(0), IDF = numeric(0), TF_IDF_Score = numeric(0)))
  }
  
  tfidf_res <- words_df %>%
    tidytext::bind_tf_idf(word, doc_id, n) %>%
    group_by(word) %>%
    summarise(
      TF = round(mean(tf), 4),
      IDF = round(mean(idf), 4),
      TF_IDF_Score = round(mean(tf_idf), 4),
      Max_TF_IDF = round(max(tf_idf), 4),
      .groups = "drop"
    ) %>%
    rename(Term = word) %>%
    arrange(desc(TF_IDF_Score))
  
  return(tfidf_res)
}

#' Extract top keywords based on TF-IDF importance
#'
#' @param tfidf_df Data frame returned by `compute_tfidf`
#' @param top_n Integer, top terms to extract
#' @return Data frame of top keywords with their TF-IDF scores
extract_keywords <- function(tfidf_df, top_n = 20) {
  if (nrow(tfidf_df) == 0) {
    return(data.frame(Rank = integer(0), Keyword = character(0), TF_IDF_Score = numeric(0)))
  }
  
  res <- tfidf_df %>%
    arrange(desc(TF_IDF_Score)) %>%
    head(top_n) %>%
    mutate(Rank = row_number()) %>%
    select(Rank, Term, TF_IDF_Score) %>%
    rename(Keyword = Term)
  
  return(res)
}

#' Create Document-Term Matrix (DTM) as sparse matrix for Machine Learning
#'
#' @param clean_text_vec Character vector of cleaned text
#' @param min_term_freq Minimum frequency count threshold for terms
#' @return List containing `dtm` (Matrix) and `vocabulary`
create_dtm_matrix <- function(clean_text_vec, min_term_freq = 2) {
  corpus <- tm::VCorpus(tm::VectorSource(clean_text_vec))
  dtm <- tm::DocumentTermMatrix(corpus, control = list(bounds = list(global = c(min_term_freq, Inf))))
  
  # Remove sparse terms if DTM is very large
  if (ncol(dtm) > 1000) {
    dtm <- tm::removeSparseTerms(dtm, 0.99)
  }
  
  mat <- as.matrix(dtm)
  return(list(dtm_matrix = mat, vocabulary = colnames(mat)))
}
