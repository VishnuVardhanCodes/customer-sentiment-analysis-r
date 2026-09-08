# ==============================================================================
# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
# Module: Dynamic Visualizations (R/visualization.R)
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(wordcloud)
  library(wordcloud2)
  library(RColorBrewer)
})

# Custom Academic Color Palette
COLOR_POS <- "#2ecc71"
COLOR_NEU <- "#3498db"
COLOR_NEG <- "#e74c3c"
COLOR_PRIMARY <- "#2c3e50"
COLOR_SECONDARY <- "#16a085"

#' Plot Sentiment Distribution (Bar Chart)
#'
#' @param sentiment_df Data frame containing `Sentiment` column
#' @return ggplot2 object
plot_sentiment_distribution <- function(sentiment_df) {
  if (is.null(sentiment_df) || !"Sentiment" %in% colnames(sentiment_df)) {
    return(ggplot() + labs(title = "No sentiment data available"))
  }
  
  counts <- sentiment_df %>%
    count(Sentiment) %>%
    mutate(Percentage = round((n / sum(n)) * 100, 1))
  
  # Ensure order Positive, Neutral, Negative
  counts$Sentiment <- factor(counts$Sentiment, levels = c("Positive", "Neutral", "Negative"))
  
  p <- ggplot(counts, aes(x = Sentiment, y = n, fill = Sentiment)) +
    geom_bar(stat = "identity", width = 0.55, color = "#2c3e50", linewidth = 0.4) +
    geom_text(aes(label = paste0(n, " (", Percentage, "%)")), vjust = -0.4, size = 4.2, fontface = "bold") +
    scale_fill_manual(values = c("Positive" = COLOR_POS, "Neutral" = COLOR_NEU, "Negative" = COLOR_NEG)) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
    labs(
      title = "Customer Sentiment Distribution",
      subtitle = "Categorized into Positive, Neutral, and Negative classes",
      x = "Sentiment Category",
      y = "Number of Reviews"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 15, color = "#2c3e50"),
      legend.position = "none",
      panel.grid.major.x = element_blank()
    )
  
  return(p)
}

#' Plot Top Frequent Words (Horizontal Bar Chart)
#'
#' @param freq_df Data frame with `Word` and `Frequency`
#' @param top_n Integer
#' @return ggplot2 object
plot_word_frequency <- function(freq_df, top_n = 20) {
  if (is.null(freq_df) || nrow(freq_df) == 0) {
    return(ggplot() + labs(title = "No word frequency data"))
  }
  
  plot_data <- head(freq_df, top_n)
  
  p <- ggplot(plot_data, aes(x = reorder(Word, Frequency), y = Frequency)) +
    geom_bar(stat = "identity", fill = COLOR_SECONDARY, width = 0.65) +
    geom_text(aes(label = Frequency), hjust = -0.2, size = 3.8) +
    coord_flip() +
    scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
    labs(
      title = paste("Top", top_n, "Most Frequent Words"),
      x = "Terms",
      y = "Frequency Count"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
      panel.grid.major.y = element_blank()
    )
  
  return(p)
}

#' Plot Top TF-IDF Terms
#'
#' @param tfidf_df Data frame with `Term` and `TF_IDF_Score`
#' @param top_n Integer
#' @return ggplot2 object
plot_tfidf_terms <- function(tfidf_df, top_n = 20) {
  if (is.null(tfidf_df) || nrow(tfidf_df) == 0) {
    return(ggplot() + labs(title = "No TF-IDF data available"))
  }
  
  plot_data <- head(tfidf_df, top_n)
  
  p <- ggplot(plot_data, aes(x = reorder(Term, TF_IDF_Score), y = TF_IDF_Score)) +
    geom_bar(stat = "identity", fill = "#8e44ad", width = 0.65) +
    geom_text(aes(label = sprintf("%.4f", TF_IDF_Score)), hjust = -0.15, size = 3.6) +
    coord_flip() +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
    labs(
      title = paste("Top", top_n, "Terms by TF-IDF Importance Score"),
      x = "Terms",
      y = "Mean TF-IDF Weight"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
      panel.grid.major.y = element_blank()
    )
  
  return(p)
}

#' Plot Machine Learning Models Comparison (Grouped Bar Chart)
#'
#' @param comparison_df Data frame returned by `compare_all_models`
#' @return ggplot2 object
plot_model_comparison <- function(comparison_df) {
  if (is.null(comparison_df) || nrow(comparison_df) == 0) {
    return(ggplot() + labs(title = "No model evaluation data available"))
  }
  
  df_long <- comparison_df %>%
    tidyr::pivot_longer(
      cols = c("Accuracy", "Precision", "Recall", "F1_Score"),
      names_to = "Metric",
      values_to = "Value"
    )
  
  p <- ggplot(df_long, aes(x = Model, y = Value, fill = Metric)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.75) +
    geom_text(aes(label = sprintf("%.2f", Value)),
              position = position_dodge(width = 0.8), vjust = -0.3, size = 3.5) +
    scale_fill_brewer(palette = "Set2") +
    scale_y_continuous(limits = c(0, 1.15), breaks = seq(0, 1, 0.2)) +
    labs(
      title = "Supervised Machine Learning Model Comparison",
      subtitle = "Performance evaluation across Naive Bayes, SVM, and KNN",
      x = "Algorithms",
      y = "Score (0.0 to 1.0)"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 15, color = "#2c3e50"),
      legend.position = "top",
      panel.grid.major.x = element_blank()
    )
  
  return(p)
}

#' Plot Heatmap Confusion Matrix
#'
#' @param cm_df Data frame containing Actual, Predicted, and Freq
#' @param model_name Character model title
#' @return ggplot2 object
plot_confusion_matrix <- function(cm_df, model_name = "Model") {
  if (is.null(cm_df) || nrow(cm_df) == 0) {
    return(ggplot() + labs(title = "No confusion matrix data"))
  }
  
  p <- ggplot(cm_df, aes(x = Predicted, y = Actual, fill = Freq)) +
    geom_tile(color = "white", linewidth = 0.8) +
    geom_text(aes(label = Freq), size = 6, fontface = "bold", color = "white") +
    scale_fill_gradient(low = "#34495e", high = "#16a085") +
    labs(
      title = paste("Confusion Matrix -", model_name),
      x = "Predicted Label",
      y = "Actual Ground Truth Label"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#2c3e50"),
      panel.grid = element_blank()
    )
  
  return(p)
}
