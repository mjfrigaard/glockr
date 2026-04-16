# Helper: call build_args with all defaults except the one(s) under test
default_args <- function(...) {
  args <- list(
    sort                         = "code",
    by_file                      = FALSE,
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
    file_summary_job_queue_size  = NULL
  )
  args[names(list(...))] <- list(...)
  do.call(glockr:::build_args, args)
}

# --- %||% -------------------------------------------------------------------

test_that("%||% returns left value when it is not NULL", {
  expect_equal("a" %||% "b", "a")
  expect_equal(0L  %||% 99L, 0L)
  expect_equal(FALSE %||% TRUE, FALSE)
})

test_that("%||% returns right value when left is NULL", {
  expect_equal(NULL %||% "b",   "b")
  expect_equal(NULL %||% 42L,   42L)
  expect_equal(NULL %||% FALSE, FALSE)
})

# --- defaults ---------------------------------------------------------------

test_that("build_args() always emits --format json", {
  args <- default_args()
  idx  <- which(args == "--format")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "json")
})

test_that("build_args() defaults to --sort code", {
  args <- default_args()
  idx  <- which(args == "--sort")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "code")
})

test_that("build_args() emits no optional flags by default", {
  args <- default_args()
  optional_flags <- c(
    "--by-file", "--no-complexity", "--uloc", "--dryness", "--character",
    "--percent", "--size-unit", "--verbose", "--debug",
    "--no-duplicates", "--binary", "--gen", "--no-gen",
    "--min", "--no-min", "--min-gen", "--no-min-gen",
    "--min-gen-line-length", "--generated-markers",
    "--include-ext", "--exclude-ext", "--exclude-dir", "--exclude-file",
    "--not-match", "--count-as", "--remap-all", "--remap-unknown",
    "--include-symlinks", "--no-large", "--large-byte-count", "--large-line-count",
    "--count-ignore",
    "--no-gitignore", "--no-gitmodule", "--no-ignore", "--no-scc-ignore",
    "--no-hborder", "--no-size",
    "--no-cocomo", "--avg-wage", "--cocomo-project-type", "--eaf", "--overhead",
    "--currency-symbol", "--sloccount-format",
    "--directory-walker-job-workers", "--file-gc-count",
    "--file-list-queue-size", "--file-process-job-workers",
    "--file-summary-job-queue-size"
  )
  expect_false(any(optional_flags %in% args))
})

# --- sort values ------------------------------------------------------------

test_that("build_args() accepts all valid sort values", {
  valid <- c("name", "files", "lines", "code", "comments", "blanks", "complexity")
  for (s in valid) {
    args <- default_args(sort = s)
    expect_equal(args[[which(args == "--sort") + 1L]], s,
                 label = paste("sort =", s))
  }
})

test_that("build_args() rejects an invalid sort value", {
  expect_error(default_args(sort = "bad"), "should be one of")
})

# --- core boolean flags -----------------------------------------------------

test_that("build_args() adds --by-file when by_file = TRUE", {
  expect_true("--by-file" %in% default_args(by_file = TRUE))
})

test_that("build_args() omits --by-file when by_file = FALSE", {
  expect_false("--by-file" %in% default_args(by_file = FALSE))
})

test_that("build_args() adds --no-complexity when no_complexity = TRUE", {
  expect_true("--no-complexity" %in% default_args(no_complexity = TRUE))
})

test_that("build_args() adds --uloc when uloc = TRUE", {
  expect_true("--uloc" %in% default_args(uloc = TRUE))
})

test_that("build_args() adds --dryness when dryness = TRUE", {
  expect_true("--dryness" %in% default_args(dryness = TRUE))
})

test_that("build_args() adds --character when character = TRUE", {
  expect_true("--character" %in% default_args(character = TRUE))
})

test_that("build_args() adds --percent when percent = TRUE", {
  expect_true("--percent" %in% default_args(percent = TRUE))
})

test_that("build_args() adds --verbose when verbose = TRUE", {
  expect_true("--verbose" %in% default_args(verbose = TRUE))
})

test_that("build_args() adds --debug when debug = TRUE", {
  expect_true("--debug" %in% default_args(debug = TRUE))
})

# --- detection boolean flags ------------------------------------------------

test_that("build_args() adds --no-duplicates when no_duplicates = TRUE", {
  expect_true("--no-duplicates" %in% default_args(no_duplicates = TRUE))
})

test_that("build_args() adds --binary when binary = TRUE", {
  expect_true("--binary" %in% default_args(binary = TRUE))
})

test_that("build_args() adds --gen when gen = TRUE", {
  expect_true("--gen" %in% default_args(gen = TRUE))
})

