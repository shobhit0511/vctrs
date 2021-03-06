
foobar <- function(x = list()) structure(x, class = "vctrs_foobar")

unrownames <- function(x) {
  row.names(x) <- NULL
  x
}

scoped_global_bindings <- function(..., .frame = caller_env()) {
  scoped_bindings(..., .env = global_env(), .frame = .frame)
}
scoped_proxy <- function(frame = caller_env()) {
  scoped_global_bindings(.frame = frame,
    vec_proxy.vctrs_proxy = function(x) proxy_deref(x),
    vec_restore.vctrs_proxy = function(x, to, ..., i) new_proxy(x),

    vec_type2.vctrs_proxy = function(x, y, ...) UseMethod("vec_type2.vctrs_proxy", y),
    vec_type2.vctrs_proxy.vctrs_proxy = function(x, y, ...) new_proxy(vec_type(proxy_deref(x))),

    vec_cast.vctrs_proxy = function(x, to) UseMethod("vec_cast.vctrs_proxy"),
    vec_cast.vctrs_proxy.default = function(x, to) stop_incompatible_cast(x, to),
    vec_cast.vctrs_proxy.vctrs_proxy = function(x, to) x
  )
}


new_proxy <- function(x) {
  structure(list(env(x = x)), class = "vctrs_proxy")
}
proxy_deref <- function(x) {
  x[[1]]$x
}
scoped_env_proxy <- function(frame = caller_env()) {
  scoped_global_bindings(.frame = frame,
    vec_proxy.vctrs_proxy = proxy_deref,
    vec_restore.vctrs_proxy = function(x, ...) new_proxy(x)
  )
}

scoped_no_stringsAsFactors <- function(frame = caller_env()) {
  scoped_options(.frame = frame, stringsAsFactors = FALSE)
}

tibble <- tibble::tibble

scoped_foobar_proxy <- function(frame = caller_env()) {
  scoped_global_bindings(.frame = frame, vec_proxy.vctrs_foobar = identity)
}

subclass <- function(x) {
  class(x) <- c("vctrs_foo", "vctrs_foobar", class(x))
  x
}
