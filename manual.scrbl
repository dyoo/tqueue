#lang scribble/doc
@(require scribble/manual)
@(require (for-label "tqueue.ss"))
@title{tqueue: a queue-like topological-sort data structure.}

tqueue provides a queue-like data structure for elements that have
dependencies.  It keeps track of the known satisfied dependencies; any
elements whose dependencies are all satisifed are allowed to pop off a
tqueue.
