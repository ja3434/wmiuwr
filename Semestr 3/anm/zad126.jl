using Plots

phi = pi / 3

x0 = 0
y0 = 0
u0 = 100 * cos(phi)
v0 = 100 * sin(phi)
g = 9.81

function iterate(x, y, u, v, h, k)
    xn = x + h * u
    yn = y + h * v
    un = u * (1 - h * k * sqrt(u * u + v * v))
    vn = v - h * (g + k * sqrt(u * u + v * v) * v)
    return (xn, yn, un, vn)
end

function getPoints(k, h, phi)
    x0 = 0
    y0 = 0
    u0 = 100 * cos(phi)
    v0 = 100 * sin(phi)
    
    x = x0
    y = y0
    u = u0
    v = v0  

    X = Array{Float64}(undef, 0)
    Y = Array{Float64}(undef, 0)
    i = 1
    while y >= 0
        if (y < 0)
            return (X[1:1:i - 1], Y[1:1:i - 1])
        end
        append!(X, x)
        append!(Y, y)
        x, y, u, v = iterate(x, y, u, v, h, k)
        i += 1
    end
    println(x, " ", y)
    return (X, Y)
end

function plotArmata(K, phi, h)
    X, Y = getPoints(K[1], h, phi[1])
    p = plot(X, Y, label=string("k: ", (K[1]), " φ: ", string(phi[1])[1:1:5]); draw_arrow=true, aspect_ratio=:equal)
    for i in 2:length(K)
        X, Y = getPoints(K[i], h, phi[i])
        plot!(p, X, Y, label=string("k: ", (K[i]), " φ: ", string(phi[i])[1:1:5]), aspect_ratio=:equal)
    end
    xlabel!("Odległość [m]")
    ylabel!("Wysokość [m]")
    display(p)
end

# plotArmata([0.01, 0.012, 0.014, 0.016, 0.018, 0.2], 0.01)