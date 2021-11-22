mutable struct Group
    name::String
    units::Int
    hp::Int
    weaknesses::Vector{String}
    immunities::Vector{String}
    damage::Int
    damage_type::String
    initiative::Int
end

function Base.show(io::IO, g::Group)
    print(io, "$(g.name): UNITS=$(g.units)")
end

function parse_input(filename)
    reg = r"(\d+) units each with (\d+) hit points (\(.+\))? ?" *
          r"with an attack that does (\d+) (\w+) damage at initiative (\d+)"

    imm_sys = Group[]
    infection = Group[]

    current_sys = imm_sys

    name = ""
    i = 0

    open(filename) do io
        for l in eachline(io)
            if l == "Immune System:"
                current_sys = imm_sys
                name = "Imm"
                i = 1
            elseif l == "Infection:"
                current_sys = infection
                name = "Inf"
                i = 1
            elseif !isempty(l)
                m = match(reg, l)

                units = parse(Int, m.captures[1])
                hp = parse(Int, m.captures[2])

                weaknesses = String[]
                immunities = String[]

                if !isnothing(m.captures[3])
                    parts = split(m.captures[3][2:end-1], "; ")

                    for part in parts
                        type, things = split(part, " to ")

                        list = if type == "weak"
                            weaknesses
                        elseif type == "immune"
                            immunities
                        end

                        append!(list, split(things, ", "))
                    end
                end

                damage = parse(Int, m.captures[4])
                damage_type = m.captures[5]

                initiative = parse(Int, m.captures[6])

                push!(current_sys, Group("$name $i", units, hp, weaknesses,
                    immunities, damage, damage_type, initiative))

                i += 1
            end
        end
    end

    imm_sys, infection
end

function effective_power(g::Group)
    g.damage * g.units
end

function sort_army_init!(army::Vector{Group})
    sort!(army; rev = true, lt = (a, b) -> a.initiative < b.initiative)
end

function sort_army_power!(army::Vector{Group})
    sort!(army; rev = true,
        lt = (a, b) -> effective_power(a) < effective_power(b)
    )
end

function damage(attacker::Group, defender::Group)
    effective_power(attacker) *
    if attacker.damage_type in defender.immunities
        0
    elseif attacker.damage_type in defender.weaknesses
        2
    else
        1
    end
end

function choose_targets(attackers::Vector{Group}, defenders::Vector{Group})
    sort_army_init!(attackers)
    sort_army_power!(attackers)

    remaining_defenders = copy(defenders)

    sort_army_power!(remaining_defenders)

    targets = Pair{Group,Group}[]

    for attacker in attackers
        _, i = findmax(
            defender -> damage(attacker, defender), remaining_defenders
        )

        push!(targets, attacker => popat!(remaining_defenders, i))

        if isempty(remaining_defenders)
            break
        end
    end

    targets
end

function attack!(attacker::Group, defender::Group)
    d = damage(attacker, defender)

    deaths = d ÷ defender.hp

    defender.units -= deaths
end

function remove_dead!(army::Vector{Group})
    for i in length(army):-1:1
        if army[i].units <= 0
            deleteat!(army, i)
        end
    end
end

function fight!(imm_sys, infection)
    targets = append!(
        choose_targets(imm_sys, infection), choose_targets(infection, imm_sys)
    )

    sort!(targets; rev = true,
        lt = ((a, _), (b, _)) -> a.initiative < b.initiative
    )

    for (att, def) in targets
        attack!(att, def)
    end

    remove_dead!(imm_sys)
    remove_dead!(infection)
end

function part1()
    imm_sys, infection = parse_input("inputfiles/day24/input")

    while !isempty(imm_sys) && !isempty(infection)
        fight!(imm_sys, infection)
    end

    surviving_army = if isempty(imm_sys)
        infection
    else
        imm_sys
    end

    sum(g.units for g in surviving_army)
end
