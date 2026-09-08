# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Customer Insights & Opinion Analysis (R/insights.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
})

#' Automatically generate dynamic customer insights & recommendations
#'
#' @param sentiment_df Data frame containing `cleaned_text` and `Sentiment` columns
#' @param ml_summary List returned by `compare_all_models` (optional, if labeled ML ran)
#' @return List of insight strings, topics, and recommendations
generate_customer_insights <- function(sentiment_df, ml_summary = NULL) {
  if (is.null(sentiment_df) || !"Sentiment" %in% colnames(sentiment_df)) {
    return(list(
      Executive_Summary = "No dataset loaded or sentiment analysis not yet performed.",
      Positive_Themes   = character(0),
      Negative_Themes   = character(0),
      Common_Issues     = character(0),
      Recommendations   = character(0)
    ))
  }
  
  kpis <- calculate_sentiment_kpis(sentiment_df)
  
  # 1. Executive Summary Statement
  exec_summary <- sprintf(
    "Based on the analysis of %d customer reviews, overall sentiment is predominantly %s (%.1f%% Positive, %.1f%% Neutral, and %.1f%% Negative).",
    kpis$Total, kpis$Dominant, kpis$Pos_Pct, kpis$Neu_Pct, kpis$Neg_Pct
  )
  
  # 2. Extract Positive and Negative Word Frequencies
  pos_docs <- sentiment_df %>% filter(Sentiment == "Positive") %>% pull(cleaned_text)
  neg_docs <- sentiment_df %>% filter(Sentiment == "Negative") %>% pull(cleaned_text)
  
  pos_freq <- get_word_frequencies(pos_docs, top_n = 15)
  neg_freq <- get_word_frequencies(neg_docs, top_n = 15)
  
  pos_words <- if (nrow(pos_freq) > 0) pos_freq$Word else character(0)
  neg_words <- if (nrow(neg_freq) > 0) neg_freq$Word else character(0)
  
  # 3. Categorize Themes & Common Issues
  pos_themes <- head(pos_words, 5)
  neg_themes <- head(neg_words, 5)
  
  # Domain topic detection rules based on dataset keywords
  recommendations <- c()
  
  if (any(c("deliveri", "ship", "packag", "transit", "time", "delay") %in% neg_words)) {
    recommendations <- c(recommendations, 
      "Logistics Optimization: Delivery and shipping delays were frequently mentioned in negative customer feedback. Investigating carrier performance and dispatch speed is recommended.")
  }
  
  if (any(c("support", "servic", "agent", "ticket", "refund", "call", "phone") %in% neg_words)) {
    recommendations <- c(recommendations,
      "Customer Support Enhancement: Response times and refund resolution workflows generated notable dissatisfaction. Staff training and automated ticketing upgrades are advised.")
  }
  
  if (any(c("app", "checkout", "crash", "interfac", "fee", "price", "charg") %in% neg_words)) {
    recommendations <- c(recommendations,
      "Digital Platform & Pricing Audit: Users highlighted issues regarding mobile app stability or pricing transparency. Technical debugging of payment gateways and clear fee displays are recommended.")
  }
  
  if (any(c("qualiti", "defect", "flimsi", "broke", "scratched", "materi") %in% neg_words)) {
    recommendations <- c(recommendations,
      "Quality Assurance Review: Physical product durability and defect complaints were observed. Enhancing manufacturer quality control inspections is suggested.")
  }
  
  # Fallback general recommendation
  if (length(recommendations) == 0) {
    recommendations <- c(
      "Maintain High Satisfaction Standards: Continue capitalizing on positive feedback drivers while establishing proactive monitoring for emerging negative customer trends."
    )
  }
  
  # If ML model evaluation occurred, append ML summary insight
  ml_insight <- NULL
  if (!is.null(ml_summary) && !is.null(ml_summary$Best_Model)) {
    ml_insight <- sprintf(
      "Supervised Machine Learning Evaluation: %s achieved the highest performance with %.2f%% Accuracy and an F1-Score of %.2f%% on the test evaluation dataset.",
      ml_summary$Best_Model, ml_summary$Best_Accuracy * 100, ml_summary$Best_F1 * 100
    )
  }
  
  return(list(
    Executive_Summary = exec_summary,
    Positive_Themes   = pos_themes,
    Negative_Themes   = neg_themes,
    Common_Issues     = neg_themes,
    Recommendations   = recommendations,
    ML_Insight        = ml_insight
  ))
}
