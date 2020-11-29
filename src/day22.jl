using Base.Iterators

using DataStructures

# depth = 510
# target = (10, 10)

depth = 11541
target = (14, 778)


geo_index = let memo = Dict{Tuple{Int,Int},Int}()
    (x, y) -> begin
        if haskey(memo, (x, y))
            memo[(x, y)]
        else
            ind = if (x, y) == (0, 0) || (x, y) == target
                0
            elseif y == 0
                x * 16807
            elseif x == 0
                y * 48271
            else
                ero_level(x - 1, y) * ero_level(x, y - 1)
            end % 20183
            memo[(x, y)] = ind
            ind
        end
    end
end


ero_level(x, y) = (geo_index(x, y) + depth) % 20183
terrain(x, y) = ero_level(x, y) % 3


function render_cave(xs, ys)
    types = ['.', '=', '|']
    buff = IOBuffer()
    for y in ys
        for x in xs
            if (x, y) == target
                print(buff, 'T')
            else
                print(buff, types[terrain(x, y) + 1])
            end
        end
        println(buff, ' ')
    end
    println(String(take!(buff)))
end


function part1()
    sum(terrain(x, y) for (x, y) in product(0:target[1], 0:target[2]))
end


dirs = [
    (0, 1),
    (1, 0),
    (0, -1),
    (-1, 0),
]


function valid_equipment(pos, equipment)
    terrain(pos...) != equipment
end


function part2()
    start_pos = (0, 0)
    # Equipment: 0: neither, 1: torch, 2: climbing gear
    start_equip = 1
    
    queue = PriorityQueue((start_pos, start_equip) => 0)
    visited = Set((start_pos, start_equip), )
    
    i = 0
    
    while !isempty(queue)
        i += 1
        ((pos, equipment), cur_time) = dequeue_pair!(queue)
        
        if pos == target && equipment == 1
            return cur_time
        end
        
        for d in dirs
            npos = pos .+ d
            if all(x -> x >= 0, npos)
                if valid_equipment(npos, equipment)
                    nkey = (npos, equipment)
                    ntime = cur_time + 1
                    
                    if haskey(queue, nkey) && queue[nkey] > ntime
                        queue[nkey] = ntime
                    elseif !(nkey in visited)
                        push!(visited, nkey)
                        queue[nkey] = ntime
                    end
                end
            end
        end
        
        for n_equip in (0, 1, 2)
            if n_equip != equipment
                if valid_equipment(pos, n_equip)
                    nkey = (pos, n_equip)
                    ntime = cur_time + 7
                    
                    if haskey(queue, nkey) && queue[nkey] > ntime
                        queue[nkey] = ntime
                    elseif !(nkey in visited)
                        push!(visited, nkey)
                        queue[nkey] = ntime
                    end
                end
            end
        end
    end
end
