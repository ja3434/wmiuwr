module taylor
using Base
using Printf
 
ITER = 12
HYPERBOLIC_MAX = 0.2
 
function series(x, parity, change_sign, iterations)
    elements = ones(Float64, 2 * iterations)
    res = 0.0
    i = 2
    while i <= 2 * iterations + parity - 2
        elements[i + 1] = elements[i] / i
        if change_sign && (i % 2 == parity)
            elements[i + 1] = -elements[i + 1]
        end -
        i += 1
    end
    i = 2 * iterations + parity - 2
    while i >= parity
        res *= x * x
        res += elements[i + 1]
        i -= 2
    end
    if parity == 1
        res *= x
    end
    return res
end
 
function real_sin(r, iterations)
    r = r - floor(r / (2 * pi)) * 2 * pi
    if r > pi
        return -real_sin(r - pi, iterations)
    end
    if r > pi / 2
        return real_cos(r - pi / 2, iterations)
    end
    if r > pi / 4
        return real_cos(pi / 2 - r, iterations)
    end
 
    return series(r, 1, true, iterations)
end
 
function real_cos(r, iterations)
    r = r - floor(r / (2 * pi)) * 2 * pi
    if r > pi
        return -real_cos(r - pi, iterations)
    end
    if r > pi / 2
        return -real_sin(r - pi / 2, iterations)
    end
    if r > pi / 4
        return real_sin(pi / 2 - r, iterations)
    end
 
    return series(r, 0, true, iterations)
end
 
function real_sinh(r, iterations)
    if abs(r) > HYPERBOLIC_MAX
        return 2 * real_sinh(r / 2, iterations) * real_cosh(r / 2, iterations)
    end
    return series(r, 1, false, iterations)
end
 
function real_cosh(r, iterations)
    if abs(r) > HYPERBOLIC_MAX
        s = real_sinh(r / 2, iterations)
        c = real_cosh(r / 2, iterations)
        return s * s + c * c
    end
    return series(r, 0, false, iterations)
end
 
function complex_sin(a, b, iterations)
    return (real_sin(a, iterations) * real_cosh(b, iterations), 
            real_cos(a, iterations) * real_sinh(b, iterations)) 
end
 
function complex_cos(a, b, iterations)
    return (real_cos(a, iterations) * real_cosh(b, iterations),
            -real_sin(a, iterations) * real_sinh(b, iterations))
end
 
# c = a + bi
function csin(a, b)
    return complex_sin(a, b, ITER)
end
 
function ccos(a, b)
    return complex_cos(a, b, ITER)
end
 
function rsinh(r)
    return real_sinh(r, ITER)
end
 
function rcosh(r)
    return real_cosh(r, ITER)
end
end