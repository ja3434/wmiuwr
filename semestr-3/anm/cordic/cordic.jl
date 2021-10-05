using Printf

global ITERATIONS = 30
global CORDIC_MUL_POW = 30
global CORDIC_MUL = 2.0^CORDIC_MUL_POW
global CORDIC_ATANS
global CORDIC_F
global CORDIC_F_INV

CORDIC_ATANS = [843314857, 497837829, 263043837, 133525159, 67021687, 33543516, 16775851, 8388437, 4194283, 2097149, 1048576, 524288, 262144, 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2]
CORDIC_F = 1768195363
CORDIC_F_INV = 652032874

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

function preprocess_scaling_factor(iterations)
    # @printf("Preprocessing scaling factor, %d iterations\n", iterations)
    CORDIC_F = 1.0
    for i in 0:iterations
        CORDIC_F *= sqrt(1. + 1. / Float64(BigInt(2)^(2 * i)))
    end
    # @printf("Scaling factor: %.16f\n", F)
    @printf("CORDIC_F = %d\nCORDIC_F_INV = %d\n", round(CORDIC_F * CORDIC_MUL), round(CORDIC_MUL / CORDIC_F))
end

function approx_trig(x, iterations)
    global CORDIC_ATANS
    global CORDIC_F_INV
    X = CORDIC_F_INV
    Y = 0
    Z = round(x * CORDIC_MUL)
    s = 1
    for i in 0:(iterations - 1)
        println(X, " ", Y)

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

    println(X, " ", Y)
    return (Float64(X) / CORDIC_MUL, Float64(Y) / CORDIC_MUL)
end

# works only for real numbers
function approx_sin(x, y)
    return (approx_trig(x, ITERATIONS)[2], 0)
end

# works only for real numbers
function approx_cos(x, y)
    return (approx_trig(x, ITERATIONS)[1], 0)
end

function main()
    println("Preprocessing CORDIC constants.")
    preprocess_atan(CORDIC_MUL_POW)
    preprocess_scaling_factor(CORDIC_MUL_POW)
end
