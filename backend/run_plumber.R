# ==============================================================================
# LG9 – R Plumber API Server Launcher (backend/run_plumber.R)
# ==============================================================================

user_dirs <- c(
  "C:/Users/POLLA VISHNU VARDHAN/AppData/Local/R/win-library/4.6",
  "C:/Users/POLLA VISHNU VARDHAN/AppData/Local/R/win-library/4.5",
  "C:/Users/POLLA VISHNU VARDHAN/AppData/Local/R/win-library/4.4",
  "C:/Users/POLLA VISHNU VARDHAN/Documents/R/win-library/4.6",
  "C:/Users/POLLA VISHNU VARDHAN/Documents/R/win-library/4.5",
  "C:/Users/POLLA VISHNU VARDHAN/Documents/R/win-library/4.4"
)

for (p in user_dirs) {
  if (dir.exists(p)) {
    .libPaths(c(p, .libPaths()))
  }
}

cat("Current R libPaths:\n")
print(.libPaths())

suppressPackageStartupMessages({
  library(plumber)
})

cat("Starting LG9 Customer Sentiment Analysis R Plumber API on http://127.0.0.1:8000 ...\n")
pr <- plumber::plumb("plumber.R")
pr$run(host = "0.0.0.0", port = 8000)
