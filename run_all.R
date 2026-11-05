#!/usr/bin/env Rscript
# =============================================================================
# run_all.R: jalankan seluruh alur kerja dari awal sampai akhir:
#   1. bangkitkan data simulasi  -> data/raw/*.csv
#   2. render tiga laporan R Markdown -> reports/*.html (+ gambar di assets/)
#   3. buat gambar hero untuk README -> assets/hero.png
#   4. jalankan tes unit (testthat)
#
# Cara pakai (dari root repositori):  Rscript run_all.R
# Mengapa satu skrip: agar siapa pun (termasuk CI) dapat mereproduksi semua
# angka di README dengan satu perintah.
# =============================================================================

if (!file.exists("R/simulate_data.R")) {
  stop("Jalankan skrip ini dari root repositori (folder yang berisi run_all.R).")
}
t0 <- Sys.time()
source("R/plot_theme.R"); pastikan_utf8()   # lokal UTF-8 untuk simbol pada grafik
pkgs <- c("dplyr", "tidyr", "ggplot2", "psych", "car", "qcc", "MASS",
          "rmarkdown", "knitr", "testthat")
hilang <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(hilang)) stop("Paket belum terpasang: ", paste(hilang, collapse = ", "),
                         ". Jalankan: source('requirements.R')")

# 1. Data ----------------------------------------------------------------------
message("[1/4] Membangkitkan data simulasi ...")
source("R/simulate_data.R")
files <- write_all_data("data/raw")
message("      ", length(files), " berkas CSV ditulis ke data/raw/")

# 2. Render laporan ------------------------------------------------------------
message("[2/4] Merender laporan R Markdown ...")
rmds <- list.files("analysis", pattern = "\\.Rmd$", full.names = TRUE)
for (f in rmds) {
  message("      - ", basename(f))
  rmarkdown::render(f, output_dir = "reports", knit_root_dir = getwd(),
                    quiet = TRUE, envir = new.env())
}

# 3. Gambar hero ---------------------------------------------------------------
message("[3/4] Membuat gambar hero README ...")
source("R/make_hero.R")
make_hero("assets/hero.png")

# 4. Tes unit ------------------------------------------------------------------
message("[4/4] Menjalankan tes unit ...")
res <- testthat::test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE)

message(sprintf("Selesai dalam %.1f menit.", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
