# Helper: menentukan root repositori agar tes bisa dijalankan dari root
# (Rscript -e 'testthat::test_dir("tests/testthat")') maupun dari folder tes.
root_dir <- normalizePath(
  if (file.exists("R/spc.R")) "." else if (file.exists("../../R/spc.R")) "../.." else "../.."
)
