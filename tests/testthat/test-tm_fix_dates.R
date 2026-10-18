test_that(".tm_fix_dates parses dd/mm/yyyy dates", {
  expect_equal(.tm_fix_dates("30/06/2027"), "2027-06-30")
})

test_that(".tm_fix_dates parses dd.mm.yyyy dates", {
  expect_equal(.tm_fix_dates("30.06.2027"), "2027-06-30")
})

test_that(".tm_fix_dates parses 'Mon d, yyyy' dates", {
  expect_equal(.tm_fix_dates("Jun 30, 2027"), "2027-06-30")
})

test_that(".tm_fix_dates returns NA for NA input", {
  expect_true(is.na(.tm_fix_dates(NA_character_)))
})
