# LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R

Academic Data Analytics Project

---

## 1. Project Title & Objective

**Project Title:** LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R  
**Domain:** Data Analytics & Natural Language Processing (NLP)  
**Objective:** Transform raw social media customer feedback and reviews into actionable business intelligence using statistical text mining, TF-IDF feature extraction, lexicon-based sentiment analysis, supervised machine learning (Naive Bayes, SVM, KNN), and dynamic SaaS dashboard visualizations.

---

## 2. Core Architecture

The application is structured into a decoupled **React Frontend** and **R Plumber REST API Backend**:

```
                    USER
                     |
                     v
              REACT FRONTEND (Port 3000)
                     |
                     | HTTP / REST API (JSON)
                     v
              R PLUMBER API (Port 8000)
                     |
          +----------+----------+
          |          |          |
          v          v          v
     PREPROCESSING TEXT MINING SENTIMENT
          |          |          |
          +----------+----------+
                     |
                     v
             MACHINE LEARNING
              NB / SVM / KNN
                     |
                     v
             MODEL EVALUATION
                     |
                     v
              VISUALIZATION
                     |
                     v
             CUSTOMER INSIGHTS
```

### Responsibility Matrix

* **Frontend (React.js):** UI rendering, navigation, interactive forms, drag-and-drop file upload, pipeline stepper, Recharts data visualization, status badges, toast notifications, download triggers.
* **Backend (R Plumber):** Data loading, quality validation, text preprocessing (`tm`, `stringr`, `SnowballC`), term frequency & TF-IDF computation (`tidytext`), lexicon sentiment scoring (`syuzhet` Bing lexicon), supervised ML classification (`e1071`, `class`), model evaluation matrix, and dynamic customer insights generation.

---

## 3. Technology Stack

* **Frontend:** React.js, React Router v6, Axios, Recharts, Lucide React Icons, Vanilla CSS (Design Tokens & Utility System).
* **Backend:** R (v4.6.1+), R Plumber (`plumber`), `dplyr`, `tidytext`, `tm`, `SnowballC`, `syuzhet`, `e1071`, `class`, `readr`, `jsonlite`.

---

## 4. Required Project Structure

```
customer-sentiment-analysis-r/
    frontend/
        package.json
        vite.config.js
        index.html
        .env
        .env.example
        src/
            components/
                Sidebar.jsx
                TopNavbar.jsx
                PageHeader.jsx
                KpiCard.jsx
                StatusBadge.jsx
                WorkflowStepper.jsx
                UploadZone.jsx
                DatasetInfoCard.jsx
                ValidationTable.jsx
                DataPreviewTable.jsx
                ChartCard.jsx
                EmptyState.jsx
                LoadingState.jsx
                ErrorState.jsx
                ModelCard.jsx
                MetricCard.jsx
                InsightCard.jsx
                DownloadCard.jsx
                ConfirmationModal.jsx
                ToastNotification.jsx
            pages/
                Dashboard.jsx
                UploadData.jsx
                DataValidation.jsx
                Preprocessing.jsx
                TextMining.jsx
                SentimentAnalysis.jsx
                MachineLearning.jsx
                ModelEvaluation.jsx
                Visualization.jsx
                CustomerInsights.jsx
                ResultsDownload.jsx
            layouts/
                MainLayout.jsx
            charts/
                SentimentDonutChart.jsx
                WordFreqChart.jsx
                TfidfChart.jsx
                ModelComparisonChart.jsx
                ConfusionMatrixHeatmap.jsx
                WordCloudView.jsx
            services/
                api.js
            context/
                AnalysisContext.jsx
            styles/
                index.css
                layout.css
                components.css
            App.jsx
            main.jsx
        public/

    backend/
        plumber.R
        run_plumber.R
        R/
            preprocessing.R
            text_mining.R
            sentiment_analysis.R
            machine_learning.R
            evaluation.R
            visualization.R
            insights.R
            validation.R
            helpers.R
        data/
            sample/
                sample_reviews.csv
                sample_unlabeled.csv
        outputs/

    requirements.R
    README.md
    .gitignore
```

---

## 5. Installation & Setup Instructions

### Prerequisites

* **R (v4.0.0 or higher)** installed.
* **Node.js (v18.0.0 or higher)** and `npm` installed.

### Step 1: Install R Dependencies

Run the dependency checker script using `Rscript`:

```bash
Rscript requirements.R
```

### Step 2: Install Frontend Dependencies

Navigate to the `frontend` folder and install Node packages:

```bash
cd frontend
npm install
```

## 6. How to Run the Application

### Option A: Using One-Click Batch Launchers (Recommended for Windows)

* **Start Backend Server:** Double-click `start_backend.bat` or run `backend\run_plumber.bat`
* **Start Frontend Server:** Double-click `start_frontend.bat`

---

### Option B: Running Manually from PowerShell Terminal

#### 1. Start the R Plumber API Backend (Port 8000)

Navigate to the `backend` folder:

```powershell
cd backend
```

