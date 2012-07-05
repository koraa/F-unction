fs   = require 'fs'
util = require 'util'

dw = reqire '../dirwalker'

describe "Dirwalker", ->
    describe "Modifier" ->
        
        describe 'NOERR', ->
            beforeEach ->
                testF = dw.NOERR (x, err) -> return x, err
                testval = 23
                testerr = 42
                testthrow = null
                spyOn(util.error).andCall (x) -> testthrow = x

            it 'noerr', ->
                r = testF null, testval
                expect(r).toEqual testval
                expect(util.error).not.toHaveBeenCalled()

            it 'noerr', ->
                r = testF testerr , testval
                expect(r).toEqual testval
                expect(util.error).toHaveBeenCalled().
                expect(testthrow).toEqual testerr
           