scc_available <- nchar(Sys.which("scc")) > 0L

# Helper: create an isolated temp dir and populate it with known files.
make_test_dir <- function(files) {
  dir <- withr::local_tempdir(.local_envir = parent.frame())
  for (nm in names(files)) {
    writeLines(files[[nm]], file.path(dir, nm))
  }
  dir
}

# Helper: create a subdir inside a temp dir with its own files.
make_test_subdir <- function(parent, subdir_name, files) {
  sub <- file.path(parent, subdir_name)
  dir.create(sub)
  for (nm in names(files)) writeLines(files[[nm]], file.path(sub, nm))
  invisible(sub)
}

# Fixtures -------------------------------------------------------------------

# Normal R file: 3 code, 2 comment, 1 blank = 6 lines
r_content <- c("# comment one", "# comment two", "x <- 1", "y <- 2", "", "z <- 3")

# Normal Python file: 2 code, 1 comment, 1 blank = 4 lines
py_content <- c("# python comment", "x = 1", "", "y = 2")

# Generated R file: scc default marker "do not edit" in header
gen_content <- c("# do not edit", "x <- 1", "y <- 2", "z <- 3")

# Minified R file: single line > 255 chars triggers scc minified detection
# 60 repetitions * (6 chars + 2 sep) = ~476 chars on one line
min_content <- paste(rep("x <- 1", 60), collapse = "; ")

# Duplicate content: two files with identical content
dup_content <- c("x <- 1", "y <- 2", "z <- 3")

# Small content for large-file threshold tests (3 lines)
small_content <- c("x <- 1", "y <- 2", "z <- 3")

# Large content: 10 lines (exceeds a threshold of 5)
large_content <- paste0("x_", seq_len(10), " <- ", seq_len(10))


# === weighted_complexity type ================================================

test_that("scc() weighted_complexity column is type double", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir)
  expect_type(result$weighted_complexity, "double")
})

test_that("scc_by_file() weighted_complexity column is type double", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc_by_file(dir)
  expect_type(result$weighted_complexity, "double")
})


# === uloc / dryness ==========================================================

test_that("uloc = TRUE makes the uloc column non-zero", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, uloc = TRUE)
  expect_true(all(result$uloc > 0L))
})

test_that("uloc = FALSE keeps uloc at zero", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, uloc = FALSE)
  expect_true(all(result$uloc == 0L))
})

test_that("dryness = TRUE populates the uloc column (dryness implies uloc)", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, dryness = TRUE)
  expect_true(all(result$uloc > 0L))
})


# === sort ====================================================================

test_that("sort = 'name' returns languages in alphabetical order", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content, "script.py" = py_content))
  result <- scc(dir, sort = "name")
  expect_equal(result$language, sort(result$language))
})

test_that("sort = 'files' places language with more files first", {
  skip_if_not(scc_available, "scc not on PATH")
  # 2 R files, 1 Python file
  dir    <- make_test_dir(list(
    "a.R" = r_content, "b.R" = r_content, "script.py" = py_content
  ))
  result <- scc(dir, sort = "files")
  expect_equal(result$language[[1L]], "R")
})

test_that("sort = 'lines' places language with most lines first", {
  skip_if_not(scc_available, "scc not on PATH")
  # r_content has 6 lines; py_content has 4 lines
  dir    <- make_test_dir(list("script.R" = r_content, "script.py" = py_content))
  result <- scc(dir, sort = "lines")
  expect_equal(result$language[[1L]], "R")
})

test_that("sort = 'code' places language with most code lines first", {
  skip_if_not(scc_available, "scc not on PATH")
  # r_content has 3 code; py_content has 2 code
  dir    <- make_test_dir(list("script.R" = r_content, "script.py" = py_content))
  result <- scc(dir, sort = "code")
  expect_equal(result$language[[1L]], "R")
})


# === exclude_dir =============================================================

test_that("exclude_dir omits files in the excluded subdirectory", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("top.R" = r_content))
  make_test_subdir(dir, "hidden", list("sub.R" = r_content))

  result_default  <- scc(dir)
  result_excluded <- scc(dir, exclude_dir = "hidden")

  r_default  <- result_default[result_default$language == "R", ]
  r_excluded <- result_excluded[result_excluded$language == "R", ]

  expect_equal(r_default$files,  2L)
  expect_equal(r_excluded$files, 1L)
})

test_that("exclude_dir accepts multiple directories", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("top.R" = r_content))
  make_test_subdir(dir, "dirA", list("a.R" = r_content))
  make_test_subdir(dir, "dirB", list("b.R" = r_content))

  result <- scc(dir, exclude_dir = c("dirA", "dirB"))
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files, 1L)   # only top.R remains
})

