# Tes unit untuk pembangkit data simulasi (R/simulate_data.R)
source(file.path(root_dir, "R", "simulate_data.R"))

test_that("simulate_survey menghasilkan dimensi dan rentang nilai yang benar", {
  s <- simulate_survey()
  items <- grep("^(tan|rel|res|ass|emp)_[0-9]$", names(s), value = TRUE)
  expect_equal(nrow(s), 400)
  expect_length(items, 20)
  expect_true(all(as.matrix(s[, items]) %in% 1:5))
  expect_true(all(s$overall_satisfaction %in% 1:5))
  expect_equal(length(unique(s$respondent_id)), 400)
  expect_false(anyNA(s))
})

test_that("simulate_experiment menghasilkan rancangan 3 x 2 x 5 yang seimbang", {
  e <- simulate_experiment()
  expect_equal(nrow(e), 30)
  expect_equal(sort(unique(e$temperature)), c(150, 175, 200))
  expect_equal(sort(unique(e$material)), c("A", "B"))
  expect_true(all(table(e$temperature, e$material) == 5))
  expect_equal(sort(e$run_order), 1:30)   # urutan run adalah permutasi
})

test_that("simulate_spc menghasilkan 25 x 5 fase I, 15 x 5 fase II, dan 30 lot", {
  s <- simulate_spc()
  expect_equal(nrow(s$phase1), 125)
  expect_equal(nrow(s$phase2), 75)
  expect_equal(nrow(s$attribute), 30)
  expect_equal(max(s$phase1$subgroup), 25)
  expect_equal(max(s$phase2$subgroup), 15)
  expect_true(all(s$attribute$defectives <= s$attribute$sample_size))
})

test_that("simulasi deterministik: dua pemanggilan memberi hasil identik", {
  expect_identical(simulate_survey(), simulate_survey())
  expect_identical(simulate_experiment(), simulate_experiment())
  expect_identical(simulate_spc(), simulate_spc())
})

test_that("write_all_data menulis lima berkas CSV", {
  tmp <- tempfile("data")
  files <- write_all_data(tmp)
  expect_length(files, 5)
  expect_true(all(file.exists(files)))
  expect_equal(nrow(read.csv(files["survey_kepuasan"])), 400)
  unlink(tmp, recursive = TRUE)
})
