# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Backend R Plumber REST API Server (backend/plumber.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(plumber)
  library(jsonlite)
  library(dplyr)
  library(readr)
  library(stringr)
})

# Source R Analytics modules
source("R/helpers.R")
source("R/validation.R")
source("R/preprocessing.R")
source("R/text_mining.R")
source("R/sentiment_analysis.R")
source("R/machine_learning.R")
source("R/evaluation.R")
source("R/visualization.R")
source("R/insights.R")

ensure_dir("outputs")
ensure_dir("data/sample")

# Persistent state environment for current analysis session
state <- new.env()

reset_state_env <- function() {
  state$raw_df <- NULL
  state$text_col <- NULL
  state$label_col <- NULL
  state$filename <- NULL
  state$file_size <- 0
  state$validation <- NULL
  state$preprocessed_df <- NULL
  state$preprocessing_stats <- NULL
  state$text_mining <- NULL
  state$sentiment_df <- NULL
  state$sentiment_kpis <- NULL
  state$sentiment_words <- NULL
  state$ml_data <- NULL
  state$ml_preds <- list()
  state$ml_summary <- NULL
  state$insights <- NULL
  state$status <- list(
    uploaded = FALSE,
    validated = FALSE,
    preprocessed = FALSE,
    text_mined = FALSE,
    sentiment_analyzed = FALSE,
    ml_trained = FALSE,
    evaluated = FALSE,
    insights_generated = FALSE,
    is_labeled = FALSE,
    is_demo = FALSE
  )
}

# Initialize state
reset_state_env()

#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  
  plumber::forward()
}

#* Check API Health Status
#* @get /health
function() {
  list(
    success = TRUE,
    message = "R Analytics API active",
    version = "1.0",
    timestamp = Sys.time(),
    R_version = R.version.string,
    status = state$status
  )
}

#* Upload CSV/TXT customer dataset
#* @post /upload
function(req, res) {
  tryCatch({
    post_data <- req$body
    
    df <- NULL
    fname <- "uploaded_dataset.csv"
    fsize <- 0
    
    if (!is.null(req$postBody) && nchar(req$postBody) > 0) {
      json_body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) NULL)
      if (!is.null(json_body) && !is.null(json_body$file_content)) {
        fname <- if (!is.null(json_body$filename)) json_body$filename else "uploaded.csv"
        raw_text <- json_body$file_content
        fsize <- nchar(raw_text)
        df <- readr::read_csv(raw_text, show_col_types = FALSE)
      }
    }
    
    if (is.null(df) && !is.null(post_data)) {
      for (item in post_data) {
        if (inherits(item, "raw") || is.list(item)) {
          if (!is.null(item$filename)) fname <- item$filename
          if (!is.null(item$datapath)) {
            fsize <- file.info(item$datapath)$size
            df <- readr::read_csv(item$datapath, show_col_types = FALSE)
            break
          } else if (!is.null(item$value)) {
            df <- readr::read_csv(item$value, show_col_types = FALSE)
            break
          }
        }
      }
    }
    
    if (is.null(df) || nrow(df) == 0) {
      return(api_response(FALSE, "Failed to parse CSV/TXT file or file is empty.", error_code = "INVALID_FILE"))
    }
    
    reset_state_env()
    state$raw_df <- df
    state$filename <- fname
    state$file_size <- fsize
    
    state$text_col <- detect_text_column(df)
    state$label_col <- detect_label_column(df)
    
    state$status$uploaded <- TRUE
    state$status$is_labeled <- !is.null(state$label_col)
    
    state$validation <- validate_dataset(df, state$text_col, state$label_col)
    state$status$validated <- TRUE
    
    api_response(TRUE, "Dataset uploaded and parsed successfully.", list(
      filename = fname,
      file_size = fsize,
      rows = nrow(df),
      columns = ncol(df),
      column_names = colnames(df),
      text_column = state$text_col,
      label_column = state$label_col,
      is_labeled = state$status$is_labeled,
      preview = head(df, 15)
    ))
  }, error = function(e) {
    api_response(FALSE, paste("Error uploading file:", e$message), error_code = "UPLOAD_ERROR")
  })
}