test_that("scc_by_file() exclude_dir omits files in excluded subdirectory", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("top.R" = r_content))
  make_test_subdir(dir, "hidden", list("sub.R" = r_content))

  result <- scc_by_file(dir, exclude_dir = "hidden")
  expect_false(any(grepl("hidden", result$location)))
})


# === exclude_file ============================================================

test_that("exclude_file omits the file with the specified name", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("keep.R" = r_content, "drop.R" = r_content))

  result_all     <- scc(dir)
  result_dropped <- scc(dir, exclude_file = "drop.R")

  r_all     <- result_all[result_all$language == "R", ]
  r_dropped <- result_dropped[result_dropped$language == "R", ]

  expect_equal(r_all$files,     2L)
  expect_equal(r_dropped$files, 1L)
})

test_that("scc_by_file() exclude_file omits the specified filename", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("keep.R" = r_content, "drop.R" = r_content))
  result <- scc_by_file(dir, exclude_file = "drop.R")
  expect_false("drop.R" %in% result$filename)
  expect_true ("keep.R" %in% result$filename)
})


# === not_match (integration) =================================================

test_that("not_match excludes files whose paths match the pattern", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("main.R" = r_content, "test_helper.R" = r_content))

  result_all  <- scc(dir)
  result_excl <- scc(dir, not_match = "test_")

  r_all  <- result_all[result_all$language == "R", ]
  r_excl <- result_excl[result_excl$language == "R", ]

  expect_equal(r_all$files,  2L)
  expect_equal(r_excl$files, 1L)
})


# === large-file threshold ====================================================

test_that("no_large + large_line_count excludes files exceeding the line threshold", {
  skip_if_not(scc_available, "scc not on PATH")
  # small_content: 3 lines; large_content: 10 lines; threshold: 5
  dir    <- make_test_dir(list("small.R" = small_content, "large.R" = large_content))
  result <- scc(dir, no_large = TRUE, large_line_count = 5L)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files, 1L)   # large.R excluded
})

test_that("no_large + large_byte_count excludes files exceeding the byte threshold", {
  skip_if_not(scc_available, "scc not on PATH")
  # small.R: ~18 bytes; large.R: ~80 bytes; threshold: 30
  dir    <- make_test_dir(list("small.R" = small_content, "large.R" = large_content))
  result <- scc(dir, no_large = TRUE, large_byte_count = 30L)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files, 1L)   # large.R excluded
})

test_that("without no_large, the threshold flags have no effect on output", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("small.R" = small_content, "large.R" = large_content))
  result <- scc(dir, no_large = FALSE, large_line_count = 5L)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files, 2L)   # both files included
})


# === generated-file detection ================================================

test_that("scc_by_file() with gen=TRUE marks 'do not edit' files as generated", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("normal.R" = r_content, "gen.R" = gen_content))
  result <- scc_by_file(dir, gen = TRUE)
  gen_row <- result[result$filename == "gen.R", ]
  expect_true(gen_row$generated)
  normal_row <- result[result$filename == "normal.R", ]
  expect_false(normal_row$generated)
})

test_that("no_gen = TRUE excludes generated files from scc() output", {
  skip_if_not(scc_available, "scc not on PATH")
  dir           <- make_test_dir(list("normal.R" = r_content, "gen.R" = gen_content))
  result_all    <- scc(dir)
  result_no_gen <- scc(dir, no_gen = TRUE)

  r_all    <- result_all[result_all$language == "R", ]
  r_no_gen <- result_no_gen[result_no_gen$language == "R", ]

  expect_equal(r_all$files,    2L)
  expect_equal(r_no_gen$files, 1L)
})

test_that("no_gen = TRUE excludes generated files from scc_by_file() output", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("normal.R" = r_content, "gen.R" = gen_content))
  result <- scc_by_file(dir, no_gen = TRUE)
  expect_false("gen.R" %in% result$filename)
  expect_true ("normal.R" %in% result$filename)
})

test_that("generated_markers replaces default markers for generation detection", {
  skip_if_not(scc_available, "scc not on PATH")
  custom_gen  <- c("# CUSTOM_GEN_MARKER", "x <- 1", "y <- 2")
  dir         <- make_test_dir(list("normal.R" = r_content, "gen.R" = custom_gen))

  # With default markers, gen.R is NOT detected as generated → still counted
  result_default <- scc(dir, no_gen = TRUE)
  r_default      <- result_default[result_default$language == "R", ]
  expect_equal(r_default$files, 2L)

  # With custom marker, gen.R IS detected and excluded
  result_custom <- scc(dir, no_gen = TRUE,
                       generated_markers = "CUSTOM_GEN_MARKER")
  r_custom      <- result_custom[result_custom$language == "R", ]
  expect_equal(r_custom$files, 1L)
})


