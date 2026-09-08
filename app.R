# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Main Shiny Application (app.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(dplyr)
  library(readr)
  library(stringr)
  library(tidytext)
  library(tm)
  library(SnowballC)
  library(ggplot2)
  library(wordcloud)
  library(wordcloud2)
  library(e1071)
  library(class)
  library(Matrix)
  library(DT)
  library(tidyr)
  library(syuzhet)
})

# Source modular backend scripts
source("R/preprocessing.R", local = TRUE)
source("R/text_mining.R", local = TRUE)
source("R/sentiment_analysis.R", local = TRUE)
source("R/machine_learning.R", local = TRUE)
source("R/evaluation.R", local = TRUE)
source("R/visualization.R", local = TRUE)
source("R/insights.R", local = TRUE)

# Set seed for reproducibility across all random ops
set.seed(123)

# Define Shiny User Interface (UI)
ui <- page_navbar(
  title = "LG9 – Customer Sentiment Analysis in R",
  theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#2563eb"),
  header = tags$head(
    includeCSS("www/styles.css"),
    tags$div(
      class = "main-header",
      tags$h1("LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R"),
      tags$p("An Academic R-based Application for Text Preprocessing, Mining, Lexicon Sentiment Analysis, Machine Learning, & Customer Insights")
    )
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 1: DASHBOARD / HOME
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Dashboard",
    icon = icon("home"),
    fluidRow(
      column(
        width = 12,
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Project Overview & Key Capabilities"),
          div(
            class = "academic-card-body",
            p("Welcome to the LG9 Customer Sentiment Analysis platform. This system processes raw customer reviews and social media feedback using robust text mining, lexicon-based sentiment analysis, supervised machine learning (Naive Bayes, SVM, KNN), and dynamic visualizations."),
            hr(),
            h5("Core Capabilities:", class = "fw-bold text-primary"),
            tags$ul(
              tags$li(tags$strong("Text Mining:"), " Automated tokenization, word frequency, TF-IDF calculation, word clouds, and key term extraction."),
              tags$li(tags$strong("Sentiment Analysis:"), " Baseline lexicon-based classification into Positive, Neutral, and Negative categories."),
              tags$li(tags$strong("Supervised Machine Learning:"), " When ground-truth labels exist, trains Naive Bayes, SVM, and KNN models using 80/20 train/test split."),
              tags$li(tags$strong("Model Evaluation:"), " Calculates Accuracy, Precision, Recall, F1-Score, and tabular Confusion Matrices."),
              tags$li(tags$strong("Customer Insights:"), " Extracts positive/negative opinion themes and generates data-supported recommendations."),
              tags$li(tags$strong("Export Results:"), " Interactive DT tables and CSV export of clean data, sentiment scores, and metrics.")
            ),
            br(),
            div(
              style = "display: flex; gap: 1rem; align-items: center;",
              actionButton("btn_goto_upload", "Upload Dataset", icon = icon("file-upload"), class = "btn-primary btn-lg"),
              actionButton("btn_load_sample_labeled", "Demo: Load Sample Labeled Data", icon = icon("flask"), class = "btn-outline-success btn-lg"),
              actionButton("btn_load_sample_unlabeled", "Demo: Load Sample Unlabeled Data", icon = icon("flask"), class = "btn-outline-info btn-lg")
            )
          )
        )
      )
    ),
    
    # KPI Overview Section
    uiOutput("ui_dashboard_kpis")
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 2: UPLOAD DATA
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Upload Data",
    icon = icon("upload"),
    sidebarLayout(
      sidebarPanel(
        width = 4,
        h5("Upload Dataset", class = "fw-bold"),
        fileInput("file_input", "Choose CSV or TXT File", accept = c(".csv", ".txt")),
        helpText("Main expected format is CSV. Columns will be auto-detected."),
        hr(),
        uiOutput("ui_text_column_selector"),
        uiOutput("ui_label_column_selector"),
        br(),
        actionButton("btn_confirm_upload", "Confirm Column Selection", icon = icon("check-circle"), class = "btn-success w-100")
      ),
      mainPanel(
        width = 8,
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Dataset Overview & Structure"),
          div(
            class = "academic-card-body",
            uiOutput("ui_upload_summary"),
            hr(),
            h6("Dataset Preview (First Few Records):", class = "fw-bold"),
            DTOutput("tbl_raw_preview")
          )
        )
      )
    )
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 3: DATA VALIDATION
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Data Validation",
    icon = icon("clipboard-check"),
    fluidRow(
      column(
        width = 12,
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Dataset Quality & Integrity Checks"),
          div(
            class = "academic-card-body",
            uiOutput("ui_validation_status_boxes"),
            hr(),
            uiOutput("ui_validation_notice")
          )
        )
      )
    )
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 4: PREPROCESSING
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Preprocessing",
    icon = icon("cogs"),
    sidebarLayout(
      sidebarPanel(
        width = 4,
        h5("Preprocessing Controls", class = "fw-bold"),
        checkboxInput("chk_stopwords", "Remove English Stop Words", value = TRUE),
        checkboxInput("chk_stemming", "Apply Porter Stemming", value = TRUE),
        br(),
        actionButton("btn_run_preprocess", "Run Preprocessing Pipeline", icon = icon("play"), class = "btn-primary w-100"),
        hr(),
        h6("Pipeline Operations:", class = "fw-bold"),
        tags$ol(
          tags$li("Convert text to lowercase"),
          tags$li("Remove URLs & web links"),
          tags$li("Remove Email addresses"),
          tags$li("Remove @mentions"),
          tags$li("Strip hashtag symbols"),
          tags$li("Remove punctuation & digits"),
          tags$li("Remove special characters"),
          tags$li("Remove extra whitespace"),
          tags$li("Filter stop words & Stem terms")
        )
      ),
      mainPanel(
        width = 8,
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Original vs Cleaned Text Comparison"),
          div(
            class = "academic-card-body",
            DTOutput("tbl_preprocess_compare")
          )
        )
      )
    )
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 5: TEXT MINING
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Text Mining",
    icon = icon("font"),
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
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 6: SENTIMENT ANALYSIS
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Sentiment Analysis",
    icon = icon("smile"),
    fluidRow(
      column(width = 12, actionButton("btn_run_sentiment", "Run Lexicon Sentiment Analysis", icon = icon("magic"), class = "btn-primary btn-lg mb-3"))
    ),
    uiOutput("ui_sentiment_kpis"),
    br(),
    fluidRow(
      column(width = 6, plotOutput("plot_sentiment_dist", height = "380px")),
      column(
        width = 6,
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Per-Review Sentiment Results"),
          div(class = "academic-card-body", DTOutput("tbl_sentiment_results"))
        )
      )
    )
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 7: MACHINE LEARNING
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Machine Learning",
    icon = icon("brain"),
    fluidRow(
      column(
        width = 12,
        uiOutput("ui_ml_status_banner")
      )
    ),
    fluidRow(
      column(
        width = 4,
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Supervised Training Setup"),
          div(
            class = "academic-card-body",
            p("Train Naive Bayes, SVM, and KNN algorithms using TF-IDF features."),
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
          class = "academic-card",
          div(class = "academic-card-header", "Machine Learning Pipeline Log"),
          div(
            class = "academic-card-body",
            verbatimTextOutput("txt_ml_log")
          )
        )
      )
    )
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 8: MODEL EVALUATION
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Model Evaluation",
    icon = icon("chart-line"),
    uiOutput("ui_eval_content")
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 9: VISUALIZATION
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Visualization",
    icon = icon("chart-pie"),
    navset_card_tab(
      nav_panel("Sentiment Distribution", plotOutput("plot_viz_sentiment", height = "450px")),
      nav_panel("Top Frequent Words", plotOutput("plot_viz_freq", height = "450px")),
      nav_panel("Top TF-IDF Terms", plotOutput("plot_viz_tfidf", height = "450px")),
      nav_panel("ML Models Comparison", plotOutput("plot_viz_ml_comp", height = "450px"))
    )
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 10: CUSTOMER INSIGHTS
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Customer Insights",
    icon = icon("lightbulb"),
    uiOutput("ui_insights_content")
  ),
  
  # ----------------------------------------------------------------------------
  # TAB 11: RESULTS & DOWNLOAD
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Results & Download",
    icon = icon("download"),
    sidebarLayout(
      sidebarPanel(
        width = 4,
        h5("Export Options", class = "fw-bold"),
        p("Download processed datasets and evaluation reports."),
        downloadButton("download_processed", "Download Processed Data (CSV)", class = "btn-outline-primary w-100 mb-2"),
        downloadButton("download_sentiment", "Download Sentiment Results (CSV)", class = "btn-outline-success w-100 mb-2"),
        downloadButton("download_ml_metrics", "Download ML Model Metrics (CSV)", class = "btn-outline-purple w-100 mb-2"),
        downloadButton("download_report", "Download Insights Summary (TXT)", class = "btn-outline-dark w-100")
      ),
      mainPanel(
        width = 8,
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Complete Analysis Results Table"),
          div(class = "academic-card-body", DTOutput("tbl_full_results"))
        )
      )
    )
  )
)

