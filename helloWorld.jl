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
        bodyExprC
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
                        return interp(fn.bodyC, newEnv)
                elseif isa(fn, primV)
                        op = fn.op
                        if op == "+"
                                return numPlus(argval)
                        elseif op == "-"
                                return numMinus(argval)
                        elseif op == "*"
                                return numMult(argval)
                        elseif op == "/"
                                return numDiv(argval)
                        elseif op == "<="
                                return lessEqual(argval)
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

function numPlus(argval)
        f = argval[1]
        s = argval[2]
        if (isa(f, numV) && isa(s, numV))
                return numV(f.number + s.number)
        else
                error("wrong type")
        end
end

function numMinus(argval)
        f = argval[1]
        s = argval[2]
        if (isa(f, numV) && isa(s, numV))
                return numV(f.number - s.number)
        else
                error("wrong type")
        end
end
function numMult(argval)
        f = argval[1]
        s = argval[2]
        if (isa(f, numV) && isa(s, numV))
                return numV(f.number*s.number)
        else
                error("wrong type")
        end
end

function numDiv(argval)
        f= argval[1]
        s = argval[2]
        if (isa(f, numV) && isa(s, numV))
                if s.number == 0
                        error("attempting to divide by 0")
                else
                        return numV(f.number/s.number)
                end
        end
end

function lessEqual(argval)
        f = argval[1]
        s = argval[2]
        if (isa(f, numV) && isa(s, numV))
                if (f.number <= s.number)
                        return boolV(true)
                else
                        return boolV(false)
                end
        else
                error("one comparison not a number")
        end
end
function checkEqual(argval)
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
        if isempty(name) && !(isempty(value))
                error("wrong number of args")
        elseif length(name) != length(value)
                return env
        elseif isempty(name) && isempty(value)
                return env
        else
                for nv in zip(name,value)
                        push!(env.listOfBindings, binding(nv[1], last(nv)))
                end
                return env
        end
end

function interpArgs(argsList, env)
        toReturn = []
        for a in argsList
                append!(toReturn, [interp(a, env)])
        end
        return toReturn
end

@testset "the only set" begin
        @test interp(numC(5), TopEnv) == numV(5)
        @test interp(strC("hello"), TopEnv) == strV("hello")
        @test interp(AppC(idC("equal?"), [numC(5), numC(100)]), TopEnv) == boolV(false)
        @test interp(AppC(lamC(["f"], numC(10)), [numC(2)]), TopEnv) == numV(10)

        @test interp(AppC(lamC(["minus"], AppC(idC("minus"), [numC(8), numC(5)])),
                        [lamC(["a", "b"], AppC(idC("+"), [idC("a"),
                                AppC(idC("*"), [numC(-1), idC("b")])]))]), TopEnv) == numV(3)

        @test_throws ErrorException interp(AppC(idC("/"), [numC(1), numC(0)]), TopEnv)
end;
