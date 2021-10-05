using Printf
 
# stałe dla CORDIC'A
global C_ITERATIONS = 30
global CORDIC_MUL_POW = 30
global CORDIC_MUL = 2.0^CORDIC_MUL_POW
global CORDIC_ATANS = [843314857, 497837829, 263043837, 133525159, 67021687, 33543516, 16775851,
                8388437, 4194283, 2097149, 1048576, 524288, 262144, 131072, 65536, 32768, 16384, 8192, 4096,
                2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2]
global CORDIC_F = 1768195363
global CORDIC_F_INV = 652032874
 
# stałe dla obliczania szeregiem Taylora
global T_ITERATIONS = 15
global HYPERBOLIC_MAX = 1
 
# liczenie szeregu Taylora
function series(x, parity, change_sign, iterations)
    res = zero(x)
    elem = one(x)
    if parity == 1
        elem = x
    end
    i = parity + 1
    while i <= 2*iterations + parity
        res += elem
        elem *= change_sign*x*x/(i*(i+1))
        i += 2
    end
    return res
end
 
# generyczna funkcja stosująca wzory redukcyjne, licząca sin(x)
# za pomocą podanych funkcji sin_fun, cos_fun 
function gen_sin(x, iterations, sin_fun, cos_fun)
    # sin(-x) = sin(x)
    if x < 0
        return -gen_sin(-x, iterations, sin_fun, cos_fun)
    end
    x = mod2pi(x)
    # sin(π + x) = -sin(x)
    if x > pi
        return -gen_sin(x-pi, iterations, sin_fun, cos_fun)
    end
    # sin(π/2 + x) = cos(x)
    if x > pi/2
        return gen_cos(x-pi/2, iterations, sin_fun, cos_fun)
    end
    # sin(π/2 - x) = cos(x)
    if x > pi/4
        return gen_cos(pi/2-x, iterations, sin_fun, cos_fun)
    end
    return sin_fun(x, iterations)
end
 
# generyczna funkcja stosująca wzory redukcyjne, licząca cos(x)
# za pomocą podanych funkcji sin_fun, cos_fun 
function gen_cos(x, iterations, sin_fun, cos_fun)
    # cos(-x) = cos(x)
    if x < 0
        return gen_cos(-x, iterations, sin_fun, cos_fun)
    end
    x = mod2pi(x)
    # cos(π + x) = -cos(x)
    if x > pi
        return -gen_cos(x-pi, iterations, sin_fun, cos_fun)
    end
    # cos(π/2 + x) = -sin(x)
    if x > pi/2
        return -gen_sin(x-pi/2, iterations, sin_fun, cos_fun)
    end
    # cos(π/2 - x) = sin(x)
    if x > pi/4
        return gen_sin(pi/2-x, iterations, sin_fun, cos_fun)
    end
    return cos_fun(x, iterations)
end
 
# sin dla liczb rzeczywistych [Taylor]
function real_sin(r, iterations)
    return series(r, 1, -1, iterations)
end
 
# cos dla liczb rzeczywistych [Taylor]
function real_cos(r, iterations)
    return series(r, 0, -1, iterations)
end
 
# sinh [Taylor]
function real_sinh(r, iterations)
    # sinh(1000) jest za duży by reprezentować go we Float64
    if r > 1000
        return Inf
    end
    if r < -1000
        return -Inf
    end
    if r == 0
        return Float64(0)
    end
    # dla dużych liczb korzystamy ze wzoru:
    # sinh(2r) = 2 * cosh(r) * sinh(r)
    if abs(r) > HYPERBOLIC_MAX
        return 2*real_sinh(r/2, iterations)*real_cosh(r/2, iterations)
    end
    return series(r, 1, 1, iterations)
end
 
# cosh [Taylor]
function real_cosh(r, iterations)
    # cosh(1000) jest za duży by reprezentować go we Float64
    if abs(r) > 1000
        return Inf
    end
    if r == 1
        return Float64(1)
    end
    # dla dużych liczb korzystamy ze wzoru:
    # cosh(2r) = cosh(r)^2 + sinh(r)^2
    if abs(r) > HYPERBOLIC_MAX
        s = real_sinh(r/2, iterations)
        c = real_cosh(r/2, iterations)
        return s*s+c*c
    end
    return series(r, 0, 1, iterations)
end
 
# sin dla liczb zespolonych [Taylor]
function complex_sin(a, b, iterations)
    # sin(a + bi) = sin(a) * cosh(b) + i(cos(a) * sinh(b))
    return (gen_sin(a, iterations, real_sin, real_cos)*real_cosh(b, iterations), 
            gen_cos(a, iterations, real_sin, real_cos)*real_sinh(b, iterations)) 
end
 
# cos dla liczb zespolonych [Taylor]
function complex_cos(a, b, iterations)
    # cos(a + bi) = cos(a) * cosh(b) - i(sin(a) * sinh(b))
    return (real_cos(a, iterations)*real_cosh(b, iterations),
            -real_sin(a, iterations)*real_sinh(b, iterations))
