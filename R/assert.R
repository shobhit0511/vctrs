#' Assert an argument has known prototype and/or size
#'
#' @description
#'
#' * `vec_is()` is a predicate that checks if its input conforms to a
#'   prototype and/or a size.
#'
#' * `vec_assert()` throws an error when the input doesn't conform.
#'
#' @section Error types:
#'
#' * If the prototype doesn't match, an error of class
#'   `"vctrs_error_assert_ptype"` is raised.
#'
#' * If the size doesn't match, an error of class
#' `"vctrs_error_assert_size"` is raised.
#'
#' Both errors inherit from `"vctrs_error_assert"`.
#'
#' @param x A vector argument to check.
#' @param ptype Prototype to compare against. If the prototype has a
#'   class, its [vec_type()] is compared to that of `x` with
#'   `identical()`. Otherwise, its [typeof()] is compared to that of
#'   `x` with `==`.
#' @param size Size to compare against
#' @param arg Name of argument being checked. This is used in error
#'   messages. The label of the expression passed as `x` is taken as
#'   default.
#'
#' @return `vec_is()` returns `TRUE` or `FALSE`. `vec_assert()` either
#'   throws a typed error (see section on error types) or returns `x`,
#'   invisibly.
#' @export
vec_assert <- function(x, ptype = NULL, size = NULL, arg = as_label(substitute(x))) {
  if (!vec_is_vector(x)) {
    stop_scalar_type(x, arg)
  }

  if (!is_null(ptype)) {
    ptype <- vec_type(ptype)
    x_type <- vec_type_finalise(vec_type(x))
    if (!is_same_type(x_type, ptype)) {
      msg <- vec_assert_type_explain(x_type, ptype, arg)
      abort(
        msg,
        .subclass = c("vctrs_error_assert_ptype", "vctrs_error_assert"),
        required = ptype,
        actual = x_type
      )
    }
  }

  if (!is_null(size)) {
    size <- vec_recycle(vec_cast(size, integer()), 1L)
    x_size <- vec_size(x)
    if (!identical(x_size, size)) {
      msg <- paste0("`", arg, "` must have size ", size, ", not size ", x_size, ".")
      abort(
        msg,
        .subclass = c("vctrs_error_assert_size", "vctrs_error_assert"),
        required = size,
        actual = x_size
      )
    }
  }

  invisible(x)
}
#' @rdname vec_assert
#' @export
vec_is <- function(x, ptype = NULL, size = NULL) {
  if (!vec_is_vector(x)) {
    return(FALSE)
  }

  if (!is_null(ptype)) {
    ptype <- vec_type(ptype)
    x_type <- vec_type_finalise(vec_type(x))
    if (!is_same_type(x_type, ptype)) {
      return(FALSE)
    }
  }

  if (!is_null(size)) {
    size <- vec_recycle(vec_cast(size, integer()), 1L)
    x_size <- vec_size(x)
    if (!identical(x_size, size)) {
      return(FALSE)
    }
  }

  TRUE
}

#' Is object a vector?
#' @noRd
#'
#' @description
#'
#' Returns `TRUE` if:
#'
#' * `x` is an atomic, whether it has a class or not.
#' * `x` is a bare list without class.
#' * `x` implements [vec_proxy()].
#'
#' S3 lists are thus treated as scalars unless they implement a proxy.
vec_is_vector <- function(x) {
  .Call(vctrs_is_vector, x)
}

is_same_type <- function(x, ptype) {
  if (is_partial(ptype)) {
    env <- environment()
    ptype <- tryCatch(
      vctrs_error_incompatible_type = function(...) return_from(env, FALSE),
      vec_type_common(x, ptype)
    )
  }

  identical(x, ptype)
}

vec_assert_type_explain <- function(x, type, arg) {
  arg <- str_backtick(arg)
  x <- vec_ptype_full(x)
  type <- vec_ptype_full(type)

  intro <- paste0(arg, " must be a vector with type")
  intro <- layout_type(intro, type)

  outro <- paste0("Instead, it has type")
  outro <- layout_type(outro, x)

  paste_line(
    !!!intro,
    if (str_is_multiline(intro)) "",
    !!!outro
  )
}

layout_type <- function(start, type) {
  if (str_is_multiline(type)) {
    paste_line(
      paste0(start, ":"),
      "",
      paste0("  ", indent(type, 2))
    )
  } else {
    paste0(start, " ", type, ".")
  }
}
