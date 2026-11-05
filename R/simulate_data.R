# =============================================================================
# simulate_data.R
# Pembangkit data simulasi yang deterministik untuk ketiga modul analisis.
#
# Mengapa data disimulasikan: data survei dan data proses produksi yang nyata
# biasanya bersifat rahasia. Dengan simulasi yang parameternya dijelaskan
# terbuka, pembaca bisa menilai apakah metode analisis mampu "menemukan
# kembali" struktur yang sengaja ditanam (misalnya 5 faktor SERVQUAL, efek
# interaksi suhu x bahan, atau pergeseran rata-rata proses).
# Semua fungsi memakai set.seed(2024) supaya hasil selalu sama.
# =============================================================================

#' Simulasi data survei kepuasan pelanggan (SERVQUAL)
#'
#' Menghasilkan 20 item Likert 1-5 (4 item untuk tiap 5 dimensi SERVQUAL),
#' variabel demografi, dan kepuasan keseluruhan ordinal 1-5.
#'
#' Mekanisme: setiap responden punya 5 skor laten dimensi yang saling
#' berkorelasi (r = 0,45) karena pada layanan nyata dimensi-dimensi ini memang
#' tidak independen. Setiap item = loading x skor laten + galat, lalu dipotong
#' menjadi 5 kategori. Kepuasan keseluruhan bergantung terutama pada
#' reliability dan responsiveness (dengan bobot lebih besar) supaya regresi
#' ordinal punya efek yang jelas untuk diinterpretasi.
#'
#' @param n Jumlah responden (default 400).
#' @param seed Benih acak (default 2024).
#' @return data.frame berisi id, demografi, 20 item, dan overall_satisfaction.
#' @export
simulate_survey <- function(n = 400, seed = 2024) {
  set.seed(seed)
  dims <- c("tangibles", "reliability", "responsiveness", "assurance", "empathy")

  # Skor laten 5 dimensi dengan korelasi antar-dimensi 0,45
  rho   <- 0.45
  sigma <- matrix(rho, 5, 5); diag(sigma) <- 1
  latent <- MASS::mvrnorm(n, mu = rep(0, 5), Sigma = sigma)
  colnames(latent) <- dims

  # Loading item sengaja dibuat berbeda (0,55-0,85) agar ada variasi
  # korelasi item-total; item ke-4 empathy dibuat lemah (0,35) sebagai
  # "item bermasalah" yang seharusnya terdeteksi oleh uji validitas.
  loadings <- list(
    tangibles      = c(0.75, 0.80, 0.70, 0.65),
    reliability    = c(0.85, 0.80, 0.78, 0.72),
    responsiveness = c(0.80, 0.76, 0.74, 0.70),
    assurance      = c(0.78, 0.72, 0.70, 0.60),
    empathy        = c(0.74, 0.70, 0.66, 0.35)
  )
  # Ambang pemotongan ke skala 1-5 (sedikit condong ke kanan karena
  # responden survei kepuasan cenderung memberi nilai 3-4)
  cuts <- c(-Inf, -1.6, -0.7, 0.4, 1.4, Inf)

  items <- list()
  for (d in dims) {
    for (k in seq_along(loadings[[d]])) {
      lam <- loadings[[d]][k]
      y   <- lam * latent[, d] + sqrt(1 - lam^2) * rnorm(n)
      items[[sprintf("%s_%d", substr(d, 1, 3), k)]] <- as.integer(cut(y, cuts))
    }
  }
  items <- as.data.frame(items)

  # Kepuasan keseluruhan: reliability & responsiveness berbobot paling besar
  eta <- 0.9 * latent[, "reliability"] + 0.7 * latent[, "responsiveness"] +
         0.4 * latent[, "assurance"]   + 0.3 * latent[, "empathy"] +
         0.2 * latent[, "tangibles"]   + rnorm(n, sd = 0.8)
  # Ambang sedikit condong ke kanan: survei kepuasan nyata umumnya didominasi
  # jawaban "puas" (4) dan "netral" (3)
  overall <- as.integer(cut(eta, c(-Inf, -2.2, -1.1, 0.1, 1.3, Inf)))

  demog <- data.frame(
    respondent_id = sprintf("R%03d", seq_len(n)),
    gender        = sample(c("Laki-laki", "Perempuan"), n, TRUE, prob = c(0.48, 0.52)),
    age_group     = sample(c("18-25", "26-35", "36-45", "46-55", ">55"), n, TRUE,
                           prob = c(0.22, 0.33, 0.25, 0.13, 0.07)),
    usage_freq    = sample(c("Jarang", "Bulanan", "Mingguan", "Harian"), n, TRUE,
                           prob = c(0.2, 0.35, 0.3, 0.15)),
    stringsAsFactors = FALSE
  )
  cbind(demog, items, overall_satisfaction = overall)
}

