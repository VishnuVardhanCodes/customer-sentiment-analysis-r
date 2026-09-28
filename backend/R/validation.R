# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Data Quality Validation (backend/R/validation.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
})

#' Auto-detect text column in dataset
#'
#' @param df Data frame
#' @return Character column name if found, else NULL
detect_text_column <- function(df) {
  col_names <- colnames(df)
  col_names_lower <- tolower(col_names)
  
  candidate_names <- c("review_text", "text", "comment", "review", "feedback", "tweet", "message", "body", "content")
  
  match_idx <- which(col_names_lower %in% candidate_names)
  if (length(match_idx) > 0) {
    return(col_names[match_idx[1]])
  }
  
  # Fallback: Find first character column with average string length > 15
  for (col in col_names) {
    if (is.character(df[[col]]) || is.factor(df[[col]])) {
      avg_len <- mean(nchar(as.character(df[[col]])), na.rm = TRUE)
      if (!is.na(avg_len) && avg_len > 15) {
        return(col)
      }
    }
  }
  
  # Default to first column if dataframe not empty
  if (ncol(df) > 0) return(col_names[1])
  return(NULL)
}

#' Validate dataset quality, completeness, and structure
#'
#' @param df Data frame to validate
#' @param text_col Character, name of text column
#' @param label_col Character, optional name of sentiment label column
#' @return List containing summary metrics, validation checks table, and preview data
validate_dataset <- function(df, text_col = NULL, label_col = NULL) {
  if (is.null(df) || nrow(df) == 0) {
    return(list(
      summary = list(rows = 0, columns = 0, missing_values = 0, duplicates = 0, is_labeled = FALSE),
      checks = data.frame(Check = character(0), Result = character(0), Status = character(0)),
      preview = data.frame()
    ))
  }
  
  # Auto-detect text column if not specified
  if (is.null(text_col) || !text_col %in% colnames(df)) {
    text_col <- detect_text_column(df)
  }
  
  # Auto-detect label column if not specified
  if (is.null(label_col) || !label_col %in% colnames(df)) {
    label_col <- detect_label_column(df)
  }
  
  total_rows <- nrow(df)
  total_cols <- ncol(df)
  total_missing <- sum(is.na(df))
  
  # Duplicates in text column
  text_vec <- if (!is.null(text_col) && text_col %in% colnames(df)) as.character(df[[text_col]]) else character(0)
  total_duplicates <- if (length(text_vec) > 0) sum(duplicated(text_vec)) else 0
  
  is_labeled <- !is.null(label_col) && label_col %in% colnames(df)
  
  checks <- list()
  
  # Check 1: Text column existence
  if (!is.null(text_col) && text_col %in% colnames(df)) {
    checks[[1]] <- data.frame(
      Check = "Text Column Identification",
      Result = paste0("Column '", text_col, "' found and selected for text mining."),
      Status = "PASS",
      stringsAsFactors = FALSE
    )
  } else {
    checks[[1]] <- data.frame(
      Check = "Text Column Identification",
      Result = "No valid text column detected in dataset.",
      Status = "ERROR",
      stringsAsFactors = FALSE
    )
  }
  
  # Check 2: Missing text values
  missing_text_count <- if (length(text_vec) > 0) sum(is.na(df[[text_col]])) else 0
  if (missing_text_count == 0) {
    checks[[2]] <- data.frame(
      Check = "Missing Text Values",
      Result = "No missing (NA) text records found.",
      Status = "PASS",
      stringsAsFactors = FALSE
    )
  } else {
    checks[[2]] <- data.frame(
      Check = "Missing Text Values",
      Result = paste(missing_text_count, "records contain missing (NA) text."),
      Status = "WARNING",
      stringsAsFactors = FALSE
    )
  }
  
  # Check 3: Empty text strings
  empty_text_count <- if (length(text_vec) > 0) sum(nchar(str_trim(ifelse(is.na(text_vec), "", text_vec))) == 0) else 0
  if (empty_text_count == 0) {
    checks[[3]] <- data.frame(
      Check = "Empty Text Records",
      Result = "All rows contain non-empty text content.",
      Status = "PASS",
      stringsAsFactors = FALSE
    )
  } else {
    checks[[3]] <- data.frame(
      Check = "Empty Text Records",
      Result = paste(empty_text_count, "records contain empty text strings."),
      Status = "WARNING",
      stringsAsFactors = FALSE
    )
  }
  
  # Check 4: Duplicate text reviews
  if (total_duplicates == 0) {
    checks[[4]] <- data.frame(
      Check = "Duplicate Customer Reviews",
      Result = "All customer feedback text records are unique.",
      Status = "PASS",
      stringsAsFactors = FALSE
    )
  } else {
    checks[[4]] <- data.frame(
      Check = "Duplicate Customer Reviews",
      Result = paste(total_duplicates, "duplicate text entries detected."),
      Status = "WARNING",
      stringsAsFactors = FALSE
    )
  }
  
  # Check 5: Sentiment label column
  if (is_labeled) {
    unique_labels <- unique(na.omit(as.character(df[[label_col]])))
    checks[[5]] <- data.frame(
      Check = "Ground-Truth Sentiment Labels",
      Result = paste0("Label column '", label_col, "' detected with categories: ", paste(unique_labels, collapse = ", ")),
      Status = "PASS",
      stringsAsFactors = FALSE
    )
  } else {
    checks[[5]] <- data.frame(
      Check = "Ground-Truth Sentiment Labels",
      Result = "No sentiment ground-truth label column found (Unlabeled Dataset).",
      Status = "UNLABELED",
      stringsAsFactors = FALSE
    )
  }
  
  # Check 6: Dataset size check
  if (total_rows >= 10) {
    checks[[6]] <- data.frame(
      Check = "Dataset Size & Volume",
      Result = paste(total_rows, "records available for text analysis."),
      Status = "PASS",
      stringsAsFactors = FALSE
    )
  } else {
    checks[[6]] <- data.frame(
      Check = "Dataset Size & Volume",
      Result = paste(total_rows, "records is relatively small for machine learning."),
      Status = "WARNING",
      stringsAsFactors = FALSE
    )
  }
  
  checks_df <- do.call(rbind, checks)
  
  # Preview dataset (up to 50 rows for performance)
  preview_df <- head(df, 50)
  
  return(list(
    summary = list(
      rows = total_rows,
      columns = total_cols,
      missing_values = total_missing,
      duplicates = total_duplicates,
      is_labeled = is_labeled,
      text_column = text_col,
      label_column = label_col,
      column_names = colnames(df)
    ),
    checks = checks_df,
    preview = preview_df
  ))
}
