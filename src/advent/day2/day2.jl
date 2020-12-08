using BenchmarkTools
using Transducers

struct Rule
    args::Tuple{Int64, Int64}
    c::Char
end

struct Entry
    rule::Rule
    password::String
end

function parseRule(s::AbstractString)::Rule
    p = findfirst(" ", s)
    rangePart = s[1:p[1]-1]
    charPart = s[p[1]+1:length(s)]
    p = findfirst("-", rangePart)
    arg1Part = rangePart[1:p[1]-1]
    arg2Part = rangePart[p[1]+1:length(rangePart)]
    arg1 = parse(Int64, arg1Part)
    arg2 = parse(Int64, arg2Part)
    Rule((arg1, arg2), charPart[1])
end

function parseEntry(s::AbstractString)::Entry
    p = findfirst(": ", s)
    rule = parseRule(s[1:p[1]-1])
    password = s[p[2]+1:length(s)]
    Entry(rule, password)
end

function readEntries(path)
    readlines(path) |> Map(line -> parseEntry(line))
end

function isValid1(entry::Entry)::Bool
    min, max = entry.rule.args
    count = 0
    for i = 1:length(entry.password)
        if entry.password[i] == entry.rule.c
            count += 1
            count > max && return false
        end
    end
    count >= min
end

function isValid2(entry::Entry)::Bool
    count = 0
    for arg in entry.rule.args
        if entry.password[arg] == entry.rule.c
            count += 1
            count > 1 && return false
        end
    end
    count == 1
end

function countValid(entries, isValid)
    entries |> Filter(entry -> isValid(entry)) |> Map(entry -> 1) |> sum
end

exampleEntries = readEntries("src/advent/day2/example.txt")
testEntries = readEntries("src/advent/day2/input.txt")

@assert countValid(exampleEntries, isValid1) == 2
@assert countValid(exampleEntries, isValid2) == 1

@btime countValid(testEntries, isValid1)
@btime countValid(testEntries, isValid2)

#@code_warntype countValid(testEntries, isValid1)
#@code_warntype countValid(testEntries, isValid2)
