#' Data frame class
#'
#' A `data.frame` [data.frame()] is a list with "row.names" attribute. Each
#' element of the list must be named, and of the same length. These functions
#' help the base data.frame classes fit in to the vctrs type system by
#' providing constructors, coercion functions, and casting functions.
#'
#' @param x A named list of equal-length vectors. The lengths are not
#'   checked; it is responsibility of the caller to make sure they are
#'   equal.
#' @param n Number of rows. If `NULL`, will be computed from the length of
#'   the first element of `x`.
#' @param ...,class Additional arguments for creating subclasses.
#' @export
#' @keywords internal
#' @examples
#' new_data_frame(list(x = 1:10, y = 10:1))
new_data_frame <- function(x = list(), n = NULL, ..., class = character()) {
  stopifnot(is.list(x))
  n <- n %||% df_length(x)
  stopifnot(is.integer(n), length(n) == 1L)

  # names() should always be a character vector, but we can't enforce that
  # because as.data.frame() returns a data frame with NULL names to indicate
  # that outer names should be used
  if (length(x) == 0) {
    names(x) <- character()
  }

  structure(
    x,
    ...,
    class = c(class, "data.frame"),
    row.names = .set_row_names(n)
  )
}

# Light weight constructor used for tests - avoids having to repeatedly do
# stringsAsFactors = FALSE etc. Should not be used in internal code as is
# not a real helper as it lacks value checks.
data_frame <- function(...) {
  cols <- list(...)
  new_data_frame(cols)
}

#' @export
vec_ptype_full.data.frame <- function(x) {
  if (length(x) == 0) {
    return(paste0(class(x)[[1]], "<>"))
  } else if (length(x) == 1) {
    return(paste0(class(x)[[1]], "<", names(x), ":", vec_ptype_full(x[[1]]), ">"))
  }

  # Needs to handle recursion with indenting
  types <- map_chr(x, vec_ptype_full)
  needs_indent <- grepl("\n", types)
  types[needs_indent] <- map(types[needs_indent], function(x) indent(paste0("\n", x), 4))

  names <- paste0("  ", format(names(x)))

  paste0(
    class(x)[[1]], "<\n",
    paste0(names, ": ", types, collapse = "\n"),
    "\n>"
  )
}

#' @export
vec_ptype_abbr.data.frame <- function(x) {
  paste0("df", vec_ptype_shape(x))
}

#' @export
vec_proxy.data.frame <- function(x) {
  x
}

# Coercion ----------------------------------------------------------------

#' @rdname new_data_frame
#' @export vec_type2.data.frame
#' @method vec_type2 data.frame
#' @export
vec_type2.data.frame <- function(x, y, ...) UseMethod("vec_type2.data.frame", y)
#' @method vec_type2.data.frame data.frame
#' @export
vec_type2.data.frame.data.frame <- function(x, y, ..., x_arg = "", y_arg = "") {
  .Call(vctrs_type2_df_df, x, y, x_arg, y_arg)
}
#' @method vec_type2.data.frame default
#' @export
vec_type2.data.frame.default <- function(x, y, ..., x_arg = "", y_arg = "") {
  vec_default_type2(x, y, x_arg = x_arg, y_arg = y_arg)
}


# Cast --------------------------------------------------------------------

#' @rdname new_data_frame
#' @export vec_cast.data.frame
#' @method vec_cast data.frame
#' @export
vec_cast.data.frame <- function(x, to) {
  UseMethod("vec_cast.data.frame")
}
#' @export
#' @method vec_cast.data.frame data.frame
vec_cast.data.frame.data.frame <- function(x, to) {
  .Call(vctrs_df_as_dataframe, x, to)
}
#' @export
#' @method vec_cast.data.frame default
vec_cast.data.frame.default <- function(x, to) vec_default_cast(x, to)

#' @export
vec_restore.data.frame <- function(x, to, ..., i = NULL) {
  .Call(vctrs_df_restore, x, to, i)
}


# Helpers -----------------------------------------------------------------

df_length <- function(x) {
  # Possibly inefficient because it forces a realisation of row names vector?
  rn <- attr(x, "row.names", exact = TRUE)

  if (!is.null(rn)) {
    .row_names_info(x, 2L)
  } else if (vec_size(x) > 0) {
    vec_size(x[[1]])
  } else {
    0L
  }
}

df_lossy_cast <- function(out, x, to) {
  extra <- setdiff(names(x), names(to))

  maybe_lossy_cast(
    result = out,
    x = x,
    to = to,
    lossy = length(extra) > 0,
    locations = int(),
    details = inline_list("Dropped variables: ", extra, quote = "`"),
    .subclass = "vctrs_error_cast_lossy_dropped"
  )
}
