using BenchmarkTools
using Printf
using Transducers

benchmark = true

exampleFilename = "src/advent/day12/example.txt"
inputFilename = "src/advent/day12/input.txt"

#### Direction

struct Direction
    name::Char
    heading::Int64
    dx::Int64
    dy::Int64
end

const north = Direction('N', 0, 0, 1)
const east = Direction('E', 90, 1, 0)
const south = Direction('S', 180, 0, -1)
const west = Direction('W', 270, -1, 0)

const directions = [north, east, south, west]
const directionByName = Dict('N' => north, 'E' => east, 'S' => south, 'W' => west)
const directionByHeading = Dict(0 => north, 90 => east, 180 => south, 270 => west)

function turnRight(direction::Direction, degrees::Int64)::Direction
    heading = direction.heading + degrees
    while heading < 0
        heading += 360
    end
    heading = heading % 360
    directionByHeading[heading]
end

turnLeft(direction::Direction, degrees::Int64)::Direction = turnRight(direction, -degrees)

#### Runner

function run(filename, entity; trace = false)
    f = open(filename)
    while !eof(f)
        line = readline(f)
        c, value = line[1], parse(Int64, line[2:length(line)])
        if c == 'F'
            doF(entity, value)
        elseif c == 'L'
            doL(entity, value)
        elseif c == 'R'
            doR(entity, value)
        else
            doDirection(entity, directionByName[c], value)
        end
        trace && @printf("%s -> %s\n", line, toString(entity))
    end
    close(f)
end

#### Point

struct Point
    x::Int64
    y::Int64
end

Base.:+(a::Point, b::Tuple{Int64, Int64}) = Point(a.x + b[1], a.y + b[2])

toString(point::Point) = @sprintf("(%s, %s)", point.x, point.y)

manhattanDistance(point::Point) = abs(point.x) + abs(point.y)

#### part 1

## Vehicle

mutable struct Vehicle
    position::Point
    heading::Direction
end

doDirection(vehicle::Vehicle, direction::Direction, distance::Int64) = vehicle.position += (direction.dx * distance, direction.dy * distance)

doF(vehicle::Vehicle, distance::Int64) = doDirection(vehicle, vehicle.heading, distance)

function doR(vehicle::Vehicle, degrees::Int64)
    vehicle.heading = turnRight(vehicle.heading, degrees)
end

doL(vehicle::Vehicle, degrees::Int64) = doR(vehicle, -degrees)

toString(vehicle::Vehicle) = @sprintf("%s %s", toString(vehicle.position), vehicle.heading.name)

##

function part1(filename; trace=false)
    vehicle = Vehicle(Point(0, 0), east)
    run(filename, vehicle; trace = trace)
    manhattanDistance(vehicle.position)
end

@assert part1(exampleFilename) == 25

@show part1(inputFilename)
benchmark && @btime part1(inputFilename);

#### part 2

## Vehicle2

mutable struct Vehicle2
    position::Point
    waypoint::Point
    heading::Direction
end

doDirection(vehicle::Vehicle2, direction::Direction, distance::Int64) = vehicle.waypoint += (direction.dx * distance, direction.dy * distance)

doF(vehicle::Vehicle2, value::Int64) = vehicle.position += (vehicle.waypoint.x * value, vehicle.waypoint.y * value)

function doR(vehicle::Vehicle2, degrees::Int64)
    radians = Base.Math.deg2rad(degrees)
    vehicle.waypoint = Point(round(vehicle.waypoint.x * cos(radians) + vehicle.waypoint.y * sin(radians)), round(vehicle.waypoint.y * cos(radians) - vehicle.waypoint.x * sin(radians)))
end

doL(vehicle::Vehicle2, degrees::Int64) = doR(vehicle, -degrees)

toString(vehicle::Vehicle2) = @sprintf("%s %s %s", toString(vehicle.position), toString(vehicle.waypoint), vehicle.heading.name)

##

function part2(filename; trace=false)
    vehicle = Vehicle2(Point(0, 0), Point(10, 1), east)
    run(filename, vehicle; trace = trace)
    manhattanDistance(vehicle.position)
end

@assert part2(exampleFilename) == 286

@show part2(inputFilename)
benchmark && @btime part2(inputFilename);
