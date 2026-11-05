# Metodologi

Dokumen ini merangkum keputusan metodologis setiap modul beserta alasannya. Rincian
perhitungan dan keluaran lengkap ada di laporan HTML pada folder `reports/`.

## Prinsip umum

1. **Reproduksibilitas penuh**: data dibangkitkan secara deterministik (`set.seed(2024)`),
   seluruh alur dijalankan oleh `run_all.R`, dan versi paket dikunci (`renv.lock`,
   `requirements.R`).
2. **Verifikasi silang**: rumus yang ditulis manual (Cronbach's alpha, batas kendali, Cp/Cpk)
   dibandingkan terhadap implementasi paket mapan (`psych`, `qcc`) di dalam laporan dan diuji
   unit dengan `testthat`.
3. **Simulasi dengan struktur yang diketahui**: karena "jawaban benar" diketahui (misal 5 faktor,
   satu item lemah, pergeseran +0,75σ), pembaca bisa menilai apakah prosedur analisis bekerja.

## Modul 1 — Survei kepuasan (SERVQUAL)

| Tahap | Metode | Alasan pemilihan |
|---|---|---|
| Validitas item | Korelasi item-total terkoreksi, ambang 0,30 | Koreksi menghindari item berkorelasi dengan dirinya sendiri; ambang 0,30 lazim (Nunnally & Bernstein, 1994) |
| Reliabilitas | Cronbach's alpha per dimensi + alpha jika item dihapus | Standar industri untuk konsistensi internal; ambang 0,70 (George & Mallery) |
| Kelayakan EFA | KMO (≥ 0,60) dan uji Bartlett | Memastikan matriks korelasi cukup "berkelompok" untuk difaktorkan |
| Jumlah faktor | Parallel analysis (Horn, 1965) | Lebih akurat daripada aturan eigenvalue > 1 yang cenderung melebih-lebihkan |
| Ekstraksi & rotasi | Minimum residual, rotasi oblimin | Dimensi layanan secara teori berkorelasi, sehingga rotasi oblik lebih realistis daripada varimax |
| Model kepuasan | Regresi logistik ordinal (proportional odds, `MASS::polr`) | Respons ordinal 1–5; regresi linier mengabaikan sifat ordinal, regresi multinomial membuang urutan |
| Asumsi proportional odds | Perbandingan koefisien logit biner per titik potong | Pemeriksaan informal ala Harrell (2015) tanpa paket tambahan |

Catatan: EFA memakai korelasi Pearson pada data Likert 5 kategori. Korelasi polikorik lebih
tepat secara teori, tetapi dengan 5 kategori dan n = 400 perbedaannya kecil; ini dicatat sebagai
keterbatasan di README.

## Modul 2 — Desain eksperimen faktorial

| Tahap | Metode | Alasan pemilihan |
|---|---|---|
| Rancangan | Faktorial penuh 3 × 2, 5 replikasi, urutan run diacak | Memungkinkan estimasi interaksi; pengacakan melindungi dari variabel pengganggu yang berurutan waktu |
| Model | ANOVA dua arah dengan interaksi (`lm` + `anova`, verifikasi `car::Anova` Tipe II) | Desain seimbang membuat Tipe I/II/III identik |
| Asumsi | Shapiro-Wilk residual, Levene (median), plot residual | Levene berbasis median lebih tegar terhadap non-normalitas |
| Uji lanjut | Tukey HSD pada efek utama dan sel | Mengendalikan tingkat kesalahan keluarga pada semua perbandingan berpasangan |
| Ukuran efek | Eta-squared parsial | Standar pelaporan APA; memisahkan kontribusi tiap efek dari galat |
| Pembanding | Kruskal-Wallis dan Wilcoxon | Alternatif bila asumsi normalitas tidak terpenuhi; juga mengilustrasikan hilangnya daya uji bila interaksi diabaikan |

## Modul 3 — Statistical Process Control

| Tahap | Metode | Alasan pemilihan |
|---|---|---|
| Fase I | Peta R lalu X-bar, konstanta A2/D3/D4/d2 (Montgomery, 2013) | Peta R dibaca lebih dulu karena batas X-bar bergantung pada R-bar |
| Sinyal | Aturan Western Electric 1–4 | Meningkatkan kepekaan terhadap pergeseran kecil tanpa menambah peta |
| Kapabilitas | Cp, Cpk (σ within = R-bar/d2); Pp, Ppk (σ overall); Cpm | Membedakan potensi jangka pendek dan kinerja jangka panjang; Cpm memberi penalti deviasi dari target |
| Atribut | Peta p dengan batas 3σ binomial | Ukuran sampel tetap (200) sehingga batas konstan |
| Fase II | Batas fase I dibekukan; Western Electric; CUSUM (k = 0,5σ, h = 5σ) | Pergeseran 0,75σ terlalu kecil untuk aturan 3σ saja; CUSUM dirancang untuk pergeseran 0,5–1,5σ |

## Referensi

- Montgomery, D. C. (2013). *Introduction to Statistical Quality Control* (7th ed.). Wiley.
- Montgomery, D. C. (2017). *Design and Analysis of Experiments* (9th ed.). Wiley.
- Parasuraman, A., Zeithaml, V. A., & Berry, L. L. (1988). SERVQUAL: A multiple-item scale for
  measuring consumer perceptions of service quality. *Journal of Retailing*, 64(1), 12–40.
- Nunnally, J. C., & Bernstein, I. H. (1994). *Psychometric Theory* (3rd ed.). McGraw-Hill.
- Harrell, F. E. (2015). *Regression Modeling Strategies* (2nd ed.). Springer.
- Revelle, W. (2024). *psych: Procedures for Psychological, Psychometric, and Personality Research*. R package.
- Scrucca, L. (2004). qcc: An R package for quality control charting and statistical process control. *R News*, 4(1), 11–17.