# Define Shiny Server Logic
server <- function(input, output, session) {
  
  # Reactive State Store
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
    ml_log            = "Awaiting dataset upload and machine learning execution..."
  )
  
  # Navigation Shortcuts
  observeEvent(input$btn_goto_upload, {
    nav_select(id = "navbar", selected = "Upload Data")
  })
  
  # Load Sample Labeled Data Demo Button
  observeEvent(input$btn_load_sample_labeled, {
    req(file.exists("data/sample/sample_reviews.csv"))
    rv$raw_data  <- read_csv("data/sample/sample_reviews.csv", show_col_types = FALSE)
    rv$file_name <- "sample_reviews.csv (Labeled Demo)"
    rv$text_col  <- "review_text"
    rv$label_col <- "sentiment"
    
    showNotification("Loaded sample labeled customer reviews dataset!", type = "message")
    nav_select(id = "navbar", selected = "Upload Data")
  })
  
  # Load Sample Unlabeled Data Demo Button
  observeEvent(input$btn_load_sample_unlabeled, {
    req(file.exists("data/sample/sample_unlabeled.csv"))
    rv$raw_data  <- read_csv("data/sample/sample_unlabeled.csv", show_col_types = FALSE)
    rv$file_name <- "sample_unlabeled.csv (Unlabeled Demo)"
    rv$text_col  <- "review_text"
    rv$label_col <- NULL
    
    showNotification("Loaded sample unlabeled customer feedback dataset!", type = "warning")
    nav_select(id = "navbar", selected = "Upload Data")
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
      
      rv$raw_data  <- df
      rv$file_name <- input$file_input$name
      
      # Auto-detect text column
      cols <- colnames(df)
      cols_lower <- tolower(cols)
      candidates <- c("review", "review_text", "comment", "feedback", "text", "message", "tweet", "opinion", "customer_feedback", "description")
      match_idx  <- which(cols_lower %in% candidates)
      
      if (length(match_idx) > 0) {
        rv$text_col <- cols[match_idx[1]]
      } else {
        rv$text_col <- cols[1] # fallback to first col
      }
      
      # Auto-detect label column
      rv$label_col <- detect_label_column(df)
      
      showNotification("File uploaded and analyzed successfully!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })
  
  # Text Column Selector Dropdown
  output$ui_text_column_selector <- renderUI({
    req(rv$raw_data)
    selectInput("sel_text_col", "Select Text Column:", choices = colnames(rv$raw_data), selected = rv$text_col)
  })
  
  # Label Column Selector Dropdown
  output$ui_label_column_selector <- renderUI({
    req(rv$raw_data)
    opts <- c("None (Unlabeled)" = "", colnames(rv$raw_data))
    selected_val <- if (!is.null(rv$label_col)) rv$label_col else ""
    selectInput("sel_label_col", "Select Sentiment Label Column (Optional):", choices = opts, selected = selected_val)
  })
  
  # Confirm Column Selection
  observeEvent(input$btn_confirm_upload, {
    req(rv$raw_data, input$sel_text_col)
    rv$text_col <- input$sel_text_col
    rv$label_col <- if (nchar(input$sel_label_col) > 0) input$sel_label_col else NULL
    showNotification("Column selections confirmed!", type = "message")
  })
  
  # Upload Summary Output
  output$ui_upload_summary <- renderUI({
    if (is.null(rv$raw_data)) {
      return(p("No dataset uploaded yet. Please upload a file or click Demo button."))
    }
    
    tagList(
      p(tags$strong("File Name: "), rv$file_name),
      p(tags$strong("Total Records (Rows): "), nrow(rv$raw_data)),
      p(tags$strong("Total Columns: "), ncol(rv$raw_data)),
      p(tags$strong("Detected Text Column: "), tags$span(class = "badge bg-primary", rv$text_col)),
      p(tags$strong("Detected Sentiment Label: "), 
        if (!is.null(rv$label_col)) tags$span(class = "badge bg-success", rv$label_col)
        else tags$span(class = "badge bg-warning text-dark", "None (Unlabeled)"))
    )
  })
  
  # Raw Preview Table
  output$tbl_raw_preview <- renderDT({
    req(rv$raw_data)
    datatable(head(rv$raw_data, 10), options = list(pageLength = 5, scrollX = TRUE))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 3: DATA VALIDATION LOGIC
  # ----------------------------------------------------------------------------
  output$ui_validation_status_boxes <- renderUI({
    if (is.null(rv$raw_data)) {
      return(div(class = "alert alert-info", "Please upload a dataset to perform data validation checks."))
    }
    
    df <- rv$raw_data
    text_c <- rv$text_col
    
    total_records <- nrow(df)
    total_cols    <- ncol(df)
    missing_vals  <- sum(is.na(df[[text_c]]))
    empty_records <- sum(nchar(str_trim(as.character(df[[text_c]]))) == 0, na.rm = TRUE)
    dup_rows      <- sum(duplicated(df[[text_c]]))
    
    fluidRow(
      column(width = 3, div(class = "kpi-card kpi-total", div(class = "kpi-title", "Records"), div(class = "kpi-value", total_records))),
      column(width = 3, div(class = "kpi-card kpi-pos", div(class = "kpi-title", "Columns"), div(class = "kpi-value", total_cols))),
      column(width = 3, div(class = "kpi-card kpi-neu", div(class = "kpi-title", "Missing Values"), div(class = "kpi-value", missing_vals))),
      column(width = 3, div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Duplicate Text"), div(class = "kpi-value", dup_rows)))
    )
  })
  
  output$ui_validation_notice <- renderUI({
    if (is.null(rv$raw_data)) return(NULL)
    
    if (!is.null(rv$label_col)) {
      div(
        class = "alert alert-success",
        icon("check-circle"),
        tags$strong(" Genuine Sentiment Label Detected: "),
        sprintf("Column '%s' is available for Supervised Machine Learning (Naive Bayes, SVM, KNN) evaluation.", rv$label_col)
      )
    } else {
      div(
        class = "alert alert-warning",
        icon("exclamation-triangle"),
        tags$strong(" Unlabeled Dataset Notice: "),
        "No genuine sentiment label column was found. Lexicon-based sentiment analysis will be performed. Supervised machine-learning evaluation requires labeled training data."
      )
    }
  })
  
  # Dashboard KPIs Output
  output$ui_dashboard_kpis <- renderUI({
    if (is.null(rv$sentiment_data)) return(NULL)
    
    kpis <- calculate_sentiment_kpis(rv$sentiment_data)
    
    fluidRow(
      column(width = 3, div(class = "kpi-card kpi-total", div(class = "kpi-title", "Total Reviews"), div(class = "kpi-value", kpis$Total))),
      column(width = 3, div(class = "kpi-card kpi-pos", div(class = "kpi-title", "Positive Reviews"), div(class = "kpi-value", paste0(kpis$Pos_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Pos_Count, "reviews")))),
      column(width = 3, div(class = "kpi-card kpi-neu", div(class = "kpi-title", "Neutral Reviews"), div(class = "kpi-value", paste0(kpis$Neu_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Neu_Count, "reviews")))),
      column(width = 3, div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Negative Reviews"), div(class = "kpi-value", paste0(kpis$Neg_Pct, "%")), div(class = "kpi-subtext", paste(kpis$Neg_Count, "reviews"))))
    )
  })
  
  # ----------------------------------------------------------------------------
  # TAB 4: PREPROCESSING LOGIC
  # ----------------------------------------------------------------------------
  observeEvent(input$btn_run_preprocess, {
    req(rv$raw_data, rv$text_col)
    
    withProgress(message = "Cleaning and preprocessing textual data...", value = 0.3, {
      res_df <- preprocess_dataset(
        df = rv$raw_data,
        text_col = rv$text_col,
        remove_stopwords = input$chk_stopwords,
        perform_stemming = input$chk_stemming
      )
      
      incProgress(0.4, detail = "Calculating word frequencies & TF-IDF...")
      
      # Perform text mining automatically
      rv$processed_data <- res_df
      rv$freq_data      <- get_word_frequencies(res_df$cleaned_text, top_n = 100)
      rv$tfidf_data     <- compute_tfidf(res_df$cleaned_text)
      
      incProgress(0.3, detail = "Done!")
      showNotification("Text preprocessing pipeline completed successfully!", type = "message")
    })
  })
  
  output$tbl_preprocess_compare <- renderDT({
    req(rv$processed_data, rv$text_col)
    
    display_df <- rv$processed_data %>%
      select(Original_Text = !!sym(rv$text_col), Cleaned_Text = cleaned_text)
    
    datatable(head(display_df, 50), options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 5: TEXT MINING OUTPUTS
  # ----------------------------------------------------------------------------
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
  
  # ----------------------------------------------------------------------------
  # TAB 6: SENTIMENT ANALYSIS LOGIC
  # ----------------------------------------------------------------------------
  observeEvent(input$btn_run_sentiment, {
    req(rv$processed_data, rv$text_col)
    
    withProgress(message = "Executing lexicon sentiment analysis...", value = 0.5, {
      res_df <- analyze_lexicon_sentiment(
        df = rv$processed_data,
        text_col = rv$text_col,
        clean_col = "cleaned_text"
      )
      
      rv$sentiment_data <- res_df
      rv$insights_data  <- generate_customer_insights(res_df, rv$ml_eval)
      
      incProgress(0.5)
      showNotification("Lexicon sentiment analysis complete!", type = "message")
    })
  })
  
  output$ui_sentiment_kpis <- renderUI({
    req(rv$sentiment_data)
    kpis <- calculate_sentiment_kpis(rv$sentiment_data)
    
    fluidRow(
      column(width = 3, div(class = "kpi-card kpi-total", div(class = "kpi-title", "Total Analyzed"), div(class = "kpi-value", kpis$Total))),
      column(width = 3, div(class = "kpi-card kpi-pos", div(class = "kpi-title", "Positive %"), div(class = "kpi-value", paste0(kpis$Pos_Pct, "%")))),
      column(width = 3, div(class = "kpi-card kpi-neu", div(class = "kpi-title", "Neutral %"), div(class = "kpi-value", paste0(kpis$Neu_Pct, "%")))),
      column(width = 3, div(class = "kpi-card kpi-neg", div(class = "kpi-title", "Negative %"), div(class = "kpi-value", paste0(kpis$Neg_Pct, "%"))))
    )
  })
  
  output$plot_sentiment_dist <- renderPlot({
    req(rv$sentiment_data)
    plot_sentiment_distribution(rv$sentiment_data)
  })
  
  output$tbl_sentiment_results <- renderDT({
    req(rv$sentiment_data, rv$text_col)
    
    disp <- rv$sentiment_data %>%
      select(Text = !!sym(rv$text_col), Score = Sentiment_Score, Sentiment = Sentiment)
    
    datatable(disp, options = list(pageLength = 8, scrollX = TRUE))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 7 & 8: MACHINE LEARNING & MODEL EVALUATION
  # ----------------------------------------------------------------------------
  output$ui_ml_status_banner <- renderUI({
    if (is.null(rv$label_col)) {
      div(
        class = "alert alert-warning mb-3",
        icon("info-circle"),
        tags$strong(" Supervised Learning Restriction: "),
        "No genuine sentiment-label column was found in the dataset. Lexicon-based sentiment analysis is active. Supervised machine-learning evaluation requires labeled training data."
      )
    } else {
      div(
        class = "alert alert-success mb-3",
        icon("check-circle"),
        tags$strong(" Ready for Supervised Learning: "),
        sprintf("Using ground-truth column '%s' for supervised classification.", rv$label_col)
      )
    }
  })
  
  output$ui_run_ml_button <- renderUI({
    if (is.null(rv$label_col)) {
      actionButton("btn_run_ml_disabled", "Run Supervised ML (Requires Labels)", class = "btn-secondary w-100", disabled = TRUE)
    } else {
      actionButton("btn_run_ml", "Run Supervised ML Models (NB, SVM, KNN)", icon = icon("play-circle"), class = "btn-primary w-100")
    }
  })
  
  observeEvent(input$btn_run_ml, {
    req(rv$processed_data, rv$label_col)
    
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
        
        # Update insights with ML findings
        if (!is.null(rv$sentiment_data)) {
          rv$insights_data <- generate_customer_insights(rv$sentiment_data, ml_eval)
        }
        
        rv$ml_log <- sprintf(
          "Supervised Machine Learning Completed Successfully!\nBest Model: %s\nAccuracy: %.2f%%\nF1-Score: %.2f%%\nTrain Samples: %d\nTest Samples: %d",
          ml_eval$Best_Model, ml_eval$Best_Accuracy * 100, ml_eval$Best_F1 * 100,
          nrow(ml_prep$train_x), nrow(ml_prep$test_x)
        )
        
        incProgress(0.1)
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
  
  output$ui_eval_content <- renderUI({
    if (is.null(rv$ml_eval)) {
      return(
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Model Evaluation"),
          div(
            class = "academic-card-body",
            if (is.null(rv$label_col)) {
              div(class = "alert alert-warning", "No labeled sentiment column was found. Lexicon-based sentiment analysis will be used. Supervised model evaluation requires labeled training data.")
            } else {
              p("Please navigate to the Machine Learning tab and click 'Run Supervised ML Models' to generate model performance evaluation metrics.")
            }
          )
        )
      )
    }
    
    comp_df <- rv$ml_eval$Comparison_Table
    best_m  <- rv$ml_eval$Best_Model
    
    tagList(
      fluidRow(
        column(
          width = 12,
          div(
            class = "alert alert-info",
            tags$strong("Best Performing Model: "),
            sprintf("%s achieved the highest score with Accuracy of %.2f%% and F1-Score of %.2f%%.",
                    best_m, rv$ml_eval$Best_Accuracy * 100, rv$ml_eval$Best_F1 * 100)
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          div(
            class = "academic-card",
            div(class = "academic-card-header", "Model Comparison Metrics Table"),
            div(
              class = "academic-card-body",
              tableOutput("tbl_model_comparison")
            )
          )
        )
      ),
      fluidRow(
        column(width = 4, plotOutput("plot_cm_nb", height = "320px")),
        column(width = 4, plotOutput("plot_cm_svm", height = "320px")),
        column(width = 4, plotOutput("plot_cm_knn", height = "320px"))
      )
    )
  })
  
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
  
  # ----------------------------------------------------------------------------
  # TAB 9: VISUALIZATION HUB
  # ----------------------------------------------------------------------------
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
  
  # ----------------------------------------------------------------------------
  # TAB 10: CUSTOMER INSIGHTS OUTPUTS
  # ----------------------------------------------------------------------------
  output$ui_insights_content <- renderUI({
    if (is.null(rv$insights_data)) {
      return(div(class = "alert alert-info", "Please run Text Preprocessing and Sentiment Analysis to generate customer insights."))
    }
    
    ins <- rv$insights_data
    
    tagList(
      div(
        class = "academic-card",
        div(class = "academic-card-header", "Executive Sentiment Summary"),
        div(class = "academic-card-body", p(ins$Executive_Summary, class = "lead"))
      ),
      if (!is.null(ins$ML_Insight)) {
        div(
          class = "academic-card",
          div(class = "academic-card-header", "Machine Learning Performance Insight"),
          div(class = "academic-card-body", p(ins$ML_Insight))
        )
      },
      fluidRow(
        column(
          width = 6,
          div(
            class = "academic-card",
            div(class = "academic-card-header", "Customers Like (Positive Themes)"),
            div(
              class = "academic-card-body",
              tags$ul(lapply(ins$Positive_Themes, function(x) tags$li(tags$span(class = "badge-pos", x))))
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "academic-card",
            div(class = "academic-card-header", "Customers Dislike / Common Issues"),
            div(
              class = "academic-card-body",
              tags$ul(lapply(ins$Negative_Themes, function(x) tags$li(tags$span(class = "badge-neg", x))))
            )
          )
        )
      ),
      div(
        class = "academic-card",
        div(class = "academic-card-header", "Data-Driven Actionable Recommendations"),
        div(
          class = "academic-card-body",
          lapply(ins$Recommendations, function(rec) {
            div(class = "recommendation-item", rec)
          })
        )
      )
    )
  })
  
  # ----------------------------------------------------------------------------
  # TAB 11: RESULTS & DOWNLOAD HANDLERS
  # ----------------------------------------------------------------------------
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

# Run R Shiny Web Application
shinyApp(ui = ui, server = server)