test_that("build_args() adds --no-gen when no_gen = TRUE", {
  expect_true("--no-gen" %in% default_args(no_gen = TRUE))
})

test_that("build_args() adds --min when min = TRUE", {
  expect_true("--min" %in% default_args(min = TRUE))
})

test_that("build_args() adds --no-min when no_min = TRUE", {
  expect_true("--no-min" %in% default_args(no_min = TRUE))
})

test_that("build_args() adds --min-gen when min_gen = TRUE", {
  expect_true("--min-gen" %in% default_args(min_gen = TRUE))
})

test_that("build_args() adds --no-min-gen when no_min_gen = TRUE", {
  expect_true("--no-min-gen" %in% default_args(no_min_gen = TRUE))
})

# --- detection integer / string flags ---------------------------------------

test_that("build_args() adds --min-gen-line-length with integer value", {
  args <- default_args(min_gen_line_length = 100L)
  idx  <- which(args == "--min-gen-line-length")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "100")
})

test_that("build_args() collapses generated_markers with a comma", {
  args <- default_args(generated_markers = c("do not edit", "<auto-generated />"))
  idx  <- which(args == "--generated-markers")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "do not edit,<auto-generated />")
})

# --- extension / path filters -----------------------------------------------

test_that("build_args() adds --include-ext with a single extension", {
  args <- default_args(include_ext = "R")
  idx  <- which(args == "--include-ext")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "R")
})

test_that("build_args() collapses multiple include extensions with a comma", {
  args <- default_args(include_ext = c("R", "py", "js"))
  expect_equal(args[[which(args == "--include-ext") + 1L]], "R,py,js")
})

test_that("build_args() adds --exclude-ext with a single extension", {
  args <- default_args(exclude_ext = "json")
  idx  <- which(args == "--exclude-ext")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "json")
})

test_that("build_args() collapses multiple exclude extensions with a comma", {
  args <- default_args(exclude_ext = c("js", "ts"))
  expect_equal(args[[which(args == "--exclude-ext") + 1L]], "js,ts")
})

test_that("build_args() adds --exclude-dir with a single directory", {
  args <- default_args(exclude_dir = "tests")
  idx  <- which(args == "--exclude-dir")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "tests")
})

test_that("build_args() collapses multiple exclude dirs with a comma", {
  args <- default_args(exclude_dir = c("tests", "vignettes"))
  expect_equal(args[[which(args == "--exclude-dir") + 1L]], "tests,vignettes")
})

test_that("build_args() adds --exclude-file with a single filename", {
  args <- default_args(exclude_file = "package-lock.json")
  idx  <- which(args == "--exclude-file")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "package-lock.json")
})

test_that("build_args() collapses multiple exclude files with a comma", {
  args <- default_args(exclude_file = c("package-lock.json", "yarn.lock"))
  expect_equal(args[[which(args == "--exclude-file") + 1L]],
               "package-lock.json,yarn.lock")
})

test_that("build_args() adds --include-symlinks when include_symlinks = TRUE", {
  expect_true("--include-symlinks" %in% default_args(include_symlinks = TRUE))
})

test_that("build_args() adds --no-large when no_large = TRUE", {
  expect_true("--no-large" %in% default_args(no_large = TRUE))
})

test_that("build_args() adds --large-byte-count with integer value", {
  args <- default_args(large_byte_count = 500000L)
  idx  <- which(args == "--large-byte-count")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "500000")
})

test_that("build_args() adds --large-line-count with integer value", {
  args <- default_args(large_line_count = 10000L)
  idx  <- which(args == "--large-line-count")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "10000")
})

test_that("build_args() adds --count-ignore when count_ignore = TRUE", {
  expect_true("--count-ignore" %in% default_args(count_ignore = TRUE))
})

test_that("build_args() adds --count-as with string value", {
  args <- default_args(count_as = "jsp:htm")
  idx  <- which(args == "--count-as")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "jsp:htm")
})

test_that("build_args() adds --remap-all with string value", {
  args <- default_args(remap_all = "-*- C++ -*-:C Header")
  idx  <- which(args == "--remap-all")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "-*- C++ -*-:C Header")
})

test_that("build_args() adds --remap-unknown with string value", {
  args <- default_args(remap_unknown = "-*- C++ -*-:C Header")
  idx  <- which(args == "--remap-unknown")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "-*- C++ -*-:C Header")
})

# --- not_match --------------------------------------------------------------

test_that("build_args() adds one --not-match flag per pattern", {
  args   <- default_args(not_match = c("test", "vendor"))
  nm_idx <- which(args == "--not-match")
  expect_length(nm_idx, 2L)
  expect_equal(args[nm_idx + 1L], c("test", "vendor"))
})

