//
//  Utils.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 23/12/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import Foundation

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}
