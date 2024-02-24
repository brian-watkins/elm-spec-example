module Main exposing (..)
import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode as Json

type alias Model =
  { things: List String
  }

defaultModel : Model
defaultModel =
  { things = 
    [ "Default Thing 1"
    , "Default Thing 2"
    ]
  }

type Msg
  = FetchedThings (Result Http.Error (List String))

view : Model -> Html Msg
view model =
  Html.div []
  [ Html.ul [ Attr.id "things" ] <|
    List.map thingView model.things
  ]

thingView : String -> Html Msg
thingView thing =
  Html.li [] [ Html.text thing ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FetchedThings result ->
      case result of
        Ok things ->
          ( { model | things = things }, Cmd.none )
        Err _ ->
          ( model, Cmd.none )


fetchThings : String -> Cmd Msg
fetchThings url =
  Http.get
    { url = url
    , expect = Http.expectJson FetchedThings (Json.list Json.string)
    }

type alias Flags =
  { apiURL: String
  }

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

init : Flags -> ( Model, Cmd Msg )
init flags =
  ( defaultModel, fetchThings flags.apiURL )

main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }