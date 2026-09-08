# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Model Evaluation & Performance Metrics (R/evaluation.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
})

#' Calculate classification metrics (Accuracy, Precision, Recall, F1-Score) & Confusion Matrix
#'
#' @param actual_y Factor or character vector of ground truth labels
#' @param pred_y Factor or character vector of model predicted labels
#' @return List containing metrics vector and confusion matrix dataframe
evaluate_model_performance <- function(actual_y, pred_y) {
  actual <- as.character(actual_y)
  pred   <- as.character(pred_y)
  
  classes <- union(unique(actual), unique(pred))
  n_total <- length(actual)
  
  # Overall Accuracy
  accuracy <- sum(actual == pred) / n_total
  
  # Per-class Precision, Recall, and F1-score
  class_metrics <- lapply(classes, function(cls) {
    tp <- sum(actual == cls & pred == cls)
    fp <- sum(actual != cls & pred == cls)
    fn <- sum(actual == cls & pred != cls)
    
    precision <- if ((tp + fp) > 0) tp / (tp + fp) else 0
    recall    <- if ((tp + fn) > 0) tp / (tp + fn) else 0
    f1        <- if ((precision + recall) > 0) 2 * (precision * recall) / (precision + recall) else 0
    
    return(data.frame(Class = cls, Precision = precision, Recall = recall, F1 = f1, Count = sum(actual == cls)))
  })
  
  metrics_df <- do.call(rbind, class_metrics)
  
  # Calculate Macro-Averaged Metrics
  macro_precision <- mean(metrics_df$Precision, na.rm = TRUE)
  macro_recall    <- mean(metrics_df$Recall, na.rm = TRUE)
  macro_f1        <- mean(metrics_df$F1, na.rm = TRUE)
  
  # Generate tabular Confusion Matrix
  cm_table <- table(Actual = factor(actual, levels = classes),
                    Predicted = factor(pred, levels = classes))
  
  cm_df <- as.data.frame(cm_table)
  
  return(list(
    Accuracy  = round(accuracy, 4),
    Precision = round(macro_precision, 4),
    Recall    = round(macro_recall, 4),
    F1_Score  = round(macro_f1, 4),
    Class_Metrics = metrics_df,
    Confusion_Matrix = cm_table,
    Confusion_Matrix_DF = cm_df
  ))
}

#' Generate structured comparison table across all trained models
#'
#' @param ml_eval_results List of predictions returned by `execute_all_ml_models`
#' @return Data frame comparing Model, Accuracy, Precision, Recall, F1-Score
compare_all_models <- function(ml_eval_results) {
  actual <- ml_eval_results$actual
  preds  <- ml_eval_results$predictions
  
  model_names <- names(preds)
  summary_list <- list()
  cm_list <- list()
  
  for (m_name in model_names) {
    res <- evaluate_model_performance(actual, preds[[m_name]])
    
    summary_list[[m_name]] <- data.frame(
      Model     = m_name,
      Accuracy  = res$Accuracy,
      Precision = res$Precision,
      Recall    = res$Recall,
      F1_Score  = res$F1_Score,
      stringsAsFactors = FALSE
    )
    
    cm_list[[m_name]] <- res$Confusion_Matrix_DF
  }
  
  comparison_df <- do.call(rbind, summary_list)
  rownames(comparison_df) <- NULL
  
  # Rank best model primarily by F1_Score, secondarily by Accuracy
  comparison_df <- comparison_df %>% arrange(desc(F1_Score), desc(Accuracy))
  best_model_name <- comparison_df$Model[1]
  best_accuracy   <- comparison_df$Accuracy[1]
  best_f1         <- comparison_df$F1_Score[1]
  
  return(list(
    Comparison_Table = comparison_df,
    Best_Model       = best_model_name,
    Best_Accuracy    = best_accuracy,
    Best_F1          = best_f1,
    Confusion_Matrices = cm_list
  ))
}
