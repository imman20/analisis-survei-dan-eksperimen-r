# =============================================================================
# spc.R
# Fungsi Statistical Process Control (SPC): konstanta peta kendali, batas
# kendali X-bar/R dan p, aturan Western Electric, serta indeks kapabilitas.
#
# Mengapa ditulis manual padahal paket qcc tersedia: (1) agar rumus transparan
# dan dapat diuji unit; (2) agar hasil tetap bisa direproduksi bila qcc tidak
# terpasang. Di laporan, hasil manual diverifikasi silang terhadap qcc dan
# terhadap konstanta Montgomery, "Introduction to Statistical Quality Control".
# =============================================================================

#' Tabel konstanta peta kendali (Montgomery, Appendix VI)
#'
#' @param n Ukuran subgrup (2-10).
#' @return data.frame satu baris: n, A2, D3, D4, d2, c4.
#' @export
spc_constants <- function(n) {
  tbl <- data.frame(
    n  = 2:10,
    A2 = c(1.880, 1.023, 0.729, 0.577, 0.483, 0.419, 0.373, 0.337, 0.308),
    D3 = c(0,     0,     0,     0,     0,     0.076, 0.136, 0.184, 0.223),
    D4 = c(3.267, 2.574, 2.282, 2.114, 2.004, 1.924, 1.864, 1.816, 1.777),
    d2 = c(1.128, 1.693, 2.059, 2.326, 2.534, 2.704, 2.847, 2.970, 3.078),
    c4 = c(0.7979, 0.8862, 0.9213, 0.9400, 0.9515, 0.9594, 0.9650, 0.9693, 0.9727)
  )
  if (!n %in% tbl$n) stop("Konstanta tersedia untuk n = 2 sampai 10.")
  tbl[tbl$n == n, ]
}

#' Batas kendali peta X-bar dan R (fase I)
#'
#' @param x Matriks numerik: baris = subgrup, kolom = pengukuran.
#' @return list: n, xbar (vektor), r (vektor), xbar_cl/ucl/lcl, r_cl/ucl/lcl,
#'   sigma_within (R-bar/d2).
#' @export
xbar_r_limits <- function(x) {
  x <- as.matrix(x)
  n <- ncol(x)
  k <- spc_constants(n)
  xbar <- rowMeans(x)
  r    <- apply(x, 1, function(v) max(v) - min(v))
  xbb  <- mean(xbar)   # grand mean (X double bar)
  rbar <- mean(r)
  list(
    n = n, xbar = xbar, r = r,
    xbar_cl = xbb, xbar_ucl = xbb + k$A2 * rbar, xbar_lcl = xbb - k$A2 * rbar,
    r_cl = rbar,   r_ucl = k$D4 * rbar,          r_lcl = k$D3 * rbar,
    sigma_within = rbar / k$d2
  )
}

#' Aturan Western Electric (4 aturan dasar) pada deret statistik subgrup
#'
#' Aturan: (1) 1 titik di luar 3 sigma; (2) 2 dari 3 titik berurutan di luar
#' 2 sigma pada sisi yang sama; (3) 4 dari 5 titik berurutan di luar 1 sigma
#' pada sisi yang sama; (4) 8 titik berurutan pada sisi yang sama dari garis
#' tengah. Sigma yang dimaksud adalah sigma dari statistik yang diplot
#' (untuk X-bar: sigma_within / sqrt(n)).
#'
#' @param stat Vektor statistik subgrup (misal X-bar).
#' @param cl Garis tengah.
#' @param sigma_stat Simpangan baku statistik yang diplot.
#' @return data.frame: index, value, rule1, rule2, rule3, rule4, any_signal.
#' @export
western_electric <- function(stat, cl, sigma_stat) {
  z <- (stat - cl) / sigma_stat
  m <- length(z)
  rule1 <- abs(z) > 3
  rule2 <- rule3 <- rule4 <- rep(FALSE, m)
  for (i in seq_len(m)) {
    if (i >= 3) {
      w <- z[(i - 2):i]
      rule2[i] <- sum(w > 2) >= 2 || sum(w < -2) >= 2
    }
    if (i >= 5) {
      w <- z[(i - 4):i]
      rule3[i] <- sum(w > 1) >= 4 || sum(w < -1) >= 4
    }
    if (i >= 8) {
      w <- z[(i - 7):i]
      rule4[i] <- all(w > 0) || all(w < 0)
    }
  }
  data.frame(index = seq_len(m), value = stat, z = z,
             rule1 = rule1, rule2 = rule2, rule3 = rule3, rule4 = rule4,
             any_signal = rule1 | rule2 | rule3 | rule4)
}