#' Simulasi eksperimen faktorial 3 x 2 (suhu x bahan) dengan 5 replikasi
#'
#' Respons: kekuatan tarik (MPa). Efek yang ditanam: suhu menaikkan kekuatan
#' secara non-linier, bahan B lebih kuat dari A, dan ada interaksi: keuntungan
#' bahan B mengecil pada suhu tinggi. Galat normal dengan sd = 2,2 MPa.
#'
#' @param reps Jumlah replikasi tiap kombinasi (default 5).
#' @param seed Benih acak.
#' @return data.frame: run_order, temperature, material, tensile_strength.
#' @export
simulate_experiment <- function(reps = 5, seed = 2024) {
  set.seed(seed)
  design <- expand.grid(replicate   = seq_len(reps),
                        material    = c("A", "B"),
                        temperature = c(150, 175, 200),
                        stringsAsFactors = FALSE)
  # Rata-rata sel (MPa) yang ditanam
  cell_mean <- c("150_A" = 40, "175_A" = 46, "200_A" = 48,
                 "150_B" = 47, "175_B" = 50, "200_B" = 49)
  key <- paste(design$temperature, design$material, sep = "_")
  design$tensile_strength <- round(cell_mean[key] + rnorm(nrow(design), sd = 2.2), 2)
  # Urutan run diacak, sebagaimana praktik eksperimen yang baik
  design$run_order <- sample(seq_len(nrow(design)))
  design <- design[order(design$run_order), ]
  rownames(design) <- NULL
  design[, c("run_order", "temperature", "material", "replicate", "tensile_strength")]
}

#' Simulasi data proses produksi untuk peta kendali
#'
#' Variabel: diameter poros (mm) dengan target 50,00 mm.
#' Fase I: 25 subgrup x 5 pengukuran, proses stabil (mean 50, sd 0,20).
#' Fase II: 15 subgrup x 5; mulai subgrup ke-6 fase II rata-rata bergeser
#' +0,15 mm (0,75 sigma) - pergeseran kecil yang menantang untuk dideteksi.
#' Atribut: 30 lot berukuran 200 unit, proporsi cacat 0,03; lot 18-19 naik
#' menjadi 0,09 untuk meniru gangguan sesaat.
#'
#' @param seed Benih acak.
#' @return list berisi tiga data.frame: phase1, phase2, attribute.
#' @export
simulate_spc <- function(seed = 2024) {
  set.seed(seed)
  make_phase <- function(n_sub, mu, sigma, label) {
    df <- data.frame(
      phase    = label,
      subgroup = rep(seq_len(n_sub), each = 5),
      obs      = rep(1:5, times = n_sub),
      diameter = round(rnorm(n_sub * 5, mean = mu, sd = sigma), 3)
    )
    df
  }
  phase1 <- make_phase(25, 50.00, 0.20, "I")

  mu2 <- c(rep(50.00, 5), rep(50.15, 10))
  phase2 <- make_phase(15, rep(mu2, each = 5), 0.20, "II")

  p_true <- rep(0.03, 30); p_true[18:19] <- 0.09
  attribute <- data.frame(
    lot        = seq_len(30),
    sample_size = 200L,
    defectives = rbinom(30, 200, p_true)
  )
  list(phase1 = phase1, phase2 = phase2, attribute = attribute)
}

#' Bangkitkan semua data dan simpan ke data/raw
#'
#' @param dir Folder tujuan (default "data/raw").
#' @return Vektor path berkas CSV yang ditulis (invisible).
#' @export
write_all_data <- function(dir = "data/raw") {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  spc <- simulate_spc()
  files <- c(
    survey_kepuasan      = file.path(dir, "survey_kepuasan.csv"),
    eksperimen_faktorial = file.path(dir, "eksperimen_faktorial.csv"),
    spc_fase1            = file.path(dir, "spc_fase1.csv"),
    spc_fase2            = file.path(dir, "spc_fase2.csv"),
    spc_atribut          = file.path(dir, "spc_atribut.csv")
  )
  utils::write.csv(simulate_survey(),     files["survey_kepuasan"],      row.names = FALSE)
  utils::write.csv(simulate_experiment(), files["eksperimen_faktorial"], row.names = FALSE)
  utils::write.csv(spc$phase1,            files["spc_fase1"],            row.names = FALSE)
  utils::write.csv(spc$phase2,            files["spc_fase2"],            row.names = FALSE)
  utils::write.csv(spc$attribute,         files["spc_atribut"],          row.names = FALSE)
  invisible(files)
}
