# ==============================================================================
# LG9 – R Plumber API Server Launcher (backend/run_plumber.R)
# ==============================================================================

user_lib1 <- file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library", "4.6")
user_lib2 <- file.path(Sys.getenv("USERPROFILE"), "AppData", "Local", "R", "win-library", "4.6")
user_lib3 <- file.path("C:", "Users", Sys.getenv("USERNAME"), "AppData", "Local", "R", "win-library", "4.6")

for (ulib in c(user_lib1, user_lib2, user_lib3)) {
  if (dir.exists(ulib)) {
    .libPaths(c(ulib, .libPaths()))
  }
}

suppressPackageStartupMessages({
  library(plumber)
})

cat("Starting LG9 Customer Sentiment Analysis R Plumber API on http://127.0.0.1:8000 ...\n")
pr <- plumber::plumb("plumber.R")
pr$run(host = "0.0.0.0", port = 8000)