#* Validate dataset quality and select target columns
#* @post /validate
function(req, res) {
  if (is.null(state$raw_df)) {
    return(api_response(FALSE, "No dataset loaded. Please upload a dataset first.", error_code = "NO_DATASET"))
  }
  
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) list())
  if (!is.null(body$text_column) && body$text_column %in% colnames(state$raw_df)) {
    state$text_col <- body$text_column
  }
  if (!is.null(body$label_column)) {
    if (body$label_column %in% colnames(state$raw_df)) {
      state$label_col <- body$label_column
    } else if (body$label_column == "" || body$label_column == "none") {
      state$label_col <- NULL
    }
  }
  
  state$validation <- validate_dataset(state$raw_df, state$text_col, state$label_col)
  state$status$validated <- TRUE
  state$status$is_labeled <- !is.null(state$label_col)
  
  api_response(TRUE, "Data validation completed.", state$validation)
}

#* Preprocess text
#* @post /preprocess
function(req, res) {
  if (is.null(state$raw_df) || is.null(state$text_col)) {
    return(api_response(FALSE, "No text column selected for preprocessing.", error_code = "NO_TEXT_COL"))
  }
  
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) list())
  remove_stopwords <- if (!is.null(body$remove_stopwords)) as.logical(body$remove_stopwords) else TRUE
  perform_stemming <- if (!is.null(body$perform_stemming)) as.logical(body$perform_stemming) else TRUE
  
  raw_text_vec <- as.character(state$raw_df[[state$text_col]])
  words_before <- sum(sapply(strsplit(raw_text_vec, "\\s+"), length))
  
  state$preprocessed_df <- preprocess_dataset(
    state$raw_df,
    text_col = state$text_col,
    remove_stopwords = remove_stopwords,
    perform_stemming = perform_stemming
  )
  
  clean_vec <- state$preprocessed_df$cleaned_text
  words_after <- sum(sapply(strsplit(clean_vec, "\\s+"), length))
  stopwords_removed <- max(0, words_before - words_after)
  
  state$preprocessing_stats <- list(
    records_processed = length(clean_vec),
    words_before = words_before,
    words_after = words_after,
    stopwords_removed = stopwords_removed,
    remove_stopwords = remove_stopwords,
    perform_stemming = perform_stemming
  )
  
  state$status$preprocessed <- TRUE
  
  preview_df <- state$preprocessed_df %>%
    select(all_of(c(state$text_col, "cleaned_text"))) %>%
    rename(Original_Review = !!state$text_col, Processed_Review = cleaned_text) %>%
    head(30)
  
  api_response(TRUE, "Text preprocessing completed.", list(
    stats = state$preprocessing_stats,
    preview = preview_df
  ))
}

#* Perform Text Mining
#* @post /text-mining
function(req, res) {
  if (is.null(state$preprocessed_df)) {
    return(api_response(FALSE, "Preprocessing must be run prior to text mining.", error_code = "NOT_PREPROCESSED"))
  }
  
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) list())
  top_n <- if (!is.null(body$top_n)) as.integer(body$top_n) else 50
  
  clean_vec <- state$preprocessed_df$cleaned_text
  freq_df   <- get_word_frequencies(clean_vec, top_n = top_n)
  tfidf_df  <- compute_tfidf(clean_vec)
  kw_df     <- extract_keywords(tfidf_df, top_n = 20)
  dtm_info  <- create_dtm_matrix(clean_vec)
  
  state$text_mining <- list(
    frequencies = freq_df,
    tfidf = tfidf_df,
    keywords = kw_df,
    vocabulary_count = length(dtm_info$vocabulary),
    unique_terms = nrow(freq_df)
  )
  
  state$status$text_mined <- TRUE
  
  api_response(TRUE, "Text mining analysis completed.", state$text_mining)
}

#* Run Sentiment Analysis
#* @post /sentiment
function(req, res) {
  if (is.null(state$preprocessed_df)) {
    return(api_response(FALSE, "Preprocessing required before running sentiment analysis.", error_code = "NOT_PREPROCESSED"))
  }
  
  state$sentiment_df    <- analyze_lexicon_sentiment(state$preprocessed_df, text_col = state$text_col)
  state$sentiment_kpis  <- calculate_sentiment_kpis(state$sentiment_df)
  state$sentiment_words <- get_sentiment_word_counts(state$sentiment_df$cleaned_text, top_n = 20)
  
  state$status$sentiment_analyzed <- TRUE
  
  review_results <- state$sentiment_df %>%
    mutate(Row_ID = row_number()) %>%
    select(Row_ID, all_of(state$text_col), cleaned_text, Sentiment_Score, Sentiment, everything())
  
  api_response(TRUE, "Sentiment analysis completed.", list(
    kpis = state$sentiment_kpis,
    sentiment_words = state$sentiment_words,
    reviews = head(review_results, 100),
    is_labeled = state$status$is_labeled
  ))
}

