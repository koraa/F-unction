0fs   = require 'fs'
util = require 'util'

F = reqire '../dirwalker'

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

describe "F" ->
    describe "Modifier", ->

        describe 'NOERR', ->
            beforeEach ->
                f = F.NOERR (x, err) -> return x, err
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
            expect(do F.Y f).toEqual f

        they 'CONST', [null, 0, 1, true, false, "fnord", (->)], (c) ->
            expect(do F.CONST c).toEqual c

        they 'GEN_F', [null, 0, 1, true, false, "fnord"], (c) ->
            expect(do F.GEN_F c).toEqual c
            expect(do F.GEN_F F.CONST c).toEqual c

        describe "ARG", ->
            beforeEach ->
                f = (a...) -> a
                argo = [2,4,6,8, "foo"]
                argmod = [4, 6, 9 12, "bar"]

            it 'REF', ->
                expect(f argo...).toEqual argo

            it 'SET', ->
                expect((F.SETARG f, argmod...) argo...).toEqual argmod

            it 'APP', ->
                expect((F.APPARG f, argmod...) argo...).toEqual argo.concat argmod

            it 'PREP', ->
                expect((F.APPARG f, argmod...) argo...).toEqual argmod.concat argo

        it 'NOT', ->
            expect(do F.NOT F.Ftrue).toEqual  false
            expect(do F.NOT F.Ffalse).toEqual true
            expect(do F.NOT F.Fproxy1, true).toEqual  false
            expect(do F.NOT F.Fproxy1, false).toEqual true

        it 'ALL', ->
           expect(do F.ALL).toEqual true
        
           expect(do F.ALL true).toEqual true
           expect(do F.ALL F.Ftrue).toEqual true

           expect(do F.ALL false).toEqual false
           expect(do F.ALL F.Ffalse).toEqual false

           expect(do F.ALL true, F.Ftrue).toEqual true
           expect(do F.ALL true, F.Ftrue, false).toEqual false

        it 'ANY', ->
           expect(do F.ANY).toEqual true
        
           expect(do F.ANY true).toEqual true
           expect(do F.ANY F.Ftrue).toEqual true

           expect(do F.ANY false).toEqual false
           expect(do F.ANY F.Ffalse).toEqual false

           expect(do F.ANY true, F.Ftrue).toEqual true
           expect(do F.ANY true, F.Ftrue, false).toEqual true

           expect(do F.ANY false, F.Ffalse).toEqual false
           expect(do F.ANY F.true, F.Ffalse, false).toEqual true

        it 'NONE', ->
           expect(do F.ANY).toEqual false
        
           expect(do F.ANY true).toEqual false
           expect(do F.ANY F.Ftrue).toEqual false

           expect(do F.ANY false).toEqual true
           expect(do F.ANY F.Ffalse).toEqual true

           expect(do F.ANY true, F.Ftrue).toEqual false
           expect(do F.ANY true, F.Ftrue, false).toEqual false

           expect(do F.ANY false, F.Ffalse).toEqual true
           expect(do F.ANY F.true, F.Ffalse, false).toEqual false