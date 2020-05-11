module DoomedLib
using PyPlot
export generate_fractals

function newton(f ::Function, z0 ::Complex{Float64}, precision ::Real, epsilon ::Number, max_iterations ::Integer ) ::Tuple{Complex{Float64}, Int64}

    z_i_minus = z0
    f_i_minus = f(z_i_minus)

    for i in 1:max_iterations
        f_prime_i_minus = diff(f, z_i_minus, epsilon) # Ableitung bestimmen
        z_i = z_i_minus - (f_i_minus / f_prime_i_minus) # Neues x[i] gemäss x[i] = x[i-1] - f(x[i-1]) / f'(x[i-1])
        f_i_minus = f(z_i) # Neuen Funktionswert für nächsten durchlauf speichern
        if(abs(f_i_minus) <= precision) return (z_i, i) end
        z_i_minus = z_i
    end
    return (NaN, max_iterations + 1)
end

function diff(f, x, epsilon)
    return (f(x + epsilon) - f(x - epsilon)) / (2 * epsilon)
end

function fractal(f;x_length = 720 ::Int64, y_length = 720 ::Int64, x_min = -2, x_max = 2, y_min = -2, y_max = 2, max_steps = 200, zero_precision = 1e-6, diff_precision = 1e-10, plot_failures = true)
    mat = zeros(Int64, y_length, x_length)
    x_range = range(x_min, length=x_length, stop=x_max)
    y_range = range(y_min, length=y_length, stop=y_max)
    i_index = 0
    r_index = 0
    for i in y_range
        i_index += 1
        for r in x_range
            r_index += 1
            z = r + i*im
            zero, steps = newton(f, z, zero_precision, diff_precision, max_steps)
            if(plot_failures || zero != NaN)
                mat[i_index, r_index] = steps
            end
        end
        r_index = 0
    end
    return mat
end

function func_wrapper(params ::Array, constant ::Real)
    function to_string()
        out = "";
        for f in params
            if (length(out) > 0) out = out * " + " end
            out = out * f.to_string()
        end
        return out * " + " *(string(constant))
    end
    function print()
        println(to_string())
    end
    function f(z)
        out = constant
        for f in params
            out = out + f.exec(z)
        end
        return out
    end
    function init()
        for f in params
            f.init()
        end
    end
    () -> (to_string;print;f;init)
end

function random_fractal(image_name;function_length=10, x_length = 720 ::Int64, y_length = 720 ::Int64, x_min = -2, x_max = 2, y_min = -2, y_max = 2, max_steps = 200, zero_precision = 1e-6, diff_precision = 1e-10, plot_failures = true)
    functions = func_list()
    array = []
    for i in 1:function_length
        append!(array, [functions.rand_func()])
    end
    rf = func_wrapper(array, rand(Float64))
    rf.init()
    function f(z)
        return rf.f(z)
    end
    mat = fractal(f, x_length = x_length, y_length = y_length, x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max, max_steps = max_steps, zero_precision = zero_precision, diff_precision = diff_precision, plot_failures = plot_failures)
    imsave(image_name, mat, origin="lower")
    return (image_name, rf.to_string())
end

function func_list()
    function f1()
        function init() end
        function exec(z) return tan(z) end
        function to_string() return "tan(z)" end
        () -> (init;exec;to_string)
    end
    function f2()
        function init() end
        function exec(z) return sin(z) end
        function to_string() return "sin(z)" end
        () -> (init;exec;to_string)
    end
    function f3()
        function init() end
        function exec(z) return cos(z) end
        function to_string() return "cos(z)" end
        () -> (init;exec;to_string)
    end
    function f4()
        function init() end
        function exec(z) return abs(z) end
        function to_string() return "abs(z)" end
        () -> (init;exec;to_string)
    end
    function f5()
        x = 0
        y = 0
        function init()
            x = rand(-100:100)
            y = rand(-10:10)
        end
        function exec(z) return x*z^y end
        function to_string() return string(x) * "*z^" * string(y) end
        () -> (init;exec;to_string)
    end
    function f6()
        functions = func_list()
        func1 = f1()
        func2 = f1()
        function init()
            func1 = functions.rand_func()
            func1.init()
            func2 = functions.rand_func()
            func2.init()
        end
        function exec(z) return func1.exec(z)^func2.exec(z) end
        function to_string() return "(" * func1.to_string() * ")^(" * func2.to_string() * ")" end
        () -> (init;exec;to_string)
    end
    function rand_func()
        i = rand(1:6)
        if(i == 1) return f1() end
        if(i == 2) return f2() end
        if(i == 3) return f3() end
        if(i == 4) return f4() end
        if(i == 5) return f5() end
        if(i == 6) return f6() end
    end
    () -> (rand_func)
end

function generate_fractals(amount = 5, file_prefix = "fractal"; save_functions=true, function_save_loc="functions.txt", print_to_cmd=false, function_length=10, x_length = 720 ::Int64, y_length = 720 ::Int64, x_min = -2, x_max = 2, y_min = -2, y_max = 2, max_steps = 200, zero_precision = 1e-6, diff_precision = 1e-10, plot_failures = true)

    for i in 1:amount
        a, b = random_fractal(file_prefix * string(i) * ".png", function_length = function_length, x_length = x_length, y_length = y_length, x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max, max_steps = max_steps, zero_precision = zero_precision, diff_precision = diff_precision, plot_failures = plot_failures)
        if(save_functions)
            open(function_save_loc, "a") do io
                write(io, a * " :   " * b)
            end
        end
        if(print_to_cmd)
            println(a, " :   ", b)
        end
    end
end

end # module
