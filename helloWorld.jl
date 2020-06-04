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
        ifExprC
        thenExprC
        elseExprC
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

function interp(ExprC)
        1+1
end

@test interp(numC(5)) == numV(5)
@test interp(strC(5)) == strV("hello")
@test interp(AppC(idC("equal")), [(numC(5)), numC(100)]) == boolV(false)
