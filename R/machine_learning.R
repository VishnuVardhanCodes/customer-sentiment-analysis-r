# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Supervised Machine Learning (R/machine_learning.R)
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
  if (n_docs < 10) {
    stop("Dataset contains too few records for supervised machine learning split.")
  }
  
  # Create Document-Term Matrix
  corpus <- tm::VCorpus(tm::VectorSource(clean_text_vec))
  dtm <- tm::DocumentTermMatrix(corpus, control = list(weighting = tm::weightTfIdf))
  
  # Filter sparse terms to maintain reasonable feature dimensions
  if (ncol(dtm) > 500) {
    dtm <- tm::removeSparseTerms(dtm, 0.98)
  }
  
  feature_matrix <- as.matrix(dtm)
  
  # Ensure column names are valid R symbols
  colnames(feature_matrix) <- make.names(colnames(feature_matrix), unique = TRUE)
  
  labels_factor <- as.factor(labels)
  
  # Stratified or random sampling
  train_indices <- sample(seq_len(n_docs), size = floor(train_prop * n_docs))
  
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
  # Convert numeric TF-IDF to categorical or use e1071 naiveBayes
  nb_model <- e1071::naiveBayes(train_x, train_y)
  preds    <- predict(nb_model, test_x)
  return(preds)
}

#' Train Support Vector Machine (SVM) model and predict on test set
#'
#' @param train_x Train feature matrix
#' @param train_y Train labels
#' @param test_x Test feature matrix
#' @return Factor of predicted class labels for test set
run_svm <- function(train_x, train_y, test_x) {
  svm_model <- e1071::svm(
    x = train_x,
    y = train_y,
    kernel = "linear",
    cost = 1.0,
    scale = FALSE
  )
  preds <- predict(svm_model, test_x)
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
  # Adjust k if sample size is small
  k_val <- min(k, nrow(train_x) - 1)
  if (k_val < 1) k_val <- 1
  
  preds <- class::knn(
    train = train_x,
    test  = test_x,
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