# === minified-file detection =================================================

test_that("scc_by_file() with min=TRUE marks single-long-line files as minified", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("normal.R" = r_content, "min.R" = min_content))
  result <- scc_by_file(dir, min = TRUE)
  min_row <- result[result$filename == "min.R", ]
  expect_true(min_row$minified)
  normal_row <- result[result$filename == "normal.R", ]
  expect_false(normal_row$minified)
})

test_that("no_min = TRUE excludes minified files from scc() output", {
  skip_if_not(scc_available, "scc not on PATH")
  dir          <- make_test_dir(list("normal.R" = r_content, "min.R" = min_content))
  result_all   <- scc(dir)
  result_no_min <- scc(dir, no_min = TRUE)

  r_all    <- result_all[result_all$language == "R", ]
  r_no_min <- result_no_min[result_no_min$language == "R", ]

  expect_equal(r_all$files,     2L)
  expect_equal(r_no_min$files,  1L)
})

test_that("no_min = TRUE excludes minified files from scc_by_file() output", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("normal.R" = r_content, "min.R" = min_content))
  result <- scc_by_file(dir, no_min = TRUE)
  expect_false("min.R"    %in% result$filename)
  expect_true ("normal.R" %in% result$filename)
})

test_that("min_gen_line_length overrides the minified detection threshold", {
  skip_if_not(scc_available, "scc not on PATH")
  # r_content has 6 lines and ~40 bytes → average ~7 bytes/line
  # With threshold of 5, it would be "minified" → excluded by no_min
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, no_min = TRUE, min_gen_line_length = 5L)
  expect_equal(nrow(result), 0L)   # all R files excluded as "minified"
})

test_that("no_min_gen = TRUE excludes both minified and generated files", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list(
    "normal.R" = r_content,
    "gen.R"    = gen_content,
    "min.R"    = min_content
  ))
  result <- scc(dir, no_min_gen = TRUE)
  r_row  <- result[result$language == "R", ]
  expect_equal(r_row$files, 1L)   # only normal.R remains
})


# === no_duplicates ===========================================================

test_that("no_duplicates = TRUE counts identical files only once", {
  skip_if_not(scc_available, "scc not on PATH")
  dir         <- make_test_dir(list("a.R" = dup_content, "b.R" = dup_content))
  result_both <- scc(dir)
  result_dedup <- scc(dir, no_duplicates = TRUE)

  r_both  <- result_both[result_both$language == "R", ]
  r_dedup <- result_dedup[result_dedup$language == "R", ]

  expect_equal(r_both$files,  2L)
  expect_equal(r_dedup$files, 1L)
})


# === gitignore / ignore logic ================================================

test_that("no_gitignore = TRUE counts files listed in .gitignore", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list(
    "script.R"  = r_content,
    "script.py" = py_content,
    ".gitignore" = "*.py"
  ))
  # Default: .gitignore respected → Python excluded
  result_default <- scc(dir)
  expect_false("Python" %in% result_default$language)

  # no_gitignore: .gitignore ignored → Python included
  result_no_gi   <- scc(dir, no_gitignore = TRUE)
  expect_true("Python" %in% result_no_gi$language)
})

test_that("count_ignore = TRUE causes .gitignore to be counted as a file", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list(
    "script.R"   = r_content,
    ".gitignore" = c("*.log", "*.tmp")
  ))
  result_default      <- scc(dir)
  result_count_ignore <- scc(dir, count_ignore = TRUE)

  # With count_ignore, total files across all languages is higher
  expect_gt(sum(result_count_ignore$files), sum(result_default$files))
})

test_that("no_ignore = TRUE counts files listed in .ignore", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list(
    "script.R"  = r_content,
    "script.py" = py_content,
    ".ignore"    = "*.py"
  ))
  result_default  <- scc(dir)
  result_no_ignore <- scc(dir, no_ignore = TRUE)

  # Default: .ignore respected → Python excluded or same; no_ignore → Python present
  expect_true("Python" %in% result_no_ignore$language)
})


# === include_symlinks ========================================================

