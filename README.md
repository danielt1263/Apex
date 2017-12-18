# Apex

Apex is designed to help you architect your app in a declarative manner with a clear separation between the logic of the app and the side effects it necessarily creates.

This is accomplished by imagining your app as a [Moore type State Machine](https://en.wikipedia.org/wiki/Moore_machine). As mentioned in the Wikipedia article, a Moore Machine can be defined by referring to the parts that make it up.

 - The set of states: This is modeled in Apex by a State struct that you provide. It is important that it be a struct so that code outside the Store cannot modify it except through the prescribed interface. This struct represents all possible states that your app can be in. The struct can be mutable because it's a value type. The source of truth resides in the Apex Store.
 - A start state: This is modeled in Apex by the value of your state struct that you pass into the Apex store. The initial state of your app could be modeled by the default `init` method of the State struct, but you could also load a state value from persistent storage and feed it in.
 - The input alphabet: This is modeled in Apex by `Action` values. An action can be any type but it is important that all actions are immutable. For this reason, it makes the most sense for them to be enums but they could also be structs or even classes, as long as all properties are immutable.
 - A transition function: This is modeled by the update function that is passed in when the Store is constructed. This function represents the logic of your app and is the only place where state transformations take place. Your update function needs to be [referentially transparent](https://en.wikipedia.org/wiki/Referential_transparency). Of course, this function can call other functions through functional decomposition.
 - An output function: In Apex, the output function is modeled by the various functions that subscribe to the store. The output functions are where you perform all of your side effects in response to state changes.
 
## Using Apex
To use Apex, you create a single `Store` object to manage the State of your app. This store object can either be a global or passed to objects that need access to or need to change the state.

### Handling Asynchronousity and Side Effects.

Apex deals with asynchronousity and side effects in two ways, `Command`s and `Subscription`s.

Use commands when you need some sort of one-off job to be done. Examples include many network requests as well as getting a random number or anything that you can essentially fire and forget until the response comes back. Commands *can* be used for continuious monotoring of something, but keep in mind that a Command cannot be canceled once it has been launched.

Use subscriptions for monotoring ongoing tasks or side effects that need to be cancled. This includes View Controllers.

#### Network Commands

Since the most common use of the system is for network requests, a special `URLCommand` has been added to the library. Whenever you need to make a network request, create a URLCommand in your reducer and return it. You can test that the correct commands are being returned because all commands are equatable. The Store will execute any commands you return from your reducer.

#### View Controller management

Another useful component that comes with the system is the `ViewControllerPresentationComponent`. To use this component, create one by passing in the window's root view controller, the store and a lens/selector (a function that extracts the apporprate part of your state for this component.) Your State object will need a property that represents an array of `ViewController`s which are hashable types that act as `UIViewController` factories. This component will present and dismiss UIViewControllers as necessary to conform to the array in your state. To present a view controller, add it's factory to your state's ViewController array, to dismiss one remove it from the array. As with Actions, your type that conforms to the `ViewController` protocol can be any type as long as it's immutable but it makes the most sense to make it an enum.
