import XCTest
@testable import SwiftGraphQLCodegen


final class EnumTests: XCTestCase {
    func testGenerateEmptyEnum() {
        let type = GraphQL.EnumType(
            name: "Episodes",
            description: "Collection of all StarWars episodes.",
            enumValues: []
        )
        
        let expected = """
        /// Collection of all StarWars episodes.
        enum Episodes: String, CaseIterable, Codable {

        }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateEnum(type), expected)
    }
    
    func testGenerateEnumWithoutDescription() {
        let type = GraphQL.EnumType(
            name: "Episodes",
            description: "Collection of all StarWars episodes.",
            enumValues: [
                GraphQL.EnumValue(
                    name: "NEWHOPE",
                    description: "Released in 1977.",
                    isDeprecated: false,
                    deprecationReason: nil
                ),
            ]
        )
        
        let expected = """
        /// Episodes
        enum Episodes: String, CaseIterable, Codable {
            /// Released in 1977.
            case newhope = "NEWHOPE"
        }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateEnum(type), expected)
    }
    
    
    
    func testGenerateEnumWithDescription() {
        /* Declaration */
        
        let type = GraphQL.EnumType(
            name: "Episodes",
            description: "Collection of all StarWars episodes.",
            enumValues: [
                GraphQL.EnumValue(
                    name: "NEWHOPE",
                    description: "Released in 1977.",
                    isDeprecated: false,
                    deprecationReason: nil
                ),
                GraphQL.EnumValue(
                    name: "EMPIRE",
                    description: nil,
                    isDeprecated: false,
                    deprecationReason: nil
                ),
                GraphQL.EnumValue(
                    name: "JEDI",
                    description: "Released in 1983.",
                    isDeprecated: true,
                    deprecationReason: "Was too good."
                ),
                GraphQL.EnumValue(
                    name: "SKYWALKER",
                    description: nil,
                    isDeprecated: true,
                    deprecationReason: nil
                ),
            ]
        )
        
        let expected = """
        /// Collection of all StarWars episodes.
        enum Episodes: String, CaseIterable, Codable {
            /// Released in 1977.
            case newhope = "NEWHOPE"

            case empire = "EMPIRE"

            /// Released in 1983.
            @available(*, deprecated, message: "Was too good.")
            case jedi = "JEDI"

            @available(*, deprecated, message: "")
            case skywalker = "SKYWALKER"
        }
        """
        
        /* Test */
        
        XCTAssertEqual(GraphQLCodegen.generateEnum(type), expected)
    }
}

