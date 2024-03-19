module TimeSpec exposing (main)

import Main as App
import Spec exposing (..)
import Spec.Setup as Setup
import Spec.Markup as Markup
import Spec.Markup.Selector exposing (..)
import Spec.Claim as Claim
import Spec.Http.Stub as Stub
import Spec.Time
import Runner
import Extra exposing (..)
import Helpers exposing (..)


timePassesSpec : Spec App.Model App.Msg
timePassesSpec =
  describe "time display"
  [ scenario "when the app starts" (
      given (
        Setup.init (App.init testFlags)
          |> Setup.withUpdate App.update
          |> Setup.withView App.view
          |> Setup.withSubscriptions App.subscriptions
          |> Stub.serve
            [ successfulThingsStub
            , successfulAccessTokenStub
            ]
          |> Spec.Time.withTime 1710807777458
      )
      |> it "displays the current time in seconds" (
        expectTimeDisplayed "1710807777"
      )
    )
  , scenario "when time passes" (
      given (
        Setup.init (App.init testFlags)
          |> Setup.withUpdate App.update
          |> Setup.withView App.view
          |> Setup.withSubscriptions App.subscriptions
          |> Stub.serve
            [ successfulThingsStub
            , successfulAccessTokenStub
            ]
          |> Spec.Time.withTime 1710807777458
      )
      |> when "30 seconds pass"
        [ Spec.Time.tick 30000
        ]
      |> it "updates the time" (
        expectTimeDisplayed "1710807807"
      )
    )
  ]


expectTimeDisplayed expectedTime =
  Markup.observeElement
    |> Markup.query << by [ attributeName "data-current-time" ]
    |> expect (
      Claim.isSomethingWhere <|
        Markup.text <|
        equals expectedTime
    )


main =
  Runner.browserProgram
    [ timePassesSpec
    ]
