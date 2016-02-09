//
//  CuckooSearch.swift
//  SwiftEA
//
//  Created by Ng Tzy Luen.
//  Copyright © 2016 TzyInc. All rights reserved.
//

import Foundation

struct Nest {
    var egg: [UInt8]
    var fitness: Int
}

class CuckooSearch {
    var optimal: [UInt8]
    var populationSize: Int
    var generations: Int
    var Pa: Float
    var Pc: Float
    var population: [Nest]
    
    
    init(optimal: [UInt8], populationSize: Int, generations: Int, Pa: Float, Pc: Float) {
        self.optimal = optimal
        self.populationSize = populationSize
        self.generations = generations
        self.Pa = Pa
        self.Pc = Pc
        self.population = [Nest]()
    }
    
    
    func run() -> [UInt8] {
        var fittest = [UInt8]()
        
        // Generate an initial population of n host nests
        self.population = self.randomPopulation(populationSize: self.populationSize,
                                                dnaSize: self.optimal.count)
        
        var t = 0
        // While (t < MaxGeneration) or (stop criterion)
        while fittest != self.optimal {
            t += 1
            
            // Get a cuckoo randomly (say, i) and replace its solution by performing levy flight
            // Evaluate its quality/fitness Fi
            let fi = irand(ubound: Int(Float(self.populationSize) * self.Pc))
            let cuckoo = self.levyflight(Fi: fi)
            let Fi = Nest(egg: cuckoo, fitness: fx(dna: cuckoo, optimal: self.optimal))
            
            // Choose a nest among n (say, j) randomly
            let fj = irand(ubound: Int(Float(self.populationSize) * self.Pc))
            let Fj = self.population[fj].egg
            
            // if (Fi < Fj)
            //      replace j by the new solution Fi
            if Fi.fitness < fx(dna: Fj, optimal: self.optimal) {
                self.population[fj] = Fi
            }
            
            // A fraction Pa of the worse nests are abondoned and new ones are built
            // Keep the best solutions/nests
            self.abandon()
            
            // Rank the solutions or nests, and find the current best
            self.population.sort { (x: Nest, y: Nest)  -> Bool in
                return x.fitness < y.fitness
            }
            
            fittest = self.population[0].egg
            
            print("Generation \(t), fitness \(self.population[0].fitness): " +
                  "\(String(bytes: fittest, encoding:.ascii)!)")
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
     * returns random integer from 0 to ubound - 1
     */
    func irand(ubound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(ubound)))
    }
    
    
    /**
     * returns random float from 0.0 and 1.0
     */
    func frand() -> Float {
        return Float(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    
    /**
     * returns a random float with step-lengths have a probability distribution
     * that is heavy-tailed
     */
    func levyflight(b: Float) -> Float {
        return powf(b, -1.0/3.0)
    }
    
    
    /**
     * mutation operator:
     * each char in the new egg has:
     *      levyflight() chance of differing from original/current fittest cuckoo
     */
    func levyflight(Fi: Int) -> [UInt8] {
        var egg = self.population[Fi].egg
        
        for i in 0..<egg.count {
            // big-jump
            if levyflight(b: frand()) > 2 {
                let x = irand(ubound: charset.count)
                egg[i] = charset[x]
            } else {
            // regular
                egg[i] = self.population[Fi].egg[i]
            }
        }
        
        return egg
    }

    
    /**
     * abandon a fraction Pa of the worse nests and replace with new nests
     */
    func abandon() {
        let keep:Int = Int((1.0 - self.Pa) * Float(self.populationSize))
        for i in (keep..<self.populationSize).reversed() {
            let f = levyflight(Fi: irand(ubound: self.populationSize))
            let newNest = Nest(egg: f, fitness: fx(dna: f, optimal: self.optimal))
            self.population[i] = newNest
        }
    }
    
    
    /**
     * returns a random population
     */
    func randomPopulation(populationSize: Int, dnaSize: Int) -> [Nest] {
        var nests:[Nest] = [Nest]()
        for _ in 0..<populationSize {
            var dna = [UInt8]()
            for _ in 0..<dnaSize {
                let c = charset[irand(ubound: charset.count)]
                dna.append(c)
            }
            let n = Nest(egg: dna, fitness: fx(dna: dna, optimal: self.optimal))
            nests.append(n)
        }
        
        return nests
    }
}
