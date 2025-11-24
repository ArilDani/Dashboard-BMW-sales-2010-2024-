library(shiny)
library(dplyr)
library(plotly)
library(DT)
library(shinyjs)
library(readxl)


# Data & Configuration
# Data anggota tim 
anggota <- data.frame(
  Nama = c(
    "Muhammad Fauzan Ali Fatah",
    "Ahmad Naufal Dzaky",
    "M Aril Ardani",
    "Firman"
  ),
  NIM = c("240907500027","240907502037","240907500023","240907501044"),
  Foto = c(
    "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhqP9RvCDlCoBeXbQ_yy30amxW0mbk4Y7F_G4JVM9gI-UiZiLAZhO9i8yal52yhb_rpDELiAO4LREgrLMwLxC37dWvj4ovEs41IcqJdlY3IJQEVunj41FU74Q7e6DY3da9Nns1fTJdWOB0KGQoG37aq8kCvg2qb_-SBvML9YVaSRBZdaC020q3RVbOzfto/s320",
    "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhh5lPHtLC-oX6DTXvhK83SAuCeVtLX97XRXzGT_QLA-ITpuO4MJd1uFzj3t5USJN8cLWPMWBW49XnViDqZfxqz68j9b24UPfzF3gbb-xPcU7gdWcUwBaBe4zHuXCsrY5fjiNlGaLNkRFYSTPZ7Cfm00qKVa0GXYHoNbVOABm0fW4dmGiK3jqq55J8dlS/s320",
    "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiF0I9v_t_21wOtMtn8Te5lfP065YXnES2oJkpMvwitZwv5hn8g-CG1YdLqjmym85Hz50pYoj0vIORxIo33tw5vR3gh9A6g822pVN0Yjr78f3rtwvMOIa4SN6C0VphaD9ueLdnuoIkDxr8skvZ0le_t7kBG86ub4RnCQRyB3Z8gp7WRXYzRKk5rZsfb9f4/s320/Aril.jpg",
    "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhkv2yGzxSHid88zrn0r7FBW6qraTut0dlxn0NtyFGaCmxBEBrlUIipNXr1RIgOXEdXv6hmxyyUjeVqHyKFjk6lEa-0cSUZdTGnxbo_PMfIMhqKF5SgU25Pwc6DGxGu6zZ0onNYWqu_dWsBh9pbOeQKhRJFdP__zOvcm9xlilcFSPLrepIVUSERG2nnOTU/s320/Firman.jpg"
  ),
  Tiktok = c("https://www.tiktok.com/@tezuganzi", "@naufal.dzaky", "https://www.tiktok.com/@arutia?_r=1&_t=ZS-91fczLnYpdo", "https://www.tiktok.com/@manthekid_"),
  Instagram = c("https://www.instagram.com/fauzanalifatah_/","kocak", "https://www.instagram.com/p.starrrr7?igsh=MXNwNW1hcDJhcHJhNg==", "https://www.instagram.com/pirmngg_/"),
  Github = c("https://github.com/Fauzan893", "naufaldzaky", "https://github.com/ArilDani", "https://github.com/Firman-Bisdig"),
  stringsAsFactors = FALSE
)


# FUNGSI UNTUK UI
plot_with_loading <- function(plot_output_id, height = "100%") {
  div(class = "plot-container",
      div(id = paste0("loading-", plot_output_id), class = "plot-loading",
          img(src = "https://upload.wikimedia.org/wikipedia/commons/4/44/BMW.svg", class = "loading-logo")
      ),
      plotlyOutput(plot_output_id, height = height)
  )
}

render_trend <- function(pct) {
  if(pct >= 0) {
    div(class="trend-green", icon("arrow-up"), paste0(abs(pct), "% vs Previous Year"))
  } else {
    div(class="trend-red", icon("arrow-down"), paste0(abs(pct), "% vs Previous Year"))
  }
}


