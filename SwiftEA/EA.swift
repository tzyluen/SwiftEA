//
//  EA.swift
//  SwiftGA
//
//  Created by Ng Tzy Luen.
//  Copyright © 2016 TzyInc. All rights reserved.
//

import Foundation

class EA {
    var optimal: [UInt8]
    var populationSize: Int
    var generations: Int
    var mutationRate: Int
    var population: [[UInt8]]
    
    init(optimal: [UInt8], populationSize: Int, generations: Int, mutationRate: Int) {
        self.optimal = optimal
        self.populationSize = populationSize
        self.generations = generations
        self.mutationRate = mutationRate
        self.population = [[]]
    }
    
    
    func run() -> [UInt8] {
        // initialization
        var fittest = [UInt8]()
        self.population = self.randomPopulation(populationSize: self.populationSize,
                                                dnaSize: self.optimal.count)
        
        var (g, best, bestIndex, unfit) = (0, 0, 0, 0)
        while fittest != self.optimal {
            g += 1
            // mutation
            for i in 1..<self.populationSize {
                self.population[i] = self.mutate(dna1: self.population[0],
                                                 dna2: self.population[i],
                                                 rate: self.mutationRate)
            }
            
            // find the best fitting string
            bestIndex = 0
            for i in 0..<self.populationSize {
                unfit = fx(dna: self.population[i], optimal: self.optimal)
                if ((unfit < best) || (i == 0)) {
                    best = unfit
                    bestIndex = i
                }
            }
            
            if bestIndex != 0 {
                fittest = self.population[bestIndex]
                self.population[0] = fittest
            }
            
            print("Generation \(g), fitness \(best): \(String(bytes: fittest, encoding:.ascii)!)")
        }
        
        return fittest
    }
    
    
    /**
     * fitness function:
     * compute the fitness value based on approximate string matching technique where
     * each character's ascii value is compared and adds to the delta of the total fitness
     *
     * returns a fitness value of integer type
     */
    func fx(dna: [UInt8], optimal: [UInt8]) -> Int {
        var fitness = 0
        for i in 0..<dna.count {
            if dna[i] != optimal[i] {
                fitness += 1
            }
        }
        
        return fitness
    }
    
    
    /**
     * mutation operator:
     * each char in dna2 has 1/rate chance of differing from original/current fittest dna1.
     *
     * notes:
     * if rate is too low - the algorithm will not cover the search space much
     * if rate is too high - good candidate solutions will be pertubated and pushed into worse solutions
     */
    func mutate(dna1: [UInt8], dna2: [UInt8], rate: Int) -> [UInt8] {
        var newDna = dna2
        for i in 0..<dna1.count {
            let rand = Int(arc4random_uniform(UInt32(rate)))
            if rand == 0 {
                let x = Int(arc4random_uniform(UInt32(charset.count)))
                newDna[i] = charset[x]
            } else {
                newDna[i] = dna1[i]
            }
        }
        
        return newDna
    }
    
    
    /**
     * returns a random population
     */
    func randomPopulation(populationSize: Int, dnaSize: Int) -> [[UInt8]] {
        let len = UInt32(charset.count)
        var p = [[UInt8]]()
        for _ in 0..<populationSize {
            var dna = [UInt8]()
            for _ in 0..<dnaSize {
                let rand = arc4random_uniform(len)
                let c = charset[Int(rand)]
                dna.append(c)
            }
            p.append(dna)
        }
        
        return p
    }
}


/**
 * helper String extension to convert a string to ascii value
 */
extension String {
    var asciiArray: [UInt8] {
        return unicodeScalars.filter{$0.isASCII}.map{UInt8($0.value)}
    }
}
