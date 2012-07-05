#
# File:   dirwalker.coffee
# Author: Karolin Varner
# Date:   7/1/2012
#
# This file provides a lib for asynchroniously walking directories.
# 
##########################################################
#
# This file is part of PinkText.
#
# PinkText is free software: you can redistribute it and/or modify
# it under the terms of the Lesser GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# PinkText is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# Lesser GNU General Public License for more details.
#
# You should have received a copy of the Lesser GNU General Public License
# along with PinkText.  If not, see <http://www.gnu.org/licenses/>.
#

fs   = require 'fs'
path = require 'path'
util = require 'util'

#
#

##############################
# F Transformer
#
# These functions (modifyiers) transform other functions
#
# The FUT (future) versions work for nonblocking code like the one used in the testers.
# 

#
# - Print the first value if it is truuthy
# - Left-shift the arguments by 1 (move the first arg to the end)
# 
noerr = (err, f) ->
    (err, a...) ->
        util.error err if err
        f a..., err

#
# - Modyfy the arguments, so that the first argument always the function itself
# 
Y = (f) ->
    (a...) -> f f, a...

#
# Generates a Function that allways returns the given value
# 
CONST = (x) -> (->x)

#
# IF x is a function returns x
# otherwise creates a constant function from x
# 
GEN_F = (x) ->
    f if x instanceof Function
    CONST x

#
# - Reset the arguments of a Function
#
SETARG = (f, a...) ->
    (-> f a...)

#
# Always appends the given arguments to the end of the arg list
# 
APPARG = (f, a1...) ->
    (a2...) -> f a2..., a1...

#
# Always prepends the given arguments to the end of the arg list
# 
PREPARG = (f, a1...) ->
    (a2...) -> f a1..., a2...

#
# Returns the boolean-inverted value
#
FUT_NOT = (f) ->
    (a..., Yf, Nf) -> f a..., Nf, Yf
NOT = (f) ->
    (a...) -> ! f a...

#
# Takes a list of functions and returns true if all return values are truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
FUT_ALL = (Lf...) ->
    (a..., final) ->
        cnt = 1
        collect = ->
            cnt++
            final if cnt >= Lf.length
        cond a..., collect for cond in Lf    
ALL = (Lf...) ->
    (a...) ->
        return false for f in Lf where not GEN_F f a...
        true

#
# Takes a list of functions and returns true if any return value is truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
#
# Takes a list of functions and returns true if all return values are truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
FUT_ANY = (Lf...) ->
    (a..., final) ->h
        cond a..., final for cond in Lf    
ANY = (Lf...) ->
    (a...) ->
        return true for f in Lf where GEN_F f a...
        false

#
# Takes a list of functions and returns true if all return values are falsey
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
FUT_NONE = (Lf...) -> FUT_NOT FUT_ANY Lf...
NONE = (Lf...) -> NOT ANY Lf...

###############################
# TESTER

isDir = noerr (o, Yf, Nf) ->
    fs.stat noerr (stat) ->
        if stat.isDirectory()
            do Yf
        else
            do Nf

isFile = FUT_NOT isDir

nameMatch = (n, p, Yf, Nf) ->
    if n.match p
        do Yf
    else
        do Nf

###############################
# Fun

walk_dir = (dir, preq, f) ->
    fs.readdir noerr (files) ->
        util.error err if err
        for o in files
            preq  o, f
            isDir o, SETARG walk_dir, o, preq, f

###############################
# Export