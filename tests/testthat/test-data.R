context("test-data")

test_that("strips vector attributes apart from names", {
  x <- new_vctr(1:10, a = 1, b = 2)
  expect_equal(vec_data(x), 1:10)

  x <- new_vctr(c(x = 1, y = 2), a = 1, b = 2)
  expect_equal(vec_data(x), c(x = 1, y = 2))
})

test_that("strips attributes apart from dim and dimnames", {
  x <- new_vctr(1, a = 1, dim = c(1L, 1L), dimnames = list("foo", "bar"))
  expect <- matrix(1, nrow = 1L, ncol = 1L, dimnames = list("foo", "bar"))
  expect_equal(vec_data(x), expect)
})

test_that("vec_proxy() is a no-op with data vectors", {
  for (x in vectors) {
    expect_identical(vec_proxy(!!x), !!x)
  }

  x <- structure(1:3, foo = "bar")
  expect_identical(vec_proxy(!!x), !!x)
})

test_that("vec_proxy() transforms records to data frames", {
  for (x in records) {
    expect_identical(vec_proxy(x), new_data_frame(unclass(x)))
  }
})

test_that("vec_proxy() is a no-op with non vectors", {
  x <- foobar(list())
  expect_identical(vec_proxy(x), x)
})

test_that("can take the proxy of non-vector objects", {
  scoped_env_proxy()
  expect_identical(vec_proxy(new_proxy(1:3)), 1:3)
})