Since `Rscript.exe` is installed at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`, execute:

```powershell
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" run_plumber.R
```

*Or temporarily add R to your PowerShell session PATH first:*

```powershell
$env:Path += ";C:\Program Files\R\R-4.6.1\bin"
Rscript run_plumber.R
```

The R backend API will start on `http://127.0.0.1:8000` with Swagger docs available at `http://127.0.0.1:8000/__docs__/`.

#### 2. Start the React Frontend Application (Port 3000)

In a new terminal window:

```powershell
cd frontend
npm run dev
```

Open your browser and navigate to `http://localhost:3000`.

---

## 7. API Endpoints Reference

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/health` | Check R Plumber API status and session health |
| `POST` | `/upload` | Upload and parse raw CSV/TXT customer dataset |
| `POST` | `/validate` | Execute data quality checks & select target columns |
| `POST` | `/preprocess` | Run text normalization, stopword filtering, and Porter stemming |
| `POST` | `/text-mining` | Calculate word frequencies, DTM, and TF-IDF weights |
| `POST` | `/sentiment` | Perform lexicon-based Syuzhet Bing sentiment scoring |
| `POST` | `/train/naive-bayes` | Train Naive Bayes model on TF-IDF features |
| `POST` | `/train/svm` | Train Linear Support Vector Machine (SVM) model |
| `POST` | `/train/knn` | Train K-Nearest Neighbors (KNN) model |
| `POST` | `/train/all` | Train and compare all 3 supervised ML models |
| `GET` | `/evaluate` | Fetch comparative evaluation metrics & confusion matrices |
| `GET` | `/visualization-data` | Fetch pre-computed payloads for Recharts frontend |
| `GET` | `/insights` | Generate dynamic opinion insights and strategic recommendations |
| `GET` | `/results` | Fetch overall pipeline status and KPI metrics |
| `GET` | `/download/processed` | Download preprocessed dataset CSV |
| `GET` | `/download/sentiment` | Download sentiment results CSV |
| `GET` | `/download/models` | Download model evaluation summary CSV |
| `GET` | `/download/insights` | Download executive insights report TXT |
| `GET` | `/download/complete` | Download complete combined analysis CSV |
| `POST` | `/reset` | Reset current analysis session |
| `POST` | `/demo/labeled` | Run full end-to-end supervised demo workflow |
| `POST` | `/demo/unlabeled` | Run end-to-end unsupervised demo workflow |

---

## 8. Dataset Format & Demos

### Labeled Dataset Format (.CSV)
Requires text column and optional sentiment ground-truth label:
```csv
"review_id","review_text","sentiment"
"REV_001","The product quality is outstanding! Fast delivery and great support.","Positive"
"REV_002","Terrible service. Package arrived damaged. Very disappointed!","Negative"
```

### Unlabeled Dataset Format (.CSV / .TXT)
```csv
"review_id","review_text"
"UNL_001","The product quality is fantastic! Fast shipping."
```

### Running Demos from UI
* **Run Labeled Demo:** Loads `sample_reviews.csv` (100 reviews), runs preprocessing, text mining, sentiment analysis, NB, SVM, KNN training, evaluation, and insights.
* **Run Unlabeled Demo:** Loads `sample_unlabeled.csv` (50 reviews), runs preprocessing, text mining, lexicon sentiment scoring, visualizations, and insights. Supervised ML displays `UNAVAILABLE` adhering to academic integrity.

---

## 9. Academic Methodology

1. **Text Preprocessing:** Lowercase conversion, regex cleaning of URLs (`https?://\S+`), emails, `@mentions`, hashtags, punctuation, and digits, followed by English stopword removal (`tm::stopwords`) and Porter stemming (`SnowballC::wordStem`).
2. **Text Mining & TF-IDF:** Tokenization via `tidytext::unnest_tokens`, term frequency computation, and Inverse Document Frequency (IDF) weighting:
   $$\text{TF-IDF}(t, d, D) = \text{TF}(t, d) \times \log\left(\frac{|D|}{|\{d \in D : t \in d\}|}\right)$$
3. **Sentiment Analysis:** Unsupervised lexicon scoring using Syuzhet Bing dictionary ($S > 0 \implies \text{Positive}$, $S < 0 \implies \text{Negative}$, $S = 0 \implies \text{Neutral}$).
4. **Supervised ML Classification:** 80/20 train/test split on sparse TF-IDF Document-Term Matrix (DTM) evaluated across Naive Bayes, Linear Support Vector Machines (SVM), and K-Nearest Neighbors (KNN).
5. **Evaluation Metrics:** Accuracy, Macro-Precision, Macro-Recall, Macro F1-Score, and Confusion Matrix Heatmaps:
   $$\text{F1-Score} = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}}$$

---

## 10. Future Scope

* Multi-language text mining and translation capabilities.
* Aspect-based sentiment analysis (ABSA) for fine-grained feature sentiment.
* Integration of deep learning transformer models (BERT, RoBERTa).
* Real-time streaming API connectors for Twitter/X, Reddit, and Amazon API data.