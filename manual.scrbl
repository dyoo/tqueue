#lang scribble/doc
@(require scribble/manual
          (for-label "tqueue.ss"))


@title{tqueue: a queue-like data structure for elements with
topologicial sorting.}

@defmodule[(planet dyoo/tqueue:1/tqueue)]

@scheme[tqueue] provides a data structure for elements that have
dependencies.  It keeps track of known satisfied dependencies; any
elements whose dependencies are all satisifed are allowed to pop off a
tqueue.


@section{Example}

We can topologically sort elements by feeding a tqueue all the
dependencies.  We then alternate the popping of ready elements with
the notification of that element's satisfaction back to the tqueue.


(define a-tqueue (new-tqueue))
(tqueue-add! a-tqueue 'belt '(pants))            ;; pants before belt
(tqueue-add! a-tqueue 'pants '(socks underwear)) ;; socks before pants, and
                                                 ;; underwear before pants
(tqueue-add! a-tqueue 'shoes '(socks))           ;; socks before shoes
(tqueue-add! a-tqueue 'shirt '(underwear))       ;; underwear before shirt




@section{API}

Elements and dependencies are allowed to be of any type.  Equality of
dependencies are compared by @scheme[eq?].


@defproc[(new-tqueue) tqueue?]{
Creates a new tqueue.
}


@defproc[(tqueue? [datum any/c]) boolean?]{
Returns true if the datum is a tqueue.
}


@defproc[(tqueue-add! [a-tqueue tqueue?] [elt any/c]) any]{
Adds an elements and its list of dependencies to a tqueue.
}

@defproc[(tqueue-satisfy! [a-tqueue tqueue?] [dep any/c]) any]{
Notifies the queue that a dependency has been satisfied.
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



@section{References}
Knuth, D. E.  The Art of Computer Programming