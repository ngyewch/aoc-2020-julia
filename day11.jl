using Pkg
Pkg.instantiate()

####

using BenchmarkTools
using Transducers

####

exampleFilename = ARGS[1]
inputFilename = ARGS[2]

benchmark = false

####

isFloor(c) = c == '.'
isEmpty(c) = c == 'L'
isOccupied(c) = c == '#'

readLayout(filename) = readlines(filename) |> Map(line -> collect(line)) |> collect

function isOccupied(layout, rowNo, colNo)
    ((rowNo < 1) || (colNo < 1) || (rowNo > length(layout))) && return false
    row = layout[rowNo]
    ((colNo > length(row)) || !isOccupied(row[colNo])) && return false
    true
end

const directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

function iterate!(layout, numberOfOccupiedSeats, occupiedSeatsThreshold)
    changes = Tuple{Int64, Int64, Char}[]
    for rowNo = 1:length(layout)
        row = layout[rowNo]
        for colNo = 1:length(row)
            c = row[colNo]
            isFloor(c) && continue
            n = numberOfOccupiedSeats(layout, rowNo, colNo)
            isEmpty(c) && n == 0 && push!(changes, (rowNo, colNo, '#'))
            isOccupied(c) && n >= occupiedSeatsThreshold && push!(changes, (rowNo, colNo, 'L'))
        end
    end
    for (rowNo, colNo, c) in changes
        layout[rowNo][colNo] = c
    end
    !isempty(changes)
end

function dump(layout)
    foreach(row -> println(String(row)), layout)
    println()
end

function process(layout, numberOfOccupiedSeats, occupiedSeatsThreshold; trace = false)
    while true
        hasChanged = iterate!(layout, numberOfOccupiedSeats, occupiedSeatsThreshold)
        trace && dump(layout)
        !hasChanged && break
    end
    layout |> Cat() |> Filter(c -> isOccupied(c)) |> Map(c -> 1) |> foldxl(+; init = 0)
end

#### part 1

function numberOfAdjacentOccupiedSeats(layout, rowNo, colNo)
    directions |>
    Map(direction -> isOccupied(layout, rowNo + direction[1], colNo + direction[2])) |>
    Map(occupied -> occupied ? 1 : 0) |>
    sum
end

part1(layout; trace = false) = process(layout, numberOfAdjacentOccupiedSeats, 4; trace = trace)

@assert part1(readLayout(exampleFilename)) == 37

@show part1(readLayout(inputFilename))
benchmark && @btime part1(readLayout(inputFilename));

#### part 2

function isOccupiedInDirection(layout, currentLocation, direction)
    (rowNo, colNo) = currentLocation
    while true
        rowNo += direction[1]
        colNo += direction[2]
        ((rowNo < 1) || (rowNo > length(layout)) || (colNo < 1)) && return false
        row = layout[rowNo]
        (colNo > length(row)) && return false
        c = row[colNo]
        isOccupied(c) && return true
        isEmpty(c) && return false
    end
    false
end

function numberOfVisibleOccupiedSeats(layout, rowNo, colNo)
    directions |>
    Map(direction -> isOccupiedInDirection(layout, (rowNo, colNo), direction)) |>
    Map(occupied -> occupied ? 1 : 0) |>
    sum
end

part2(layout; trace = false) = process(layout, numberOfVisibleOccupiedSeats, 5; trace = trace)

@assert part2(readLayout(exampleFilename)) == 26

@show part2(readLayout(inputFilename))
benchmark && @btime part2(readLayout(inputFilename));
