using BenchmarkTools
using Printf
using Transducers

function parseInstruction(line)
    part = split(line; limit = 2)
    (part[1], parse(Int64, part[2]))
end

function readInstructions(filename)
    readlines(filename) |> Map(line -> parseInstruction(line)) |> collect
end

exampleInstructions = readInstructions("src/advent/day8/example.txt")
inputInstructions = readInstructions("src/advent/day8/input.txt")

function run(instructions; trace = false)
    executionCounts = zeros(Int64, length(instructions))
    currentAddress = 1
    accumulator = 0

    while (currentAddress <= length(instructions)) && (executionCounts[currentAddress] == 0)
        trace && @printf("%04d: %s\n", currentAddress, instructions[currentAddress])
        (operation, value) = instructions[currentAddress]
        executionCounts[currentAddress] += 1
        if operation == "nop"
            # do nothing
        elseif operation == "acc"
            accumulator += value
        elseif operation == "jmp"
            currentAddress += value - 1
        else
            throw(ErrorException("invalid instruction"))
        end
        currentAddress += 1
    end

    (accumulator = accumulator, currentAddress = currentAddress)
end

@show run(exampleInstructions)

@assert run(exampleInstructions).accumulator == 5

@printf("part1 = %d\n", run(inputInstructions).accumulator)
@btime run(inputInstructions)

function part2(instructions; trace = false)
    for i = 1:length(instructions)
        (operation, value) = instruction = instructions[i]
        (operation != "nop" && operation != "jmp") && continue
        instructions[i] = operation == "nop" ? ("jmp", instruction[2]) : ("nop", instruction[2])
        trace && @printf("running with change @ %d...\n", i)
        result = run(instructions)
        instructions[i] = instruction
        result.currentAddress > length(instructions) && return (modifiedAddress = i, result = result)
    end
end

println(part2(exampleInstructions))
println("====")
println(part2(inputInstructions))
@btime part2(inputInstructions)
