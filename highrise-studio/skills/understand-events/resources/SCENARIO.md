# Event report: $SCENARIO

<!-- Give a brief description of the scenario that the user is asking about. -->

## Relevant events
### `MyRequest`
- Created in: `MyScript1.lua`
- Local? `Yes` or `No`
- Fired in:  <!-- add one entry for each occurrence of a `Fire*()` call -->
    - `MyScript1.lua:PublicFunction1()`
        - **Is this function local?** TODO
        - **What functions, if any, call this function?** TODO
        - **Is this function called on the client, the server, or both?** TODO
        - **When this function is called, what conditions must be met for the event to be fired?** TODO
        - **What type of `Fire*()` call is this?** TODO (Client, Server, AllClients, etc.)
        - **What arguments, if any, are passed to the `Fire*()` call?** TODO
    - ...
- Connected to in:  <!-- add one entry for each occurrence of a `Connect()` call -->
    - `MyScript2.lua:PublicFunction2()`
        - **Is this function called on the client, the server, or both?** TODO
        - **When this function is called, what conditions must be met for the event to be connected to?** TODO
        - **What arguments does the callback depend on?** TODO
        - **What does the callback do?** TODO
    - ...

### `MyResponse`
... <!-- repeat the above sections for each event -->

## Sequence diagrams
<!-- Add one sequence diagram for each potential sequence of event fires and connections. -->
### Situation 1
<!-- Describe the situation that the sequence diagram is representing. For example, "A single client connects along with the server." -->
```mermaid
sequenceDiagram
    participant Client1
    participant Server
    par serverStart
        Server->>Server: Start
        Server->>Server: Connect to MyRequest
    and client1Start
        Client1->>Client1: Start
        Client1->>Client1: Connect to MyResponse
    end
    Note over Client1: Waits 1 second
    Client1->>Server: MyRequest (arg0: "C1")
    Note over Server: Waits 1 second
    Server->>Client1: MyResponse (arg0: "C1")
    Client1->>Client1: print("C1")
    Note over Server: Waits 1 second
    Server->>Client1: MyResponse (arg0: "C1")
    Client1->>Client1: print("C1")
```

### Situation 2
<!-- Describe another situation that the next sequence diagram will represent. For example, "A second client joins shortly after the first client." -->
...

### Situation 3 <!-- Add as many of these sections as needed to cover any potential sequences of event fires and connections.>
...
<!-- EOF. Do not add any other sections. -->