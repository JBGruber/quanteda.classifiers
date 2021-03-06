#' Logistic regression classifier for texts
#'
#' Fit a fast logistic regression classifier for texts, using the \pkg{glmnet}
#' package.
#' @param x the \link{dfm} on which the model will be fit.  Does not need to
#'   contain only the training documents.
#' @param y vector of training labels associated with each document identified
#'   in \code{train}.  (These will be converted to factors if not already
#'   factors.)
#' @param nfolds .
#' @param ... additional arguments passed to \code{\link[glmnet]{cv.glmnet}}
#' @references Friedman J, Hastie T, Tibshirani R (2010). “Regularization Paths
#'   for Generalized Linear Models via Coordinate Descent.” \emph{Journal of
#'   Statistical Software}, 33(1), 1–22.
#'   \url{http://www.jstatsoft.org/v33/i01/}.
#' @seealso \code{\link[glmnet]{cv.glmnet}}
#' @examples
#' \dontrun{
#' library(quanteda.textmodels)
#' # use party leaders for govt and opposition classes
#' docvars(data_corpus_irishbudget2010, "govtopp") <-
#'     c(rep(NA, 4), "Govt", "Opp", NA, "Opp", NA, NA, NA, NA, NA, NA)
#' dfmat <- dfm(data_corpus_irishbudget2010)
#' tmod <- textmodel_lr(dfmat, y = docvars(dfmat, "govtopp"))
#' predict(tmod)
#' predict(tmod, type = "probability")
#'
#' # multiclass problem - all party leaders
#' tmod2 <- textmodel_lr(dfmat,
#'                       y = c(rep(NA, 3), "SF", "FF", "FG", NA, "LAB",
#'                            NA, NA, "Green", rep(NA, 3)))
#' predict(tmod2)
#' predict(tmod2, type = "probability")
#' }
#' @export
textmodel_lr <- function(x, y, nfolds = 10, ...) {
    UseMethod("textmodel_lr")
}

#' @export
textmodel_lr.default <- function(x, y, nfolds = 10, ...) {
    stop(quanteda:::friendly_class_undefined_message(class(x), "textmodel_lr"))
}

#' @export
#' @importFrom glmnet cv.glmnet
#' @importFrom SparseM as.matrix.csr
textmodel_lr.dfm <- function(x, y, nfolds = 10, ...) {

    x <- as.dfm(x)
    if (!sum(x)) stop(quanteda:::message_error("dfm_empty"))
    call <- match.call()

    # exclude NA in training labels
    x_train <- suppressWarnings(
        dfm_trim(x[!is.na(y), ], min_termfreq = .0000000001,
                 termfreq_type = "prop")
    )
    y_train <- y[!is.na(y)]

    n_class <- if (is.factor(y_train)) {
        length(levels(y_train))
    } else {
        length(unique(y_train))
    }

    family <- if (n_class > 2) {
        "multinomial"
    } else if (n_class > 1) {
        "binomial"
    } else {
        stop("y must at least have two different labels.")
    }

    # for parallel = TRUE to work
    #doMC::registerDoMC(cores = quanteda::quanteda_options("threads"))

    lrfitted <- glmnet::cv.glmnet(
        x = x_train,
        y = y_train,
        family = family,
        nfolds = nfolds,
        maxit = 10000,
        ...
    )

    result <- list(
        x = x, y = y,
        nfolds = nfolds,
        algorithm = paste(family, "logistic regression"),
        type = family,
        classnames = lrfitted[["glmnet.fit"]][["classnames"]],
        lrfitted = lrfitted,
        call = call
    )
    class(result) <- c("textmodel_lr", "textmodel", "list")
    result

}

# helper methods ----------------

#' Prediction from a fitted textmodel_lr object
#'
#' \code{predict.textmodel_lr()} implements class predictions from a fitted
#' logistic regression model.
#' @param object a fitted logistic regression textmodel
#' @param newdata dfm on which prediction should be made
#' @param type the type of predicted values to be returned; see Value
#' @param force make newdata's feature set conformant to the model terms
#' @param ... not used
#' @return \code{predict.textmodel_lr} returns either a vector of class
#'   predictions for each row of \code{newdata} (when \code{type = "class"}), or
#'   a document-by-class matrix of class probabilities (when \code{type =
#'   "probability"}).
#' @seealso \code{\link{textmodel_lr}}
#' @keywords textmodel internal
#' @import glmnet
#' @importFrom stats predict
#' @importFrom SparseM as.matrix.csr
#' @export
predict.textmodel_lr <- function(object, newdata = NULL,
                                 type = c("class", "probability"),
                                 force = TRUE, ...) {

    type <- match.arg(type)
    if (type == "probability") {
        type <- "response"
    }

    if (!is.null(newdata)) {
        data <- as.dfm(newdata)
    } else {
        data <- as.dfm(object$x)
    }

    model_featnames <- colnames(object$x)
    data <- if (is.null(newdata)) {
        suppressWarnings(quanteda.textmodels:::force_conformance(data, model_featnames, force))
    } else {
        quanteda.textmodels:::force_conformance(data, model_featnames, force)
    }

    pred_y <- predict(
        object$lrfitted,
        newx = data,
        type = type,
        ...
    )
    if (type == "class") {
        pred_y <- as.factor(pred_y)
        names(pred_y) <-  quanteda::docnames(data)
    } else if (type == "response") {
        if (ncol(pred_y) == 1) {
            pred_y <- cbind(
                pred_y[, 1],
                1 - pred_y[, 1]
            )
            colnames(pred_y) <- rev(object$classnames)
        } else {
            pred_y <- pred_y[, , 1]
        }
    }
    pred_y
}

#' @export
#' @method print textmodel_lr
print.textmodel_lr <- function(x, ...) {
    cat("\nCall:\n")
    print(x$call)
    cat("\n",
        format(quanteda::ndoc(x$x), big.mark = ","), " training documents; ",
        format(quanteda::nfeat(x$x), big.mark = ","), " fitted features",
        ".\n",
        "Method: ", x$algorithm, "\n",
        sep = "")
}

#' @noRd
#' @method coef textmodel_lr
#' @import glmnet
#' @importFrom stats coef
#' @export
coef.textmodel_lr <- function(object, ...) {
    if (object$type == "binomial") {
        out <- coef(object$lrfitted)
        colnames(out) <- object$classnames[2]
    } else if (object$type == "multinomial") {
        out <- coef(object$lrfitted)
        out <- do.call(cbind, out)
        colnames(out) <- object$classnames
    }
    out
}

#' @noRd
#' @method coefficients textmodel_lr
#' @importFrom stats coefficients
#' @export
coefficients.textmodel_lr <- function(object, ...) {
    UseMethod("coef")
}

#' summary method for textmodel_lr objects
#' @param object output from [textmodel_lr()]
#' @param n how many coefficients to print before truncating
#' @param ... additional arguments not used
#' @keywords textmodel internal
#' @method summary textmodel_lr
#' @export
summary.textmodel_lr <- function(object, n = 30, ...) {
    result <- list(
        "call" = object$call,
        "folds" = object$nfolds,
        "lambda min" = object$lrfitted$lambda.min,
        "lambda 1se" = object$lrfitted$lambda.1se,
        "estimated.feature.scores" = as.matrix(head(coef(object), n))
    )
    as.summary.textmodel(result)
}

