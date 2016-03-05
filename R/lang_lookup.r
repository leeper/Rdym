check_lang <- function(lang)
{
  if (!"R-Rdym.mo" %in% dir(file.path(bindtextdomain("R"), tolower(if(missing(lang)) Sys.getenv("LANG") else lang), "LC_MESSAGES")))
    stop("Language is not supported in Rdym at this time.  If you have localization support in R, please file an issue with Rdym at https://github.com/wrathematics/Rdym/issues")
  
  return(invisible())
}



get_missing_obj <- function(lang)
{
  obj <- paste0("(?<=", sprintf(gettext("object %s not found"), ")(.*)(?="), ")")
  return(obj)
}



get_missing_fun <- function(lang)
{
  fun <- paste0("(?<=", sprintf(gettext("could not find function %s"), ")(.*)(?="), ")")
  return(fun)
}

