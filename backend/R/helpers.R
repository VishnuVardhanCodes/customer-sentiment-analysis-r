# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Backend Helpers & Response Formatter (backend/R/helpers.R)
# ==============================================================================

#' Consistent JSON API Response Formatter
#'
#' @param success Logical indicator
#' @param message Message string
#' @param data Payload data
#' @param error_code Optional error code string
#' @return Formatted list
api_response <- function(success = TRUE, message = "Operation completed", data = list(), error_code = NULL) {
  res <- list(
    success = success,
    message = message,
    data = data
  )
  if (!is.null(error_code)) {
    res$error_code <- error_code
  }
  return(res)
}

#' Ensure directory exists
#'
#' @param dir_path Directory path string
ensure_dir <- function(dir_path) {
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
  }
}
