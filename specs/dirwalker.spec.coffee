fs   = require 'fs'
util = require 'util'

dw = reqire '../dirwalker'

#######################################
# Util

#
# Add support for cascaded describes
# 
_describe = describe
describe = (p..., f) ->
    if p.length < 2
        _describe p[0], f
    else
        _describe p[0], (-> describe p[1..], f)

#
# Test for multiple datasets
# 
they = (mssg, data, arg...) ->
    if data instanceof Function
        [n, fun] = arg
        datagen = data
    else if data instanceof Array
        [fun] = arg
        n = data.length
        datagen = ((i) -> data[i])

    for i in [0..n]
        it mssg + " #" + i, (-> fun datagen i )

#######################################
# Test

describe "Dirwalker", "Modifier", ->
    describe 'NOERR', ->
        beforeEach ->
            f = dw.NOERR (x, err) -> return x, err
            val = 23
            err = 42
            thrown = null
            spyOn(util.error).andCall (x) -> thrown = x

        it 'noerr', ->
            r = f null, val
            expect(r).toEqual val
            expect(util.error).not.toHaveBeenCalled()

        it 'noerr', ->
            r = f err , val
            expect(r).toEqual val
            expect(util.error).toHaveBeenCalled().
            expect(thrown).toEqual err

    it 'Y', ->
        f = (x)->x
        expect(do dw.Y f).toEqual f

    they 'CONST', [null, 0, 1, true, false, "fnord"], (c) ->
        expect(do dw.CONST c).toEqual c

    describe "ARG", ->
        beforeEach ->
            f = (a...) -> a
            argo = [2,4,6,8, "foo"]
            argmod = [4, 6, 9 12, "bar"]
            