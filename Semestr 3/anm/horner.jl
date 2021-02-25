function horner(w, n, x0)
    p = w[n + 1]
    q = 0
    r = w[n + 1]
    t = 0
    for i in range(n, 1, step=-1)
        q = p + x0 * q
        p = w[i] + x0 * p
        t = r + x0 * t
        r = p + x0 * r  
    end
    return [p, q, r, t]
end


println(horner([-13, 10, -7, 2], 3, 2))