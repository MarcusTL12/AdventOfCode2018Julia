

function load_input(filename)
    open(filename) do io
        track = Dict{Complex{Int},Char}()
        carts = Tuple{Complex{Int},Complex{Int},Complex{Int},Bool}[]
        for (i, l) in enumerate(eachline(io))
            for (j, c) in enumerate(l)
                pos = j + i * im
                if c in "^v<>"
                    push!(carts, (pos, if c == '^'
                        -1im
                    elseif c == 'v'
                        1im
                    elseif c == '<'
                        -1 + 0im
                    else
                        1 + 0im
                    end::Complex{Int}, -1im, true))
                elseif c in "\\+/"
                    push!(track, pos => c)
                end
            end
        end
        track, carts
    end
end


cross_turn_next = Dict{Complex{Int},Complex{Int}}([
    -1im => 1 + 0im,
    1 + 0im => 1im,
    1im => -1im,
])


function part1()
    track, carts = load_input("inputfiles/day13/input.txt")
    
    cart_pos_set = Set(p for (p, _, _, _) in carts)
    
    while true
        sort!(carts; lt=((x, _), (y, _)) -> if imag(x) < imag(y)
            true
        elseif imag(x) == imag(y)
            real(x) < real(y)
        else
            false
        end)
        
        for i in 1:length(carts)
            pos, dir, cross_turn, _ = carts[i]
            
            npos = pos + dir
            
            if npos in cart_pos_set
                return npos - 1 - 1im
            end
            
            delete!(cart_pos_set, pos)
            push!(cart_pos_set, npos)
            
            pos = npos
            
            piece = get(track, pos, ' ')
            
            rotation = if piece == '\\'
                real(dir) == 0 ? -1im : 1im
            elseif piece == '/'
                real(dir) == 0 ? 1im : -1im
            elseif piece == '+'
                tmp = cross_turn
                cross_turn = cross_turn_next[cross_turn]
                tmp
            else
                1 + 0im
            end::Complex{Int}
            
            dir *= rotation
            
            carts[i] = (pos, dir, cross_turn, true)
        end
    end
end


function part2()
    track, carts = load_input("inputfiles/day13/input.txt")
    
    cart_pos_set = Set(p for (p, _, _, _) in carts)
    
    while count(x->x[end], carts) > 1
        sort!(carts; lt=((x, _), (y, _)) -> if imag(x) < imag(y)
            true
        elseif imag(x) == imag(y)
            real(x) < real(y)
        else
            false
        end)
        
        for i in 1:length(carts)
            pos, dir, cross_turn, alive = carts[i]
            
            if !alive
                continue
            end
            
            npos = pos + dir
            
            if npos in cart_pos_set
                j = first(j for (j, (p, _, _, a)) in enumerate(carts)
                if a && p == npos)
                
                carts[j] = (pos, dir, cross_turn, false)
                
                delete!(cart_pos_set, pos)
                delete!(cart_pos_set, npos)
                carts[i] = (pos, dir, cross_turn, false)
                continue
            end
            
            delete!(cart_pos_set, pos)
            push!(cart_pos_set, npos)
            
            pos = npos
            
            piece = get(track, pos, ' ')
            
            rotation = if piece == '\\'
                real(dir) == 0 ? -1im : 1im
            elseif piece == '/'
                real(dir) == 0 ? 1im : -1im
            elseif piece == '+'
                tmp = cross_turn
                cross_turn = cross_turn_next[cross_turn]
                tmp
            else
                1 + 0im
            end::Complex{Int}
            
            dir *= rotation
            
            carts[i] = (pos, dir, cross_turn, alive)
        end
    end
    
    only(x[1] for x in carts if x[end]) - 1 - 1im
end
