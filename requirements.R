# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Requirements & Dependency Installation Script
# ==============================================================================

cat("Checking and installing required R packages for LG9 Project...\n\n")

# Ensure writable user library path exists
user_lib <- Sys.getenv("R_LIBS_USER")
if (user_lib == "" || is.na(user_lib)) {
  user_lib <- file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library", "4.6")
}
if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
}
.libPaths(c(user_lib, .libPaths()))
cat("Using R library directory:", user_lib, "\n")

required_packages <- c(
  "plumber",
  "jsonlite",
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
  install.packages(missing_packages, lib = user_lib, repos = "https://cloud.r-project.org/")
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

