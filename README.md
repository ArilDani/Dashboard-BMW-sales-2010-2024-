# BMW Sales Analytics Dashboard (2010-2024)

[![Shiny App Link](https://img.shields.io/badge/Launch%20App-ShinyApps.io-blue?style=for-the-badge&logo=rstudio)](https://arutia.shinyapps.io/Dashboard_BMW_Sales/)

Dashboard interaktif ini dibuat menggunakan **R Shiny** dan **Plotly** untuk memvisualisasikan dan menganalisis data penjualan mobil BMW dari tahun 2010 hingga 2024. Dashboard ini memberikan wawasan mendalam mengenai tren penjualan, pendapatan (revenue), distribusi regional, dan model terlaris.

## 👥 Kelompok: Keatawa-Kertawa

| No | Nama Anggota | NIM |
|---|---|---|
| 1 | M. Aril Ardani | 240907500023 |
| 2 | Muhammad Fauzan Ali Fatah | 240907500027 |
| 3 | Firman | 240907501044 |
| 4 | Ahmad Naufal Dzaky | 240907502037 |

---

## Fitur Utama

Dashboard ini dibagi menjadi tiga tampilan utama yang dapat diakses melalui Sidebar:

### 1. Dashboard 📊
Menampilkan visualisasi kunci untuk analisis penjualan:
* **Key Performance Indicators (KPIs):** Menampilkan total **Sales Volume** dan **Revenue (USD)**, lengkap dengan persentase perubahan (**Trend**) dibandingkan periode sebelumnya (tahun sebelumnya atau tahun teratas dalam data).
* **Filter Interaktif:** Memungkinkan pengguna memfilter data berdasarkan **Tahun** dan **Model** tertentu.
* **Plot Garis (Annual Trend):** Menampilkan tren total volume penjualan dari tahun ke tahun.
* **Plot Pie (Region Distribution):** Menunjukkan proporsi penjualan berdasarkan **Region**.
* **Plot Bar (Top Models):** Memvisualisasikan 10 model mobil terlaris berdasarkan volume penjualan.
* **Image Slider:** Menampilkan gambar-gambar mobil BMW secara bergantian untuk estetika.

### 2. Database 📁
Menampilkan tabel data lengkap (**Raw Data**) dalam format interaktif (menggunakan `DT`) sehingga pengguna dapat melihat detail, mencari, dan mengurutkan seluruh data penjualan.

### 3. Profil Tim 🧑‍💻
Menyajikan informasi anggota tim pengembang, lengkap dengan foto dan tautan ke media sosial/profil GitHub masing-masing.

---

## 📈 Mekanisme Analisis dan Visualisasi

Analisis dalam dashboard ini didorong oleh komponen reaktif dalam R Shiny, yang diorganisir dalam objek `Data_Manager` dan `KPI_Calculator` di sisi **Server**.

### 1. Pengelolaan Data (`Data_Manager`)
* **Sumber Data:** Aplikasi ini dapat menggunakan **Data Dummy** (jika tidak ada file yang diunggah) atau menerima data melalui `fileInput` dari file **Excel (.xlsx)**.
* **Persiapan Data:** Fungsi `raw_data()` memastikan data yang masuk memiliki kolom yang diperlukan, termasuk menghitung kolom `Revenue` ($Revenue = Price\_USD \times Sales\_Volume$) jika kolom tersebut belum ada.
* **Filtering:** Fungsi `filter_kpi()` dan `filter_line()` secara reaktif menyesuaikan data berdasarkan pilihan filter `in_year` dan `in_model` dari pengguna.

### 2. Perhitungan KPI (`KPI_Calculator`)
* Fungsi `kpi_metrics()` menghitung Total Penjualan dan Total Revenue dari data yang telah difilter.
* **Logika Trend (Perubahan Persentase):**
    * Jika filter **Tahun** adalah "All Years", perbandingan dilakukan antara **Tahun Terakhir** dengan **Tahun Sebelumnya**.
    * Jika filter **Tahun** adalah tahun tertentu, perbandingan dilakukan antara **Tahun yang Dipilih** dengan **Tahun Sebelumnya** ($Tahun\_n$ vs $Tahun\_{n-1}$).

### 3. Visualisasi (Menggunakan `plotly`)
* **`plot_line`:** Meringkas data penjualan per `Year` dan menampilkan hasilnya sebagai *Line Chart* untuk menunjukkan tren waktu.
* **`plot_pie`:** Mengelompokkan data berdasarkan `Region` dan menggunakan hasilnya untuk *Donut Chart* untuk perbandingan proporsi regional.
* **`plot_bar`:** Mengelompokkan data berdasarkan `Model`, menghitung total volume penjualan, dan menampilkan 10 teratas dalam *Bar Chart*.

Visualisasi di-render menggunakan `renderPlotly` dan `plot_ly` untuk fitur interaktif (hover, zoom) dan desain yang menarik.

---

## 🛠️Requirements

Untuk menjalankan aplikasi ini, Anda harus memiliki **R** terinstal dan menginstal *package* berikut:

```r
install.packages(c("shiny", "dplyr", "plotly", "DT", "shinyjs", "readxl"))