#* Train Naive Bayes Machine Learning Model
#* @post /train/naive-bayes
function(req, res) {
  if (is.null(state$status$is_labeled) || !state$status$is_labeled) {
    return(api_response(FALSE, "Supervised machine learning requires a genuine sentiment label column.", error_code = "MISSING_LABEL"))
  }
  if (is.null(state$preprocessed_df)) {
    return(api_response(FALSE, "Preprocessed dataset required for model training.", error_code = "NOT_PREPROCESSED"))
  }
  
  tryCatch({
    if (is.null(state$ml_data)) {
      labels <- state$preprocessed_df[[state$label_col]]
      state$ml_data <- prepare_ml_datasets(state$preprocessed_df$cleaned_text, labels = labels)
    }
    
    nb_preds <- run_naive_bayes(state$ml_data$train_x, state$ml_data$train_y, state$ml_data$test_x)
    state$ml_preds[["Naive Bayes"]] <- nb_preds
    
    eval_res <- evaluate_model_performance(state$ml_data$test_y, nb_preds)
    
    api_response(TRUE, "Naive Bayes classifier trained successfully.", list(
      model = "Naive Bayes",
      metrics = list(
        Accuracy = eval_res$Accuracy,
        Precision = eval_res$Precision,
        Recall = eval_res$Recall,
        F1_Score = eval_res$F1_Score
      ),
      confusion_matrix = eval_res$Confusion_Matrix_DF
    ))
  }, error = function(e) {
    api_response(FALSE, paste("Naive Bayes training error:", e$message), error_code = "TRAIN_ERROR")
  })
}

#* Train Support Vector Machine (SVM) Model
#* @post /train/svm
function(req, res) {
  if (is.null(state$status$is_labeled) || !state$status$is_labeled) {
    return(api_response(FALSE, "Supervised machine learning requires a genuine sentiment label column.", error_code = "MISSING_LABEL"))
  }
  if (is.null(state$preprocessed_df)) {
    return(api_response(FALSE, "Preprocessed dataset required for model training.", error_code = "NOT_PREPROCESSED"))
  }
  
  tryCatch({
    if (is.null(state$ml_data)) {
      labels <- state$preprocessed_df[[state$label_col]]
      state$ml_data <- prepare_ml_datasets(state$preprocessed_df$cleaned_text, labels = labels)
    }
    
    svm_preds <- run_svm(state$ml_data$train_x, state$ml_data$train_y, state$ml_data$test_x)
    state$ml_preds[["SVM"]] <- svm_preds
    
    eval_res <- evaluate_model_performance(state$ml_data$test_y, svm_preds)
    
    api_response(TRUE, "Support Vector Machine (SVM) trained successfully.", list(
      model = "SVM",
      metrics = list(
        Accuracy = eval_res$Accuracy,
        Precision = eval_res$Precision,
        Recall = eval_res$Recall,
        F1_Score = eval_res$F1_Score
      ),
      confusion_matrix = eval_res$Confusion_Matrix_DF
    ))
  }, error = function(e) {
    api_response(FALSE, paste("SVM training error:", e$message), error_code = "TRAIN_ERROR")
  })
}

#* Train K-Nearest Neighbors (KNN) Model
#* @post /train/knn
function(req, res) {
  if (is.null(state$status$is_labeled) || !state$status$is_labeled) {
    return(api_response(FALSE, "Supervised machine learning requires a genuine sentiment label column.", error_code = "MISSING_LABEL"))
  }
  if (is.null(state$preprocessed_df)) {
    return(api_response(FALSE, "Preprocessed dataset required for model training.", error_code = "NOT_PREPROCESSED"))
  }
  
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) list())
  k <- if (!is.null(body$k)) as.integer(body$k) else 5
  
  tryCatch({
    if (is.null(state$ml_data)) {
      labels <- state$preprocessed_df[[state$label_col]]
      state$ml_data <- prepare_ml_datasets(state$preprocessed_df$cleaned_text, labels = labels)
    }
    
    knn_preds <- run_knn(state$ml_data$train_x, state$ml_data$train_y, state$ml_data$test_x, k = k)
    state$ml_preds[["KNN"]] <- knn_preds
    
    eval_res <- evaluate_model_performance(state$ml_data$test_y, knn_preds)
    
    api_response(TRUE, "K-Nearest Neighbors (KNN) trained successfully.", list(
      model = "KNN",
      metrics = list(
        Accuracy = eval_res$Accuracy,
        Precision = eval_res$Precision,
        Recall = eval_res$Recall,
        F1_Score = eval_res$F1_Score
      ),
      confusion_matrix = eval_res$Confusion_Matrix_DF
    ))
  }, error = function(e) {
    api_response(FALSE, paste("KNN training error:", e$message), error_code = "TRAIN_ERROR")
  })
}

