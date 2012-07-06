#
# File:   F.coffee
# Author: Karolin Varner
# Date:   7/5/2012
#
# This file provides a lib for better working with functions
# 
##########################################################
#
# This file is part of F/unction.
#
# F/unction is free software: you can redistribute it and/or modify
# it under the terms of the Lesser GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# F/unction is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# Lesser GNU General Public License for more details.
#
# You should have received a copy of the Lesser GNU General Public License
# along with F/unction.  If not, see <http://www.gnu.org/licenses/>.
#
############################################################
#
# Concepts:
#    Modifiers:
#        Modifiers are functions that modify other functions
#

util = require 'util'

##############################
# Constants

Fnull   = -> null
Ftrue   = -> true
Ffalse  = -> false
Fproxy  = (a...) -> a
Fproxy1 = (x)    -> x

##############################
# Modifiers

#
# - Print the first value if it is truuthy
# - Left-shift the arguments by 1 (move the first arg to the end)
# 
NOERR = (f) ->
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
CONST = (x) ->
    (->x)

#
# IF x is a function returns x
# otherwise creates a constant function from x
# 
GEN_F = (x) ->
    return x if x instanceof Function
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
NOT = (f) ->
    (a...) -> ! f a...

#
# Takes a list of functions and returns true if all return values are truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
ALL = (Lf...) ->
    (a...) ->
        return false for f in Lf when not (GEN_F f) a...
        true

#
# Takes a list of functions and returns true if any return value is truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
#
# Takes a list of functions and returns true if all return values are truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
# It Returns false for an empty list
#
ANY = (Lf...) ->
    (a...) ->
        return true for f in Lf when (GEN_F f) a...
        false

#
# Takes a list of functions and returns true if all return values are falsey
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
# It returns true for an empty list
#
NONE = (Lf...) -> NOT ANY Lf...

#
# Processing pipline:
# Takes a list of functions ans sequentially invokes the function with the
# result from the last fun
# The first pipe element might be not a function,
# in which case it will just be used as input for the next function
#
PIPE = (Fl...) ->
    (a...) ->
        Fl[1..].reduce ((o, f) -> f o),
                       Fl[0] a... # First one is a special case: invoke with all args

###############################
# Util

#
# Just like the do keyword,
# but treates the last arg as the function, not the first.
# 
dor = (a..., f) -> f a...

###############################
# Export

module.exports.Fnull   = Fnull
module.exports.Ftrue   = Ftrue
module.exports.Ffalse  = Ffalse
module.exports.Fproxy  = Fproxy
module.exports.Fproxy1 = Fproxy1


module.exports.NOERR = NOERR

module.exports.Y  = Y

module.exports.CONST = CONST
module.exports.GEN_F = GEN_F

module.exports.SETARG  = SETARG
module.exports.APPARG  = APPARG
module.exports.PREPARG = PREPARG

module.exports.NOT = NOT

module.exports.ALL = ALL

module.exports.ANY = ANY

module.exports.NONE = NONE

module.exports.PIPE = PIPE



module.exports.dor = dor