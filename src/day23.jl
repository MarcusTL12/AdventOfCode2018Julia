using PyCall
z3 = pyimport("z3")


function load_input(filename)
    reg = r"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)"
    open(filename) do io
        [begin
            m = match(reg, l)
            (parse.(Int, (m.captures[1:3]...,)), parse(Int, m.captures[4]))
        end for l in eachline(io)]
    end
end


function mandist(a, b)
    sum(abs, a .- b)
end


function part1()
    inp = load_input("inputfiles/day23/input.txt")
    
    strongest_boi = 1
    
    for i in 2:length(inp)
        if inp[i][2] > inp[strongest_boi][2]
            strongest_boi = i
        end
    end
    
    count(i -> mandist(inp[i][1], inp[strongest_boi][1]) <=
    inp[strongest_boi][2], 1:length(inp))
end


function part2()
    inp = load_input("inputfiles/day23/input.txt")
    
    zabs(x) = z3.If(x < 0, -x, x)
    
    x = z3.Int("x")
    y = z3.Int("y")
    z = z3.Int("z")
    
    eqs = [begin
        dist = zabs(bot_x - x) + zabs(bot_y - y) + zabs(bot_z - z)
        dist <= bot_r
    end for ((bot_x, bot_y, bot_z), bot_r) in inp]
    
    in_ranges = [
        z3.Int("in_range_" * string(i)) for i in 1:length(eqs)
    ]
    
    range_count = z3.Int("range_count")
    
    dist_from_zero = z3.Int("dist_from_zero")
    
    o = z3.Optimize()
    for (in_range, eq) in zip(in_ranges, eqs)
        o.add(in_range == z3.If(eq, 1, 0))
    end
    o.add(range_count == sum(in_ranges))
    o.add(dist_from_zero == zabs(x) + zabs(y) + zabs(z))
    
    o.maximize(range_count)
    o.minimize(dist_from_zero)
    o.check()
    
    println(o.model().__getitem__(dist_from_zero))
end
