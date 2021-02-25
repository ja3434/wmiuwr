include("cordic.jl")
include("taylor.jl")
using Printf

# preprocessing
cordic.main()

function rel_error(x, y)
    return abs((x - y) / y)
end

function test_real_sin(arg, trig_func)
    @printf("Testing relative error for function %s and argument %f.\n", String(Symbol(trig_func)), arg)
    res = trig_func(arg, 0)
    real_res = sin(arg)
    @printf("Result: %.50f\n", res[1])
    @printf("LibRes: %.50F\n", real_res)
    @printf("Relative error: %e\n", rel_error(res[1], real_res))
end

function test_complex_sin(arg_real, arg_imag, trig_func)
    @printf("Testing relative error for function %s and argument %f + %f i.\n", String(Symbol(trig_func)), arg_real, arg_imag)
    res = trig_func(arg_real, arg_imag)
    real_res = sin(arg_real + arg_imag * im)
    @printf("Result: %.50f + %.50f i\n", res[1], res[2])
    @printf("LibRes: %.50f + %.50f i\n", real(real_res), imag(real_res))
    @printf("Relative error: %e, %e\n", rel_error(res[1], real(real_res)), rel_error(res[2], imag(real_res)))
end

test_real_sin(0.5, taylor.csin)
test_real_sin(0.5, cordic.approx_sin)


test_real_sin(0.001, taylor.csin)
test_real_sin(0.001, cordic.approx_sin)


test_real_sin(0.1, taylor.csin)
test_real_sin(0.1, cordic.approx_sin)


# test_complex_sin(0.5 + 2pi, 0.5, taylor.csin)
# test_complex_sin(100, 0.5, taylor.csin)