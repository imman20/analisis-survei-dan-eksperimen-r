#!/usr/bin/env Rscript
# =============================================================================
# requirements.R: memasang paket yang dibutuhkan dengan versi yang sama persis
# seperti saat laporan ini dibuat (hasil packageVersion() pada lingkungan asal).
#
# Cara pakai:  Rscript requirements.R
# Alternatif:  renv::restore()  (memakai renv.lock)
#
# Mengapa versi dikunci: hasil numerik (terutama EFA dan polr) bisa sedikit
# berbeda antar-versi paket; mengunci versi menjamin angka di README dapat
# direproduksi persis.
# =============================================================================

versi <- c(
  dplyr       = "1.1.4",
  tidyr       = "1.3.1",
  ggplot2     = "3.4.4",
  psych       = "2.4.1",
  GPArotation = "2026.8-2",
  car         = "3.1-2",
  qcc         = "2.7",
  MASS        = "7.3-60.0.1",
  rmarkdown   = "2.25",
  knitr       = "1.45",
  testthat    = "3.2.1",
  renv        = "1.0.3"
)

repos <- "https://cloud.r-project.org"
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes", repos = repos)

for (p in names(versi)) {
  sudah <- requireNamespace(p, quietly = TRUE) &&
    as.character(utils::packageVersion(p)) == gsub("-", ".", versi[[p]])
  if (sudah) { message("OK   ", p, " ", versi[[p]]); next }
  message("Pasang ", p, " ", versi[[p]], " ...")
  # Coba versi persis dari arsip CRAN; jika gagal (misal versi sudah ditarik),
  # pasang versi terbaru agar alur kerja tetap berjalan.
  tryCatch(remotes::install_version(p, version = versi[[p]], repos = repos, upgrade = "never"),
           error = function(e) {
             message("  gagal versi persis (", conditionMessage(e), "); memasang versi terbaru.")
             install.packages(p, repos = repos)
           })
}
message("Selesai. Jalankan: Rscript run_all.R")
