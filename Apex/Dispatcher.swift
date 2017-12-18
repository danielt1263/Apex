//
//  Dispatcher.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/16/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License
//



public
protocol Dispatcher {
	func dispatch(action: Action)
}