test_that("build_args() handles a single not_match pattern", {
  args <- default_args(not_match = "node_modules")
  nm_idx <- which(args == "--not-match")
  expect_length(nm_idx, 1L)
  expect_equal(args[[nm_idx + 1L]], "node_modules")
})

# --- git / ignore flags -----------------------------------------------------

test_that("build_args() adds --no-gitignore when no_gitignore = TRUE", {
  expect_true("--no-gitignore" %in% default_args(no_gitignore = TRUE))
})

test_that("build_args() adds --no-gitmodule when no_gitmodule = TRUE", {
  expect_true("--no-gitmodule" %in% default_args(no_gitmodule = TRUE))
})

test_that("build_args() adds --no-ignore when no_ignore = TRUE", {
  expect_true("--no-ignore" %in% default_args(no_ignore = TRUE))
})

test_that("build_args() adds --no-scc-ignore when no_scc_ignore = TRUE", {
  expect_true("--no-scc-ignore" %in% default_args(no_scc_ignore = TRUE))
})

# --- display flags ----------------------------------------------------------

test_that("build_args() adds --no-hborder when no_hborder = TRUE", {
  expect_true("--no-hborder" %in% default_args(no_hborder = TRUE))
})

test_that("build_args() adds --no-size when no_size = TRUE", {
  expect_true("--no-size" %in% default_args(no_size = TRUE))
})

# --- COCOMO flags -----------------------------------------------------------

test_that("build_args() adds --no-cocomo when no_cocomo = TRUE", {
  expect_true("--no-cocomo" %in% default_args(no_cocomo = TRUE))
})

test_that("build_args() adds --avg-wage with integer value", {
  args <- default_args(avg_wage = 75000L)
  idx  <- which(args == "--avg-wage")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "75000")
})

test_that("build_args() adds --cocomo-project-type with string value", {
  args <- default_args(cocomo_project_type = "embedded")
  idx  <- which(args == "--cocomo-project-type")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "embedded")
})

test_that("build_args() adds --eaf with numeric value", {
  args <- default_args(eaf = 1.2)
  idx  <- which(args == "--eaf")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "1.2")
})

test_that("build_args() adds --overhead with numeric value", {
  args <- default_args(overhead = 3.0)
  idx  <- which(args == "--overhead")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "3")
})

test_that("build_args() adds --currency-symbol with string value", {
  args <- default_args(currency_symbol = "€")
  idx  <- which(args == "--currency-symbol")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "€")
})

test_that("build_args() adds --sloccount-format when sloccount_format = TRUE", {
  expect_true("--sloccount-format" %in% default_args(sloccount_format = TRUE))
})

# --- size_unit --------------------------------------------------------------

test_that("build_args() adds --size-unit with string value", {
  args <- default_args(size_unit = "binary")
  idx  <- which(args == "--size-unit")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "binary")
})

# --- performance flags ------------------------------------------------------

test_that("build_args() adds --directory-walker-job-workers with integer value", {
  args <- default_args(directory_walker_job_workers = 4L)
  idx  <- which(args == "--directory-walker-job-workers")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "4")
})

test_that("build_args() adds --file-gc-count with integer value", {
  args <- default_args(file_gc_count = 5000L)
  idx  <- which(args == "--file-gc-count")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "5000")
})

test_that("build_args() adds --file-list-queue-size with integer value", {
  args <- default_args(file_list_queue_size = 16L)
  idx  <- which(args == "--file-list-queue-size")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "16")
})

test_that("build_args() adds --file-process-job-workers with integer value", {
  args <- default_args(file_process_job_workers = 4L)
  idx  <- which(args == "--file-process-job-workers")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "4")
})

test_that("build_args() adds --file-summary-job-queue-size with integer value", {
  args <- default_args(file_summary_job_queue_size = 4L)
  idx  <- which(args == "--file-summary-job-queue-size")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "4")
})

# --- combinations -----------------------------------------------------------

test_that("build_args() combines multiple flags correctly", {
  args <- default_args(
    sort          = "lines",
    by_file       = TRUE,
    no_complexity = TRUE,
    uloc          = TRUE,
    include_ext   = c("R", "py"),
    exclude_dir   = "tests",
    not_match     = "test"
  )
  expect_equal(args[[which(args == "--sort") + 1L]], "lines")
  expect_true("--by-file"       %in% args)
  expect_true("--no-complexity" %in% args)
  expect_true("--uloc"          %in% args)
  expect_equal(args[[which(args == "--include-ext") + 1L]], "R,py")
  expect_equal(args[[which(args == "--exclude-dir") + 1L]], "tests")
  expect_equal(args[[which(args == "--not-match")  + 1L]], "test")
})
