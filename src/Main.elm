module Main exposing (..)
import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode as Json
import Api exposing (AccessToken)
import State exposing (ProgramState(..))
import Time exposing (Posix)
import Task

type alias Model =
  { apiBaseUrl: String
  , state: ProgramState
  , currentTime: Posix
  }


defaultModel : String -> Model
defaultModel apiBaseURL =
  { apiBaseUrl = apiBaseURL
  , state = Unauthenticated
  , currentTime = Time.millisToPosix 0
  }


type Msg
  = FetchedAccessToken (Result Http.Error AccessToken)
  | FetchedThings (Result Http.Error (List String))
  | TimeUpdated Posix


view : Model -> Html Msg
view model =
  case model.state of
    Unauthenticated ->
      Html.h1 [] [ Html.text "You do not have access!" ]
    Authenticated state ->
      Html.div []
      [ currentTimeView model.currentTime
      , Html.ul [ Attr.id "things" ] <|
        List.map thingView state.things
      ]


currentTimeView : Posix -> Html Msg
currentTimeView time =
  Html.div [ Attr.attribute "data-current-time" "" ]
    [ (Time.posixToMillis time // 1000)
      |> String.fromInt
      |> Html.text
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
    TimeUpdated posix ->
      ( { model | currentTime = posix }, Cmd.none )

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
  Time.every 1000 TimeUpdated


init : Flags -> ( Model, Cmd Msg )
init flags =
  ( defaultModel flags.apiBaseURL
  , Cmd.batch
    [ Api.fetchAccessToken flags.apiBaseURL FetchedAccessToken
    , Time.now
      |> Task.perform TimeUpdated
    ]
  )


main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }