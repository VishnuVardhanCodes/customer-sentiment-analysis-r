# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Requirements & Dependency Installation Script
# ==============================================================================

cat("Checking and installing required R packages for LG9 Project...\n\n")

required_packages <- c(
  "shiny",
  "bslib",
  "dplyr",
  "readr",
  "stringr",
  "tidytext",
  "tm",
  "SnowballC",
  "ggplot2",
  "wordcloud",
  "wordcloud2",
  "caret",
  "e1071",
  "class",
  "Matrix",
  "DT",
  "tidyr",
  "syuzhet"
)

missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cloud.r-project.org/")
} else {
  cat("All required packages are already installed.\n")
}

cat("\nVerifying package loadings...\n")
success <- TRUE

for (pkg in required_packages) {
  if (!suppressPackageStartupMessages(require(pkg, character.only = TRUE))) {
    cat("  [FAIL] Failed to load package:", pkg, "\n")
    success <- FALSE
  } else {
    cat("  [OK] Successfully loaded:", pkg, "\n")
  }
}

if (success) {
  cat("\nEnvironment verification successful! All packages are ready.\n")
} else {
  cat("\nWarning: Some packages failed to load. Please check installation messages.\n")
}
