#' Rdym
#' 
#' Most search engines have a "did you mean?" feature, where
#' suggestions are given in the presence of likely typos. We are able to
#' somewhat replicate this functionality with ancient spellchecker techniques.
#' When R detects that a function or object listed in the user's input is not
#' found, the package finds the minimum 'Levenshtein' distance between the
#' "'un-found'" token and all symbols in the user's global environment plus all
#' loaded 'namespaces'.  The word with minimum 'Levenshtein' distance (in the event
#' of ties, the first such detected) is then suggested as an alternative to the
#' missing symbol.  To use, simply load the package from an interactive R
#' session and start making some errors.  However, there is an explicit
#' interface for starting and stopping "did you mean?" behavior.
#' 
#' @useDynLib Rdym R_levenshtein_dist R_find_closest_word
#' 
#' @name Rdym-package
#' @docType package
#' @author Drew Schmidt and Homer White
#' @keywords Package
NULL