#' Indeks kapabilitas proses Cp, Cpk, Pp, Ppk
#'
#' Cp/Cpk memakai sigma jangka pendek (within, dari R-bar/d2); Pp/Ppk memakai
#' sigma jangka panjang (overall, simpangan baku seluruh data). Selisih
#' keduanya menunjukkan seberapa besar variasi antar-subgrup.
#'
#' @param x Vektor seluruh pengukuran individual.
#' @param lsl,usl Batas spesifikasi bawah dan atas.
#' @param sigma_within Sigma jangka pendek (misal dari xbar_r_limits()).
#' @param target Nilai target (opsional, untuk Cpm).
#' @return data.frame satu baris: mean, sigma_within, sigma_overall, Cp, Cpk,
#'   Pp, Ppk, Cpm, ppm_expected (perkiraan ppm di luar spesifikasi, sigma within).
#' @export
capability_indices <- function(x, lsl, usl, sigma_within, target = NULL) {
  mu  <- mean(x)
  s_o <- stats::sd(x)
  cp  <- (usl - lsl) / (6 * sigma_within)
  cpk <- min((usl - mu) / (3 * sigma_within), (mu - lsl) / (3 * sigma_within))
  pp  <- (usl - lsl) / (6 * s_o)
  ppk <- min((usl - mu) / (3 * s_o), (mu - lsl) / (3 * s_o))
  cpm <- if (is.null(target)) NA_real_ else
    (usl - lsl) / (6 * sqrt(sigma_within^2 + (mu - target)^2))
  ppm <- 1e6 * (stats::pnorm(lsl, mu, sigma_within) +
                stats::pnorm(usl, mu, sigma_within, lower.tail = FALSE))
  data.frame(mean = mu, sigma_within = sigma_within, sigma_overall = s_o,
             Cp = cp, Cpk = cpk, Pp = pp, Ppk = ppk, Cpm = cpm,
             ppm_expected = ppm)
}

#' Batas kendali peta p (proporsi cacat)
#'
#' @param defectives Vektor jumlah unit cacat per lot.
#' @param n Ukuran sampel tiap lot (skalar atau vektor).
#' @return list: p (vektor proporsi), pbar, ucl, lcl (vektor, dipotong di 0),
#'   out_of_control (logikal).
#' @export
p_chart_limits <- function(defectives, n) {
  n    <- rep_len(n, length(defectives))
  p    <- defectives / n
  pbar <- sum(defectives) / sum(n)
  se   <- sqrt(pbar * (1 - pbar) / n)
  ucl  <- pbar + 3 * se
  lcl  <- pmax(0, pbar - 3 * se)
  list(p = p, pbar = pbar, ucl = ucl, lcl = lcl,
       out_of_control = p > ucl | p < lcl)
}

#' Grafik peta kendali (X-bar, R, atau p) dengan ggplot2
#'
#' @param stat Vektor statistik subgrup.
#' @param cl,ucl,lcl Garis tengah dan batas kendali (skalar atau vektor).
#' @param signal Vektor logikal titik yang memberi sinyal (ditandai merah).
#' @param title,ylab Judul dan label sumbu y.
#' @param phase_break Indeks subgrup terakhir fase I (garis pemisah, opsional).
#' @return Objek ggplot.
#' @export
plot_control_chart <- function(stat, cl, ucl, lcl, signal = NULL,
                               title = "Peta kendali", ylab = "Statistik",
                               phase_break = NULL) {
  m  <- length(stat)
  df <- data.frame(index = seq_len(m), stat = stat,
                   ucl = rep_len(ucl, m), lcl = rep_len(lcl, m),
                   signal = if (is.null(signal)) FALSE else signal)
  st <- pal_status()
  g <- ggplot2::ggplot(df, ggplot2::aes(index, stat)) +
    ggplot2::geom_step(ggplot2::aes(y = ucl), colour = st["critical"],
                       linetype = "dashed", linewidth = 0.6) +
    ggplot2::geom_step(ggplot2::aes(y = lcl), colour = st["critical"],
                       linetype = "dashed", linewidth = 0.6) +
    ggplot2::geom_hline(yintercept = cl, colour = st["neutral"], linewidth = 0.6) +
    ggplot2::geom_line(colour = pal_kategori()[1], linewidth = 0.7) +
    ggplot2::geom_point(ggplot2::aes(colour = signal, shape = signal), size = 2.6) +
    ggplot2::scale_colour_manual(values = c(`FALSE` = pal_kategori()[1],
                                            `TRUE` = unname(st["critical"])),
                                 labels = c("Terkendali", "Sinyal"), name = NULL) +
    ggplot2::scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 17),
                                labels = c("Terkendali", "Sinyal"), name = NULL) +
    ggplot2::labs(title = title, x = "Subgrup", y = ylab) +
    theme_portofolio()
  if (!is.null(phase_break)) {
    g <- g + ggplot2::geom_vline(xintercept = phase_break + 0.5,
                                 colour = st["neutral"], linetype = "dotted")
  }
  g
}
