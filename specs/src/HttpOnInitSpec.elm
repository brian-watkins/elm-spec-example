module HttpOnInitSpec exposing (main)

import Main as App
import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Claim as Claim
import Spec.Http
import Spec.Http.Stub as Stub
import Spec.Http.Route as Route
import Json.Encode as Encode
import Extra exposing (..)
import Runner


makeHtttpRequestOnInitSpec : Spec App.Model App.Msg
makeHtttpRequestOnInitSpec =
  describe "An authenticated HTTP request is made to fetch things when the app starts"
  [ scenario "the access token request fails" (
      given (
        Setup.init (App.init testFlags)
          |> Setup.withUpdate App.update
          |> Setup.withView App.view
          |> Stub.serve
            [ failedAccessTokenStub
            ]
      )
      |> it "displays an error message" (
        Markup.observeElement
          |> Markup.query << by [ tag "h1" ]
          |> expect (
            Claim.isSomethingWhere <|
              Markup.text <| 
              equals "You do not have access!"
          )
      )
    )
  , scenario "both requests are successful" (
      given (
        Setup.init (App.init testFlags)
          |> Setup.withUpdate App.update
          |> Setup.withView App.view
          |> Stub.serve
            [ successfulThingsStub
            , successfulAccessTokenStub
            ]
      )
      |> observeThat
        [ it "sends the access token in the request for things" (
            Spec.Http.observeRequests (Route.get testThingsUrl)
              |> expect (
                Claim.isListWhere
                  [ Spec.Http.header "Authorization" <|
                      Claim.isSomethingWhere <|
                      Claim.isStringContaining 1 testAccessToken
                  ]
              )
          )
        , it "displays the results of the request for things" (
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
        ]
    )
  , scenario "the things request is unsuccessful" (
      given (
        Setup.init (App.init testFlags)
          |> Setup.withUpdate App.update
          |> Setup.withView App.view
          |> Stub.serve [ successfulAccessTokenStub, failedThingsStub ]
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
  { apiBaseURL = "http://testing-only.com/api"
  }

testAccessTokenUrl =
  testFlags.apiBaseURL ++ "/accessToken"

testThingsUrl =
  testFlags.apiBaseURL ++ "/things"

testAccessToken =
  "my-fake-access-token"

successfulAccessTokenStub =
  Stub.for (Route.get testAccessTokenUrl)
    |> Stub.withBody (Stub.withJson <| Encode.string testAccessToken)

failedAccessTokenStub =
  Stub.for (Route.get testAccessTokenUrl)
    |> Stub.withStatus 403

successfulThingsStub =
  Stub.for (Route.get testThingsUrl)
    |> Stub.withBody (Stub.withJson <|
      Encode.list Encode.string [ "birds", "fish", "trees" ]
    )

failedThingsStub =
  Stub.for (Route.get testThingsUrl)
    |> Stub.withStatus 403

main =
  Runner.browserProgram
    [ makeHtttpRequestOnInitSpec
    ]
