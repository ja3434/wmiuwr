using LinearAlgebra
using Polynomials
using Printf
using OffsetArrays
using FFTW
 
function emptyArray(type, size)
    return OffsetVector{type}(undef, 0:(size - 1))
end
 
function naive_cc(f, N)
    a = emptyArray(Float64, Int(N) + 1)
    for j in 0.0:1.0:N
        for k in 0.0:1.0:N
            u = cos(k * pi / N)
            uj = cos(j * k * pi / N)
            val = f(u) * uj
            if k == 0 || k == N
                val /= 2.0
            end
            a[Int(j)] += val
        end
    end
    return a * (2.0 / N)
end
 
function naive_approx(f, N)
    b = emptyArray(Float64, N)
    a = naive_cc(f, N)
    a[0] /= 2.0
    a[N] /= 2.0
 
    print(a)
    result = 0.0
 
    for k in 0:2:N
        result += a[k] / Float64(1 - k * k)
    end
    return result * 2.0
end
 
function naive_approx2(f, N)
    b = emptyArray(Float64, N)
    N = Float64(N)
    a = naive_cc(f, N)
    result = 0.0
 
    for k in 1:1:Int(floor(N / 2.0))
        b[2 * k - 1] = a[2 * k - 2] - a[2 * k]
        b[2 * k - 1] /= (Float64(k) * 4.0 - 2.0)
        result += b[2 * k - 1]
    end
    return result * 2.0
end
 
function smart_cc(f, N)
    x = [cos(pi * i / N) for i in 0:N]
    fx = f.(x) / (2 * N)
    g = real(fft(vcat(fx, fx[N:-1:2])))
    a = [g[1] * 2; g[2:N] + g[(2 * N):-1:(N + 2)]; g[N + 1] * 2]
    return a
end
 
function clenshaw_curtis_coeffs(f, N)
    x = [cos(pi * i / N) for i in 0:N]
    fx = f.(x) / (2 * N)
    g = real(fft(vcat(fx, fx[N:-1:2])))
    return [g[1]; g[2:N] + g[(2 * N):-1:(N + 2)]; g[N + 1]]
end

function clenshaw_curtis(f, N)
    a = clenshaw_curtis_coeffs(f, N)
    w = zeros(length(a))
    w[1:2:end] = 2 ./ (1 .- (0:2:N).^2 )
  # w oraz a są malejące, więc lepiej dodawać ich iloczyny od końca
    LinearAlgebra.dot(reverse(w), reverse(a))
end
 
global MAX_ITER = 2^18
 
function clenshaw_curtis_with_eps(f, eps)
    N = 4
    while N <= MAX_ITER
        res1 = clenshaw_curtis(f, N)
        res2 = clenshaw_curtis(f, N - 1)
        if abs(res1 - res2) < eps * res1 || N >= MAX_ITER
            return res1
        end
        N *= 2
    end
end
 
 
# zera n-tego wielomianu Czebyszewa
function chebyshev_nodes(n)
    return [cos((2.0 * k - 1.0) * pi / (2.0 * n)) for k in 1:n]
end
 
# kwadratura Czebyszewa-Gaussa 
# współczynniki stałe równe π/N
# węzły to zera n-tego wielomianu Czebyszewa
function gauss_chebyshev(f, N)
    x = chebyshev_nodes(N)
    res = 0.0
    for i in 1:N
        res += f(x[i]) * sqrt(1.0 - x[i] * x[i])
    end
    return res * pi / N
end
 
# kwadratura Gaussa-Legendre'a:
# współczynniki w_i = 2(q_1,i)^2, gdzie q_1,i to pierwsza współrzędna
# i-tego wektora własnego macierzy trójprzekątniowej
# węzły x_i to zera N-tego wielomianu Legendre'a
function gauss_legendre(f, N)
  # wyliczanie wartości i wektorów własnych macierzy trójprzekątniowej 
  # (Golub-Welsch algorithm)
  # wartości własne to zera wielomianu Legendre'a
    X, Q = eigen(SymTridiagonal(zeros(N), [n / sqrt(4.0n^2 - 1.0) for n = 1:N - 1]))
 
    res = 0.0
    for i in 1:N
        w = 2.0 * (Q[1, i])^2
        res += f(X[i]) * w
    end
 
    return res
end
 
# uruchamianie kwadratury dla funkcji f, N węzłów,
# na przedziale (a, b)
function quadrature(f, quadrature_fun, N=ITER, a=-1.0, b=1.0)
    return (b - a) / 2 * quadrature_fun(x -> f(x * (b - a) / 2 + (a + b) / 2), N)
end
    
# Testowanie-------------------------------------------------------------
 
funs = [exp, x -> 1.0 / ((x - 1.01) * (x - 1.01)), x -> 10x^4 + 4x^3 + 2x - 1, x -> cos(1000.0x),
        x -> (3x^2 + 4) / (x - 1.1), abs, x -> 1.0, x -> cos(100.0x) * cos(100.0x), x -> 1 / (x^4 + x^2 + 0.9),
        x -> 1.0 / (1.0 + x^4), x -> 2.0 / (2.0 + sin(10pi * x))]
 
# f - całka nieoznaczona
# obliczanie całki oznaczonej na przedziale (a, b)
function definete(f)
    return (a, b) -> f(b) - f(a)
end
 
 
# ręcznie policzone całki oznaczone (lub obliczone wyniki)
# dla testowanych funkcji
results = [definete(exp), definete(x -> 1.0 / (1.01 - x)), definete(x -> 2x^5 + x^4 + x^2 - x), definete(x -> sin(1000.0x) / 1000.0),
           definete(x -> 1.5x^2 + 3.3x + 7.63log(abs(x - 1.1))), definete(x -> (x >= 0) ? ((x^2) / 2.0) : (-(x^2) / 2.0)), definete(x -> x),
           definete(x -> (200.0x + sin(200.0x)) / 400.0), definete(x -> -0.278185log(x^2 - 0.947294x + 0.948683) + 
           0.278185log(x^2 + 0.947294x + 0.948683) + 0.309633atan(0.587487 * (2x - 0.947294)) + 0.309633atan(0.587487 * (2.0x + 0.947294))),
           definete(x -> 1.0 / (4.0 * sqrt(2)) * (-log(abs(x^2 - sqrt(2)x + 1)) + log(abs(x^2 + sqrt(2)x + 1)) - 2.0atan(1 - sqrt(2)x)
           + 2.0atan(1 + sqrt(2)x))), (a, b) -> 4.0 / sqrt(3)]
 
 
function rel_error(a, b)
    return abs((a - b) / a)
end
 
function test(quadrature_fun, fun_nr, a=-1.0, b=1.0, N=ITER)
    my_res = quadrature(funs[fun_nr], quadrature_fun, N, a, b)
    rel_e = rel_error(results[fun_nr](a, b), my_res)
    abs_e = abs(results[fun_nr](a, b) - my_res)
 
    return (rel_e, abs_e)
end

function print_coefficients_of_cc(f, N, ile_pierwszych)
    a = clenshaw_curtis_coeffs(f, N)
    for i in 1:ile_pierwszych
        # println(string(i - 1, " & ", a[i], " \\\\"))
        @printf("%d & %.20f \\\\\n", i - 1, a[i])
    end
end