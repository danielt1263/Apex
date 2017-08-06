# Apex

Apex is designed to help you architect your app in a declarative manner with a clear separation between the logic of the app and the side effects it necessarily creates.

This is accomplished by imagining your app as a [Moore type State Machine](https://en.wikipedia.org/wiki/Moore_machine). As mentioned in the Wikipedia article, a Moore Machine can be defined by referring to the parts that make it up.

 - The set of states: This is modeled in Apex by a State struct that you provide. The struct must conform to the `State` protocol in order for Apex to use it. It is important that it be a struct so that code outside the Store cannot modify it except through the prescribed interface. This struct represents all possible states that your app can be in. The struct can be mutable because it's a value type. The source of truth resides in the Apex Store.
 - A start state: This is modeled in Apex by the value of your state struct that you pass into the Apex store. The initial state of your app should be modeled by the default `init` method of the State struct, but you could also load a state value from persistent storage and feed it in.
 - The input alphabet: This is modeled in Apex by `Action` values. An action can be any type that conforms to the Action tagging protocol but it is important that all actions are immutable. For this reason, it makes the most sense for them to be enums but they could also be structs or even classes, as long as all properties are immutable.
 - A transition function: This is modeled by the transition function that must be implemented by your State struct. This function represents the logic of your app and is the only place where state transformations take place. Your transition function needs to be [referentially transparent](https://en.wikipedia.org/wiki/Referential_transparency). Of course, this function can call other functions through functional decomposition.
 - An output function: In Apex, the output function is modeled by the various functions that subscribe to the store. The output functions are where you perform all of your side effects in response to state changes.
 
## Using Apex
To use Apex, you simply need to create a single Store object to manage the State of your app. This store object can either be a global or passed to objects that need access to or need to change the state.

### Handling Asynchronous commands.

To those have heard of redux, the above will sound  familiar, but notice that Apex has no notion of `middleware` to handle asynchronous actions. Instead, Apex deals with asynchronous commands through a `CommandComponent`.

The command component isn't necessary for Apex to work, and simple apps that don't need it can ignore it. In order for an App to handle commands, simply create a type that conforms to the `Command` protocol and put a `Set<MyCommand>` inside your state that represents all the commands that should currently be active. After you have that, create a CommandComponent (one for each type of command) and keep it with your Store object.

In order to create a command component, provide a `lens`. A lens is a function that knows how to navigate through your State value to get to the underlying command Set.

Commands can be both launched and canceled. To launch a command, insert one into your state's command set. Then the CommandComponent will launch that command. When your transition removes a command from its set, the component will cancel that command.

One important thing to remember is to remove commands if they naturally complete so as not to fill the set with commands that are no longer needed.

#### Network Commands

Since the most common use of the system is for network requests, a special `URLRequestComponent` has been added to the library that uses the CommandComponent in its implementation. This component already has an implemented command class: `URLRequestCommand`, its own actions `URLRequestAction` and state object `URLRequestState`.

To use this, add a URLRequestState object as a property of your State struct and be sure to call its `transition` function from inside your transition function. Then create a URLRequestComponent.

The URLRequestComponent you created will make network requests when they are added to the state and cancel them if they are removed from the state before they complete. When they complete naturally, the URLRequestState object will remove them from its Set of requests.
