# Kamus Data

Semua berkas berada di `data/raw/` dan dibangkitkan oleh `R/simulate_data.R`
(`set.seed(2024)`). Data **bukan** data nyata; parameter pembangkitnya dijelaskan di
[`metodologi.md`](metodologi.md) dan di README.

## 1. `survey_kepuasan.csv`: 400 baris × 25 kolom

| Kolom | Tipe | Nilai | Keterangan |
|---|---|---|---|
| `respondent_id` | karakter | R001–R400 | Identitas responden |
| `gender` | karakter | Laki-laki, Perempuan | Jenis kelamin |
| `age_group` | karakter | 18-25, 26-35, 36-45, 46-55, >55 | Kelompok usia |
| `usage_freq` | karakter | Jarang, Bulanan, Mingguan, Harian | Frekuensi menggunakan layanan |
| `tan_1` … `tan_4` | integer | 1–5 | Item dimensi **Tangibles** (bukti fisik: fasilitas, peralatan, penampilan) |
| `rel_1` … `rel_4` | integer | 1–5 | Item dimensi **Reliability** (keandalan: janji ditepati, akurat) |
| `res_1` … `res_4` | integer | 1–5 | Item dimensi **Responsiveness** (daya tanggap: cepat, bersedia membantu) |
| `ass_1` … `ass_4` | integer | 1–5 | Item dimensi **Assurance** (jaminan: kompetensi, kesopanan, rasa aman) |
| `emp_1` … `emp_4` | integer | 1–5 | Item dimensi **Empathy** (empati: perhatian individual) |
| `overall_satisfaction` | integer | 1–5 | Kepuasan keseluruhan, ordinal (1 = sangat tidak puas, 5 = sangat puas) |

Skala Likert: 1 = sangat tidak setuju, 2 = tidak setuju, 3 = netral, 4 = setuju, 5 = sangat setuju.
Item `emp_4` sengaja disimulasikan dengan loading rendah (0,35) sebagai item bermasalah.

## 2. `eksperimen_faktorial.csv`: 30 baris × 5 kolom

| Kolom | Tipe | Nilai | Keterangan |
|---|---|---|---|
| `run_order` | integer | 1–30 | Urutan pelaksanaan run (diacak sepenuhnya) |
| `temperature` | integer | 150, 175, 200 | Suhu perlakuan panas (°C), faktor A, 3 level |
| `material` | karakter | A, B | Jenis bahan, faktor B, 2 level |
| `replicate` | integer | 1–5 | Nomor replikasi dalam sel |
| `tensile_strength` | numerik | ≈ 36–52 | Respons: kekuatan tarik (MPa) |

Rata-rata sel yang ditanam (MPa): 150/A = 40, 175/A = 46, 200/A = 48, 150/B = 47, 175/B = 50,
200/B = 49; galat N(0, 2,2²).

## 3. `spc_fase1.csv`: 125 baris × 4 kolom; `spc_fase2.csv` - 75 baris × 4 kolom

| Kolom | Tipe | Nilai | Keterangan |
|---|---|---|---|
| `phase` | karakter | I, II | Fase pengendalian |
| `subgroup` | integer | 1–25 (fase I), 1–15 (fase II) | Nomor subgrup (satu subgrup per jam) |
| `obs` | integer | 1–5 | Nomor pengukuran dalam subgrup |
| `diameter` | numerik | ≈ 49,4–50,7 | Diameter poros (mm); target 50,00, spesifikasi 49,35–50,65 |

Fase I: N(50,00; 0,20²) stabil. Fase II: subgrup 1–5 N(50,00; 0,20²), subgrup 6–15
N(50,15; 0,20²), pergeseran +0,75σ.

## 4. `spc_atribut.csv`: 30 baris × 3 kolom

| Kolom | Tipe | Nilai | Keterangan |
|---|---|---|---|
| `lot` | integer | 1–30 | Nomor lot produksi |
| `sample_size` | integer | 200 | Jumlah unit yang diperiksa per lot |
| `defectives` | integer | 0–200 | Jumlah unit cacat; Binomial(200, p), p = 0,03 kecuali lot 18–19 (p = 0,09) |

## Data turunan

Folder `data/processed/` disediakan untuk hasil antara (misal skor dimensi) bila diperlukan;
saat ini semua turunan dihitung langsung di dalam laporan sehingga folder ini kosong.
