//
//  main.swift
//  SwiftGA
//
//  Created by Ng Tzy Luen.
//  Copyright © 2016 TzyInc. All rights reserved.
//


let charset : [UInt8] = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~".asciiArray
let OPTIMAL:[UInt8] = "In the beginning we were all fish. - Ms. Garrison".asciiArray
let POP_SIZE = 30
let GENERATIONS = 1000
let MUTATION_RATE = 15


// EA:
//var ea = EA(optimal: OPTIMAL, populationSize: POP_SIZE,
//            generations: GENERATIONS, mutationRate: MUTATION_RATE)
//var fittest = ea.run()


// CuckooSearch:
var cs = CuckooSearch(optimal: OPTIMAL, populationSize: POP_SIZE,
                      generations: GENERATIONS, Pa: 0.25, Pc: 0.60)
var fittest = cs.run()


print("fittest string: \(String(bytes: fittest, encoding: .ascii)!)")
