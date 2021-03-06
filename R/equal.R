#' Test if two vectors are equal
#'
#' `vec_equal_na()` tests a special case: equality with `NA`. It is similar to
#' [is.na] but:
#' * Considers the missing element of a list to be `NULL`.
#' * Considered data frames and records to be missing if every component
#'   is missing.
#' This preserves the invariant that `vec_equal_na(x)` is equal to
#' `vec_equal(x, vec_na(x), na_equal = TRUE)`.
#'
#' @inheritParams vec_compare
#' @return A logical vector the same size as. Will only contain `NA`s if `na_equal` is `FALSE`.
#' @export
#' @examples
#' vec_equal(c(TRUE, FALSE, NA), FALSE)
#' vec_equal(c(TRUE, FALSE, NA), FALSE, na_equal = TRUE)
#' vec_equal_na(c(TRUE, FALSE, NA))
#'
#' vec_equal(5, 1:10)
#' vec_equal("d", letters[1:10])
#'
#' df <- data.frame(x = c(1, 1, 2, 1, NA), y = c(1, 2, 1, NA, NA))
#' vec_equal(df, data.frame(x = 1, y = 2))
#' vec_equal_na(df)
vec_equal <- function(x, y, na_equal = FALSE, .ptype = NULL) {
  args <- vec_recycle_common(x, y)
  args <- vec_cast_common(!!!args, .to = .ptype)
  .Call(
    vctrs_equal,
    vec_proxy(args[[1]]),
    vec_proxy(args[[2]]),
    na_equal
  )
}

#' @export
#' @rdname vec_equal
vec_equal_na <- function(x) {
  x <- vec_proxy(x)
  .Call(vctrs_equal_na, x)
}

obj_equal <- function(x, y, na_equal = TRUE) {
  .Call(vctrs_equal_object, x, y, na_equal)
}
