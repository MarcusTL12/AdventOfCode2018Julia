using StaticArrays

function parse_input(filename)
    open(filename) do io
        Set(SVector{4}(parse.(Int, split(l, ','))) for l in eachline(io))
    end
end

function get_dirs()
    v = @SVector [1, 0, 0, 0]
    dirs = typeof(v)[]
    for _ = 1:4
        push!(dirs, v)
        push!(dirs, -v)
        v = circshift(v, 1)
    end
    dirs
end

function get_moves()
    dirs = get_dirs()

    all_moves = [Set(dirs)]

    for i = 2:3
        n_moves = eltype(all_moves)()

        for start in all_moves[i-1], dir in dirs
            push!(n_moves, start + dir)
        end

        push!(all_moves, n_moves)
    end

    moves = popfirst!(all_moves)
    for sub_moves in all_moves
        union!(moves, sub_moves)
    end
    moves
end

function part1()
    points = parse_input("inputfiles/day25/input")

    constellations = 0

    moves = get_moves()

    function dfs(pos)
        delete!(points, pos)
        for mov in moves
            npos = pos + mov
            if npos in points
                dfs(npos)
            end
        end
    end

    while !isempty(points)
        constellations += 1

        dfs(pop!(points))
    end

    constellations
end
