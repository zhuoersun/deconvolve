library(deconvolve)
context("Bandwidth")

load("sym_error_test_result.RData")

set.seed(1)
n <- 50
sd_X <- 1
sd_U <- 0.2
W <- GenerateTestData(n, sd_X, sd_U, dist_type = "chi", error_type = "norm")

test_that("no error case gives expected result", {
	skip_on_cran()
	expect_equal(bandwidth(W), 0.166332, tolerance = 0.0000001)
})

set.seed(1)
test_that("homoscedastic errors case gives expected result", {
	skip_on_cran()
	expect_equal(bandwidth(W, errortype = "norm", sd_U = sd_U), 0.157268, tolerance = 0.0000001)
})

set.seed(1)
sd_U_vec <- 0.6 * sqrt(1 + (1:n) / n) * sqrt(0.5)
W <- GenerateTestData(n, sd_X, sd_U_vec, dist_type = "mix", error_type = "norm")
test_that("heteroscedastic error case gives expected result", {
	skip_on_cran()
	expect_equal(bandwidth(W, errortype = "norm", sd_U = sd_U_vec), 0.2312728, tolerance = 0.0000001)
})

set.seed(1)
data <- GenerateTestData(n, sd_X, sd_U, dist_type = "chi", error_type = "norm", replicates = TRUE)
test_that("replicates case gives expected result", {
	skip_on_cran()
	expect_equal(bandwidth(data$W1, data$W2), 0.1253582, tolerance = 0.0000001)
})

set.seed(1)
W <- GenerateTestData(n, sd_X, sd_U, dist_type = "mix", error_type = "norm")
test_that("CV case gives expected result", {
	skip_on_cran()
	expect_equal(bandwidth(W, errortype = "norm", sd_U = sd_U, algorithm = "CV"), 0.1387812, tolerance = 0.0000001)
})