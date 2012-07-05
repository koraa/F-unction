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
#    Future Modifiers:
#        Futures are Proxy-Objects for information that is not computed yet.
#        Future Modifiers are Modifiers that can operate on information that is not computed yet,
#        more exact: Asynchronous/Callback Style/Asynchronous Functions.
#        Explicit Future-Style Functions defined by adding a FUT proprtty with
#        the future style function.
#        Future Style Functions should be used by invokeing F.FUT $function_name,
#        it also works for functions without future style definitions, in wich case the
#        the return value will be used to simulate a future-style function.
#        

util = require 'util'

##############################
# Constants

Fnull   = ->
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
NOERR = (err, f) ->
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
NOT = (f) ->
    (a...) -> ! f a...
NOT.FUT = (f) ->
    (a..., Yf=Fnone, Nf=Fnone) -> f a..., Nf, Yf

#
# Takes a list of functions and returns true if all return values are truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
ALL = (Lf...) ->
    (a...) ->
        return false for f in Lf where not GEN_F f a...
        true
ALL.FUT = (Lf...) ->
    (a..., final) ->
        cnt = 1
        collect = ->
            cnt++
            final if cnt >= Lf.length
        cond a..., collect for cond in Lf    

#
# Takes a list of functions and returns true if any return value is truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
#
# Takes a list of functions and returns true if all return values are truuthy
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
ANY = (Lf...) ->
    (a...) ->
        return true for f in Lf where GEN_F f a...
        false
ANY.FUT = (Lf...) ->
    (a..., final) ->h
        cond a..., final for cond in Lf    

#
# Takes a list of functions and returns true if all return values are falsey
# Non-functions are treated as constant functions (there boolen value is used instad of ther return value)
#
NONE = (Lf...) -> NOT ANY Lf...
NONE.FUT = (Lf...) -> FUT_NOT FUT_ANY Lf...

#
# This is a MODIFIER that generates a Asynchronous (callback) API
# for originally synchronus functions
# 
FUT = (f) ->
    f.FUT if f.FUT?

    (a..., , Yf=Fnull, Nf=Fnull) ->
        if do f
            do Yf
        else
            do Nf

###############################
# Export

module.exports.Fnull  = Fnull
module.exports.Ftrue  = Ftrue
module.exports.Ffalse = Ffalse

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

module.exports.GEN_FUT = GEN_FUT