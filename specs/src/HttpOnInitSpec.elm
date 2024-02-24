module HttpOnInitSpec exposing (main)

import Main as App
import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Claim as Claim
import Spec.Http.Stub as Stub
import Spec.Http.Route as Route
import Json.Encode as Encode
import Extra exposing (..)
import Runner


makeHtttpRequestOnInitSpec : Spec App.Model App.Msg
makeHtttpRequestOnInitSpec =
  describe "An HTTP request is made when the app starts"
  [ scenario "the request is successful" (
      given (
        Setup.init (App.init testFlags)
          |> Setup.withUpdate App.update
          |> Setup.withView App.view
          |> Stub.serve [ successStub ]
      )
      |> it "displays the results of the request" (
        Markup.observeElements
          |> Markup.query << by [ tag "li" ]
          |> expect (
            Claim.isListWhere
              [ Markup.text <| equals "birds"
              , Markup.text <| equals "fish"
              , Markup.text <| equals "trees"
              ]
          )
      )
    )
  , scenario "the request is unsuccessful" (
      given (
        Setup.init (App.init testFlags)
          |> Setup.withUpdate App.update
          |> Setup.withView App.view
          |> Stub.serve [ failureStub ]
      )
      |> it "displays some default things" (
        Markup.observeElements
          |> Markup.query << by [ tag "li" ]
          |> expect (
            Claim.isListWhere
              [ Markup.text <| equals "Default Thing 1"
              , Markup.text <| equals "Default Thing 2"
              ]
          )
      )
    )
  ]

testFlags : App.Flags
testFlags =
  { apiURL = "http://testing-only.com/api/things"
  }

successStub =
  Stub.for (Route.get testFlags.apiURL)
    |> Stub.withBody (Stub.withJson <|
      Encode.list Encode.string [ "birds", "fish", "trees" ]
    )

failureStub =
  Stub.for (Route.get testFlags.apiURL)
    |> Stub.withStatus 403

main =
  Runner.browserProgram
    [ makeHtttpRequestOnInitSpec
    ]
