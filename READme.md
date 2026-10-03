# Customer Sentiment Analysis from Social Media and Product Reviews Using Text Mining in R

**Academic B.Tech Final-Year Data Analytics Project (LG9)**

---

## 1. Project Title & Overview

**Project Title:** Customer Sentiment Analysis from Social Media and Product Reviews Using Text Mining in R  
**Domain:** Applied Data Analytics, Natural Language Processing (NLP) & Statistical Machine Learning  
**Environment:** R (v4.6.1+) REST API Backend via R Plumber + React Frontend with Vanilla CSS Design Tokens

### Core Objective
Customer Sentiment Analysis is an interactive application that analyzes product reviews using text mining and machine learning. It helps **potential buyers** understand the opinions expressed in existing customer reviews before making purchase decisions, while enabling **businesses and sellers** to identify product strengths, common complaints, and customer feedback patterns across product catalogs. Users can analyze individual reviews, compare multiple reviews for a single product, or upload bulk datasets to explore sentiment distribution, TF-IDF keywords, and supervised model performance.

> **Decision-Support Principle:** Sentiment analysis is designed to assist informed decisions rather than automatically dictate purchases. A positive review does not guarantee a product is flawless, and a negative review does not imply it should never be purchased. All insights are strictly evidence-based and grounded in the input text.

---

## 2. Target User Groups

| User Group | Primary Use Cases & Benefits |
|---|---|
| **Potential Customers & Buyers** | • Paste individual reviews copied from Amazon or other e-commerce platforms.<br>• Identify key product-related feedback (battery, sound, durability, value).<br>• Compare multiple reviews for the same product to gauge consensus.<br>• Make informed, evidence-based purchasing decisions. |
| **Businesses & Product Sellers** | • Upload full product review datasets (CSV/TXT).<br>• Generate product-level and category-level sentiment scorecards.<br>• Pinpoint recurring defect complaints and customer satisfaction drivers.<br>• Export clean analytical reports for product engineering and marketing. |
| **Academic Researchers & Students** | • Study end-to-end R text mining pipelines (`tm`, `tidytext`, `SnowballC`).<br>• Inspect Document-Term Matrix (DTM) and TF-IDF extraction.<br>• Train and compare supervised ML classifiers: Naive Bayes, Support Vector Machines (SVM), and K-Nearest Neighbors (KNN).<br>• Examine confusion matrices, precision, recall, and F1-scores. |

---

## 3. Two Core Application Workflows

### Workflow A: Individual Product Review Analyzer (Customer-Facing)
1. **Input:** User specifies product name (e.g., *Sony WH-1000XM5*), category (e.g., *Audio*), pastes customer review text, and enters optional rating (1 to 5).
2. **Preprocessing:** Lowercasing, punctuation/number stripping, stop-word removal with negation preservation (`not`, `no`, `never`), whitespace trimming, and Snowball stemming.
3. **Keyword & Aspect Extraction:** Extracts positive/negative polar terms and detects mentioned product aspects (audio quality, battery life, build quality, value for money, customer service).
4. **Sentiment Classification:** 
   - Uses Bing/AFINN lexicon polarity scoring via R `syuzhet` (calculates score and calibrated confidence).
   - If supervised models have been trained on labeled data, allows direct inference using trained **SVM**, **Naive Bayes**, or **KNN**.
5. **Grounded Explanation & Potential Buyer Insight:** Returns human-readable feedback synthesis explaining *why* the sentiment was assigned and what a buyer should consider.
6. **Multi-Review Comparison Tool (`/compare`):** Enables pasting 2 to 5 reviews for the same product to calculate collective consensus, percentage breakdowns, repeated positive strengths, and repeated complaints.

### Workflow B: Bulk Customer Review Analysis (Business & Academic)
1. **Dataset Import & Validation:** Upload CSV/TXT files with column mapping for Review Text, Sentiment Label (optional), Product Name (optional), Category (optional), and Rating (optional).
2. **Text Preprocessing:** Batch corpus cleaning with token reduction tracking and stop-word filtering.
3. **Feature Extraction:** Generates Document-Term Matrix (DTM), term frequencies, and TF-IDF weighting.
4. **Supervised ML Training & Evaluation:** When ground-truth labels exist, trains Naive Bayes (`e1071`), SVM linear kernel (`e1071`), and KNN (`class`) on an 80/20 train/test split.
5. **Product & Category Summaries:** Generates aggregated sentiment ratios, average ratings, and satisfaction bars per product and per category.
6. **Visual Analytics & Export:** Recharts charts (sentiment donut, term frequency, TF-IDF bars, word cloud, model comparison, confusion matrix heatmap, product comparisons) and CSV/JSON downloads.

