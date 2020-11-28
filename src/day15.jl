using Base.Iterators


function load_input(filename)
    open(filename) do io
        map = Char[]
        w = 0
        h = 0
        for l in eachline(io)
            h += 1
            w = length(l)
            append!(map, l)
        end
        reshape(map, (h, w))
    end
end


function find_players(map)
    players = Dict{Tuple{Int,Int},Int}()
    for (i, row) in enumerate(eachrow(map))
        for (j, c) in enumerate(row)
            if c in "EG"
                players[(i, j)] = 200
            end
        end
    end
    players
end


dirs = [
    (0, -1),
    (-1, 0),
    (1, 0),
    (0, 1),
]


function find_closest(map, startpos)
    target = map[startpos...] == 'E' ? 'G' : 'E'
    
    queue = [(startpos, 0)]
    visited = Set((startpos,))
    
    backtrack = Dict(startpos => (0, 0))
    
    target_locations = Tuple{Int,Int}[]
    finaldist = 0
    
    while !isempty(queue)
        pos, dist = popfirst!(queue)
        
        if any(d -> get(map, pos .+ d, '#') == target, dirs)
            if finaldist == 0
                finaldist = dist
            end
            if dist == finaldist
                push!(target_locations, pos)
            end
        elseif finaldist == 0 || dist < finaldist
            for dir in dirs
                npos = pos .+ dir
                
                if get(map, npos, '#') == '.' && !(npos in visited)
                    push!(visited, npos)
                    push!(queue, (npos, dist + 1))
                    backtrack[npos] = dir
                end
            end
        end
    end
    
    if length(target_locations) > 0
        target_location = sort!(target_locations; by=x -> reverse(x))[1]
        
        cur_loc = target_location
        
    # Vær så god fremtide marcus, lykke til med forsåelsen <3<3 -nåtidsmarcus
        while (cur_loc = (cur_loc .- (step = backtrack[cur_loc]))) != startpos end
        
        step
    end
end


function do_player_turn(map, players, player_pos, attack_power)
    target = map[player_pos...] == 'E' ? 'G' : 'E'
    
    exist_target = false
    
    for pos in keys(players)
        if map[pos...] == target
            exist_target = true
        end
    end
    
    if !any(d -> get(map, player_pos .+ d, '#') == target, dirs)
        move_dir = find_closest(map, player_pos)
        if !isnothing(move_dir)
            map[(player_pos .+ move_dir)...] = map[player_pos...]
            map[player_pos...] = '.'
            
            player = pop!(players, player_pos)
            players[player_pos .+ move_dir] = player
            
            player_pos = player_pos .+ move_dir
        end
    end
    
    enemy_dirs = collect(d for d in dirs if map[(player_pos .+ d...)] == target)
    
    if !isempty(enemy_dirs)
        min_health = minimum(d -> players[player_pos .+ d], enemy_dirs)
        
        critically_hurt = collect(player_pos .+ d for d in enemy_dirs
        if players[player_pos .+ d] == min_health)
        
        sort!(critically_hurt; by=by = x -> reverse(x))
        
        attack_pos = critically_hurt[1]
        dmg = if map[attack_pos...] == 'G'
            attack_power
        else
            3
        end
        players[attack_pos] -= dmg
        if players[attack_pos] <= 0
            pop!(players, attack_pos)
            map[attack_pos...] = '.'
        end
    end
    
    exist_target
end


function do_turn(map, players, attakc_power=3)
    player_coords = collect(keys(players))
    sort!(player_coords; by=x -> reverse(x))
    
    targets_empty = false
    
    for player_pos in player_coords
        if haskey(players, player_pos)
            if !do_player_turn(map, players, player_pos, attakc_power)
                targets_empty = true
                break
            end
        end
    end
    
    !targets_empty
end


function render_map(map)
    buff = IOBuffer()
    for col in eachcol(map)
        for c in col
            print(buff, c)
        end
        println(buff, ' ')
    end
    print(String(take!(buff)))
end


function part1()
    map = load_input("inputfiles/day15/input.txt")
    
    players = find_players(map)
    
    i = 0
    
    while do_turn(map, players)
        i += 1
    end
    
    i * sum(values(players))
end


function part2()
    map = load_input("inputfiles/day15/input.txt")
    
    for attack_power in countfrom(4)
        curmap = copy(map)
        players = find_players(curmap)
        
        amt_elves = count(p->curmap[p...] == 'E', keys(players))
        lost_an_elf = false
        
        i = 0
        
        while do_turn(curmap, players, attack_power)
            if count(p->curmap[p...] == 'E', keys(players)) < amt_elves
                lost_an_elf = true
                break
            end
            i += 1
        end
        
        if count(p->curmap[p...] == 'E', keys(players)) < amt_elves
            lost_an_elf = true
        end
        
        if !lost_an_elf
            return i * sum(values(players))
        end
    end
end
