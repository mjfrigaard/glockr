#' Count lines of code by language
#'
#' Runs `scc` on one or more paths and returns a per-language summary.
#'
#' @param path Character vector of file/directory paths to analyse.
#'   Defaults to the current working directory (`"."`).
#' @inheritParams build_args
#'
#' @return A [tibble::tibble()] with one row per language and columns:
#'   \describe{
#'     \item{language}{Programming language name.}
#'     \item{files}{Number of files (integer).}
#'     \item{lines}{Total line count (integer).}
#'     \item{code}{Lines of code (integer).}
#'     \item{comments}{Lines of comments (integer).}
#'     \item{blanks}{Blank lines (integer).}
#'     \item{complexity}{Total cyclomatic complexity score (integer).}
#'     \item{weighted_complexity}{Complexity weighted by lines of code (double,
#'       rounded to 2 decimal places).}
#'     \item{bytes}{File size in bytes (integer).}
#'     \item{uloc}{Unique lines of code; `0` unless `uloc` or `dryness` is
#'       `TRUE` (integer).}
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' scc()
#' scc("~/myproject", sort = "lines", no_complexity = TRUE)
#' scc(".", uloc = TRUE, exclude_dir = c("tests", "vignettes"))
#' scc(".", no_gen = TRUE, no_min = TRUE, no_duplicates = TRUE)
#' }
scc <- function(
    path                         = ".",
    sort                         = "code",
    no_complexity                = FALSE,
    uloc                         = FALSE,
    dryness                      = FALSE,
    character                    = FALSE,
    percent                      = FALSE,
    size_unit                    = NULL,
    verbose                      = FALSE,
    debug                        = FALSE,
    no_duplicates                = FALSE,
    binary                       = FALSE,
    gen                          = FALSE,
    no_gen                       = FALSE,
    min                          = FALSE,
    no_min                       = FALSE,
    min_gen                      = FALSE,
    no_min_gen                   = FALSE,
    min_gen_line_length          = NULL,
    generated_markers            = NULL,
    include_ext                  = NULL,
    exclude_ext                  = NULL,
    exclude_dir                  = NULL,
    exclude_file                 = NULL,
    not_match                    = NULL,
    count_as                     = NULL,
    remap_all                    = NULL,
    remap_unknown                = NULL,
    include_symlinks             = FALSE,
    no_large                     = FALSE,
    large_byte_count             = NULL,
    large_line_count             = NULL,
    count_ignore                 = FALSE,
    no_gitignore                 = FALSE,
    no_gitmodule                 = FALSE,
    no_ignore                    = FALSE,
    no_scc_ignore                = FALSE,
    no_hborder                   = FALSE,
    no_size                      = FALSE,
    no_cocomo                    = FALSE,
    avg_wage                     = NULL,
    cocomo_project_type          = NULL,
    eaf                          = NULL,
    overhead                     = NULL,
    currency_symbol              = NULL,
    sloccount_format             = FALSE,
    directory_walker_job_workers = NULL,
    file_gc_count                = NULL,
    file_list_queue_size         = NULL,
    file_process_job_workers     = NULL,
    file_summary_job_queue_size  = NULL) {

  scc_bin <- find_scc()
  args <- build_args(
    sort                         = sort,
    by_file                      = FALSE,
    no_complexity                = no_complexity,
    uloc                         = uloc,
    dryness                      = dryness,
    character                    = character,
    percent                      = percent,
    size_unit                    = size_unit,
    verbose                      = verbose,
    debug                        = debug,
    no_duplicates                = no_duplicates,
    binary                       = binary,
    gen                          = gen,
    no_gen                       = no_gen,
    min                          = min,
    no_min                       = no_min,
    min_gen                      = min_gen,
    no_min_gen                   = no_min_gen,
    min_gen_line_length          = min_gen_line_length,
    generated_markers            = generated_markers,
    include_ext                  = include_ext,
    exclude_ext                  = exclude_ext,
    exclude_dir                  = exclude_dir,
    exclude_file                 = exclude_file,
    not_match                    = not_match,
    count_as                     = count_as,
    remap_all                    = remap_all,
    remap_unknown                = remap_unknown,
    include_symlinks             = include_symlinks,
    no_large                     = no_large,
    large_byte_count             = large_byte_count,
    large_line_count             = large_line_count,
    count_ignore                 = count_ignore,
    no_gitignore                 = no_gitignore,
    no_gitmodule                 = no_gitmodule,
    no_ignore                    = no_ignore,
    no_scc_ignore                = no_scc_ignore,
    no_hborder                   = no_hborder,
    no_size                      = no_size,
    no_cocomo                    = no_cocomo,
    avg_wage                     = avg_wage,
    cocomo_project_type          = cocomo_project_type,
    eaf                          = eaf,
    overhead                     = overhead,
    currency_symbol              = currency_symbol,
    sloccount_format             = sloccount_format,
    directory_walker_job_workers = directory_walker_job_workers,
    file_gc_count                = file_gc_count,
    file_list_queue_size         = file_list_queue_size,
    file_process_job_workers     = file_process_job_workers,
    file_summary_job_queue_size  = file_summary_job_queue_size
  )
  args <- c(args, path)

  res <- processx::run(scc_bin, args = args, error_on_status = FALSE)
  if (res$status != 0L) stop("scc failed:\n", res$stderr, call. = FALSE)

  parse_scc_json(res$stdout, by_file = FALSE)
}