#* Train all supervised machine learning models (NB, SVM, KNN)
#* @post /train/all
function(req, res) {
  if (is.null(state$status$is_labeled) || !state$status$is_labeled) {
    return(api_response(FALSE, "Supervised machine learning models require genuine sentiment labels.", error_code = "MISSING_LABEL"))
  }
  if (is.null(state$preprocessed_df)) {
    return(api_response(FALSE, "Preprocessed dataset required for model training.", error_code = "NOT_PREPROCESSED"))
  }
  
  tryCatch({
    labels <- state$preprocessed_df[[state$label_col]]
    state$ml_data <- prepare_ml_datasets(state$preprocessed_df$cleaned_text, labels = labels)
    
    ml_eval <- execute_all_ml_models(state$ml_data)
    state$ml_preds <- ml_eval$predictions
    
    state$ml_summary <- compare_all_models(ml_eval)
    state$status$ml_trained <- TRUE
    state$status$evaluated  <- TRUE
    
    api_response(TRUE, "All machine learning models trained and evaluated successfully.", list(
      comparison_table = state$ml_summary$Comparison_Table,
      best_model = state$ml_summary$Best_Model,
      best_accuracy = state$ml_summary$Best_Accuracy,
      best_f1 = state$ml_summary$Best_F1,
      confusion_matrices = state$ml_summary$Confusion_Matrices
    ))
  }, error = function(e) {
    api_response(FALSE, paste("Error training ML models:", e$message), error_code = "ML_TRAIN_ERROR")
  })
}

#* Get Model Evaluation Results
#* @post /evaluate
#* @get /evaluate
function(req, res) {
  if (is.null(state$ml_summary)) {
    if (!is.null(state$status$is_labeled) && state$status$is_labeled && length(state$ml_preds) > 0 && !is.null(state$ml_data)) {
      state$ml_summary <- compare_all_models(list(actual = state$ml_data$test_y, predictions = state$ml_preds))
      state$status$evaluated <- TRUE
    } else {
      return(api_response(TRUE, "No model evaluation data available yet. Run model training first.", NULL))
    }
  }
  
  api_response(TRUE, "Model evaluation summary retrieved.", list(
    comparison_table = state$ml_summary$Comparison_Table,
    best_model = state$ml_summary$Best_Model,
    best_accuracy = state$ml_summary$Best_Accuracy,
    best_f1 = state$ml_summary$Best_F1,
    confusion_matrices = state$ml_summary$Confusion_Matrices
  ))
}

#* Get visualization chart data formatted for React UI
#* @get /visualization-data
function(req, res) {
  viz_data <- list()
  
  if (!is.null(state$sentiment_df)) {
    viz_data$sentiment_distribution <- state$sentiment_df %>%
      count(Sentiment) %>%
      mutate(Percentage = round((n / sum(n)) * 100, 1))
  }
  
  if (!is.null(state$text_mining)) {
    viz_data$word_frequencies <- head(state$text_mining$frequencies, 20)
    viz_data$tfidf_terms       <- head(state$text_mining$tfidf, 20)
    viz_data$word_cloud         <- head(state$text_mining$frequencies, 50)
  }
  
  if (!is.null(state$ml_summary)) {
    viz_data$model_comparison    <- state$ml_summary$Comparison_Table
    viz_data$confusion_matrices  <- state$ml_summary$Confusion_Matrices
  }
  
  api_response(TRUE, "Visualization data generated.", viz_data)
}

#* Get Dynamic Customer Insights & Recommendations
#* @get /insights
function(req, res) {
  if (is.null(state$sentiment_df)) {
    return(api_response(FALSE, "Sentiment analysis must be performed prior to generating insights.", error_code = "NO_SENTIMENT"))
  }
  
  state$insights <- generate_customer_insights(state$sentiment_df, state$ml_summary)
  state$status$insights_generated <- TRUE
  
  api_response(TRUE, "Customer insights generated successfully.", state$insights)
}

#* Get Overall Analysis Results & Pipeline Status
#* @get /results
function(req, res) {
  best_model_name <- if (!is.null(state$ml_summary)) state$ml_summary$Best_Model else "--"
  best_model_acc  <- if (!is.null(state$ml_summary)) paste0(round(state$ml_summary$Best_Accuracy * 100, 1), "%") else "--"
  
  unique_terms <- if (!is.null(state$text_mining)) state$text_mining$unique_terms else 0
  avg_sentiment <- if (!is.null(state$sentiment_df)) round(mean(state$sentiment_df$Sentiment_Score, na.rm = TRUE), 2) else "--"
  
  api_response(TRUE, "Current analysis state summary.", list(
    status = state$status,
    filename = state$filename,
    total_reviews = if (!is.null(state$raw_df)) nrow(state$raw_df) else 0,
    dominant_sentiment = if (!is.null(state$sentiment_kpis)) state$sentiment_kpis$Dominant else "--",
    best_model = best_model_name,
    best_accuracy = best_model_acc,
    unique_terms = unique_terms,
    avg_sentiment = avg_sentiment,
    kpis = state$sentiment_kpis,
    available_downloads = list(
      processed = !is.null(state$preprocessed_df),
      sentiment = !is.null(state$sentiment_df),
      models    = !is.null(state$ml_summary),
      insights  = !is.null(state$insights),
      complete  = !is.null(state$sentiment_df)
    )
  ))
}

#* Download processed dataset CSV
#* @get /download/processed
function(req, res) {
  if (is.null(state$preprocessed_df)) {
    return(api_response(FALSE, "Processed dataset not available.", error_code = "NOT_AVAILABLE"))
  }
  
  file_path <- file.path("outputs", "processed_dataset.csv")
  readr::write_csv(state$preprocessed_df, file_path)
  
  res$setHeader("Content-Type", "text/csv")
  res$setHeader("Content-Disposition", 'attachment; filename="processed_dataset.csv"')
  include_file(file_path, res, "text/csv")
}

#* Download sentiment results CSV
#* @get /download/sentiment
function(req, res) {
  if (is.null(state$sentiment_df)) {
    return(api_response(FALSE, "Sentiment analysis results not available.", error_code = "NOT_AVAILABLE"))
  }
  
  file_path <- file.path("outputs", "sentiment_results.csv")
  readr::write_csv(state$sentiment_df, file_path)
  
  res$setHeader("Content-Type", "text/csv")
  res$setHeader("Content-Disposition", 'attachment; filename="sentiment_results.csv"')
  include_file(file_path, res, "text/csv")
}

#* Download model performance CSV
#* @get /download/models
function(req, res) {
  if (is.null(state$ml_summary)) {
    return(api_response(FALSE, "Model performance comparison not available.", error_code = "NOT_AVAILABLE"))
  }
  
  file_path <- file.path("outputs", "model_performance.csv")
  readr::write_csv(state$ml_summary$Comparison_Table, file_path)
  
  res$setHeader("Content-Type", "text/csv")
  res$setHeader("Content-Disposition", 'attachment; filename="model_performance.csv"')
  include_file(file_path, res, "text/csv")
}

#* Download insights report TXT
#* @get /download/insights
function(req, res) {
  if (is.null(state$insights)) {
    return(api_response(FALSE, "Customer insights report not available.", error_code = "NOT_AVAILABLE"))
  }
  
  ins <- state$insights
  report_lines <- c(
    "=================================================================",
    "LG9 - CUSTOMER SENTIMENT ANALYSIS EXECUTIVE REPORT",
    "=================================================================",
    paste("Generated On:", Sys.time()),
    paste("Dataset File:", ifelse(is.null(state$filename), "Unknown", state$filename)),
    "",
    "--- EXECUTIVE SUMMARY ---",
    ins$Executive_Summary,
    "",
    "--- POSITIVE THEMES & DRIVERS ---",
    paste("-", ins$Positive_Themes),
    "",
    "--- NEGATIVE THEMES & COMPLAINTS ---",
    paste("-", ins$Negative_Themes),
    "",
    "--- STRATEGIC RECOMMENDATIONS ---",
    paste("1.", ins$Recommendations),
    ""
  )
  if (!is.null(ins$ML_Insight)) {
    report_lines <- c(report_lines, "--- MACHINE LEARNING EVALUATION ---", ins$ML_Insight, "")
  }
  
  file_path <- file.path("outputs", "customer_insights_report.txt")
  writeLines(report_lines, file_path)
  
  res$setHeader("Content-Type", "text/plain")
  res$setHeader("Content-Disposition", 'attachment; filename="customer_insights_report.txt"')
  include_file(file_path, res, "text/plain")
}

#* Download complete combined analysis CSV
#* @get /download/complete
function(req, res) {
  if (is.null(state$sentiment_df)) {
    return(api_response(FALSE, "Analysis results not available.", error_code = "NOT_AVAILABLE"))
  }
  
  file_path <- file.path("outputs", "complete_analysis_results.csv")
  readr::write_csv(state$sentiment_df, file_path)
  
  res$setHeader("Content-Type", "text/csv")
  res$setHeader("Content-Disposition", 'attachment; filename="complete_analysis_results.csv"')
  include_file(file_path, res, "text/csv")
}

#* Reset Analysis Session
#* @post /reset
function(req, res) {
  reset_state_env()
  api_response(TRUE, "Analysis session has been reset successfully.", list(status = state$status))
}

#* Run Full Supervised Labeled Demo Workflow
#* @post /demo/labeled
function(req, res) {
  reset_state_env()
  sample_path <- file.path("data", "sample", "sample_reviews.csv")
  if (!file.exists(sample_path)) {
    sample_path <- file.path("..", "data", "sample", "sample_reviews.csv")
  }
  
  df <- readr::read_csv(sample_path, show_col_types = FALSE)
  state$raw_df <- df
  state$filename <- "sample_reviews.csv"
  state$file_size <- file.info(sample_path)$size
  state$text_col <- "review_text"
  state$label_col <- "sentiment"
  
  state$status$uploaded <- TRUE
  state$status$is_labeled <- TRUE
  state$status$is_demo <- TRUE
  
  # Step 1: Validate
  state$validation <- validate_dataset(df, state$text_col, state$label_col)
  state$status$validated <- TRUE
  
  # Step 2: Preprocess
  state$preprocessed_df <- preprocess_dataset(df, state$text_col, remove_stopwords = TRUE, perform_stemming = TRUE)
  clean_vec <- state$preprocessed_df$cleaned_text
  words_before <- sum(sapply(strsplit(as.character(df$review_text), "\\s+"), length))
  words_after <- sum(sapply(strsplit(clean_vec, "\\s+"), length))
  state$preprocessing_stats <- list(
    records_processed = length(clean_vec),
    words_before = words_before,
    words_after = words_after,
    stopwords_removed = max(0, words_before - words_after),
    remove_stopwords = TRUE,
    perform_stemming = TRUE
  )
  state$status$preprocessed <- TRUE
  
  # Step 3: Text Mining
  freq_df  <- get_word_frequencies(clean_vec, top_n = 50)
  tfidf_df <- compute_tfidf(clean_vec)
  kw_df    <- extract_keywords(tfidf_df, top_n = 20)
  dtm_info <- create_dtm_matrix(clean_vec)
  state$text_mining <- list(
    frequencies = freq_df,
    tfidf = tfidf_df,
    keywords = kw_df,
    vocabulary_count = length(dtm_info$vocabulary),
    unique_terms = nrow(freq_df)
  )
  state$status$text_mined <- TRUE
  
  # Step 4: Sentiment
  state$sentiment_df    <- analyze_lexicon_sentiment(state$preprocessed_df, text_col = state$text_col)
  state$sentiment_kpis  <- calculate_sentiment_kpis(state$sentiment_df)
  state$sentiment_words <- get_sentiment_word_counts(state$sentiment_df$cleaned_text, top_n = 20)
  state$status$sentiment_analyzed <- TRUE
  
  # Step 5: Supervised ML (NB, SVM, KNN)
  labels <- state$preprocessed_df[[state$label_col]]
  state$ml_data <- prepare_ml_datasets(state$preprocessed_df$cleaned_text, labels = labels)
  ml_eval <- execute_all_ml_models(state$ml_data)
  state$ml_preds <- ml_eval$predictions
  state$ml_summary <- compare_all_models(ml_eval)
  state$status$ml_trained <- TRUE
  state$status$evaluated  <- TRUE
  
  # Step 6: Insights
  state$insights <- generate_customer_insights(state$sentiment_df, state$ml_summary)
  state$status$insights_generated <- TRUE
  
  api_response(TRUE, "Labeled demo workflow executed successfully.", list(
    status = state$status,
    validation = state$validation,
    stats = state$preprocessing_stats,
    text_mining = state$text_mining,
    sentiment = list(kpis = state$sentiment_kpis, sentiment_words = state$sentiment_words),
    ml_evaluation = list(
      comparison_table = state$ml_summary$Comparison_Table,
      best_model = state$ml_summary$Best_Model,
      best_accuracy = state$ml_summary$Best_Accuracy,
      best_f1 = state$ml_summary$Best_F1,
      confusion_matrices = state$ml_summary$Confusion_Matrices
    ),
    insights = state$insights
  ))
}

