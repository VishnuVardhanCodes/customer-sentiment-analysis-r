# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Supervised Machine Learning (backend/R/machine_learning.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tm)
  library(e1071)
  library(class)
  library(Matrix)
  library(tidytext)
})

#' Auto-detect sentiment label column in dataset
#'
#' @param df Data frame
#' @return Character column name if found, else NULL
detect_label_column <- function(df) {
  col_names <- tolower(colnames(df))
  candidate_names <- c("sentiment", "sentiment_label", "label", "class", "polarity", "target")
  
  match_idx <- which(col_names %in% candidate_names)
  if (length(match_idx) > 0) {
    return(colnames(df)[match_idx[1]])
  }
  return(NULL)
}

#' Prepare TF-IDF feature matrix and Train/Test split for ML
#'
#' @param clean_text_vec Character vector of cleaned text
#' @param labels Factor/character vector of ground-truth sentiment labels
#' @param train_prop Numeric split proportion (default 0.8)
#' @param seed Integer seed for reproducibility
#' @return List containing train/test feature matrices, labels, and vocabulary
prepare_ml_datasets <- function(clean_text_vec, labels, train_prop = 0.8, seed = 123) {
  set.seed(seed)
  
  n_docs <- length(clean_text_vec)
  if (n_docs < 5) {
    stop("Dataset contains too few records for supervised machine learning split.")
  }
  
  # Replace empty clean strings with default token to prevent empty corpus DTM
  clean_vec <- ifelse(n_docs == 0 | is.na(clean_text_vec) | nchar(trimws(clean_text_vec)) == 0, "sample", clean_text_vec)
  
  # Create Document-Term Matrix with TF-IDF weighting
  corpus <- tm::VCorpus(tm::VectorSource(clean_vec))
  dtm <- tm::DocumentTermMatrix(corpus, control = list(weighting = tm::weightTfIdf))
  
  # Remove sparse terms if feature dimension is large
  if (ncol(dtm) > 100) {
    dtm <- tm::removeSparseTerms(dtm, 0.98)
  }
  
  feature_matrix <- as.matrix(dtm)
  
  if (ncol(feature_matrix) == 0) {
    # Fallback dummy feature if corpus is empty
    feature_matrix <- matrix(1, nrow = n_docs, ncol = 1)
    colnames(feature_matrix) <- "term"
  }
  
  colnames(feature_matrix) <- make.names(colnames(feature_matrix), unique = TRUE)
  
  labels_factor <- as.factor(labels)
  
  # Train/Test split
  train_size <- floor(train_prop * n_docs)
  if (train_size >= n_docs) train_size <- n_docs - 1
  if (train_size < 1) train_size <- 1
  
  train_indices <- sample(seq_len(n_docs), size = train_size)
  
  train_x <- feature_matrix[train_indices, , drop = FALSE]
  train_y <- labels_factor[train_indices]
  
  test_x  <- feature_matrix[-train_indices, , drop = FALSE]
  test_y  <- labels_factor[-train_indices]
  
  return(list(
    train_x = train_x,
    train_y = train_y,
    test_x  = test_x,
    test_y  = test_y,
    vocabulary = colnames(feature_matrix)
  ))
}

#' Train Naive Bayes model and predict on test set
#'
#' @param train_x Train feature matrix
#' @param train_y Train labels
#' @param test_x Test feature matrix
#' @return Factor of predicted class labels for test set
run_naive_bayes <- function(train_x, train_y, test_x) {
  df_train <- as.data.frame(train_x)
  df_test  <- as.data.frame(test_x)
  
  # Filter zero variance columns
  if (ncol(df_train) > 1) {
    var_cols <- sapply(df_train, function(c) var(as.numeric(c), na.rm = TRUE))
    valid_cols <- which(!is.na(var_cols) & var_cols > 0)
    if (length(valid_cols) > 0) {
      df_train <- df_train[, valid_cols, drop = FALSE]
      df_test  <- df_test[, valid_cols, drop = FALSE]
    }
  }
  
  nb_model <- e1071::naiveBayes(df_train, train_y)
  preds    <- predict(nb_model, df_test)
  return(preds)
}

#' Train Support Vector Machine (SVM) model and predict on test set
#'
#' @param train_x Train feature matrix
#' @param train_y Train labels
#' @param test_x Test feature matrix
#' @return Factor of predicted class labels for test set
run_svm <- function(train_x, train_y, test_x) {
  df_train <- as.data.frame(train_x)
  df_test  <- as.data.frame(test_x)
  
  if (ncol(df_train) > 1) {
    var_cols <- sapply(df_train, function(c) var(as.numeric(c), na.rm = TRUE))
    valid_cols <- which(!is.na(var_cols) & var_cols > 0)
    if (length(valid_cols) > 0) {
      df_train <- df_train[, valid_cols, drop = FALSE]
      df_test  <- df_test[, valid_cols, drop = FALSE]
    }
  }
  
  svm_model <- e1071::svm(
    x = df_train,
    y = train_y,
    kernel = "linear",
    cost = 1.0,
    scale = FALSE
  )
  preds <- predict(svm_model, df_test)
  return(preds)
}

#' Train K-Nearest Neighbors (KNN) model and predict on test set
#'
#' @param train_x Train feature matrix
#' @param train_y Train labels
#' @param test_x Test feature matrix
#' @param k Integer number of neighbors
#' @return Factor of predicted class labels for test set
run_knn <- function(train_x, train_y, test_x, k = 5) {
  df_train <- as.matrix(train_x)
  df_test  <- as.matrix(test_x)
  
  k_val <- min(k, nrow(df_train) - 1)
  if (k_val < 1) k_val <- 1
  
  preds <- class::knn(
    train = df_train,
    test  = df_test,
    cl    = train_y,
    k     = k_val
  )
  return(preds)
}

#' Wrapper to execute Naive Bayes, SVM, and KNN sequentially
#'
#' @param ml_data List returned by `prepare_ml_datasets`
#' @return List of predictions and actual test labels
execute_all_ml_models <- function(ml_data) {
  cat("Training Naive Bayes model...\n")
  nb_preds <- run_naive_bayes(ml_data$train_x, ml_data$train_y, ml_data$test_x)
  
  cat("Training Support Vector Machine (SVM) model...\n")
  svm_preds <- run_svm(ml_data$train_x, ml_data$train_y, ml_data$test_x)
  
  cat("Training K-Nearest Neighbors (KNN) model...\n")
  knn_preds <- run_knn(ml_data$train_x, ml_data$train_y, ml_data$test_x, k = 5)
  
  return(list(
    actual = ml_data$test_y,
    predictions = list(
      "Naive Bayes" = nb_preds,
      "SVM"         = svm_preds,
      "KNN"         = knn_preds
    )
  ))
}
