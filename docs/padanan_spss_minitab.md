# Padanan Analisis: R ↔ SPSS ↔ Minitab

Tabel ini memetakan setiap analisis di repositori ke menu SPSS (versi 26+) dan Minitab (versi
19+) beserta keluaran yang sebanding. Tujuannya menunjukkan bahwa alur kerja yang sama dapat
dijalankan di ketiga perangkat lunak, dan hasilnya dapat saling diverifikasi.

Notasi: `›` berarti klik menu berikutnya; teks dalam [kurung siku] adalah kotak dialog/opsi.

## Modul 1: Survei kepuasan

| Analisis | R (repositori ini) | SPSS | Minitab | Keluaran yang sebanding |
|---|---|---|---|---|
| Deskriptif item | `dplyr::summarise`, `psych::describe` | *Analyze › Descriptive Statistics › Frequencies* [Statistics: mean, SD, median] | *Stat › Basic Statistics › Display Descriptive Statistics* | Mean, SD, median per item |
| Tabel demografi | `dplyr::count` | *Analyze › Descriptive Statistics › Frequencies* | *Stat › Tables › Tally Individual Variables* | Frekuensi dan persen |
| Korelasi item-total terkoreksi | `item_total_correlation()` | *Analyze › Scale › Reliability Analysis* [Statistics: Scale if item deleted] | *Stat › Multivariate › Item Analysis* | Kolom *Corrected Item-Total Correlation* (SPSS) = *Adjusted Item-Total Correlation* (Minitab) = `r_item_total` |
| Cronbach's alpha | `cronbach_alpha()`, `psych::alpha` | *Analyze › Scale › Reliability Analysis* [Model: Alpha] | *Stat › Multivariate › Item Analysis* | *Cronbach's Alpha* dan *Alpha if Item Deleted* = `alpha_if_deleted` |
| KMO dan Bartlett | `psych::KMO`, `psych::cortest.bartlett` | *Analyze › Dimension Reduction › Factor* [Descriptives: KMO and Bartlett's test of sphericity] | Tidak tersedia langsung; hitung via *Stat › Multivariate › Principal Components* (hanya korelasi) atau makro | *KMO Measure of Sampling Adequacy*, *Bartlett's Test* χ², df, Sig. |
| Jumlah faktor (parallel analysis) | `psych::fa.parallel` | Tidak bawaan; gunakan syntax/makro O'Connor (2000) | Tidak bawaan; gunakan scree plot di *Factor Analysis › Graphs* | Perbandingan eigenvalue data vs acak |
| Analisis faktor eksploratori | `psych::fa(fm="minres", rotate="oblimin")` | *Analyze › Dimension Reduction › Factor* [Extraction: Principal axis factoring / ULS; Rotation: Direct Oblimin; Options: sorted by size, suppress < 0.30] | *Stat › Multivariate › Factor Analysis* [Method: Maximum likelihood; Rotation: Varimax/Equimax/Quartimax, Minitab tidak menyediakan oblimin, sehingga hasil hanya sebanding kualitatif] | *Pattern Matrix* (SPSS) ≈ `efa$loadings`; *Factor Correlation Matrix* ≈ `efa$Phi`; komunalitas |
| Skor dimensi | `dimension_scores()` (rata-rata item) | *Transform › Compute Variable* [MEAN(item1, …)] | *Calc › Row Statistics* [Mean] | Variabel baru skor 1–5 |
| Regresi logistik ordinal | `MASS::polr(method="logistic")` | *Analyze › Regression › Ordinal* [Link: Logit; Output: Parameter estimates, Test of parallel lines] | *Stat › Regression › Ordinal Logistic Regression* | Koefisien (*Estimate*), Wald/Z, p; odds ratio = exp(B) (SPSS tidak menampilkan OR otomatis; Minitab menampilkannya langsung) |
| Uji proportional odds | Perbandingan logit biner per titik potong | *Test of Parallel Lines* (bawaan di dialog Ordinal) | Tidak tersedia langsung | SPSS memberi uji formal χ²; pendekatan di R bersifat informal |
| Pseudo-R² | McFadden manual | *Pseudo R-Square* (Cox & Snell, Nagelkerke, McFadden) | *Goodness-of-Fit* dan *Measures of Association* | Nilai McFadden identik |

## Modul 2: Desain eksperimen faktorial

| Analisis | R (repositori ini) | SPSS | Minitab | Keluaran yang sebanding |
|---|---|---|---|---|
| Membuat rancangan | `expand.grid` + `sample` | Tidak ada perancang DOE bawaan; susun manual | *Stat › DOE › Factorial › Create Factorial Design* [General full factorial; 3 dan 2 level; 5 replikasi; randomize runs] | Lembar rancangan dengan *RunOrder* |
| Deskriptif per sel | `group_by + summarise` | *Analyze › Compare Means › Means* [Layer: temperature, material] | *Stat › Basic Statistics › Display Descriptive Statistics* [By variables] | n, mean, SD per sel |
| Boxplot | `ggplot2::geom_boxplot` | *Graphs › Chart Builder › Boxplot* [Clustered] | *Graph › Boxplot › With Groups* | - |
| Interaction plot | `ggplot2::geom_line` pada rata-rata sel | *Analyze › GLM › Univariate › Plots* [Horizontal: temperature; Separate lines: material] | *Stat › ANOVA › Interaction Plot* atau *Stat › DOE › Factorial › Factorial Plots* | Profile plot / interaction plot |
| ANOVA dua arah + interaksi | `lm` + `anova`; `car::Anova(type=2)` | *Analyze › General Linear Model › Univariate* [Fixed factors; Model: Full factorial; Options: Descriptive statistics, Estimates of effect size, Homogeneity tests] | *Stat › ANOVA › General Linear Model › Fit General Linear Model* [Model: termasuk interaksi] | *Tests of Between-Subjects Effects* (SS Tipe III) = tabel ANOVA (identik pada desain seimbang) |
| Eta-squared parsial | Manual SS_efek/(SS_efek+SS_galat) | Kolom *Partial Eta Squared* (centang *Estimates of effect size*) | Tidak tersedia langsung; hitung dari *Adj SS* | Nilai identik |
| Shapiro-Wilk residual | `shapiro.test(residuals(fit))` | Simpan residual [Save: Unstandardized] lalu *Analyze › Descriptive Statistics › Explore* [Plots: Normality plots with tests] | Simpan residual [Storage] lalu *Stat › Basic Statistics › Normality Test* (Anderson-Darling / Ryan-Joiner; Shapiro-Wilk tidak tersedia, Ryan-Joiner mirip) | W dan p |
| Uji Levene | `car::leveneTest` (center = median) | *Homogeneity tests* di dialog Univariate (SPSS 26+ menyediakan versi mean dan median) | *Stat › ANOVA › Test for Equal Variances* [Levene's test] | F dan p (Minitab dan car default ke median) |
| Tukey HSD | `TukeyHSD(aov)` | *Post Hoc* [Tukey] untuk efek utama; untuk sel gunakan *EMMEANS /COMPARE ADJ(TUKEY)* via syntax | *Comparisons* [Tukey; pilih term termasuk interaksi] | Selisih, IK simultan 95%, p terkoreksi; *Grouping Information* (Minitab) |
| Plot diagnostik | ggplot residual vs fitted, Q-Q, vs run order | *Plots › Residual plots* | *Graphs › Four in one* | Sama |
| Kruskal-Wallis | `kruskal.test` | *Analyze › Nonparametric Tests › Legacy Dialogs › K Independent Samples* | *Stat › Nonparametrics › Kruskal-Wallis* | H, df, p |
| Mann-Whitney / Wilcoxon | `wilcox.test` | *Legacy Dialogs › 2 Independent Samples* [Mann-Whitney U] | *Stat › Nonparametrics › Mann-Whitney* | U (SPSS) vs W (R, Minitab), p identik |

## Modul 3: Statistical Process Control

| Analisis | R (repositori ini) | SPSS | Minitab | Keluaran yang sebanding |
|---|---|---|---|---|
| Peta X-bar dan R | `xbar_r_limits()`, `qcc::qcc(type="xbar"/"R")` | *Analyze › Quality Control › Control Charts › X-Bar, R, s* [Cases are subgroups / units; Charts: X-bar using range] | *Stat › Control Charts › Variables Charts for Subgroups › Xbar-R* [Subgroup size 5; Xbar-R Options › Estimate: Rbar] | CL, UCL, LCL identik (konstanta A2, D3, D4 sama) |
| Aturan Western Electric | `western_electric()` | *Statistics › Control rules* [pilih aturan] | *Xbar-R Options › Tests* [Tests 1–4 = WE rules 1–4] | Titik berlabel nomor tes |
| Sigma within | R-bar/d2 | Ditampilkan di *Process capability* | *Capability Analysis* [Estimate: Rbar] | *StDev (Within)* |
| Analisis kapabilitas | `capability_indices()`, `qcc::process.capability` | *Control Charts › Statistics* [Capability sigma: Rbar/d2; Process Capability Indices: Cp, CpK] | *Stat › Quality Tools › Capability Analysis › Normal* [LSL, USL, Target] | Cp, Cpk (within), Pp, Ppk (overall), Cpm, *PPM Expected* |
| Histogram + spesifikasi | ggplot + `geom_vline` | *Graphs › Histogram* + garis referensi | Bagian dari laporan Capability Analysis | - |
| Peta p | `p_chart_limits()`, `qcc::qcc(type="p")` | *Control Charts › p, np* [Subgroups: lot; Sample size variable] | *Stat › Control Charts › Attributes Charts › P* | p-bar, UCL/LCL per lot |
| Fase II dengan batas beku | Batas fase I diterapkan ke data baru | *Options* [Specify historical mean and sigma] | *Xbar-R Options › Parameters* [Historical mean, Historical standard deviation] | Titik di luar batas historis |
| CUSUM | `qcc::cusum(decision.interval=5, se.shift=1)` | Tidak tersedia | *Stat › Control Charts › Time-Weighted Charts › CUSUM* [h = 5, k = 0,5] | Statistik CUSUM atas/bawah, titik melewati h |

## Catatan perbedaan antar perangkat lunak

- **Jumlah kuadrat ANOVA**: SPSS memakai Tipe III secara default, `anova()` R memakai Tipe I.
  Pada rancangan seimbang (seperti modul 2) hasilnya identik; pada data tidak seimbang gunakan
  `car::Anova(type = 3)` dengan kontras `contr.sum` agar sebanding dengan SPSS.
- **Rotasi faktor**: Minitab tidak menyediakan rotasi oblik; untuk perbandingan langsung gunakan
  varimax di ketiga perangkat lunak.
- **Uji normalitas**: Minitab tidak menyediakan Shapiro-Wilk; Ryan-Joiner setara secara konsep.
- **Estimasi sigma SPC**: pastikan ketiganya memakai estimator yang sama (R-bar/d2). Minitab
  secara default memakai *pooled standard deviation* untuk Xbar-S dan R-bar untuk Xbar-R.
- **Konstanta d2**: `qcc` memakai nilai d2 dengan presisi penuh, sedangkan tabel Montgomery
  memakai 3 desimal; selisih batas kendali yang muncul berada di orde 10⁻⁴.
