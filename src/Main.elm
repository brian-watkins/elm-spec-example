module Main exposing (..)
import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode as Json
import Api exposing (AccessToken)
import State exposing (ProgramState(..))

type alias Model =
  { apiBaseUrl: String
  , state: ProgramState
  }


defaultModel : String -> Model
defaultModel apiBaseURL =
  { apiBaseUrl = apiBaseURL
  , state = Unauthenticated
  }


type Msg
  = FetchedAccessToken (Result Http.Error AccessToken)
  | FetchedThings (Result Http.Error (List String))


view : Model -> Html Msg
view model =
  case model.state of
    Unauthenticated ->
      Html.h1 [] [ Html.text "You do not have access!" ]
    Authenticated state ->
      Html.div []
      [ Html.ul [ Attr.id "things" ] <|
        List.map thingView state.things
      ]


thingView : String -> Html Msg
thingView thing =
  Html.li [] [ Html.text thing ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FetchedAccessToken result ->
      case result of
        Ok token ->
          ( { model | state = Authenticated { accessToken = token, things = [] } }
          , fetchThings model.apiBaseUrl token
          )
        Err _ ->
          ( model, Cmd.none )
    FetchedThings result ->
      case result of
        Ok things ->
          ( { model | state = State.withThings model.state things }, Cmd.none )
        Err _ ->
          ( { model | state = State.withThings model.state State.defaultThings }, Cmd.none )


fetchThings : String -> AccessToken -> Cmd Msg
fetchThings baseUrl accessToken =
  Api.authenticatedRequest
    { accessToken = accessToken
    , url = baseUrl ++ "/things"
    , expect = Http.expectJson FetchedThings (Json.list Json.string)
    }


type alias Flags =
  { apiBaseURL: String
  }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


init : Flags -> ( Model, Cmd Msg )
init flags =
  ( defaultModel flags.apiBaseURL
  , Api.fetchAccessToken flags.apiBaseURL FetchedAccessToken
  )


main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }