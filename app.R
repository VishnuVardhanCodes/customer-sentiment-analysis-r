# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Main Shiny Web Application (app.R) - Professional Analytics Dashboard
# ==============================================================================

# Auto-set working directory to project root if needed
proj_dir <- "C:/DOCUMENTS/4 YEAR SUBJECTS/TERM 1/DA/PROJECT DA/customer-sentiment-analysis-r"
if (dir.exists(proj_dir)) {
  try(setwd(proj_dir), silent = TRUE)
}

# Auto-check and install missing packages dynamically at startup
required_packages <- c(
  "shiny", "bslib", "dplyr", "readr", "stringr", "tidytext",
  "tm", "SnowballC", "ggplot2", "wordcloud", "wordcloud2",
  "e1071", "class", "Matrix", "DT", "tidyr", "syuzhet"
)

missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(missing_packages) > 0) {
  message("Installing missing R packages for LG9 Project: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, repos = "https://cloud.r-project.org/", dependencies = TRUE)
}

suppressPackageStartupMessages({
  lapply(required_packages, library, character.only = TRUE)
})

# Source modular backend scripts using robust absolute paths
source(file.path(proj_dir, "R/preprocessing.R"), local = TRUE)
source(file.path(proj_dir, "R/text_mining.R"), local = TRUE)
source(file.path(proj_dir, "R/sentiment_analysis.R"), local = TRUE)
source(file.path(proj_dir, "R/machine_learning.R"), local = TRUE)
source(file.path(proj_dir, "R/evaluation.R"), local = TRUE)
source(file.path(proj_dir, "R/visualization.R"), local = TRUE)
source(file.path(proj_dir, "R/insights.R"), local = TRUE)

# Set seed for reproducibility across all random operations
set.seed(123)

# Define Shiny User Interface (UI)
ui <- page_sidebar(
  title = NULL,
  theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#1e3a8a"),
  
  # Inject Custom CSS Stylesheet
  header = tags$head(
    includeCSS(file.path(proj_dir, "www/styles.css"))
  ),
  
  # ----------------------------------------------------------------------------
  # SIDEBAR NAVIGATION (11 Numbered Items with Icons)
  # ----------------------------------------------------------------------------
  sidebar = sidebar(
    width = 270,
    class = "sidebar",
    title = div(
      class = "sidebar-title",
      span(class = "sidebar-title-badge", "LG9"),
      span(class = "sidebar-title-text", "ANALYTICS")
    ),
    
    navlistPanel(
      id = "main_nav",
      well = FALSE,
      widths = c(12, 12),
      
      tabPanel(
        title = tagList(span(class = "nav-num", "01"), icon("tachometer-alt"), "Dashboard"),
        value = "tab_dashboard"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "02"), icon("cloud-upload-alt"), "Upload Data"),
        value = "tab_upload"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "03"), icon("check-circle"), "Data Validation"),
        value = "tab_validation"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "04"), icon("cogs"), "Preprocessing"),
        value = "tab_preprocessing"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "05"), icon("search"), "Text Mining"),
        value = "tab_text_mining"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "06"), icon("smile"), "Sentiment Analysis"),
        value = "tab_sentiment"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "07"), icon("brain"), "Machine Learning"),
        value = "tab_ml"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "08"), icon("chart-line"), "Model Evaluation"),
        value = "tab_evaluation"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "09"), icon("chart-pie"), "Visualization"),
        value = "tab_visualization"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "10"), icon("lightbulb"), "Customer Insights"),
        value = "tab_insights"
      ),
      tabPanel(
        title = tagList(span(class = "nav-num", "11"), icon("download"), "Results & Download"),
        value = "tab_export"
      )
    )
  ),
  
  # MAIN HEADER BANNER WITH DYNAMIC STATUS PILL
  div(
    class = "top-app-header",
    div(
      class = "top-header-brand",
      div(class = "top-header-logo", "LG9"),
      div(
        class = "top-header-titles",
        h1("Customer Sentiment Analysis"),
        p("Social Media • Text Mining • R")
      )
    ),
    div(
      class = "top-header-status",
      uiOutput("ui_app_status_pill")
    )
  ),
  
  # MAIN CONTENT AREA
  div(
    style = "min-height: calc(100vh - 160px);",
    uiOutput("ui_main_content")
  ),
  
  # GLOBAL FOOTER
  div(
    class = "app-footer",
    span("LG9 Analytics"), " • Customer Sentiment Analysis from Social Media using Text Mining in R • Academic Data Analytics Project"
  )
)

