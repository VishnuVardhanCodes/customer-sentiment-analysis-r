# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Text Preprocessing Pipeline (R/preprocessing.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
  library(tidytext)
  library(tm)
  library(SnowballC)
})

#' Clean a character vector of customer review/feedback text
#'
#' @param text_vector Character vector of raw text
#' @param remove_stopwords Logical, whether to filter standard English stop words
#' @param perform_stemming Logical, whether to apply Porter stemming
#' @return Character vector of cleaned and preprocessed text
clean_text <- function(text_vector, remove_stopwords = TRUE, perform_stemming = TRUE) {
  if (is.null(text_vector) || length(text_vector) == 0) {
    return(character(0))
  }
  
  # Replace NA values with empty string
  text_vec <- ifelse(is.na(text_vector), "", as.character(text_vector))
  
  # 1. Convert text to lowercase
  text_vec <- tolower(text_vec)
  
  # 2. Remove URLs (http, https, www)
  text_vec <- str_replace_all(text_vec, "https?://\\S+|www\\.\\S+", " ")
  
  # 3. Remove email addresses
  text_vec <- str_replace_all(text_vec, "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b", " ")
  
  # 4. Remove @mentions
  text_vec <- str_replace_all(text_vec, "@\\w+", " ")
  
  # 5. Handle hashtags (remove # sign but keep the tag word)
  text_vec <- str_replace_all(text_vec, "#(\\w+)", "\\1")
  
  # 6. Remove punctuation
  text_vec <- str_replace_all(text_vec, "[[:punct:]]", " ")
  
  # 7. Remove numbers
  text_vec <- str_replace_all(text_vec, "[[:digit:]]", " ")
  
  # 8. Remove non-ASCII and special characters
  text_vec <- str_replace_all(text_vec, "[^a-zA-Z\\s]", " ")
  
  # 9. Remove extra whitespace
  text_vec <- str_replace_all(text_vec, "\\s+", " ")
  text_vec <- str_trim(text_vec)
  
  # Process word-by-word for stop words and stemming
  cleaned_list <- lapply(text_vec, function(doc) {
    if (nchar(doc) == 0) return("")
    
    # Tokenize by space
    words <- unlist(strsplit(doc, "\\s+"))
    words <- words[nchar(words) > 1] # filter single-letter artifacts
    
    # 10. Remove Stop Words
    if (remove_stopwords && length(words) > 0) {
      stop_words_list <- tm::stopwords("english")
      words <- words[!(words %in% stop_words_list)]
    }
    
    # 12. Apply Stemming
    if (perform_stemming && length(words) > 0) {
      words <- SnowballC::wordStem(words, language = "english")
    }
    
    paste(words, collapse = " ")
  })
  
  return(as.character(unlist(cleaned_list)))
}

#' Preprocess a full dataset by adding a cleaned_text column
#'
#' @param df Data frame containing customer dataset
#' @param text_col Character, name of the text column
#' @param remove_stopwords Logical
#' @param perform_stemming Logical
#' @return Data frame with added column `cleaned_text`
preprocess_dataset <- function(df, text_col, remove_stopwords = TRUE, perform_stemming = TRUE) {
  if (!text_col %in% colnames(df)) {
    stop(paste("Specified text column", text_col, "does not exist in dataset."))
  }
  
  res_df <- df
  res_df$cleaned_text <- clean_text(
    df[[text_col]],
    remove_stopwords = remove_stopwords,
    perform_stemming = perform_stemming
  )
  
  return(res_df)
}
