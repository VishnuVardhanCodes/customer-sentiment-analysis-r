# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Main Shiny Web Application (app.R) - Modern SaaS Data Analytics Platform
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

user_lib <- Sys.getenv("R_LIBS_USER")
if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
}
.libPaths(c(user_lib, .libPaths()))

missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(missing_packages) > 0) {
  message("Installing missing R packages for LG9 Project: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, lib = user_lib, repos = "https://cloud.r-project.org/", dependencies = TRUE)
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
  
  # Inject Custom CSS & JS for Sidebar Collapse and Tooltips
  header = tags$head(
    includeCSS(file.path(proj_dir, "www/styles.css")),
    tags$script(HTML("
      $(document).on('click', '#sidebar_toggle_btn', function() {
        $('.sidebar').toggleClass('sidebar-collapsed');
        var icon = $(this).find('i');
        if ($('.sidebar').hasClass('sidebar-collapsed')) {
          icon.removeClass('fa-chevron-left').addClass('fa-chevron-right');
        } else {
          icon.removeClass('fa-chevron-right').addClass('fa-chevron-left');
        }
      });
      
      // Auto-attach data-tooltip to nav links for collapsed sidebar tooltips
      $(document).ready(function() {
        var titles = [
          'Dashboard', 'Upload Data', 'Data Validation', 'Preprocessing',
          'Text Mining', 'Sentiment Analysis', 'Machine Learning',
          'Model Evaluation', 'Visualization', 'Customer Insights', 'Results & Download'
        ];
        $('.nav-pills .nav-link').each(function(index) {
          if (index < titles.length) {
            $(this).attr('data-tooltip', titles[index]);
          }
        });
      });
    "))
  ),
  
  # ----------------------------------------------------------------------------
  # SIDEBAR NAVIGATION (11 Numbered Items with Icons & Collapse Toggle)
  # ----------------------------------------------------------------------------
  sidebar = sidebar(
    width = 270,
    class = "sidebar",
    title = div(
      class = "sidebar-header-row",
      div(
        class = "sidebar-brand-box",
        span(class = "sidebar-title-badge", "LG9"),
        div(
          span(class = "sidebar-title-text", "ANALYTICS"),
          span(class = "sidebar-subtitle", "Customer Intelligence")
        )
      ),
      tags$button(
        id = "sidebar_toggle_btn",
        class = "sidebar-collapse-btn",
        title = "Toggle Sidebar",
        icon("chevron-left")
      )
    ),
    
    navlistPanel(
      id = "main_nav",
      well = FALSE,
      widths = c(12, 12),
      
      tabPanel(
        title = tagList(
          span(class = "nav-num", "01"),
          icon("tachometer-alt"),
          span(class = "nav-text-label", "Dashboard")
        ),
        value = "tab_dashboard"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "02"),
          icon("cloud-upload-alt"),
          span(class = "nav-text-label", "Upload Data")
        ),
        value = "tab_upload"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "03"),
          icon("shield-alt"),
          span(class = "nav-text-label", "Data Validation")
        ),
        value = "tab_validation"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "04"),
          icon("sliders-h"),
          span(class = "nav-text-label", "Preprocessing")
        ),
        value = "tab_preprocessing"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "05"),
          icon("search"),
          span(class = "nav-text-label", "Text Mining")
        ),
        value = "tab_text_mining"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "06"),
          icon("smile"),
          span(class = "nav-text-label", "Sentiment Analysis")
        ),
        value = "tab_sentiment"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "07"),
          icon("brain"),
          span(class = "nav-text-label", "Machine Learning")
        ),
        value = "tab_ml"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "08"),
          icon("chart-line"),
          span(class = "nav-text-label", "Model Evaluation")
        ),
        value = "tab_evaluation"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "09"),
          icon("chart-pie"),
          span(class = "nav-text-label", "Visualization")
        ),
        value = "tab_visualization"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "10"),
          icon("lightbulb"),
          span(class = "nav-text-label", "Customer Insights")
        ),
        value = "tab_insights"
      ),
      tabPanel(
        title = tagList(
          span(class = "nav-num", "11"),
          icon("download"),
          span(class = "nav-text-label", "Results & Download")
        ),
        value = "tab_export"
      )
    )
  ),
  
  # MAIN SaaS TOP HEADER WITH DYNAMIC STATUS PILL & RESET ACTION
  div(
    class = "top-app-header",
    div(
      class = "top-header-brand",
      div(class = "top-header-logo-badge", icon("chart-bar"), "LG9 Analytics"),
      div(
        class = "top-header-titles",
        h1("Customer Sentiment Analysis"),
        p("From Social Media using Text Mining in R")
      )
    ),
    div(
      class = "top-header-controls",
      uiOutput("ui_header_dataset_badge"),
      uiOutput("ui_app_status_pill"),
      actionButton("btn_reset_modal", "Reset Analysis", icon = icon("redo-alt"), class = "btn-header-reset")
    )
  ),
  
  # MAIN CONTENT AREA
  div(
    style = "min-height: calc(100vh - 170px); padding: 0 0.5rem;",
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
  
  # Reactive State Store
  rv <- reactiveValues(
    raw_data          = NULL,
    file_name         = NULL,
    file_size_str     = NULL,
    text_col          = NULL,
    label_col         = NULL,
    processed_data    = NULL,
    freq_data         = NULL,
    tfidf_data        = NULL,
    sentiment_data    = NULL,
    ml_results        = NULL,
    ml_eval           = NULL,
    insights_data     = NULL,
    app_status        = "Ready for Analysis",
    ml_log            = "Awaiting dataset upload and machine learning execution..."
  )

  # ----------------------------------------------------------------------------
  # DYNAMIC TOP HEADER BADGES & PILL
  # ----------------------------------------------------------------------------
  output$ui_header_dataset_badge <- renderUI({
    if (is.null(rv$raw_data)) {
      div(class = "header-dataset-badge", icon("database"), "Dataset: Not Loaded")
    } else {
      lbl <- if (!is.null(rv$file_name)) rv$file_name else "Dataset Loaded"
      rows_cnt <- nrow(rv$raw_data)
      div(
        class = "header-dataset-badge",
        icon("file-alt"),
        sprintf("%s (%d records)", lbl, rows_cnt)
      )
    }
  })
  
  output$ui_app_status_pill <- renderUI({
    status_text <- rv$app_status
    dot_color <- case_when(
      status_text == "Ready for Analysis"   ~ "#3b82f6", # Blue
      status_text == "Dataset Loaded"       ~ "#f59e0b", # Amber
      status_text == "Analysis in Progress" ~ "#8b5cf6", # Purple
      status_text == "Analysis Complete"    ~ "#10b981", # Green
      TRUE                                  ~ "#3b82f6"
    )
    
    div(
      class = "status-pill",
      div(class = "status-dot", style = paste0("background-color: ", dot_color, "; color: ", dot_color, ";")),
      span(status_text)
    )
  })

  # Helper: Universal Page Header Component
  ui_page_header <- function(title, description, breadcrumb_label) {
    div(
      class = "page-header-container",
      div(
        class = "page-header-left",
        h2(title),
        p(description)
      ),
      div(
        class = "page-breadcrumb",
        "LG9 Analytics / ", span(breadcrumb_label)
      )
    )
  }

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
  # TAB 1: DASHBOARD BUILDER (Contains Hero, Quick Actions & Full Stepper Workflow)
  # ----------------------------------------------------------------------------
  ui_tab_dashboard <- function() {
    tagList(
      ui_page_header("DASHBOARD OVERVIEW", "Turn customer feedback into meaningful insights using text mining and sentiment analysis in R.", "Dashboard"),
      
      # Hero & Quick Actions Banner
      div(
        class = "hero-banner",
        div(class = "hero-banner-title", "LG9 – Customer Sentiment Analysis"),
        div(class = "hero-banner-subtitle", "Analyze customer feedback using text mining, sentiment analysis, machine learning and visualization."),
        
        div(
          class = "quick-action-cards",
          div(
            class = "quick-action-card",
            div(class = "quick-action-title", "Option 1 • Custom Dataset"),
            div(class = "quick-action-desc", "Upload your own customer feedback dataset (CSV or TXT format)."),
            actionButton("btn_goto_upload", "Upload Dataset", icon = icon("upload"), class = "btn-primary w-100")
          ),
          div(
            class = "quick-action-card",
            div(class = "quick-action-title", "Option 2 • Labeled Demo"),
            div(class = "quick-action-desc", "Test sentiment classification and supervised ML models (Naive Bayes, SVM, KNN)."),
            actionButton("btn_load_sample_labeled", "Run Labeled Demo", icon = icon("flask"), class = "btn-success w-100")
          ),
          div(
            class = "quick-action-card",
            div(class = "quick-action-title", "Option 3 • Unlabeled Demo"),
            div(class = "quick-action-desc", "Analyze raw customer feedback using lexicon-based sentiment analysis."),
            actionButton("btn_load_sample_unlabeled", "Run Unlabeled Demo", icon = icon("play"), class = "btn-outline-primary w-100")
          )
        ),
        
        # COMPLETE METHODOLOGY WORKFLOW STEPPER CARDS (Displayed ONLY on Dashboard)
        div(
          class = "workflow-steps-wrapper",
          div(class = "workflow-steps-title", "Academic Methodology Pipeline Workflow"),
          div(
            class = "workflow-steps-grid",
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "01"),
              div(class = "workflow-step-name", "DATA INPUT"),
              div(class = "workflow-step-desc", "Upload CSV/TXT"),
              div(class = if(!is.null(rv$raw_data)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$raw_data)) "✓ Completed" else "○ Not Started")
            ),
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "02"),
              div(class = "workflow-step-name", "VALIDATE"),
              div(class = "workflow-step-desc", "Check Quality"),
              div(class = if(!is.null(rv$raw_data)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$raw_data)) "✓ Completed" else "○ Not Started")
            ),
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "03"),
              div(class = "workflow-step-name", "PREPROCESS"),
              div(class = "workflow-step-desc", "Clean & Stem"),
              div(class = if(!is.null(rv$processed_data)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$processed_data)) "✓ Completed" else "○ Not Started")
            ),
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "04"),
              div(class = "workflow-step-name", "TEXT MINING"),
              div(class = "workflow-step-desc", "TF-IDF & Keywords"),
              div(class = if(!is.null(rv$freq_data)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$freq_data)) "✓ Completed" else "○ Not Started")
            ),
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "05"),
              div(class = "workflow-step-name", "SENTIMENT"),
              div(class = "workflow-step-desc", "Syuzhet Lexicon"),
              div(class = if(!is.null(rv$sentiment_data)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$sentiment_data)) "✓ Completed" else "○ Not Started")
            ),
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "06"),
              div(class = "workflow-step-name", "ML MODELS"),
              div(class = "workflow-step-desc", "NB, SVM, KNN"),
              div(class = if(!is.null(rv$ml_results)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$ml_results)) "✓ Completed" else "○ Not Started")
            ),
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "07"),
              div(class = "workflow-step-name", "EVALUATION"),
              div(class = "workflow-step-desc", "Accuracy & F1"),
              div(class = if(!is.null(rv$ml_eval)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$ml_eval)) "✓ Completed" else "○ Not Started")
            ),
            div(
              class = "workflow-step-card",
              div(class = "workflow-step-num", "08"),
              div(class = "workflow-step-name", "INSIGHTS"),
              div(class = "workflow-step-desc", "Recommendations"),
              div(class = if(!is.null(rv$insights_data)) "workflow-step-status status-completed" else "workflow-step-status status-not-started",
                  if(!is.null(rv$insights_data)) "✓ Generated" else "○ Not Started")
            )
          )
        )
      ),

      # Dynamic Dataset Status Summary Card
      div(
        class = "analytics-card",
        div(class = "analytics-card-header", icon("database"), " Active Dataset Workspace Status"),
        div(
          class = "analytics-card-body",
          uiOutput("ui_dash_dataset_status_summary")
        )
      ),

      # Dynamic Primary KPI Cards
      uiOutput("ui_dashboard_kpis"),

      # 2x2 Core Analytics Grid
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("chart-pie"), " Sentiment Overview"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) {
                fluidRow(
                  column(width = 7, plotOutput("plot_dash_sentiment", height = "280px")),
                  column(width = 5, uiOutput("ui_dash_sentiment_breakdown"))
                )
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("chart-bar")),
                  div(class = "empty-state-title", "No Sentiment Analysis Executed"),
                  div(class = "empty-state-text", "Run sentiment analysis to generate sentiment distribution results."),
                  actionButton("btn_goto_sentiment", "Run Sentiment Analysis", class = "btn-primary btn-sm")
                )
              }
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("font"), " Most Discussed Terms"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$freq_data)) {
                plotOutput("plot_dash_freq", height = "280px")
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("sort-alpha-down")),
                  div(class = "empty-state-title", "No Text Mining Results Yet"),
                  div(class = "empty-state-text", "Run text preprocessing and mining to extract term frequencies."),
                  actionButton("btn_goto_preprocessing", "Run Text Preprocessing", class = "btn-primary btn-sm")
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
            div(class = "analytics-card-header", icon("brain"), " Supervised ML Model Performance"),
            div(
              class = "analytics-card-body",
              if (!is.null(rv$ml_eval)) {
                tableOutput("tbl_dash_ml_summary")
              } else if (is.null(rv$label_col) && !is.null(rv$raw_data)) {
                div(
                  class = "alert alert-warning mb-0",
                  icon("info-circle"),
                  " Supervised machine-learning models require a genuine sentiment-label column."
                )
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("cogs")),
                  div(class = "empty-state-title", "Supervised ML Models"),
                  div(class = "empty-state-text", "Upload labeled data to train and compare Naive Bayes, SVM, and KNN algorithms.")
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
              span(icon("lightbulb"), " Executive Customer Insights Preview"),
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
                  div(class = "empty-state-title", "No Insights Available"),
                  div(class = "empty-state-text", "Run sentiment analysis to generate customer insights and recommendations.")
                )
              }
            )
          )
        )
      )
    )
  }

  # Render Dashboard Dataset Status Summary
  output$ui_dash_dataset_status_summary <- renderUI({
    if (is.null(rv$raw_data)) {
      div(
        class = "alert alert-info mb-0 d-flex align-items-center justify-content-between",
        div(
          icon("info-circle"),
          " Your analysis workspace is currently empty. Upload a CSV/TXT dataset or click a Demo button to begin."
        ),
        actionButton("btn_goto_upload_2", "Upload Dataset Now", class = "btn-primary btn-sm")
      )
    } else {
      div(
        class = "pipeline-steps-grid",
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Status"), div(class = "pipeline-step-name text-success", "✓ Loaded")),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "File"), div(class = "pipeline-step-name", rv$file_name)),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Records"), div(class = "pipeline-step-name", nrow(rv$raw_data))),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Columns"), div(class = "pipeline-step-name", ncol(rv$raw_data))),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Text Column"), div(class = "pipeline-step-name text-primary", rv$text_col)),
        div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Labels"), div(class = "pipeline-step-name", if(!is.null(rv$label_col)) span(class = "badge-pass", rv$label_col) else span(class = "badge-warn", "Unlabeled")))
      )
    }
  })

  # Render Dashboard Sentiment Breakdown Box
  output$ui_dash_sentiment_breakdown <- renderUI({
    req(rv$sentiment_data)
    kpis <- calculate_sentiment_kpis(rv$sentiment_data)
    tagList(
      div(class = "insight-theme-box mb-2", div(class = "insight-theme-title text-success", icon("thumbs-up"), sprintf("Positive: %.1f%%", kpis$Pos_Pct)), p(sprintf("%d customer reviews", kpis$Pos_Count), class = "mb-0 small text-muted")),
      div(class = "insight-theme-box mb-2", div(class = "insight-theme-title text-warning", icon("minus-circle"), sprintf("Neutral: %.1f%%", kpis$Neu_Pct)), p(sprintf("%d customer reviews", kpis$Neu_Count), class = "mb-0 small text-muted")),
      div(class = "insight-theme-box", div(class = "insight-theme-title text-danger", icon("thumbs-down"), sprintf("Negative: %.1f%%", kpis$Neg_Pct)), p(sprintf("%d customer reviews", kpis$Neg_Count), class = "mb-0 small text-muted"))
    )
  })

  # ----------------------------------------------------------------------------
  # TAB 2: UPLOAD DATA BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_upload <- function() {
    tagList(
      ui_page_header("Upload Customer Feedback", "Import CSV or TXT files containing customer reviews, comments or social-media feedback.", "Upload Data"),

      fluidRow(
        column(
          width = 5,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("cloud-upload-alt"), " File Upload & Configuration"),
            div(
              class = "analytics-card-body",
              fileInput("file_input", "Select CSV or TXT File", accept = c(".csv", ".txt"), width = "100%"),
              helpText("Supported formats: CSV (comma-separated) or TXT (tab-delimited)."),
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
            div(
              class = "analytics-card-header",
              span(icon("info-circle"), " Dataset Information Summary"),
              if(!is.null(rv$raw_data)) div(
                actionButton("btn_replace_dataset", "Replace Dataset", icon = icon("exchange-alt"), class = "btn-outline-primary btn-sm me-2"),
                actionButton("btn_remove_dataset", "Remove Dataset", icon = icon("trash-alt"), class = "btn-header-reset btn-sm")
              ) else NULL
            ),
            div(
              class = "analytics-card-body",
              uiOutput("ui_upload_summary_cards"),
              hr(),
              h6("Dataset Raw Preview (First 10 Records):", class = "fw-bold text-dark mb-3"),
              DTOutput("tbl_raw_preview")
            )
          )
        )
      ),

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_validation", "Continue to Validation ->", class = "btn-continue-step")
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 3: DATA VALIDATION BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_validation <- function() {
    tagList(
      ui_page_header("Data Validation", "Check dataset quality before analysis.", "Data Validation"),

      uiOutput("ui_validation_status_boxes"),
      br(),

      div(
        class = "analytics-card",
        div(class = "analytics-card-header", icon("clipboard-check"), " Data Quality Diagnostic Checklist"),
        div(
          class = "analytics-card-body",
          uiOutput("ui_validation_checklist_table"),
          br(),
          uiOutput("ui_validation_notice")
        )
      ),

      div(
        class = "analytics-card",
        div(class = "analytics-card-header", icon("table"), " Dataset Structure & Column Metadata"),
        div(
          class = "analytics-card-body",
          tableOutput("tbl_validation_structure")
        )
      ),

      div(
        class = "analytics-card",
        div(class = "analytics-card-header", icon("search"), " Interactive Dataset Browser"),
        div(
          class = "analytics-card-body",
          if(!is.null(rv$raw_data)) DTOutput("tbl_validation_browser")
          else div(class = "empty-state", div(class = "empty-state-title", "No Dataset Available"))
        )
      ),

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_preprocessing", "Continue to Preprocessing ->", class = "btn-continue-step")
      )
    )
  }

  output$ui_validation_checklist_table <- renderUI({
    if (is.null(rv$raw_data)) return(NULL)
    df <- rv$raw_data
    text_c <- rv$text_col
    
    missing_cnt <- sum(is.na(df[[text_c]]))
    dup_cnt     <- sum(duplicated(df[[text_c]]))
    empty_cnt   <- sum(nchar(str_trim(as.character(df[[text_c]]))) == 0, na.rm = TRUE)
    
    tags$table(
      class = "table table-hover align-middle mb-0",
      tags$thead(
        tags$tr(
          tags$th("Quality Check Parameter"),
          tags$th("Diagnostic Result"),
          tags$th("Status Badge")
        )
      ),
      tags$tbody(
        tags$tr(
          tags$td("Text Column Detection"),
          tags$td(sprintf("Target column '%s' identified", text_c)),
          tags$td(span(class = "badge-pass", "✓ PASS"))
        ),
        tags$tr(
          tags$td("Missing Text Records"),
          tags$td(sprintf("%d missing NA values found", missing_cnt)),
          tags$td(if(missing_cnt == 0) span(class = "badge-pass", "✓ PASS") else span(class = "badge-warn", sprintf("⚠ %d MISSING", missing_cnt)))
        ),
        tags$tr(
          tags$td("Duplicate Customer Text"),
          tags$td(sprintf("%d duplicate review records found", dup_cnt)),
          tags$td(if(dup_cnt == 0) span(class = "badge-pass", "✓ PASS") else span(class = "badge-warn", sprintf("⚠ %d DUPLICATES", dup_cnt)))
        ),
        tags$tr(
          tags$td("Empty Text Strings"),
          tags$td(sprintf("%d zero-length text strings found", empty_cnt)),
          tags$td(if(empty_cnt == 0) span(class = "badge-pass", "✓ PASS") else span(class = "badge-warn", sprintf("⚠ %d EMPTY", empty_cnt)))
        ),
        tags$tr(
          tags$td("Supervised Sentiment Label"),
          tags$td(if(!is.null(rv$label_col)) sprintf("Label column '%s' present", rv$label_col) else "No label column specified"),
          tags$td(if(!is.null(rv$label_col)) span(class = "badge-pass", "✓ LABELED") else span(class = "badge-warn", "⚠ UNLABELED"))
        )
      )
    )
  })

  output$tbl_validation_browser <- renderDT({
    req(rv$raw_data)
    datatable(rv$raw_data, options = list(pageLength = 8, scrollX = TRUE))
  })

  # ----------------------------------------------------------------------------
  # TAB 4: PREPROCESSING BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_preprocessing <- function() {
    tagList(
      ui_page_header("Text Preprocessing", "Clean and transform raw customer feedback into analysis-ready text.", "Preprocessing"),

      div(
        class = "analytics-card",
        div(class = "analytics-card-header", icon("project-diagram"), " Visual Preprocessing Pipeline Process"),
        div(
          class = "analytics-card-body",
          div(
            class = "pipeline-steps-grid",
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 1"), div(class = "pipeline-step-name", "RAW TEXT")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 2"), div(class = "pipeline-step-name", "LOWERCASE")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 3"), div(class = "pipeline-step-name", "REMOVE URLs")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 4"), div(class = "pipeline-step-name", "PUNCTUATION")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 5"), div(class = "pipeline-step-name", "NUMBERS")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 6"), div(class = "pipeline-step-name", "STOPWORDS")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 7"), div(class = "pipeline-step-name", "STEMMING")),
            div(class = "pipeline-step-card", div(class = "pipeline-step-num", "Step 8"), div(class = "pipeline-step-name", "CLEAN TEXT"))
          )
        )
      ),

      fluidRow(
        column(
          width = 4,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("sliders-h"), " Pipeline Controls"),
            div(
              class = "analytics-card-body",
              checkboxInput("chk_stopwords", "Remove English Stop Words", value = TRUE),
              checkboxInput("chk_stemming", "Apply Porter Stemming", value = TRUE),
              hr(),
              uiOutput("ui_preprocess_button"),
              br(),
              actionButton("btn_reset_preprocess", "Reset Preprocessing", icon = icon("undo"), class = "btn-outline-primary w-100 mt-2")
            )
          )
        ),
        column(
          width = 8,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("exchange-alt"), " Original vs Cleaned Text Comparison"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$processed_data)) {
                DTOutput("tbl_preprocess_compare")
              } else {
                div(
                  class = "empty-state",
                  div(class = "empty-state-icon", icon("cogs")),
                  div(class = "empty-state-title", "Preprocessing Has Not Been Completed"),
                  div(class = "empty-state-text", "Click 'Run Preprocessing' to clean and transform raw customer text.")
                )
              }
            )
          )
        )
      ),

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_text_mining", "Continue to Text Mining ->", class = "btn-continue-step")
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 5: TEXT MINING BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_text_mining <- function() {
    tagList(
      ui_page_header("Text Mining", "Discover important words, terms and patterns in customer feedback.", "Text Mining"),

      div(
        class = "analytics-card mb-3",
        div(
          class = "analytics-card-body py-2 d-flex align-items-center justify-content-between",
          div(
            class = "d-flex align-items-center gap-3",
            span(class = "fw-bold text-dark", "Top Terms Filter:"),
            selectInput("sel_top_n_freq", NULL, choices = c(10, 20, 30, 50), selected = 20, width = "120px")
          ),
          actionButton("btn_refresh_text_mining", "Refresh Analysis", icon = icon("sync"), class = "btn-outline-primary btn-sm")
        )
      ),

      if (is.null(rv$freq_data)) {
        div(
          class = "analytics-card",
          div(class = "analytics-card-header", icon("search"), " Text Mining Results"),
          div(
            class = "analytics-card-body",
            div(
              class = "empty-state",
              div(class = "empty-state-icon", icon("sort-alpha-down")),
              div(class = "empty-state-title", "No text-mining results available."),
              div(class = "empty-state-text", "Run text preprocessing to discover key terms, frequencies, and TF-IDF weights."),
              actionButton("btn_goto_preprocessing", "Run Preprocessing", class = "btn-primary btn-sm")
            )
          )
        )
      } else {
        navset_card_tab(
          nav_panel(
            title = "WORD FREQUENCY",
            fluidRow(
              column(width = 6, plotOutput("plot_word_freq", height = "400px")),
              column(width = 6, DTOutput("tbl_word_freq"))
            )
          ),
          nav_panel(
            title = "TF-IDF",
            div(
              class = "alert alert-info py-2 mb-3",
              icon("info-circle"), " TF-IDF (Term Frequency-Inverse Document Frequency) measures how important a term is across the customer review corpus."
            ),
            fluidRow(
              column(width = 6, plotOutput("plot_tfidf", height = "400px")),
              column(width = 6, DTOutput("tbl_tfidf"))
            )
          ),
          nav_panel(
            title = "WORD CLOUD",
            div(style = "text-align: center; padding: 1.5rem;", plotOutput("plot_wordcloud", height = "480px"))
          ),
          nav_panel(
            title = "KEYWORDS",
            DTOutput("tbl_keywords")
          )
        )
      },

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_sentiment", "Continue to Sentiment Analysis ->", class = "btn-continue-step")
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 6: SENTIMENT ANALYSIS BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_sentiment <- function() {
    tagList(
      ui_page_header("Sentiment Analysis", "Classify customer feedback into Positive, Neutral and Negative sentiment.", "Sentiment Analysis"),

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
            div(class = "analytics-card-header", icon("chart-bar"), " Sentiment Distribution"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) plotOutput("plot_sentiment_dist", height = "360px")
              else div(class = "empty-state", div(class = "empty-state-title", "Run sentiment analysis to generate sentiment results."), actionButton("btn_run_sentiment_inline", "Run Sentiment Analysis", class = "btn-primary btn-sm"))
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("table"), " Sentiment Results Table"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) DTOutput("tbl_sentiment_results")
              else div(class = "empty-state", div(class = "empty-state-title", "No Sentiment Data Available"))
            )
          )
        )
      ),

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_ml", "Continue to Machine Learning ->", class = "btn-continue-step")
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 7: MACHINE LEARNING BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_ml <- function() {
    tagList(
      ui_page_header("Machine Learning", "Train and compare supervised sentiment-classification models using TF-IDF features.", "Machine Learning"),

      uiOutput("ui_ml_status_banner"),

      div(
        class = "model-card-grid",
        div(
          class = "model-card",
          div(
            div(class = "model-card-title", "NAIVE BAYES"),
            div(class = "model-card-desc", "Probabilistic classifier based on Bayes' Theorem assuming feature independence."),
            uiOutput("ui_ml_card_metrics_nb")
          ),
          actionButton("btn_run_nb", "Run Naive Bayes", icon = icon("play"), class = "btn-outline-primary w-100")
        ),
        div(
          class = "model-card",
          div(
            div(class = "model-card-title", "SVM"),
            div(class = "model-card-desc", "Support Vector Machine max-margin classifier in TF-IDF feature space."),
            uiOutput("ui_ml_card_metrics_svm")
          ),
          actionButton("btn_run_svm", "Run SVM", icon = icon("play"), class = "btn-outline-primary w-100")
        ),
        div(
          class = "model-card",
          div(
            div(class = "model-card-title", "KNN"),
            div(class = "model-card-desc", "K-Nearest Neighbors instance-based classifier using term Euclidean distance."),
            uiOutput("ui_ml_card_metrics_knn")
          ),
          actionButton("btn_run_knn", "Run KNN", icon = icon("play"), class = "btn-outline-primary w-100")
        )
      ),

      fluidRow(
        column(
          width = 4,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("cogs"), " Supervised Training Execution"),
            div(
              class = "analytics-card-body",
              p("Algorithms: ", tags$strong("Naive Bayes, SVM, KNN")),
              p("Feature Matrix: ", tags$strong("TF-IDF Vector Space")),
              p("Train/Test Split: ", tags$strong("80% Training / 20% Testing")),
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
            div(class = "analytics-card-header", icon("terminal"), " Machine Learning Console Output"),
            div(
              class = "analytics-card-body",
              verbatimTextOutput("txt_ml_log")
            )
          )
        )
      ),

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_evaluation", "Continue to Model Evaluation ->", class = "btn-continue-step")
      )
    )
  }

  output$ui_ml_card_metrics_nb <- renderUI({
    if (!is.null(rv$ml_eval)) {
      row <- rv$ml_eval$Comparison_Table %>% filter(Model == "Naive Bayes")
      div(class = "model-card-metrics",
          div(class = "model-metric-item", div(class = "model-metric-label", "Accuracy"), div(class = "model-metric-value", sprintf("%.1f%%", row$Accuracy * 100))),
          div(class = "model-metric-item", div(class = "model-metric-label", "F1 Score"), div(class = "model-metric-value", sprintf("%.1f%%", row$F1_Score * 100)))
      )
    } else div(class = "model-card-metrics", div(class = "model-metric-item", div(class = "model-metric-label", "Status"), div(class = "model-metric-value text-muted", if(is.null(rv$label_col)) "Unavailable" else "Not Run")))
  })

  output$ui_ml_card_metrics_svm <- renderUI({
    if (!is.null(rv$ml_eval)) {
      row <- rv$ml_eval$Comparison_Table %>% filter(Model == "SVM")
      div(class = "model-card-metrics",
          div(class = "model-metric-item", div(class = "model-metric-label", "Accuracy"), div(class = "model-metric-value", sprintf("%.1f%%", row$Accuracy * 100))),
          div(class = "model-metric-item", div(class = "model-metric-label", "F1 Score"), div(class = "model-metric-value", sprintf("%.1f%%", row$F1_Score * 100)))
      )
    } else div(class = "model-card-metrics", div(class = "model-metric-item", div(class = "model-metric-label", "Status"), div(class = "model-metric-value text-muted", if(is.null(rv$label_col)) "Unavailable" else "Not Run")))
  })

  output$ui_ml_card_metrics_knn <- renderUI({
    if (!is.null(rv$ml_eval)) {
      row <- rv$ml_eval$Comparison_Table %>% filter(Model == "KNN")
      div(class = "model-card-metrics",
          div(class = "model-metric-item", div(class = "model-metric-label", "Accuracy"), div(class = "model-metric-value", sprintf("%.1f%%", row$Accuracy * 100))),
          div(class = "model-metric-item", div(class = "model-metric-label", "F1 Score"), div(class = "model-metric-value", sprintf("%.1f%%", row$F1_Score * 100)))
      )
    } else div(class = "model-card-metrics", div(class = "model-metric-item", div(class = "model-metric-label", "Status"), div(class = "model-metric-value text-muted", if(is.null(rv$label_col)) "Unavailable" else "Not Run")))
  })

  # ----------------------------------------------------------------------------
  # TAB 8: MODEL EVALUATION BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_evaluation <- function() {
    tagList(
      ui_page_header("Model Evaluation", "Evaluate supervised sentiment models using standard classification metrics.", "Model Evaluation"),

      if (is.null(rv$ml_eval)) {
        div(
          class = "analytics-card",
          div(class = "analytics-card-header", icon("chart-line"), " Model Evaluation Status"),
          div(
            class = "analytics-card-body",
            if (is.null(rv$label_col)) {
              div(
                class = "unlabeled-warning-card mb-0",
                div(class = "unlabeled-warning-title", icon("exclamation-triangle"), " SUPERVISED EVALUATION UNAVAILABLE"),
                p(class = "unlabeled-warning-desc", "Supervised model evaluation requires a genuine sentiment-label column. Lexicon-based sentiment analysis is active.")
              )
            } else {
              div(
                class = "empty-state",
                div(class = "empty-state-icon", icon("chart-line")),
                div(class = "empty-state-title", "Run supervised model before viewing evaluation metrics."),
                div(class = "empty-state-text", "Navigate to Machine Learning tab and execute models to generate performance metrics."),
                actionButton("btn_goto_ml", "Go to Machine Learning", class = "btn-primary btn-sm")
              )
            }
          )
        )
      } else {
        best_m <- rv$ml_eval$Best_Model
        tagList(
          div(
            class = "alert alert-success mb-4 d-flex align-items-center gap-3",
            icon("trophy", class = "fs-2 text-warning"),
            div(
              tags$strong("Best Performing Algorithm: "),
              sprintf("%s achieved top overall performance with Accuracy of %.2f%% and F1-Score of %.2f%%.",
                      best_m, rv$ml_eval$Best_Accuracy * 100, rv$ml_eval$Best_F1 * 100)
            )
          ),

          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("table"), " MODEL COMPARISON Table"),
            div(
              class = "analytics-card-body",
              tableOutput("tbl_model_comparison")
            )
          ),

          div(
            class = "analytics-card",
            div(
              class = "analytics-card-header",
              span(icon("th"), " Confusion Matrix"),
              selectInput("sel_cm_model", "Select Model:", choices = c("All Models", "Naive Bayes", "SVM", "KNN"), selected = "All Models", width = "200px")
            ),
            div(
              class = "analytics-card-body",
              uiOutput("ui_confusion_matrices_display")
            )
          )
        )
      },

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_visualization", "Continue to Visualization ->", class = "btn-continue-step")
      )
    )
  }

  output$ui_confusion_matrices_display <- renderUI({
    req(rv$ml_eval)
    sel <- input$sel_cm_model
    
    if (is.null(sel) || sel == "All Models") {
      fluidRow(
        column(width = 4, plotOutput("plot_cm_nb", height = "320px")),
        column(width = 4, plotOutput("plot_cm_svm", height = "320px")),
        column(width = 4, plotOutput("plot_cm_knn", height = "320px"))
      )
    } else if (sel == "Naive Bayes") {
      plotOutput("plot_cm_nb", height = "400px")
    } else if (sel == "SVM") {
      plotOutput("plot_cm_svm", height = "400px")
    } else {
      plotOutput("plot_cm_knn", height = "400px")
    }
  })

  # ----------------------------------------------------------------------------
  # TAB 9: VISUALIZATION BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_visualization <- function() {
    tagList(
      ui_page_header("Visualization", "Explore sentiment, term frequency, TF-IDF and model-performance patterns.", "Visualization"),

      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("chart-pie"), " Sentiment Distribution"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$sentiment_data)) plotOutput("plot_viz_sentiment", height = "320px")
              else div(class = "empty-state", div(class = "empty-state-icon", icon("chart-pie")), div(class = "empty-state-title", "Run sentiment analysis to generate distribution."))
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("bar-chart"), " Top Frequent Terms"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$freq_data)) plotOutput("plot_viz_freq", height = "320px")
              else div(class = "empty-state", div(class = "empty-state-icon", icon("sort-alpha-down")), div(class = "empty-state-title", "Run text mining to generate term frequencies."))
            )
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("sort-amount-up"), " TF-IDF Terms"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$tfidf_data)) plotOutput("plot_viz_tfidf", height = "320px")
              else div(class = "empty-state", div(class = "empty-state-icon", icon("filter")), div(class = "empty-state-title", "Run text mining to calculate TF-IDF weights."))
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("cloud"), " Word Cloud"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$freq_data)) plotOutput("plot_wordcloud", height = "320px")
              else div(class = "empty-state", div(class = "empty-state-icon", icon("cloud")), div(class = "empty-state-title", "Run text mining to render word cloud."))
            )
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("chart-bar"), " Model Comparison"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$ml_eval)) plotOutput("plot_viz_ml_comp", height = "320px")
              else div(class = "empty-state", div(class = "empty-state-icon", icon("brain")), div(class = "empty-state-title", "Supervised ML evaluation required for model comparison."))
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("th"), " Confusion Matrix"),
            div(
              class = "analytics-card-body",
              if(!is.null(rv$ml_eval)) plotOutput("plot_cm_nb", height = "320px")
              else div(class = "empty-state", div(class = "empty-state-icon", icon("th")), div(class = "empty-state-title", "Supervised ML evaluation required for confusion matrix."))
            )
          )
        )
      ),

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_insights_2", "Continue to Customer Insights ->", class = "btn-continue-step")
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 10: CUSTOMER INSIGHTS BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_insights <- function() {
    tagList(
      ui_page_header("Customer Insights", "Translate customer feedback into understandable findings.", "Customer Insights"),

      if (is.null(rv$insights_data)) {
        div(
          class = "analytics-card",
          div(class = "analytics-card-header", icon("lightbulb"), " Executive Customer Insights"),
          div(
            class = "analytics-card-body",
            div(
              class = "empty-state",
              div(class = "empty-state-icon", icon("lightbulb")),
              div(class = "empty-state-title", "No Insights Available"),
              div(class = "empty-state-text", "Run text preprocessing and sentiment analysis to generate dynamic executive insights."),
              actionButton("btn_goto_sentiment_2", "Go to Sentiment Analysis", class = "btn-primary btn-sm")
            )
          )
        )
      } else {
        ins <- rv$insights_data
        
        tagList(
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("chart-line"), " OVERALL SENTIMENT"),
            div(class = "analytics-card-body", p(ins$Executive_Summary, class = "lead fw-bold text-dark mb-0"))
          ),
          if (!is.null(ins$ML_Insight)) {
            div(
              class = "analytics-card",
              div(class = "analytics-card-header", icon("brain"), " MACHINE LEARNING PERFORMANCE INSIGHT"),
              div(class = "analytics-card-body", p(ins$ML_Insight, class = "mb-0"))
            )
          },
          fluidRow(
            column(
              width = 6,
              div(
                class = "analytics-card",
                div(class = "analytics-card-header", icon("thumbs-up"), " WHAT CUSTOMERS LIKE"),
                div(
                  class = "analytics-card-body",
                  div(
                    class = "d-flex flex-wrap gap-2",
                    if(length(ins$Positive_Themes) > 0) lapply(ins$Positive_Themes, function(x) span(class = "badge-pos", icon("check"), x))
                    else span(class = "text-muted", "No specific positive themes extracted.")
                  )
                )
              )
            ),
            column(
              width = 6,
              div(
                class = "analytics-card",
                div(class = "analytics-card-header", icon("thumbs-down"), " WHAT CUSTOMERS DISLIKE / COMMON ISSUES"),
                div(
                  class = "analytics-card-body",
                  div(
                    class = "d-flex flex-wrap gap-2",
                    if(length(ins$Negative_Themes) > 0) lapply(ins$Negative_Themes, function(x) span(class = "badge-neg", icon("exclamation-triangle"), x))
                    else span(class = "text-muted", "No specific negative themes extracted.")
                  )
                )
              )
            )
          ),
          div(
            class = "analytics-card",
            div(class = "analytics-card-header", icon("lightbulb"), " RECOMMENDATIONS"),
            div(
              class = "analytics-card-body",
              lapply(ins$Recommendations, function(rec) {
                div(
                  class = "recommendation-card",
                  span(class = "recommendation-card-icon", icon("lightbulb")),
                  rec
                )
              })
            )
          )
        )
      },

      div(
        class = "d-flex justify-content-end mt-3",
        actionButton("btn_goto_export", "Export Results & Download ->", class = "btn-continue-step")
      )
    )
  }

  # ----------------------------------------------------------------------------
  # TAB 11: RESULTS & DOWNLOAD BUILDER
  # ----------------------------------------------------------------------------
  ui_tab_export <- function() {
    tagList(
      ui_page_header("Results & Download", "Export analysis results for further study and reporting.", "Results & Download"),

      div(
        class = "export-card-grid",
        div(
          class = "export-card",
          div(class = "export-card-icon", icon("file-csv")),
          div(class = "export-card-title", "PROCESSED DATA"),
          div(class = "export-card-desc", "Download cleaned customer text dataset."),
          if(!is.null(rv$processed_data)) downloadButton("download_processed", "Download CSV", class = "btn-outline-primary w-100")
          else actionButton("btn_down_disabled_1", "Run preprocessing first", class = "btn-secondary w-100", disabled = TRUE)
        ),
        div(
          class = "export-card",
          div(class = "export-card-icon", icon("smile")),
          div(class = "export-card-title", "SENTIMENT RESULTS"),
          div(class = "export-card-desc", "Download lexicon sentiment classifications."),
          if(!is.null(rv$sentiment_data)) downloadButton("download_sentiment", "Download CSV", class = "btn-success w-100")
          else actionButton("btn_down_disabled_2", "Run sentiment analysis first", class = "btn-secondary w-100", disabled = TRUE)
        ),
        div(
          class = "export-card",
          div(class = "export-card-icon", icon("chart-bar")),
          div(class = "export-card-title", "MODEL PERFORMANCE"),
          div(class = "export-card-desc", "Download ML metrics (NB, SVM, KNN)."),
          if(!is.null(rv$ml_eval)) downloadButton("download_ml_metrics", "Download CSV", class = "btn-outline-primary w-100")
          else actionButton("btn_down_disabled_3", "Run supervised ML first", class = "btn-secondary w-100", disabled = TRUE)
        ),
        div(
          class = "export-card",
          div(class = "export-card-icon", icon("file-alt")),
          div(class = "export-card-title", "CUSTOMER INSIGHTS"),
          div(class = "export-card-desc", "Download generated narrative report."),
          if(!is.null(rv$insights_data)) downloadButton("download_report", "Download TXT", class = "btn-primary w-100")
          else actionButton("btn_down_disabled_4", "Generate insights first", class = "btn-secondary w-100", disabled = TRUE)
        )
      ),

      div(
        class = "analytics-card",
        div(class = "analytics-card-header", icon("table"), " COMPLETE RESULTS"),
        div(
          class = "analytics-card-body",
          if(!is.null(rv$sentiment_data)) DTOutput("tbl_full_results")
          else div(class = "empty-state", div(class = "empty-state-title", "No Results Ready for Export"), div(class = "empty-state-text", "Run sentiment analysis to view complete results table."))
        )
      )
    )
  }

  # ----------------------------------------------------------------------------
  # OBSERVERS & EVENT HANDLERS (Preserving 100% backend logic)
  # ----------------------------------------------------------------------------
  
  # Navigation Shortcuts & Sequential Step Buttons
  observeEvent(input$btn_goto_upload, { updateNavlistPanel(session, "main_nav", selected = "tab_upload") })
  observeEvent(input$btn_goto_upload_2, { updateNavlistPanel(session, "main_nav", selected = "tab_upload") })
  observeEvent(input$btn_goto_validation, { updateNavlistPanel(session, "main_nav", selected = "tab_validation") })
  observeEvent(input$btn_goto_preprocessing, { updateNavlistPanel(session, "main_nav", selected = "tab_preprocessing") })
  observeEvent(input$btn_goto_text_mining, { updateNavlistPanel(session, "main_nav", selected = "tab_text_mining") })
  observeEvent(input$btn_goto_sentiment, { updateNavlistPanel(session, "main_nav", selected = "tab_sentiment") })
  observeEvent(input$btn_goto_sentiment_2, { updateNavlistPanel(session, "main_nav", selected = "tab_sentiment") })
  observeEvent(input$btn_goto_ml, { updateNavlistPanel(session, "main_nav", selected = "tab_ml") })
  observeEvent(input$btn_goto_evaluation, { updateNavlistPanel(session, "main_nav", selected = "tab_evaluation") })
  observeEvent(input$btn_goto_visualization, { updateNavlistPanel(session, "main_nav", selected = "tab_visualization") })
  observeEvent(input$btn_goto_insights, { updateNavlistPanel(session, "main_nav", selected = "tab_insights") })
  observeEvent(input$btn_goto_insights_2, { updateNavlistPanel(session, "main_nav", selected = "tab_insights") })
  observeEvent(input$btn_goto_export, { updateNavlistPanel(session, "main_nav", selected = "tab_export") })

  # GLOBAL RESET ANALYSIS MODAL
  observeEvent(input$btn_reset_modal, {
    showModal(modalDialog(
      title = div(class = "fw-bold text-danger", icon("exclamation-triangle"), " Reset Current Analysis Workspace?"),
      p("This will reset all uploaded datasets, cleaned text matrices, sentiment classifications, ML models, and generated insights."),
      p(class = "small text-muted", "Note: No files will be deleted from your computer."),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("btn_confirm_reset", "Reset Workspace", class = "btn-danger")
      ),
      easyClose = TRUE
    ))
  })

  observeEvent(input$btn_confirm_reset, {
    rv$raw_data       <- NULL
    rv$file_name      <- NULL
    rv$file_size_str  <- NULL
    rv$text_col       <- NULL
    rv$label_col      <- NULL
    rv$processed_data <- NULL
    rv$freq_data      <- NULL
    rv$tfidf_data     <- NULL
    rv$sentiment_data <- NULL
    rv$ml_results     <- NULL
    rv$ml_eval        <- NULL
    rv$insights_data  <- NULL
    rv$app_status     <- "Ready for Analysis"
    rv$ml_log         <- "Awaiting dataset upload and machine learning execution..."
    
    removeModal()
    showNotification("Analysis workspace reset successfully!", type = "warning")
    updateNavlistPanel(session, "main_nav", selected = "tab_dashboard")
  })

  # REMOVE DATASET ACTION
  observeEvent(input$btn_remove_dataset, {
    rv$raw_data       <- NULL
    rv$file_name      <- NULL
    rv$text_col       <- NULL
    rv$label_col      <- NULL
    rv$processed_data <- NULL
    rv$freq_data      <- NULL
    rv$tfidf_data     <- NULL
    rv$sentiment_data <- NULL
    rv$ml_results     <- NULL
    rv$ml_eval        <- NULL
    rv$insights_data  <- NULL
    rv$app_status     <- "Ready for Analysis"
    showNotification("Dataset removed from active workspace.", type = "warning")
  })

  observeEvent(input$btn_replace_dataset, {
    updateNavlistPanel(session, "main_nav", selected = "tab_upload")
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
    selectInput("sel_text_col", "Select Customer Text Column:", choices = colnames(rv$raw_data), selected = rv$text_col)
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

  observeEvent(input$btn_reset_preprocess, {
    rv$processed_data <- NULL
    rv$freq_data      <- NULL
    rv$tfidf_data     <- NULL
    showNotification("Preprocessing results cleared.", type = "warning")
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
  observeEvent(input$btn_refresh_text_mining, {
    req(rv$processed_data)
    n_val <- as.numeric(input$sel_top_n_freq)
    rv$freq_data  <- get_word_frequencies(rv$processed_data$cleaned_text, top_n = 100)
    rv$tfidf_data <- compute_tfidf(rv$processed_data$cleaned_text)
    showNotification("Text mining metrics refreshed!", type = "message")
  })

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
    n_val <- as.numeric(input$sel_top_n_freq)
    plot_tfidf_terms(rv$tfidf_data, top_n = n_val)
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

  run_sentiment_exec <- function() {
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
  }

  observeEvent(input$btn_run_sentiment, { run_sentiment_exec() })
  observeEvent(input$btn_run_sentiment_inline, { run_sentiment_exec() })
  
  output$ui_sentiment_kpis <- renderUI({
    req(rv$sentiment_data)
    kpis <- calculate_sentiment_kpis(rv$sentiment_data)
    
    div(
      class = "kpi-grid",
      div(class = "kpi-card kpi-total", div(class = "kpi-title", "Total Reviews"), div(class = "kpi-value", kpis$Total)),
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
        class = "unlabeled-warning-card mb-3",
        div(class = "unlabeled-warning-title", icon("exclamation-triangle"), " SUPERVISED MODELS UNAVAILABLE"),
        p(class = "unlabeled-warning-desc", "This dataset does not contain a genuine sentiment-label column. Lexicon-based sentiment analysis is active, but supervised machine-learning model training requires labeled data.")
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
      actionButton("btn_run_ml", "Run All ML Models (NB, SVM, KNN)", icon = icon("play-circle"), class = "btn-primary w-100")
    }
  })

  # Helper: ML Model Execution
  run_ml_pipeline <- function() {
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
          "Supervised Machine Learning Completed Successfully!\nBest Performing Model: %s\nAccuracy: %.2f%%\nF1-Score: %.2f%%\nTrain Samples: %d\nTest Samples: %d",
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
  }

  observeEvent(input$btn_run_ml, { run_ml_pipeline() })
  observeEvent(input$btn_run_nb, { run_ml_pipeline() })
  observeEvent(input$btn_run_svm, { run_ml_pipeline() })
  observeEvent(input$btn_run_knn, { run_ml_pipeline() })

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
        div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Negative Reviews"), div(class = "kpi-value", paste0(kpis$Neg_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Neg_Count, "reviews"))),
        if (!is.null(rv$ml_eval)) div(class = "kpi-card kpi-ml-acc", div(class = "kpi-title", "Best Model Accuracy"), div(class = "kpi-value", sprintf("%.1f%%", rv$ml_eval$Best_Accuracy * 100)), div(class = "kpi-subtext", rv$ml_eval$Best_Model)) else NULL,
        if (!is.null(rv$ml_eval)) div(class = "kpi-card kpi-ml-f1", div(class = "kpi-title", "Best Model F1 Score"), div(class = "kpi-value", sprintf("%.1f%%", rv$ml_eval$Best_F1 * 100)), div(class = "kpi-subtext", rv$ml_eval$Best_Model)) else NULL
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
    rv$ml_eval$Comparison_Table %>% select(Model, Accuracy, Precision, Recall, F1_Score)
  }, digits = 4)

  output$ui_dash_quick_insights <- renderUI({
    req(rv$insights_data)
    ins <- rv$insights_data
    tagList(
      p(tags$strong("Executive Summary: "), ins$Executive_Summary),
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
