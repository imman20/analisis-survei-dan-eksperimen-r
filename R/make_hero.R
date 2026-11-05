# =============================================================================
# make_hero.R
# Membuat gambar "hero" untuk README: panel tiga grafik kunci, satu dari
# tiap modul (alpha per dimensi, interaction plot, peta X-bar fase II).
#
# Mengapa dibangun ulang dari data dan bukan menggabungkan PNG: supaya ukuran
# huruf dan tema konsisten dalam satu kanvas, tanpa paket tambahan
# (hanya grid bawaan R).
# =============================================================================

#' Buat gambar hero README
#'
#' @param out Path PNG keluaran.
#' @return Path berkas (invisible).
make_hero <- function(out = "assets/hero.png") {
  source("R/plot_theme.R"); source("R/survey_utils.R"); source("R/spc.R")
  pastikan_utf8()
  library(ggplot2)

  # --- Panel 1: alpha per dimensi ------------------------------------------
  survey <- read.csv("data/raw/survey_kepuasan.csv")
  items  <- grep("^(tan|rel|res|ass|emp)_[0-9]$", names(survey), value = TRUE)
  dims   <- unique(map_dimension(items))
  alpha_df <- data.frame(
    dimensi = dims,
    alpha   = sapply(dims, function(d) cronbach_alpha(survey[, items[map_dimension(items) == d]]))
  )
  p1 <- ggplot(alpha_df, aes(alpha, reorder(dimensi, alpha))) +
    geom_col(fill = pal_kategori()[1], width = 0.6) +
    geom_vline(xintercept = 0.7, linetype = "dashed", colour = pal_status()["critical"]) +
    geom_text(aes(label = sprintf("%.2f", alpha)), hjust = -0.15, size = 3.2, colour = "#52514e") +
    scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
    labs(title = "Survei: Cronbach's alpha", x = "Alpha", y = NULL) +
    theme_portofolio(base_size = 10)

  # --- Panel 2: interaction plot --------------------------------------------
  ex <- read.csv("data/raw/eksperimen_faktorial.csv")
  # Escape \u dipakai (bukan karakter literal) agar simbol tetap benar walau
  # skrip di-source pada lokal non-UTF-8 (misal LANG=C di server CI)
  ex$temperature <- factor(ex$temperature,
                           labels = c("150°C", "175°C", "200°C"))
  ex$material    <- factor(ex$material, labels = c("Bahan A", "Bahan B"))
  cm <- aggregate(tensile_strength ~ temperature + material, ex, mean)
  p2 <- ggplot(cm, aes(temperature, tensile_strength, colour = material, group = material)) +
    geom_line(linewidth = 1) + geom_point(size = 2.6) +
    scale_colour_manual(values = pal_kategori()[1:2], name = NULL) +
    labs(title = "Eksperimen: interaksi suhu × bahan", x = NULL, y = "Kekuatan tarik (MPa)") +
    theme_portofolio(base_size = 10)

  # --- Panel 3: peta X-bar fase I + II --------------------------------------
  to_matrix <- function(df) {
    w <- reshape(df[, c("subgroup", "obs", "diameter")], idvar = "subgroup",
                 timevar = "obs", direction = "wide")
    as.matrix(w[order(w$subgroup), -1])
  }
  m1 <- to_matrix(read.csv("data/raw/spc_fase1.csv"))
  m2 <- to_matrix(read.csv("data/raw/spc_fase2.csv"))
  lim <- xbar_r_limits(m1)
  sx  <- lim$sigma_within / sqrt(lim$n)
  xb  <- c(lim$xbar, rowMeans(m2))
  sig <- c(western_electric(lim$xbar, lim$xbar_cl, sx)$any_signal,
           western_electric(rowMeans(m2), lim$xbar_cl, sx)$any_signal)
  p3 <- plot_control_chart(xb, lim$xbar_cl, lim$xbar_ucl, lim$xbar_lcl, sig,
                           title = "SPC: peta X-bar fase I dan II", ylab = "Diameter (mm)",
                           phase_break = nrow(m1)) + theme_portofolio(base_size = 10)

  # --- Susun tiga panel dengan grid -----------------------------------------
  dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
  grDevices::png(out, width = 1800, height = 560, res = 140, bg = "#fcfcfb", type = "cairo")
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(1, 3, widths = c(1, 1, 1.25))))
  print(p1, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1))
  print(p2, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 2))
  print(p3, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 3))
  grDevices::dev.off()
  invisible(out)
}