test_that("include_symlinks = TRUE counts symlinked files", {
  skip_if_not(scc_available, "scc not on PATH")
  skip_on_os("windows")

  dir    <- make_test_dir(list("real.R" = r_content))
  link   <- file.path(dir, "link.R")
  file.symlink(file.path(dir, "real.R"), link)

  result_no_symlink  <- scc(dir)
  result_symlink     <- scc(dir, include_symlinks = TRUE)

  r_no_symlink <- result_no_symlink[result_no_symlink$language == "R", ]
  r_symlink    <- result_symlink[result_symlink$language == "R", ]

  # Without: only real.R counted; with: real.R + link.R
  expect_equal(r_no_symlink$files, 1L)
  expect_equal(r_symlink$files,    2L)
})


# === count_as ================================================================

test_that("count_as remaps an unknown extension to a known language", {
  skip_if_not(scc_available, "scc not on PATH")
  # .glock is not a recognised scc extension
  dir <- make_test_dir(list(
    "script.glock" = r_content
  ))
  result_default <- scc(dir)
  expect_equal(nrow(result_default), 0L)   # not recognised

  result_mapped <- scc(dir, count_as = "glock:r")
  expect_true("R" %in% result_mapped$language)
})


# === verbose / debug =========================================================

test_that("verbose = TRUE still returns a valid tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, verbose = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0L)
})

test_that("debug = TRUE still returns a valid tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, debug = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0L)
})


# === binary ==================================================================

test_that("binary = TRUE still returns a valid tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, binary = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0L)
})


# === COCOMO flags don't break JSON output ====================================

test_that("COCOMO flags pass through without corrupting JSON output", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir,
    no_cocomo           = TRUE,
    avg_wage            = 75000L,
    cocomo_project_type = "embedded",
    eaf                 = 1.2,
    overhead            = 3.0,
    currency_symbol     = "€",
    sloccount_format    = TRUE
  )
  expect_s3_class(result, "tbl_df")
  expect_true("R" %in% result$language)
})


# === display-only flags don't break JSON output ==============================

test_that("percent, no_hborder, no_size return valid tibbles", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, percent = TRUE, no_hborder = TRUE, no_size = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_true("R" %in% result$language)
})

test_that("size_unit values return valid tibbles", {
  skip_if_not(scc_available, "scc not on PATH")
  dir <- make_test_dir(list("script.R" = r_content))
  for (unit in c("si", "binary", "mixed")) {
    result <- scc(dir, size_unit = unit)
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0L, info = paste("size_unit =", unit))
  }
})


# === performance flags don't break JSON output ===============================

test_that("performance-tuning flags return valid tibbles", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir,
    directory_walker_job_workers = 4L,
    file_gc_count                = 100L,
    file_list_queue_size         = 4L,
    file_process_job_workers     = 4L,
    file_summary_job_queue_size  = 4L
  )
  expect_s3_class(result, "tbl_df")
  expect_true("R" %in% result$language)
})


# === git / ignore passthrough flags ==========================================

test_that("no_gitmodule, no_scc_ignore return valid tibbles", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, no_gitmodule = TRUE, no_scc_ignore = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_true("R" %in% result$language)
})


# === remap_all / remap_unknown ===============================================

test_that("remap_unknown returns a valid tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, remap_unknown = "# R script:R")
  expect_s3_class(result, "tbl_df")
})

test_that("remap_all returns a valid tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, remap_all = "# R script:R")
  expect_s3_class(result, "tbl_df")
})


# === min_gen (identifies combined minified/generated) ========================

test_that("min_gen = TRUE still returns a valid tibble", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, min_gen = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0L)
})

test_that("min_gen = TRUE with scc_by_file marks correct files", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list(
    "normal.R" = r_content,
    "gen.R"    = gen_content,
    "min.R"    = min_content
  ))
  result   <- scc_by_file(dir, min_gen = TRUE)
  gen_row  <- result[result$filename == "gen.R",  ]
  min_row  <- result[result$filename == "min.R",  ]
  norm_row <- result[result$filename == "normal.R", ]

  expect_true (gen_row$generated)
  expect_true (min_row$minified)
  expect_false(norm_row$generated)
  expect_false(norm_row$minified)
})


# === character flag (passes through; LineLength is null in JSON) =============

test_that("character = TRUE still returns a valid tibble with correct columns", {
  skip_if_not(scc_available, "scc not on PATH")
  dir    <- make_test_dir(list("script.R" = r_content))
  result <- scc(dir, character = TRUE)
  expect_s3_class(result, "tbl_df")
  expect_named(result,
    c("language", "files", "lines", "code", "comments", "blanks",
      "complexity", "weighted_complexity", "bytes", "uloc"))
})