---

## 4. Machine Learning Implementation Details

Demonstrating **where exactly machine learning is implemented** in the architecture:

```
[Customer Review or Dataset]
          │
          ▼
   Stage 1: Input Validation (validation.R)
          │ Checks text column, dimensions, missing values, label distribution
          ▼
   Stage 2: Text Preprocessing (preprocessing.R)
          │ Lowercasing, URL/HTML removal, punctuation/number handling,
          │ Stop-word filtering (preserving negation: not, no, never), Snowball stemming
          ▼
   Stage 3: Feature Extraction (text_mining.R)
          │ Document-Term Matrix (DTM), Term Frequency, TF-IDF statistical weighting
          ▼
   Stage 4: Supervised ML Training (machine_learning.R)
          │ • Naive Bayes (e1071::naiveBayes with Laplace smoothing)
          │ • Support Vector Machine (e1071::svm with Linear Kernel, cost=1)
          │ • K-Nearest Neighbors (class::knn with Euclidean distance, k=5)
          ▼
   Stage 5: Model Evaluation (model_evaluation.R)
          │ Confusion Matrix, Accuracy, Precision (macro), Recall (macro), F1-Score (macro)
          ▼
   Stage 6: Prediction & Inference (sentiment_analysis.R)
          │ Single-review TF-IDF feature projection onto trained vocabulary
          │ Lexicon polarity fallback when models are not yet trained
          ▼
   Stage 7: Grounded Customer Insight Generation
```

### ML Files in Backend
- `backend/R/preprocessing.R`: Text cleaning, negation preservation, preprocessing stats tracking.
- `backend/R/text_mining.R`: Document-Term Matrix, TF-IDF calculation, vocabulary building.
- `backend/R/machine_learning.R`: Supervised model training, evaluation metrics, and `predict_single_review_ml()` for single-review inference.
- `backend/R/sentiment_analysis.R`: Lexicon polarity scoring, aspect detection, grounded explanations, buyer insights, multi-review consensus, and product-level summaries.
- `backend/plumber.R`: REST API exposing all ML routines to the React frontend.

---

## 5. Technology Stack

- **Backend:** R (v4.6.1+), R Plumber (`plumber` v1.2.2), `tm`, `tidytext`, `SnowballC`, `syuzhet`, `e1071`, `class`, `dplyr`, `readr`, `jsonlite`.
- **Frontend:** React 18, React Router v6, Axios, Recharts, Lucide React, Vanilla CSS Design System.
- **Port Allocation:** R Plumber API on `http://127.0.0.1:8000`, React Frontend on `http://localhost:3000`.

---

## 6. Complete API Reference

| Endpoint | Method | Parameters / Body | Description |
|---|---|---|---|
| `/health` | `GET` | None | Returns API status, R version, and session state. |
| `/analyze-review` | `POST` | `review_text`, `product_name`, `category`, `original_rating`, `model_choice` | Analyzes a single customer review (Workflow A). Returns sentiment, score, keywords, aspects, explanation, and buyer insight. |
| `/analyze-reviews` | `POST` | `product_name`, `category`, `reviews` (array) | Compares 2-5 reviews for the same product, computing consensus sentiment, strengths, complaints, and synthesis. |
| `/model-info` | `GET` | None | Returns status of trained supervised ML models, vocabulary size, and benchmark comparison table. |
| `/product-summary` | `GET` | None | Returns product-level and category-level sentiment aggregations from the uploaded dataset. |
| `/upload` | `POST` | `filename`, `file_content` | Uploads and parses CSV/TXT review dataset. |
| `/validate` | `POST` | `text_column`, `label_column`, `product_column`, `category_column`, `rating_column` | Executes data quality verification and validates column mappings. |
| `/preprocess` | `POST` | `remove_stopwords`, `perform_stemming` | Cleans corpus and returns token transition metrics. |
| `/text-mining` | `POST` | `top_n` | Computes term frequencies, TF-IDF weights, and DTM vocabulary. |
| `/sentiment` | `POST` | None | Computes dataset-wide sentiment scores and product summaries. |
| `/train/all` | `POST` | None | Trains Naive Bayes, SVM, and KNN on labeled training split. |
| `/evaluate` | `GET` | None | Computes accuracy, precision, recall, F1, and confusion matrices. |
| `/visualization-data`| `GET` | None | Aggregates all chart payloads for the visualization dashboard. |
| `/insights` | `GET` | None | Generates executive recommendations and feedback themes. |
| `/demo/labeled` | `POST` | None | 1-Click execution of full supervised ML pipeline on 100 verified reviews. |
| `/demo/unlabeled` | `POST` | None | 1-Click execution of lexicon pipeline on 50 unlabeled reviews. |
| `/download/product-summary` | `GET` | None | Downloads product-level sentiment summary CSV. |
| `/download/review-analysis` | `GET` | None | Downloads latest single-review analysis JSON. |
| `/download/processed` | `GET` | None | Downloads preprocessed dataset CSV. |
| `/download/sentiment` | `GET` | None | Downloads sentiment scored dataset CSV. |
| `/download/models` | `GET` | None | Downloads ML performance metrics CSV. |
| `/download/insights` | `GET` | None | Downloads executive insights text report. |
| `/download/complete` | `GET` | None | Downloads full combined analysis CSV. |
| `/reset` | `POST` | None | Resets all active analysis session memory. |

