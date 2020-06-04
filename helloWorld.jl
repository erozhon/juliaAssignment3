#is this an import?
using Test
#this is a comment

# master plan
# 1: make the data structures
# 2: pass them into stuff
# 3: interp the things
# 4: ???
# 5 : profit

#EXPRC TYPES, no idea how to make them reference each other explicity, maybe it doesn't matter!
struct numC
        number
end
struct strC
        string
end
struct AppC
        f
        argC
end
struct ifC
        testC
        thenC
        elseC
end
struct idC
        idSymbol
end
struct lamC
        argExprC
        bodyExprc
end

#environment stuff
struct numV
        number
end
struct boolV
        b
end
struct closV
        param
        bodyC
        environment
end
struct primV
        op
end
struct strV
        string
end

struct binding
        name
        val
end
#big environment
struct topenvironment
        #hard initialize this?
        listOfBindings
end

TopEnv = topenvironment([binding("true", boolV(true)), binding("false", boolV(false)),
                binding("+", primV("+")), binding("-", primV("-")),
                binding("*", primV("*")), binding("/", primV("/")),
                binding("<=", primV("<=")), binding("equal?", primV("equal?"))])

function lookup(sym, env)
        for bind in env.listOfBindings
                if bind.name == sym
                        return bind.val
                end
        end
        error("you broke the environment")
end

function interp(expr, env)
        if isa(expr, numC)
                return numV(expr.number)
        elseif isa(expr, strC)
                return strV(expr.string)
        elseif isa(expr, idC)
                return lookup(expr.idSymbol, env)
        elseif isa(expr, ifC)
                testResult = interp(expr.testC, env)
                if isa(testResult, boolV)
                        if testResult.b
                                return interp(expr.thenC, env)
                        else
                                return interp(expr.elseC, env)
                        end
                else
                        error("not a boolean")
                end
        elseif isa(expr, AppC)
                fn = interp(expr.f, env)
                argval = interpArgs(expr.argC, env)
                if isa(fn, closV)
                        newEnv = extendEnv(fn.environment, fn.param, argval)
                elseif isa(fn, primV)
                        op = fn.op
                        #INDEXING STARTS AT 1 BECAUSE FUCK YOU
                        #TODO all of the stuff below
                        if op == "+"
                                return argval[0] + argval[1]
                        elseif op == "-"
                                return argval[0] + argval[1]
                        elseif op == "*"
                                return argval[0] * argval[1]
                        elseif op == "/"
                                if argval[1] != 0
                                        return argval[0] / argval[1]
                                else
                                        error("div 0 error")
                                end
                        elseif op == "<="
                                return argval[0] <= argval[1]
                        elseif op == "equal?"
                                return checkEqual(argval)
                        end
                else
                        error("bad format")
                end
        elseif isa(expr, lamC)
                return closV(expr.argExprC, expr.bodyExprC, env)
        else
                error("you broke interp")
        end
end

function checkEqual(argval)
        println(argval)
        f = argval[1]
        s = argval[2]
        if (isa(f, numV) && isa(s, numV))
                if s.number == f.number
                        return boolV(true)
                else
                        return boolV(false)
                end
        elseif (isa(f, strV) && isa(s, strV))
                if s.string == f.string
                        return boolV(true)
                else
                        return boolV(false)
                end
        elseif (isa(f, boolV) && isa(s, boolV))
                if f.b == s.b
                        return boolV(true)
                else
                        return boolV(false)
                end
        else
                return boolV(false)
        end
end

function extendEnv(env, name, value)
        if empty!(name) && !(empty!(value))
                error("wrong number of args")
        elseif length(name) != length(value)
                return env
        elseif empty!(name) && empty!(value)
                return env
        else
                newEnv = []
                for nv in zip(name,value)
                        append!(newEnv, binding(nv[0], nv[1]))
                end
                return newEnv
        end
end

function interpArgs(argsList, env)
        toReturn = []
        for a in argsList
                append!(toReturn, [interp(a, env)])
        end
        return toReturn
end

#TODO more tests
@testset "the only set" begin
        @test interp(numC(5), TopEnv) == numV(5)
        @test interp(strC("hello"), TopEnv) == strV("hello")
        @test interp(AppC(idC("equal?"), [numC(5), numC(100)]), TopEnv) == boolV(false)
end;
