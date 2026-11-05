# =============================================================================
# survey_utils.R
# Fungsi bantu untuk analisis instrumen survei: validitas item, reliabilitas,
# skor dimensi, dan tabel odds ratio regresi logistik ordinal.
#
# Mengapa ditulis manual padahal ada psych::alpha: supaya rumus yang dipakai
# transparan dan bisa diuji unit (tests/testthat). Di laporan, hasil manual
# tetap dibandingkan dengan psych::alpha sebagai verifikasi silang.
# =============================================================================

#' Cronbach's alpha (rumus baku)
#'
#' alpha = k/(k-1) * (1 - sum(var_item) / var_total)
#'
#' @param x data.frame atau matriks numerik; kolom = item, baris = responden.
#' @return Nilai alpha (numerik tunggal).
#' @export
cronbach_alpha <- function(x) {
  x <- as.matrix(x)
  k <- ncol(x)
  if (k < 2) stop("Minimal dua item diperlukan untuk menghitung alpha.")
  var_item  <- apply(x, 2, stats::var)
  var_total <- stats::var(rowSums(x))
  (k / (k - 1)) * (1 - sum(var_item) / var_total)
}

#' Korelasi item-total terkoreksi (corrected item-total correlation)
#'
#' Setiap item dikorelasikan dengan jumlah item LAIN dalam dimensi yang sama
#' (dikoreksi agar item tidak berkorelasi dengan dirinya sendiri). Item dengan
#' r < 0,30 lazim dianggap kurang valid secara konstruk.
#'
#' @param x data.frame numerik, kolom = item.
#' @param threshold Ambang minimal r (default 0,30).
#' @return data.frame: item, r_item_total, alpha_if_deleted, valid.
#' @export
item_total_correlation <- function(x, threshold = 0.30) {
  x <- as.data.frame(x)
  out <- lapply(names(x), function(nm) {
    rest <- rowSums(x[, setdiff(names(x), nm), drop = FALSE])
    data.frame(
      item             = nm,
      r_item_total     = stats::cor(x[[nm]], rest),
      alpha_if_deleted = cronbach_alpha(x[, setdiff(names(x), nm), drop = FALSE]),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, out)
  out$valid <- out$r_item_total >= threshold
  out
}

#' Peta item ke dimensi SERVQUAL berdasarkan awalan nama kolom
#'
#' @param item_names Vektor nama item, misal "rel_1".
#' @return Vektor karakter nama dimensi.
#' @export
map_dimension <- function(item_names) {
  prefix <- substr(item_names, 1, 3)
  dict <- c(tan = "Tangibles", rel = "Reliability", res = "Responsiveness",
            ass = "Assurance", emp = "Empathy")
  unname(dict[prefix])
}

#' Hitung skor dimensi (rata-rata item) untuk tiap responden
#'
#' @param df data.frame survei.
#' @param items Vektor nama kolom item.
#' @return data.frame dengan satu kolom per dimensi (skor 1-5).
#' @export
dimension_scores <- function(df, items) {
  dims <- unique(map_dimension(items))
  out <- lapply(dims, function(d) {
    cols <- items[map_dimension(items) == d]
    rowMeans(df[, cols, drop = FALSE])
  })
  names(out) <- dims
  as.data.frame(out)
}

#' Tabel odds ratio dari model MASS::polr
#'
#' @param model Objek hasil MASS::polr.
#' @param conf_level Tingkat kepercayaan (default 0,95).
#' @return data.frame: term, estimate, odds_ratio, ci_lower, ci_upper, p_value.
#' @export
odds_ratio_table <- function(model, conf_level = 0.95) {
  ct <- stats::coef(summary(model))
  ct <- ct[seq_along(stats::coef(model)), , drop = FALSE]  # hanya koefisien, bukan threshold
  z  <- stats::qnorm(1 - (1 - conf_level) / 2)
  p  <- 2 * stats::pnorm(abs(ct[, "t value"]), lower.tail = FALSE)
  data.frame(
    term       = rownames(ct),
    estimate   = ct[, "Value"],
    odds_ratio = exp(ct[, "Value"]),
    ci_lower   = exp(ct[, "Value"] - z * ct[, "Std. Error"]),
    ci_upper   = exp(ct[, "Value"] + z * ct[, "Std. Error"]),
    p_value    = p,
    row.names  = NULL
  )
}

#' Interpretasi kualitatif nilai alpha (George & Mallery)
#'
#' @param alpha Nilai numerik.
#' @return Label karakter.
#' @export
interpret_alpha <- function(alpha) {
  cut(alpha, c(-Inf, 0.5, 0.6, 0.7, 0.8, 0.9, Inf),
      labels = c("Tidak dapat diterima", "Buruk", "Dipertanyakan",
                 "Dapat diterima", "Baik", "Sangat baik"),
      right = FALSE)
}
