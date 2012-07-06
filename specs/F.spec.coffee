fs   = require 'fs'
util = require 'util'

F = require '../F'

#######################################
# Util
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

describe "F", ->
    describe "Modifier", ->

        describe 'NOERR', ->
            _ = {}
            beforeEach ->
                _.f = F.NOERR (x, err) -> x
                _.val = 23
                _.err = 32
                _.thrown = null
                
                spyOn(util, 'error').andCallFake (x) ->
                    _.thrown = x

            it 'Y noerr', ->
                r = _.f null, _.val
                expect(r         ).toEqual _.val
                expect(util.error).not.toHaveBeenCalled()

            it 'ERR noerr', ->
                r = _.f _.err , _.val
                expect(r          ).toEqual _.val
                expect(util.error ).toHaveBeenCalled()
                expect(_.thrown).toEqual _.err

        it 'Y', ->
            f = (x)->x
            expect(do F.Y f).toEqual f

        they 'CONST', [null, 0, 1, true, false, "fnord", (->)], (c) ->
            expect(do F.CONST c).toEqual c

        they 'GEN_F', [null, 0, 1, true, false, "fnord"], (c) ->
            expect(do F.GEN_F c).toEqual c
            expect(do F.GEN_F F.CONST c).toEqual c

        describe "ARG", ->
            _ = {}
            beforeEach ->
                _.f = (a...) -> a
                _.argo = [2,4,6,8, "foo"]
                _.argmod = [4, 6, 9, 12, "bar"]

            it 'REF', ->
                expect(_.f _.argo...).toEqual _.argo

            it 'SET', ->
                expect((F.SETARG _.f, _.argmod...) _.argo...).toEqual _.argmod

            it 'APP', ->
                expect((F.APPARG _.f, _.argmod...) _.argo...).toEqual _.argo.concat _.argmod

            it 'PREP', ->
                expect((F.PREPARG _.f, _.argmod...) _.argo...).toEqual _.argmod.concat _.argo

        it 'NOT', ->
            expect(do F.NOT F.Ftrue).toEqual  false
            expect(do F.NOT F.Ffalse).toEqual true
            expect((F.NOT F.Fproxy1) true).toEqual  false
            expect((F.NOT F.Fproxy1) false).toEqual true

        it 'ALL', ->
           expect(do F.ALL()).toEqual true
        
           expect(do F.ALL true).toEqual true
           expect(do F.ALL F.Ftrue).toEqual true

           expect(do F.ALL false).toEqual false
           expect(do F.ALL F.Ffalse).toEqual false

           expect(do F.ALL true, F.Ftrue).toEqual true
           expect(do F.ALL true, F.Ftrue, false).toEqual false

        it 'ANY', ->
           expect(do F.ANY()).toEqual false
        
           expect(do F.ANY true).toEqual true
           expect(do F.ANY F.Ftrue).toEqual true

           expect(do F.ANY false).toEqual false
           expect(do F.ANY F.Ffalse).toEqual false

           expect(do F.ANY true, F.Ftrue).toEqual true
           expect(do F.ANY true, F.Ftrue, false).toEqual true

           expect(do F.ANY false, F.Ffalse).toEqual false
           expect(do F.ANY F.Ftrue, F.Ffalse, false).toEqual true

        it 'NONE', ->
           expect(do F.NONE()).toEqual true
        
           expect(do F.NONE true).toEqual false
           expect(do F.NONE F.Ftrue).toEqual false

           expect(do F.NONE false).toEqual true
           expect(do F.NONE F.Ffalse).toEqual true

           expect(do F.NONE true, F.Ftrue).toEqual false
           expect(do F.NONE true, F.Ftrue, false).toEqual false

           expect(do F.NONE false, F.Ffalse).toEqual true
           expect(do F.NONE F.Ftrue, F.Ffalse, false).toEqual false