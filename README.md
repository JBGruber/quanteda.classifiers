
# quanteda.classifiers: Text classification textmodel extensions for quanteda

[![CRAN
Version](https://www.r-pkg.org/badges/version/quanteda.classifiers)](https://CRAN.R-project.org/package=quanteda.classifiers)
[![Travis build
status](https://travis-ci.org/quanteda/quanteda.classifiers.svg?branch=master)](https://travis-ci.org/quanteda/quanteda.classifiers)
[![Build
status](https://ci.appveyor.com/api/projects/status/l80oet8swj2q6h4y/branch/master?svg=true)](https://ci.appveyor.com/project/kbenoit/quanteda-svm/branch/master)
[![Coverage
status](https://codecov.io/gh/quanteda/quanteda.classifiers/branch/master/graph/badge.svg)](https://codecov.io/github/quanteda/quanteda.classifiers?branch=master)

## Installation

``` r
# devtools package required to install quanteda from Github 
devtools::install_github("quanteda/quanteda.classifiers") 

keras::install_keras(method = "conda")
```

## Available classifiers

| Classifier                                                          | Command                  |
| ------------------------------------------------------------------- | ------------------------ |
| Support Vector Machine (SVM)                                        | `textmodel_svm()`        |
| Alternative (faster) SVM                                            | `textmodel_svmlin()`     |
| Sequential neural network                                           | `textmodel_nnseq()`      |
| Convolutional neural network + LSTM model fitted to word embeddings | `textmodel_cnnlstmemb()` |

## Available human-annotated corpora

| Corpus                                                                                                                       | Name                           |
| ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| Sentence-level corpus of UK party manifestos 1945–2017, partially annotated                                                  | `data_corpus_manifestosentsUK` |
| Crowd-labelled sentence corpus from a 2010 EP debate on coal subsidies (in six languages)                                    | `data_corpus_EPcoaldebate`     |
| Large Movie Review Dataset of 50,000 annotated highly polar movie reviews for training and testing, from Maas et. al. (2011) | `data_corpus_LMRD`             |

## Demonstration

See this (very preliminary\!) [performance
comparison](https://htmlpreview.github.io/?https://github.com/quanteda/quanteda.classifiers/blob/master/tests/misc/test-LMRD.nb.html).

## How to cite

Benoit, Kenneth, Patrick Chester, and Stefan Müller (2019).
quanteda.classifiers: Models for supervised text classification. R
package version 0.1. URL: <http://github.com/quanteda/quanteda.svm>.

For a BibTeX entry, use the output from citation(package =
“quanteda.classifiers”).

## Issues

  - Please file an issue (with a bug, wish list, etc.) [via
    GitHub](https://github.com/quanteda/quanteda.classifiers/issues).