# Define Shiny Server Logic
server <- function(input, output, session) {
  
  # Reactive State Store (Preserving 100% backend structure)
  rv <- reactiveValues(
    raw_data          = NULL,
    file_name         = NULL,
    text_col          = NULL,
    label_col         = NULL,
    processed_data    = NULL,
    freq_data         = NULL,
    tfidf_data        = NULL,
    sentiment_data    = NULL,
    ml_results        = NULL,
    ml_eval           = NULL,
    insights_data     = NULL,
    app_status        = "Ready for Analysis", # Ready for Analysis -> Dataset Loaded -> Analysis in Progress -> Analysis Complete
    ml_log            = "Awaiting dataset upload and machine learning execution..."
  )
  
  # ----------------------------------------------------------------------------
  # DYNAMIC TOP HEADER STATUS PILL
  # ----------------------------------------------------------------------------
  output$ui_app_status_pill <- renderUI({
    status_text <- rv$app_status
    dot_color <- case_when(
      status_text == "Ready for Analysis"   ~ "#3b82f6", # Blue
      status_text == "Dataset Loaded"       ~ "#f59e0b", # Amber
      status_text == "Analysis in Progress" ~ "#6366f1", # Indigo
      status_text == "Analysis Complete"    ~ "#10b981", # Green
      TRUE                                  ~ "#3b82f6"
    )
    
    div(
      class = "status-pill",
      div(class = "status-dot", style = paste0("background-color: ", dot_color, "; color: ", dot_color, ";")),
      span(paste0("● ", status_text))
    )
  })
  
  # ----------------------------------------------------------------------------
  # NAVIGATION ROUTER
  # ----------------------------------------------------------------------------
  output$ui_main_content <- renderUI({
    req(input$main_nav)
    
    switch(input$main_nav,
      "tab_dashboard"     = ui_tab_dashboard(),
      "tab_upload"        = ui_tab_upload(),
      "tab_validation"    = ui_tab_validation(),
      "tab_preprocessing" = ui_tab_preprocessing(),
      "tab_text_mining"   = ui_tab_text_mining(),
      "tab_sentiment"     = ui_tab_sentiment(),
      "tab_ml"            = ui_tab_ml(),
      "tab_evaluation"    = ui_tab_evaluation(),
      "tab_visualization" = ui_tab_visualization(),
      "tab_insights"      = ui_tab_insights(),
      "tab_export"        = ui_tab_export(),
      ui_tab_dashboard()
    )
  })

  # ----------------------------------------------------------------------------
  # TAB 1: DASHBOARD BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_dashboard <- function() {
    tagList(
      # Hero & Quick Action Card
      div(
        class = "hero-banner",
        div(class = "hero-banner-title", "Customer Sentiment Analysis Platform"),
        div(class = "hero-banner-subtitle", "Analyze customer feedback using text mining, TF-IDF weights, lexicon sentiment analysis, and machine learning in R."),
        
        div(
          class = "quick-action-cards",
          div(
            class = "quick-action-card",
            div(class = "quick-action-title", "01 • Dataset Upload"),
            div(class = "quick-action-desc", "Load your custom CSV or TXT customer feedback dataset to begin analysis."),
            actionButton("btn_goto_upload", "Upload Dataset", icon = icon("upload"), class = "btn-primary w-100")
          ),
          div(
            class = "quick-action-card",
            div(class = "quick-action-title", "02 • Demo Datasets"),
            div(class = "quick-action-desc", "Test system workflow using pre-loaded sample datasets."),
            div(
              style = "display: flex; gap: 0.5rem;",
              actionButton("btn_load_sample_labeled", "Run Labeled Demo", icon = icon("flask"), class = "btn-success w-50"),
              actionButton("btn_load_sample_unlabeled", "Run Unlabeled Demo", icon = icon("info-circle"), class = "btn-outline-primary w-50")
            )
          )
        ),
        
        # Horizontal Visual Workflow Step Cards
        div(
          class = "workflow-steps-wrapper",
          div(class = "workflow-steps-title", "Academic Methodology Workflow"),
          div(
            class = "workflow-steps-grid",
            div(class = "workflow-step-card", div(class = "workflow-step-num", "01"), div(class = "workflow-step-name", "DATA INPUT"), div(class = "workflow-step-desc", "Upload CSV/TXT")),
            div(class = "workflow-step-card", div(class = "workflow-step-num", "02"), div(class = "workflow-step-name", "PREPROCESSING"), div(class = "workflow-step-desc", "Clean customer text")),
            div(class = "workflow-step-card", div(class = "workflow-step-num", "03"), div(class = "workflow-step-name", "TEXT MINING"), div(class = "workflow-step-desc", "TF-IDF & keywords")),
            div(class = "workflow-step-card", div(class = "workflow-step-num", "04"), div(class = "workflow-step-name", "SENTIMENT"), div(class = "workflow-step-desc", "Pos / Neu / Neg")),
            div(class = "workflow-step-card", div(class = "workflow-step-num", "05"), div(class = "workflow-step-name", "MACHINE LEARNING"), div(class = "workflow-step-desc", "NB, SVM, KNN")),
            div(class = "workflow-step-card", div(class = "workflow-step-num", "06"), div(class = "workflow-step-name", "EVALUATION"), div(class = "workflow-step-desc", "Accuracy & F1")),
            div(class = "workflow-step-card", div(class = "workflow-step-num", "07"), div(class = "workflow-step-name", "VISUALIZATION"), div(class = "workflow-step-desc", "Charts & clouds")),
            div(class = "workflow-step-card", div(class = "workflow-step-num", "08"), div(class = "workflow-step-name", "INSIGHTS"), div(class = "workflow-step-desc", "Recommendations"))
          )
        )
      ),
      
      # Pipeline Status Tracker Card
      div(
        class = "analytics-card",
        div(class = "analytics-card-header", "Application Pipeline Status Tracker"),
        div(
          class = "analytics-card-body",
          div(
            class = "pipeline-steps-grid",
            div(
              class = "pipeline-step-card",
              div(class = "pipeline-step-num", "Dataset"),
              div(class = "pipeline-step-name", if(!is.null(rv$raw_data)) span(class = "badge-pass", "Loaded") else span(class = "text-muted", "Not Loaded"))
            ),
            div(
              class = "pipeline-step-card",
              div(class = "pipeline-step-num", "Preprocessing"),
              div(class = "pipeline-step-name", if(!is.null(rv$processed_data)) span(class = "badge-pass", "Completed") else span(class = "text-muted", "Not Run"))
            ),
            div(
              class = "pipeline-step-card",
              div(class = "pipeline-step-num", "Text Mining"),
              div(class = "pipeline-step-name", if(!is.null(rv$freq_data)) span(class = "badge-pass", "Completed") else span(class = "text-muted", "Not Run"))
            ),
            div(
              class = "pipeline-step-card",
              div(class = "pipeline-step-num", "Sentiment"),
              div(class = "pipeline-step-name", if(!is.null(rv$sentiment_data)) span(class = "badge-pass", "Completed") else span(class = "text-muted", "Not Run"))
            ),
            div(
              class = "pipeline-step-card",
              div(class = "pipeline-step-num", "ML Models"),
              div(class = "pipeline-step-name", 
                  if(is.null(rv$label_col) && !is.null(rv$raw_data)) span(class = "badge-warn", "Unlabeled") 
                  else if(!is.null(rv$ml_eval)) span(class = "badge-pass", "Evaluated")
                  else span(class = "text-muted", "Ready to Run"))
            ),
            div(
              class = "pipeline-step-card",
              div(class = "pipeline-step-num", "Insights"),
              div(class = "pipeline-step-name", if(!is.null(rv$insights_data)) span(class = "badge-pass", "Generated") else span(class = "text-muted", "Not Run"))
            )
          )
        )
      ),
      
      # Dynamic KPI Cards
      uiOutput("ui_dashboard_kpis"),
      
      # 2x2 Analytics Grid
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Sentiment Overview"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) {
                plotOutput("plot_dash_sentiment", height = "300px")
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("chart-bar")),
                  div(class = "empty-state-title", "No Sentiment Data Available"),
                  div(class = "empty-state-text", "Upload a dataset and run sentiment analysis to view distribution.")
                )
              }
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Most Discussed Terms (Top Words)"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$freq_data)) {
                plotOutput("plot_dash_freq", height = "300px")
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("font")),
                  div(class = "empty-state-title", "No Word Frequency Data"),
                  div(class = "empty-state-text", "Run text preprocessing and mining to extract term frequencies.")
                )
              }
            )
          )
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Machine Learning Model Performance"),
            div(
              class = "analytics-card-body",
              if (!is.null(rv$ml_eval)) {
                tableOutput("tbl_dash_ml_summary")
              } else if (is.null(rv$label_col) && !is.null(rv$raw_data)) {
                div(
                  class = "alert alert-warning mb-0",
                  icon("info-circle"),
                  " Supervised model evaluation is unavailable because this dataset does not contain genuine sentiment labels. Lexicon-based sentiment analysis is active."
                )
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("brain")),
                  div(class = "empty-state-title", "Supervised ML Ready"),
                  div(class = "empty-state-text", "Upload labeled data to evaluate Naive Bayes, SVM, and KNN algorithms.")
                )
              }
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(
              class = "analytics-card-header",
              "Quick Customer Insights Preview",
              if(!is.null(rv$insights_data)) actionButton("btn_goto_insights", "View All Insights", class = "btn-outline-primary btn-sm") else NULL
            ),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$insights_data)) {
                uiOutput("ui_dash_quick_insights")
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("lightbulb")),
                  div(class = "empty-state-title", "No Insights Generated"),
                  div(class = "empty-state-text", "Run sentiment analysis to generate dynamic executive insights and recommendations.")
                )
              }
            )
          )
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 2: UPLOAD DATA BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_upload <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Upload Customer Feedback Dataset"),
        p("Upload a CSV or TXT file containing customer reviews, comments, or social-media feedback.")
      ),
      
      fluidRow(
        column(
          width = 5,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "File Selector & Configuration"),
            div(
              class = "analytics-card-body",
              fileInput("file_input", "Select CSV or TXT Dataset", accept = c(".csv", ".txt"), width = "100%"),
              helpText("Supported file formats: CSV (comma-separated) or TXT (tab-delimited)."),
              hr(),
              uiOutput("ui_text_column_selector"),
              uiOutput("ui_label_column_selector"),
              br(),
              actionButton("btn_confirm_upload", "Confirm Dataset Configuration", icon = icon("check-circle"), class = "btn-primary w-100")
            )
          )
        ),
        column(
          width = 7,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Dataset Summary Checklist"),
            div(
              class = "analytics-card-body",
              uiOutput("ui_upload_summary_cards"),
              hr(),
              h6("Dataset Preview (First 10 Records):", class = "fw-bold text-dark mb-3"),
              DTOutput("tbl_raw_preview")
            )
          )
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 3: DATA VALIDATION BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_validation <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Data Validation & Quality Diagnostics"),
        p("Verify dataset integrity, missing records, column types, and sentiment label availability.")
      ),
      
      uiOutput("ui_validation_status_boxes"),
      br(),
      
      div(
        class = "analytics-card",
        div(class = "analytics-card-header", "Data Quality Checklist"),
        div(
          class = "analytics-card-body",
          uiOutput("ui_validation_notice")
        )
      ),
      
      div(
        class = "analytics-card",
        div(class = "analytics-card-header", "Dataset Structure & Column Metadata"),
        div(
          class = "analytics-card-body",
          tableOutput("tbl_validation_structure")
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 4: PREPROCESSING BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_preprocessing <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Text Preprocessing Pipeline"),
        p("Clean customer text feedback by removing noise, URLs, stopwords, and applying Porter stemming.")
      ),
      
      div(
        class = "analytics-card",
        div(class = "analytics-card-header", "Processing Pipeline Steps"),
        div(
          class = "analytics-card-body",
          div(
            class = "pipeline-steps-grid",
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 1"), div(class = "pipeline-step-name", "Lowercase")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 2"), div(class = "pipeline-step-name", "Remove URLs")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 3"), div(class = "pipeline-step-name", "Remove Emails")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 4"), div(class = "pipeline-step-name", "@Mentions")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 5"), div(class = "pipeline-step-name", "Hashtags")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 6"), div(class = "pipeline-step-name", "Punctuation")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 7"), div(class = "pipeline-step-name", "Digits")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 8"), div(class = "pipeline-step-name", "Stop Words & Stem"))
          )
        )
      ),
      
      fluidRow(
        column(
          width = 4,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Preprocessing Controls"),
            div(
              class = "analytics-card-body",
              checkboxInput("chk_stopwords", "Remove English Stop Words", value = TRUE),
              checkboxInput("chk_stemming", "Apply Porter Stemming", value = TRUE),
              br(),
              uiOutput("ui_preprocess_button"),
              helpText("Filters noise, tokenizes documents, and builds clean feature vectors.")
            )
          )
        ),
        column(
          width = 8,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "BEFORE vs AFTER Text Cleaning Comparison"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$processed_data)) {
                DTOutput("tbl_preprocess_compare")
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("cogs")),
                  div(class = "empty-state-title", "Preprocessing Pipeline Not Executed"),
                  div(class = "empty-state-text", "Click 'Run Preprocessing Pipeline' to clean textual feedback.")
                )
              }
            )
          )
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 5: TEXT MINING BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_text_mining <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Text Mining & Feature Extraction"),
        p("Explore word frequencies, TF-IDF term weights, keyword extractions, and word clouds.")
      ),
      
      navset_card_tab(
        nav_panel(
          title = "Word Frequency",
          fluidRow(
            column(width = 4, selectInput("sel_top_n_freq", "Select Top N Words:", choices = c(10, 20, 30, 50), selected = 20))
          ),
          fluidRow(
            column(width = 6, plotOutput("plot_word_freq", height = "400px")),
            column(width = 6, DTOutput("tbl_word_freq"))
          )
        ),
        nav_panel(
          title = "TF-IDF Analysis",
          fluidRow(
            column(width = 6, plotOutput("plot_tfidf", height = "400px")),
            column(width = 6, DTOutput("tbl_tfidf"))
          )
        ),
        nav_panel(
          title = "Word Cloud",
          div(style = "text-align: center; padding: 1rem;", plotOutput("plot_wordcloud", height = "500px"))
        ),
        nav_panel(
          title = "Keywords",
          DTOutput("tbl_keywords")
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 6: SENTIMENT ANALYSIS BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_sentiment <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Lexicon-Based Sentiment Analysis"),
        p("Classify reviews into Positive, Neutral, and Negative categories using Syuzhet lexicon scores.")
      ),
      
      fluidRow(
        column(width = 12, uiOutput("ui_sentiment_button"))
      ),
      uiOutput("ui_sentiment_kpis"),
      br(),
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Sentiment Class Distribution"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) plotOutput("plot_sentiment_dist", height = "380px")
              else div(class = "empty-state", div(class = "empty-state-title", "Run Sentiment Analysis to view distribution."))
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Per-Review Sentiment Scores"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) DTOutput("tbl_sentiment_results")
              else div(class = "empty-state", div(class = "empty-state-title", "No Sentiment Data"))
            )
          )
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 7: MACHINE LEARNING BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_ml <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Sentiment Classification Models"),
        p("Train and compare supervised machine-learning algorithms (Naive Bayes, SVM, KNN) using TF-IDF features.")
      ),
      
      uiOutput("ui_ml_status_banner"),
      
      fluidRow(
        column(
          width = 4,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Supervised Training Setup"),
            div(
              class = "analytics-card-body",
              p("Algorithms: ", tags$strong("Naive Bayes, SVM, KNN")),
              p("Feature Matrix: ", tags$strong("TF-IDF Vector Space")),
              p("Data Split: ", tags$strong("80% Training / 20% Testing")),
              p("Reproducibility Seed: ", tags$strong("set.seed(123)")),
              br(),
              uiOutput("ui_run_ml_button")
            )
          )
        ),
        column(
          width = 8,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Machine Learning Pipeline Log"),
            div(
              class = "analytics-card-body",
              verbatimTextOutput("txt_ml_log")
            )
          )
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 8: MODEL EVALUATION BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_evaluation <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Supervised Model Performance & Evaluation"),
        p("Compare Accuracy, Precision, Recall, F1-Score, and Confusion Matrices across Naive Bayes, SVM, and KNN.")
      ),
      
      if (is.null(rv$ml_eval)) {
        div(
          class = "analytics-card",
          div(class = "analytics-card-header", "Model Evaluation"),
          div(
            class = "analytics-card-body",
            if (is.null(rv$label_col)) {
              div(class = "alert alert-warning mb-0", icon("info-circle"), " No labeled sentiment column was found. Lexicon-based sentiment analysis is available, but supervised model evaluation requires genuine labeled training data.")
            } else {
              div(class = "empty-state", div(class = "empty-state-title", "Run Supervised Machine Learning"), div(class = "empty-state-text", "Navigate to Machine Learning tab and click 'Run Supervised ML Models'."))
            }
          )
        )
      } else {
        comp_df <- rv$ml_eval$Comparison_Table
        best_m  <- rv$ml_eval$Best_Model
        
        tagList(
          div(
            class = "alert alert-info mb-4",
            tags$strong("Best Performing Model: "),
            sprintf("%s achieved the highest score with Accuracy of %.2f%% and F1-Score of %.2f%%.",
                    best_m, rv$ml_eval$Best_Accuracy * 100, rv$ml_eval$Best_F1 * 100)
          ),
          
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Model Performance Metrics Table"),
            div(
              class = "analytics-card-body",
              tableOutput("tbl_model_comparison")
            )
          ),
          
          div(
            class = "section-header mt-4",
            h3("Confusion Matrices"),
            p("Classification breakdown across actual vs predicted sentiment classes.")
          ),
          
          fluidRow(
            column(width = 4, plotOutput("plot_cm_nb", height = "320px")),
            column(width = 4, plotOutput("plot_cm_svm", height = "320px")),
            column(width = 4, plotOutput("plot_cm_knn", height = "320px"))
          )
        )
      }
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 9: VISUALIZATION HUB BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_visualization <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Visualization Dashboard"),
        p("Comprehensive visual analytics summarizing sentiment distributions, term frequencies, and ML metrics.")
      ),
      
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Sentiment Class Distribution"),
            div(class = "analytics-card-body", plotOutput("plot_viz_sentiment", height = "360px"))
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Top Frequent Terms"),
            div(class = "analytics-card-body", plotOutput("plot_viz_freq", height = "360px"))
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Top TF-IDF Term Weights"),
            div(class = "analytics-card-body", plotOutput("plot_viz_tfidf", height = "360px"))
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Supervised ML Model Comparison"),
            div(class = "analytics-card-body", plotOutput("plot_viz_ml_comp", height = "360px"))
          )
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 10: CUSTOMER INSIGHTS BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_insights <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Customer Insights & Recommendations"),
        p("Turn customer feedback into actionable business intelligence.")
      ),
      
      if (is.null(rv$insights_data)) {
        div(
          class = "analytics-card",
          div(class = "analytics-card-header", "Customer Insights"),
          div(
            class = "analytics-card-body",
            div(class = "empty-state", div(class = "empty-state-title", "No Insights Available"), div(class = "empty-state-text", "Please run Text Preprocessing and Sentiment Analysis to generate dynamic executive insights."))
          )
        )
      } else {
        ins <- rv$insights_data
        
        tagList(
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("chart-line"), " Executive Sentiment Summary"),
            div(class = "analytics-card-body", p(ins$Executive_Summary, class = "lead fw-bold text-dark"))
          ),
          if (!is.null(ins$ML_Insight)) {
            div(
              class = "analytics-card",
              div(class = "analytics-card-header", icon("brain"), " Machine Learning Performance Insight"),
              div(class = "analytics-card-body", p(ins$ML_Insight))
            )
          },
          fluidRow(
            column(
              width = 6,
              div(
                class = "analytics-card",
                div(class = "analytics-card-header", icon("thumbs-up"), " What Customers Like (Positive Themes)"),
                div(
                  class = "analytics-card-body",
                  div(
                    class = "d-flex flex-wrap gap-2",
                    lapply(ins$Positive_Themes, function(x) span(class = "badge-pos", x))
                  )
                )
              )
            ),
            column(
              width = 6,
              div(
                class = "analytics-card",
                div(class = "analytics-card-header", icon("thumbs-down"), " What Customers Dislike / Common Issues"),
                div(
                  class = "analytics-card-body",
                  div(
                    class = "d-flex flex-wrap gap-2",
                    lapply(ins$Negative_Themes, function(x) span(class = "badge-neg", x))
                  )
                )
              )
            )
          ),
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("lightbulb"), " Actionable Data-Driven Recommendations"),
            div(
              class = "analytics-card-body",
              lapply(ins$Recommendations, function(rec) {
                div(
                  class = "recommendation-card",
                  span(class = "recommendation-card-icon", icon("check-circle")),
                  rec
                )
              }),
              hr(),
              p(class = "text-muted small italic mb-0", "Note: Insights and recommendations are dynamically derived from pattern frequencies in the uploaded dataset.")
            )
          )
        )
      }
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 11: RESULTS & DOWNLOAD BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_export <- function() {
    tagList(
      div(
        class = "section-header",
        h2("Results & Export Center"),
        p("Download processed datasets, sentiment classifications, ML metrics, and executive summary reports.")
      ),
      
      fluidRow(
        column(
          width = 4,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Export Options"),
            div(
              class = "analytics-card-body",
              downloadButton("download_processed", "Download Processed Data (CSV)", class = "btn-outline-primary w-100 mb-3"),
              downloadButton("download_sentiment", "Download Sentiment Results (CSV)", class = "btn-success w-100 mb-3"),
              downloadButton("download_ml_metrics", "Download ML Model Metrics (CSV)", class = "btn-outline-primary w-100 mb-3"),
              downloadButton("download_report", "Download Insights Summary (TXT)", class = "btn-primary w-100")
            )
          )
        ),
        column(
          width = 8,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", "Complete Analysis Results Table"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) DTOutput("tbl_full_results")
              else div(class = "empty-state", div(class = "empty-state-title", "No Results Ready for Export"), div(class = "empty-state-text", "Run sentiment analysis to view and export complete dataset results."))
            )
          )
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # OBSERVERS & EVENT HANDLERS (Preserving 100% backend logic)
  # ----------------------------------------------------------------------------
  
  # Navigation Shortcuts
  observeEvent(input$btn_goto_upload, {
    updateNavlistPanel(session, "main_nav", selected = "tab_upload")
  })
  
  observeEvent(input$btn_goto_insights, {
    updateNavlistPanel(session, "main_nav", selected = "tab_insights")
  })
  
  # Load Sample Labeled Data Demo Button
  observeEvent(input$btn_load_sample_labeled, {
    req(file.exists("data/sample/sample_reviews.csv"))
    rv$raw_data   <- read_csv("data/sample/sample_reviews.csv", show_col_types = FALSE)
    rv$file_name  <- "sample_reviews.csv (Labeled Demo)"
    rv$text_col   <- "review_text"
    rv$label_col  <- "sentiment"
    rv$app_status <- "Dataset Loaded"
    
    showNotification("Loaded sample labeled customer reviews dataset!", type = "message")
    updateNavlistPanel(session, "main_nav", selected = "tab_upload")
  })
  
  # Load Sample Unlabeled Data Demo Button
  observeEvent(input$btn_load_sample_unlabeled, {
    req(file.exists("data/sample/sample_unlabeled.csv"))
    rv$raw_data   <- read_csv("data/sample/sample_unlabeled.csv", show_col_types = FALSE)
    rv$file_name  <- "sample_unlabeled.csv (Unlabeled Demo)"
    rv$text_col   <- "review_text"
    rv$label_col  <- NULL
    rv$app_status <- "Dataset Loaded"
    
    showNotification("Loaded sample unlabeled customer feedback dataset!", type = "warning")
    updateNavlistPanel(session, "main_nav", selected = "tab_upload")
  })
  
  # Handle File Upload
  observeEvent(input$file_input, {
    req(input$file_input)
    file_path <- input$file_input$datapath
    file_ext  <- tools::file_ext(input$file_input$name)
    
    tryCatch({
      if (tolower(file_ext) == "csv") {
        df <- read_csv(file_path, show_col_types = FALSE)
      } else if (tolower(file_ext) == "txt") {
        df <- read_delim(file_path, delim = "\t", show_col_types = FALSE)
      } else {
        showNotification("Unsupported file format. Please upload CSV or TXT.", type = "error")
        return()
      }
      
      rv$raw_data   <- df
      rv$file_name  <- input$file_input$name
      rv$app_status <- "Dataset Loaded"
      
      # Auto-detect text column
      cols <- colnames(df)
      cols_lower <- tolower(cols)
      candidates <- c("review", "review_text", "comment", "feedback", "text", "message", "tweet", "opinion", "customer_feedback", "description")
      match_idx  <- which(cols_lower %in% candidates)
      
      if (length(match_idx) > 0) {
        rv$text_col <- cols[match_idx[1]]
      } else {
        rv$text_col <- cols[1]
      }
      
      # Auto-detect label column
      rv$label_col <- detect_label_column(df)
      
      showNotification("File uploaded and analyzed successfully!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })
  
  # Selectors Renderers
  output$ui_text_column_selector <- renderUI({
    req(rv$raw_data)
    selectInput("sel_text_col", "Select Text Column:", choices = colnames(rv$raw_data), selected = rv$text_col)
  })
  
  output$ui_label_column_selector <- renderUI({
    req(rv$raw_data)
    opts <- c("None (Unlabeled)" = "", colnames(rv$raw_data))
    selected_val <- if (!is.null(rv$label_col)) rv$label_col else ""
    selectInput("sel_label_col", "Select Sentiment Label Column (Optional):", choices = opts, selected = selected_val)
  })
  
  observeEvent(input$btn_confirm_upload, {
    req(rv$raw_data, input$sel_text_col)
    rv$text_col  <- input$sel_text_col
    rv$label_col <- if (nchar(input$sel_label_col) > 0) input$sel_label_col else NULL
    showNotification("Column selections confirmed!", type = "message")
  })
  
  # Upload Summary Cards
  output$ui_upload_summary_cards <- renderUI({
    if (is.null(rv$raw_data)) {
      return(div(class = "empty-state", div(class = "empty-state-title", "No Dataset Uploaded"), div(class = "empty-state-text", "Upload a CSV or TXT file using the panel on the left.")))
    }
    
    tagList(
      div(
        class = "pipeline-steps-grid",
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "File Name"), div(class = "pipeline-step-name", rv$file_name)),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Total Rows"), div(class = "pipeline-step-name", nrow(rv$raw_data))),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Total Columns"), div(class = "pipeline-step-name", ncol(rv$raw_data))),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Text Column"), div(class = "pipeline-step-name text-primary", rv$text_col)),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Label Column"), div(class = "pipeline-step-name", if(!is.null(rv$label_col)) span(class = "badge-pass", rv$label_col) else span(class = "badge-warn", "Unlabeled")))
      ),
      br(),
      div(
        class = "alert alert-success py-2 mb-0",
        icon("check-circle"), " ✓ Dataset uploaded ",
        icon("check-circle"), " ✓ Text column detected ",
        icon("check-circle"), " ✓ Ready for preprocessing"
      )
    )
  })
  
  output$tbl_raw_preview <- renderDT({
    req(rv$raw_data)
    datatable(head(rv$raw_data, 10), options = list(pageLength = 5, scrollX = TRUE))
  })

  # Validation UI
  output$ui_validation_status_boxes <- renderUI({
    if (is.null(rv$raw_data)) {
      return(div(class = "empty-state", div(class = "empty-state-title", "No Dataset Uploaded"), div(class = "empty-state-text", "Upload a dataset to run quality validation checks.")))
    }
    
    df <- rv$raw_data
    text_c <- rv$text_col
    
    total_records <- nrow(df)
    total_cols    <- ncol(df)
    missing_vals  <- sum(is.na(df[[text_c]]))
    empty_records <- sum(nchar(str_trim(as.character(df[[text_c]]))) == 0, na.rm = TRUE)
    dup_rows      <- sum(duplicated(df[[text_c]]))
    
    div(
      class = "kpi-grid",
      div(class = "kpi-card kpi-total", div(class = "kpi-title", "Total Records"), div(class = "kpi-value", total_records)),
      div(class = "kpi-card kpi-pos", div(class = "kpi-title", "Columns Count"), div(class = "kpi-value", total_cols)),
      div(class = "kpi-card kpi-neu", div(class = "kpi-title", "Missing Values"), div(class = "kpi-value", missing_vals)),
      div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Duplicate Text"), div(class = "kpi-value", dup_rows))
    )
  })
  
  output$ui_validation_notice <- renderUI({
    if (is.null(rv$raw_data)) return(NULL)
    
    if (!is.null(rv$label_col)) {
      div(
        class = "alert alert-success mb-0",
        icon("check-circle"),
        tags$strong(" Genuine Sentiment Label Detected: "),
        sprintf("Column '%s' is available for Supervised Machine Learning (Naive Bayes, SVM, KNN) evaluation.", rv$label_col)
      )
    } else {
      div(
        class = "alert alert-warning mb-0",
        icon("exclamation-triangle"),
        tags$strong(" Unlabeled Dataset Notice: "),
        "No genuine sentiment label column was found. Lexicon-based sentiment analysis will be performed. Supervised machine-learning evaluation requires labeled training data."
      )
    }
  })
  
  output$tbl_validation_structure <- renderTable({
    req(rv$raw_data)
    df <- rv$raw_data
    data.frame(
      Column_Name = colnames(df),
      Data_Type = sapply(df, class),
      Sample_Value = sapply(df, function(x) paste(head(na.omit(x), 1), collapse = ", "))
    )
  })

  # Preprocessing Exec
  output$ui_preprocess_button <- renderUI({
    if (is.null(rv$raw_data)) {
      actionButton("btn_run_preprocess_disabled", "Run Preprocessing Pipeline", class = "btn-secondary w-100", disabled = TRUE)
    } else {
      actionButton("btn_run_preprocess", "Run Preprocessing Pipeline", icon = icon("play"), class = "btn-primary w-100")
    }
  })
  
  observeEvent(input$btn_run_preprocess, {
    req(rv$raw_data, rv$text_col)
    
    rv$app_status <- "Analysis in Progress"
    
    withProgress(message = "Cleaning and preprocessing textual data...", value = 0.3, {
      res_df <- preprocess_dataset(
        df = rv$raw_data,
        text_col = rv$text_col,
        remove_stopwords = input$chk_stopwords,
        perform_stemming = input$chk_stemming
      )
      
      incProgress(0.4, detail = "Calculating word frequencies & TF-IDF...")
      
      rv$processed_data <- res_df
      rv$freq_data      <- get_word_frequencies(res_df$cleaned_text, top_n = 100)
      rv$tfidf_data     <- compute_tfidf(res_df$cleaned_text)
      
      incProgress(0.3, detail = "Done!")
      rv$app_status <- "Analysis Complete"
      showNotification("Text preprocessing pipeline completed successfully!", type = "message")
    })
  })

  output$tbl_preprocess_compare <- renderDT({
    req(rv$processed_data, rv$text_col)
    disp <- rv$processed_data %>% select(Original_Text = !!sym(rv$text_col), Cleaned_Text = cleaned_text)
    datatable(head(disp, 50), options = list(pageLength = 10, scrollX = TRUE))
  })

  # Text Mining Renderers
  output$plot_word_freq <- renderPlot({
    req(rv$freq_data)
    n_val <- as.numeric(input$sel_top_n_freq)
    plot_word_frequency(rv$freq_data, top_n = n_val)
  })
  
  output$tbl_word_freq <- renderDT({
    req(rv$freq_data)
    n_val <- as.numeric(input$sel_top_n_freq)
    datatable(head(rv$freq_data, n_val), options = list(pageLength = 10))
  })
  
  output$plot_tfidf <- renderPlot({
    req(rv$tfidf_data)
    plot_tfidf_terms(rv$tfidf_data, top_n = 20)
  })
  
  output$tbl_tfidf <- renderDT({
    req(rv$tfidf_data)
    datatable(rv$tfidf_data, options = list(pageLength = 10))
  })
  
  output$plot_wordcloud <- renderPlot({
    req(rv$freq_data)
    freqs <- rv$freq_data
    if (nrow(freqs) > 0) {
      wordcloud(
        words = freqs$Word,
        freq = freqs$Frequency,
        min.freq = 1,
        max.words = 80,
        random.order = FALSE,
        colors = brewer.pal(8, "Dark2")
      )
    }
  })
  
  output$tbl_keywords <- renderDT({
    req(rv$tfidf_data)
    kw <- extract_keywords(rv$tfidf_data, top_n = 25)
    datatable(kw, options = list(pageLength = 10))
  })

  # Sentiment Analysis Exec
  output$ui_sentiment_button <- renderUI({
    if (is.null(rv$processed_data)) {
      actionButton("btn_run_sentiment_disabled", "Run Lexicon Sentiment Analysis", class = "btn-secondary btn-lg w-100 mb-3", disabled = TRUE)
    } else {
      actionButton("btn_run_sentiment", "Run Lexicon Sentiment Analysis", icon = icon("magic"), class = "btn-primary btn-lg w-100 mb-3")
    }
  })

  observeEvent(input$btn_run_sentiment, {
    req(rv$processed_data, rv$text_col)
    
    rv$app_status <- "Analysis in Progress"
    withProgress(message = "Executing lexicon sentiment analysis...", value = 0.5, {
      res_df <- analyze_lexicon_sentiment(
        df = rv$processed_data,
        text_col = rv$text_col,
        clean_col = "cleaned_text"
      )
      
      rv$sentiment_data <- res_df
      rv$insights_data  <- generate_customer_insights(res_df, rv$ml_eval)
      
      incProgress(0.5)
      rv$app_status <- "Analysis Complete"
      showNotification("Lexicon sentiment analysis complete!", type = "message")
    })
  })
  
  output$ui_sentiment_kpis <- renderUI({
    req(rv$sentiment_data)
    kpis <- calculate_sentiment_kpis(rv$sentiment_data)
    
    div(
      class = "kpi-grid",
      div(class = "kpi-card kpi-total", div(class = "kpi-title", "Total Analyzed"), div(class = "kpi-value", kpis$Total)),
      div(class = "kpi-card kpi-pos", div(class = "kpi-title", "Positive"), div(class = "kpi-value", paste0(kpis$Pos_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Pos_Count, "reviews"))),
      div(class = "kpi-card kpi-neu", div(class = "kpi-title", "Neutral"), div(class = "kpi-value", paste0(kpis$Neu_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Neu_Count, "reviews"))),
      div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Negative"), div(class = "kpi-value", paste0(kpis$Neg_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Neg_Count, "reviews")))
    )
  })

  output$plot_sentiment_dist <- renderPlot({
    req(rv$sentiment_data)
    plot_sentiment_distribution(rv$sentiment_data)
  })
  
  output$tbl_sentiment_results <- renderDT({
    req(rv$sentiment_data, rv$text_col)
    disp <- rv$sentiment_data %>% select(Text = !!sym(rv$text_col), Score = Sentiment_Score, Sentiment = Sentiment)
    datatable(disp, options = list(pageLength = 8, scrollX = TRUE))
  })

  # Machine Learning Exec
  output$ui_ml_status_banner <- renderUI({
    if (is.null(rv$label_col) && !is.null(rv$raw_data)) {
      div(
        class = "alert alert-warning mb-3",
        icon("info-circle"),
        tags$strong(" Supervised Machine Learning Unavailable: "),
        "Your dataset does not contain a genuine sentiment-label column. Lexicon-based sentiment analysis is available, but supervised model evaluation requires labeled data."
      )
    } else if (!is.null(rv$label_col)) {
      div(
        class = "alert alert-success mb-3",
        icon("check-circle"),
        tags$strong(" Ready for Supervised Learning: "),
        sprintf("Using ground-truth column '%s' for supervised classification.", rv$label_col)
      )
    } else {
      NULL
    }
  })
  
  output$ui_run_ml_button <- renderUI({
    if (is.null(rv$label_col) || is.null(rv$processed_data)) {
      actionButton("btn_run_ml_disabled", "Run Supervised ML (Requires Labels)", class = "btn-secondary w-100", disabled = TRUE)
    } else {
      actionButton("btn_run_ml", "Run Supervised ML Models (NB, SVM, KNN)", icon = icon("play-circle"), class = "btn-primary w-100")
    }
  })

  observeEvent(input$btn_run_ml, {
    req(rv$processed_data, rv$label_col)
    
    rv$app_status <- "Analysis in Progress"
    withProgress(message = "Executing Supervised Machine Learning Models...", value = 0.2, {
      tryCatch({
        clean_txt <- rv$processed_data$cleaned_text
        labels    <- rv$processed_data[[rv$label_col]]
        
        incProgress(0.2, detail = "Building TF-IDF Matrix & Train/Test Split (80/20)...")
        ml_prep <- prepare_ml_datasets(clean_txt, labels, train_prop = 0.8, seed = 123)
        
        incProgress(0.3, detail = "Training Naive Bayes, SVM, and KNN models...")
        ml_res <- execute_all_ml_models(ml_prep)
        
        incProgress(0.2, detail = "Evaluating accuracy, precision, recall, & F1...")
        ml_eval <- compare_all_models(ml_res)
        
        rv$ml_results <- ml_res
        rv$ml_eval    <- ml_eval
        
        if (!is.null(rv$sentiment_data)) {
          rv$insights_data <- generate_customer_insights(rv$sentiment_data, ml_eval)
        }
        
        rv$ml_log <- sprintf(
          "Supervised Machine Learning Completed Successfully!\nBest Model: %s\nAccuracy: %.2f%%\nF1-Score: %.2f%%\nTrain Samples: %d\nTest Samples: %d",
          ml_eval$Best_Model, ml_eval$Best_Accuracy * 100, ml_eval$Best_F1 * 100,
          nrow(ml_prep$train_x), nrow(ml_prep$test_x)
        )
        
        incProgress(0.1)
        rv$app_status <- "Analysis Complete"
        showNotification("Machine Learning models evaluated successfully!", type = "message")
      }, error = function(e) {
        rv$ml_log <- paste("Error during machine learning execution:", e$message)
        showNotification(paste("ML Error:", e$message), type = "error")
      })
    })
  })

  output$txt_ml_log <- renderText({
    rv$ml_log
  })

  # Evaluation Renderers
  output$tbl_model_comparison <- renderTable({
    req(rv$ml_eval)
    rv$ml_eval$Comparison_Table
  }, digits = 4)
  
  output$plot_cm_nb <- renderPlot({
    req(rv$ml_eval)
    plot_confusion_matrix(rv$ml_eval$Confusion_Matrices[["Naive Bayes"]], "Naive Bayes")
  })
  
  output$plot_cm_svm <- renderPlot({
    req(rv$ml_eval)
    plot_confusion_matrix(rv$ml_eval$Confusion_Matrices[["SVM"]], "SVM")
  })
  
  output$plot_cm_knn <- renderPlot({
    req(rv$ml_eval)
    plot_confusion_matrix(rv$ml_eval$Confusion_Matrices[["KNN"]], "KNN")
  })

  # Dashboard Specific Renderers
  output$ui_dashboard_kpis <- renderUI({
    if (is.null(rv$sentiment_data)) {
      div(
        class = "kpi-grid",
        div(class = "kpi-card kpi-total", div(class = "kpi-title", "Total Reviews"), div(class = "kpi-value", "—"), div(class = "kpi-subtext", "Upload dataset to calculate")),
        div(class = "kpi-card kpi-pos", div(class = "kpi-title", "Positive Reviews"), div(class = "kpi-value", "—"), div(class = "kpi-subtext", "Awaiting sentiment analysis")),
        div(class = "kpi-card kpi-neu", div(class = "kpi-title", "Neutral Reviews"), div(class = "kpi-value", "—"), div(class = "kpi-subtext", "Awaiting sentiment analysis")),
        div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Negative Reviews"), div(class = "kpi-value", "—"), div(class = "kpi-subtext", "Awaiting sentiment analysis"))
      )
    } else {
      kpis <- calculate_sentiment_kpis(rv$sentiment_data)
      
      div(
        class = "kpi-grid",
        div(class = "kpi-card kpi-total", div(class = "kpi-title", "Total Reviews"), div(class = "kpi-value", kpis$Total)),
        div(class = "kpi-card kpi-pos", div(class = "kpi-title", "Positive Reviews"), div(class = "kpi-value", paste0(kpis$Pos_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Pos_Count, "reviews"))),
        div(class = "kpi-card kpi-neu", div(class = "kpi-title", "Neutral Reviews"), div(class = "kpi-value", paste0(kpis$Neu_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Neu_Count, "reviews"))),
        div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Negative Reviews"), div(class = "kpi-value", paste0(kpis$Neg_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Neg_Count, "reviews")))
      )
    }
  })

  output$plot_dash_sentiment <- renderPlot({
    req(rv$sentiment_data)
    plot_sentiment_distribution(rv$sentiment_data)
  })

  output$plot_dash_freq <- renderPlot({
    req(rv$freq_data)
    plot_word_frequency(rv$freq_data, 10)
  })

  output$tbl_dash_ml_summary <- renderTable({
    req(rv$ml_eval)
    rv$ml_eval$Comparison_Table %>% select(Model, Accuracy, F1_Score)
  }, digits = 4)

  output$ui_dash_quick_insights <- renderUI({
    req(rv$insights_data)
    ins <- rv$insights_data
    tagList(
      p(tags$strong("Overall Summary: "), ins$Executive_Summary),
      tags$ul(
        lapply(head(ins$Recommendations, 3), function(r) tags$li(r))
      )
    )
  })

  # Visualization Hub Plots
  output$plot_viz_sentiment <- renderPlot({
    req(rv$sentiment_data)
    plot_sentiment_distribution(rv$sentiment_data)
  })
  
  output$plot_viz_freq <- renderPlot({
    req(rv$freq_data)
    plot_word_frequency(rv$freq_data, 20)
  })
  
  output$plot_viz_tfidf <- renderPlot({
    req(rv$tfidf_data)
    plot_tfidf_terms(rv$tfidf_data, 20)
  })
  
  output$plot_viz_ml_comp <- renderPlot({
    req(rv$ml_eval)
    plot_model_comparison(rv$ml_eval$Comparison_Table)
  })

  # Results & Export Handlers
  output$tbl_full_results <- renderDT({
    req(rv$sentiment_data, rv$text_col)
    res <- rv$sentiment_data
    disp <- res %>% select(Original_Text = !!sym(rv$text_col), Cleaned_Text = cleaned_text, Score = Sentiment_Score, Sentiment = Sentiment)
    if (!is.null(rv$label_col) && rv$label_col %in% colnames(res)) {
      disp$Actual_Label <- res[[rv$label_col]]
    }
    datatable(disp, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$download_processed <- downloadHandler(
    filename = function() { paste0("processed_dataset_", Sys.Date(), ".csv") },
    content = function(file) {
      req(rv$processed_data)
      write.csv(rv$processed_data, file, row.names = FALSE)
    }
  )
  
  output$download_sentiment <- downloadHandler(
    filename = function() { paste0("sentiment_results_", Sys.Date(), ".csv") },
    content = function(file) {
      req(rv$sentiment_data)
      write.csv(rv$sentiment_data, file, row.names = FALSE)
    }
  )
  
  output$download_ml_metrics <- downloadHandler(
    filename = function() { paste0("ml_model_comparison_", Sys.Date(), ".csv") },
    content = function(file) {
      req(rv$ml_eval)
      write.csv(rv$ml_eval$Comparison_Table, file, row.names = FALSE)
    }
  )
  
  output$download_report <- downloadHandler(
    filename = function() { paste0("customer_insights_report_", Sys.Date(), ".txt") },
    content = function(file) {
      req(rv$insights_data)
      ins <- rv$insights_data
      lines <- c(
        "==================================================================",
        "LG9 - CUSTOMER SENTIMENT ANALYSIS REPORT",
        "==================================================================",
        "",
        "EXECUTIVE SUMMARY:",
        ins$Executive_Summary,
        "",
        "POSITIVE THEMES:",
        paste("-", ins$Positive_Themes, collapse = "\n"),
        "",
        "NEGATIVE THEMES / COMMON ISSUES:",
        paste("-", ins$Negative_Themes, collapse = "\n"),
        "",
        "RECOMMENDATIONS:",
        paste("•", ins$Recommendations, collapse = "\n\n")
      )
      writeLines(lines, file)
    }
  )
}

# Launch Shiny Web Application
shinyApp(ui = ui, server = server)
