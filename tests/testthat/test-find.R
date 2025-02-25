context("test-find")

test_that("primitive functions are never supersets", {
  env <- pkgload::load_all(test_path("primitive"))
  on.exit(pkgload::unload("primitive"))

  expect_false(is_superset("sum", "primitive", "base"))
})

# moved functions ----------------------------------------------------

test_that(".Deprecated call contains function name", {
  f <- function() {
    .Deprecated("pkg::x")
  }

  expect_false(has_moved("pkg", "foo", f))
  expect_true(has_moved("pkg", "x", f))
})

test_that("returns FALSE for weird inputs", {
  expect_false(has_moved(obj = 20))
  expect_false(has_moved(obj = mean))

  f <- function() {}
  expect_false(has_moved(obj = mean))

  f <- function() {
    .Deprecated()
  }
  expect_false(has_moved(obj = mean))

  f <- function() {
    .Deprecated(1)
  }
  expect_false(has_moved(obj = mean))

})
