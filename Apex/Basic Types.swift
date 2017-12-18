//
//  Basic Types.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/17/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License
//


enum Result<T> {
	case success(T)
	case failure(Error)
}

struct UnknownError: Error { }
