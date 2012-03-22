#lang scribble/manual
@(require scribble/eval
          planet/scribble
          (for-label (this-package-in main)))


@title{tqueue: a queue-like data structure for topological sorting.}

@defmodule/this-package[main]

@scheme[tqueue] provides a data structure for maintaining elements
with dependencies.  It keeps track of known satisfied dependencies;
any elements whose dependencies are all satisifed can pop off a
@scheme[tqueue].  This is basically an implementation of Algorithm T from
Section 2.2.3 of The Art of Computer Programming @cite["TAOCP"].


@section{Example}

As a simple application, we can topologically sort a sequence of
elements by feeding a @scheme[tqueue] all the dependency information.
We can then alternate the following steps until we exhaust the
@scheme[tqueue]:

@itemize{
  @item{Pop off a ready element.}
  @item{Tell the queue that we've satisfied the element.}
}

@examples[
(require (planet dyoo/tqueue))

(define a-tqueue (new-tqueue))

(tqueue-add! a-tqueue 'belt '(pants))
(tqueue-add! a-tqueue 'pants '(socks underwear))
(tqueue-add! a-tqueue 'shoes '(socks pants))
(tqueue-add! a-tqueue 'shirt '(underwear))
(tqueue-add! a-tqueue 'underwear '())
(tqueue-add! a-tqueue 'socks '())

(define (toposort a-tqueue)
  (let loop ()
    (let ([next-elt (tqueue-try-get a-tqueue)])
      (cond
        [next-elt
         (tqueue-satisfy! a-tqueue next-elt)
         (cons next-elt (loop))]
        [else
         '()]))))        

(toposort a-tqueue)
]


@section{API}


@defproc[(new-tqueue) tqueue?]{
Creates a new @scheme[tqueue].
}


@defproc[(tqueue? [datum any/c]) boolean?]{
Returns true if the datum is a @scheme[tqueue].
}


@defproc[(tqueue-add! [a-tqueue tqueue?] [elt any/c] [deps (listof any/c)]) any]{
Adds an elements and its list of dependencies to a @scheme[tqueue].

Elements and dependencies are allowed to be of any type.  Equality of
dependencies are compared by @scheme[eq?], not @scheme[equal?].
}


@defproc[(tqueue-satisfy! [a-tqueue tqueue?] [dep any/c]) any]{
Notifies the @scheme[tqueue] that a dependency has been satisfied.

Note: the effect of this applies prospectively to any elements
added in the future with @racket[tqueue-add!].  For example:
@interaction[
(require (planet dyoo/tqueue))
(let ([a-queue (new-tqueue)])
  (tqueue-satisfy! a-queue 'milk)
  (tqueue-satisfy! a-queue 'cookies)
  (tqueue-add! a-queue 'mouse '(cookies milk))
  (tqueue-try-get a-queue))
]
}


@defproc[(tqueue-get [a-tqueue tqueue?]) any/c]{
Returns the next element from a @scheme[tqueue].  Blocks if no element
is available.
}

@defproc[(tqueue-try-get [a-tqueue tqueue?]) (or/c any/c false/c)]{
Returns the next element from a @scheme[tqueue], or @scheme[#f] if no
element is available.
}

@defproc[(tqueue-ready-channel [a-tqueue tqueue?]) async-channel?]{
Provides low-level access to the @scheme[async-channel] that fills with
ready elements that have all their dependencies satisfied.
}


@section{Notes}

Be careful that the dependencies fed with @racket[tqueue-add!] and
satisfied with @racket[tqueue-satisfy!] are @racket[eq?].

For example,
the following interaction:
@interaction[
(require (planet dyoo/tqueue))
(let ([tqueue (new-tqueue)])
  (tqueue-add! tqueue "a" (list "b"))
  (tqueue-satisfy! tqueue (string-copy "b"))
  (tqueue-try-get tqueue))
]
shows that the use of @racket[tqueue-satisfy!] here does not satisfy
the dependency of @racket["a"], since it depends on a different @racket["b"].


Also, a @scheme[tqueue] will remember all dependencies that are passed by
@scheme[tqueue-satisfy!], so be careful if the @scheme[tqueue] is
long-lived, as it will continue to hold references in memory.



@bibliography{
  @bib-entry[#:key "TAOCP" 
             #:title "The Art of Computer Programming.  Volume 1: Fundamental Algorithms" 
             #:author "D. E. Knuth"
             #:location "Reading, Massachusetts: Addison-Wesley"
             #:date "1997"]{}
}