# UI 
ui <- fluidPage(
  useShinyjs(),
  
  title = "BMW Analytics",
  
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"),
    tags$style(HTML("
             /* --- GLOBAL VARIABLES & RESET --- */
             :root {
               --sidebar-width: 250px;
               --sidebar-width-collapsed: 70px;
               --glass-bg: rgba(255, 255, 255, 0.95);
               --glass-border: 1px solid rgba(255, 255, 255, 0.6);
               --shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15);
               --primary-text: #2c3e50;
             }

             body {
               font-family: 'Poppins', sans-serif;
               margin: 0;
               background: linear-gradient(135deg, #3080A8 0%, #EEEEEE 100%);
               background-attachment: fixed;
               height: 100vh;
               overflow: hidden;
             }

             /* --- LAYOUT WRAPPER --- */
             .wrapper { display: flex; width: 100%; height: 100vh; }

             /* --- SIDEBAR STYLE --- */
             #sidebar {
               width: var(--sidebar-width);
               background: rgba(255, 255, 255, 0.15);
               backdrop-filter: blur(15px);
               border-right: var(--glass-border);
               display: flex; flex-direction: column;
               transition: all 0.3s ease;
               padding: 20px 10px;
               z-index: 200;
             }
             #sidebar.collapsed { width: var(--sidebar-width-collapsed); }

             .logo-area { display: flex; align-items: center; justify-content: center; margin-bottom: 30px; }
             .logo-img { width: 50px; border-radius: 50%; box-shadow: 0 4px 10px rgba(0,0,0,0.2); }
             .logo-text { margin-left: 10px; font-weight: 700; color: white; font-size: 20px; white-space: nowrap; transition: 0.3s; }
             #sidebar.collapsed .logo-text { opacity: 0; display: none; }

             .menu-btn {
               background: transparent; border: none; color: white;
               padding: 15px; width: 100%; text-align: left; cursor: pointer;
               border-radius: 12px; margin-bottom: 8px; transition: 0.2s;
               display: flex; align-items: center; font-size: 15px; font-weight: 500;
             }
             .menu-btn:hover { background: rgba(255,255,255,0.25); }
             .menu-btn.active { background: white; color: #3080A8; font-weight: bold; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
             .menu-btn i { width: 30px; text-align: center; }
             .menu-text { margin-left: 10px; }
             #sidebar.collapsed .menu-text { display: none; }

             /* Style khusus File Input di Sidebar */
             .shiny-input-container { color: white; margin-bottom: 20px; }
             .btn-file { background-color: #3080A8; border-color: #3080A8; color: white; }

             /* --- MAIN CONTENT --- */
             #content { flex-grow: 1; padding: 20px 30px; overflow-y: auto; position: relative; }

             /* --- DASHBOARD GRID --- */
             .dashboard-grid {
               display: grid;
               grid-template-columns: repeat(4, 1fr);
               grid-template-rows: auto 150px 320px 300px;
               gap: 20px;
               grid-template-areas:
                 'header header header header'
                 'kpi1 kpi2 inputs pie'
                 'line line line slider'
                 'bar bar bar bar';
             }

             @media (max-width: 1200px) {
               .dashboard-grid {
                 grid-template-columns: 1fr 1fr;
                 grid-template-rows: auto;
                 grid-template-areas:
                   'header header'
                   'kpi1 kpi2'
                   'inputs pie'
                   'line line'
                   'slider slider'
                   'bar bar';
               }
             }

             /* --- CARD STYLES + HOVER ANIMATION --- */
             .card {
               background: var(--glass-bg);
               border-radius: 20px;
               padding: 24px;
               box-shadow: var(--shadow);
               border: var(--glass-border);
               display: flex; flex-direction: column; justify-content: center; position: relative;
               /* Animation */
               transition: all 0.3s ease-out;
             }

             /* Hover animation for cards */
             .card:not(.area-slider):hover {
               transform: translateY(-5px);
               box-shadow: 0 12px 40px 0 rgba(31, 38, 135, 0.25);
             }

             .area-inputs { grid-area: inputs; z-index: 100; overflow: visible !important; justify-content: space-evenly; }
             .area-inputs.card { overflow: visible !important; }
             .area-header { grid-area: header; }
             .area-kpi1 { grid-area: kpi1; }
             .area-kpi2 { grid-area: kpi2; }
             .area-pie { grid-area: pie; padding: 10px; }
             .area-line { grid-area: line; }
             .area-slider { grid-area: slider; padding: 0 !important; overflow: hidden; border-radius: 20px;}
             .area-bar { grid-area: bar; }

             h2.page-title { margin: 0; color: white; font-weight: 700; font-size: 28px; text-shadow: 0 2px 5px rgba(0,0,0,0.15); }
             h5 { margin: 0 0 15px 0; color: #7f8c8d; font-weight: 700; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 1px; }

             .kpi-val { font-size: 36px; font-weight: 700; color: #2c3e50; margin-bottom: 5px; line-height: 1.2; }

             .trend-green { color: #27ae60; font-size: 14px; display: flex; align-items: center; gap: 5px; font-weight: 600; }
             .trend-red { color: #e74c3c; font-size: 14px; display: flex; align-items: center; gap: 5px; font-weight: 600; }

             .slider-img { width: 100%; height: 100%; object-fit: cover; transition: opacity 0.5s ease-in-out; }

             .selectize-input { border-radius: 12px !important; border: 1px solid #e0e0e0; padding: 12px 15px !important; font-size: 14px; box-shadow: none; background-color: #f9f9f9; }
             .selectize-dropdown { z-index: 9999 !important; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }

             /* --- LOADING ANIMATION (FIXED INITIAL STATE) --- */
             #loading_overlay {
               position: fixed; /* Ubah ke fixed agar menutupi seluruh viewport */
               top: 0; left: 0; width: 100%; height: 100%;
               background: rgba(255, 255, 255, 0.9); backdrop-filter: blur(5px);
               display: flex; flex-direction: column; justify-content: center; align-items: center;
               z-index: 1000; transition: opacity 0.5s;
               pointer-events: auto; /* Awalnya aktif */
               opacity: 1; /* Awalnya terlihat */
             }
             .loading-logo-container {
               display: flex; flex-direction: column; justify-content: center; align-items: center;
             }
             .loading-logo {
               width: 100px; height: 100px;
               animation: spin 2s linear infinite, grow-shrink 2s ease-in-out infinite alternate;
             }
             .loading-text {
               color: #3080A8; font-weight: 600; font-size: 18px; margin-top: 15px;
             }
             @keyframes spin { 100% { transform: rotate(360deg); } }
             @keyframes grow-shrink {
                 0% { transform: scale(0.8); opacity: 0.7; }
                 100% { transform: scale(1.0); opacity: 1; }
             }

             /* Wrapper untuk Plot dengan Loading */
             .plot-container { position: relative; width: 100%; height: 100%; }
             .plot-loading {
                 position: absolute; top: 0; left: 0; width: 100%; height: 100%;
                 background: rgba(255, 255, 255, 0.8);
                 border-radius: 18px;
                 display: flex; justify-content: center; align-items: center;
                 z-index: 10;
                 opacity: 0; /* Plot loading awalnya tersembunyi */
                 transition: opacity 0.5s;
             }
             .plot-loading .loading-logo { width: 50px; height: 50px; }
             .plot-loading .loading-text { display: none; } /* Jangan tampilkan teks loading di chart kecil */


             /* --- PROFIL PAGE: SOCIAL MEDIA BUTTONS --- */
             .social-links {
                 display: flex; justify-content: center; gap: 15px; margin-top: 15px;
             }
             .social-btn {
                 color: white; width: 35px; height: 35px; border-radius: 50%;
                 display: flex; justify-content: center; align-items: center;
                 font-size: 18px; transition: transform 0.2s, box-shadow 0.2s;
             }
             .social-btn:hover { transform: translateY(-3px); box-shadow: 0 6px 10px rgba(0,0,0,0.2); }
             .tiktok { background-color: #000000; }
             .instagram { background: radial-gradient(circle at 30% 107%, #fdf497 0%, #fdf497 5%, #fd5949 45%, #d6249f 60%, #285AEB 90%); }
             .github { background-color: #333; }
        "))
  ),
  
  tags$script(HTML("
        /* Toggle Sidebar */
        $(document).on('click', '#toggle_sidebar', function() {
          $('#sidebar').toggleClass('collapsed');
          setTimeout(function() { $(window).trigger('resize'); }, 300);
        });

        /* Image Slider for area-slider */
        var imgIndex = 0;
        var images = [
          'https://i.pinimg.com/1200x/b6/ac/26/b6ac26e6ddbcf4adc924c95083089f45.jpg',
          'https://i.pinimg.com/1200x/24/06/1d/24061da59828576d6a82654d7c5f8e5d.jpg',
          'https://i.pinimg.com/736x/ac/66/f2/ac66f2b428a4813a2295ed1cbc33f46a.jpg',
          'https://i.pinimg.com/736x/f4/01/aa/f401aa1d98fcf8b8bf3be370ea8e341f.jpg'
        ];
        setInterval(function(){
          imgIndex = (imgIndex + 1) % images.length;
          $('#slider_img_tag').fadeOut(400, function() {
            $(this).attr('src', images[imgIndex]).fadeIn(400);
          });
        }, 4000);

        /* --- Show/Hide Loading Overlay for Main Content (FIXED) --- */
        // Logika ini memastikan loading overlay muncul saat operasi Shiny sedang berlangsung
        $(document).on('shiny:busy', function(event) {
            // Cek jika ada operasi yang membutuhkan waktu, selain interaksi input cepat
            if (event.target.id === 'content' || event.target.id === 'main_view' || event.target.id === 'raw_data') {
                $('#loading_overlay').css('opacity', '1').css('pointer-events', 'auto');
            }
        });

        // Logika ini memastikan loading overlay HILANG setelah semua selesai (termasuk inisialisasi awal)
        $(document).on('shiny:idle', function(event) {
            // Tunggu sebentar untuk memastikan semua render selesai
            setTimeout(function() {
                $('#loading_overlay').css('opacity', '0').css('pointer-events', 'none');
            }, 300); // Penundaan kecil 300ms untuk memastikan UI sudah stabil
        });


        /* Animation when Plotly charts update */
        $(document).on('shiny:recalculating', function(event) {
            var plotId = event.target.id;
            if (plotId.startsWith('plot_')) {
                $('#loading-' + plotId).css('opacity', '1');
                $('#' + plotId).css('opacity', '0.3'); // Efek blur/fade pada chart lama
            }
        });

        $(document).on('shiny:value', function(event) {
            var plotId = event.target.id;
            if (plotId.startsWith('plot_')) {
                  // Beri sedikit delay untuk melihat animasi loading
                setTimeout(function() {
                    $('#loading-' + plotId).css('opacity', '0');
                    $('#' + plotId).css('opacity', '1');
                }, 500); // 500ms delay untuk menunjukkan loading
            }
        });

    ")),
  
  div(id = "loading_overlay", # Full Screen Loading Overlay (FIXED POSITION)
      div(class = "loading-logo-container",
          img(src = "https://upload.wikimedia.org/wikipedia/commons/4/44/BMW.svg", class = "loading-logo"),
          div(class = "loading-text", "Loading...") # Teks Loading Baru
      )
  ),
  
  div(class = "wrapper",
      div(id = "sidebar",
          div(class = "logo-area",
              img(src = "https://upload.wikimedia.org/wikipedia/commons/4/44/BMW.svg", class = "logo-img"),
              span(class = "logo-text", "BMW Data")
          ),
          
          # Input file excel
          div(style="padding: 0 15px;",
              fileInput("file_upload", "Upload Data Excel (.xlsx)", accept = c(".xlsx"))
          ),
          
          actionLink("btn_dashboard", HTML("<i class='fa-solid fa-chart-line'></i> <span class='menu-text'>Dashboard</span>"), class = "menu-btn active"),
          actionLink("btn_table", HTML("<i class='fa-solid fa-table'></i> <span class='menu-text'>Database</span>"), class = "menu-btn"),
          actionLink("btn_profile", HTML("<i class='fa-solid fa-users'></i> <span class='menu-text'>Profil Tim</span>"), class = "menu-btn")
      ),
      
      div(id = "content",
          div(style = "margin-bottom: 20px; display: flex; align-items: center;",
              tags$button(id = "toggle_sidebar", icon("bars"), style = "background:none; border:none; color:white; font-size:24px; cursor:pointer; margin-right: 15px;")
          ),
          uiOutput("main_view")
      )
  )
)


# SERVER
server <- function(input, output, session) {
  
  current_page <- reactiveVal("dashboard")
  
  observeEvent(input$btn_dashboard, { current_page("dashboard") })
  observeEvent(input$btn_table, { current_page("table") })
  observeEvent(input$btn_profile, { current_page("profile") })
  
  observe({
    pg <- current_page()
    runjs("$('.menu-btn').removeClass('active');")
    if(pg == "dashboard") runjs("$('#btn_dashboard').addClass('active');")
    if(pg == "table") runjs("$('#btn_table').addClass('active');")
    if(pg == "profile") runjs("$('#btn_profile').addClass('active');")
  })
  
  # LOGIKA DATA
  Data_Manager <- list(
    
    # Properti Reaktif
    raw_data = reactive({
      Sys.sleep(0.5)
      
      if (is.null(input$file_upload)) {
        # Dummy data 
        set.seed(123)
        models <- c("5 Series", "i8", "X3", "7 Series", "M5", "3 Series", "X1", "M3", "X5")
        regions <- c("Asia", "North America", "Middle East", "South America", "Europe", "Africa")
        years <- 2010:2024
        
        df <- data.frame(
          Model = sample(models, 1000, replace = TRUE),
          Year = sample(years, 1000, replace = TRUE),
          Region = sample(regions, 1000, replace = TRUE),
          Sales_Volume = sample(500:10000, 1000, replace = TRUE),
          Price_USD = sample(30000:120000, 1000, replace = TRUE)
        ) %>%
          mutate(Revenue = Price_USD * Sales_Volume)
        return(df)
      } else {
        # Baca Excel
        req(input$file_upload)
        tryCatch({
          df <- read_excel(input$file_upload$datapath)
          if(!"Revenue" %in% names(df) && "Price_USD" %in% names(df) && "Sales_Volume" %in% names(df)){
            df$Revenue <- df$Price_USD * df$Sales_Volume
          }
          return(df)
        }, error = function(e) {
          showNotification("Error membaca file Excel. Pastikan format benar.", type = "error")
          return(NULL)
        })
      }
    }),
    
    # Metode Reaktif 
    filter_kpi = reactive({
      req(Data_Manager$raw_data())
      d <- Data_Manager$raw_data()
      if(!is.null(input$in_year) && input$in_year != "All Years") {
        d <- d %>% filter(Year == as.numeric(input$in_year))
      }
      if(!is.null(input$in_model) && input$in_model != "All Models") {
        d <- d %>% filter(Model == input$in_model)
      }
      d
    }),
    
    # Metode Reaktif 
    filter_line = reactive({
      req(Data_Manager$raw_data())
      d <- Data_Manager$raw_data()
      if(!is.null(input$in_model) && input$in_model != "All Models") {
        d <- d %>% filter(Model == input$in_model)
      }
      d
    })
  )
  
  # LOGIKA KALKULASI
  KPI_Calculator <- list(
    
    # Metode Reaktif (Hitung Semua KPI)
    kpi_metrics = reactive({
      current_data <- Data_Manager$filter_kpi()
      full_data <- Data_Manager$raw_data()
      
      curr_sales <- sum(current_data$Sales_Volume)
      curr_rev <- sum(current_data$Revenue)
      
      # Logika Perbandingan Tahun 
      if(input$in_year == "All Years") {
        max_year <- max(full_data$Year)
        last_yr_data <- full_data %>% filter(Year == max_year)
        prev_yr_data <- full_data %>% filter(Year == max_year - 1)
        
        if(input$in_model != "All Models") {
          last_yr_data <- last_yr_data %>% filter(Model == input$in_model)
          prev_yr_data <- prev_yr_data %>% filter(Model == input$in_model)
        }
        
        sales_diff <- sum(last_yr_data$Sales_Volume) - sum(prev_yr_data$Sales_Volume)
        rev_diff <- sum(last_yr_data$Revenue) - sum(prev_yr_data$Revenue)
        prev_sales_sum <- sum(prev_yr_data$Sales_Volume)
        prev_rev_sum <- sum(prev_yr_data$Revenue)
        
        pct_sales <- if(prev_sales_sum > 0) (sales_diff / prev_sales_sum) * 100 else 0
        pct_rev <- if(prev_rev_sum > 0) (rev_diff / prev_rev_sum) * 100 else 0
        
      } else {
        target_year <- as.numeric(input$in_year)
        prev_year <- target_year - 1
        
        prev_data <- full_data %>% filter(Year == prev_year)
        if(input$in_model != "All Models") {
          prev_data <- prev_data %>% filter(Model == input$in_model)
        }
        
        prev_sales <- sum(prev_data$Sales_Volume)
        prev_rev <- sum(prev_data$Revenue)
        
        pct_sales <- if(prev_sales > 0) ((curr_sales - prev_sales) / prev_sales) * 100 else 0
        pct_rev <- if(prev_rev > 0) ((curr_rev - prev_rev) / prev_rev) * 100 else 0
      }
      
      list(sales = curr_sales, rev = curr_rev, pct_sales = round(pct_sales, 2), pct_rev = round(pct_rev, 2))
    })
  )
  
  # UI DYNAMIC FOR INPUTS 
  observe({
    req(Data_Manager$raw_data())
    d <- Data_Manager$raw_data()
    updateSelectInput(session, "in_year", choices = c("All Years", sort(unique(d$Year))))
    updateSelectInput(session, "in_model", choices = c("All Models", unique(d$Model)))
  })
  
  # UI RENDERER
  output$main_view <- renderUI({
    pg <- current_page()
    
    if (pg == "dashboard") {
      div(class = "dashboard-grid",
          
          div(class = "area-header", h2("Analisis Penjualan BMW 2010-2024", class="page-title")),
          
          div(class = "card area-kpi1", h5("Total Penjualan"), uiOutput("kpi_sales_ui")),
          
          div(class = "card area-kpi2", h5("Revenue (USD)"), uiOutput("kpi_revenue_ui")),
          
          div(class = "card area-inputs",
              div(style="display:flex; justify-content:space-between; align-items:center;", h5("Filter Data", style="margin:0;")),
              div(style="height: 15px;"),
              selectInput("in_year", NULL, choices = NULL, width = "100%"),
              div(style="height: 15px;"),
              selectInput("in_model", NULL, choices = NULL, width = "100%")
          ),
          
          div(class = "card area-pie", h5("Region Distribution", style="text-align:center; margin-bottom:5px;"), plot_with_loading("plot_pie")),
          
          # Chart Line Overview
          div(class = "card area-line", h5("Sales Overview (Trend Tahunan)"), plot_with_loading("plot_line")),
          
          div(class = "card area-slider", tags$img(id = "slider_img_tag", src = "", class = "slider-img")),
          
          div(class = "card area-bar", h5("Model Paling Laku"), plot_with_loading("plot_bar"))
      )
    } else if (pg == "table") {
      div(class = "card", h3("Database Penjualan Lengkap"), DTOutput("tbl_data"))
    } else if (pg == "profile") {
      div(
        class = "card",
        h2("Profil Tim BMW Analytics", style="margin-bottom:25px; font-weight:700;"),
        
        div(
          style="display:grid;
                            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                            gap:25px;",
          
          lapply(1:nrow(anggota), function(i) {
            div(
              style="
                            background:white;
                            border-radius:18px;
                            padding:18px;
                            text-align:center;
                            box-shadow:0 8px 25px rgba(0,0,0,0.08);
                            transition:0.3s;
                            ",
              onmouseover = "this.style.transform='translateY(-5px)'",
              onmouseout  = "this.style.transform='translateY(0)'",
              
              # FOTO
              img(
                src = anggota$Foto[i],
                style="width:110px; height:110px; object-fit:cover; border-radius:50%;
                                        margin-bottom:15px; box-shadow:0 4px 12px rgba(0,0,0,0.15);"
              ),
              
              # NAMA
              h4(
                anggota$Nama[i],
                style="font-weight:700; margin:8px 0; color:#2c3e50;"
              ),
              
              # NIM
              p(
                paste("NIM:", anggota$NIM[i]),
                style="margin:0; color:#7f8c8d; font-size:14px;"
              ),
              
              # SOCIAL MEDIA BUTTONS
              div(class = "social-links",
                  tags$a(href = paste0("https://www.tiktok.com/", anggota$Tiktok[i]), target = "_blank", class = "social-btn tiktok", icon("tiktok")),
                  tags$a(href = paste0("https://www.instagram.com/", sub("^@", "", anggota$Instagram[i])), target = "_blank", class = "social-btn instagram", icon("instagram")),
                  tags$a(href = paste0("https://github.com/", anggota$Github[i]), target = "_blank", class = "social-btn github", icon("github"))
              )
            )
          })
        )
      )
    }
  })
  
  # PLOTS & METRICS RENDER
  output$kpi_sales_ui <- renderUI({
    m <- KPI_Calculator$kpi_metrics()
    tagList(div(class="kpi-val", format(m$sales, big.mark=",")), render_trend(m$pct_sales))
  })
  
  output$kpi_revenue_ui <- renderUI({
    m <- KPI_Calculator$kpi_metrics()
    txt <- paste0("$", format(round(m$rev/1e6, 1), big.mark=","), " M")
    tagList(div(class="kpi-val", txt), render_trend(m$pct_rev))
  })
  
  output$plot_line <- renderPlotly({
    Sys.sleep(0.2)
    df <- Data_Manager$filter_line() %>% group_by(Year) %>% summarise(Total = sum(Sales_Volume))
    
    p <- plot_ly(df, x = ~Year, y = ~Total, type = 'scatter', mode = 'lines+markers',
                 line = list(color = '#3080A8', width = 4, shape = 'spline'),
                 marker = list(color = '#1b5e80', size = 8)) %>%
      layout(margin = list(l=40, r=20, t=10, b=40),
             paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)',
             xaxis = list(showgrid=FALSE, title=""), yaxis = list(showgrid=TRUE, gridcolor='#eee', title="")) %>%
      config(displayModeBar = FALSE)
    p$x$layout$hovermode = 'x'
    p
  })
  
  output$plot_pie <- renderPlotly({
    Sys.sleep(0.2)
    df <- Data_Manager$filter_kpi() %>% count(Region)
    p <- plot_ly(df, labels = ~Region, values = ~n, type = 'pie', hole = 0.6,
                 textinfo = 'none', hoverinfo = 'label+percent+value',
                 marker = list(colors = c('#2ecc71', '#f1c40f', '#e74c3c', '#3498db', '#9b59b6'))) %>%
      layout(showlegend = TRUE, legend = list(orientation = "h", xanchor = "center", x = 0.5, y = -0.15, font = list(size = 10)),
             margin = list(l=10, r=10, t=10, b=30), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)') %>%
      config(displayModeBar = FALSE)
    p
  })
  
  output$plot_bar <- renderPlotly({
    Sys.sleep(0.2)
    df <- Data_Manager$filter_kpi() %>% group_by(Model) %>% summarise(Vol = sum(Sales_Volume)) %>% arrange(desc(Vol)) %>% head(10)
    p <- plot_ly(df, x = ~Model, y = ~Vol, type = 'bar', marker = list(color = '#5DADE2')) %>%
      layout(margin = list(l=30, r=10, t=10, b=30), paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)',
             xaxis = list(title=""), yaxis = list(title="")) %>%
      config(displayModeBar = FALSE)
    p
  })
  
  output$tbl_data <- renderDT({
    datatable(Data_Manager$raw_data(), options = list(pageLength = 10, scrollX = TRUE))
  })
}

shinyApp(ui, server)