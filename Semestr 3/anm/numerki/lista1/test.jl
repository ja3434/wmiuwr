using Random

function prettyfloat64(f)
    ss = bitstring(f)
    s = ss[1]
    c = ss[2:12]
    m = ss[13:end]
    return string(s, " ", c, " ", m)
end

function string_to_float64(st)
    s = st[1]
    c = st[2:12]
    m = st[13:end]

    if s == '0'
        s = 1.0
    else
        s = -1.0
    end

    c = parse(Int, string("0b", c))
    c = 2.0^(c - 1023)
    m = Float64(parse(Int64, string("0b", m))) / Float64(2^52) + 1.0
    return s * c * m
end

rng = MersenneTwister(123)

function rand_f64_bitstring()
    return randstring(rng, ['0', '1'], 64)
end

function test_string_to_float()
    for i in 1:100000
    # st = rand_f64_bitstring()
        st = rand(rng)
        res = string_to_float64(bitstring(st))
        println(string(st, " -> ", prettyfloat64(st), " -> ", res))
        if bitstring(res) == bitstring(st)
            println("OK")
        else
            println("ZJEBALO SIE")
            break
        end
    end
end

function find_felerny_x()
    while true    
        x = rand(rng) + 1.0
        res = x * (1.0 / x)
        if res != 1.0
            println(string("Znalazlem! ", x))
            return x
        end
    end
end

function find_felerne_iksy(iterations)
    bad_xs = 0
    for i in 1:iterations
        x = rand(rng) + 1.0
        res = x * (1.0 / x)
        if res != 1.0
            bad_xs += 1
        end
    end
    println("Znalazlem ", bad_xs, " felernych iksow, czyli ", bad_xs / iterations * 100.0, "% wszystkich losowanych wartosci.")
end

# find_felerne_iksy(10000000)


function rel_error(x, rx)
    x  = Float64(x)
    rx = Float64(rx)
    relative = abs((x - rx) / x)
    return relative
end

function test_poly(t, poly, x=4.71, exact=-14.636489)
    println("Testing poly \"", poly, "\" with float type ", t, ".")
    res = poly(x, t)
    println(poly, "(", x, ") = ", res)
    println("Relative error (exact: ", exact, "): ", rel_error(exact, res))
end

function w(x, t)
    x = t(x)
    return x^3 - (t(6)) * (x^2) + (t(3)) * x - t(0.149)
end

function w2(x, t)
    x = t(x)
    return ((x - t(6)) * x + t(3)) * x - t(0.149)
end
    
    
function task3()
    println("Task3: ")
    
    test_poly(Float16, w)
    println()
    test_poly(Float32, w)
    println()
    test_poly(Float64, w)
    println()

    test_poly(Float16, w2)
    println()
    test_poly(Float32, w2)
    println()
    test_poly(Float64, w2)
    println()
end


