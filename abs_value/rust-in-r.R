# You have a function you want to apply to every element of a vector

# create a vector
set.seed(20240124)
z <- rnorm(1)

# create a function
# trivial example to calculate absolute value of x
abs_value_r <- function(x) {
  if (x >= 0) {
    return(x)
  } else {
    return(-x)
  }
}
abs_value_r(z)

# write single function in rust
library(rextendr)
rust_function(
  "fn abs_value_rust(x: f64) -> f64 {
    let number = if x>=0.0 { x } else { -1.0 * x };
    return number;
  }"
)
abs_value_rust(z)




# Vectorising -------------------------------------------------------------

# rust
code <- r"(
#[extendr]
fn abs_value_rust(x: f64) -> f64 {
  let number = if x>=0.0 { x } else { -1.0 * x };
  return number;
}

#[extendr]
fn abs_value_iter(v: Vec<f64>) -> Vec<f64> {
    let abs_v: Vec<_> = v.iter().map(|x| abs_value_rust(*x)).collect();
    return abs_v;
}
)"

rust_source(code = code)

set.seed(20240124)
z <- rnorm(20)
abs_value_iter(z)


# Comparison of methods ---------------------------------------------------

# for loop (pre-allocated) function
for_allocated <- function(z) {
  abs_z <- numeric(length = length(z))
  for (i in seq_along(z)) {
    abs_z[i] <- abs_value_r(z[i])
  }
  return(abs_z)
}
for_allocated(z)

set.seed(20240124)
z1 <- rnorm(100)
z2 <- rnorm(1000)
z3 <- rnorm(10000)
z4 <- rnorm(100000)

library(bench)
z1_res <- bench::mark(
  for_allocated(z1),
  sapply(z1, abs_value_r),
  purrr::map_vec(z1, abs_value_r),
  abs_value_iter(z1),
  iterations = 100,
  time_unit = "ms"
)

z2_res <- bench::mark(
  for_allocated(z2),
  sapply(z2, abs_value_r),
  purrr::map_vec(z2, abs_value_r),
  abs_value_iter(z2),
  iterations = 100,
  time_unit = "ms"
)

z3_res <- bench::mark(
  for_allocated(z3),
  sapply(z3, abs_value_r),
  purrr::map_vec(z3, abs_value_r),
  abs_value_iter(z3),
  iterations = 100,
  time_unit = "ms"
)

z4_res <- bench::mark(
  for_allocated(z4),
  sapply(z4, abs_value_r),
  purrr::map_vec(z4, abs_value_r),
  abs_value_iter(z4),
  iterations = 100,
  time_unit = "ms"
)

# combine
results <- data.frame(
  methods = c("for loop",
              "sapply",
              "purrr::map_vec",
              "Rust iter.map"),
  `n_100` = z1_res$median,
  `n_1000` = z2_res$median,
  `n_10000` = z3_res$median,
  `n_100000` = z4_res$median
)

library(tidyverse)
results |> 
  pivot_longer(-methods, names_to = "n") |> 
  mutate(n = as.numeric(str_remove(n, "n_"))) |> 
  mutate(methods = factor(methods,
                          levels = c("purrr::map_vec",
                                     "sapply",
                                     "for loop",
                                     "Rust iter.map"))) |> 
  ggplot(mapping = aes(x = n, y = value, colour = methods)) +
  geom_line() +
  geom_point() +
  scale_y_log10() +
  scale_color_brewer(palette = "Dark2") +
  labs(x = "Length of input vector", y = "Time (ms)") +
  theme_light() +
  theme(legend.position = "bottom",
        legend.title = element_blank())

ggsave("comparison_plot.png", height = 5, width = 5, units = "in")
