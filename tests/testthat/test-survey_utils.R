# Tes unit untuk fungsi survei (R/survey_utils.R)
source(file.path(root_dir, "R", "survey_utils.R"))

test_that("cronbach_alpha cocok dengan perhitungan manual pada data kecil", {
  # Tiga item, empat responden; alpha dihitung tangan:
  # var item = 5/3, 11/12, 19/12 (jumlah 25/6) ; var total (4,7,9,12) = 34/3
  # alpha = 3/2 * (1 - (25/6)/(34/3)) = 1.5 * 43/68 = 0.94853
  x <- data.frame(a = c(1, 2, 3, 4), b = c(2, 2, 3, 4), c = c(1, 3, 3, 4))
  expect_equal(cronbach_alpha(x), 1.5 * (1 - (25 / 6) / (34 / 3)), tolerance = 1e-10)
  expect_equal(cronbach_alpha(x), 0.94853, tolerance = 1e-5)
})

test_that("cronbach_alpha = 1 untuk item yang identik sempurna", {
  x <- data.frame(a = 1:10, b = 1:10, c = 1:10)
  expect_equal(cronbach_alpha(x), 1)
})

test_that("cronbach_alpha menolak kurang dari dua item", {
  expect_error(cronbach_alpha(data.frame(a = 1:5)))
})

test_that("item_total_correlation mengembalikan struktur dan ambang yang benar", {
  set.seed(1)
  f <- rnorm(200)
  x <- data.frame(i1 = f + rnorm(200, sd = 0.5), i2 = f + rnorm(200, sd = 0.5),
                  i3 = f + rnorm(200, sd = 0.5), noise = rnorm(200))
  res <- item_total_correlation(x, threshold = 0.30)
  expect_named(res, c("item", "r_item_total", "alpha_if_deleted", "valid"))
  expect_equal(nrow(res), 4)
  expect_true(all(res$valid[1:3]))
  expect_false(res$valid[4])
  # Menghapus item 'noise' seharusnya menaikkan alpha
  expect_gt(res$alpha_if_deleted[4], cronbach_alpha(x))
})

test_that("map_dimension memetakan awalan nama item ke dimensi SERVQUAL", {
  expect_equal(map_dimension(c("tan_1", "rel_2", "res_3", "ass_4", "emp_1")),
               c("Tangibles", "Reliability", "Responsiveness", "Assurance", "Empathy"))
})

test_that("interpret_alpha memberi label sesuai ambang George & Mallery", {
  expect_equal(as.character(interpret_alpha(c(0.95, 0.85, 0.75, 0.65, 0.55, 0.3))),
               c("Sangat baik", "Baik", "Dapat diterima", "Dipertanyakan", "Buruk",
                 "Tidak dapat diterima"))
})
