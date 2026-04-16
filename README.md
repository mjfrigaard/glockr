
<!-- README.md is generated from README.Rmd. Please edit that file -->

# glockr

<!-- badges: start -->

<!-- badges: end -->

The goal of `glockr` is to wrap the [`scc` code
counter](https://github.com/boyter/scc) in an R package:

> “*Goal is to be the fastest code counter possible, but also perform
> COCOMO calculation like sloccount, LOCOMO estimation for LLM-based
> development costs, estimate code complexity similar to cyclomatic
> complexity calculators and produce unique lines of code or DRYness
> metrics. In short one tool to rule them all.*”

This project was hugely inspired by the [`cloc` R
package](https://github.com/hrbrmstr/cloc) by [boB
Rudis](https://github.com/hrbrmstr)

## Installation

You can install the development version of `glockr` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("mjfrigaard/glockr")
```

## Examples

``` r
library(glockr)

pkg_path <- system.file(package = "glockr")
```

``` r
scc_version()
```

``` r
#> [1] "scc version 3.7.0"
```

``` r
scc(pkg_path)
```

``` r
#> # A tibble: 4 × 10
#>   language files lines  code comments blanks
#>   <chr>    <int> <int> <int>    <int>  <int>
#> 1 R            4   644   534       26     84
#> 2 CSS          1   130   106        0     24
#> 3 HTML         1    33    29        0      4
#> 4 License      1     2     2        0      0
#> # ℹ 4 more variables: complexity <int>,
#> #   weighted_complexity <int>, bytes <int>,
#> #   uloc <int>
```

Filter to just the R source files for a tighter view:

``` r
r_files <- scc_by_file(pkg_path, include_ext = "r")
r_files[, c("filename", "lines", "code", "comments", "blanks", "complexity")]
```

``` r
#> # A tibble: 4 × 6
#>   filename  lines  code comments blanks complexity
#>   <chr>     <int> <int>    <int>  <int>      <int>
#> 1 testthat…     4     3        0      1          0
#> 2 test-par…   238   212        5     21         12
#> 3 test-bui…   154   119        8     27         13
#> 4 test-scc…   248   200       13     35         11
```

`scc` estimates cyclomatic complexity by counting control-flow keywords
(`if`, `for`, `while`, etc.). The `complexity` column is the raw total;
`weighted_complexity` divides by lines of code to give a per-line rate.

``` r
r_files[order(-r_files$complexity),
        c("filename", "code", "complexity", "weighted_complexity")]
```

``` r
#> # A tibble: 4 × 4
#>   filename     code complexity weighted_complexity
#>   <chr>       <int>      <int>               <int>
#> 1 test-build…   119         13                   0
#> 2 test-parse…   212         12                   0
#> 3 test-scc.R    200         11                   0
#> 4 testthat.R      3          0                   0
```

`scc_languages()` returns every language `scc` recognizes, along with
the file extensions it maps to that language.

``` r
langs <- scc_languages()
nrow(langs)
```

``` r
#> [1] 358
```

``` r
head(langs, 10)
```

``` r
#> # A tibble: 10 × 2
#>    language     extensions     
#>    <chr>        <chr>          
#>  1 ABAP         abap           
#>  2 ABNF         abnf           
#>  3 ActionScript as             
#>  4 Ada          ada,adb,ads,pad
#>  5 Agda         agda           
#>  6 Alchemist    crn            
#>  7 Alex         x              
#>  8 Algol 68     a68            
#>  9 Alloy        als            
#> 10 Amber        ab
```
