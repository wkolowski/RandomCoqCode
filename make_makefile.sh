#!/bin/sh

coq_makefile -R "." RandomCoqCode -o makefile Sorting/*v Reification/*v Trees/* Ord/*
