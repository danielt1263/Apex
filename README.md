# Apex
A Swift model management library with async capability built in.

Apex is designed to help you archetect your app in a declarative manor with a clear sepration between the logic of the app and the side effects it necessarally creates.

This is accomplished by imagining your app as a [Moore type State Machine](https://en.wikipedia.org/wiki/Moore_machine). As mentioned in the Wikipedia article, a Moore Machine can be defined by refering to the parts that make it up.

 - The set of states: This is modeled in Apex by a State struct that you provide. It is important that it be a struct becuase (reasons). This struct represents all possible states that your app can be in. The struct can be mutable because it's a value type. The source of truth resides in the Apex store.
 - A start state: This is modeled in Apex by the value of your state struct that you pass into the Apex store.
 - The input alphebet: This is modeled in Apex by `Action` values. An action can be any type that conforms to the Action tagging protocol but it is important that all actions are immutable. For this reason, it makes the most sense for them to be enums but they could also be structs or even classes, as long as all properties are immutable.
 - A transition function: This is modeled by a function passed into the Apex Store init called the reducer. This function represents the logic of your app and is the only place where state transformations take place. Your reducer function needs to be [referentially transparent] (https://en.wikipedia.org/wiki/Referential_transparency). 
 - An output function: In Apex, the output function is modeled by the various functions that subscribe to the store. The output functions are where you perform all of your side effects. 
 
 