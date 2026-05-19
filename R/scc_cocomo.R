#' Build a COCOMO summary tibble from scc's tabular output
#'
#' Runs `scc` a second time in tabular mode and extracts the COCOMO cost /
#' effort block, which `scc` only emits for its tabular formatter (not for
#' `--format json`). The three default-format lines are parsed into a
#' [tibble::tibble()] with columns `metric`, `project_type`, `value`.
#'
#' Called by [scc()] and [scc_by_file()] only when `cocomo = TRUE`.
#'
#' @param scc_bin Path to the `scc` executable.
#' @param path Character vector of paths passed to `scc`.
#' @param avg_wage,cocomo_project_type,eaf,overhead,currency_symbol,sloccount_format
#'   COCOMO-related arguments; see [scc()] for descriptions.
#' @param auto_print Logical. When `sloccount_format = TRUE` the upstream
#'   block has a different shape than the default 3-line summary; if
#'   `auto_print` is `TRUE` it is printed verbatim and the function returns
#'   `NULL` (since it cannot be coerced to the standard tibble).
#'
#' @return A 3-row [tibble::tibble()] with columns `metric`, `project_type`,
#'   `value`, or `NULL` for the sloccount-format / unparseable cases.
#' @keywords internal
scc_cocomo <- function(scc_bin,
                       path,
                       avg_wage            = NULL,
                       cocomo_project_type = NULL,
                       eaf                 = NULL,
                       overhead            = NULL,
                       currency_symbol     = NULL,
                       sloccount_format    = FALSE,
                       auto_print          = TRUE) {
  args <- character()
  if (!is.null(avg_wage))
    args <- c(args, "--avg-wage", as.character(avg_wage))
  if (!is.null(cocomo_project_type))
    args <- c(args, "--cocomo-project-type", cocomo_project_type)
  if (!is.null(eaf))
    args <- c(args, "--eaf", as.character(eaf))
  if (!is.null(overhead))
    args <- c(args, "--overhead", as.character(overhead))
  if (!is.null(currency_symbol))
    args <- c(args, "--currency-symbol", currency_symbol)
  if (isTRUE(sloccount_format))
    args <- c(args, "--sloccount-format")
  args <- c(args, path)

  res <- processx::run(scc_bin, args = args, error_on_status = FALSE)
  if (res$status != 0L) return(NULL)

  lines     <- strsplit(res$stdout, "\n", fixed = TRUE)[[1L]]
  total_idx <- head(which(grepl("^Total\\s+\\d", lines)), 1L)
  proc_idx  <- head(which(grepl("^Processed\\s", lines)), 1L)
  if (length(total_idx) == 0L || length(proc_idx) == 0L) return(NULL)
  if (proc_idx <= total_idx + 1L) return(NULL)

  block <- lines[(total_idx + 1L):(proc_idx - 1L)]
  if (length(block) > 0L && grepl("^─+$", block[1L]))
    block <- block[-1L]
  if (length(block) > 0L && grepl("^─+$", block[length(block)]))
    block <- block[-length(block)]
  if (length(block) == 0L) return(NULL)

  if (isTRUE(sloccount_format)) {
    if (isTRUE(auto_print)) {
      cat(block, sep = "\n")
      cat("\n")
    }
    return(NULL)
  }

  line_re <- "^(.+?)\\s+\\(([^)]+)\\)\\s+(.+)$"
  parsed  <- regmatches(block, regexec(line_re, block))
  rows    <- Filter(function(x) length(x) == 4L, parsed)
  if (length(rows) == 0L) return(NULL)

  tibble::tibble(
    metric       = vapply(rows, function(x) trimws(x[2L]), character(1L)),
    project_type = vapply(rows, function(x) trimws(x[3L]), character(1L)),
    value        = vapply(rows, function(x) trimws(x[4L]), character(1L))
  )
}
