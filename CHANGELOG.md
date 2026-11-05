# Changelog

Semua perubahan penting pada proyek ini dicatat di berkas ini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/) dan proyek ini
menganut [Semantic Versioning](https://semver.org/lang/id/).

## [Unreleased]

## [1.0.0] - 2025-11-05

### Added
- Pembangkit data simulasi deterministik (`R/simulate_data.R`, `set.seed(2024)`) untuk
  survei SERVQUAL, eksperimen faktorial 3 × 2, dan proses produksi (fase I, fase II, atribut).
- Modul 1: analisis survei kepuasan — deskriptif, validitas item, Cronbach's alpha, KMO dan
  Bartlett, EFA (`psych::fa`), regresi logistik ordinal (`MASS::polr`) dengan odds ratio.
- Modul 2: desain eksperimen — ANOVA dua arah dengan interaksi, uji asumsi, Tukey HSD,
  eta-squared parsial, pembanding Kruskal-Wallis.
- Modul 3: SPC — peta X-bar/R fase I, aturan Western Electric, Cp/Cpk/Pp/Ppk, peta p,
  deteksi pergeseran fase II, CUSUM; verifikasi silang terhadap paket `qcc`.
- Fungsi reusable berdokumentasi roxygen: `survey_utils.R`, `spc.R`, `plot_theme.R`.
- 17 tes unit `testthat` untuk alpha, konstanta SPC, batas kendali, Cpk, peta p, aturan
  Western Electric, dan dimensi data simulasi.
- Dokumentasi: `docs/padanan_spss_minitab.md`, `docs/metodologi.md`, `docs/kamus_data.md`.
- `run_all.R` untuk reproduksi satu perintah; `renv.lock`, `DESCRIPTION`, `requirements.R`.
- CI GitHub Actions (tes unit dan render laporan).
