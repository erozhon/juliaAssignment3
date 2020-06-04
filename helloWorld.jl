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


@test interp("5") == 5
@test interp("hello") == "hello"
