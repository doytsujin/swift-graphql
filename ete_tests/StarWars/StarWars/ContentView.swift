import SwiftUI
import SwiftGraphQL

/* Playground */


struct Character: Identifiable {
    let id: String
    let name: String
    let message: String
}

let character = Selection<Character, Interfaces.Character> {
    Character(
        id: $0.id(),
        name: $0.name(),
        message: $0.on(
            droid: .init { $0.primaryFunction() },
            human: .init { $0.homePlanet() ?? "Unknown" }
        )
    )
}

struct Human {
    let id: String
    let name: String
    let url: String?
}

let human = Selection<Human, Objects.Human> {
    Human(
        id: $0.id(),
        name: $0.name(),
        url: $0.infoUrl()
    )
}

let characterInterface = Selection<String, Interfaces.Character> {
    
    /* Common */
    let name = $0.name()
    
    /* Fragments */
    let about = $0.on(
        droid: Selection<String, Objects.Droid> { droid in droid.primaryFunction() },
        human: Selection<String, Objects.Human> { human in human.infoUrl() ?? "Unknown" }
    )
    
    return "\(name). \(about)"
}

let characterUnion = Selection<String, Unions.CharacterUnion> {
    $0.on(
        human: .init { $0.infoUrl() ?? "Unknown" },
        droid: .init { $0.primaryFunction() }
    )
}

struct Model {
    let whoami: String
    let time: DateTime?
    let greeting: String
    let character: String
    let characters: [Character]
}

let query = Selection<Model, Operations.Query> {
    let english = $0.greeting()
    let slovene = $0.greeting(input: .present(.init(name: "Matic")))
    
    let greeting = "\(english); \(slovene)"
    
    return Model(
        whoami: $0.whoami(),
        time: $0.time(),
        greeting: greeting,
        character: $0.character(id: "3000", characterUnion.nullable) ?? "No character",
        characters: $0.characters(character.list)
    )
}

/* View */

class AppState: ObservableObject {
    // MARK: - State
    
    @Published private(set) var model = Model(
        whoami: "Who knows!?",
        time: nil,
        greeting: "Not greeted yet.",
        character: "NONE",
        characters: []
    )

    // MARK: - Intentions
    
    func fetch() {
        print("FETCHING")
        SG.send(
            query,
            to: "http://localhost:4000",
            headers: ["Authorization": "Bearer Matic"]
        ) { result in
            do {
                let data = try result.get()
                print("DATA")
                print(data)
                DispatchQueue.main.async {
                    if let data = data.data {
                        self.model = data
                    }
                }
            } catch let error {
                print("ERROR")
                print(error)
            }
        }
    }
    
}

struct ContentView: View {
    @ObservedObject private var state = AppState()
    
    var body: some View {
        NavigationView {
            VStack {
                /* Greeting */
                HStack {
                    Text(state.model.greeting)
                        .font(.headline)
                    Spacer()
                    Text(state.model.character)
                }
                .padding()
                /* Time */
                HStack {
                    Text(state.model.time?.value ?? "What's the time??")
                        .font(.headline)
                    Spacer()
                    Text("\(state.model.time?.raw ?? 0)")
                        .font(.headline)
                }
                .padding()
                /* Authorization */
                HStack {
                    Text(state.model.whoami)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                /* Characters */
                List {
                    ForEach(state.model.characters, id: \.id) { character in
                        VStack {
                            Text(character.name)
                            Text(character.message)
                        }
                    }
                }
            }
            .navigationTitle("StarWars 🌌")
        }
        .onAppear(perform: {
            state.fetch()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
