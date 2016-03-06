matcherr <- function(msg, pattern)
{
  grepl(x=msg, pattern=pattern, perl=TRUE)
}


removechar <- function(char, str)
{
  gsub(str, pattern=char, replacement="")
}



get_lastcall <- function(call_stack, msg, err_token)
{
  # the lst item in the call stack is the code for stop_dym
  #if call stack has length greater thne one, then we can get the last call from the stack:
  #no guesswork with R history
  if (length(call_stack) > 1) return(call_stack[[1]])
  
  # guess from R history; this could fail if user enter multiple commands on a single line
  # but probability is low, I think
  backsearch_limit <- 10
  
  Rhistfile <- tempfile(".Rhistory")
  utils::savehistory(Rhistfile)
  Rhist <- readLines(Rhistfile)
  unlink(Rhistfile)

  n <- length(Rhist)
  place <- n
  match <- FALSE
  call_frag <- Rhist[n]
  safety <- 0 #count up to backsearch_limit
  while (!match && safety <= backsearch_limit)
  {
    error <- function(e) geterrmessage()
    current_msg <- tryCatch(eval(parse(text=call_frag)), error=error)
    
    msg_chop <- sub(msg, pattern=paste0(err_token, ".*: "), replacement="", ignore.case=TRUE)
    msg_chop <- sub(msg_chop, pattern="[[:space:]]$", replacement="")
    msg_chop <- sub(msg_chop, pattern="^[[:space:]]*", replacement="")
    
    if (current_msg == msg_chop)
      match <- TRUE 
    else
    {
      place <- place - 1
      safety <- safety + 1
      call_frag <- paste0(Rhist[place], call_frag)
    }
  }
  
  if (match == FALSE) 
    return(NULL) 
  else
    return(call_frag)
}



stop_dym <- function()
{
  ### Get the call stack (will always contain at least the call for stop_dym)
  call_stack <- sys.calls()
  
  missing_fun <- paste0("(?<=", sprintf(gettext("could not find function %s"), ")(.*)(?="), ")")
  missing_obj <- paste0("(?<=", sprintf(gettext("object %s not found"), ")(.*)(?="), ")")
  
  msg <- geterrmessage()
  err_token <- gettext("Error:")
  lastcall <- get_lastcall(call_stack, msg, err_token)
  
  
  ### "could not find function"
  if (matcherr(msg=msg, pattern=missing_fun))
  {
    did_you_mean(gettext("could not find function %s"), lastcall, problem="function", msg, call_stack)
  }
  ### "is not an exported object from"
  else if (matcherr(msg=msg, pattern=gettext("is not an exported object from"))) #FIXME language
  {
    notExported <- sub(x=msg, pattern=gettext("Error:"), replacement="")
    notExported <- sub(x=notExported, pattern=paste0(gettext(" is not an exported object from"),".*"), replacement="")
    notExported <- gsub(x=notExported, pattern="'", replacement="")
    
    did_you_mean(notExported, lastcall, problem="not_exported", msg, call_stack)
  }
  ### "object %s not found"
  else if (matcherr(msg=msg, pattern=missing_obj))
  {
    did_you_mean(gettext("object %s not found", domain = "R-base"), lastcall, problem="object", msg, call_stack)
  }
  ### "there is no package called"
  else if (matcherr(msg=msg, pattern=gettext("there is no package called %s", domain = "R-base")))
  {
    pack <- sub(x=msg, pattern=paste0(".*", gettext("there is no package called %s")," "), replacement="")
    pack <- sub(x=pack, pattern="\\n", replacement="")
    
    alphanum <- c(letters, LETTERS)
    c <- substr(pack, 1, 1)
    if (!(c %in% alphanum)) pack <- removechar(c, pack)
    c <- substr(pack, nchar(pack), nchar(pack))
    if (!(c %in% alphanum)) pack <- removechar(c, pack)
    
    did_you_mean(pack, lastcall, problem="package", msg, call_stack)
  }
  ### unused argument
  else if (matcherr(msg=msg, pattern=paste0(gettext("unused argument"), "(?s)")))
  {  
    # best to work on problematic tokens in dym.R, so put placeholder for name
    did_you_mean(name="placeholder", lastcall, problem="unused_arguments", msg, call_stack)
  }
  
  invisible()
}

