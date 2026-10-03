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
#' @return List containing predictions, fitted model, and valid column indices
run_naive_bayes <- function(train_x, train_y, test_x) {
  df_train <- as.data.frame(train_x)
  df_test  <- as.data.frame(test_x)
  
  valid_cols <- NULL
  if (ncol(df_train) > 1) {
    var_cols <- sapply(df_train, function(c) var(as.numeric(c), na.rm = TRUE))
    v_idx <- which(!is.na(var_cols) & var_cols > 0)
    if (length(v_idx) > 0) {
      valid_cols <- v_idx
      df_train <- df_train[, valid_cols, drop = FALSE]
      df_test  <- df_test[, valid_cols, drop = FALSE]
    }
  }
  
  nb_model <- e1071::naiveBayes(df_train, train_y)
  preds    <- predict(nb_model, df_test)
  
  return(list(
    predictions = preds,
    model = nb_model,
    valid_cols = valid_cols
  ))
}

#' Train Support Vector Machine (SVM) model and predict on test set
#'
#' @param train_x Train feature matrix
#' @param train_y Train labels
#' @param test_x Test feature matrix
#' @return List containing predictions, fitted model, and valid column indices
run_svm <- function(train_x, train_y, test_x) {
  df_train <- as.data.frame(train_x)
  df_test  <- as.data.frame(test_x)
  
  valid_cols <- NULL
  if (ncol(df_train) > 1) {
    var_cols <- sapply(df_train, function(c) var(as.numeric(c), na.rm = TRUE))
    v_idx <- which(!is.na(var_cols) & var_cols > 0)
    if (length(v_idx) > 0) {
      valid_cols <- v_idx
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
  
  return(list(
    predictions = preds,
    model = svm_model,
    valid_cols = valid_cols
  ))
}

#' Train K-Nearest Neighbors (KNN) model and predict on test set
#'
#' @param train_x Train feature matrix
#' @param train_y Train labels
#' @param test_x Test feature matrix
#' @param k Integer number of neighbors
#' @return List containing predictions and KNN reference training data
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
  
  return(list(
    predictions = preds,
    train_x = df_train,
    train_y = train_y,
    k = k_val
  ))
}

#' Wrapper to execute Naive Bayes, SVM, and KNN sequentially
#'
#' @param ml_data List returned by `prepare_ml_datasets`
#' @return List of predictions, actual test labels, and fitted models
execute_all_ml_models <- function(ml_data) {
  cat("Training Naive Bayes model...\n")
  nb_res  <- run_naive_bayes(ml_data$train_x, ml_data$train_y, ml_data$test_x)
  
  cat("Training Support Vector Machine (SVM) model...\n")
  svm_res <- run_svm(ml_data$train_x, ml_data$train_y, ml_data$test_x)
  
  cat("Training K-Nearest Neighbors (KNN) model...\n")
  knn_res <- run_knn(ml_data$train_x, ml_data$train_y, ml_data$test_x, k = 5)
  
  return(list(
    actual = ml_data$test_y,
    predictions = list(
      "Naive Bayes" = nb_res$predictions,
      "SVM"         = svm_res$predictions,
      "KNN"         = knn_res$predictions
    ),
    models = list(
      nb = nb_res$model,
      nb_valid_cols = nb_res$valid_cols,
      svm = svm_res$model,
      svm_valid_cols = svm_res$valid_cols,
      knn_train_x = knn_res$train_x,
      knn_train_y = knn_res$train_y,
      knn_k = knn_res$k,
      vocabulary = ml_data$vocabulary,
      classes = levels(ml_data$train_y)
    )
  ))
}

#' Predict sentiment for an individual review using trained ML model
#'
#' @param clean_text Preprocessed review text
#' @param model_name Character: "SVM", "Naive Bayes", "KNN", or "Auto"
#' @param trained_models List of trained models stored in server state
#' @return List with predicted sentiment, confidence, and method info, or NULL if unavailable
predict_single_review_ml <- function(clean_text, model_name = "SVM", trained_models = NULL) {
  if (is.null(trained_models) || is.null(trained_models$vocabulary)) {
    return(NULL)
  }
  
  vocab <- trained_models$vocabulary
  tokens <- unlist(strsplit(tolower(clean_text), "\\s+"))
  tokens <- tokens[nchar(tokens) > 0]
  
  # Term frequencies in the input review
  tf_counts <- table(tokens)
  
  # Construct 1-row feature vector matching the training vocabulary
  feat_vec <- numeric(length(vocab))
  names(feat_vec) <- vocab
  
  common_terms <- intersect(names(tf_counts), vocab)
  if (length(common_terms) > 0) {
    feat_vec[common_terms] <- as.numeric(tf_counts[common_terms])
  }
  
  row_mat <- matrix(feat_vec, nrow = 1, dimnames = list("1", vocab))
  df_input <- as.data.frame(row_mat)
  
  target_model <- model_name
  if (target_model == "Auto" || target_model == "auto") {
    if (!is.null(trained_models$svm)) target_model <- "SVM"
    else if (!is.null(trained_models$nb)) target_model <- "Naive Bayes"
    else if (!is.null(trained_models$knn_train_x)) target_model <- "KNN"
  }
  
  if (target_model == "Naive Bayes" && !is.null(trained_models$nb)) {
    df_nb <- df_input
    if (!is.null(trained_models$nb_valid_cols)) {
      df_nb <- df_nb[, trained_models$nb_valid_cols, drop = FALSE]
    }
    pred <- predict(trained_models$nb, df_nb)
    probs <- tryCatch(predict(trained_models$nb, df_nb, type = "raw"), error = function(e) NULL)
    conf <- if (!is.null(probs)) round(max(probs[1, ]) * 100, 1) else 85.0
    
    return(list(
      sentiment = as.character(pred[1]),
      confidence = conf,
      method = "Supervised Naive Bayes (e1071)",
      method_type = "Supervised Machine Learning",
      matching_features = length(common_terms)
    ))
  }
  
  if (target_model == "SVM" && !is.null(trained_models$svm)) {
    df_svm <- df_input
    if (!is.null(trained_models$svm_valid_cols)) {
      df_svm <- df_svm[, trained_models$svm_valid_cols, drop = FALSE]
    }
    pred <- predict(trained_models$svm, df_svm)
    
    # Heuristic confidence based on matched feature support
    conf <- min(95.0, 75.0 + (length(common_terms) * 4.0))
    
    return(list(
      sentiment = as.character(pred[1]),
      confidence = conf,
      method = "Supervised Support Vector Machine (Linear Kernel SVM)",
      method_type = "Supervised Machine Learning",
      matching_features = length(common_terms)
    ))
  }
  
  if (target_model == "KNN" && !is.null(trained_models$knn_train_x)) {
    k_val <- if (!is.null(trained_models$knn_k)) trained_models$knn_k else 5
    pred <- class::knn(
      train = trained_models$knn_train_x,
      test  = row_mat,
      cl    = trained_models$knn_train_y,
      k     = k_val
    )
    conf <- min(90.0, 70.0 + (length(common_terms) * 3.5))
    
    return(list(
      sentiment = as.character(pred[1]),
      confidence = conf,
      method = paste0("Supervised K-Nearest Neighbors (k=", k_val, ")"),
      method_type = "Supervised Machine Learning",
      matching_features = length(common_terms)
    ))
  }
  
  return(NULL)
}
