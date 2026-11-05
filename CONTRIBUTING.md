# Panduan Kontribusi

Terima kasih telah berminat memperbaiki repositori ini. Beberapa aturan sederhana
agar kontribusi mudah ditinjau dan hasil tetap dapat direproduksi.

## Alur kerja

1. *Fork* repositori, lalu buat cabang dari `main`:
   `git checkout -b feat/nama-fitur` atau `fix/nama-perbaikan`.
2. Pasang dependensi: `Rscript requirements.R` (atau `renv::restore()`).
3. Lakukan perubahan. Jika mengubah fungsi di `R/`, tambahkan atau perbarui tes di
   `tests/testthat/`.
4. Jalankan seluruh alur: `Rscript run_all.R`. Semua tes harus lulus dan ketiga laporan
   harus berhasil dirender.
5. Jika angka hasil berubah, perbarui tabel **Hasil Utama** di `README.md` dengan angka
   dari output yang baru — jangan pernah menulis angka yang tidak berasal dari eksekusi.
6. Ajukan *pull request* dengan penjelasan singkat "apa" dan "mengapa".

## Gaya kode

- Bahasa dokumentasi dan komentar: Bahasa Indonesia baku. Nama variabel, fungsi, kolom,
  dan istilah teknis tetap dalam bahasa Inggris.
- Komentar menjelaskan **mengapa** suatu keputusan dibuat, bukan sekadar mengulang kode.
- Setiap fungsi di `R/` berdokumentasi roxygen (`#'`).
- Gunakan `<-` untuk penugasan, indentasi dua spasi, lebar baris maksimal 100 karakter.
- Grafik memakai `theme_portofolio()` dan `pal_kategori()` agar konsisten.

## Pesan commit

Ikuti [Conventional Commits](https://www.conventionalcommits.org/):
`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`, `ci:`.

## Melaporkan masalah

Buka *issue* dengan: versi R, versi paket (`sessionInfo()`), langkah untuk mereproduksi,
dan pesan galat lengkap.
