#is this an import?
using Test
#this is a comment
println("hello, world");

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
        fExprC
        argExprCList
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
        argExprCList
        bodyExprC
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
        for bind in env
                if bind.name == sym
                        return bind.val
                end
        end
        error("you broke the environment")

# for now we are pretending we have a main that will handle error cases (i.e -1)
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
                return #a whole thing
        elseif isa(expr, lamC)
                return closV(expr.argExprC, expr.bodyExprC, env)
        else
                error("you broke interp")
        end
end


@testset "the only set" begin
        @test interp(numC(5), TopEnv) == numV(5)
        @test interp(strC(5), TopEnv) == strV("hello")
        @test interp(AppC(idC("equal"), [numC(5), numC(100)]), TopEnv) == boolV(false)
end;