end
 
# funkcja sin dla użytkownika [Taylor]
function taylor_sin(a, b)
    return complex_sin(a, b, T_ITERATIONS)
end
 
# funkcja cos dla użytkownika [Taylor]
function taylor_cos(a, b)
    return complex_cos(a, b, T_ITERATIONS)
end
 
# funkcja sinh dla użytkownika [Taylor]
function taylor_sinh(r)
    return real_sinh(r, T_ITERATIONS)
end
 
# funkcja cosh dla użytkownika [Taylor]
function taylor_cosh(r)
    return real_cosh(r, T_ITERATIONS)
end
 
# preprocesing [CORDIC]
function preprocess_atan(iterations)
    global CORDIC_MUL
    atan2pow = Array{Float64}(undef, iterations)
    @printf("CORDIC_ATANS = [")
    for i in 1:iterations
        atan2pow[i] = round(atan(1.0 / Float64(BigInt(2)^(i - 1))) * CORDIC_MUL)
        @printf("%d", atan2pow[i])  
        if i < iterations
            @printf(", ")
        end
    end
    @printf("]\n")
end
 
 
# preprocesing [CORDIC]
function preprocess_scaling_factor(iterations)
    CORDIC_F = 1.0
    for i in 0:iterations
        CORDIC_F *= sqrt(1. + 1. / Float64(BigInt(2)^(2 * i)))
    end
    @printf("CORDIC_F = %d\nCORDIC_F_INV = %d\n", round(CORDIC_F * CORDIC_MUL), round(CORDIC_MUL / CORDIC_F))
end
 
 
# funkcja licząca zarówno cosx oraz sinx algorytmem CORDIC
function approx_trig(x, iterations)
    global CORDIC_ATANS
    global CORDIC_F_INV
    X = CORDIC_F_INV
    Y = 0
    Z = round(x * CORDIC_MUL)
    s = 1
    # Proces iteracyjny algorytmu CORDIC
    for i in 0:(iterations - 1)
        tempX = X
        if Z == 0
            break
        end
        if Z >= 0
            X -= s * (Y >> i)
            Y += s * (tempX >> i)
            Z -= s * CORDIC_ATANS[i + 1]
        else
            X += s * (Y >> i)
            Y -= s * (tempX >> i)
            Z += s * CORDIC_ATANS[i + 1]
        end
    end
 
    return (Float64(X) / CORDIC_MUL, Float64(Y) / CORDIC_MUL)
end
 
# wyciąganie sin z approx_trig [CORDIC] 
function approx_sin(x, iterations)
    return approx_trig(x, iterations)[2]
end
 
 
# wyciąganie cos z approx_trig [CORDIC]
function approx_cos(x, iterations)
    return approx_trig(x, iterations)[1]
end
 
# funkcja sin dla użytkownika [CORDIC]
function cordic_sin(x)
    return gen_sin(x, C_ITERATIONS, approx_sin, approx_cos)
end
 
# funkcja cos dla użytkownika [CORDIC]
function cordic_cos(x)
    return gen_cos(x, C_ITERATIONS, approx_sin, approx_cos)
end
 
# uruchamianie preprocesingu [CORDIC]
# funkcja wypisuje kod w języku Julia na ekran, który potem po prostu wkleiliśmy do pliku źródłowego
# oblicza stałe potrzebne do obliczania funkcji trygonometrycznych metodą CORDIC
function preprocess_cordic()
    println("Preprocessing CORDIC constants.")
    preprocess_atan(CORDIC_MUL_POW)
    preprocess_scaling_factor(CORDIC_MUL_POW)
end
 
# sinh bez stosowania wzorów redukcyjnych [Taylor]
function sinh_no_reduction(x, iterations)
    return series(x, 1, 1, iterations)
end
 
# cosh bez stosowania wzorów redukcyjnych [Taylor]
function cosh_no_reduction(x, iterations)
    return series(x, 0, 1, iterations)
end
 
# sin bez stosowania wzorów redukcyjnych [Taylor]
function taylor_sin_no_reduction(x, y)
    # sin(a + bi) = sin(a) * cosh(b) + i(cos(a) * sinh(b))
    # wykonujemy odpowiednio (10a + 10), (10b + 10) iteracji - szereg Tylora
    # powinien dobrze przybliżać funkcje trygonometryczne dla takiej liczby wyrazów
    return (real_sin(x, 10*round(x)+10) * cosh_no_reduction(y, 10*round(y)+10),
            real_cos(x, 10*round(x)+10) * sinh_no_reduction(y, 10*round(y)+10))
end
 
# zmiana liczby iteracji [Taylor]
function set_taylor_iterations(x)
    global T_ITERATIONS = x    
end
 
# zmiana liczby iteracji [CORDIC]
function set_cordic_iterations(x)
    global C_ITERATIONS = x    
end