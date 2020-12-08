using BenchmarkTools
using Printf
using Transducers

struct BagCount
    n::Int64
    color::String
end

struct BagRule
    color::String
    contains::Array{BagCount, 1}
end

function parseBagDescriptor(s)
    p = findfirst(r"\s+bags?$", s)
    isnothing(p) && throw(DomainError(s, "invalid bag descriptor"))
    s[1:p.start-1]
end

function toBagCount(s)
    parts = split(s, " "; limit = 2)
    BagCount(parse(Int64, parts[1]), parseBagDescriptor(parts[2]))
end

function toBagRule(s)
    s = rstrip(s, '.')
    p = findfirst(" contain ", s)
    bagDescriptor = parseBagDescriptor(s[1:p.start-1])
    contents = s[p.stop+1:length(s)]
    BagRule(bagDescriptor, contents == "no other bags" ? [] : [toBagCount(content) for content = split(contents, ", ")])
end

####

exampleBagRules = readlines("src/advent/day7/example.txt") |> Map(line -> toBagRule(line)) |> collect
inputBagRules = readlines("src/advent/day7/input.txt") |> Map(line -> toBagRule(line)) |> collect

#### part 1

function canBeContainedBy(bagRules, color)
    entries = bagRules |> Map(rule -> [(entry.color, rule.color) for entry ∈ rule.contains]) |> Iterators.flatten |> collect
    dict = Dict(entry[1] => Set{String}() for entry ∈ entries)
    foreach(entry -> union!(dict[entry[1]], Set([entry[2]])), entries)

    function _canBeContainedBy(color)
        answer = Set{String}()
        !haskey(dict, color) && return answer
        foreach(child -> union!(answer, Set([child]), _canBeContainedBy(child)), dict[color])
        answer
    end

    _canBeContainedBy(color)
end

@assert length(canBeContainedBy(exampleBagRules, "shiny gold")) == 4
@printf("part1 = %d\n", length(canBeContainedBy(inputBagRules, "shiny gold")))
#@btime length(canBeContainedBy(inputBagRules, "shiny gold"));

#### part 2

function countBags(bagRules, color)
    bagRuleDict = Dict(bagRule.color => bagRule for bagRule ∈ bagRules)
    _countBags(color) = haskey(bagRuleDict, color) ? reduce(+, bagCount.n * (1 + _countBags(bagCount.color)) for bagCount ∈ bagRuleDict[color].contains; init = 0) : 0
    _countBags(color)
end

@assert countBags(exampleBagRules, "faded blue") == 0
@assert countBags(exampleBagRules, "dotted black") == 0
@assert countBags(exampleBagRules, "vibrant plum") == 11
@assert countBags(exampleBagRules, "dark olive") == 7
@assert countBags(exampleBagRules, "shiny gold") == 32

@printf("part2 = %d\n", countBags(inputBagRules, "shiny gold"))
#@btime countBags(inputBagRules, "shiny gold");
