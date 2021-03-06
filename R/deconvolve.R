#' Deconvolution Kernel Density Estimator
#' 
#' Computes the deconvolution kernel density estimator (KDE) of \eqn{X} from 
#' data \eqn{W = X + U} when the distribution of \eqn{U} is known, unknown, or
#' estimated from replicates, \eqn{W_2 = X + U_2}.
#' 
#' The function \code{deconvolve} chooses from one of four different methods 
#' depending on how the error distribution is defined.
#' 
#' \strong{Error from Replicates:} If both \code{W} and \code{W2} are supplied
#' then the error is calculated using replicates.
#' 
#' \strong{Symmetric Error:} If none of \code{errortype}, \code{phiU}, or 
#' \code{W2} are supplied then the error is assumed symmetric and the 
#' deconvolution method is based on the method described in Delaigle and Hall 
#' 2016.
#' 
#' \strong{Homoscedastic Error:} If the errors are defined by either a single 
#' function \code{phiU}, or a single value \code{sd_U} along with its 
#' \code{errortype} then the method used is as described in Stefanski and
#' Carroll 1990.
#' 
#' \strong{Heteroscedastic Errors:} If the errors are defined by a either a 
#' vector of functions \code{phiU}, or a vector \code{sd_U} along with its 
#' \code{errortype} then the method used is as described in Delaigle and 
#' Meister 2008.
#' 
#' Errors can be defined by either a distribution type (\code{errortype}) along 
#' with the standard deviation(s) (\code{sd_U}), or by the characteristic 
#' function(s) of the errors (\code{phiU}). 
#' 
#' @param W A vector of the univariate contaminated data.
#' @param W2 A vector of replicate measurements. If supplied, then the error 
#' will be estimated using replicates.
#' @param xx A vector of x values on which to compute the density. This can be
#' missing if \code{pmf = TRUE}.
#' @param errortype The distribution type of \eqn{U}. Either "laplace" or 
#' "normal". If you define the errors this way then you must also provide 
#' \code{sd_U} but should not provide \code{phiU}. Argument is case-insensitive
#' and partially matched.
#' @param sd_U The standard deviations of \eqn{U}. A single value for
#' homoscedastic errors and a vector having the same length as \code{W} for 
#' heteroscedastic errors. This does not need to be provided if you define your
#' error using phiU and provide \code{bw}.
#' @param phiU A function giving the characteristic function of \eqn{U}. A 
#' single value for homoscedastic errors and a vector having the same length as 
#' \code{W} for heteroscedastic errors. If you define the errors this way then 
#' you should not provide \code{errortype}.
#' @param bw The bandwidth to use. If \code{NULL}, a bandwidth will be
#' calculated using an appropriate plug-in estimator.
#' @param rescale If \code{TRUE}, estimator is rescaled so that it 
#' integrates to 1. Rescaling requires \code{xx} to be a fine grid of equispaced 
#' \eqn{x} values that covers the whole range of \eqn{x}-values where the 
#' estimated density is significantly non zero.
#' @param pmf If \code{TRUE}, returns a probability mass function instead of a 
#' density as the estimator. This is quicker than estimating a density. To use
#' this option, the errors must not be provided.
# ' @param phiK A function giving the fourier transform of the kernel. 
# ' If supplied, \code{muK2}, \code{RK}, and \code{tt} must also be supplied. If 
# ' not supplied it defaults to \eqn{(1 - t^2)^3} on the interval \eqn{[-1,1]}.
# ' @param muK2 The second moment of the kernel, i.e. \eqn{\int x^2 K(x) dx}.
# ' @param RK The integral of the square of the kernel, i.e. \eqn{\int K^2(x) dx}.
# ' @param tt A vector of evenly spaced t values on which to approximate the 
# ' integrals in the Fourier domain. If phiK is compactly supported, the first 
# ' and last elements of \code{tt} must be the lower and upper bound of the 
# ' support of phiK. If phiK is not compactly supported, the first and last 
# ' elements of \code{tt} must be large enough for your discretisation of the 
# ' integrals to be accurate.
#' @param kernel_type The deconvolution kernel to use. The default kernel has
#' characteristic function \eqn{(1-t^2)^3}.
#' @param m The number of point masses to use to estimate the distribution of 
#' \eqn{X} when the error is not supplied.
#' 
#' @return An object of class "\code{deconvolve}".
#' 
#' The function \code{plot} produces a plot of the deconvolution KDE.
#' 
#' An object of class "\code{deconvolve}" is a list containing at least some of
#' the elements:
#' \item{W}{The original contaminated data}
#' \item{x}{The values on which the deconvolution KDE is evaluated.}
#' \item{pdf}{A vector containing the deconvolution KDE evaluated at each point 
#' in \code{x}}
#' \item{support}{The support of the pmf found when the errors are assumed
#' symmetric}
#' \item{probweights}{The probability masses of the pmf found when the errors
#' are assumed symmetric}
#' 
#' @section Warnings:
#' \itemize{
#'	\item If you supply your own bandwidth, then you should ensure that the
#' 	kernel used here matches the one you used to calculate your bandwidth.
#'	\item The DKDE can also be computed using the Fast Fourier Transform, which 
#' 	is a bit more complex. See Delaigle and Gijbels 2007. However if the grid of 
#' 	t-values is fine enough, the estimator can simply be computed like here 
#' 	without having problems with oscillations.
#' }
#' 
#' @section References:
#' Stefanski, L.A. and Carroll, R.J. (1990). Deconvolving kernel density
#' estimators. \emph{Statistics}, 21, 2, 169-184.
#' 
#' Delaigle, A. and Meister, A. (2008). Density estimation with heteroscedastic 
#' error. \emph{Bernoulli}, 14, 2, 562-579.
#' 
#' Delaigle, A. and Hall, P. (2016). Methodology for non-parametric 
#' deconvolution when the error distribution is unknown. \emph{Journal of the 
#' Royal Statistical Society: Series B (Statistical Methodology)}, 78, 1, 
#' 231-252.
#' 
#' Delaigle, A. and Gijbels, I. (2007). Frequent problems in calculating 
#' integrals and optimizing objective functions: a case study in density 
#' deconvolution. \emph{Statistics and Computing}, 17, 349-355.
#' 
#' @author Aurore Delaigle, Timothy Hyndman, Tianying Wang
#' 
#' @example man/examples/deconvolve_eg.R
#' 
#' @export

