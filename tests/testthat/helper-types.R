
base_empty_types <- list(
  null = NULL,
  logical = lgl(),
  integer = int(),
  double = dbl(),
  complex = cpl(),
  character = chr(),
  raw = bytes(),
  list = list(),
  dataframe = data.frame()
)

proxied_empty_types <- list(
  double = new_hidden(),
  dataframe = tibble::tibble(),
  dataframe = structure(data.frame(), class = c("vctrs_foobar", "data.frame"))
)

empty_types <- c(
  base_empty_types,
  proxied_empty_types,
  # Non proxied type
  scalar = foobar(list()),
  scalar = function() NULL
)

atomics <- list(TRUE, 1L, 1.0, 1i, "foo", bytes(1))
vectors <- c(atomics, list(list()))
records <- list(
  df = data.frame(x = 1),
  rcrd = new_rcrd(list(x = 1)),
  posixlt = as.POSIXlt("2020-01-01")
)

tuple <- function(x = integer(), y = integer()) {
  fields <- vec_recycle_common(
    x = vec_cast(x, integer()),
    y = vec_cast(y, integer())
  )
  new_rcrd(fields, class = "tuple")
}

scoped_tuple_methods <- function(frame = caller_env()) {
  scoped_global_bindings(.frame = frame,
    format.tuple = function(x, ...) {
      paste0("(", field(x, "x"), ",", field(x, "y"), ")")
    },

    vec_type2.tuple = function(x, y, ...)  UseMethod("vec_type2.tuple", y),
    vec_type2.tuple.vctrs_unspecified = function(x, y, ...) tuple(),
    vec_type2.tuple.tuple = function(x, y, ...) tuple(),
    vec_type2.tuple.default = function(x, y, ..., x_arg = "", y_arg = "") {
      stop_incompatible_type(x, y, x_arg = x_arg, y_arg = y_arg)
    },

    vec_cast.tuple = function(x, to) UseMethod("vec_cast.tuple"),
    vec_cast.tuple.list = function(x, to) vec_list_cast(x, to),
    vec_cast.tuple.tuple = function(x, to) x
  )
}

c_na <- function(...) {
  x <- c(...)
  names(x)[names(x) == ""] <- NA_character_
  x
}