---

## 7. How to Run the Application

### Method 1: Using One-Click Batch Launchers (Recommended)
1. Double-click `start_backend.bat` in the project root to start the R Plumber API on port 8000.
2. Double-click `start_frontend.bat` in the project root to start the React interface on port 3000.
3. Open your browser and navigate to `http://localhost:3000`.

### Method 2: Manual Terminal Startup
**Backend (R Plumber):**
```bash
cd backend
"C:\Program Files\R\R-4.6.1\bin\Rscript.exe" run_plumber.R

-- & "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" run_plumber.R
```
*API will start listening on `http://127.0.0.1:8000` with Swagger documentation at `http://127.0.0.1:8000/__docs__/`.*

**Frontend (React):**
```bash
cd frontend
npm run dev
```
*Frontend will launch on `http://localhost:3000`.*

---

## 8. Academic Demonstration Walkthrough

For presenting the project to faculty or viva examiners:

1. **Overview & Motivation (Dashboard):**
   - Show the 3 Target User cards (Potential Buyers, Businesses, Researchers).
   - Point out the active R backend indicator (`R API Active` on port 8000).

2. **Demonstrate Workflow A (Individual Review Analyzer):**
   - Click **Review Analyzer** in the sidebar.
   - Click **Positive Sample** (Sony Headphones). Click **Analyze Review**.
   - Show the green **Positive** badge, confidence score, preprocessed tokens, detected aspects (*sound & audio quality*, *battery life*), grounded explanation, and potential buyer insight.
   - Click **Negative Sample** (draining battery). Show the red **Negative** badge and caution insight.
   - Click **Neutral Sample** (factual package arrival). Show the blue **Neutral** classification.

3. **Demonstrate Comparative Analysis (Compare Reviews):**
   - Click **Compare Reviews** in the sidebar.
   - Click **Quick-Load Sample Reviews** (loads 4 reviews for Sony Headphones). Click **Analyze All Reviews**.
   - Highlight the **75% Positive Consensus**, average star rating, repeated strengths (*comfortable*, *incredible*, *top*), and repeated complaints (*noise*, *expensive*, *poor*).

4. **Demonstrate Machine Learning Implementation (How It Works & Workflow B):**
   - Navigate to **How It Works (ML)** to show the 8-stage text mining and ML pipeline with specific R files.
   - Click **Dashboard** -> **Run Supervised Demo** (executes on `sample_reviews.csv` with product categories and ratings).
   - Navigate to **Machine Learning** to show the trained algorithms: Naive Bayes, SVM (Linear Kernel), and KNN.
   - Navigate to **Model Evaluation** to show the comparative evaluation table (Accuracy, Precision, Recall, F1) and SVM confusion matrix.
   - Navigate back to **Review Analyzer**, select **Analysis Model: SVM**, and demonstrate real supervised ML inference on a single review!

5. **Demonstrate Business Intelligence & Visualizations:**
   - Navigate to **Visualization** to show product-wise and category-wise comparison charts alongside word frequencies, TF-IDF weights, and word cloud.
   - Navigate to **Results & Export** to download the Product Summaries CSV and Single Review JSON report.