# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Lexicon-Based Sentiment Analysis (backend/R/sentiment_analysis.R)
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
  if (is.null(sentiment_df) || !"Sentiment" %in% colnames(sentiment_df)) {
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

#' Analyze an individual customer review with explainability and buyer insights
#'
#' @param review_text Character string of review
#' @param product_name Character string of product name
#' @param product_category Character string of product category
#' @param original_rating Numeric or string rating (optional)
#' @param model_choice Character: "Auto", "Bing Lexicon", "SVM", "Naive Bayes", "KNN"
#' @param trained_models List of trained models in server environment
#' @return Comprehensive structured list containing sentiment, keywords, explanation, and buyer insight
analyze_single_review <- function(review_text, product_name = "Product", product_category = "General", 
                                  original_rating = NULL, model_choice = "Auto", trained_models = NULL) {
  if (is.null(review_text) || is.na(review_text) || nchar(trimws(review_text)) == 0) {
    stop("Review text is empty. Please provide a valid customer review.")
  }
  
  # Step 1: Preprocessing
  prep <- get_preprocessing_details(review_text, remove_stopwords = TRUE, perform_stemming = TRUE)
  cleaned_text <- prep$cleaned_text
  
  # Step 2: Lexicon Sentiment Scoring via Syuzhet (Bing)
  lex_score <- syuzhet::get_sentiment(cleaned_text, method = "bing")
  if (length(lex_score) == 0 || is.na(lex_score)) lex_score <- 0
  
  # Step 3: Extract sentiment-driving words using Bing lexicon
  tokens_raw <- tolower(unlist(strsplit(gsub("[[:punct:]0-9]", " ", review_text), "\\s+")))
  tokens_raw <- tokens_raw[nchar(tokens_raw) > 1]
  
  bing_lex <- tidytext::get_sentiments("bing")
  matched_lex <- bing_lex %>% filter(word %in% tokens_raw)
  
  pos_words <- unique(matched_lex %>% filter(sentiment == "positive") %>% pull(word))
  neg_words <- unique(matched_lex %>% filter(sentiment == "negative") %>% pull(word))
  
  # Detect mentioned product aspects directly from the review
  aspect_keywords <- list(
    "sound & audio quality" = c("sound", "audio", "bass", "treble", "volume", "music", "noise", "microphone", "mic"),
    "battery life & charging" = c("battery", "charge", "charging", "charger", "power", "drain"),
    "build quality & durability" = c("quality", "material", "durability", "build", "sturdy", "flimsy", "broke", "broken", "plastic"),
    "value for money" = c("price", "cost", "value", "money", "expensive", "cheap", "worth", "discount"),
    "delivery & packaging" = c("delivery", "shipping", "package", "arrived", "box", "dispatch"),
    "customer service" = c("support", "service", "refund", "return", "warranty", "agent"),
    "performance & display" = c("speed", "fast", "slow", "smooth", "lag", "performance", "display", "screen", "camera")
  )
  
  mentioned_aspects <- character(0)
  for (asp in names(aspect_keywords)) {
    if (any(aspect_keywords[[asp]] %in% tokens_raw)) {
      mentioned_aspects <- c(mentioned_aspects, asp)
    }
  }
  
  # Step 4: Determine Classification Method (ML vs Lexicon)
  sentiment <- "Neutral"
  confidence <- 75.0
  method <- "Bing Lexicon Polarity (R Syuzhet)"
  method_type <- "Lexicon-Based Scoring"
  
  # Check if user requested an ML model or Auto with trained model available
  ml_pred <- NULL
  if (model_choice %in% c("SVM", "Naive Bayes", "KNN") || (model_choice == "Auto" && !is.null(trained_models$vocabulary))) {
    req_model <- if (model_choice == "Auto") "SVM" else model_choice
    ml_pred <- predict_single_review_ml(cleaned_text, model_name = req_model, trained_models = trained_models)
  }
  
  if (!is.null(ml_pred)) {
    sentiment   <- ml_pred$sentiment
    confidence  <- ml_pred$confidence
    method      <- ml_pred$method
    method_type <- ml_pred$method_type
  } else {
    # Lexicon Classification
    if (lex_score > 0) {
      sentiment <- "Positive"
      confidence <- min(96.0, 72.0 + abs(lex_score) * 8.0)
    } else if (lex_score < 0) {
      sentiment <- "Negative"
      confidence <- min(96.0, 72.0 + abs(lex_score) * 8.0)
    } else {
      sentiment <- "Neutral"
      confidence <- 70.0
    }
    
    if (model_choice %in% c("SVM", "Naive Bayes", "KNN")) {
      method <- paste0(method, " [Fallback: ", model_choice, " model not yet trained on labeled data]")
    }
  }
  
  # Step 5: Generate Review Explanation grounded strictly in review content
  all_found_terms <- unique(c(pos_words, neg_words))
  terms_phrase <- if (length(all_found_terms) > 0) {
    paste0(" (keywords: '", paste(head(all_found_terms, 4), collapse = "', '"), "')")
  } else ""
  
  aspects_phrase <- if (length(mentioned_aspects) > 0) {
    paste0(" regarding ", paste(head(mentioned_aspects, 2), collapse = " and "))
  } else ""
  
  explanation <- ""
  if (sentiment == "Positive") {
    if (length(pos_words) > 0) {
      explanation <- sprintf("The review expresses customer satisfaction%s, using favorable terms like '%s'.", 
                             aspects_phrase, paste(head(pos_words, 3), collapse = "', '"))
    } else {
      explanation <- sprintf("The review conveys a favorable customer opinion%s with positive sentiment orientation.", aspects_phrase)
    }
  } else if (sentiment == "Negative") {
    if (length(neg_words) > 0) {
      explanation <- sprintf("The review reports customer dissatisfaction%s, pointing out concerns with terms like '%s'.", 
                             aspects_phrase, paste(head(neg_words, 3), collapse = "', '"))
    } else {
      explanation <- sprintf("The review highlights critical customer concerns or product deficiencies%s.", aspects_phrase)
    }
  } else {
    explanation <- sprintf("The review provides balanced or factual product observations%s without strong positive or negative language.", aspects_phrase)
  }
  
  # Step 6: Generate Potential Buyer Insight
  buyer_insight <- ""
  if (sentiment == "Positive") {
    aspect_text <- if (length(mentioned_aspects) > 0) paste(" (notably", paste(head(mentioned_aspects, 2), collapse = " and "), ")") else ""
    buyer_insight <- sprintf("The reviewer highlights favorable aspects of the product%s. This positive feedback supports consideration for purchase, though comparing multiple customer reviews is recommended before finalizing your decision.", aspect_text)
  } else if (sentiment == "Negative") {
    aspect_text <- if (length(mentioned_aspects) > 0) paste(" regarding", paste(head(mentioned_aspects, 2), collapse = " and ")) else ""
    buyer_insight <- sprintf("The reviewer reports specific issues or dissatisfaction%s. Potential buyers may want to weigh these reported concerns against alternatives before purchasing.", aspect_text)
  } else {
    buyer_insight <- "The review offers informational or neutral commentary but does not provide strong approval or disapproval. Consulting additional customer reviews will provide a clearer picture for purchasing."
  }
  
  return(list(
    product_name = if (is.null(product_name) || nchar(trimws(product_name)) == 0) "Product" else product_name,
    product_category = if (is.null(product_category) || nchar(trimws(product_category)) == 0) "General" else product_category,
    original_rating = original_rating,
    original_review = review_text,
    cleaned_review = cleaned_text,
    predicted_sentiment = sentiment,
    sentiment_score = lex_score,
    confidence_score = round(confidence, 1),
    analysis_method = method,
    analysis_method_type = method_type,
    positive_keywords = pos_words,
    negative_keywords = neg_words,
    mentioned_aspects = mentioned_aspects,
    important_keywords = unique(c(pos_words, neg_words, head(tokens_raw[nchar(tokens_raw) > 3], 6))),
    explanation = explanation,
    potential_buyer_insight = buyer_insight,
    preprocessing_stats = list(
      words_before = prep$words_before,
      words_after = prep$words_after,
      stopwords_removed = prep$stopwords_removed,
      tokens = prep$tokens
    )
  ))
}

#' Analyze multiple reviews for the same product and compute comparison consensus
#'
#' @param reviews_list List of review objects (each containing text and optional rating)
#' @param product_name Product title
#' @param product_category Product category
#' @param model_choice Model algorithm selection
#' @param trained_models Trained model environment
#' @return List with individual review analyses and aggregated product consensus
analyze_multiple_reviews <- function(reviews_list, product_name = "Product", product_category = "General", 
                                     model_choice = "Auto", trained_models = NULL) {
  if (is.null(reviews_list)) {
    stop("No reviews provided for comparison.")
  }
  
  # Normalize if passed as data.frame (from jsonlite array of objects) or nested list
  normalized_list <- list()
  if (is.data.frame(reviews_list)) {
    txt_col <- if ("review_text" %in% names(reviews_list)) "review_text" else if ("text" %in% names(reviews_list)) "text" else names(reviews_list)[1]
    rat_col <- if ("rating" %in% names(reviews_list)) "rating" else if ("original_rating" %in% names(reviews_list)) "original_rating" else NULL
    for (row_idx in seq_len(nrow(reviews_list))) {
      t_val <- as.character(reviews_list[row_idx, txt_col])
      r_val <- if (!is.null(rat_col) && !is.na(reviews_list[row_idx, rat_col])) as.numeric(reviews_list[row_idx, rat_col]) else NULL
      normalized_list[[length(normalized_list) + 1]] <- list(text = t_val, rating = r_val)
    }
  } else if (is.list(reviews_list)) {
    for (i in seq_along(reviews_list)) {
      item <- reviews_list[[i]]
      if (is.list(item)) {
        t_val <- if (!is.null(item$review_text)) as.character(item$review_text) else if (!is.null(item$text)) as.character(item$text) else ""
        r_val <- if (!is.null(item$rating) && item$rating != "") suppressWarnings(as.numeric(item$rating)) else if (!is.null(item$original_rating) && item$original_rating != "") suppressWarnings(as.numeric(item$original_rating)) else NULL
        normalized_list[[length(normalized_list) + 1]] <- list(text = t_val, rating = r_val)
      } else {
        normalized_list[[length(normalized_list) + 1]] <- list(text = as.character(item), rating = NULL)
      }
    }
  } else if (is.character(reviews_list)) {
    for (txt in reviews_list) {
      normalized_list[[length(normalized_list) + 1]] <- list(text = as.character(txt), rating = NULL)
    }
  }
  
  if (length(normalized_list) == 0) {
    stop("No reviews provided for comparison.")
  }
  
  results <- list()
  sentiments <- character(0)
  ratings <- numeric(0)
  all_pos_words <- character(0)
  all_neg_words <- character(0)
  all_aspects <- character(0)
  
  for (i in seq_along(normalized_list)) {
    item <- normalized_list[[i]]
    r_text <- item$text
    r_rating <- item$rating
    
    if (is.null(r_text) || length(r_text) == 0 || nchar(trimws(r_text)) == 0) next
    
    res <- analyze_single_review(
      review_text = r_text,
      product_name = product_name,
      product_category = product_category,
      original_rating = r_rating,
      model_choice = model_choice,
      trained_models = trained_models
    )
    
    results[[length(results) + 1]] <- res
    sentiments <- c(sentiments, res$predicted_sentiment)
    if (!is.null(r_rating) && !is.na(r_rating)) ratings <- c(ratings, r_rating)
    all_pos_words <- c(all_pos_words, res$positive_keywords)
    all_neg_words <- c(all_neg_words, res$negative_keywords)
    all_aspects <- c(all_aspects, res$mentioned_aspects)
  }

  
  total <- length(sentiments)
  if (total == 0) {
    stop("None of the submitted reviews contained valid text.")
  }
  
  pos_cnt <- sum(sentiments == "Positive")
  neu_cnt <- sum(sentiments == "Neutral")
  neg_cnt <- sum(sentiments == "Negative")
  
  pos_pct <- round((pos_cnt / total) * 100, 1)
  neu_pct <- round((neu_cnt / total) * 100, 1)
  neg_pct <- round((neg_cnt / total) * 100, 1)
  
  dominant <- if (pos_cnt >= neu_cnt && pos_cnt >= neg_cnt) "Positive" else if (neg_cnt >= pos_cnt && neg_cnt >= neu_cnt) "Negative" else "Neutral"
  avg_rating <- if (length(ratings) > 0) round(mean(ratings), 1) else NULL
  
  # Top recurring positive & negative keywords
  top_pos <- names(sort(table(all_pos_words), decreasing = TRUE))[seq_len(min(5, length(unique(all_pos_words))))]
  top_neg <- names(sort(table(all_neg_words), decreasing = TRUE))[seq_len(min(5, length(unique(all_neg_words))))]
  top_aspects <- names(sort(table(all_aspects), decreasing = TRUE))[seq_len(min(4, length(unique(all_aspects))))]
  
  # Multi-review buyer synthesis
  synthesis <- sprintf(
    "Based on %d analyzed reviews for '%s', overall customer sentiment is %.1f%% Positive, %.1f%% Neutral, and %.1f%% Negative.",
    total, product_name, pos_pct, neu_pct, neg_pct
  )
  if (length(top_pos) > 0) {
    synthesis <- paste(synthesis, sprintf("Repeated product strengths mentioned by buyers include: %s.", paste(top_pos, collapse = ", ")))
  }
  if (length(top_neg) > 0) {
    synthesis <- paste(synthesis, sprintf("Commonly reported complaints or issues include: %s.", paste(top_neg, collapse = ", ")))
  }
  
  return(list(
    product_name = product_name,
    product_category = product_category,
    total_reviews = total,
    pos_count = pos_cnt,
    neu_count = neu_cnt,
    neg_count = neg_cnt,
    pos_pct = pos_pct,
    neu_pct = neu_pct,
    neg_pct = neg_pct,
    average_rating = avg_rating,
    dominant_sentiment = dominant,
    top_positive_aspects = if (is.null(top_pos)) character(0) else top_pos,
    top_negative_aspects = if (is.null(top_neg)) character(0) else top_neg,
    top_mentioned_topics = if (is.null(top_aspects)) character(0) else top_aspects,
    buyer_synthesis = synthesis,
    reviews = results
  ))
}

#' Calculate product-level summaries from bulk analyzed dataset
#'
#' @param df Data frame with sentiment results
#' @param product_col Name of product column
#' @param rating_col Optional rating column
#' @return Data frame of product-wise sentiment aggregations
calculate_product_summaries <- function(df, product_col, rating_col = NULL) {
  if (is.null(df) || !product_col %in% colnames(df) || !"Sentiment" %in% colnames(df)) {
    return(NULL)
  }
  
  grouped <- df %>%
    filter(!is.na(.data[[product_col]]), nchar(trimws(as.character(.data[[product_col]]))) > 0) %>%
    group_by(Product = as.character(.data[[product_col]])) %>%
    summarise(
      Total_Reviews = n(),
      Pos_Count = sum(Sentiment == "Positive", na.rm = TRUE),
      Neu_Count = sum(Sentiment == "Neutral", na.rm = TRUE),
      Neg_Count = sum(Sentiment == "Negative", na.rm = TRUE),
      Pos_Pct = round((sum(Sentiment == "Positive", na.rm = TRUE) / n()) * 100, 1),
      Neu_Pct = round((sum(Sentiment == "Neutral", na.rm = TRUE) / n()) * 100, 1),
      Neg_Pct = round((sum(Sentiment == "Negative", na.rm = TRUE) / n()) * 100, 1),
      Avg_Rating = if (!is.null(rating_col) && rating_col %in% colnames(df)) {
        round(mean(suppressWarnings(as.numeric(.data[[rating_col]])), na.rm = TRUE), 2)
      } else NA_real_,
      .groups = "drop"
    ) %>%
    mutate(
      Dominant_Sentiment = case_when(
        Pos_Count >= Neu_Count & Pos_Count >= Neg_Count ~ "Positive",
        Neg_Count >= Pos_Count & Neg_Count >= Neu_Count ~ "Negative",
        TRUE ~ "Neutral"
      )
    ) %>%
    arrange(desc(Total_Reviews))
  
  return(grouped)
}

#' Calculate category-level summaries from bulk analyzed dataset
#'
#' @param df Data frame with sentiment results
#' @param category_col Name of category column
#' @return Data frame of category-wise sentiment aggregations
calculate_category_summaries <- function(df, category_col) {
  if (is.null(df) || !category_col %in% colnames(df) || !"Sentiment" %in% colnames(df)) {
    return(NULL)
  }
  
  grouped <- df %>%
    filter(!is.na(.data[[category_col]]), nchar(trimws(as.character(.data[[category_col]]))) > 0) %>%
    group_by(Category = as.character(.data[[category_col]])) %>%
    summarise(
      Total_Reviews = n(),
      Pos_Count = sum(Sentiment == "Positive", na.rm = TRUE),
      Neu_Count = sum(Sentiment == "Neutral", na.rm = TRUE),
      Neg_Count = sum(Sentiment == "Negative", na.rm = TRUE),
      Pos_Pct = round((sum(Sentiment == "Positive", na.rm = TRUE) / n()) * 100, 1),
      Neu_Pct = round((sum(Sentiment == "Neutral", na.rm = TRUE) / n()) * 100, 1),
      Neg_Pct = round((sum(Sentiment == "Negative", na.rm = TRUE) / n()) * 100, 1),
      .groups = "drop"
    ) %>%
    arrange(desc(Total_Reviews))
  
  return(grouped)
}
