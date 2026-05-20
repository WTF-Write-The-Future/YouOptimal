<div align="center">
  <img src="docs/logo.png" alt="YouOptimal Logo" width="120" onerror="this.style.display='none'"/>

  # 🌍 YouOptimal
  **Smart City-Ranking & Relocation Analytics Platform**

  ![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Python](https://img.shields.io/badge/Data_Engineering-Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
  ![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
  ![GitHub Actions](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
</div>

---

## 📖 About the Project
**YouOptimal** is an intelligent, cross-platform ecosystem designed for analyzing and comparing cities worldwide. Forget about keeping dozens of tabs open to research your next destination: we aggregate real-time data on climate, safety, rent costs, and real user experiences into a single, seamless neomorphic interface.

<div align="center">
  <h3>📍 Main Dashboard</h3>
  <img src="docs/main.png" alt="YouOptimal Main Screen" width="850"/>
</div>

## ✨ Key Features
* **Dynamic Currency Conversion:** Real-time exchange rate updates (UAH, EUR, USD) fetched via the National Bank of Ukraine (NBU) API and seamlessly integrated into the UI.
* **Automated Data Engineering:** CRON-triggered Python scripts run via GitHub Actions to synchronize climate metrics via OpenWeather API twice a day.
* **Interactive Analytics & Reviews:** Calculation of average city scores based on detailed, expandable user reviews (covering Safety, Architecture, and Culture).
* **Cross-Platform Consistency:** A single, responsive codebase tailored perfectly for Web, iOS, and Android platforms using advanced layout constraints.

<div align="center">
  <h3>📊 Detailed City Analytics & Reviews</h3>
  <img src="docs/city_detail.png" alt="YouOptimal City Details" width="850"/>
</div>

## 🏗 System Architecture
Our platform utilizes a modern Serverless + Monorepo approach, completely isolating the reactive client UI from background automated data pipelines.

```mermaid
graph TD
  subgraph Frontend ["📱 Client Layer (Flutter / Dart)"]
    UI[Neomorphic User Interface]
    State[State Management / ValueNotifier]
  end

  subgraph Backend ["🗄️ Backend Cloud (Supabase)"]
    Auth[GoTrue Authentication]
    DB[(PostgreSQL Database)]
  end

  subgraph Pipelines ["⚙️ Automated Pipelines (GitHub Actions)"]
    WeatherBot[update_metrics.py]
    CurrencyBot[update_rates.py]
  end

  subgraph ExternalAPIs ["🌐 External Data Provider APIs"]
    OpenWeather[OpenWeather API]
    NBU[National Bank of Ukraine API]
  end

  UI <--> State
  State <-->|User Session Management| Auth
  State <-->|Fetch Cities & Read-Write Reviews| DB
  
  WeatherBot -->|Fetch Weather JSON| OpenWeather
  CurrencyBot -->|Fetch Daily Rates| NBU
  
  WeatherBot -->|Update Live Metrics| DB
  CurrencyBot -->|Update Cross Exchange Rates| DB
```

## 🚀 How to Run Locally

1. **Clone the Monorepo:**
   ```bash
   git clone [https://github.com/WTF-Write-The-Future/YouOptimal.git](https://github.com/WTF-Write-The-Future/YouOptimal.git)
   cd YouOptimal
   ```

2. **Configure Environment Variables:**
   Create a file named `env` (without extension) in the root directory and populate your Supabase configuration:
   ```env
   SUPABASE_URL=[https://your-project-id.supabase.co](https://your-project-id.supabase.co)
   SUPABASE_ANON_KEY=your-public-anon-key
   ```

3. **Launch the Application:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 👥 The "WTF" (Write The Future) Team
* **Oleksandr Tseniuk** — Frontend Developer
* **Ostap Tutyn** — Team Lead & Backend Developer
* **Bozhena Schur** — UI/UX Designer
* **Ostap Bakhurskyi** — Full-Stack Developer
* **Vitaliy Malevych** — Backend Developer
* **Oksana Datskiv** — QA Engineer
