# Verifikasi penyempurnaan

Tanggal: 6 November 2026 (Asia/Jakarta).

Saya menjalankan pemeriksaan sintaks sumber, lint logika NA dengan lintr, seluruh 17 tes testthat, serta pipeline penuh run_all.R pada salinan terpisah menggunakan R 4.5.0. Seluruh tes lulus tanpa skip, termasuk pembanding batas kendali dengan qcc 2.7. Ketiga laporan berhasil dirender dan gambar hero berhasil dibangun.

Saya membandingkan kelima CSV hasil pembangkitan ulang dengan data final secara byte demi byte. Semua identik. Saya juga membandingkan seluruh 27 tabel HTML, terdiri atas 8 tabel survei, 11 tabel eksperimen, dan 8 tabel SPC. Isi teks tabel hasil eksekusi ulang cocok tepat dengan laporan final pada presisi yang ditampilkan. Nilai utama tetap: 400 responden, 30 run eksperimen, interaksi suhu × bahan p = 0,0077, serta Cpk 1,071.

Saya mempertahankan data, kode model, laporan HTML, dan gambar final identik terhadap main. Saya memperbaiki kalimat insight README mengenai CUSUM: Western Electric memberi sinyal pada subgrup 6, sedangkan CUSUM dan batas Shewhart 3σ sama-sama pada subgrup 8. Angka hasil tidak diubah.

Saya menambahkan English summary setelah badge serta tautan catatan verifikasi ini. Saya memeriksa 20 tautan relatif README, tanpa target berkas rusak. Saya memberi tag v1.0.0 pada commit terakhir main sebelum penyempurnaan. Riwayat repositori linear sehingga tidak ada commit merge dengan dua parent.

Versi acuan laporan final tetap didokumentasikan pada README. CI memakai R 4.5.0 karena pemasangan dependensi transitif terbaru pada R 4.3.3 gagal: Deriv memerlukan R ≥ 4.5. Pemeriksaan lokal menggunakan paket yang tersedia pada runtime verifikasi, bukan klaim pemulihan penuh renv.lock. Kesamaan kelima CSV dan seluruh tabel hasil dicatat terpisah dari variasi versi paket dan rendering gambar.