#* Run Unlabeled Lexicon Demo Workflow
#* @post /demo/unlabeled
function(req, res) {
  reset_state_env()
  sample_path <- file.path("data", "sample", "sample_unlabeled.csv")
  if (!file.exists(sample_path)) {
    sample_path <- file.path("..", "data", "sample", "sample_unlabeled.csv")
  }
  
  df <- readr::read_csv(sample_path, show_col_types = FALSE)
  state$raw_df <- df
  state$filename <- "sample_unlabeled.csv"
  state$file_size <- file.info(sample_path)$size
  state$text_col <- "review_text"
  state$label_col <- NULL
  
  state$status$uploaded <- TRUE
  state$status$is_labeled <- FALSE
  state$status$is_demo <- TRUE
  
  # Step 1: Validate
  state$validation <- validate_dataset(df, state$text_col, state$label_col)
  state$status$validated <- TRUE
  
  # Step 2: Preprocess
  state$preprocessed_df <- preprocess_dataset(df, state$text_col, remove_stopwords = TRUE, perform_stemming = TRUE)
  clean_vec <- state$preprocessed_df$cleaned_text
  words_before <- sum(sapply(strsplit(as.character(df$review_text), "\\s+"), length))
  words_after <- sum(sapply(strsplit(clean_vec, "\\s+"), length))
  state$preprocessing_stats <- list(
    records_processed = length(clean_vec),
    words_before = words_before,
    words_after = words_after,
    stopwords_removed = max(0, words_before - words_after),
    remove_stopwords = TRUE,
    perform_stemming = TRUE
  )
  state$status$preprocessed <- TRUE
  
  # Step 3: Text Mining
  freq_df  <- get_word_frequencies(clean_vec, top_n = 50)
  tfidf_df <- compute_tfidf(clean_vec)
  kw_df    <- extract_keywords(tfidf_df, top_n = 20)
  dtm_info <- create_dtm_matrix(clean_vec)
  state$text_mining <- list(
    frequencies = freq_df,
    tfidf = tfidf_df,
    keywords = kw_df,
    vocabulary_count = length(dtm_info$vocabulary),
    unique_terms = nrow(freq_df)
  )
  state$status$text_mined <- TRUE
  
  # Step 4: Lexicon Sentiment
  state$sentiment_df    <- analyze_lexicon_sentiment(state$preprocessed_df, text_col = state$text_col)
  state$sentiment_kpis  <- calculate_sentiment_kpis(state$sentiment_df)
  state$sentiment_words <- get_sentiment_word_counts(state$sentiment_df$cleaned_text, top_n = 20)
  state$status$sentiment_analyzed <- TRUE
  
  # ML unavailable for unlabeled dataset
  state$ml_summary <- NULL
  
  # Step 5: Insights
  state$insights <- generate_customer_insights(state$sentiment_df, NULL)
  state$status$insights_generated <- TRUE
  
  api_response(TRUE, "Unlabeled demo workflow executed successfully.", list(
    status = state$status,
    validation = state$validation,
    stats = state$preprocessing_stats,
    text_mining = state$text_mining,
    sentiment = list(kpis = state$sentiment_kpis, sentiment_words = state$sentiment_words),
    ml_message = "SUPERVISED ML UNAVAILABLE - Supervised machine-learning models require genuine sentiment labels.",
    insights = state$insights
  ))
}
