# Tes unit untuk fungsi SPC (R/spc.R)
source(file.path(root_dir, "R", "plot_theme.R"))
source(file.path(root_dir, "R", "spc.R"))

test_that("konstanta peta kendali n = 5 sesuai tabel Montgomery", {
  k <- spc_constants(5)
  expect_equal(k$A2, 0.577)
  expect_equal(k$D3, 0)
  expect_equal(k$D4, 2.114)
  expect_equal(k$d2, 2.326)
  expect_equal(k$c4, 0.9400)
  expect_error(spc_constants(11))
})

test_that("batas X-bar dan R dihitung dengan rumus baku", {
  # Matriks kecil yang hasilnya bisa dihitung tangan: 4 subgrup x 2 pengukuran
  m <- matrix(c(10, 12, 11, 13, 9, 11, 10, 10), ncol = 2, byrow = TRUE)
  lim <- xbar_r_limits(m)
  # xbar = 11, 12, 10, 10 -> grand mean 10.75 ; R = 2, 2, 2, 0 -> Rbar 1.5
  expect_equal(lim$xbar_cl, 10.75)
  expect_equal(lim$r_cl, 1.5)
  expect_equal(lim$xbar_ucl, 10.75 + 1.880 * 1.5)
  expect_equal(lim$xbar_lcl, 10.75 - 1.880 * 1.5)
  expect_equal(lim$r_ucl, 3.267 * 1.5)
  expect_equal(lim$r_lcl, 0)
  expect_equal(lim$sigma_within, 1.5 / 1.128)
})

test_that("batas X-bar/R manual cocok dengan qcc pada data acak", {
  skip_if_not_installed("qcc")
  set.seed(42)
  m <- matrix(rnorm(125, 50, 0.2), ncol = 5)
  lim <- xbar_r_limits(m)
  q <- qcc::qcc(m, type = "xbar", plot = FALSE)
  expect_equal(lim$xbar_cl, q$center, tolerance = 1e-10)
  expect_equal(lim$xbar_ucl, q$limits[1, "UCL"], tolerance = 1e-3)
  expect_equal(lim$xbar_lcl, q$limits[1, "LCL"], tolerance = 1e-3)
})

test_that("Cp dan Cpk benar pada kasus yang diketahui", {
  # Proses terpusat: mean 50, sigma 1, spesifikasi 47-53 -> Cp = Cpk = 1
  x <- c(49, 50, 51, 50, 50, 49, 51, 50)        # mean tepat 50
  cap <- capability_indices(x, lsl = 47, usl = 53, sigma_within = 1)
  expect_equal(cap$Cp, 1)
  expect_equal(cap$Cpk, 1)
  # Proses bergeser: mean 51 -> Cpk = min((53-51)/3, (51-47)/3) = 2/3, Cp tetap 1
  cap2 <- capability_indices(x + 1, lsl = 47, usl = 53, sigma_within = 1)
  expect_equal(cap2$Cp, 1)
  expect_equal(cap2$Cpk, 2 / 3)
  # ppm untuk proses terpusat dengan Cp = 1 adalah 2 * pnorm(-3) * 1e6 = 2699.8
  expect_equal(cap$ppm_expected, 2 * pnorm(-3) * 1e6)
  # Cpm sama dengan Cp bila mean = target
  cap3 <- capability_indices(x, 47, 53, 1, target = 50)
  expect_equal(cap3$Cpm, 1)
})

test_that("batas peta p mengikuti pbar +/- 3 sqrt(pbar(1-pbar)/n) dan dipotong di nol", {
  pl <- p_chart_limits(defectives = c(2, 4, 3, 1, 10), n = 100)
  expect_equal(pl$pbar, 20 / 500)
  se <- sqrt(0.04 * 0.96 / 100)
  expect_equal(pl$ucl[1], 0.04 + 3 * se)
  expect_equal(pl$lcl[1], 0)             # 0.04 - 3*se negatif -> dipotong 0
  expect_true(pl$out_of_control[5])      # p = 0.10 > UCL 0.0988
  expect_false(any(pl$out_of_control[1:4]))
})

test_that("aturan Western Electric mendeteksi pola yang diketahui", {
  cl <- 0; s <- 1
  # Aturan 1: satu titik di luar 3 sigma
  we <- western_electric(c(0, 0.5, 3.5, 0), cl, s)
  expect_true(we$rule1[3]); expect_false(any(we$rule1[-3]))
  # Aturan 2: 2 dari 3 titik berurutan di atas 2 sigma
  we <- western_electric(c(2.5, 0, 2.5), cl, s)
  expect_true(we$rule2[3])
  # Aturan 4: 8 titik berurutan di sisi yang sama (tidak ada aturan lain yang memicu)
  we <- western_electric(c(rep(0.2, 8), -0.1), cl, s)
  expect_true(we$rule4[8]); expect_false(we$rule4[9])
  # Proses acak terkendali seharusnya jarang memberi sinyal
  set.seed(7)
  we <- western_electric(rnorm(25), cl, s)
  expect_lte(sum(we$rule1), 1)
})
