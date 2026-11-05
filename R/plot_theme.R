# =============================================================================
# plot_theme.R
# Tema dan palet warna seragam untuk seluruh grafik di repositori ini.
#
# Mengapa dibuat terpisah: ketiga modul analisis (survei, eksperimen, SPC)
# memakai puluhan grafik. Dengan satu tema dan satu palet, laporan terlihat
# konsisten dan warna kategori tetap aman untuk pembaca buta warna
# (urutan hue biru - oranye - aqua - kuning - magenta - hijau sudah
# divalidasi jarak warnanya untuk deuteranopia/protanopia).
# =============================================================================

#' Pastikan lokal UTF-8 agar simbol seperti ° dan × tergambar benar
#'
#' Pada server CI atau kontainer, lokal sering "C" sehingga perangkat grafis
#' menampilkan simbol non-ASCII sebagai "<U+00D7>". Fungsi ini mencoba beberapa
#' lokal UTF-8 yang umum dan diam-diam melewati bila tidak ada.
#'
#' @return Nama lokal yang aktif (invisible).
#' @export
pastikan_utf8 <- function() {
  if (grepl("UTF-8|utf8", Sys.getlocale("LC_CTYPE"), ignore.case = TRUE)) {
    return(invisible(Sys.getlocale("LC_CTYPE")))
  }
  for (loc in c("C.UTF-8", "en_US.UTF-8", "id_ID.UTF-8", "C.utf8", "en_US.utf8")) {
    ok <- suppressWarnings(tryCatch(Sys.setlocale("LC_CTYPE", loc), error = function(e) ""))
    if (nzchar(ok)) break
  }
  invisible(Sys.getlocale("LC_CTYPE"))
}

#' Palet warna kategori (urutan tetap, jangan diacak)
#'
#' Urutan hue dipertahankan karena jarak warna antar pasangan berdekatan sudah
#' diverifikasi aman untuk buta warna. Warna ke-n selalu dipakai untuk seri ke-n.
#'
#' @return Vektor karakter berisi kode heksadesimal warna.
#' @export
pal_kategori <- function() {
  c("#2a78d6", # biru
    "#eb6834", # oranye
    "#1baf7a", # aqua
    "#eda100", # kuning
    "#e87ba4", # magenta
    "#008300") # hijau
}

#' Palet warna status (untuk titik di luar kendali, batas spesifikasi, dll.)
#'
#' Warna status dipisahkan dari warna seri agar "merah" selalu berarti
#' "bermasalah", bukan "seri ke-8".
#'
#' @return Vektor karakter bernama: good, warning, critical, neutral.
#' @export
pal_status <- function() {
  c(good = "#0ca30c", warning = "#fab219", critical = "#d03b3b",
    neutral = "#52514e")
}

#' Tema ggplot2 untuk portofolio
#'
#' Tema minimalis dengan grid tipis dan teks abu gelap supaya data (bukan
#' dekorasi) yang menonjol.
#'
#' @param base_size Ukuran huruf dasar.
#' @return Objek tema ggplot2.
#' @export
theme_portofolio <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background   = ggplot2::element_rect(fill = "#fcfcfb", colour = NA),
      panel.background  = ggplot2::element_rect(fill = "#fcfcfb", colour = NA),
      panel.grid.minor  = ggplot2::element_blank(),
      panel.grid.major  = ggplot2::element_line(colour = "#e6e5e1", linewidth = 0.4),
      plot.title        = ggplot2::element_text(face = "bold", colour = "#0b0b0b"),
      plot.subtitle     = ggplot2::element_text(colour = "#52514e"),
      axis.title        = ggplot2::element_text(colour = "#52514e"),
      axis.text         = ggplot2::element_text(colour = "#52514e"),
      legend.position   = "bottom",
      strip.text        = ggplot2::element_text(face = "bold", colour = "#0b0b0b")
    )
}

#' Simpan grafik ke folder assets dengan ukuran baku
#'
#' @param plot Objek ggplot.
#' @param nama Nama berkas tanpa ekstensi.
#' @param dir Folder tujuan (default "assets").
#' @param width,height Ukuran dalam inci.
#' @return Path berkas yang disimpan (invisible).
#' @export
simpan_grafik <- function(plot, nama, dir = "assets", width = 8, height = 5) {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  path <- file.path(dir, paste0(nama, ".png"))
  # type = "cairo" agar simbol non-ASCII (°, ×) tergambar benar di semua lokal
  ggplot2::ggsave(path, plot, width = width, height = height, dpi = 150,
                  bg = "#fcfcfb", device = grDevices::png, type = "cairo")
  invisible(path)
}
