using BenchmarkTools
using Printf
using Transducers

benchmark = false

exampleFilename = "src/advent/day13/example.txt"
example1Filename = "src/advent/day13/example1.txt"
example2Filename = "src/advent/day13/example2.txt"
example3Filename = "src/advent/day13/example3.txt"
example4Filename = "src/advent/day13/example4.txt"
example5Filename = "src/advent/day13/example5.txt"
inputFilename = "src/advent/day13/input.txt"

struct Notes
    t::Int64
    buses::Array{Union{Missing, Int64}}
end

function readData(filename)
    f = open(filename)
    t = parse(Int64, readline(f))
    buses = split(readline(f), ",") |> 
            Map(s -> s == "x" ? Missing() : parse(Int64, s)) |> 
            collect
    close(f)
    Notes(t, buses)
end

exampleNotes = readData(exampleFilename)
example1Notes = readData(example1Filename)
example2Notes = readData(example2Filename)
example3Notes = readData(example3Filename)
example4Notes = readData(example4Filename)
example5Notes = readData(example5Filename)
inputNotes = readData(inputFilename)

#### part1

function part1(notes)
    result = notes.buses |>
            Filter(bus -> !ismissing(bus)) |>
            Map(bus -> (bus = bus, t = notes.t + (bus - (notes.t % bus)) % bus)) |>
            foldxl((a, b) -> a.t < b.t ? a : b)
    result.bus * (result.t - notes.t)
end

@assert part1(exampleNotes) == 295

@show part1(inputNotes)
benchmark && @btime part1(inputNotes);

#### part2

function part2(notes)
    buses = NamedTuple{(:number, :index), Tuple{Int64, Int64}}[]
    for i = 1:length(notes.buses)
        if !ismissing(notes.buses[i])
            push!(buses, (number = notes.buses[i], index = i))
        end
    end
    sort!(buses; rev = true, by = bus -> bus.number)
    referenceBus = buses[1]
    otherBuses = @view buses[2:length(buses)]
    
    t = referenceBus.number
    while true
        matched = true
        for bus in otherBuses
            t2 = t + bus.index - referenceBus.index
            if t2 % bus.number != 0
                matched = false
                break
            end
        end
        matched && break
        t += referenceBus.number
    end
    t - (referenceBus.index - 1)
end

@assert part2(exampleNotes) == 1068781
@assert part2(example1Notes) == 3417
@assert part2(example2Notes) == 754018
@assert part2(example3Notes) == 779210
@assert part2(example4Notes) == 1261476
@assert part2(example5Notes) == 1202161486

#@show part2(inputNotes)
#benchmark && @btime part2(inputNotes);
