//
//  Command.swift
//  Apex
//
//  Created by Daniel Tartaglia on 11/27/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License
//



public
protocol Command {
	func execute(dispatcher: Dispatcher)
}