deconvolve <- function(W, W2 = NULL, xx = seq(min(W), max(W), length.out = 100), 
					   errortype = NULL, sd_U = NULL, phiU = NULL, bw = NULL, 
					   rescale = FALSE, pmf = FALSE, 
					   kernel_type = c("default", "normal", "sinc"), m = 20){

	# Partial matching ---------------------------------------------------------
	dist_types <- c("normal", "laplace")
	if (!is.null(errortype)) {
		errortype <- dist_types[pmatch(tolower(errortype), dist_types)]
		if (is.na(errortype)) {
			stop("Please provide a valid errortype.")
		}
	}

	kernel_type <- match.arg(kernel_type)

	# Determine error type provided --------------------------------------------
	if (!is.null(W2)) {
		errors <- "rep"
	} else if (is.null(errortype) & is.null(phiU)) {
		errors <- "sym"
	} else if ((length(sd_U) > 1) | length(phiU) > 1){
		errors <- "het"
	} else {
		errors <- "hom"
	}

	# Check inputs -------------------------------------------------------------
	if (errors == "het") {
		if (is.null(phiU)) {
			if ((length(sd_U) == length(W)) == FALSE) {
				stop("sd_U must be either length 1 for homoscedastic errors or have the same length as W for heteroscedastic errors.")
			}
		} else {
			if ((length(phiU) == length(W)) == FALSE) {
				stop("phiU must be either length 1 for homoscedastic errors or have the same length as W for heteroscedastic errors.")
			}
		}
	}

	if (!is.null(errortype) & is.null(sd_U)) {
		stop("You must provide sd_U along with errortype.")
	}

	if (!is.null(phiU) & is.null(bw) & is.null(sd_U)){
		stop("You must provide sd_U along with phiU if you do not provide bw.")
	}

	if (pmf & !(errors == "sym")){
		stop("Option pmf cannot be used when the error is provided.")
	}

	if (errors == "rep"){
		if (!(length(W) == length(W2))) {
			stop("W and W2 must be the same length.")
		}
	}

	if (kernel_type == "normal") {
		warning("You should only use the 'normal' kernel when the errors are 
			Laplace or convolutions of Laplace.")
	}

	if (kernel_type == "sinc") {
		warning("You should ensure that you are not using a plug-in bandwidth 
			method for the bandwidth.")
	}

	# Calculate Bandwidth if not supplied --------------------------------------
	if (is.null(bw) & !(errors == "sym")) {
			bw <- bandwidth(W, W2, errortype, sd_U, phiU, 
							kernel_type = kernel_type)
	}

	# --------------------------------------------------------------------------
	kernel_list <- kernel(kernel_type)
	phiK <- kernel_list$phik
	muK2 <- kernel_list$muk2
	RK <- kernel_list$rk
	tt <- kernel_list$tt
	deltat <- tt[2] - tt[1]
	
	# Convert errortype to phiU ------------------------------------------------
	if ((errors == "hom") | (errors == "het")){
		if(is.null(phiU)) {
			phiU <- create_phiU(errors, errortype, sd_U)
		}
	}

	# Perform appropriate deconvolution ----------------------------------------
	if (errors == "hom"){
		pdf <- DeconErrKnownPdf(xx, W, bw, phiU, kernel_type, rescale)
		output <- list("x" = xx, "pdf" = pdf, "W" = W)
	}

	if (errors == "het"){
		pdf <- DeconErrKnownHetPdf(xx, W, bw, phiU, rescale, phiK, muK2, RK, tt)
		output <- list("x" = xx, "pdf" = pdf, "W" = W)
	}

	if (errors == "rep") {
		t_search <- tt/bw
		phiU_splined <- function(t){
			replicates_phiU(t, W, W2, t_search)
		}
		W <- c(W, W2)
		pdf <- DeconErrKnownPdf(xx, W, bw, phiU_splined, kernel_type, rescale)
		output <- list("x" = xx, "pdf" = pdf, "W1" = W, "W2" = W2)
	}

	if (errors == "sym") {
		out <- DeconErrSymPmf(W, m, kernel_type)
		if (!pmf) {
			phi.W <- out$phi.W
			pdf <- DeconErrSymPmfToPdf(out, W, phi.W, xx, kernel_type, rescale, 
									   bw)
			output <- list("x" = xx, "pdf" = pdf, "support" = out$support, 
						   "probweights" = out$probweights, "W" = W)
		} else {
			output <- list("support" = out$support,
						   "probweights" = out$probweights,
						   "W" = W)
		}
	}

	# Output object of class "deconvolve" --------------------------------------
	class(output) <- c("deconvolve", "list")
	output
}
