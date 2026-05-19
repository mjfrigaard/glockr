#' Fetch the rlang package source tree for vignette demos
#'
#' Downloads a tagged release tarball of the rlang package from GitHub and
#' extracts it into a session-local tempdir, returning the path to the
#' extracted directory. Subsequent calls within the same R session reuse
#' the cached extraction. This is used by the package vignettes so they can
#' point `scc()` at a real R package without bundling rlang's source with
#' the installed glockr package.
#'
#' The vignette setup chunks typically use it like:
#'
#' ```
#' rlang_path <- glockr:::fetch_rlang_source()
#' if (is.na(rlang_path)) {
#'   knitr::opts_chunk$set(eval = FALSE)
#'   rlang_path <- ""
#' }
#' ```
#'
#' @param version Character. rlang release tag without the leading `"v"`.
#' @param host Character. URL probed by the internal connectivity check.
#' @param timeout Integer. Seconds to wait for the connectivity check
#'   before giving up.
#'
#' @return Character scalar — the absolute path of the extracted rlang
#'   source directory on success, or `NA_character_` when no network is
#'   available or the download / untar step fails.
#'
#' @keywords internal
fetch_rlang_source <- function(version = "1.1.6",
                               host    = "https://api.github.com",
                               timeout = 5L) {
  cache <- file.path(tempdir(), paste0("rlang-", version))
  if (dir.exists(cache)) return(cache)
  if (!has_internet(host, timeout)) return(NA_character_)

  url     <- sprintf(
    "https://github.com/r-lib/rlang/archive/refs/tags/v%s.tar.gz",
    version
  )
  tarball <- tempfile(fileext = ".tar.gz")
  ok <- tryCatch(
    {
      utils::download.file(url, tarball, mode = "wb", quiet = TRUE)
      utils::untar(tarball, exdir = tempdir())
      dir.exists(cache)
    },
    error   = function(e) FALSE,
    warning = function(w) FALSE
  )
  if (isTRUE(ok)) cache else NA_character_
}

# Cheap HEAD-based connectivity probe used by fetch_rlang_source().
has_internet <- function(host = "https://api.github.com", timeout = 5L) {
  tryCatch(
    {
      h      <- curlGetHeaders(host, redirect = TRUE, timeout = timeout)
      status <- attr(h, "status")
      is.numeric(status) && status >= 200L && status < 500L
    },
    error   = function(e) FALSE,
    warning = function(w) FALSE
  )
}
